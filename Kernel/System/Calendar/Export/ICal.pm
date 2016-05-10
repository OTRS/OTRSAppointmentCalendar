# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Calendar::Export::ICal;

use strict;
use warnings;

use Data::ICal;
use Data::ICal::Entry::Event;
use Date::ICal;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Cache',
    'Kernel::System::Calendar',
    'Kernel::System::Calendar::Appointment',
    'Kernel::System::Calendar::Helper',
    'Kernel::System::DB',
    'Kernel::System::Log',
);

=head1 NAME

Kernel::System::Calendar::Export::ICal - iCalendar export lib

=head1 SYNOPSIS

Export functions for iCalendar format.

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object. Do not use it directly, instead use:

    use Kernel::System::ObjectManager;
    local $Kernel::OM = Kernel::System::ObjectManager->new();
    my $ExportObject = $Kernel::OM->Get('Kernel::System::Calendar::Export::ICal');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

=item Export()

export calendar to iCalendar format

    my $ICalString = $ExportObject->Export(
        CalendarID   => 1,    # (required) Valid CalendarID
        UserID       => 1,    # (required) UserID
    );

returns iCalendar string if successful

=cut

sub Export {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(CalendarID UserID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    # needed objects
    my $CalendarObject    = $Kernel::OM->Get('Kernel::System::Calendar');
    my $AppointmentObject = $Kernel::OM->Get('Kernel::System::Calendar::Appointment');

    my %Calendar = $CalendarObject->CalendarGet(
        CalendarID => $Param{CalendarID},
        UserID     => $Param{UserID},
    );
    return if !$Calendar{CalendarID};

    my @AppointmentIDs = $AppointmentObject->AppointmentList(
        CalendarID => $Calendar{CalendarID},
        Result     => 'ARRAY',
    );

    my $ICalCalendar = Data::ICal->new(
        calname => $Calendar{CalendarName},
    );

    APPOINTMENT_ID:
    for my $AppointmentID (@AppointmentIDs) {
        my %Appointment = $AppointmentObject->AppointmentGet(
            AppointmentID => $AppointmentID,
        );
        return if !$Appointment{AppointmentID};
        next APPOINTMENT_ID if $Appointment{ParentID};

        # get offset
        my $Offset = $Self->_GetOffset(
            TimezoneID => $Appointment{TimezoneID},
        );

        # calculate start time
        my $StartTime = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->SystemTimeGet(
            String => $Appointment{StartTime},
        );
        my $ICalStartTime = Date::ICal->new(
            epoch => $StartTime,
        );
        $ICalStartTime->offset($Offset);

        # calculate end time
        my $EndTime = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->SystemTimeGet(
            String => $Appointment{EndTime},
        );
        my $ICalEndTime = Date::ICal->new(
            epoch => $EndTime,
        );
        $ICalEndTime->offset($Offset);

        # recalculate for all day appointment
        if ( $Appointment{AllDay} ) {
            my ( $Sec, $Min, $Hour, $Day, $Month, $Year )
                = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->DateGet(
                SystemTime => $StartTime,
                );
            $ICalStartTime = Date::ICal->new(
                year  => $Year,
                month => $Month,
                day   => $Day,
            );
            ( $Sec, $Min, $Hour, $Day, $Month, $Year ) = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->DateGet(
                SystemTime => $EndTime,
            );
            $ICalEndTime = Date::ICal->new(
                year  => $Year,
                month => $Month,
                day   => $Day,
            );
        }

        # create iCalendar event entry
        my $ICalEvent = Data::ICal::Entry::Event->new();

        # optional properties
        my %ICalEventProperties;
        if ( $Appointment{Description} ) {
            $ICalEventProperties{description} = $Appointment{Description};
        }
        if ( $Appointment{Location} ) {
            $ICalEventProperties{location} = $Appointment{Location};
        }
        if ( $Appointment{Recurring} ) {
            $ICalEventProperties{rrule} = 'FREQ=';
            if ( $Appointment{RecurrenceFrequency} == 1 ) {
                $ICalEventProperties{rrule} .= 'DAILY';
            }
            elsif ( $Appointment{RecurrenceFrequency} == 7 ) {
                $ICalEventProperties{rrule} .= 'WEEKLY';
            }
            elsif ( $Appointment{RecurrenceFrequency} == 30 ) {
                $ICalEventProperties{rrule} .= 'MONTHLY';
            }
            elsif ( $Appointment{RecurrenceFrequency} == 365 ) {
                $ICalEventProperties{rrule} .= 'YEARLY';
            }
            else {
                $ICalEventProperties{rrule} .= 'DAILY;INTERVAL=' . $Appointment{RecurrenceFrequency};
            }
            if ( $Appointment{RecurrenceUntil} ) {
                my $RecurrenceUntil = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->SystemTimeGet(
                    String => $Appointment{RecurrenceUntil},
                );
                my $ICalRecurrenceUntil = Date::ICal->new(
                    epoch => $RecurrenceUntil - 1,    # make it exclusive
                );
                $ICalRecurrenceUntil->offset($Offset);
                $ICalEventProperties{rrule} .= ';UNTIL=' . $ICalRecurrenceUntil->ical();
            }
            elsif ( $Appointment{RecurrenceCount} ) {
                $ICalEventProperties{rrule} .= ';COUNT=' . $Appointment{RecurrenceCount};
            }
        }

        # calculate last modified time
        my $ChangeTime = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->SystemTimeGet(
            String => $Appointment{ChangeTime},
        );
        my $ICalChangeTime = Date::ICal->new(
            epoch => $ChangeTime,
        );

        # add both required and optional properties
        # remove time zone flag for all day appointments
        $ICalEvent->add_properties(
            summary         => $Appointment{Title},
            dtstart         => $Appointment{AllDay} ? substr( $ICalStartTime->ical(), 0, -1 ) : $ICalStartTime->ical(),
            dtend           => $Appointment{AllDay} ? substr( $ICalEndTime->ical(), 0, -1 ) : $ICalEndTime->ical(),
            uid             => $Appointment{UniqueID},
            'last-modified' => $ICalChangeTime->ical(),
            %ICalEventProperties,
        );

        $ICalCalendar->add_entry($ICalEvent);
    }

    return $ICalCalendar->as_string();
}

sub _GetOffset {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(TimezoneID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    my $Result;

    # make sure it's an integer
    $Param{TimezoneID} = int $Param{TimezoneID};

    # get sign
    if ( $Param{TimezoneID} > 0 ) {
        $Result = '+';
    }
    else {
        $Result = '-';
    }

    # pad the string
    $Result .= sprintf( '%02d00', abs $Param{TimezoneID} );

    return $Result;
}

no warnings 'redefine';

sub Data::ICal::product_id {    ## no critic
    return 'OTRS ' . $Kernel::OM->Get('Kernel::Config')->Get('Version');
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not
