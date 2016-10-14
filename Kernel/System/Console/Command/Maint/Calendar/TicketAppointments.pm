# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Console::Command::Maint::Calendar::TicketAppointments;

use strict;
use warnings;

use base qw(Kernel::System::Console::BaseCommand);

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Calendar',
    'Kernel::System::Ticket',
);

sub Configure {
    my ( $Self, %Param ) = @_;

    $Self->Description('Process ticket appointments for a single calendar.');

    $Self->AddArgument(
        Name        => 'calendar-id',
        Description => 'Calendar to process ticket appointment rules of.',
        Required    => 1,
        ValueRegex  => qr/\d+/smx,
    );

    return;
}

sub Run {
    my ( $Self, %Param ) = @_;

    $Self->Print("<yellow>Processing ticket appointments...</yellow>\n");

    my $CalendarID = $Self->GetArgument('calendar-id');

    my %Result = $Kernel::OM->Get('Kernel::System::Calendar')->TicketAppointmentProcessCalendar(
        CalendarID => $CalendarID,
    );

    if (%Result) {
        for my $Process ( @{ $Result{Process} // [] } ) {
            $Self->Print(
                " Process ticket $Process->{TicketID} based on rule '$Process->{RuleID}'..."
            );
            if ( $Process->{Success} ) {
                $Self->Print(" done.\n");
            }
            else {
                $Self->Print(" failed.\n");
            }
        }

        for my $Cleanup ( @{ $Result{Cleanup} // [] } ) {
            $Self->Print(
                " Cleanup for rule '$Cleanup->{RuleID}'..."
            );
            if ( $Cleanup->{Success} ) {
                $Self->Print(" done.\n");
            }
            else {
                $Self->Print(" failed.\n");
            }

        }

        $Self->Print("<green>Done.</green>\n");
        return $Self->ExitCodeOk();
    }

    $Self->PrintError("Error processing calendar ID: $CalendarID");
    return $Self->ExitCodeError();
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
