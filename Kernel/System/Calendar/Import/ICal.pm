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
    'Kernel::System::Calendar::Helper',
    'Kernel::System::DB',
    'Kernel::System::LinkObject',
    'Kernel::System::Log',
    'Kernel::System::Main',
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

    my @Entries              = @{ $Calendar->entries() };
    my $AppointmentsImported = 0;

    ENTRY:
    for my $Entry (@Entries) {
        my $Properties = $Entry->properties();

        my %Parameters;
        my %LinkedObjects;

        # get uid
        if (
            IsArrayRefWithData( $Properties->{'uid'} )
            && ref $Properties->{'uid'}->[0] eq 'Data::ICal::Property'
            && $Properties->{'uid'}->[0]->{'value'}
            )
        {
            $Parameters{UniqueID} = $Properties->{'uid'}->[0]->{'value'};
        }

        # get title
        if (
            IsArrayRefWithData( $Properties->{'summary'} )
            && ref $Properties->{'summary'}->[0] eq 'Data::ICal::Property'
            && $Properties->{'summary'}->[0]->{'value'}
            )
        {
            $Parameters{Title} = $Properties->{'summary'}->[0]->{'value'};
        }

        # get description
        if (
            IsArrayRefWithData( $Properties->{'description'} )
            && ref $Properties->{'description'}->[0] eq 'Data::ICal::Property'
            && $Properties->{'description'}->[0]->{'value'}
            )
        {
            $Parameters{Description} = $Properties->{'description'}->[0]->{'value'};
        }

        # get start time
        if (
            IsArrayRefWithData( $Properties->{'dtstart'} )
            && ref $Properties->{'dtstart'}->[0] eq 'Data::ICal::Property'
            && $Properties->{'dtstart'}->[0]->{'value'}
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
                $Parameters{TimezoneID} = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->TimezoneOffsetGet(
                    TimezoneID => $TimezoneID,
                );
            }
        }

        # get end time
        if (
            IsArrayRefWithData( $Properties->{'dtend'} )
            && ref $Properties->{'dtend'}->[0] eq 'Data::ICal::Property'
            && $Properties->{'dtend'}->[0]->{'value'}
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

        # get location
        if (
            IsArrayRefWithData( $Properties->{'location'} )
            && ref $Properties->{'location'}->[0] eq 'Data::ICal::Property'
            && $Properties->{'location'}->[0]->{'value'}
            )
        {
            $Parameters{Location} = $Properties->{'location'}->[0]->{'value'};
        }

        # get rrule
        if (
            IsArrayRefWithData( $Properties->{'rrule'} )
            && ref $Properties->{'rrule'}->[0] eq 'Data::ICal::Property'
            && $Properties->{'rrule'}->[0]->{'value'}
            )
        {
            my ( $Frequency, $Until, $Interval, $Count, $DayNames, $MonthDays );

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
                elsif ( $Rule =~ /BYDAY=(.*?)$/i ) {
                    $DayNames = $1;
                    next RULE;
                }
                elsif ( $Rule =~ /BYMONTHDAY=(.*?)$/i ) {
                    $MonthDays = $1;
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
                if ($DayNames) {

                    # custom

                    my @Days;

                    # SU,MO,TU,WE,TH,FR,SA
                    for my $DayName ( split( ',', $DayNames ) ) {

                        if ( uc $DayName eq 'MO' ) {
                            push @Days, 1;
                        }
                        elsif ( uc $DayName eq 'TU' ) {
                            push @Days, 2;
                        }
                        elsif ( uc $DayName eq 'WE' ) {
                            push @Days, 3;
                        }
                        elsif ( uc $DayName eq 'TH' ) {
                            push @Days, 4;
                        }
                        elsif ( uc $DayName eq 'FR' ) {
                            push @Days, 5;
                        }
                        elsif ( uc $DayName eq 'SA' ) {
                            push @Days, 6;
                        }
                        elsif ( uc $DayName eq 'SU' ) {
                            push @Days, 7;
                        }
                    }

                    if ( scalar @Days > 0 ) {

                        $Parameters{Recurring}           = 1;
                        $Parameters{RecurrenceByDay}     = 1;           # TODO: check if needed
                        $Parameters{RecurrenceFrequency} = $Interval;
                        $Parameters{RecurrenceDays}      = \@Days;
                    }
                }
                else {
                    # each n days
                    $Parameters{Recurring}           = 1;
                    $Parameters{RecurrenceByDay}     = 1;
                    $Parameters{RecurrenceFrequency} = 7 * $Interval;
                }
            }
            elsif ( $Frequency eq "MONTHLY" ) {
                if ($MonthDays) {

                    # Custom
                    # FREQ=MONTHLY;UNTIL=20170101T080000Z;BYMONTHDAY=16,31'
                    my @Days = split( ',', $MonthDays );
                    $Parameters{Recurring}           = 1;
                    $Parameters{RecurrenceByMonth}   = 1;
                    $Parameters{RecurrenceMonthDays} = \@Days;
                    $Parameters{RecurrenceFrequency} = $Interval;
                }
                else {
                    $Parameters{Recurring}           = 1;
                    $Parameters{RecurrenceByMonth}   = 1;
                    $Parameters{RecurrenceFrequency} = $Interval;
                }
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

        # custom fields (starts with 'x-otrs-')
        my @CustomFields = grep { $_ =~ /x-otrs-/ } keys %{$Properties};

        for my $CustomField (@CustomFields) {
            if (
                IsArrayRefWithData( $Properties->{$CustomField} )
                && ref $Properties->{$CustomField}->[0] eq 'Data::ICal::Property'
                && $Properties->{$CustomField}->[0]->{'value'}
                )
            {
                my @ObjectIDs = split( ",", $Properties->{$CustomField}->[0]->{'value'} );

                # Extract ObjectName
                $CustomField =~ /x-otrs-(.*)$/;
                my $ObjectName = ucfirst $1;    # First letter is uppercase

                $LinkedObjects{$ObjectName} = \@ObjectIDs;
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
            # There is no Appointment, create new one
            my $AppointmentID = $AppointmentObject->AppointmentCreate(
                CalendarID => $Param{CalendarID},
                UserID     => $Param{UserID},
                TimezoneID => 0,
                %Parameters,
            );

            # get Appointment
            %Appointment = $AppointmentObject->AppointmentGet(
                AppointmentID => $AppointmentID,
            );

            $Success = %Appointment ? 1 : 0;
        }

        if ($Success) {
            OBJECT:
            for my $Object ( sort keys %LinkedObjects ) {
                next OBJECT if !IsArrayRefWithData( $LinkedObjects{$Object} );

                for my $ObjectID ( @{ $LinkedObjects{$Object} } ) {

                    # create link
                    my $LinkSuccess = $Kernel::OM->Get('Kernel::System::LinkObject')->LinkAdd(
                        SourceObject => 'Appointment',
                        SourceKey    => $Appointment{AppointmentID},
                        TargetObject => $Object,
                        TargetKey    => $ObjectID,
                        Type         => 'Normal',
                        State        => 'Valid',
                        UserID       => 1,
                    );

                    if ( !$LinkSuccess ) {
                        $Kernel::OM->Get('Kernel::System::Log')->Log(
                            Priority => 'error',
                            Message =>
                                "Unable to create object link (AppointmentID=$Appointment{AppointmentID} - $Object=$ObjectID) during Calendar import!"
                        );
                    }
                }
            }

            $AppointmentsImported++;
        }
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

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not
