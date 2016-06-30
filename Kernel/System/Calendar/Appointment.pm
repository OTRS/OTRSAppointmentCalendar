# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Calendar::Appointment;

use strict;
use warnings;

use Digest::MD5;

use vars qw(@ISA);

use Kernel::System::VariableCheck qw(:all);
use Kernel::System::EventHandler;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Cache',
    'Kernel::System::Calendar',
    'Kernel::System::Calendar::Helper',
    'Kernel::System::Group',
    'Kernel::System::DB',
    'Kernel::System::Log',
    'Kernel::System::Daemon::SchedulerDB',
);

=head1 NAME

Kernel::System::Calendar.Appointment - appointment lib

=head1 SYNOPSIS

All appointment functions.

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object. Do not use it directly, instead use:

    use Kernel::System::ObjectManager;
    local $Kernel::OM = Kernel::System::ObjectManager->new();
    my $AppointmentObject = $Kernel::OM->Get('Kernel::System::Calendar::Appointment');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    @ISA = qw(
        Kernel::System::EventHandler
    );

    # init of event handler
    $Self->EventHandlerInit(
        Config => 'AppointmentCalendar::EventModulePost',
    );

    $Self->{CacheType} = 'Appointment';
    $Self->{CacheTTL}  = 60 * 60 * 24 * 20;

    return $Self;
}

=item AppointmentCreate()

creates a new appointment.

    my $AppointmentID = $AppointmentObject->AppointmentCreate(
        ParentID              => 1,                                       # (optional) valid ParentID for recurring appointments
        CalendarID            => 1,                                       # (required) valid CalendarID
        UniqueID              => 'jwioji-fwjio',                          # (optional) provide desired UniqueID; if there is already existing Appointment
                                                                          #            with same UniqueID, system will delete it
        Title                 => 'Webinar',                               # (required) Title
        Description           => 'How to use Process tickets...',         # (optional) Description
        Location              => 'Straubing',                             # (optional) Location
        StartTime             => '2016-01-01 16:00:00',                   # (required)
        EndTime               => '2016-01-01 17:00:00',                   # (required)
        AllDay                => 0,                                       # (optional) default 0
        TimezoneID            => 1,                                       # (optional) Timezone - it can be 0 (UTC)
        TeamID                => [ 1 ],                                   # (optional) must be an array reference if supplied
        ResourceID            => [ 1, 3 ],                                # (optional) must be an array reference if supplied
        Recurring             => 1,                                       # (optional) flag the appointment as recurring (parent only!)
        RecurrenceType        => 'Daily',                                 # (required if Recurring) Possible "Daily", "Weekly", "Monthly", "Yearly",
                                                                          #           "CustomWeekly", "CustomMonthly", "CustomYearly"

        RecurrenceFrequency   => [1, 3, 5],                               # (required if Custom Recurring) Recurrence pattern
                                                                          #           for CustomWeekly: 1-Mon, 2-Tue,..., 7-Sun
                                                                          #           for CustomMonthly: 1-1st, 2-2nd,.., 31th
                                                                          #           for CustomYearly: 1-Jan, 2-Feb,..., 12-Dec
                                                                          # ...
        RecurrenceCount       => 1,                                       # (optional) How many Appointments to create
        RecurrenceInterval    => 2,                                       # (optional) Repeating interval (default 1)
        RecurrenceUntil       => '2016-01-10 00:00:00',                   # (optional) Until date
        RecurrenceID          => '2016-01-10 00:00:00',                   # (optional) Expected start time for this occurrence
        RecurrenceExclude     => [                                        # (optional) Which specific occurrences to exclude
            '2016-01-10 00:00:00',
            '2016-01-11 00:00:00',
        ],
        NotificationTime                  => '2016-01-01 17:0:00',        # (optional) Point of time to execute the notification event
        NotificationTemplate              => 'Custom',                    # (optional) Template to be used for notification point of time
        NotificationCustomUnitCount       => '12',                        # (optional) minutes, hours or days count for custom template
        NotificationCustomUnit            => 'minutes',                   # (optional) minutes, hours or days unit for custom template
        NotificationCustomUnitPointOfTime => 'beforestart',               # (optional) Point of execute for custom templates
                                                                          #            Possible "beforestart", "afterstart", "beforeend", "afterend"
        UserID                => 1,                                       # (required) UserID
    );

returns parent AppointmentID if successful

Events:
    AppointmentCreate

=cut

sub AppointmentCreate {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(CalendarID Title StartTime EndTime UserID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    # prepare possible notification params
    $Self->_AppointmentNotificationPrepare(
        Data => \%Param,
    );

    # get calendar helper object
    my $CalendarHelperObject = $Kernel::OM->Get('Kernel::System::Calendar::Helper');

    # if Recurring is provided, additional parameters must be present
    if ( $Param{Recurring} ) {

        my @RecurrenceTypes = (
            "Daily",       "Weekly",       "Monthly",       "Yearly",
            "CustomDaily", "CustomWeekly", "CustomMonthly", "CustomYearly"
        );

        if (
            !$Param{RecurrenceType}
            || !grep { $_ eq $Param{RecurrenceType} } @RecurrenceTypes
            )
        {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "RecurrenceType invalid!",
            );
            return;
        }

        if (
            (
                $Param{RecurrenceType} eq 'CustomWeekly'
                || $Param{RecurrenceType} eq 'CustomMonthly'
                || $Param{RecurrenceType} eq 'CustomYearly'
            )
            && !$Param{RecurrenceFrequency}
            )
        {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "RecurrenceFrequency needed!",
            );
            return;
        }
    }

    $Param{RecurrenceInterval} ||= 1;

    if ( $Param{UniqueID} && !$Param{ParentID} ) {
        my %Appointment = $Self->AppointmentGet(
            UniqueID   => $Param{UniqueID},
            CalendarID => $Param{CalendarID},
        );

        # delete existing appointment with same UniqueID
        if ( %Appointment && $Appointment{AppointmentID} ) {
            $Self->AppointmentDelete(
                AppointmentID => $Appointment{AppointmentID},
                UserID        => $Param{UserID},
            );
        }
    }

    # check ParentID
    if ( $Param{ParentID} && !IsInteger( $Param{ParentID} ) ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "ParentID must be a number!",
        );
        return;
    }

    # check StartTime
    my $StartTimeSystem = $CalendarHelperObject->SystemTimeGet(
        String => $Param{StartTime},
    );
    if ( !$StartTimeSystem ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Invalid StartTime!",
        );
        return;
    }

    # check UniqueID
    if ( !$Param{UniqueID} ) {
        $Param{UniqueID} = $Self->GetUniqueID(
            CalendarID => $Param{CalendarID},
            StartTime  => $StartTimeSystem,
            UserID     => $Param{UserID},
        );
    }

    # check EndTime
    my $EndTimeValid = $CalendarHelperObject->SystemTimeGet(
        String => $Param{EndTime},
    );
    if ( !$EndTimeValid ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Invalid EndTime!",
        );
        return;
    }

    # check timezone
    if ( !defined $Param{TimezoneID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "TimezoneID not defined!",
        );
        return;
    }

    # check if array refs
    my %Arrays;
    for my $Parameter (
        qw(TeamID ResourceID RecurrenceFrequency RecurrenceExclude)
        )
    {
        if ( $Param{$Parameter} ) {
            if ( !IsArrayRefWithData( $Param{$Parameter} ) ) {
                $Kernel::OM->Get('Kernel::System::Log')->Log(
                    Priority => 'error',
                    Message  => "$Parameter not ARRAYREF!",
                );
                return;
            }

            my @Array = @{ $Param{$Parameter} };

            # remove undefined values
            @Array = grep { defined $_ } @Array;

            $Arrays{$Parameter} = join( ',', @Array ) if @Array;
        }
    }

    # check if numbers
    for my $Parameter (
        qw(Recurring RecurrenceCount RecurrenceInterval)
        )
    {
        if ( $Param{$Parameter} && !IsInteger( $Param{$Parameter} ) ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "$Parameter must be a number!",
            );
            return;
        }
    }

    # check RecurrenceUntil
    if ( $Param{RecurrenceUntil} ) {

        # usually hour, minute and second = 0. In this case, take time from StartTime
        $Param{RecurrenceUntil} = $CalendarHelperObject->TimeCheck(
            OriginalTime => $Param{StartTime},
            Time         => $Param{RecurrenceUntil},
        );

        my $RecurrenceUntilSystem = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->SystemTimeGet(
            String => $Param{RecurrenceUntil},
        );

        if (
            !$RecurrenceUntilSystem
            || $StartTimeSystem > $RecurrenceUntilSystem
            )
        {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Invalid RecurrenceUntil!",
            );
            return;
        }
    }

    # get db object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');
    my @Bind;

    # parent ID supplied
    my $ParentIDCol = my $ParentIDVal = '';
    if ( $Param{ParentID} ) {
        $ParentIDCol = 'parent_id,';
        $ParentIDVal = '?,';
        push @Bind, \$Param{ParentID};

        # turn off all recurring fields
        delete $Param{Recurring};
        delete $Param{RecurrenceType};
        delete $Param{RecurrenceFrequency};
        delete $Param{RecurrenceCount};
        delete $Param{RecurrenceInterval};
        delete $Param{RecurrenceUntil};
    }

    push @Bind, \$Param{CalendarID}, \$Param{UniqueID}, \$Param{Title}, \$Param{Description},
        \$Param{Location},   \$Param{StartTime}, \$Param{EndTime},     \$Param{AllDay},
        \$Param{TimezoneID}, \$Arrays{TeamID},   \$Arrays{ResourceID}, \$Param{Recurring},
        \$Param{RecurrenceType},     \$Arrays{RecurrenceFrequency}, \$Param{RecurrenceCount},
        \$Param{RecurrenceInterval}, \$Param{RecurrenceUntil},      \$Param{RecurrenceID},
        \$Arrays{RecurrenceExclude}, \$Param{NotificationDate},     \$Param{NotificationTemplate},
        \$Param{NotificationCustom}, \$Param{NotificationCustomRelativeUnitCount},
        \$Param{NotificationCustomRelativeUnit}, \$Param{NotificationCustomRelativePointOfTime},
        \$Param{NotificationCustomDateTime}, \$Param{UserID}, \$Param{UserID};

    my $SQL = "
        INSERT INTO calendar_appointment
            ($ParentIDCol calendar_id, unique_id, title, description, location, start_time,
            end_time, all_day, timezone_id, team_id, resource_id, recurring, recur_type, recur_freq,
            recur_count, recur_interval, recur_until, recur_id, recur_exclude, notify_time,
            notify_template, notify_custom, notify_custom_unit_count, notify_custom_unit,
            notify_custom_unit_point, notify_custom_date, create_time, create_by, change_time, change_by)
        VALUES ($ParentIDVal ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,
            current_timestamp, ?, current_timestamp, ?)
    ";

    # create db record
    return if !$DBObject->Do(
        SQL  => $SQL,
        Bind => \@Bind,
    );

    my $AppointmentID;

    # return parent id for appointment occurences
    if ( $Param{ParentID} ) {
        $AppointmentID = $Param{ParentID};
    }

    # get appointment id for parent appointment
    else {
        return if !$DBObject->Prepare(
            SQL => '
                SELECT id FROM calendar_appointment
                WHERE unique_id=? AND parent_id IS NULL
            ',
            Bind  => [ \$Param{UniqueID} ],
            Limit => 1,
        );

        while ( my @Row = $DBObject->FetchrowArray() ) {
            $AppointmentID = $Row[0];
        }

        # return if there is not appointment created
        if ( !$AppointmentID ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => 'Can\'t get AppointmentID from INSERT!',
            );
            return;
        }
    }

    # add recurring appointments
    if ( $Param{Recurring} ) {
        return if !$Self->_AppointmentRecurringCreate(
            ParentID    => $AppointmentID,
            Appointment => \%Param,
        );
    }

    # clean up list methods cache
    $Kernel::OM->Get('Kernel::System::Cache')->CleanUp(
        Type => $Self->{CacheType} . 'List' . $Param{CalendarID},
    );
    $Kernel::OM->Get('Kernel::System::Cache')->CleanUp(
        Type => $Self->{CacheType} . 'Days' . $Param{UserID},
    );

    # fire event
    $Self->EventHandler(
        Event => 'AppointmentCreate',
        Data  => {
            AppointmentID => $AppointmentID,
        },
        UserID => $Param{UserID},
    );

    return $AppointmentID;
}

