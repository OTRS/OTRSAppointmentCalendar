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
        CalendarID          => 1,                                       # (required) Valid CalendarID
        Title               => 'Webinar',                               # (required) Title
        Description         => 'How to use Process tickets...',         # (optional) Description
        Location            => 'Straubing',                             # (optional) Location
        StartTime           => '2016-01-01 16:00:00',                   # (required)
        EndTime             => '2016-01-01 17:00:00',                   # (required)
        AllDay              => '0',                                     # (optional) Default 0
        TimezoneID          => 'Timezone',                              # (required)
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

    # check StartTime
    my $StartTimeSystem = $TimeObject->TimeStamp2SystemTime(
        String => $Param{StartTime},
    );
    return if !$StartTimeSystem;

    # generate a UniqueID
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

    # check RecurrenceFrequency
    return if ( $Param{RecurrenceFrequency} && !IsInteger( $Param{RecurrenceFrequency} ) );

    # check RecurrenceCount
    return if ( $Param{RecurrenceCount} && !IsInteger( $Param{RecurrenceCount} ) );

    # check RecurrenceInterval
    return if ( $Param{RecurrenceInterval} && !IsInteger( $Param{RecurrenceInterval} ) );

    # check RecurrenceUntil
    my $RecurrenceUntilSystem;
    if ( $Param{RecurrenceUntil} ) {
        $RecurrenceUntilSystem = $TimeObject->TimeStamp2SystemTime(
            String => $Param{RecurrenceUntil},
        );
        return if !$RecurrenceUntilSystem;
        return if !( $StartTimeSystem < $RecurrenceUntilSystem );
    }

    # check RecurrenceByMonth
    return if ( $Param{RecurrenceByMonth} && !IsInteger( $Param{RecurrenceByMonth} ) );

    # check RecurrenceByDay
    return if ( $Param{RecurrenceByDay} && !IsInteger( $Param{RecurrenceByDay} ) );

    my $SQL = '
        INSERT INTO calendar_appointment
            (calendar_id, unique_id, title, description, location, start_time, end_time, all_day,
            timezone_id, recur_freq, recur_count, recur_interval, recur_until, recur_bymonth,
            recur_byday, create_time, create_by, change_time, change_by)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, current_timestamp, ?, current_timestamp, ?)
    ';

    # create db record
    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL  => $SQL,
        Bind => [
            \$Param{CalendarID}, \$UniqueID, \$Param{Title}, \$Param{Description},
            \$Param{Location}, \$Param{StartTime}, \$Param{EndTime}, \$Param{AllDay},
            \$Param{TimezoneID}, \$Param{RecurrenceFrequency}, \$Param{RecurrenceCount},
            \$Param{RecurrenceInterval}, \$Param{RecurrenceUntil},
            \$Param{RecurrenceByMonth},  \$Param{RecurrenceByDay},
            \$Param{UserID},             \$Param{UserID}
        ],
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
    if ( $Param{RecurrenceFrequency} && $Param{RecurrenceUntil} ) {

        while ( $StartTimeSystem < $RecurrenceUntilSystem ) {

            # calculate recurring times
            $StartTimeSystem = $StartTimeSystem + $Param{RecurrenceFrequency} * 60 * 60 * 24;
            $EndTimeSystem   = $EndTimeSystem + $Param{RecurrenceFrequency} * 60 * 60 * 24,
                my $StartTime = $TimeObject->SystemTime2TimeStamp(
                SystemTime => $StartTimeSystem,
                );
            my $EndTime = $TimeObject->SystemTime2TimeStamp(
                SystemTime => $EndTimeSystem,
            );

            $SQL = '
                INSERT INTO calendar_recurring
                    (appointment_id, start_time, end_time)
                VALUES (?, ?, ?)
            ';

            # create db record
            return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
                SQL  => $SQL,
                Bind => [
                    \$AppointmentID, \$StartTime, \$EndTime
                ],
            );
        }

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
    );

