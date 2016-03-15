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

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
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

    return $Self;
}

=item AppointmentCreate()

creates a new appointment.

    my $Success = $AppointmentObject->AppointmentCreate(
        CalendarID          => 1,                                       # (required) Valid CalendarID
        Title               => 'Webinar',                               # (required) Title
        Description         => 'How to use Process tickets...',         # (required) Description
        Location            => 'Straubing'                              # (optional) Location
        StartTime           => '2016-01-01 16:00:00',                   # (required)
        EndTime             => '2016-01-01 17:00:00',                   # (optional)
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

=cut

sub AppointmentCreate {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(CalendarID Title Description StartTime TimezoneID UserID)) {
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
    if ( $Param{EndTime} ) {
        my $EndTimeSystem = $TimeObject->TimeStamp2SystemTime(
            String => $Param{EndTime},
        );
        return if !$EndTimeSystem;
    }

    # TODO: Check timezome

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
    }

    # check RecurrenceByMonth
    return if ( $Param{RecurrenceByMonth} && !IsInteger( $Param{RecurrenceByMonth} ) );

    # check RecurrenceByDay
    return if ( $Param{RecurrenceByDay} && !IsInteger( $Param{RecurrenceByDay} ) );

    my $SQL = '
        INSERT INTO calendar_appointment
            (calendar_id, title, description, location, start_time, end_time, timezone_id, recur_freq, recur_count,
                recur_interval, recur_until, recur_bymonth, recur_byday, create_time, create_by, change_time, change_by)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, current_timestamp, ?, current_timestamp, ?)
    ';

    # create db record
    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL  => $SQL,
        Bind => [
            \$Param{CalendarID}, \$Param{Title}, \$Param{Description}, \$Param{Location}, \$Param{StartTime},
            \$Param{EndTime},
            \$Param{TimezoneID}, \$Param{RecurrenceFrequency}, \$Param{RecurrenceCount}, \$Param{RecurrenceInterval},
            \$Param{RecurrenceUntil},
            \$Param{RecurrenceByMonth}, \$Param{RecurrenceByDay}, \$Param{UserID}, \$Param{UserID}
        ],
    );

    return 1;
}

=item AppointmentList()

get a list of Appointments.

    my @Appointments = $AppointmentObject->AppointmentList(
        CalendarID          => 1,                                       # (required) Valid CalendarID
        StartTime           => '2016-01-01 00:00:00',                   # (optional) Filter by start date
        EndTime             => '2016-02-01 00:00:00',                   # (optional) Filter by end date
    );

returns a list of AppointmentIDs:
    @Appointments = [ 1, 2, 5, 7,...];

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

    # needed objects
    my $DBObject   = $Kernel::OM->Get('Kernel::System::DB');
    my $TimeObject = $Kernel::OM->Get('Kernel::System::Time');

    my $SQL = '
        SELECT id
        FROM calendar_appointment
        WHERE calendar_id=?
    ';

    my @Bind;
    push @Bind, \$Param{CalendarID};

    # check start time
    if ( $Param{StartTime} ) {
        my $StartTimeSystem = $TimeObject->TimeStamp2SystemTime(
            String => $Param{StartTime},
        );
        return if !$StartTimeSystem;

        $SQL .= 'AND start_time > ? ';
        push @Bind, \$Param{StartTime}
    }

    # check end time
    if ( $Param{EndTime} ) {
        my $EndTimeSystem = $TimeObject->TimeStamp2SystemTime(
            String => $Param{EndTime},
        );
        return if !$EndTimeSystem;

        $SQL .= 'AND end_time < ? ';
        push @Bind, \$Param{EndTime}
    }

    # db query
    return if !$DBObject->Prepare(
        SQL  => $SQL,
        Bind => \@Bind,
    );

    my @Result;

    while ( my @Row = $DBObject->FetchrowArray() ) {
        push @Result, $Row[0];
    }

    return @Result;
}

=item AppointmentGet()