=item AppointmentList()

get a hash of Appointments.

    my @Appointments = $AppointmentObject->AppointmentList(
        CalendarID          => 1,                                       # (required) Valid CalendarID
        StartTime           => '2016-01-01 00:00:00',                   # (optional) Filter by start date
        EndTime             => '2016-02-01 00:00:00',                   # (optional) Filter by end date
        TeamID              => 1,                                       # (optional) Filter by team
        ResourceID          => 2,                                       # (optional) Filter by resource
        Result              => 'HASH',                                  # (optional), HASH|ARRAY
    );

returns an array of hashes with select Appointment data or simple array of AppointmentIDs:

Result => 'HASH':

    @Appointments = [
        {
            AppointmentID => 1,
            CalendarID    => 1,
            UniqueID      => '20160101T160000-71E386@localhost',
            Title         => 'Webinar',
            Description   => 'How to use Process tickets...',
            Location      => 'Straubing',
            StartTime     => '2016-01-01 16:00:00',
            EndTime       => '2016-01-01 17:00:00',
            TimezoneID    => 1,
            AllDay        => 0,
            Recurring     => 1,                                           # for recurring (parent) appointments only
        },
        {
            AppointmentID => 2,
            ParentID      => 1,                                           # for recurred (child) appointments only
            CalendarID    => 1,
            UniqueID      => '20160101T180000-A78B57@localhost',
            Title         => 'Webinar',
            Description   => 'How to use Process tickets...',
            Location      => 'Straubing',
            StartTime     => '2016-01-02 16:00:00',
            EndTime       => '2016-01-02 17:00:00',
            TimezoneID    => 1,
            TeamID        => [ 1 ],
            ResourceID    => [ 1, 3 ],
            AllDay        => 0,
        },
        ...
    ];

Result => 'ARRAY':

    @Appointments = [ 1, 2, ... ]

=cut

sub AppointmentList {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(CalendarID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    # output array of hashes by default
    $Param{Result} = $Param{Result} || 'HASH';

    # cache keys
    my $CacheType        = $Self->{CacheType} . 'List' . $Param{CalendarID};
    my $CacheKeyStart    = $Param{StartTime} || 'any';
    my $CacheKeyEnd      = $Param{EndTime} || 'any';
    my $CacheKeyTeam     = $Param{TeamID} || 'any';
    my $CacheKeyResource = $Param{ResourceID} || 'any';

    # check cache
    my $Data = $Kernel::OM->Get('Kernel::System::Cache')->Get(
        Type => $CacheType,
        Key  => "$CacheKeyStart-$CacheKeyEnd-$CacheKeyTeam-$CacheKeyResource-$Param{Result}",
    );

    if ( ref $Data eq 'ARRAY' ) {
        return @{$Data};
    }

    # needed objects
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # check time
    if ( $Param{StartTime} ) {
        my $StartTimeSystem = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->SystemTimeGet(
            String => $Param{StartTime},
        );
        if ( !$StartTimeSystem ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "StartTime invalid!"
            );
            return;
        }
        $StartTimeSystem -= 24 * 60 * 60;    # allow 24h because of timezone differences
        $Param{StartTime} = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->TimestampGet(
            SystemTime => $StartTimeSystem,
        );
    }
    if ( $Param{EndTime} ) {
        my $EndTimeSystem = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->SystemTimeGet(
            String => $Param{EndTime},
        );
        if ( !$EndTimeSystem ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "EndTime invalid!"
            );
            return;
        }
        $EndTimeSystem += 24 * 60 * 60;    # allow 24h because of timezone differences
        $Param{EndTime} = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->TimestampGet(
            SystemTime => $EndTimeSystem,
        );
    }

    my $SQL = '
        SELECT id, parent_id, calendar_id, unique_id, title, description, location, start_time,
            end_time, timezone_id, team_id, resource_id, all_day, recurring, notify_time
        FROM calendar_appointment
        WHERE calendar_id=?
    ';

    my @Bind;

    push @Bind, \$Param{CalendarID};

    if ( $Param{StartTime} && $Param{EndTime} ) {

        $SQL .= 'AND (
            (start_time >= ? AND start_time < ?) OR
            (end_time > ? AND end_time <= ?) OR
            (start_time <= ? AND end_time >= ?)
        ) ';
        push @Bind, \$Param{StartTime}, \$Param{EndTime}, \$Param{StartTime}, \$Param{EndTime}, \$Param{StartTime},
            \$Param{EndTime};
    }
    elsif ( $Param{StartTime} && !$Param{EndTime} ) {

        $SQL .= 'AND end_time >= ? ';
        push @Bind, \$Param{StartTime};
    }
    elsif ( !$Param{StartTime} && $Param{EndTime} ) {

        $SQL .= 'AND start_time <= ? ';
        push @Bind, \$Param{EndTime};
    }

    $SQL .= 'ORDER BY id ASC';

    # db query
    return if !$DBObject->Prepare(
        SQL  => $SQL,
        Bind => \@Bind,
    );

    my @Result;

    ROW:
    while ( my @Row = $DBObject->FetchrowArray() ) {

        # team id
        my @TeamID = split( ',', $Row[10] // '' );
        if ( $Param{TeamID} ) {
            next ROW if !grep { $_ == $Param{TeamID} } @TeamID;
        }

        # resource id
        $Row[11] = $Row[11] ? $Row[11] : 0;
        my @ResourceID = $Row[11] =~ /,/ ? split( ',', $Row[11] ) : ( $Row[11] );
        if ( $Param{ResourceID} ) {
            next ROW if !grep { $_ == $Param{ResourceID} } @ResourceID;
        }

        my %Appointment = (
            AppointmentID    => $Row[0],
            ParentID         => $Row[1],
            CalendarID       => $Row[2],
            UniqueID         => $Row[3],
            Title            => $Row[4],
            Description      => $Row[5],
            Location         => $Row[6],
            StartTime        => $Row[7],
            EndTime          => $Row[8],
            TimezoneID       => $Row[9],
            TeamID           => \@TeamID,
            ResourceID       => \@ResourceID,
            AllDay           => $Row[12],
            Recurring        => $Row[13],
            NotificationDate => $Row[14],
        );
        push @Result, \%Appointment;
    }

    # if Result was ARRAY, output only IDs
    if ( $Param{Result} eq 'ARRAY' ) {
        my @ResultList;
        for my $Appointment (@Result) {
            push @ResultList, $Appointment->{AppointmentID};
        }
        @Result = @ResultList;
    }

    # cache
    $Kernel::OM->Get('Kernel::System::Cache')->Set(
        Type  => $CacheType,
        Key   => "$CacheKeyStart-$CacheKeyEnd-$CacheKeyTeam-$CacheKeyResource-$Param{Result}",
        Value => \@Result,
        TTL   => $Self->{CacheTTL},
    );

    return @Result;
}

=item AppointmentDays()

get a hash of days with Appointments in all user calendars.

    my %AppointmentDays = $AppointmentObject->AppointmentDays(
        StartTime           => '2016-01-01 00:00:00',                   # (optional) Filter by start date
        EndTime             => '2016-02-01 00:00:00',                   # (optional) Filter by end date
        UserID              => 1,                                       # (required) Valid UserID
    );

returns a hash with days as keys and number of Appointments as values:

    %AppointmentDays = {
        '2016-01-01' => 1,
        '2016-01-13' => 2,
        '2016-01-30' => 1,
    };

=cut

