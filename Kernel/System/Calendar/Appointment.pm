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
    'Kernel::System::DB',
    'Kernel::System::Log',
    'Kernel::System::Time',
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
        ParentID            => 1,                                       # (optional) Valid ParentID for recurring appointments
        CalendarID          => 1,                                       # (required) Valid CalendarID
        Title               => 'Webinar',                               # (required) Title
        Description         => 'How to use Process tickets...',         # (optional) Description
        Location            => 'Straubing',                             # (optional) Location
        StartTime           => '2016-01-01 16:00:00',                   # (required)
        EndTime             => '2016-01-01 17:00:00',                   # (required)
        AllDay              => '0',                                     # (optional) Default 0
        TimezoneID          => 'Timezone',                              # (required)
        Recurring           => '1',                                     # (optional) Flag the appointment as recurring (parent only!)
        RecurrenceFrequency => '1',                                     # (optional)
        RecurrenceCount     => '1',                                     # (optional)
        RecurrenceInterval  => '',                                      # (optional)
        RecurrenceUntil     => '',                                      # (optional)
        RecurrenceByMonth   => '',                                      # (optional)
        RecurrenceByDay     => '',                                      # (optional)
        UserID              => 1,                                       # (required) UserID
    );

returns AppointmentID if successful

Events:
    AppointmentCreate

=cut

sub AppointmentCreate {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(CalendarID Title StartTime EndTime TimezoneID UserID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    # needed objects
    my $TimeObject = $Kernel::OM->Get('Kernel::System::Time');

    # check ParentID
    return if ( $Param{ParentID} && !IsInteger( $Param{ParentID} ) );

    # check StartTime
    my $StartTimeSystem = $TimeObject->TimeStamp2SystemTime(
        String => $Param{StartTime},
    );
    return if !$StartTimeSystem;

    my $UniqueID = $Self->_GetUniqueID(
        CalendarID => $Param{CalendarID},
        StartTime  => $StartTimeSystem,
        UserID     => $Param{UserID},
    );

    # check EndTime
    my $EndTimeSystem = $TimeObject->TimeStamp2SystemTime(
        String => $Param{EndTime},
    );
    return if !$EndTimeSystem;

    # TODO: check timezone

    # check Recurring
    return if ( $Param{Recurring} && !IsInteger( $Param{Recurring} ) );

    # check RecurrenceFrequency
    return if ( $Param{RecurrenceFrequency} && !IsInteger( $Param{RecurrenceFrequency} ) );

    # check RecurrenceCount
    return if ( $Param{RecurrenceCount} && !IsInteger( $Param{RecurrenceCount} ) );

    # check RecurrenceInterval
    return if ( $Param{RecurrenceInterval} && !IsInteger( $Param{RecurrenceInterval} ) );

    # check RecurrenceUntil
    if ( $Param{RecurrenceUntil} ) {
        my $RecurrenceUntilSystem = $TimeObject->TimeStamp2SystemTime(
            String => $Param{RecurrenceUntil},
        );
        return if !$RecurrenceUntilSystem;
        return if !( $StartTimeSystem < $RecurrenceUntilSystem );
    }

    # check RecurrenceByMonth
    return if ( $Param{RecurrenceByMonth} && !IsInteger( $Param{RecurrenceByMonth} ) );

    # check RecurrenceByDay
    return if ( $Param{RecurrenceByDay} && !IsInteger( $Param{RecurrenceByDay} ) );

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
        delete $Param{RecurrenceByMonth};
        delete $Param{RecurrenceByDay};
    }

    push @Bind, \$Param{CalendarID}, \$UniqueID, \$Param{Title}, \$Param{Description},
        \$Param{Location}, \$Param{StartTime}, \$Param{EndTime}, \$Param{AllDay},
        \$Param{TimezoneID},        \$Param{Recurring},          \$Param{RecurrenceFrequency},
        \$Param{RecurrenceCount},   \$Param{RecurrenceInterval}, \$Param{RecurrenceUntil},
        \$Param{RecurrenceByMonth}, \$Param{RecurrenceByDay},    \$Param{UserID}, \$Param{UserID};

    my $SQL = "
        INSERT INTO calendar_appointment
            ($ParentIDCol calendar_id, unique_id, title, description, location, start_time,
            end_time, all_day, timezone_id, recurring, recur_freq, recur_count, recur_interval,
            recur_until, recur_bymonth, recur_byday, create_time, create_by, change_time, change_by)
        VALUES ($ParentIDVal ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, current_timestamp, ?,
            current_timestamp, ?)
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
        return if !$Self->_AppointmentRecurringCreate(
            ParentID    => $AppointmentID,
            Appointment => \%Param,
        );
    }

    # clean up list method cache
    $Kernel::OM->Get('Kernel::System::Cache')->CleanUp(
        Type => $Self->{CacheType} . 'List' . $Param{CalendarID},
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
        Result              => 'HASH',                                  # (optional), HASH|ARRAY
    );

