# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Calendar::Plugin::TicketNumber;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::System::Log',
    'Kernel::System::Main',
    'Kernel::System::LinkObject',
    'Kernel::System::Ticket',
);

=head1 NAME

Kernel::System::Calendar::Plugin::TicketNumber - TicketNumber plugin

=head1 SYNOPSIS

Ticket Number appointment plugin.

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object. Do not use it directly, instead use:

    use Kernel::System::ObjectManager;
    local $Kernel::OM = Kernel::System::ObjectManager->new();
    my $TicketNumberObject = $Kernel::OM->Get('Kernel::System::Calendar::Plugin::TicketNumber');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

=item LinkAdd()

adds a link from an appointment to the ticket

    my $Success = $TicketNumberObject->LinkAdd(
        AppointmentID => 123,
        PluginData    => $TicketID,
        UserID        => 1,
    );

=cut

sub LinkAdd {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(AppointmentID PluginData UserID)) {
        if ( !$Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    # get ticket id
    my $TicketID = $Kernel::OM->Get('Kernel::System::Ticket')->TicketCheckNumber(
        Tn => $Param{PluginData},
    );
    return if !$TicketID;

    my $Success = $Kernel::OM->Get('Kernel::System::LinkObject')->LinkAdd(
        SourceObject => 'Appointment',
        SourceKey    => $Param{AppointmentID},
        TargetObject => 'Ticket',
        TargetKey    => $TicketID,
        Type         => 'Normal',
        State        => 'Valid',
        UserID       => $Param{UserID},
    );

    return $Success;
}

=item LinkList()

returns a hash of linked tickets to an appointment

    my $Success = $TicketNumberObject->LinkList(
        AppointmentID => 123,
        UserID        => 1,
    );

=cut

sub LinkList {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(AppointmentID UserID)) {
        if ( !$Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    my %LinkKeyList = $Kernel::OM->Get('Kernel::System::LinkObject')->LinkKeyListWithData(
        Object1 => 'Appointment',
        Key1    => $Param{AppointmentID},
        Object2 => 'Ticket',
        State   => 'Valid',
        UserID  => $Param{UserID},
    );

    my %Result = map { $_ => $LinkKeyList{$_}->{TicketNumber} } keys %LinkKeyList;

    return \%Result;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