sub AppointmentDays {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(UserID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    # cache keys
    my $CacheType     = $Self->{CacheType} . 'Days' . $Param{UserID};
    my $CacheKeyStart = $Param{StartTime} || 'any';
    my $CacheKeyEnd   = $Param{EndTime} || 'any';

    # check time
    if ( $Param{StartTime} ) {
        my $StartTimeValid = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->SystemTimeGet(
            String => $Param{StartTime},
        );

        if ( !$StartTimeValid ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "StartTime invalid!"
            );
            return;
        }
    }
    if ( $Param{EndTime} ) {
        my $EndTimeValid = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->SystemTimeGet(
            String => $Param{EndTime},
        );

        if ( !$EndTimeValid ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "EndTime invalid!"
            );
            return;
        }
    }

    # check cache
    my $Data = $Kernel::OM->Get('Kernel::System::Cache')->Get(
        Type => $CacheType,
        Key  => "$CacheKeyStart-$CacheKeyEnd",
    );

    if ( ref $Data eq 'HASH' ) {
        return %{$Data};
    }

    # needed objects
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # get user groups
    my %GroupList = $Kernel::OM->Get('Kernel::System::Group')->PermissionUserGet(
        UserID => $Param{UserID},
        Type   => 'ro',
    );
    my @GroupIDs = sort keys %GroupList;

    my $SQL = "
        SELECT ca.start_time, ca.end_time
        FROM calendar_appointment ca
        JOIN calendar c ON ca.calendar_id = c.id
        WHERE c.group_id IN ( ${\(join ', ', @GroupIDs)} )
    ";

    my @Bind;

    if ( $Param{StartTime} && $Param{EndTime} ) {

        $SQL .= 'AND (
            (ca.start_time >= ? AND ca.start_time < ?) OR
            (ca.end_time > ? AND ca.end_time <= ?) OR
            (ca.start_time <= ? AND ca.end_time >= ?)
        ) ';
        push @Bind, \$Param{StartTime}, \$Param{EndTime}, \$Param{StartTime}, \$Param{EndTime}, \$Param{StartTime},
            \$Param{EndTime};
    }
    elsif ( $Param{StartTime} && !$Param{EndTime} ) {

        $SQL .= 'AND ca.end_time >= ? ';
        push @Bind, \$Param{StartTime};
    }
    elsif ( !$Param{StartTime} && $Param{EndTime} ) {

        $SQL .= 'AND ca.start_time <= ? ';
        push @Bind, \$Param{EndTime};
    }

    $SQL .= 'ORDER BY ca.id ASC';

    # db query
    return if !$DBObject->Prepare(
        SQL  => $SQL,
        Bind => \@Bind,
    );

    my %Result;

    while ( my @Row = $DBObject->FetchrowArray() ) {

        my ( $StartTime, $EndTime, $StartTimeSystem, $EndTimeSystem );

        # StartTime
        if ( $Param{StartTime} ) {
            $StartTime = $Row[0] lt $Param{StartTime} ? $Param{StartTime} : $Row[0];
        }
        else {
            $StartTime = $Row[0];
        }

        # EndTime
        if ( $Param{EndTime} ) {
            $EndTime = $Row[1] gt $Param{EndTime} ? $Param{EndTime} : $Row[1];
        }
        else {
            $EndTime = $Row[1];
        }

        # Get system times
        $StartTimeSystem = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->SystemTimeGet(
            String => $StartTime,
        );

        $EndTimeSystem = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->SystemTimeGet(
            String => $EndTime,
        );

        for (
            my $LoopSystemTime = $StartTimeSystem;
            $LoopSystemTime < $EndTimeSystem;
            $LoopSystemTime += 60 * 60 * 24
            )
        {
            my $LoopTime = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->TimestampGet(
                SystemTime => $LoopSystemTime,
            );

            $LoopTime =~ s/\s.*?$//gsm;

            if ( $Result{$LoopTime} ) {
                $Result{$LoopTime}++;
            }
            else {
                $Result{$LoopTime} = 1;
            }
        }
    }

    # cache
    $Kernel::OM->Get('Kernel::System::Cache')->Set(
        Type  => $CacheType,
        Key   => "$CacheKeyStart-$CacheKeyEnd",
        Value => \%Result,
        TTL   => $Self->{CacheTTL},
    );

    return %Result;
}

=item AppointmentGet()

get Appointment.

    my %Appointment = $AppointmentObject->AppointmentGet(
        AppointmentID => 1,                                  # (required)
                                                             # or
        UniqueID      => '20160101T160000-71E386@localhost', # (required) will return only parent for recurring appointments
        CalendarID    => 1,                                  # (required)
    );

returns a hash:
    %Appointment = (
        AppointmentID       => 2,
        ParentID            => 1,                                  # only for recurred (child) appointments
        CalendarID          => 1,
        UniqueID            => '20160101T160000-71E386@localhost',
        Title               => 'Webinar',
        Description         => 'How to use Process tickets...',
        Location            => 'Straubing',
        StartTime           => '2016-01-01 16:00:00',
        EndTime             => '2016-01-01 17:00:00',
        AllDay              => 0,
        TimezoneID          => 1,
        TeamID              => [ 1 ],
        ResourceID          => [ 1, 3 ],
        Recurring           => 1,
        RecurrenceType      => 'Daily',
        RecurrenceFrequency => 1,
        RecurrenceCount     => 1,
        RecurrenceInterval  => 2,
        RecurrenceUntil     => '2016-01-10 00:00:00',
        RecurrenceID        => '2016-01-10 00:00:00',
        RecurrenceExclude   => [
            '2016-01-10 00:00:00',
            '2016-01-11 00:00:00',
        ],
        NotificationTime                  => '2016-01-01 17:0:00',
        NotificationTemplate              => 'Custom',
        NotificationCustomUnitCount       => '12',
        NotificationCustomUnit            => 'minutes',
        NotificationCustomUnitPointOfTime => 'beforestart',
        CreateTime          => '2016-01-01 00:00:00',
        CreateBy            => 2,
        ChangeTime          => '2016-01-01 00:00:00',
        ChangeBy            => 2,
    );
=cut