returns an array of hashes with select Appointment data or simple array of AppointmentIDs:

Result => 'HASH':

    @Appointments = [
        {
            ID          => 1,
            CalendarID  => 1,
            UniqueID    => '20160101T160000-71E386@localhost',
            Title       => 'Webinar',
            StartTime   => '2016-01-01 16:00:00',
            EndTime     => '2016-01-01 17:00:00',
            AllDay      => 0,
        },
        {
            ID          => 2,
            ParentID    => 1,                                           # for recurred (child) appointments only
            CalendarID  => 1,
            UniqueID    => '20160101T180000-A78B57@localhost',
            Title       => 'Webinar',
            StartTime   => '2016-01-02 16:00:00',
            EndTime     => '2016-01-02 17:00:00',
            AllDay      => 0,
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

    # check cache
    my $Data = $Kernel::OM->Get('Kernel::System::Cache')->Get(
        Type => $CacheType,
        Key  => "$CacheKeyStart-$CacheKeyEnd-$Param{Result}",
    );

    if ( ref $Data eq 'ARRAY' ) {
        return @{$Data};
    }

    # needed objects
    my $DBObject   = $Kernel::OM->Get('Kernel::System::DB');
    my $TimeObject = $Kernel::OM->Get('Kernel::System::Time');

    # Check time
    if ( $Param{StartTime} ) {
        my $StartTimeSystem = $TimeObject->TimeStamp2SystemTime(
            String => $Param{StartTime},
        );
        return if !$StartTimeSystem;
    }
    if ( $Param{EndTime} ) {
        my $EndTimeSystem = $TimeObject->TimeStamp2SystemTime(
            String => $Param{EndTime},
        );
        return if !$EndTimeSystem;
    }

    my $SQL = '
        SELECT id, parent_id, calendar_id, unique_id, title, start_time, end_time, all_day
        FROM calendar_appointment
        WHERE 1=1
    ';

    my @Bind;

    if ( $Param{StartTime} && $Param{EndTime} ) {

        $SQL .= 'AND (
            (start_time >= ? AND start_time < ?) OR
            (end_time > ? AND end_time <= ?)
        ) ';
        push @Bind, \$Param{StartTime}, \$Param{EndTime}, \$Param{StartTime}, \$Param{EndTime};
    }
    elsif ( $Param{StartTime} && !$Param{EndTime} ) {

        $SQL .= 'AND start_time >= ? ';
        push @Bind, \$Param{StartTime}, \$Param{StartTime};
    }
    elsif ( !$Param{StartTime} && $Param{EndTime} ) {

        $SQL .= 'AND end_time <= ?';
        push @Bind, \$Param{EndTime}, \$Param{EndTime};
    }

    # db query
    return if !$DBObject->Prepare(
        SQL  => $SQL,
        Bind => \@Bind,
    );

    my @Result;

    while ( my @Row = $DBObject->FetchrowArray() ) {
        my %Appointment = (
            ID         => $Row[0],
            ParentID   => $Row[1],
            CalendarID => $Row[2],
            UniqueID   => $Row[3],
            Title      => $Row[4],
            StartTime  => $Row[5],
            EndTime    => $Row[6],
            AllDay     => $Row[7],
        );
        push @Result, \%Appointment;
    }

    # if Result was ARRAY, output only unique IDs
    @Result = keys { map { $_->{ID} => 1 } @Result } if $Param{Result} eq 'ARRAY';

    # cache
    $Kernel::OM->Get('Kernel::System::Cache')->Set(
        Type  => $CacheType,
        Key   => "$CacheKeyStart-$CacheKeyEnd-$Param{Result}",
        Value => \@Result,
        TTL   => $Self->{CacheTTL},
    );

    return @Result;
}

=item AppointmentGet()

get Appointment.

    my %Appointment = $AppointmentObject->AppointmentGet(
        AppointmentID => 1,                               # (required)
    );