get Appointment.

    my %Appointment = $AppointmentObject->AppointmentGet(
        AppointmentID          => 1,                            # (required)
    );

returns a hash:
    %Appointment = (
        ID                  => 1,
        CalendarID          => 1,
        Title               => 'Webinar',
        Description         => 'How to use Process tickets...',
        Location            => 'Straubing',
        StartTime           => '2016-01-01 16:00:00',
        EndTime             => '2016-01-01 17:00:00',
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

    # needed objects
    my $DBObject   = $Kernel::OM->Get('Kernel::System::DB');
    my $TimeObject = $Kernel::OM->Get('Kernel::System::Time');

    my $SQL = '
        SELECT id, calendar_id, title, description, location, start_time, end_time, timezone_id,
            recur_freq, recur_count, recur_interval, recur_until, recur_bymonth, recur_byday,
            create_time, create_by, change_time, change_by
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
        $Result{Title}               = $Row[2];
        $Result{Description}         = $Row[3];
        $Result{Location}            = $Row[4];
        $Result{StartTime}           = $Row[5];
        $Result{EndTime}             = $Row[6];
        $Result{TimezoneID}          = $Row[7];
        $Result{RecurrenceFrequency} = $Row[8];
        $Result{RecurrenceCount}     = $Row[9];
        $Result{RecurrenceInterval}  = $Row[10];
        $Result{RecurrenceUntil}     = $Row[11];
        $Result{RecurrenceByMonth}   = $Row[12];
        $Result{RecurrenceByDay}     = $Row[13];
        $Result{CreateTime}          = $Row[14];
        $Result{CreateBy}            = $Row[15];
        $Result{ChangeTime}          = $Row[16];
        $Result{ChangeBy}            = $Row[17];
    }

    return %Result;
}

=item AppointmentUpdate()

updates an existing appointment.

    my $Success = $AppointmentObject->AppointmentUpdate(
        ApointmentID        => 1,                                       # (required)
        CalendarID          => 1,                                       # (required) Valid CalendarID
        Title               => 'Webinar',                               # (required) Title
        Description         => 'How to use Process tickets...',         # (required) Description
        Location            => 'Straubing'                              # (optional) Location
        StartTime           => '2016-01-01 16:00:00',                   # (required)
        EndTime             => '2016-01-01 17:00:00',                   # (optional)
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

=cut

sub AppointmentUpdate {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(AppointmentID CalendarID Title Description StartTime TimezoneID UserID)) {
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
    if ( $Param{EndTime} ) {
        my $EndTimeSystem = $TimeObject->TimeStamp2SystemTime(
            String => $Param{EndTime},
        );
        return if !$EndTimeSystem;
    }

    # TODO: Check timezome

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
    }

    # check RecurrenceByMonth
    return if ( $Param{RecurrenceByMonth} && !IsInteger( $Param{RecurrenceByMonth} ) );

    # check RecurrenceByDay
    return if ( $Param{RecurrenceByDay} && !IsInteger( $Param{RecurrenceByDay} ) );

    my $SQL = '
        UPDATE calendar_appointment
        SET
            calendar_id=?, title=?, description=?, location=?, start_time=?, end_time=?, timezone_id=?, recur_freq=?, recur_count=?,
            recur_interval=?, recur_until=?, recur_bymonth=?, recur_byday=?, change_time=current_timestamp, change_by=?
        WHERE id=?
    ';

    # update db record
    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL  => $SQL,
        Bind => [
            \$Param{CalendarID}, \$Param{Title}, \$Param{Description}, \$Param{Location}, \$Param{StartTime},
            \$Param{EndTime},
            \$Param{TimezoneID}, \$Param{RecurrenceFrequency}, \$Param{RecurrenceCount}, \$Param{RecurrenceInterval},
            \$Param{RecurrenceUntil}, \$Param{RecurrenceByMonth}, \$Param{RecurrenceByDay}, \$Param{UserID},
            \$Param{AppointmentID}
        ],
    );

    return 1;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