sub AppointmentGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if (
        !$Param{AppointmentID}
        && !( $Param{UniqueID} && $Param{CalendarID} )
        )
    {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need AppointmentID or UniqueID and CalendarID!"
        );
        return;
    }

    my $Data;

    if ( $Param{AppointmentID} ) {

        # check cache
        $Data = $Kernel::OM->Get('Kernel::System::Cache')->Get(
            Type => $Self->{CacheType},
            Key  => $Param{AppointmentID},
        );
    }

    if ( ref $Data eq 'HASH' ) {
        return %{$Data};
    }

    # needed objects
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    my @Bind;
    my $SQL = '
        SELECT id, parent_id, calendar_id, unique_id, title, description, location, start_time,
            end_time, all_day, timezone_id, team_id, resource_id, recurring, recur_type, recur_freq,
            recur_count, recur_interval, recur_until, recur_id, recur_exclude, notify_time,
            notify_template, notify_custom, notify_custom_unit_count, notify_custom_unit,
            notify_custom_unit_point, notify_custom_date, create_time, create_by, change_time, change_by
        FROM calendar_appointment
        WHERE
    ';

    if ( $Param{AppointmentID} ) {
        $SQL .= 'id=? ';
        push @Bind, \$Param{AppointmentID};
    }
    else {
        $SQL .= 'unique_id=? AND calendar_id=? AND parent_id IS NULL ';
        push @Bind, \$Param{UniqueID}, \$Param{CalendarID};
    }

    # db query
    return if !$DBObject->Prepare(
        SQL   => $SQL,
        Bind  => \@Bind,
        Limit => 1,
    );

    my %Result;

    while ( my @Row = $DBObject->FetchrowArray() ) {

        # team id
        my @TeamID = split( ',', $Row[11] // '' );

        # resource id
        my @ResourceID = split( ',', $Row[12] // '0' );

        # recurrence frequency
        my @RecurrenceFrequency = $Row[15] ? split( ',', $Row[15] ) : undef;

        # recurrence exclude
        my @RecurrenceExclude = $Row[20] ? split( ',', $Row[20] ) : undef;

        $Result{AppointmentID}                         = $Row[0];
        $Result{ParentID}                              = $Row[1];
        $Result{CalendarID}                            = $Row[2];
        $Result{UniqueID}                              = $Row[3];
        $Result{Title}                                 = $Row[4];
        $Result{Description}                           = $Row[5];
        $Result{Location}                              = $Row[6];
        $Result{StartTime}                             = $Row[7];
        $Result{EndTime}                               = $Row[8];
        $Result{AllDay}                                = $Row[9];
        $Result{TimezoneID}                            = $Row[10];
        $Result{TeamID}                                = \@TeamID;
        $Result{ResourceID}                            = \@ResourceID;
        $Result{Recurring}                             = $Row[13];
        $Result{RecurrenceType}                        = $Row[14];
        $Result{RecurrenceFrequency}                   = \@RecurrenceFrequency;
        $Result{RecurrenceCount}                       = $Row[16];
        $Result{RecurrenceInterval}                    = $Row[17];
        $Result{RecurrenceUntil}                       = $Row[18];
        $Result{RecurrenceID}                          = $Row[19];
        $Result{RecurrenceExclude}                     = \@RecurrenceExclude;
        $Result{NotificationDate}                      = $Row[21];
        $Result{NotificationTemplate}                  = $Row[22];
        $Result{NotificationCustom}                    = $Row[23];
        $Result{NotificationCustomRelativeUnitCount}   = $Row[24];
        $Result{NotificationCustomRelativeUnit}        = $Row[25];
        $Result{NotificationCustomRelativePointOfTime} = $Row[26];
        $Result{NotificationCustomDateTime}            = $Row[27];
        $Result{CreateTime}                            = $Row[28];
        $Result{CreateBy}                              = $Row[29];
        $Result{ChangeTime}                            = $Row[30];
        $Result{ChangeBy}                              = $Row[31];
    }

    if ( $Param{AppointmentID} ) {

        # cache
        $Kernel::OM->Get('Kernel::System::Cache')->Set(
            Type  => $Self->{CacheType},
            Key   => $Param{AppointmentID},
            Value => \%Result,
            TTL   => $Self->{CacheTTL},
        );
    }

    return %Result;
}

=item AppointmentUpdate()

updates an existing appointment.

    my $Success = $AppointmentObject->AppointmentUpdate(
        AppointmentID         => 2,                                       # (required)
        CalendarID            => 1,                                       # (required) Valid CalendarID
        Title                 => 'Webinar',                               # (required) Title
        Description           => 'How to use Process tickets...',         # (optional) Description
        Location              => 'Straubing',                             # (optional) Location
        StartTime             => '2016-01-01 16:00:00',                   # (required)
        EndTime               => '2016-01-01 17:00:00',                   # (required)
        AllDay                => 0,                                       # (optional) Default 0
        TimezoneID            => -2,                                      # (optional) Timezone - it can be 0 (UTC)
        Team                  => 1,                                       # (optional)
        ResourceID            => [ 1, 3 ],                                # (optional) must be an array reference if supplied
        Recurring             => 1,                                       # (optional) flag the appointment as recurring (parent only!)

        RecurrenceType        => 'Daily',                                 # (required if Recurring) Possible "Daily", "Weekly", "Monthly", "Yearly",
                                                                          #           "CustomWeekly", "CustomMonthly", "CustomYearly"

        RecurrenceFrequency   => 1,                                       # (required if Custom Recurring) Recurrence pattern
                                                                          #           for CustomWeekly: 1-Mon, 2-Tue,..., 7-Sun
                                                                          #           for CustomMonthly: 1-Jan, 2-Feb,..., 12-Dec
                                                                          # ...
        RecurrenceCount       => 1,                                       # (optional) How many Appointments to create
        RecurrenceInterval    => 2,                                       # (optional) Repeating interval (default 1)
        RecurrenceUntil       => '2016-01-10 00:00:00',                   # (optional) Until date

        NotificationDate                      => '2016-01-01 17:0:00',    # (optional) Point of time to execute the notification event
        NotificationTemplate                  => 'Custom',                # (optional) Template to be used for notification point of time
        NotificationCustom                    => '12',                    # (optional) minutes, hours or days count for custom template
        NotificationCustomRelativeUnitCount   => 'minutes',               # (optional) minutes, hours or days unit for custom template
        NotificationCustomRelativeUnit        => 'minutes',               # (optional) minutes, hours or days unit for custom template
        NotificationCustomRelativePointOfTime => 'beforestart',           # (optional) Point of execute for custom templates
                                                                          #            Possible "beforestart", "afterstart", "beforeend", "afterend"
        NotificationCustomDateTimeYear        => 'minutes',               # (optional) minutes, hours or days unit for custom template
        NotificationCustomDateTimeMonth       => 'minutes',               # (optional) minutes, hours or days unit for custom template
        NotificationCustomDateTimeDay         => 'minutes',               # (optional) minutes, hours or days unit for custom template
        NotificationCustomDateTimeHour        => 'minutes',               # (optional) minutes, hours or days unit for custom template
        NotificationCustomDateTimeMinute      => 'minutes',               # (optional) minutes, hours or days unit for custom template

        UserID                => 1,                                       # (required) UserID
    );

returns 1 if successful:
    $Success = 1;

Events:
    AppointmentUpdate

=cut

sub AppointmentUpdate {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(AppointmentID CalendarID Title StartTime EndTime UserID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    # prepare possible notification params
    $Self->_AppointmentNotificationPrepare(
        Data => \%Param,
    );

    # needed objects
    my $CalendarHelperObject = $Kernel::OM->Get('Kernel::System::Calendar::Helper');

    # if Recurring is provided, additional parameters must be present
    if ( $Param{Recurring} ) {

        my @RecurrenceTypes = (
            "Daily",       "Weekly",       "Monthly",       "Yearly",
            "CustomDaily", "CustomWeekly", "CustomMonthly", "CustomYearly"
        );

        if (
            !$Param{RecurrenceType}
            || !grep { $_ eq $Param{RecurrenceType} } @RecurrenceTypes
            )
        {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "RecurrenceType invalid!",
            );
            return;
        }

        if (
            (
                $Param{RecurrenceType} eq 'CustomWeekly'
                || $Param{RecurrenceType} eq 'CustomMonthly'
                || $Param{RecurrenceType} eq 'CustomYearly'
            )
            && !$Param{RecurrenceFrequency}
            )
        {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "RecurrenceFrequency needed!",
            );
            return;
        }
    }

    $Param{RecurrenceInterval} ||= 1;

    # check StartTime
    my $StartTimeSystem = $CalendarHelperObject->SystemTimeGet(
        String => $Param{StartTime},
    );
    if ( !$StartTimeSystem ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "StartTime invalid!",
        );
        return;
    }

    # check EndTime
    my $EndTimeSystem = $CalendarHelperObject->SystemTimeGet(
        String => $Param{EndTime},
    );
    if ( !$EndTimeSystem ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "EndTime invalid!",
        );
        return;
    }

    # needed objects
    my $CacheObject = $Kernel::OM->Get('Kernel::System::Cache');

    # check timezone
    if ( !defined $Param{TimezoneID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "TimezoneID not defined!",
        );
        return;
    }

    # check if array refs
    my %Arrays;
    for my $Parameter (
        qw(TeamID ResourceID RecurrenceFrequency)
        )
    {
        if ( $Param{$Parameter} ) {
            if ( !IsArrayRefWithData( $Param{$Parameter} ) ) {
                $Kernel::OM->Get('Kernel::System::Log')->Log(
                    Priority => 'error',
                    Message  => "$Parameter not ARRAYREF!",
                );
                return;
            }

            my @Array = @{ $Param{$Parameter} };

            # remove undefined values
            @Array = grep { defined $_ } @Array;

            $Arrays{$Parameter} = join( ',', @Array ) if @Array;
        }
    }

    # check if numbers
    for my $Parameter (
        qw(Recurring RecurrenceCount RecurrenceInterval)
        )
    {
        if ( $Param{$Parameter} && !IsInteger( $Param{$Parameter} ) ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "$Parameter must be a number!",
            );
            return;
        }
    }

    # check RecurrenceUntil
    if ( $Param{RecurrenceUntil} ) {

        # usually hour, minute and second = 0. In this case, take time from StartTime
        $Param{RecurrenceUntil} = $CalendarHelperObject->TimeCheck(
            OriginalTime => $Param{StartTime},
            Time         => $Param{RecurrenceUntil},
        );

        my $RecurrenceUntilSystem = $CalendarHelperObject->SystemTimeGet(
            String => $Param{RecurrenceUntil},
        );
        if (
            !$RecurrenceUntilSystem
            || $StartTimeSystem > $RecurrenceUntilSystem
            )
        {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "RecurrenceUntil invalid!",
            );
            return;
        }
    }

    # get previous CalendarID
    my $PreviousCalendarID = $Self->_AppointmentGetCalendarID(
        AppointmentID => $Param{AppointmentID},
    );

    # set recurrence exclude list
    my @RecurrenceExclude = @{ $Param{RecurrenceExclude} // [] };

    # get RecurrenceID
    my $RecurrenceID = $Self->_AppointmentGetRecurrenceID(
        AppointmentID => $Param{AppointmentID},
    );

    # use exclude list to flag the recurring occurrence as updated
    if ($RecurrenceID) {
        @RecurrenceExclude = ($RecurrenceID);
    }

    # reset exclude list if recurrence is turned off
    else {
        @RecurrenceExclude = () if !$Param{Recurring};
    }

    # remove undefined values
    @RecurrenceExclude = grep { defined $_ } @RecurrenceExclude;

    # serialize data
    my $RecurrenceExclude = join( ',', @RecurrenceExclude ) || undef;

    # delete existing recurred appointments
    my $DeleteSuccess = $Self->_AppointmentRecurringDelete(
        ParentID => $Param{AppointmentID},
    );

    if ( !$DeleteSuccess ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Unable to delete recurring Appointment!",
        );
        return;
    }

    # update appointment
    my $SQL = '
        UPDATE calendar_appointment
        SET
            calendar_id=?, title=?, description=?, location=?, start_time=?, end_time=?, all_day=?,
            timezone_id=?, team_id=?, resource_id=?, recurring=?, recur_type=?, recur_freq=?,
            recur_count=?, recur_interval=?, recur_until=?, recur_exclude=?, notify_time=?,
            notify_template=?, notify_custom=?, notify_custom_unit_count=?, notify_custom_unit=?,
            notify_custom_unit_point=?, notify_custom_date=?, change_time=current_timestamp, change_by=?
        WHERE id=?
    ';

    # update db record
    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL  => $SQL,
        Bind => [
            \$Param{CalendarID}, \$Param{Title},       \$Param{Description}, \$Param{Location},
            \$Param{StartTime},  \$Param{EndTime},     \$Param{AllDay},      \$Param{TimezoneID},
            \$Arrays{TeamID},    \$Arrays{ResourceID}, \$Param{Recurring},   \$Param{RecurrenceType},
            \$Arrays{RecurrenceFrequency}, \$Param{RecurrenceCount}, \$Param{RecurrenceInterval},
            \$Param{RecurrenceUntil}, \$RecurrenceExclude, \$Param{NotificationDate},
            \$Param{NotificationTemplate}, \$Param{NotificationCustom}, \$Param{NotificationCustomRelativeUnitCount},
            \$Param{NotificationCustomRelativeUnit}, \$Param{NotificationCustomRelativePointOfTime},
            \$Param{NotificationCustomDateTime}, \$Param{UserID}, \$Param{AppointmentID},
        ],
    );

    # add recurred appointments again
    if ( $Param{Recurring} ) {
        return if !$Self->_AppointmentRecurringCreate(
            ParentID    => $Param{AppointmentID},
            Appointment => \%Param,
        );
    }

    # reset seen flag
    $Self->AppointmentSeenSet(
        AppointmentID => $Param{AppointmentID},
        UserID        => $Param{UserID},
        Seen          => 0,
    );

    # handle notification entries
    if ( $Param{NotificationTime} ) {

        my $Success = $Self->AppointmentNotificationDelete(
            %Param,
        );

        $Success = $Self->_AppointmentNotificationCreate(
            %Param,
        );

        if ( !$Success ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Could not update appointment notification for appointment id '$Param{AppointmentID}'!",
            );
        }
    }

    # delete cache
    $CacheObject->Delete(
        Type => $Self->{CacheType},
        Key  => $Param{AppointmentID},
    );

    # clean up list methods cache
    my @CalendarIDs = ( $Param{CalendarID} );
    push @CalendarIDs, $PreviousCalendarID if $PreviousCalendarID ne $Param{CalendarID};
    for my $CalendarID (@CalendarIDs) {
        $CacheObject->CleanUp(
            Type => $Self->{CacheType} . 'List' . $CalendarID,
        );
    }
    $CacheObject->CleanUp(
        Type => $Self->{CacheType} . 'Days' . $Param{UserID},
    );

    # delete seen cache
    $CacheObject->CleanUp(
        Type => $Self->{CacheType} . "Seen$Param{AppointmentID}",
    );

    # fire event
    $Self->EventHandler(
        Event => 'AppointmentUpdate',
        Data  => {
            AppointmentID => $Param{AppointmentID},
        },
        UserID => $Param{UserID},
    );

    return 1;
}