returns a hash:
    %Appointment = (
        ID                  => 2,
        ParentID            => 1,                                  # only for recurred (child) appointments
        CalendarID          => 1,
        UniqueID            => '20160101T160000-71E386@localhost',
        Title               => 'Webinar',
        Description         => 'How to use Process tickets...',
        Location            => 'Straubing',
        StartTime           => '2016-01-01 16:00:00',
        EndTime             => '2016-01-01 17:00:00',
        AllDay              => 0,
        TimezoneID          => 'Timezone',
        Recurring           => 1,                                  # only for recurring (parent) appointments
        RecurrenceFrequency => '1',
        RecurrenceCount     => '1',
        RecurrenceInterval  => '',
        RecurrenceUntil     => '',
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
    for my $Needed (qw(AppointmentID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    # check cache
    my $Data = $Kernel::OM->Get('Kernel::System::Cache')->Get(
        Type => $Self->{CacheType},
        Key  => $Param{AppointmentID},
    );

    if ( ref $Data eq 'HASH' ) {
        return %{$Data};
    }

    # needed objects
    my $DBObject   = $Kernel::OM->Get('Kernel::System::DB');
    my $TimeObject = $Kernel::OM->Get('Kernel::System::Time');

    my $SQL = '
        SELECT id, parent_id, calendar_id, unique_id, title, description, location, start_time,
            end_time, all_day, timezone_id, recurring, recur_freq, recur_count, recur_interval,
            recur_until, recur_bymonth, recur_byday, create_time, create_by, change_time, change_by
        FROM calendar_appointment
        WHERE id=?
    ';

    # db query
    return if !$DBObject->Prepare(
        SQL  => $SQL,
        Bind => [ \$Param{AppointmentID} ],
    );

    my %Result;

    while ( my @Row = $DBObject->FetchrowArray() ) {
        $Result{ID}                  = $Row[0];
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
        $Result{Recurring}           = $Row[11];
        $Result{RecurrenceFrequency} = $Row[12];
        $Result{RecurrenceCount}     = $Row[13];
        $Result{RecurrenceInterval}  = $Row[14];
        $Result{RecurrenceUntil}     = $Row[15];
        $Result{RecurrenceByMonth}   = $Row[16];
        $Result{RecurrenceByDay}     = $Row[17];
        $Result{CreateTime}          = $Row[18];
        $Result{CreateBy}            = $Row[19];
        $Result{ChangeTime}          = $Row[20];
        $Result{ChangeBy}            = $Row[21];
    }

    # cache
    $Kernel::OM->Get('Kernel::System::Cache')->Set(
        Type  => $Self->{CacheType},
        Key   => $Param{AppointmentID},
        Value => \%Result,
        TTL   => $Self->{CacheTTL},
    );

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
        TimezoneID          => 'Timezone',                              # (required)
        Recurring           => 1,                                       # (optional) only for recurring (parent) appointments
        RecurrenceFrequency => '1',                                     # (optional)
        RecurrenceCount     => '1',                                     # (optional)
        RecurrenceInterval  => '',                                      # (optional)
        RecurrenceUntil     => '',                                      # (optional)
        RecurrenceByMonth   => '',                                      # (optional)
        RecurrenceByDay     => '',                                      # (optional)
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
    for my $Needed (qw(AppointmentID CalendarID Title StartTime EndTime TimezoneID UserID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    # needed objects
    my $TimeObject = $Kernel::OM->Get('Kernel::System::Time');

    # check StartTime
    my $StartTimeSystem = $TimeObject->TimeStamp2SystemTime(
        String => $Param{StartTime},
    );
    return if !$StartTimeSystem;

    # check EndTime
    my $EndTimeSystem = $TimeObject->TimeStamp2SystemTime(
        String => $Param{EndTime},
    );
    return if !$EndTimeSystem;

    # TODO: check timezone

    # check Recurring
    return if ( $Param{Recurring} && !IsInteger( $Param{Recurring} ) );

    # check RecurrenceFrequency
    return if ( $Param{RecurrenceFrequency} && !IsInteger( $Param{RecurrenceFrequency} ) );

    # check RecurrenceCount
    return if ( $Param{RecurrenceCount} && !IsInteger( $Param{RecurrenceCount} ) );

    # check RecurrenceInterval
    return if ( $Param{RecurrenceInterval} && !IsInteger( $Param{RecurrenceInterval} ) );

    # check RecurrenceUntil
    if ( $Param{RecurrenceUntil} ) {
        my $RecurrenceUntilSystem = $TimeObject->TimeStamp2SystemTime(
            String => $Param{RecurrenceUntil},
        );
        return if !$RecurrenceUntilSystem;
        return if !( $StartTimeSystem < $RecurrenceUntilSystem );
    }

    # check RecurrenceByMonth
    return if ( $Param{RecurrenceByMonth} && !IsInteger( $Param{RecurrenceByMonth} ) );

    # check RecurrenceByDay
    return if ( $Param{RecurrenceByDay} && !IsInteger( $Param{RecurrenceByDay} ) );

    # delete existing recurred appointments
    return if !$Self->_AppointmentRecurringDelete(
        ParentID => $Param{AppointmentID},
    );

    # update parent appointment
    my $SQL = '
        UPDATE calendar_appointment
        SET
            parent_id=NULL, calendar_id=?, title=?, description=?, location=?, start_time=?,
            end_time=?, all_day=?, timezone_id=?, recurring=?, recur_freq=?, recur_count=?,
            recur_interval=?, recur_until=?, recur_bymonth=?, recur_byday=?,
            change_time=current_timestamp, change_by=?
        WHERE id=?
    ';

    # update db record
    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL  => $SQL,
        Bind => [
            \$Param{CalendarID}, \$Param{Title},   \$Param{Description}, \$Param{Location},
            \$Param{StartTime},  \$Param{EndTime}, \$Param{AllDay},      \$Param{TimezoneID},
            \$Param{Recurring},          \$Param{RecurrenceFrequency}, \$Param{RecurrenceCount},
            \$Param{RecurrenceInterval}, \$Param{RecurrenceUntil},     \$Param{RecurrenceByMonth},
            \$Param{RecurrenceByDay},    \$Param{UserID},              \$Param{AppointmentID}
        ],
    );

    # add recurred appointments again
    if ( $Param{Recurring} ) {
        return if !$Self->_AppointmentRecurringCreate(
            ParentID    => $Param{AppointmentID},
            Appointment => \%Param,
        );
    }

    # delete cache
    $Kernel::OM->Get('Kernel::System::Cache')->Delete(
        Type => $Self->{CacheType},
        Key  => $Param{AppointmentID},
    );

    # clean up list method cache
    $Kernel::OM->Get('Kernel::System::Cache')->CleanUp(
        Type => $Self->{CacheType} . 'List' . $Param{CalendarID},
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

    # TODO: Check who is able to delete appointment

    # get appointment because of CalendarID
    my %Appointment = $Self->AppointmentGet(
        AppointmentID => $Param{AppointmentID},
    );

    # delete recurring appointments
    return if !$Self->_AppointmentRecurringDelete(
        ParentID => $Param{AppointmentID},
    );

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

    # delete cache
    $Kernel::OM->Get('Kernel::System::Cache')->Delete(
        Type => $Self->{CacheType},
        Key  => $Param{AppointmentID},
    );

    # clean up list method cache
    $Kernel::OM->Get('Kernel::System::Cache')->CleanUp(
        Type => $Self->{CacheType} . 'List' . $Appointment{CalendarID},
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

    # get needed objects
    my $TimeObject = $Kernel::OM->Get('Kernel::System::Time');

    my $StartTimeSystem = $TimeObject->TimeStamp2SystemTime(
        String => $Param{Appointment}->{StartTime},
    );
    my $EndTimeSystem = $TimeObject->TimeStamp2SystemTime(
        String => $Param{Appointment}->{EndTime},
    );

    # until ...
    if ( $Param{Appointment}->{RecurrenceUntil} ) {
        my $RecurrenceUntilSystem = $TimeObject->TimeStamp2SystemTime(
            String => $Param{Appointment}->{RecurrenceUntil},
        );
        while ( $StartTimeSystem < $RecurrenceUntilSystem ) {

            # calculate recurring times
            $StartTimeSystem = $StartTimeSystem + $Param{Appointment}->{RecurrenceFrequency} * 60 * 60 * 24;
            $EndTimeSystem   = $EndTimeSystem + $Param{Appointment}->{RecurrenceFrequency} * 60 * 60 * 24;
            my $StartTime = $TimeObject->SystemTime2TimeStamp( SystemTime => $StartTimeSystem );
            my $EndTime   = $TimeObject->SystemTime2TimeStamp( SystemTime => $EndTimeSystem );

            $Self->AppointmentCreate(
                %{ $Param{Appointment} },
                ParentID  => $Param{ParentID},
                StartTime => $StartTime,
                EndTime   => $EndTime,
            );
        }
    }

    # for ... time(s)
    else {
        for ( 1 .. $Param{Appointment}->{RecurrenceCount} - 1 ) {

            # calculate recurring times
            $StartTimeSystem = $StartTimeSystem + $Param{Appointment}->{RecurrenceFrequency} * 60 * 60 * 24;
            $EndTimeSystem   = $EndTimeSystem + $Param{Appointment}->{RecurrenceFrequency} * 60 * 60 * 24;
            my $StartTime = $TimeObject->SystemTime2TimeStamp( SystemTime => $StartTimeSystem );
            my $EndTime   = $TimeObject->SystemTime2TimeStamp( SystemTime => $EndTimeSystem );

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

    # get time object
    my $TimeObject = $Kernel::OM->Get('Kernel::System::Time');

    # calculate a hash
    my $CurrentTimestamp = $TimeObject->CurrentTimestamp();
    my $String           = "$Param{CalendarID}-$CurrentTimestamp-$Param{UserID}";
    my $Digest           = unpack( 'N', Digest::MD5->new()->add($String)->digest() );
    my $DigestHex        = sprintf( '%x', $Digest );
    my $Hash             = uc( sprintf( "%.6s", $DigestHex ) );

    # prepare start timestamp for UniqueID
    my $StartTimeStrg = $TimeObject->SystemTime2TimeStamp(
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

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not
