# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Calendar::Import::ICal;

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
    'Kernel::System::DB',
    'Kernel::System::Log',
    'Kernel::System::Time',
);

=head1 NAME

Kernel::System::Calendar::Import::ICal - iCalendar import lib

=head1 SYNOPSIS

Import functions for iCalendar format.

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object. Do not use it directly, instead use:

    use Kernel::System::ObjectManager;
    local $Kernel::OM = Kernel::System::ObjectManager->new();
    my $ImportObject = $Kernel::OM->Get('Kernel::System::Calendar::Export::ICal');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

=item Import()

import calendar in iCalendar format
    my $Success = $ExportObject->Import(
        ICal         =>                         # (required) iCal string
            '
                BEGIN:VCALENDAR
                PRODID:Zimbra-Calendar-Provider
                VERSION:2.0
                METHOD:REQUEST
                ...
            ',
        UserID       => 1,                      # (required) UserID
    );
returns 1 if successful

=cut

sub Import {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(ICal UserID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    my $Calendar = Date::ICal->new( data => $Param{ICal} );

    # use Data::Dumper;
    # my $Data2 = Dumper( \$Calendar );
    # open(my $fh, '>>', '/opt/otrs-test/data.txt') or die 'Could not open file ';
    # print $fh "\n==========================\n" . $Data2;
    # close $fh;

    # # time zone offset
    # $Param{UserTimeZone} = $Param{UserTimeZone} ? int $Param{UserTimeZone} : 0;

    # # needed objects
    # my $CalendarObject    = $Kernel::OM->Get('Kernel::System::Calendar');
    # my $AppointmentObject = $Kernel::OM->Get('Kernel::System::Calendar::Appointment');

    # my %Calendar = $CalendarObject->CalendarGet(
    #     CalendarID => $Param{CalendarID},
    # );
    # return if !$Calendar{CalendarID};

    # my @AppointmentIDs = $AppointmentObject->AppointmentList(
    #     CalendarID => $Calendar{CalendarID},
    #     Result     => 'ARRAY',
    # );

    # my $ICalCalendar = Data::ICal->new(
    #     calname => $Calendar{CalendarName},
    # );

    # APPOINTMENT_ID:
    # for my $AppointmentID (@AppointmentIDs) {
    #     my %Appointment = $AppointmentObject->AppointmentGet(
    #         AppointmentID => $AppointmentID,
    #     );
    #     return if !$Appointment{ID};
    #     next APPOINTMENT_ID if $Appointment{ParentID};

    #     # get time object
    #     my $TimeObject = $Kernel::OM->Get('Kernel::System::Time');

    #     # check end time
    #     my $EndTime = $TimeObject->TimeStamp2SystemTime(
    #         String => $Appointment{EndTime},
    #     );
    #     my $ICalEndTime = Date::ICal->new(
    #         epoch => $EndTime - ( $Param{UserTimeZone} * 3600 ),
    #     );

    #     # calculate start time
    #     my $StartTime = $TimeObject->TimeStamp2SystemTime(
    #         String => $Appointment{StartTime},
    #     );
    #     my $ICalStartTime = Date::ICal->new(
    #         epoch => $StartTime - ( $Param{UserTimeZone} * 3600 ),
    #     );

    #     # recalculate for all day appointment
    #     if ( $Appointment{AllDay} ) {
    #         my ( $Sec, $Min, $Hour, $Day, $Month, $Year ) = $TimeObject->SystemTime2Date(
    #             SystemTime => $StartTime,
    #         );
    #         $ICalStartTime = Date::ICal->new(
    #             year  => $Year,
    #             month => $Month,
    #             day   => $Day,
    #         );
    #         ( $Sec, $Min, $Hour, $Day, $Month, $Year ) = $TimeObject->SystemTime2Date(
    #             SystemTime => $EndTime,
    #         );
    #         $ICalEndTime = Date::ICal->new(
    #             year  => $Year,
    #             month => $Month,
    #             day   => $Day,
    #         );
    #     }

    #     # create iCalendar event entry
    #     my $ICalEvent = Data::ICal::Entry::Event->new();

    #     # optional properties
    #     my %ICalEventProperties;
    #     if ( $Appointment{Description} ) {
    #         $ICalEventProperties{description} = $Appointment{Description};
    #     }
    #     if ( $Appointment{Location} ) {
    #         $ICalEventProperties{location} = $Appointment{Location};
    #     }
    #     if ( $Appointment{Recurring} ) {
    #         $ICalEventProperties{rrule} = 'FREQ=';
    #         if ( $Appointment{RecurrenceFrequency} == 1 ) {
    #             $ICalEventProperties{rrule} .= 'DAILY';
    #         }
    #         elsif ( $Appointment{RecurrenceFrequency} == 7 ) {
    #             $ICalEventProperties{rrule} .= 'WEEKLY';
    #         }
    #         elsif ( $Appointment{RecurrenceFrequency} == 30 ) {
    #             $ICalEventProperties{rrule} .= 'MONTHLY';
    #         }
    #         elsif ( $Appointment{RecurrenceFrequency} == 365 ) {
    #             $ICalEventProperties{rrule} .= 'YEARLY';
    #         }
    #         else {
    #             $ICalEventProperties{rrule} .= 'DAILY;INTERVAL=' . $Appointment{RecurrenceFrequency};
    #         }
    #         if ( $Appointment{RecurrenceUntil} ) {
    #             my $RecurrenceUntil = $TimeObject->TimeStamp2SystemTime(
    #                 String => $Appointment{RecurrenceUntil},
    #             );
    #             my $ICalRecurrenceUntil = Date::ICal->new(
    #                 epoch => $RecurrenceUntil - ( $Param{UserTimeZone} * 3600 ) - 1,    # make it exclusive
    #             );
    #             $ICalEventProperties{rrule} .= ';UNTIL=' . $ICalRecurrenceUntil->ical();
    #         }
    #         elsif ( $Appointment{RecurrenceCount} ) {
    #             $ICalEventProperties{rrule} .= ';COUNT=' . $Appointment{RecurrenceCount};
    #         }
    #     }

    #     # calculate last modified time
    #     my $ChangeTime = $TimeObject->TimeStamp2SystemTime(
    #         String => $Appointment{ChangeTime},
    #     );
    #     my $ICalChangeTime = Date::ICal->new(
    #         epoch => $StartTime - ( $Param{UserTimeZone} * 3600 ),
    #     );

   #     # add both required and optional properties
   #     # remove time zone flag for all day appointments
   #     $ICalEvent->add_properties(
   #         summary         => $Appointment{Title},
   #         dtstart         => $Appointment{AllDay} ? substr( $ICalStartTime->ical(), 0, -1 ) : $ICalStartTime->ical(),
   #         dtend           => $Appointment{AllDay} ? substr( $ICalEndTime->ical(), 0, -1 ) : $ICalEndTime->ical(),
   #         uid             => $Appointment{UniqueID},
   #         'last-modified' => $ICalChangeTime->ical(),
   #         %ICalEventProperties,
   #     );

    #     $ICalCalendar->add_entry($ICalEvent);
    # }

    # return $ICalCalendar->as_string();

    return 1;
}

# no warnings 'redefine';

# sub Data::ICal::product_id {    ## no critic
#     return 'OTRS ' . $Kernel::OM->Get('Kernel::Config')->Get('Version');
# }

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not