=item AppointmentDelete()

deletes an existing appointment.

    my $Success = $AppointmentObject->AppointmentDelete(
        AppointmentID   => 1,                              # (required)
        UserID          => 1,                              # (required)
    );

returns 1 if successful:
    $Success = 1;

Events:
    AppointmentDelete

=cut

sub AppointmentDelete {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(AppointmentID UserID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    # needed objects
    my $CacheObject = $Kernel::OM->Get('Kernel::System::Cache');

    # get CalendarID
    my $CalendarID = $Self->_AppointmentGetCalendarID(
        AppointmentID => $Param{AppointmentID},
    );

    # check user's permissions for this calendar
    my $Permission = $Kernel::OM->Get('Kernel::System::Calendar')->CalendarPermissionGet(
        CalendarID => $CalendarID,
        UserID     => $Param{UserID},
    );

    my @RequiredPermissions = ( 'create', 'rw' );

    if ( !grep { $Permission eq $_ } @RequiredPermissions ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "User($Param{UserID}) has no permission to delete Appointment($Param{AppointmentID})!"
        );
        return;
    }

    my %Appointment = $Self->AppointmentGet(
        AppointmentID => $Param{AppointmentID},
    );

    # save exclusion info to parent appointment
    if ( $Appointment{ParentID} && $Appointment{RecurrenceID} ) {
        $Self->_AppointmentRecurringExclude(
            ParentID     => $Appointment{ParentID},
            RecurrenceID => $Appointment{RecurrenceID},
        );
    }

    # delete recurring appointments
    my $DeleteRecurringSuccess = $Self->_AppointmentRecurringDelete(
        ParentID => $Param{AppointmentID},
    );

    if ( !$DeleteRecurringSuccess ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Recurring appointments couldn\'t be deleted!',
        );
        return;
    }

    # handle notification entries
    my $Success = $Self->AppointmentNotificationDelete(
        AppointmentID => $Param{AppointmentID},
    );

    if ( !$Success ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Could not delete appointment notification for appointment id '$Param{AppointmentID}'!",
        );
    }

    # delete appointment
    my $SQL = '
        DELETE FROM calendar_appointment
        WHERE id=?
    ';

    # delete db record
    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL  => $SQL,
        Bind => [
            \$Param{AppointmentID},
        ],
    );

    # reset seen flag
    $Self->AppointmentSeenSet(
        AppointmentID => $Param{AppointmentID},
        UserID        => $Param{UserID},
        Seen          => 0,
    );

    # delete cache
    $CacheObject->Delete(
        Type => $Self->{CacheType},
        Key  => $Param{AppointmentID},
    );

    # clean up list methods cache
    $CacheObject->CleanUp(
        Type => $Self->{CacheType} . 'List' . $CalendarID,
    );
    $CacheObject->CleanUp(
        Type => $Self->{CacheType} . 'Days' . $Param{UserID},
    );

    # delete seen cache
    $CacheObject->CleanUp(
        Type => $Self->{CacheType} . "Seen$Param{AppointmentID}",
    );

    # fire event
    $Self->EventHandler(
        Event => 'AppointmentDelete',
        Data  => {
            AppointmentID => $Param{AppointmentID},
        },
        UserID => $Param{UserID},
    );

    return 1;
}

=item AppointmentDeleteOccurrence()

deletes a single recurring appointment occurrence.

    my $Success = $AppointmentObject->AppointmentDeleteOccurrence(
        UniqueID     => '20160101T160000-71E386@localhost',    # (required)
        RecurrenceID => '2016-01-10 00:00:00',                 # (required)
        UserID       => 1,                                     # (required)
    );

returns 1 if successful:
    $Success = 1;

=cut

sub AppointmentDeleteOccurrence {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(UniqueID CalendarID RecurrenceID UserID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    # get db object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # db query
    return if !$DBObject->Prepare(
        SQL => '
            SELECT id FROM calendar_appointment
            WHERE unique_id=? AND calendar_id=? AND recur_id=?',
        Bind  => [ \$Param{UniqueID}, \$Param{CalendarID}, \$Param{RecurrenceID} ],
        Limit => 1,
    );

    my %Appointment;

    # get additional info
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $Appointment{AppointmentID} = $Row[0];
    }
    return if !%Appointment;

    # delete db record
    return if !$DBObject->Do(
        SQL   => 'DELETE FROM calendar_appointment WHERE id=?',
        Bind  => [ \$Appointment{AppointmentID} ],
        Limit => 1,
    );

    # get cache object
    my $CacheObject = $Kernel::OM->Get('Kernel::System::Cache');

    # delete cache
    $CacheObject->Delete(
        Type => $Self->{CacheType},
        Key  => $Appointment{AppointmentID},
    );

    # clean up list methods cache
    $CacheObject->CleanUp(
        Type => $Self->{CacheType} . 'List' . $Param{CalendarID},
    );
    $CacheObject->CleanUp(
        Type => $Self->{CacheType} . 'Days' . $Param{UserID},
    );

    return 1;
}

=item GetUniqueID()

returns UniqueID containing appointment start time, random hash and system FQDN.

    my $UniqueID = $AppointmentObject->GetUniqueID(
        CalendarID => 1,                        # (required)
        StartTime  => 1451606400,               # (required)
        UserID     => 1,                        # (required)
    );

    $UniqueID = '';

=cut

sub GetUniqueID {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(CalendarID StartTime UserID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    # calculate a hash
    my $RandomString = $Kernel::OM->Get('Kernel::System::Calendar')->GetRandomString( Length => 32 );
    my $String       = "$Param{CalendarID}-$RandomString-$Param{UserID}";
    my $Digest       = unpack( 'N', Digest::MD5->new()->add($String)->digest() );
    my $DigestHex    = sprintf( '%x', $Digest );
    my $Hash         = uc( sprintf( "%.6s", $DigestHex ) );

    # prepare start timestamp for UniqueID
    my $StartTimeStrg = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->TimestampGet(
        SystemTime => $Param{StartTime},
    );
    $StartTimeStrg =~ s/[-:]//g;
    $StartTimeStrg =~ s/\s/T/;

    # get system FQDN
    my $FQDN = $Kernel::OM->Get('Kernel::Config')->Get('FQDN');

    # return UniqueID
    return "$StartTimeStrg-$Hash\@$FQDN";
}

=item AppointmentSeenGet()

check if particular appointment reminder was shown to given user.

    my $Seen = $AppointmentObject->AppointmentSeenGet(
        AppointmentID   => 1,                              # (required)
        UserID          => 1,                              # (required)
    );

returns 1 if seen:
    $Seen = 1;

=cut

sub AppointmentSeenGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(AppointmentID UserID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    # needed objects
    my $CacheObject = $Kernel::OM->Get('Kernel::System::Cache');
    my $DBObject    = $Kernel::OM->Get('Kernel::System::DB');

    # check cache
    my $Data = $CacheObject->Get(
        Type => $Self->{CacheType} . "Seen$Param{AppointmentID}",
        Key  => "$Param{AppointmentID}-$Param{UserID}",
    );

    return $Data if defined $Data;

    my $SQL = '
        SELECT seen
        FROM calendar_appointment_seen
        WHERE
            calendar_appointment_id=? AND
            user_id=?
    ';

    # db query
    return if !$DBObject->Prepare(
        SQL  => $SQL,
        Bind => [
            \$Param{AppointmentID}, \$Param{UserID},
        ],
    );

    my $Result = 0;

    while ( my @Row = $DBObject->FetchrowArray() ) {
        $Result = $Row[0];
    }

    # cache result
    $CacheObject->Set(
        Type  => $Self->{CacheType} . "Seen$Param{AppointmentID}",
        Key   => "$Param{AppointmentID}-$Param{UserID}",
        Value => $Result,
        TTL   => $Self->{CacheTTL},
    );

    return $Result;
}

=item AppointmentSeenSet()

set the flag if appointment reminder is shown the given user.

    my $Success = $AppointmentObject->AppointmentSeenSet(
        AppointmentID   => 1,                              # (required)
        UserID          => 1,                              # (required)
        Seen            => 1,                              # (required) Default 1.
    );

returns 1 if successful:
    $Seen = 1;

=cut

sub AppointmentSeenSet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(AppointmentID UserID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    $Param{Seen} = $Param{Seen} // 1;

    # needed objects
    my $CacheObject = $Kernel::OM->Get('Kernel::System::Cache');

    if ( $Param{Seen} ) {
        my $SQL = '
            INSERT INTO calendar_appointment_seen
                (calendar_appointment_id, user_id, seen)
            VALUES (?, ?, ?)
        ';

        # create db record
        return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
            SQL  => $SQL,
            Bind => [
                \$Param{AppointmentID}, \$Param{UserID}, \$Param{Seen},
            ],
        );
    }
    else {
        my $SQL = '
            DELETE
            FROM calendar_appointment_seen
            WHERE
                calendar_appointment_id=? AND
                user_id=?
        ';

        # create db record
        return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
            SQL  => $SQL,
            Bind => [
                \$Param{AppointmentID}, \$Param{UserID},
            ],
        );
    }

    # delete seen cache
    $CacheObject->CleanUp(
        Type => $Self->{CacheType} . "Seen$Param{AppointmentID}",
    );

    return 1;
}

