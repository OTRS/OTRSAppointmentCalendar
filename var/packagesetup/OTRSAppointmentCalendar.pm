# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package var::packagesetup::OTRSAppointmentCalendar;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::System::Log',
    'Kernel::System::Calendar::Appointment',
);

=head1 NAME

OTRSBusiness.pm - code to execute during package installation

=head1 SYNOPSIS

All functions

=head1 PUBLIC INTERFACE

=over 4

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

=item CodeInstall()

run the code install part

    my $Result = $CodeObject->CodeInstall();

=cut

sub CodeInstall {
    my ( $Self, %Param ) = @_;

    $Self->_AppointmentFutureTasksUpdate();

    return 1;
}

=item CodeReinstall()

run the code re-install part

    my $Result = $CodeObject->CodeReinstall();

=cut

sub CodeReinstall {
    my ( $Self, %Param ) = @_;

    $Self->_AppointmentFutureTasksUpdate();

    return 1;
}

=item CodeUpgrade()

run the code upgrade part

    my $Result = $CodeObject->CodeUpgrade();

=cut

sub CodeUpgrade {
    my ( $Self, %Param ) = @_;

    $Self->_AppointmentFutureTasksUpdate();

    return 1;
}

=item CodeUninstall()

run the code uninstall part

    my $Result = $CodeObject->CodeUninstall();

=cut

sub CodeUninstall {
    my ( $Self, %Param ) = @_;

    $Self->_AppointmentFutureTasksDelete();

    return 1;
}

#
# Update possible changes on the calendar appointment future tasks.
#
sub _AppointmentFutureTasksUpdate {
    my ( $Self, %Param ) = @_;

    # get a local appointment object
    my $AppointmentObject = $Kernel::OM->Get('Kernel::System::Calendar::Appointment');

    # update the future tasks
    my $Success = $AppointmentObject->AppointmentFutureTasksUpdate();

    if ( !$Success ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Could not update appointment future tasks!',
        );
        return;
    }

    return 1;
}

#
# Delete all calendar appointment future tasks.
#
sub _AppointmentFutureTasksDelete {
    my ( $Self, %Param ) = @_;

    # get a local appointment object
    my $AppointmentObject = $Kernel::OM->Get('Kernel::System::Calendar::Appointment');

    my $Success = $AppointmentObject->AppointmentFutureTasksDelete();

    if ( !$Success ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Could not delete appointment future tasks!',
        );
        return;
    }

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
