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

    # get needed objects
    my $TicketObject   = $Kernel::OM->Get('Kernel::System::Ticket');
    my $CalendarObject = $Kernel::OM->Get('Kernel::System::Calendar');

    # get calendar configuration
    my $CalendarID = $Self->GetArgument('calendar-id');
    my %Calendar   = $CalendarObject->CalendarGet(
        CalendarID => $CalendarID,
    );
    if ( !%Calendar ) {
        $Self->PrintError("Could not find calendar $CalendarID.");
        return $Self->ExitCodeError();
    }

    # get ticket appointment types
    my %TicketAppointmentTypes = $CalendarObject->_TicketAppointmentTypesGet();

    # check ticket appointment config
    if ( $Calendar{TicketAppointments} && IsArrayRefWithData( $Calendar{TicketAppointments} ) ) {

        # get active rule ids from the calendar
        my %RuleIDLookup = map { $_->{RuleID} => 1 } @{ $Calendar{TicketAppointments} };

        TICKET_APPOINTMENTS:
        for my $TicketAppointments ( @{ $Calendar{TicketAppointments} } ) {

            # check appointment types
            for my $Field (qw(StartDate EndDate)) {

                # allow special time presets for EndDate
                if ( $Field ne 'EndDate' && !( $TicketAppointments->{$Field} =~ /^Plus_/ ) ) {

                    # skip if ticket appointment type is invalid
                    if ( !$TicketAppointmentTypes{ $TicketAppointments->{$Field} } ) {
                        next TICKET_APPOINTMENTS;
                    }
                }
            }

            # find tickets that match search filter
            my @TicketIDs = $TicketObject->TicketSearch(
                Result   => 'ARRAY',
                QueueIDs => $TicketAppointments->{QueueID},
                UserID   => 1,
                %{ $TicketAppointments->{SearchParam} // {} },
            );

            # process each ticket based on ticket appointment rule
            TICKETID:
            for my $TicketID (@TicketIDs) {
                $Self->Print(
                    " Process ticket $TicketID based on rule '$TicketAppointments->{RuleID}'..."
                );

                my $Success = $CalendarObject->TicketAppointmentProcess(
                    CalendarID => $CalendarID,
                    Config     => \%TicketAppointmentTypes,
                    Rule       => $TicketAppointments,
                    TicketID   => $TicketID,
                );

                # error handling
                if ($Success) {
                    $Self->Print(" done.\n");
                }
                else {
                    $Self->Print(" failed.\n");
                }

                # get used rule ids
                my @RuleIDs = $CalendarObject->_TicketAppointmentRuleIDsGet(
                    CalendarID => $CalendarID,
                    TicketID   => $TicketID,
                );

                # remove ticket appointments for missing rules
                for my $RuleID (@RuleIDs) {
                    if ( !$RuleIDLookup{$RuleID} ) {
                        $Self->Print(
                            " Cleanup for ticket $TicketID and rule '$TicketAppointments->{RuleID}'..."
                        );
                        my $Success = $CalendarObject->_TicketAppointmentDelete(
                            CalendarID => $CalendarID,
                            TicketID   => $TicketID,
                            RuleID     => $RuleID,
                        );

                        # error handling
                        if ($Success) {
                            $Self->Print(" done.\n");
                        }
                        else {
                            $Self->Print(" failed.\n");
                        }
                    }
                }
            }
        }
    }

    # cleanup outdated rules

    # my @ActiveRuleIDs = map
    $Self->Print("<green>Done.</green>\n");
    return $Self->ExitCodeOk();
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