=item AppointmentUpcomingGet()

Get appointment data for upcoming appointment start or end.

    my %AppointmentData = $AppointmentObject->AppointmentUpcomingGet(
        Type      => 'Start', # can be either 'Start' or 'End', default: 'Start'
        Timestamp => '2016-08-02 03:59:00', # can be either 'Start' or 'End', default: 'Start'
    );

returns:

    Appointment data of AppointmentGet().

=cut

sub AppointmentUpcomingGet {
    my ( $Self, %Param ) = @_;

    # determine appointment type to get upcoming entry for
    my $AppointmentType = 'start_time';

    if ( lc $Param{Type} eq 'end' ) {
        $AppointmentType = 'end_time';
    }

    # needed objects
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # get local calendar helper object
    my $CalendarHelperObject = $Kernel::OM->Get('Kernel::System::Calendar::Helper');

    # get current timestamp
    my $CurrentTimestamp = $CalendarHelperObject->CurrentTimestampGet();

    my $SQL = "
        SELECT id, parent_id, calendar_id, unique_id
        FROM calendar_appointment
        WHERE DATE($AppointmentType) >= DATE(?)
        ORDER BY $AppointmentType";

    # db query
    return if !$DBObject->Prepare(
        SQL   => $SQL,
        Bind  => [ \$CurrentTimestamp ],
        Limit => 1,
    );

    my %Result;

    while ( my @Row = $DBObject->FetchrowArray() ) {

        $Result{AppointmentID} = $Row[0];
        $Result{ParentID}      = $Row[1];
        $Result{CalendarID}    = $Row[2];
        $Result{UniqueID}      = $Row[3];
    }

    my %UpcomingAppointment;

    if ( IsHashRefWithData( \%Result ) ) {
        %UpcomingAppointment = $Self->AppointmentGet(%Result);
    }

    return \%UpcomingAppointment;
}

=item AppointmentFutureTasksDelete()

Delete all calendar appointment future tasks.

    my $Success = $AppointmentObject->AppointmentFutureTasksDelete();

returns:

    True if future task deletion was successful, otherwise false.

=cut

sub AppointmentFutureTasksDelete {
    my ( $Self, %Param ) = @_;

    # get a local scheduler db object
    my $SchedulerDBObject = $Kernel::OM->Get('Kernel::System::Daemon::SchedulerDB');

    # get a list of already stored future tasks
    my @FutureTaskList = $SchedulerDBObject->FutureTaskList(
        Type => 'CalendarAppointment',
    );

    # flush obsolete future tasks
    if ( IsArrayRefWithData( \@FutureTaskList ) ) {

        FUTURETASK:
        for my $FutureTask (@FutureTaskList) {

            next FUTURETASK if !$FutureTask;
            next FUTURETASK if !IsHashRefWithData($FutureTask);

            my $Success = $SchedulerDBObject->FutureTaskDelete(
                TaskID => $FutureTask->{TaskID},
            );

            if ( !$Success ) {
                $Kernel::OM->Get('Kernel::System::Log')->Log(
                    Priority => 'error',
                    Message  => "Could not delete future task with id $FutureTask->{TaskID}!",
                );
                return;
            }
        }
    }

    return 1;
}

=item AppointmentFutureTasksUpdate()

Update OTRS daemon future task list for upcoming appointments.

    my $Success = $AppointmentObject->AppointmentFutureTasksUpdate();

returns:

    True if future task update was successful, otherwise false.

=cut

sub AppointmentFutureTasksUpdate {
    my ( $Self, %Param ) = @_;

    # get appointment data for upcoming appointment start and end
    my %UpcomingAppointment = (
        'Start' => $Self->AppointmentUpcomingGet(
            Type => 'Start',
        ),
        'End' => $Self->AppointmentUpcomingGet(
            Type => 'End',
        ),
    );

    if (
        !IsHashRefWithData( $UpcomingAppointment{Start} )
        || !IsHashRefWithData( $UpcomingAppointment{End} )
        )
    {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Could not get upcoming appointment data for start and/or end-time!",
        );
        return;
    }

    # get a local scheduler db object
    my $SchedulerDBObject = $Kernel::OM->Get('Kernel::System::Daemon::SchedulerDB');

    # get a list of already stored future tasks
    my @FutureTaskList = $SchedulerDBObject->FutureTaskList(
        Type => 'CalendarAppointment',
    );

    # check if it is needed to update the future task list
    if ( scalar @FutureTaskList == 2 ) {

        # get a local calendar helper object
        my $CalendarHelperObject = $Kernel::OM->Get('Kernel::System::Calendar::Helper');

        my $UpdateNeeded = 0;

        FUTURETASK:
        for my $FutureTask (@FutureTaskList) {

            if ( !IsHashRefWithData($FutureTask) || !$FutureTask->{TaskID} ) {
                $UpdateNeeded = 1;
                last FUTURETASK;
            }

            # get the stored future task
            my %FutureTaskData = $SchedulerDBObject->FutureTaskGet(
                TaskID => $FutureTask->{TaskID},
            );

            if ( !IsHashRefWithData( \%FutureTaskData ) ) {
                $UpdateNeeded = 1;
                last FUTURETASK;
            }

            my $Type = $FutureTaskData{Data}->{Type};

            # get unix timestamps of stored and upcoming times to compare
            my $FutureTaskTime = $CalendarHelperObject->SystemTimeGet(
                String => $FutureTaskData{Data}->{ $Type . 'Time' },
            );
            my $UpcomingAppointmentTime = $CalendarHelperObject->SystemTimeGet(
                String => $UpcomingAppointment{$Type}->{ $Type . 'Time' },
            );

            # do nothing if the upcoming start time and id equals the stored values
            if (
                $UpcomingAppointmentTime != $FutureTaskTime
                || $UpcomingAppointment{$Type}->{AppointmentID} != $FutureTaskData{Data}->{AppointmentID}
                )
            {
                $UpdateNeeded = 1;
                last FUTURETASK;
            }
        }

        return 1 if !$UpdateNeeded;
    }

    # flush obsolete future tasks
    my $Success = $Self->AppointmentFutureTasksDelete();

    if ( !$Success ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Could not delete appointment future tasks!',
        );
        return;
    }

    # schedule new future tasks for notification actions
    for my $TaskType ( sort keys %UpcomingAppointment ) {

        my $TaskID = $Kernel::OM->Get('Kernel::System::Daemon::SchedulerDB')->FutureTaskAdd(
            ExecutionTime => $UpcomingAppointment{$TaskType}->{ $TaskType . 'Time' },
            Type          => 'CalendarAppointment',
            Data          => {
                AppointmentID => $UpcomingAppointment{$TaskType}->{AppointmentID},
                ParentID      => $UpcomingAppointment{$TaskType}->{ParentID},
                CalendarID    => $UpcomingAppointment{$TaskType}->{CalendarID},
                StartTime     => $UpcomingAppointment{$TaskType}->{StartTime},
                EndTime       => $UpcomingAppointment{$TaskType}->{EndTime},
                Type          => $TaskType,
            },
        );

        if ( !$TaskID ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message =>
                    "Could not schedule future task for AppointmentID $UpcomingAppointment{$TaskType}->{AppointmentID} ! Type: $TaskType !",
            );
            return;
        }
    }

    return 1;
}

=item _AppointmentNotificationPrepare()

Prepare appointment notification data.

    my $Success = $AppointmentObject->_AppointmentNotificationPrepare();

returns:

    True if preparation was successful, otherwise false.

=cut