returns an array of hashes with select Appointment data:
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
            CalendarID  => 1,
            UniqueID    => '20160101T180000-A78B57@localhost',
            Title       => 'Webinar',
            StartTime   => '2016-01-01 18:00:00',
            EndTime     => '2016-01-01 19:00:00',
            AllDay      => 0,
        },
        ...
    ];
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

    # cache keys
    my $CacheType     = $Self->{CacheType} . 'List' . $Param{CalendarID};
    my $CacheKeyStart = $Param{StartTime} || 'any';
    my $CacheKeyEnd   = $Param{EndTime} || 'any';

    # check cache
    my $Data = $Kernel::OM->Get('Kernel::System::Cache')->Get(
        Type => $CacheType,
        Key  => "$CacheKeyStart-$CacheKeyEnd",
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
        SELECT ca.id, ca.calendar_id, ca.unique_id, ca.title, ca.start_time, ca.end_time,
            ca.all_day, cr.start_time, cr.end_time
        FROM calendar_appointment ca
        LEFT JOIN calendar_recurring cr ON cr.appointment_id = ca.id
        WHERE 1=1
    ';

    my @Bind;

    if ( $Param{StartTime} && $Param{EndTime} ) {

        $SQL .= 'AND (
            (
                cr.start_time IS NULL AND cr.end_time IS NULL AND (
                    (ca.start_time >= ? AND ca.start_time < ?) OR
                    (ca.end_time > ? AND ca.end_time <= ?)
                )
            ) OR (
                cr.start_time AND cr.end_time AND (
                    (cr.start_time >= ? AND cr.start_time < ?) OR
                    (cr.end_time > ? AND cr.end_time <= ?)
                )
            )
        ) ';
        push @Bind, \$Param{StartTime}, \$Param{EndTime}, \$Param{StartTime}, \$Param{EndTime},
            \$Param{StartTime}, \$Param{EndTime}, \$Param{StartTime}, \$Param{EndTime};
    }
    elsif ( $Param{StartTime} && !$Param{EndTime} ) {

        $SQL .= 'AND (
            (cr.start_time IS NULL AND ca.start_time >= ?) OR
            (cr.start_time AND cr.start_time >= ?)
        )';
        push @Bind, \$Param{StartTime}, \$Param{StartTime};
    }
    elsif ( !$Param{StartTime} && $Param{EndTime} ) {

        $SQL .= 'AND (
            (cr.end_time IS NULL AND ca.end_time <= ?) OR
            (cr.end_time AND cr.end_time <= ?)
        )';
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
            CalendarID => $Row[1],
            UniqueID   => $Row[2],
            Title      => $Row[3],
            StartTime  => $Row[7] // $Row[4],
            EndTime    => $Row[8] // $Row[5],
            AllDay     => $Row[6],
        );
        push @Result, \%Appointment;
    }

    # cache
    $Kernel::OM->Get('Kernel::System::Cache')->Set(
        Type  => $CacheType,
        Key   => "$CacheKeyStart-$CacheKeyEnd",
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
        ID                  => 1,
        CalendarID          => 1,
        UniqueID            => '20160101T160000-71E386@localhost',
        Title               => 'Webinar',
        Description         => 'How to use Process tickets...',
        Location            => 'Straubing',
        StartTime           => '2016-01-01 16:00:00',
        EndTime             => '2016-01-01 17:00:00',
        AllDay              => 0,
        TimezoneID          => 'Timezone',
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
        SELECT id, calendar_id, unique_id, title, description, location, start_time, end_time, all_day,
            timezone_id, recur_freq, recur_count, recur_interval, recur_until, recur_bymonth,
            recur_byday, create_time, create_by, change_time, change_by
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
        $Result{CalendarID}          = $Row[1];
        $Result{UniqueID}            = $Row[2];
        $Result{Title}               = $Row[3];
        $Result{Description}         = $Row[4];
        $Result{Location}            = $Row[5];
        $Result{StartTime}           = $Row[6];
        $Result{EndTime}             = $Row[7];
        $Result{AllDay}              = $Row[8];
        $Result{TimezoneID}          = $Row[9];
        $Result{RecurrenceFrequency} = $Row[10];
        $Result{RecurrenceCount}     = $Row[11];
        $Result{RecurrenceInterval}  = $Row[12];
        $Result{RecurrenceUntil}     = $Row[13];
        $Result{RecurrenceByMonth}   = $Row[14];
        $Result{RecurrenceByDay}     = $Row[15];
        $Result{CreateTime}          = $Row[16];
        $Result{CreateBy}            = $Row[17];
        $Result{ChangeTime}          = $Row[18];
        $Result{ChangeBy}            = $Row[19];
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
        AppointmentID       => 1,                                       # (required)
        CalendarID          => 1,                                       # (required) Valid CalendarID
        Title               => 'Webinar',                               # (required) Title
        Description         => 'How to use Process tickets...',         # (optional) Description
        Location            => 'Straubing',                             # (optional) Location
        StartTime           => '2016-01-01 16:00:00',                   # (required)
        EndTime             => '2016-01-01 17:00:00',                   # (required)
        AllDay              => 0,                                       # (optional) Default 0
        TimezoneID          => 'Timezone',                              # (required)
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

    # Check EndTime
    my $EndTimeSystem = $TimeObject->TimeStamp2SystemTime(
        String => $Param{EndTime},
    );
    return if !$EndTimeSystem;

    # TODO: Check timezome

    # check RecurrenceFrequency
    return if ( $Param{RecurrenceFrequency} && !IsInteger( $Param{RecurrenceFrequency} ) );

    # check RecurrenceCount
    return if ( $Param{RecurrenceCount} && !IsInteger( $Param{RecurrenceCount} ) );

    # check RecurrenceInterval
    return if ( $Param{RecurrenceInterval} && !IsInteger( $Param{RecurrenceInterval} ) );

    # check RecurrenceUntil
    my $RecurrenceUntilSystem;
    if ( $Param{RecurrenceUntil} ) {
        $RecurrenceUntilSystem = $TimeObject->TimeStamp2SystemTime(
            String => $Param{RecurrenceUntil},
        );
        return if !$RecurrenceUntilSystem;
        return if !( $StartTimeSystem < $RecurrenceUntilSystem );
    }

    # check RecurrenceByMonth
    return if ( $Param{RecurrenceByMonth} && !IsInteger( $Param{RecurrenceByMonth} ) );

    # check RecurrenceByDay
    return if ( $Param{RecurrenceByDay} && !IsInteger( $Param{RecurrenceByDay} ) );

    # delete recurring appointments
    my $SQL = '
        DELETE FROM calendar_recurring
        WHERE appointment_id=?
    ';

    # delete db record
    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL  => $SQL,
        Bind => [
            \$Param{AppointmentID},
        ],
    );

    # update parent appointment
    $SQL = '
        UPDATE calendar_appointment
        SET
            calendar_id=?, title=?, description=?, location=?, start_time=?, end_time=?, all_day=?,
            timezone_id=?, recur_freq=?, recur_count=?, recur_interval=?, recur_until=?,
            recur_bymonth=?, recur_byday=?, change_time=current_timestamp, change_by=?
        WHERE id=?
    ';

    # update db record
    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL  => $SQL,
        Bind => [
            \$Param{CalendarID}, \$Param{Title},   \$Param{Description}, \$Param{Location},
            \$Param{StartTime},  \$Param{EndTime}, \$Param{AllDay},      \$Param{TimezoneID},
            \$Param{RecurrenceFrequency}, \$Param{RecurrenceCount},   \$Param{RecurrenceInterval},
            \$Param{RecurrenceUntil},     \$Param{RecurrenceByMonth}, \$Param{RecurrenceByDay},
            \$Param{UserID},              \$Param{AppointmentID}
        ],
    );

    # add recurring appointments
    if ( $Param{RecurrenceFrequency} && $Param{RecurrenceUntil} ) {

        while ( $StartTimeSystem < $RecurrenceUntilSystem ) {

            # calculate recurring times
            $StartTimeSystem = $StartTimeSystem + $Param{RecurrenceFrequency} * 60 * 60 * 24;
            $EndTimeSystem   = $EndTimeSystem + $Param{RecurrenceFrequency} * 60 * 60 * 24,
                my $StartTime = $TimeObject->SystemTime2TimeStamp(
                SystemTime => $StartTimeSystem,
                );
            my $EndTime = $TimeObject->SystemTime2TimeStamp(
                SystemTime => $EndTimeSystem,
            );

            $SQL = '
                INSERT INTO calendar_recurring
                    (appointment_id, start_time, end_time)
                VALUES (?, ?, ?)
            ';

            # create db record
            return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
                SQL  => $SQL,
                Bind => [
                    \$Param{AppointmentID}, \$StartTime, \$EndTime
                ],
            );
        }

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

    my %Appointment = $Self->AppointmentGet(
        AppointmentID => $Param{AppointmentID},
    );

    # delete recurring appointments
    my $SQL = '
        DELETE FROM calendar_recurring
        WHERE appointment_id=?
    ';

    # delete db record
    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL  => $SQL,
        Bind => [
            \$Param{AppointmentID},
        ],
    );

    # delete single appointments
    $SQL = '
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
