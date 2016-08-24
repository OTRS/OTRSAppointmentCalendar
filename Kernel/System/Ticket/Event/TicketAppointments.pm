# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Ticket::Event::TicketAppointments;

use strict;
use warnings;

use Kernel::System::AsynchronousExecutor;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Calendar',
    'Kernel::System::DynamicField',
    'Kernel::System::Log',
    'Kernel::System::Ticket',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(Data Event Config)) {
        if ( !$Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }
    for (qw(TicketID)) {
        if ( !$Param{Data}->{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_ in Data!"
            );
            return;
        }
    }

    # get calendar object
    my $CalendarObject = $Kernel::OM->Get('Kernel::System::Calendar');

    # get all valid calendars
    my @Calendars = $CalendarObject->CalendarList(
        ValidID => 1,
    );
    return if !@Calendars;

    # get ticket appointment types
    my $TicketAppointmentConfig =
        $Kernel::OM->Get('Kernel::Config')->Get('AppointmentCalendar::TicketAppointmentType') // {};
    return if !$TicketAppointmentConfig;

    my %TicketAppointmentTypes;

    TYPE:
    for my $TypeKey ( sort keys %{$TicketAppointmentConfig} ) {
        next TYPE if !$TicketAppointmentConfig->{$TypeKey}->{Key};
        next TYPE if !$TicketAppointmentConfig->{$TypeKey}->{Event};

        if ( $TypeKey =~ /DynamicField$/ ) {
            my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');

            # get list of all valid date and date/time dynamic fields
            my $DynamicFieldList = $DynamicFieldObject->DynamicFieldListGet(
                ObjectType => 'Ticket',
            );

            DYNAMICFIELD:
            for my $DynamicField ( @{$DynamicFieldList} ) {
                next DYNAMICFIELD if $DynamicField->{FieldType} ne 'Date' && $DynamicField->{FieldType} ne 'DateTime';

                my $Key = sprintf( $TicketAppointmentConfig->{$TypeKey}->{Key}, $DynamicField->{Name} );
                $TicketAppointmentTypes{$Key} = $TicketAppointmentConfig->{$TypeKey};
            }

            next TYPE;
        }

        $TicketAppointmentTypes{ $TicketAppointmentConfig->{$TypeKey}->{Key} } =
            $TicketAppointmentConfig->{$TypeKey};
    }

    # get ticket object
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    # go through all calendars with defined ticket appointments
    CALENDAR:
    for my $Calendar (@Calendars) {
        my %CalendarData = $CalendarObject->CalendarGet(
            CalendarID => $Calendar->{CalendarID},
        );
        next CALENDAR if !$CalendarData{TicketAppointments};

        TICKET_APPOINTMENTS:
        for my $TicketAppointments ( @{ $CalendarData{TicketAppointments} } ) {

            # skip if ticket does not satisfy the search filter
            # pass all configured parameters to ticket search
            # TODO: improve performance by testing ticket data directly
            my @FilteredTicketIDs = $TicketObject->TicketSearch(
                Result   => 'ARRAY',
                QueueIDs => $TicketAppointments->{QueueID},
                UserID   => 1,
                %{ $TicketAppointments->{SearchParam} // {} },
            );
            next TICKET_APPOINTMENTS if !grep { $_ == $Param{Data}->{TicketID} } @FilteredTicketIDs;

            # check appointment types
            for my $Field (qw(StartDate EndDate)) {

                # allow special time presets for EndDate
                if ( $Field ne 'EndDate' && !( $TicketAppointments->{$Field} =~ /^Plus_/ ) ) {

                    # skip if invalid ticket appointment type or
                    # current event is not associated with appointment type
                    if (
                        !(
                            $TicketAppointmentTypes{ $TicketAppointments->{$Field} }
                            && $Param{Event} =~ /$TicketAppointmentTypes{ $TicketAppointments->{$Field} }->{Event}/
                        )
                        )
                    {
                        next TICKET_APPOINTMENTS;
                    }
                }
            }

            # handle ticket appointments in an asynchronous call
            Kernel::System::AsynchronousExecutor->AsyncCall(
                ObjectName     => 'Kernel::System::Calendar',
                FunctionName   => 'TicketAppointments',
                FunctionParams => {
                    CalendarID => $Calendar->{CalendarID},
                    Config     => \%TicketAppointmentTypes,
                    Rule       => $TicketAppointments,
                    Data       => $Param{Data},
                },

                # limit parallel instances to avoid duplicates
                # MaximumParallelInstances => 1,
            );
        }
    }

    return 1;
}

1;
