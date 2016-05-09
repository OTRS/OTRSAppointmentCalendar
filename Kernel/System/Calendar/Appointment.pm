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
    'Kernel::System::Group',
    'Kernel::System::DB',
    'Kernel::System::Log',
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
        ParentID            => 1,                                       # (optional) valid ParentID for recurring appointments
        CalendarID          => 1,                                       # (required) valid CalendarID
        UniqueID            => 'jwioji-fwjio',                          # (optional) provide desired UniqueID; if there is already existing Appointment
                                                                        #            with same UniqueID, system will delete it
        Title               => 'Webinar',                               # (required) Title
        Description         => 'How to use Process tickets...',         # (optional) Description
        Location            => 'Straubing',                             # (optional) Location
        StartTime           => '2016-01-01 16:00:00',                   # (required)
        EndTime             => '2016-01-01 17:00:00',                   # (required)
        AllDay              => 0,                                       # (optional) default 0
        TimezoneID          => 1,                                       # (optional) Timezone - it can be 0 (UTC)
        TeamID              => 1,                                       # (optional)
        ResourceID          => [ 1, 3 ],                                # (optional) must be an array reference if supplied
        Recurring           => 1,                                       # (optional) flag the appointment as recurring (parent only!)
                                                                        # if Recurring is set, one of the following 3 parameters must be provided
        RecurrenceByYear    => 1,                                       # (optional)
        RecurrenceByMonth   => 2,                                       # (optional)
        RecurrenceByDay     => 5,                                       # (optional)

        RecurrenceFrequency => 1,                                       # (optional) default 1.
        RecurrenceCount     => 1,                                       # (optional) How many Appointments to create
        RecurrenceInterval  => 2,                                       # (optional)
        RecurrenceUntil     => '2016-01-10 00:00:00',                   # (optional) Until date
        UserID              => 1,                                       # (required) UserID
    );

