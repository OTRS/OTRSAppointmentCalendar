# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Calendar::Import::ICal;

## nofilter(TidyAll::Plugin::OTRS::Migrations::OTRS6::TimeZoneOffset)

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
    'Kernel::System::Main',
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
    my $Success = $ImportObject->Import(
        CalendarID   => 123,
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
    for my $Needed (qw(CalendarID ICal UserID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    # needed objects
    my $AppointmentObject = $Kernel::OM->Get('Kernel::System::Calendar::Appointment');
    my $Calendar = Data::ICal->new( data => $Param{ICal} );

    my @Entries = @{ $Calendar->entries() };

    my $AppointmentsImported = 0;

    ENTRY:
    for my $Entry (@Entries) {
        my $Properties = $Entry->properties();

        my %Parameters;

        # get uid
        if ( $Properties->{'uid'} && ref $Properties->{'uid'} eq "ARRAY" ) {
            if (
                scalar @{ $Properties->{'uid'} } > 0
                &&
                $Properties->{'uid'}->[0]->{'value'}
                )
            {
                $Parameters{UniqueID} = $Properties->{'uid'}->[0]->{'value'};
            }
        }

        # get title
        if ( $Properties->{'summary'} && ref $Properties->{'summary'} eq "ARRAY" ) {
            if (
                scalar @{ $Properties->{'summary'} } > 0
                &&
                $Properties->{'summary'}->[0]->{'value'}
                )
            {
                $Parameters{Title} = $Properties->{'summary'}->[0]->{'value'};
            }
        }

        # get description
        if ( $Properties->{'description'} && ref $Properties->{'description'} eq "ARRAY" ) {
            if (
                scalar @{ $Properties->{'description'} } > 0
                &&
                $Properties->{'description'}->[0]->{'value'}
                )
            {
                $Parameters{Description} = $Properties->{'description'}->[0]->{'value'};
            }
        }

        # get start time
        if ( $Properties->{'dtstart'} && ref $Properties->{'dtstart'} eq "ARRAY" ) {
            if (
                scalar @{ $Properties->{'dtstart'} } > 0
                &&
                $Properties->{'dtstart'}->[0]->{'value'}
                )
            {
                my $TimezoneID;

                if ( ref $Properties->{'dtstart'}->[0]->{'_parameters'} eq 'HASH' ) {

                    # Check if all day event
                    if ( $Properties->{'dtstart'}->[0]->{'_parameters'}->{'VALUE'} ) {
                        $Parameters{AllDay} = 1;
                    }

                    # Check timezone
                    if ( $Properties->{'dtstart'}->[0]->{'_parameters'}->{'TZID'} ) {
                        $TimezoneID = $Properties->{'dtstart'}->[0]->{'_parameters'}->{'TZID'};
                    }
                }

                my $StartTime = $Properties->{'dtstart'}->[0]->{'value'};

                $Parameters{StartTime} = $Self->_FormatTime(
                    Time => $StartTime,
                );

                if ($TimezoneID) {
                    $Parameters{TimezoneID} = $Self->_GetOffset(
                        TimezoneID => $TimezoneID,
                    );
                }
            }
        }

        # get end time
        if ( $Properties->{'dtend'} && ref $Properties->{'dtend'} eq "ARRAY" ) {
            if (
                scalar @{ $Properties->{'dtend'} } > 0
                &&
                $Properties->{'dtend'}->[0]->{'value'}
                )
            {
                my $TimezoneID;

                if ( ref $Properties->{'dtend'}->[0]->{'_parameters'} eq 'HASH' ) {

                    # Check timezone
                    if ( $Properties->{'dtend'}->[0]->{'_parameters'}->{'TZID'} ) {
                        $TimezoneID = $Properties->{'dtend'}->[0]->{'_parameters'}->{'TZID'};
                    }
                }

                my $EndTime = $Properties->{'dtend'}->[0]->{'value'};

                $Parameters{EndTime} = $Self->_FormatTime(
                    Time       => $EndTime,
                    TimezoneID => $TimezoneID,
                );
            }
        }

        # get location
        if ( $Properties->{'location'} && ref $Properties->{'location'} eq "ARRAY" ) {
            if (
                scalar @{ $Properties->{'location'} } > 0
                &&
                $Properties->{'location'}->[0]->{'value'}
                )
            {
                $Parameters{Location} = $Properties->{'location'}->[0]->{'value'};
            }
        }

        # get rrule
        if ( $Properties->{'rrule'} && ref $Properties->{'rrule'} eq "ARRAY" ) {
            if (
                scalar @{ $Properties->{'rrule'} } > 0
                &&
                $Properties->{'rrule'}->[0]->{'value'}
                )
            {
                my ( $Frequency, $Until, $Interval, $Count );

                my @Rules = split ';', $Properties->{'rrule'}->[0]->{'value'};

                RULE:
                for my $Rule (@Rules) {

                    if ( $Rule =~ /FREQ=(.*?)$/i ) {
                        $Frequency = $1;
                        next RULE;
                    }
                    elsif ( $Rule =~ /UNTIL=(.*?)$/i ) {
                        $Until = $1;
                        next RULE;
                    }
                    elsif ( $Rule =~ /INTERVAL=(\d+?)$/i ) {
                        $Interval = $1;
                        next RULE;
                    }
                    elsif ( $Rule =~ /COUNT=(\d+?)$/i ) {
                        $Count = $1;
                        next RULE;
                    }
                }

                $Interval ||= 1;    # default value

                # this appointment is repeating
                if ( $Frequency eq "DAILY" ) {
                    $Parameters{Recurring}           = 1;
                    $Parameters{RecurrenceByDay}     = 1;
                    $Parameters{RecurrenceFrequency} = $Interval;

                }
                elsif ( $Frequency eq "WEEKLY" ) {
                    $Parameters{Recurring}           = 1;
                    $Parameters{RecurrenceByDay}     = 1;
                    $Parameters{RecurrenceFrequency} = 7 * $Interval;
                }
                elsif ( $Frequency eq "MONTHLY" ) {
                    $Parameters{Recurring}           = 1;
                    $Parameters{RecurrenceByMonth}   = 1;
                    $Parameters{RecurrenceFrequency} = $Interval;
                }
                elsif ( $Frequency eq "YEARLY" ) {
                    $Parameters{Recurring}           = 1;
                    $Parameters{RecurrenceByYear}    = 1;
                    $Parameters{RecurrenceFrequency} = $Interval;
                }

                # FREQ=MONTHLY;UNTIL=20170302T121500Z'
                # FREQ=MONTHLY;UNTIL=20170202T090000Z;INTERVAL=2;BYMONTHDAY=31',
                # FREQ=WEEKLY;INTERVAL=2;BYDAY=TU
                # FREQ=YEARLY;UNTIL=20200602T080000Z;INTERVAL=2;BYMONTHDAY=1;BYMONTH=4';

                # FREQ=DAILY;COUNT=3

                if ($Until) {
                    $Parameters{RecurrenceUntil} = $Self->_FormatTime(
                        Time => $Until,
                    );
                }
                elsif ($Count) {
                    $Parameters{RecurrenceCount} = $Count;
                }
                else {

                    # TODO: update this
                    # default value
                    $Parameters{RecurrenceUntil} = "2017-01-01 00:00:00";
                }
            }
        }

        next ENTRY if !$Parameters{Title};

        my $Success;

        # check if appointment exists already (same UniqueID)
        my %Appointment = $AppointmentObject->AppointmentGet(
            UniqueID => $Parameters{UniqueID},
        );

        if ( %Appointment && $Appointment{AppointmentID} ) {

            # Appointment exists, update it
            $Success = $AppointmentObject->AppointmentUpdate(
                CalendarID    => $Param{CalendarID},
                AppointmentID => $Appointment{AppointmentID},
                UserID        => $Param{UserID},
                TimezoneID    => 0,
                %Parameters,
            );
        }
        else {
            # There is no Appointment,create new one
            $Success = $AppointmentObject->AppointmentCreate(
                CalendarID => $Param{CalendarID},
                UserID     => $Param{UserID},
                TimezoneID => 0,
                %Parameters,
            );
        }

        $AppointmentsImported++ if $Success;
    }

    return $AppointmentsImported > 0 ? 1 : 0;
}

sub _FormatTime {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(Time)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    my $TimeStamp;

    if ( $Param{Time} =~ /(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})(\d{2})/i ) {

        # format string
        $TimeStamp = "$1-$2-$3 $4:$5:$6";
    }
    elsif ( $Param{Time} =~ /(\d{4})(\d{2})(\d{2})/ ) {

        # only date is given (without time)
        $TimeStamp = "$1-$2-$3 00:00:00";
    }

    return $TimeStamp;
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

    my $MainObject = $Kernel::OM->Get('Kernel::System::Main');
    my $TimeObject = $Kernel::OM->Get('Kernel::System::Time');

    # check if DateTime object exists
    return if !$MainObject->Require(
        'DateTime',
    );

    # check if DateTime::TimeZone object exists
    return if !$MainObject->Require(
        'DateTime::TimeZone',
    );

    my $DateTime = DateTime->now();

    my $Timezone = DateTime::TimeZone->new( name => $Param{TimezoneID} );
    my $Offset = $Timezone->offset_for_datetime($DateTime) / 3600.00;    # in hours

    return $Offset;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not
