# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Daemon::DaemonModules::SchedulerTaskWorker::CalendarAppointment;

use strict;
use warnings;

use base qw(Kernel::System::Daemon::DaemonModules::BaseTaskWorker);

our @ObjectDependencies = (
    'Kernel::System::Log',
    'Kernel::System::Calendar::Appointment',
);

=head1 NAME

Kernel::System::Daemon::DaemonModules::SchedulerTaskWorker::CalendarAppointment - Scheduler daemon task handler module for CalendarAppointment

=head1 SYNOPSIS

This task handler executes calendar appointment jobs

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

    use Kernel::System::ObjectManager;
    local $Kernel::OM = Kernel::System::ObjectManager->new();
    my $TaskHandlerObject = $Kernel::OM-Get('Kernel::System::Daemon::DaemonModules::SchedulerTaskWorker::CalendarAppointment');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    my $Self = {};
    bless( $Self, $Type );

    $Self->{Debug}      = $Param{Debug};
    $Self->{WorkerName} = 'Worker: CalendarAppointmentStart';

    return $Self;
}

=item Run()

performs the selected task.

    my $Result = $TaskHandlerObject->Run(
        TaskID   => 123,
        TaskName => 'some name',    # optional
        Data     => {               # appointment id as got from Kernel::System::Calendar::Appointment::AppointmentGet()
            NotifyTime => '2016-08-02 03:59:00',
        },
    );

Returns:

    $Result = 1; # or fail in case of an error

=cut

sub Run {
    my ( $Self, %Param ) = @_;

    # check task params
    my $CheckResult = $Self->_CheckTaskParams(
        %Param,
        NeededDataAttributes => [ 'AppointmentID', 'CalendarID', 'NotifyTime' ],
    );

    # stop execution if an error in params is detected
    return if !$CheckResult;

    # get a local appointment
    my $AppointmentObject = $Kernel::OM->Get('Kernel::System::Calendar::Appointment');

    # trigger the appointment notification
    my $Success = $AppointmentObject->AppointmentNotification( %{ $Param{Data} } );

    if ( !$Success ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Could not trigger appointment notification for AppointmentID $Param{Data}->{AppointmentID}!",
        );
    }

    return $Success;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