returns AppointmentID if successful

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

    # if Recurring is provided, additional parameters must be present
    if (
        $Param{Recurring}
        &&
        (
            !$Param{RecurrenceByYear} &&
            !$Param{RecurrenceByMonth} &&
            !$Param{RecurrenceByDay}
        )
        )
    {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Recurring appointment, additional parameter needed"
                . "(RecurrenceByYear, RecurrenceByMonth or RecurrenceByDay)!",
        );
        return;
    }

    $Param{RecurrenceFrequency} ||= 1;

    if ( $Param{UniqueID} ) {
        my %Appointment = $Self->AppointmentGet(
            UniqueID => $Param{UniqueID},
        );

        if ( %Appointment && $Appointment{AppointmentID} ) {
            if ( $Appointment{Recurring} ) {

                # delete existing recurred appointments
                return if !$Self->_AppointmentRecurringDelete(
                    ParentID => $Appointment{AppointmentID},
                );
            }

            # delete appointment
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
    my $StartTimeSystem = $Self->_SystemTimeGet(
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
    my $UniqueID = $Param{UniqueID};
    if ( !$UniqueID ) {
        $UniqueID = $Self->_GetUniqueID(
            CalendarID => $Param{CalendarID},
            StartTime  => $StartTimeSystem,
            UserID     => $Param{UserID},
        );
    }

    # check EndTime
    my $EndTimeValid = $Self->_SystemTimeGet(
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

    # check ResourceID
    my $ResourceID;
    if ( $Param{ResourceID} ) {
        if ( !IsArrayRefWithData( $Param{ResourceID} ) ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "ResourceID not ARRAYREF!",
            );
            return;
        }

        $ResourceID = join( ',', @{ $Param{ResourceID} } );
    }

    # check if numbers
    for my $Parameter (
        qw(Recurring RecurrenceFrequency RecurrenceCount RecurrenceInterval RecurrenceByYear RecurrenceByMonth RecurrenceByDay TeamID)
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
        my $RecurrenceUntilSystem = $Self->_SystemTimeGet(
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

    my @Bind;

    # parent ID supplied
    my $ParentIDCol = my $ParentIDVal = '';
    if ( $Param{ParentID} ) {
        $ParentIDCol = 'parent_id,';
        $ParentIDVal = '?,';
        push @Bind, \$Param{ParentID};

        # turn off all recurring fields
        delete $Param{Recurring};
        delete $Param{RecurrenceFrequency};
        delete $Param{RecurrenceCount};
        delete $Param{RecurrenceInterval};
        delete $Param{RecurrenceUntil};
        delete $Param{RecurrenceByYear};
        delete $Param{RecurrenceByMonth};
        delete $Param{RecurrenceByDay};
    }

    push @Bind, \$Param{CalendarID}, \$UniqueID, \$Param{Title}, \$Param{Description},
        \$Param{Location}, \$Param{StartTime}, \$Param{EndTime}, \$Param{AllDay},
        \$Param{TimezoneID}, \$Param{TeamID}, \$ResourceID, \$Param{Recurring}, \$Param{RecurrenceFrequency},
        \$Param{RecurrenceCount},  \$Param{RecurrenceInterval}, \$Param{RecurrenceUntil},
        \$Param{RecurrenceByYear}, \$Param{RecurrenceByMonth},  \$Param{RecurrenceByDay},
        \$Param{UserID},           \$Param{UserID};

    my $SQL = "
        INSERT INTO calendar_appointment
            ($ParentIDCol calendar_id, unique_id, title, description, location, start_time,
            end_time, all_day, timezone_id, team_id, resource_id, recurring, recur_freq,
            recur_count, recur_interval, recur_until, recur_byyear, recur_bymonth, recur_byday,
            create_time, create_by, change_time, change_by)
        VALUES ($ParentIDVal ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,
            current_timestamp, ?, current_timestamp, ?)
    ";

    # create db record
    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL  => $SQL,
        Bind => \@Bind,
    );

    # get appointment id
    my $AppointmentID = $Self->_AppointmentGetID(
        UniqueID => $UniqueID,
    );

    # return if there is not appointment created
    if ( !$AppointmentID ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Can\'t get AppointmentID from INSERT!',
        );
        return;
    }

    # add recurring appointments
    if ( $Param{Recurring} ) {

        # reset unique_id
        $Param{UniqueID} = '';

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
            TeamID        => 1,
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
    my $CacheType     = $Self->{CacheType} . 'List' . $Param{CalendarID};
    my $CacheKeyStart = $Param{StartTime} || 'any';
    my $CacheKeyEnd   = $Param{EndTime} || 'any';
    my $CacheKeyTeam  = $Param{TeamID} || 'any';

    # check cache
    my $Data = $Kernel::OM->Get('Kernel::System::Cache')->Get(
        Type => $CacheType,
        Key  => "$CacheKeyStart-$CacheKeyEnd-$CacheKeyTeam-$Param{Result}",
    );

    if ( ref $Data eq 'ARRAY' ) {
        return @{$Data};
    }

    # needed objects
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # check time
    if ( $Param{StartTime} ) {
        my $StartTimeSystem = $Self->_SystemTimeGet(
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
        $Param{StartTime} = $Self->_TimestampGet(
            SystemTime => $StartTimeSystem,
        );
    }
    if ( $Param{EndTime} ) {
        my $EndTimeSystem = $Self->_SystemTimeGet(
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
        $Param{EndTime} = $Self->_TimestampGet(
            SystemTime => $EndTimeSystem,
        );
    }

    # check TeamID
    if ( $Param{TeamID} ) {
        if ( !IsInteger( $Param{TeamID} ) ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "TeamID must be a number!"
            );
            return;
        }
    }

    my $SQL = '
        SELECT id, parent_id, calendar_id, unique_id, title, description, location, start_time,
            end_time, timezone_id, team_id, resource_id, all_day, recurring
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

    if ( $Param{TeamID} ) {

        $SQL .= 'AND team_id = ? ';
        push @Bind, \$Param{TeamID};
    }

    $SQL .= 'ORDER BY id ASC';

    # db query
    return if !$DBObject->Prepare(
        SQL  => $SQL,
        Bind => \@Bind,
    );

    my @Result;

    while ( my @Row = $DBObject->FetchrowArray() ) {

        # resource id
        $Row[11] = $Row[11] ? $Row[11] : 0;
        my @ResourceID = $Row[11] =~ /,/ ? split( ',', $Row[11] ) : ( $Row[11] );

        my %Appointment = (
            AppointmentID => $Row[0],
            ParentID      => $Row[1],
            CalendarID    => $Row[2],
            UniqueID      => $Row[3],
            Title         => $Row[4],
            Description   => $Row[5],
            Location      => $Row[6],
            StartTime     => $Row[7],
            EndTime       => $Row[8],
            TimezoneID    => $Row[9],
            TeamID        => $Row[10],
            ResourceID    => \@ResourceID,
            AllDay        => $Row[12],
            Recurring     => $Row[13],
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
        Key   => "$CacheKeyStart-$CacheKeyEnd-$CacheKeyTeam-$Param{Result}",
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
        my $StartTimeValid = $Self->_SystemTimeGet(
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
        my $EndTimeValid = $Self->_SystemTimeGet(
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
        $StartTimeSystem = $Self->_SystemTimeGet(
            String => $StartTime,
        );

        $EndTimeSystem = $Self->_SystemTimeGet(
            String => $EndTime,
        );

        for (
            my $LoopSystemTime = $StartTimeSystem;
            $LoopSystemTime < $EndTimeSystem;
            $LoopSystemTime += 60 * 60 * 24
            )
        {
            my $LoopTime = $Self->_TimestampGet(
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
        UniqueID      => '20160101T160000-71E386@localhost', # (required)
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
        TeamID              => 1,
        ResourceID          => [ 1, 3 ],
        Recurring           => 1,                                  # only for recurring (parent) appointments
        RecurrenceFrequency => 1,
        RecurrenceCount     => 1,
        RecurrenceInterval  => '',
        RecurrenceUntil     => '',
        RecurrenceByYear    => '',
        RecurrenceByMonth   => '',
        RecurrenceByDay     => '',
        CreateTime          => '2016-01-01 00:00:00',
        CreateBy            => 2,
        ChangeTime          => '2016-01-01 00:00:00',
        ChangeBy            => 2,
    );
=cut

sub AppointmentGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{AppointmentID} && !$Param{UniqueID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need AppointmentID or UniqueID!"
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
            end_time, all_day, timezone_id, team_id, resource_id, recurring, recur_freq,
            recur_count, recur_interval, recur_until, recur_byyear, recur_bymonth, recur_byday,
            create_time, create_by, change_time, change_by
        FROM calendar_appointment
        WHERE
    ';

    if ( $Param{AppointmentID} ) {
        $SQL .= "id=? ";
        push @Bind, \$Param{AppointmentID};
    }
    else {
        $SQL .= "unique_id=? ";
        push @Bind, \$Param{UniqueID};
    }

    # db query
    return if !$DBObject->Prepare(
        SQL  => $SQL,
        Bind => \@Bind,
    );

    my %Result;

    while ( my @Row = $DBObject->FetchrowArray() ) {

        # resource id
        $Row[12] = $Row[12] ? $Row[12] : 0;
        my @ResourceID = $Row[12] =~ /,/ ? split( ',', $Row[12] ) : ( $Row[12] );

        $Result{AppointmentID}       = $Row[0];
        $Result{ParentID}            = $Row[1];
        $Result{CalendarID}          = $Row[2];
        $Result{UniqueID}            = $Row[3];
        $Result{Title}               = $Row[4];
        $Result{Description}         = $Row[5];
        $Result{Location}            = $Row[6];
        $Result{StartTime}           = $Row[7];
        $Result{EndTime}             = $Row[8];
        $Result{AllDay}              = $Row[9];
        $Result{TimezoneID}          = $Row[10];
        $Result{TeamID}              = $Row[11];
        $Result{ResourceID}          = \@ResourceID;
        $Result{Recurring}           = $Row[13];
        $Result{RecurrenceFrequency} = $Row[14];
        $Result{RecurrenceCount}     = $Row[15];
        $Result{RecurrenceInterval}  = $Row[16];
        $Result{RecurrenceUntil}     = $Row[17];
        $Result{RecurrenceByYear}    = $Row[18];
        $Result{RecurrenceByMonth}   = $Row[19];
        $Result{RecurrenceByDay}     = $Row[20];
        $Result{CreateTime}          = $Row[21];
        $Result{CreateBy}            = $Row[22];
        $Result{ChangeTime}          = $Row[23];
        $Result{ChangeBy}            = $Row[24];
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
        AppointmentID       => 2,                                       # (required)
        CalendarID          => 1,                                       # (required) Valid CalendarID
        Title               => 'Webinar',                               # (required) Title
        Description         => 'How to use Process tickets...',         # (optional) Description
        Location            => 'Straubing',                             # (optional) Location
        StartTime           => '2016-01-01 16:00:00',                   # (required)
        EndTime             => '2016-01-01 17:00:00',                   # (required)
        AllDay              => 0,                                       # (optional) Default 0
        TimezoneID          => -2,                                      # (optional) Timezone - it can be 0 (UTC)
        Team                => 1,                                       # (optional)
        ResourceID          => [ 1, 3 ],                                # (optional) must be an array reference if supplied
        Recurring           => 1,                                       # (optional) only for recurring (parent) appointments
                                                                        # if Recurring is set, one of the following 3 parameters must be provided
        RecurrenceByYear    => 2,                                       # (optional)
        RecurrenceByMonth   => 2,                                       # (optional)
        RecurrenceByDay     => 5,                                       # (optional)

        RecurrenceFrequency => 1,                                       # (optional)
        RecurrenceCount     => 1,                                       # (optional)
        RecurrenceInterval  => 2,                                       # (optional)
        RecurrenceUntil     => '2016-01-10 00:00:00',                   # (optional)
        UserID              => 1,                                       # (required) UserID
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

    # if Recurring is provided, additional parameter must be present
    if (
        $Param{Recurring}
        &&
        (
            !$Param{RecurrenceByYear} &&
            !$Param{RecurrenceByMonth} &&
            !$Param{RecurrenceByDay}
        )
        )
    {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Recurring appointment, additional parameter needed"
                . "(RecurrenceFrequency, RecurrenceCount, RecurrenceInterval, RecurrenceUntil, RecurrenceByYear, RecurrenceByMonth or RecurrenceByDay)!",
        );
        return;
    }

    $Param{RecurrenceFrequency} ||= 1;

    # check StartTime
    my $StartTimeSystem = $Self->_SystemTimeGet(
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
    my $EndTimeSystem = $Self->_SystemTimeGet(
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

    # check ResourceID
    my $ResourceID;
    if ( $Param{ResourceID} ) {
        if ( !IsArrayRefWithData( $Param{ResourceID} ) ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "ResourceID not a ARRAYREF!",
            );
            return;
        }
        $ResourceID = join( ',', @{ $Param{ResourceID} } );
    }

    # check if numbers
    for my $Parameter (
        qw(Recurring RecurrenceFrequency RecurrenceCount RecurrenceInterval RecurrenceByYear RecurrenceByMonth RecurrenceByDay TeamID)
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
        my $RecurrenceUntilSystem = $Self->_SystemTimeGet(
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

    # update parent appointment
    my $SQL = '
        UPDATE calendar_appointment
        SET
            parent_id=NULL, calendar_id=?, title=?, description=?, location=?, start_time=?,
            end_time=?, all_day=?, timezone_id=?, team_id=?, resource_id=?, recurring=?,
            recur_freq=?, recur_count=?, recur_interval=?, recur_until=?, recur_byyear=?,
            recur_bymonth=?, recur_byday=?, change_time=current_timestamp, change_by=?
        WHERE id=?
    ';

    # update db record
    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL  => $SQL,
        Bind => [
            \$Param{CalendarID}, \$Param{Title},   \$Param{Description}, \$Param{Location},
            \$Param{StartTime},  \$Param{EndTime}, \$Param{AllDay},      \$Param{TimezoneID},
            \$Param{TeamID}, \$ResourceID, \$Param{Recurring}, \$Param{RecurrenceFrequency},
            \$Param{RecurrenceCount},  \$Param{RecurrenceInterval}, \$Param{RecurrenceUntil},
            \$Param{RecurrenceByYear}, \$Param{RecurrenceByMonth},  \$Param{RecurrenceByDay},
            \$Param{UserID},           \$Param{AppointmentID}
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

    # delete recurring appointments
    my $DeleteRecurringSuccess = $Self->_AppointmentRecurringDelete(
        ParentID => $Param{AppointmentID},
    );

    if ( !$DeleteRecurringSuccess ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Recurring appointment couldn\'t be deleted!',
        );
        return;
    }

    # delete parent appointment
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

    my $StartTimeSystem = $Self->_SystemTimeGet(
        String => $Param{Appointment}->{StartTime},
    );
    my $EndTimeSystem = $Self->_SystemTimeGet(
        String => $Param{Appointment}->{EndTime},
    );

    my $OriginalStartTime = $StartTimeSystem;
    my $OriginalEndTime   = $EndTimeSystem;
    my $Step              = 0;

    # Clear UniqueID
    $Param{Appointment}->{UniqueID} = '';

    # until ...
    if ( $Param{Appointment}->{RecurrenceUntil} ) {

        my $RecurrenceUntilSystem = $Self->_SystemTimeGet(
            String => $Param{Appointment}->{RecurrenceUntil},
        );

        UNTIL_TIME:
        while ( $StartTimeSystem < $RecurrenceUntilSystem ) {
            $Step += $Param{Appointment}->{RecurrenceFrequency};

            # calculate recurring times
            $StartTimeSystem = $Self->_CalculateRecurenceTime(
                Appointment  => $Param{Appointment},
                Step         => $Step,
                OriginalTime => $OriginalStartTime,
                CurrentTime  => $StartTimeSystem,
            );
            $EndTimeSystem = $Self->_CalculateRecurenceTime(
                Appointment  => $Param{Appointment},
                Step         => $Step,
                OriginalTime => $OriginalEndTime,
                CurrentTime  => $EndTimeSystem,
            );

            last UNTIL_TIME if !$StartTimeSystem;

            my $StartTime = $Self->_TimestampGet(
                SystemTime => $StartTimeSystem
            );
            my $EndTime = $Self->_TimestampGet(
                SystemTime => $EndTimeSystem
            );

            # bugfix: On some systems with older perl version system might calculate timezone difference
            $StartTime = $Self->_TimeCheck(
                OriginalTime => $Param{Appointment}->{StartTime},
                Time         => $StartTime,
            );
            $EndTime = $Self->_TimeCheck(
                OriginalTime => $Param{Appointment}->{EndTime},
                Time         => $EndTime,
            );

            $Self->AppointmentCreate(
                %{ $Param{Appointment} },
                ParentID  => $Param{ParentID},
                StartTime => $StartTime,
                EndTime   => $EndTime,
            );
        }
    }

    # for ... time(s)
    if ( $Param{Appointment}->{RecurrenceCount} ) {
        COUNT:
        for ( 1 .. $Param{Appointment}->{RecurrenceCount} - 1 ) {
            $Step += $Param{Appointment}->{RecurrenceFrequency};

            # calculate recurring times
            $StartTimeSystem = $Self->_CalculateRecurenceTime(
                Appointment  => $Param{Appointment},
                Step         => $Step,
                OriginalTime => $OriginalStartTime,
                CurrentTime  => $StartTimeSystem,
            );
            $EndTimeSystem = $Self->_CalculateRecurenceTime(
                Appointment  => $Param{Appointment},
                Step         => $Step,
                OriginalTime => $OriginalEndTime,
                CurrentTime  => $EndTimeSystem,
            );

            last COUNT if !$StartTimeSystem;

            my $StartTime = $Self->_TimestampGet(
                SystemTime => $StartTimeSystem
            );
            my $EndTime = $Self->_TimestampGet(
                SystemTime => $EndTimeSystem
            );

            # bugfix: On some systems with older perl version system might calculate timezone difference
            $StartTime = $Self->_TimeCheck(
                OriginalTime => $Param{Appointment}->{StartTime},
                Time         => $StartTime,
            );
            $EndTime = $Self->_TimeCheck(
                OriginalTime => $Param{Appointment}->{EndTime},
                Time         => $EndTime,
            );

            $Self->AppointmentCreate(
                %{ $Param{Appointment} },
                ParentID  => $Param{ParentID},
                StartTime => $StartTime,
                EndTime   => $EndTime,
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

sub _GetUniqueID {
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
    my $CurrentTimestamp = $Self->_CurrentTimestampGet();
    my $String           = "$Param{CalendarID}-$CurrentTimestamp-$Param{UserID}";
    my $Digest           = unpack( 'N', Digest::MD5->new()->add($String)->digest() );
    my $DigestHex        = sprintf( '%x', $Digest );
    my $Hash             = uc( sprintf( "%.6s", $DigestHex ) );

    # prepare start timestamp for UniqueID
    my $StartTimeStrg = $Self->_TimestampGet(
        SystemTime => $Param{StartTime},
    );
    $StartTimeStrg =~ s/[-:]//g;
    $StartTimeStrg =~ s/\s/T/;

    # get system FQDN
    my $FQDN = $Kernel::OM->Get('Kernel::Config')->Get('FQDN');

    # return UniqueID
    return "$StartTimeStrg-$Hash\@$FQDN";
}

sub _AppointmentGetID {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(UniqueID)) {
        if ( !defined $Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    # sql query
    my @Bind = ( \$Param{UniqueID} );
    my $SQL  = 'SELECT id FROM calendar_appointment WHERE unique_id = ? ORDER BY id DESC';

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # start query
    return if !$DBObject->Prepare(
        SQL   => $SQL,
        Bind  => \@Bind,
        Limit => 1,
    );

    my $ID;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $ID = $Row[0];
    }

    return $ID;
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

# Months, Years
sub _AddPeriod {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(Time)) {
        if ( !defined $Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    $Param{Months} //= 0;
    $Param{Years}  //= 0;

    my $DateTimeObject = $Kernel::OM->Create(
        'Kernel::System::DateTime',
        ObjectParams => {
            Epoch => $Param{Time},
            }
    );

    # remember start day
    my $StartDay = $DateTimeObject->Get()->{Day};

    $DateTimeObject->Add(
        Months => $Param{Months},
        Years  => $Param{Years},
    );

    # get end day
    my $EndDay = $DateTimeObject->Get()->{Day};

    # check if month doesn't have enough days (for example: january 31 + 1 month = march 01)
    if ( $StartDay != $EndDay ) {
        $DateTimeObject->Subtract(
            Days => $EndDay,
        );
    }

    return $DateTimeObject->ToEpoch();
}

sub _CalculateRecurenceTime {
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

    my $SystemTime = $Param{CurrentTime};

    if ( $Param{Appointment}->{RecurrenceByDay} ) {

        # calculate recurring times
        $SystemTime += $Param{Appointment}->{RecurrenceFrequency} * 60 * 60 * 24;
    }
    elsif ( $Param{Appointment}->{RecurrenceByMonth} ) {

        $SystemTime = $Self->_AddPeriod(
            Time   => $Param{OriginalTime},
            Months => $Param{Step},
        );
    }
    elsif ( $Param{Appointment}->{RecurrenceByYear} ) {

        $SystemTime = $Self->_AddPeriod(
            Time  => $Param{OriginalTime},
            Years => $Param{Step},
        );
    }
    else {
        return;
    }

    return $SystemTime;
}

sub _TimeCheck {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(OriginalTime Time)) {
        if ( !defined $Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    my $Result = '';

    $Param{OriginalTime} =~ /(.*?)\s(.*?)$/;
    my $OriginalDate = $1;
    my $OriginalTime = $2;

    $Param{Time} =~ /(.*?)\s(.*?)$/;
    my $Date = $1;

    $Result = "$Date $OriginalTime";
    return $Result;
}

sub _SystemTimeGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw( String )) {
        if ( !defined $Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    # extract data
    $Param{String} =~ /(\d{4})-(\d{2})-(\d{2})\s(\d{2}):(\d{2}):(\d{2})$/;

    my %Data = (
        Year   => $1,
        Month  => $2,
        Day    => $3,
        Hour   => $4,
        Minute => $5,
        Second => $6,
    );

    # Create an object with a specific date and time:
    my $DateTimeObject = $Kernel::OM->Create(
        'Kernel::System::DateTime',
        ObjectParams => {
            %Data,

            # TimeZone => 'Europe/Berlin',        # optional, defaults to setting of SysConfig OTRSTimeZone
            }
    );

    # check system time
    return $DateTimeObject->ToEpoch();
}

sub _TimestampGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw( SystemTime )) {
        if ( !defined $Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    my $DateTimeObject = $Kernel::OM->Create(
        'Kernel::System::DateTime',
        ObjectParams => {
            Epoch => $Param{SystemTime},
            }
    );

    # get timestamp
    return $DateTimeObject->ToString();
}

sub _CurrentTimestampGet {
    my ( $Self, %Param ) = @_;

    # Create an object with current date and time
    # within time zone set in SysConfig OTRSTimeZone:
    my $DateTimeObject = $Kernel::OM->Create(
        'Kernel::System::DateTime'
    );

    return $DateTimeObject->ToString();
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not
