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

our @ObjectDependencies = (
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

    return $Self;
}

=item AppointmentCreate()

creates a new appointment.

    my %Appointment = $AppointmentCreate->AppointmentCreate(
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

returns Appointment if successful:
    %Appointment = (
        CalendarID          => 1,
        Title               => 'Webinar',
        Description         => 'How to use Process tickets...',
        Location            => 'Straubing'
        StartTime           => '2016-01-01 16:00:00',
        EndTime             => '2016-01-01 16:00:00',
        TimezoneID          => 'Timezone',
        RecurrenceFrequency => '1',
        RecurrenceCount     => '1',
        RecurrenceInterval  => '',
        RecurrenceUntil     => '',
        RecurrenceByMonth   => '',
        RecurrenceByDay     => '',
        CreateTime          => '2016-01-01 12:00:00',
        CreateBy            => 1,
        ChangeTime          => '2016-01-01 12:00:00',
        ChangeBy            => 1,
    );

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

    # <Column Name="id" Required="true" PrimaryKey="true" AutoIncrement="true" Type="BIGINT"/>
    # <Column Name="calendar_id" Required="true" Type="BIGINT"/>
    # <Column Name="title" Required="true" Size="255" Type="VARCHAR"/>
    # <Column Name="description" Required="true" Size="3800" Type="VARCHAR"/>
    # <Column Name="location" Required="false" Size="255" Type="VARCHAR"/>
    # <Column Name="start_time" Required="true" Type="DATE"/>
    # <Column Name="end_time" Type="DATE"/>
    # <Column Name="timezone_id" Required="true" Size="100" Type="VARCHAR"/>
    # <Column Name="recur_freq" Size="100" Type="VARCHAR"/>
    # <Column Name="recur_count" Type="INTEGER"/>
    # <Column Name="recur_interval" Type="INTEGER"/>
    # <Column Name="recur_until" Type="DATE"/>
    # <Column Name="recur_bymonth" Type="SMALLINT"/>
    # <Column Name="recur_byday" Type="SMALLINT"/>
    # <Column Name="create_time" Type="DATE"/>
    # <Column Name="create_by" Type="INTEGER"/>
    # <Column Name="change_time" Type="DATE"/>
    # <Column Name="change_by" Type="INTEGER"/>

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

    my %Appointment;

    # %Appointment = $Self->AppointmentGet(
    #     Name   => $Param{Name},
    #     UserID => $Param{UserID},
    # );

    return %Appointment;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