sub _AppointmentNotificationPrepare {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(Data)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    # prepare possible notification params
    for my $PossibleParam (
        qw(
        NotificationDate NotificationTemplate NotificationCustom NotificationCustomRelativeUnitCount
        NotificationCustomRelativeUnit NotificationCustomRelativePointOfTime NotificationCustomDateTime
        )
        )
    {
        $Param{Data}->{$PossibleParam} ||= '';
    }

    # prepare custom datetime string
    if (
        IsStringWithData( $Param{Data}->{NotificationCustomDateTimeYear} )
        && IsStringWithData( $Param{Data}->{NotificationCustomDateTimeMonth} )
        && IsStringWithData( $Param{Data}->{NotificationCustomDateTimeDay} )
        && IsStringWithData( $Param{Data}->{NotificationCustomDateTimeHour} )
        && IsStringWithData( $Param{Data}->{NotificationCustomDateTimeMinute} )
        )
    {
        $Param{Data}->{NotificationCustomDateTime} =
            $Param{Data}->{NotificationCustomDateTimeYear}
            . '-'
            . sprintf( "%02d", $Param{Data}->{NotificationCustomDateTimeMonth} )
            . '-'
            . sprintf( "%02d", $Param{Data}->{NotificationCustomDateTimeDay} )
            . ' '
            . sprintf( "%02d", $Param{Data}->{NotificationCustomDateTimeHour} )
            . ':'
            . sprintf( "%02d", $Param{Data}->{NotificationCustomDateTimeMinute} )
            . ':00';
    }
    else {
        $Param{Data}->{NotificationCustomDateTime} = '';
    }

    return if !$Param{Data}->{NotificationTemplate};

    # get a local calendar helper object
    my $CalendarHelperObject = $Kernel::OM->Get('Kernel::System::Calendar::Helper');

    # --------------
    # template Start
    # --------------
    if ( $Param{Data}->{NotificationTemplate} eq 'Start' ) {

        # setup the appointment start date as notification date
        $Param{Data}->{NotificationDate} = $Param{Data}->{StartTime};
    }

    # --------------------------
    # template time before start
    # --------------------------
    elsif ( $Param{Data}->{NotificationTemplate} ne 'Custom' ) {

        return if !IsNumber( $Param{Data}->{NotificationTemplate} );

        # offset template (before start datetime) used
        my $Offset = $Param{Data}->{NotificationTemplate};

        # get a unix timestamp of appointment start time
        my $StartLocalTime = $CalendarHelperObject->SystemTimeGet(
            String => $Param{Data}->{StartTime},
        );

        # save the start time - offset as new notification datetime string
        $Param{Data}->{NotificationDate} = $CalendarHelperObject->TimestampGet(
            SystemTime => ( $StartLocalTime - $Offset ),
        );
    }

    # ---------------
    # template Custom
    # ---------------
    else {

        # compute date of relative input
        if ( $Param{Data}->{NotificationCustomRelativeInput} ) {

            $Param{Data}->{NotificationCustom} = 'relative';

            my $CustomUnitCount = $Param{Data}->{NotificationCustomRelativeUnitCount};
            my $CustomUnit      = $Param{Data}->{NotificationCustomRelativeUnit};
            my $CustomUnitPoint = $Param{Data}->{NotificationCustomRelativePointOfTime};

            return if !$CustomUnitCount;

            # setup the count to compute for the offset
            my %UnitOffsetCompute = (
                minutes => 60,
                hours   => 3600,
                days    => 86400,
            );

            my $NotificationLocalTime;

            # compute from start time
            if ( $CustomUnitPoint eq 'beforestart' || $CustomUnitPoint eq 'afterstart' ) {

                $NotificationLocalTime = $CalendarHelperObject->SystemTimeGet(
                    String => $Param{Data}->{StartTime},
                );
            }

            # compute from end time
            elsif ( $CustomUnitPoint eq 'beforeend' || $CustomUnitPoint eq 'afterend' ) {

                $NotificationLocalTime = $CalendarHelperObject->SystemTimeGet(
                    String => $Param{Data}->{EndTime},
                );
            }

            # not supported point of time
            else {
                return;
            }

            # compute the offset to be used
            my $Offset = ( $CustomUnitCount * $UnitOffsetCompute{$CustomUnit} );

            # save the newly computed notification datetime string
            if ( $CustomUnitPoint eq 'beforestart' || $CustomUnitPoint eq 'beforeend' ) {
                $Param{Data}->{NotificationDate} = $CalendarHelperObject->TimestampGet(
                    SystemTime => ( $NotificationLocalTime - $Offset ),
                );
            }
            else {
                $Param{Data}->{NotificationDate} = $CalendarHelperObject->TimestampGet(
                    SystemTime => ( $NotificationLocalTime + $Offset ),
                );
            }
        }

        # save date time input
        elsif ( $Param{Data}->{NotificationCustomDateTimeInput} ) {

            $Param{Data}->{NotificationCustom} = 'datetime';

            # validation
            if (
                !IsStringWithData( $Param{Data}->{NotificationCustomDateTimeYear} )
                || !IsStringWithData( $Param{Data}->{NotificationCustomDateTimeMonth} )
                || !IsStringWithData( $Param{Data}->{NotificationCustomDateTimeDay} )
                || !IsStringWithData( $Param{Data}->{NotificationCustomDateTimeHour} )
                || !IsStringWithData( $Param{Data}->{NotificationCustomDateTimeMinute} )
                )
            {
                return;
            }

            # save the given date time values as notification datetime string (i.e. 2016-06-28 02:00:00)
            $Param{Data}->{NotificationDate} =
                $Param{Data}->{NotificationCustomDateTimeYear}
                . '-'
                . sprintf( "%02d", $Param{Data}->{NotificationCustomDateTimeMonth} )
                . '-'
                . sprintf( "%02d", $Param{Data}->{NotificationCustomDateTimeDay} )
                . ' '
                . sprintf( "%02d", $Param{Data}->{NotificationCustomDateTimeHour} )
                . ':'
                . sprintf( "%02d", $Param{Data}->{NotificationCustomDateTimeMinute} )
                . ':00';
        }
    }

    return 1;
}

=item AppointmentNotification()

Get the next upcoming appointment data.

    my $Success = $AppointmentObject->AppointmentNotification();

returns:

    True if future task update was successful, otherwise false.

=cut

sub AppointmentNotification {
    my ( $Self, %Param ) = @_;

    return 1;
}

=begin Internal:

=cut

sub _AppointmentNotificationGet {
    my ( $Self, %Param ) = @_;

    return 1;
}

=begin Internal:

=cut

sub _AppointmentNotificationCreate {
    my ( $Self, %Param ) = @_;

    return 1;
}

=begin Internal:

=cut

sub AppointmentNotificationDelete {
    my ( $Self, %Param ) = @_;

    return 1;
}

=begin Internal:

=cut

sub _AppointmentRecurringCreate {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(ParentID Appointment)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    my $StartTimeSystem = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->SystemTimeGet(
        String => $Param{Appointment}->{StartTime},
    );
    my $EndTimeSystem = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->SystemTimeGet(
        String => $Param{Appointment}->{EndTime},
    );

    my @RecurrenceExclude = @{ $Param{Appointment}->{RecurrenceExclude} // [] };

    # remove undefined values
    @RecurrenceExclude = grep { defined $_ } @RecurrenceExclude;

    # reset the parameter for occurrences
    $Param{Appointment}->{RecurrenceExclude} = undef;

    my $OriginalStartTime = $StartTimeSystem;
    my $OriginalEndTime   = $EndTimeSystem;
    my $Step              = 0;

    # until ...
    if ( $Param{Appointment}->{RecurrenceUntil} ) {

        my $RecurrenceUntilSystem = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->SystemTimeGet(
            String => $Param{Appointment}->{RecurrenceUntil},
        );

        UNTIL_TIME:
        while ( $StartTimeSystem <= $RecurrenceUntilSystem ) {
            $Step += $Param{Appointment}->{RecurrenceInterval};

            # calculate recurring times
            $StartTimeSystem = $Self->_CalculateRecurrenceTime(
                Appointment  => $Param{Appointment},
                Step         => $Step,
                OriginalTime => $OriginalStartTime,
                CurrentTime  => $StartTimeSystem,
            );
            $EndTimeSystem = $Self->_CalculateRecurrenceTime(
                Appointment   => $Param{Appointment},
                Step          => $Step,
                OriginalTime  => $OriginalEndTime,
                CurrentTime   => $EndTimeSystem,
                IsEndTime     => 1,
                LastStartTime => $StartTimeSystem,
            );

            last UNTIL_TIME if !$StartTimeSystem;
            last UNTIL_TIME if $StartTimeSystem > $RecurrenceUntilSystem;

            my $StartTime = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->TimestampGet(
                SystemTime => $StartTimeSystem,
            );
            my $EndTime = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->TimestampGet(
                SystemTime => $EndTimeSystem,
            );

            # bugfix: On some systems with older perl version system might calculate timezone difference
            $StartTime = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->TimeCheck(
                OriginalTime => $Param{Appointment}->{StartTime},
                Time         => $StartTime,
            );
            $EndTime = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->TimeCheck(
                OriginalTime => $Param{Appointment}->{EndTime},
                Time         => $EndTime,
            );

            # skip excluded appointments
            next UNTIL_TIME if grep { $StartTime eq $_ } @RecurrenceExclude;

            $Self->AppointmentCreate(
                %{ $Param{Appointment} },
                ParentID     => $Param{ParentID},
                StartTime    => $StartTime,
                EndTime      => $EndTime,
                RecurrenceID => $StartTime,
            );
        }
    }

    # for ... time(s)
    elsif ( $Param{Appointment}->{RecurrenceCount} ) {

        COUNT:
        for ( 1 .. $Param{Appointment}->{RecurrenceCount} - 1 ) {
            $Step += $Param{Appointment}->{RecurrenceInterval};

            # calculate recurring times
            $StartTimeSystem = $Self->_CalculateRecurrenceTime(
                Appointment  => $Param{Appointment},
                Step         => $Step,
                OriginalTime => $OriginalStartTime,
                CurrentTime  => $StartTimeSystem,
            );
            $EndTimeSystem = $Self->_CalculateRecurrenceTime(
                Appointment   => $Param{Appointment},
                Step          => $Step,
                OriginalTime  => $OriginalEndTime,
                CurrentTime   => $EndTimeSystem,
                IsEndTime     => 1,
                LastStartTime => $StartTimeSystem,
            );

            last COUNT if !$StartTimeSystem;

            my $StartTime = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->TimestampGet(
                SystemTime => $StartTimeSystem
            );
            my $EndTime = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->TimestampGet(
                SystemTime => $EndTimeSystem
            );

            # bugfix: On some systems with older perl version system might calculate timezone difference
            $StartTime = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->TimeCheck(
                OriginalTime => $Param{Appointment}->{StartTime},
                Time         => $StartTime,
            );
            $EndTime = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->TimeCheck(
                OriginalTime => $Param{Appointment}->{EndTime},
                Time         => $EndTime,
            );

            # skip excluded appointments
            next COUNT if grep { $StartTime eq $_ } @RecurrenceExclude;

            $Self->AppointmentCreate(
                %{ $Param{Appointment} },
                ParentID     => $Param{ParentID},
                StartTime    => $StartTime,
                EndTime      => $EndTime,
                RecurrenceID => $StartTime,
            );
        }
    }

    return 1;
}

sub _AppointmentRecurringDelete {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(ParentID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    # delete recurring appointments
    my $SQL = '
        DELETE FROM calendar_appointment
        WHERE parent_id=?
    ';

    # delete db record
    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL  => $SQL,
        Bind => [
            \$Param{ParentID},
        ],
    );

    return 1;
}

sub _AppointmentRecurringExclude {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(ParentID RecurrenceID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    # needed objects
    my $CacheObject = $Kernel::OM->Get('Kernel::System::Cache');
    my $DBObject    = $Kernel::OM->Get('Kernel::System::DB');

    # db query
    return if !$DBObject->Prepare(
        SQL  => 'SELECT recur_exclude FROM calendar_appointment WHERE id=?',
        Bind => [ \$Param{ParentID} ],
    );

    # get existing exclusions
    my @RecurrenceExclude;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        @RecurrenceExclude = split( ',', $Row[0] ) if $Row[0];
    }
    push @RecurrenceExclude, $Param{RecurrenceID};
    @RecurrenceExclude = sort @RecurrenceExclude;

    # join into string
    my $RecurrenceExclude;
    if (@RecurrenceExclude) {
        $RecurrenceExclude = join( ',', @RecurrenceExclude );
    }

    # update db record
    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL  => 'UPDATE calendar_appointment SET recur_exclude=? WHERE id=?',
        Bind => [ \$RecurrenceExclude, \$Param{ParentID} ],
    );

    # delete cache
    $CacheObject->Delete(
        Type => $Self->{CacheType},
        Key  => $Param{ParentID},
    );

    return 1;
}

