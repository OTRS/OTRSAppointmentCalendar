# --
# Copyright (C) 2001-2019 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Kernel::System::Ticket::Event::TicketAppointmentDelete;

use strict;
use warnings;

use base qw(Kernel::System::AsynchronousExecutor);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Log',
    'Kernel::System::Ticket',
);

sub new {
    my ( $Type, %Param ) = @_;

    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(TicketID)) {
        if ( !$Param{Data}->{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed in Data!",
            );
            return;
        }
    }

    # Handle ticket appointment delete in an asynchronous call.
    return $Self->AsyncCall(
        ObjectName     => 'Kernel::System::Calendar',
        FunctionName   => 'TicketAppointmentDelete',
        FunctionParams => {
            TicketID => $Param{Data}->{TicketID},
        },
    );
}

1;