sub _AppointmentGetCalendarID {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(AppointmentID)) {
        if ( !defined $Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    # sql query
    my $SQL  = 'SELECT calendar_id FROM calendar_appointment WHERE id=?';
    my @Bind = ( \$Param{AppointmentID} );

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # start query
    return if !$DBObject->Prepare(
        SQL   => $SQL,
        Bind  => \@Bind,
        Limit => 1,
    );

    my $CalendarID;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $CalendarID = $Row[0];
    }

    return $CalendarID;
}

sub _AppointmentGetRecurrenceID {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(AppointmentID)) {
        if ( !defined $Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    # sql query
    my $SQL  = 'SELECT recur_id FROM calendar_appointment WHERE id=?';
    my @Bind = ( \$Param{AppointmentID} );

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # start query
    return if !$DBObject->Prepare(
        SQL   => $SQL,
        Bind  => \@Bind,
        Limit => 1,
    );

    my $RecurrenceID;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $RecurrenceID = $Row[0];
    }

    return $RecurrenceID;
}

sub _CalculateRecurrenceTime {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(Appointment Step OriginalTime CurrentTime)) {
        if ( !defined $Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    my $CalendarHelperObject = $Kernel::OM->Get('Kernel::System::Calendar::Helper');

    my $SystemTime = $Param{CurrentTime};

    if ( $Param{Appointment}->{RecurrenceType} eq 'Daily' ) {

        # add one day
        $SystemTime += 60 * 60 * 24;
    }
    elsif ( $Param{Appointment}->{RecurrenceType} eq 'Weekly' ) {

        # add 7 days
        $SystemTime += 60 * 60 * 24 * 7;
    }
    elsif ( $Param{Appointment}->{RecurrenceType} eq 'Monthly' ) {

        # add one month
        $SystemTime = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->AddPeriod(
            Time   => $Param{OriginalTime},
            Months => $Param{Step},
        );

        if ( $Param{IsEndTime} && $Param{Appointment}->{AllDay} ) {

            # Get Original StartTime
            my $StartTimeSystem = $CalendarHelperObject->SystemTimeGet(
                String => $Param{Appointment}->{StartTime},
            );

            # Get Original EndTime
            my $EndTimeSystem = $CalendarHelperObject->SystemTimeGet(
                String => $Param{Appointment}->{EndTime},
            );

            # Calculate delta (EndTime-StartTime)
            my $OriginalDelta = $EndTimeSystem - $StartTimeSystem;

            # Calculate current delta
            my $CurrentDelta = $SystemTime - $Param{LastStartTime};

            # Compare
            while ( $CurrentDelta > $OriginalDelta + 23 * 3600 ) {
                $SystemTime -= 24 * 3600;

                $CurrentDelta = $SystemTime - $Param{LastStartTime};
            }
        }
    }
    elsif ( $Param{Appointment}->{RecurrenceType} eq 'Yearly' ) {

        # add one year
        $SystemTime = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->AddPeriod(
            Time  => $Param{OriginalTime},
            Years => $Param{Step},
        );
    }
    elsif ( $Param{Appointment}->{RecurrenceType} eq 'CustomDaily' ) {
        $SystemTime += $Param{Appointment}->{RecurrenceInterval} * 60 * 60 * 24;
    }
    elsif ( $Param{Appointment}->{RecurrenceType} eq 'CustomWeekly' ) {

        # this block covers following use case:
        # each n-th Monday and Friday

        my $Found;

        my ( $OriginalWeekDay, $OriginalCW ) = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->WeekDetailsGet(
            SystemTime => $Param{OriginalTime},
        );

        # loop up to 7*n times (7 days in week * frequency)
        LOOP:
        for ( my $Counter = 0; $Counter < 7 * $Param{Appointment}->{RecurrenceInterval}; $Counter++ ) {

            # Add 1 day
            $SystemTime += 60 * 60 * 24;

            my ( $WeekDay, $CW );

            if ( $Param{IsEndTime} && $Param{Appointment}->{AllDay} ) {

                # in all day appointment, end time is usually midnight of the next day, so we need to check for 23:59:59
                ( $WeekDay, $CW ) = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->WeekDetailsGet(
                    SystemTime => $SystemTime - 1,
                );
            }
            else {
                ( $WeekDay, $CW ) = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->WeekDetailsGet(
                    SystemTime => $SystemTime,
                );
            }

            # next day if this week should be skipped
            next LOOP if ( $CW - $OriginalCW ) % $Param{Appointment}->{RecurrenceInterval};

            # check if SystemTime mach requirements
            if ( grep { $WeekDay == $_ } @{ $Param{Appointment}->{RecurrenceFrequency} } ) {
                $Found = 1;
                last LOOP;
            }
        }

        return if !$Found;
    }

    elsif ( $Param{Appointment}->{RecurrenceType} eq 'CustomMonthly' ) {

        # Occurs every 2nd month on 5th, 10th and 15th day
        my $Found;

        my ( $OriginalSec, $OriginalMin, $OriginalHour, $OriginalDay, $OriginalMonth, $OriginalYear, $OriginalWeekDay )
            = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->DateGet(
            SystemTime => $Param{OriginalTime},
            );

        # loop through each day (max one year), and check if day matches.
        DAY:
        for ( my $Counter = 0; $Counter < 31 * 366; $Counter++ ) {

            # Add one day
            $SystemTime += 24 * 60 * 60;

            my ( $Sec, $Min, $Hour, $Day, $Month, $Year, $WeekDay );
            if ( $Param{IsEndTime} ) {
                ( $Sec, $Min, $Hour, $Day, $Month, $Year, $WeekDay )
                    = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->DateGet(
                    SystemTime => $SystemTime - 1,
                    );
            }
            else {
                ( $Sec, $Min, $Hour, $Day, $Month, $Year, $WeekDay )
                    = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->DateGet(
                    SystemTime => $SystemTime,
                    );
            }

            # Skip month if needed
            next DAY if ( $Month - $OriginalMonth ) % $Param{Appointment}->{RecurrenceInterval};

            # next day if this day should be skipped
            next DAY if !grep { $Day == $_ } @{ $Param{Appointment}->{RecurrenceFrequency} };

            $Found = 1;
            last DAY;
        }
        return if !$Found;
    }
    elsif ( $Param{Appointment}->{RecurrenceType} eq 'CustomYearly' ) {

        # this block covers following use case:
        # Occurs each 3th year, January 18th and March 18th
        my $Found;

        my ( $OriginalSec, $OriginalMin, $OriginalHour, $OriginalDay, $OriginalMonth, $OriginalYear, $OriginalWeekDay )
            = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->DateGet(
            SystemTime => $Param{OriginalTime},
            );

        my $RecurrenceUntilSystem;
        if ( $Param{Appointment}->{RecurrenceUntil} ) {
            $RecurrenceUntilSystem = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->SystemTimeGet(
                String => $Param{Appointment}->{RecurrenceUntil},
            );
        }

        MONTH:
        for ( my $Counter = 1;; $Counter++ ) {

            # Add one month
            $SystemTime = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->AddPeriod(
                Time   => $Param{OriginalTime},
                Months => $Counter,
            );

            # skip this time, since it was already checked
            next MONTH if $SystemTime < $Param{CurrentTime} + 24 * 60 * 60;

            # check loop conditions (according to Until / )
            if ($RecurrenceUntilSystem) {
                last MONTH if $SystemTime > $RecurrenceUntilSystem;
            }
            else {
                last MONTH
                    if $Counter
                    > 12 * $Param{Appointment}->{RecurrenceInterval} * $Param{Appointment}->{RecurrenceCount};
            }

            my ( $Sec, $Min, $Hour, $Day, $Month, $Year, $WeekDay );

            if ( $Param{IsEndTime} ) {
                ( $Sec, $Min, $Hour, $Day, $Month, $Year, $WeekDay )
                    = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->DateGet(
                    SystemTime => $SystemTime - 1,
                    );
            }
            else {
                ( $Sec, $Min, $Hour, $Day, $Month, $Year, $WeekDay )
                    = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->DateGet(
                    SystemTime => $SystemTime,
                    );
            }

            # check if year is OK
            next MONTH if ( $Year - $OriginalYear ) % $Param{Appointment}->{RecurrenceInterval};

            # next month if this month should be skipped
            next MONTH if !grep { $Month == $_ } @{ $Param{Appointment}->{RecurrenceFrequency} };

            $Found = 1;
            last MONTH;
        }
        return if !$Found;
    }
    else {
        return;
    }

    return $SystemTime;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not
