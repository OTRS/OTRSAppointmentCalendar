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
    'Kernel::System::Calendar::Plugin',
    'Kernel::System::Calendar::Team',
    'Kernel::System::DB',
    'Kernel::System::Log',
    'Kernel::System::Main',
    'Kernel::System::User',
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
    my $PluginObject      = $Kernel::OM->Get('Kernel::System::Calendar::Plugin');

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

    # export color for apple calendar
    $ICalCalendar->add_property(
        'x-apple-calendar-color' => $Calendar{Color},
    );

    APPOINTMENT_ID:
    for my $AppointmentID (@AppointmentIDs) {
        my %Appointment = $AppointmentObject->AppointmentGet(
            AppointmentID => $AppointmentID,
        );
        return if !$Appointment{AppointmentID};

        # calculate start time
        my $StartTime = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->SystemTimeGet(
            String => $Appointment{StartTime},
        );
        my $ICalStartTime = Date::ICal->new(
            epoch => $StartTime,
        );

        # calculate end time
        my $EndTime = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->SystemTimeGet(
            String => $Appointment{EndTime},
        );
        my $ICalEndTime = Date::ICal->new(
            epoch => $EndTime,
        );

        # recalculate for all day appointment, discard time data
        if ( $Appointment{AllDay} ) {
            my ( $Sec, $Min, $Hour, $Day, $Month, $Year )
                = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->DateGet(
                SystemTime => $StartTime,
                );
            $ICalStartTime = Date::ICal->new(
                year   => $Year,
                month  => $Month,
                day    => $Day,
                offset => '+0000',    # UTC
            );
            ( $Sec, $Min, $Hour, $Day, $Month, $Year ) = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->DateGet(
                SystemTime => $EndTime,
            );
            $ICalEndTime = Date::ICal->new(
                year   => $Year,
                month  => $Month,
                day    => $Day,
                offset => '+0000',    # UTC
            );
        }

        # create iCalendar event entry
        my $ICalEvent = Data::ICal::Entry::Event->new();

        # optional properties
        my %ICalEventProperties;

        # repeatable properties
        my @ICalRepeatableProperties;

        if ( $Appointment{Description} ) {
            $ICalEventProperties{description} = $Appointment{Description};
        }
        if ( $Appointment{Location} ) {
            $ICalEventProperties{location} = $Appointment{Location};
        }
        if ( $Appointment{Recurring} ) {
            $ICalEventProperties{rrule} = '';

            if ( $Appointment{RecurrenceType} eq 'Daily' ) {
                $ICalEventProperties{rrule} .= 'FREQ=DAILY';
            }
            elsif ( $Appointment{RecurrenceType} eq 'Weekly' ) {
                $ICalEventProperties{rrule} .= 'FREQ=WEEKLY';
            }
            elsif ( $Appointment{RecurrenceType} eq 'Monthly' ) {
                $ICalEventProperties{rrule} .= 'FREQ=MONTHLY';
            }
            elsif ( $Appointment{RecurrenceType} eq 'Yearly' ) {
                $ICalEventProperties{rrule} .= 'FREQ=YEARLY';
            }
            elsif ( $Appointment{RecurrenceType} eq 'CustomDaily' ) {
                $ICalEventProperties{rrule} .= "FREQ=DAILY;INTERVAL=$Appointment{RecurrenceInterval}";
            }
            elsif ( $Appointment{RecurrenceType} eq 'CustomWeekly' ) {
                $ICalEventProperties{rrule} .= "FREQ=WEEKLY;INTERVAL=$Appointment{RecurrenceInterval}";

                if ( IsArrayRefWithData( $Appointment{RecurrenceFrequency} ) ) {
                    my @DayNames;

                    for my $Day ( @{ $Appointment{RecurrenceFrequency} } ) {
                        if ( $Day == 1 ) {
                            push @DayNames, 'MO';
                        }
                        elsif ( $Day == 2 ) {
                            push @DayNames, 'TU';
                        }
                        elsif ( $Day == 3 ) {
                            push @DayNames, 'WE';
                        }
                        elsif ( $Day == 4 ) {
                            push @DayNames, 'TH';
                        }
                        elsif ( $Day == 5 ) {
                            push @DayNames, 'FR';
                        }
                        elsif ( $Day == 6 ) {
                            push @DayNames, 'SA';
                        }
                        elsif ( $Day == 7 ) {
                            push @DayNames, 'SU';
                        }
                    }

                    $ICalEventProperties{rrule} .= ";BYDAY=" . join( ",", @DayNames );
                }
            }
            elsif ( $Appointment{RecurrenceType} eq 'CustomMonthly' ) {
                $ICalEventProperties{rrule} .= "FREQ=MONTHLY;INTERVAL=$Appointment{RecurrenceInterval}";
                $ICalEventProperties{rrule} .= ";BYMONTHDAY=" . join( ",", @{ $Appointment{RecurrenceFrequency} } );

            }
            elsif ( $Appointment{RecurrenceType} eq 'CustomYearly' ) {
                my ( $Sec, $Min, $Hour, $Day, $Month, $Year )
                    = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->DateGet(
                    SystemTime => $StartTime,
                    );

                $ICalEventProperties{rrule} .= "FREQ=YEARLY;INTERVAL=$Appointment{RecurrenceInterval};BYMONTHDAY=$Day";
                $ICalEventProperties{rrule} .= ";BYMONTH=" . join( ",", @{ $Appointment{RecurrenceFrequency} } );

                # RRULE:FREQ=YEARLY;UNTIL=20200602T080000Z;INTERVAL=2;BYMONTHDAY=1;BYMONTH=4
            }

            if ( $Appointment{RecurrenceUntil} ) {
                my $RecurrenceUntil = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->SystemTimeGet(
                    String => $Appointment{RecurrenceUntil},
                );
                my $ICalRecurrenceUntil = Date::ICal->new(
                    epoch => $RecurrenceUntil,
                );
                $ICalEventProperties{rrule} .= ';UNTIL=' . substr( $ICalRecurrenceUntil->ical(), 0, -1 );
            }
            elsif ( $Appointment{RecurrenceCount} ) {
                $ICalEventProperties{rrule} .= ';COUNT=' . $Appointment{RecurrenceCount};
            }
            if ( $Appointment{RecurrenceExclude} ) {
                RECURRENCE_EXCLUDE:
                for my $RecurrenceExclude ( @{ $Appointment{RecurrenceExclude} } ) {
                    next RECURRENCE_EXCLUDE if !$RecurrenceExclude;
                    my $RecurrenceID = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->SystemTimeGet(
                        String => $RecurrenceExclude,
                    );
                    my $ICalRecurrenceID = Date::ICal->new(
                        epoch => $RecurrenceID,
                    );

                    push @ICalRepeatableProperties, {
                        Property => 'exdate',
                        Value    => $Appointment{AllDay}
                        ? substr( $ICalRecurrenceID->ical(), 0, -1 )
                        : $ICalRecurrenceID->ical(),
                    };
                }
            }
        }

        # occurrence appointment
        if ( $Appointment{ParentID} ) {

            # overriden occurences only
            if (
                $Appointment{RecurrenceID}
                && grep { ( $_ // '' ) eq $Appointment{RecurrenceID} } @{ $Appointment{RecurrenceExclude} }
                )
            {

                # calculate recurrence id
                my $RecurrenceID = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->SystemTimeGet(
                    String => $Appointment{RecurrenceID},
                );
                my $ICalRecurrenceID = Date::ICal->new(
                    epoch => $RecurrenceID,
                );

                $ICalEventProperties{'recurrence-id'}
                    = $Appointment{AllDay} ? substr( $ICalRecurrenceID->ical(), 0, -1 ) : $ICalRecurrenceID->ical();
            }

            # skip if not overriden
            else {
                next APPOINTMENT_ID;
            }
        }

        # calculate last modified time
        my $ChangeTime = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->SystemTimeGet(
            String => $Appointment{ChangeTime},
        );
        my $ICalChangeTime = Date::ICal->new(
            epoch => $ChangeTime,
        );

        # check if team object is registered
        if ( $Kernel::OM->Get('Kernel::System::Main')->Require( 'Kernel::System::Calendar::Team', Silent => 1 ) ) {

            # include team names
            if ( $Appointment{TeamID} ) {
                my @Teams;

                # get team object
                my $TeamObject = $Kernel::OM->Get('Kernel::System::Calendar::Team');

                # get team names
                for my $TeamID ( @{ $Appointment{TeamID} } ) {
                    if ($TeamID) {
                        my %Team = $TeamObject->TeamGet(
                            TeamID => $TeamID,
                            UserID => $Param{UserID},
                        );
                        if ( $Team{Name} ) {
                            push @Teams, $Team{Name};
                        }
                    }
                }
                if (@Teams) {
                    $ICalEvent->add_properties(
                        "x-otrs-team" => join( ',', @Teams ),
                    );
                }
            }

            # include resource names
            if ( $Appointment{ResourceID} ) {
                my @Users;

                # get user object
                my $UserObject = $Kernel::OM->Get('Kernel::System::User');

                # get user data
                for my $UserID ( @{ $Appointment{ResourceID} } ) {
                    if ($UserID) {
                        my %User = $UserObject->GetUserData(
                            UserID => $UserID,
                        );
                        if ( $User{UserLogin} ) {
                            push @Users, $User{UserLogin};
                        }
                    }
                }
                if (@Users) {
                    $ICalEvent->add_properties(
                        "x-otrs-resource" => join( ',', @Users ),
                    );
                }
            }
        }

        # include plugin (link) data
        my $PluginList = $PluginObject->PluginList();
        for my $PluginKey ( sort keys %{$PluginList} ) {
            my $LinkList = $PluginObject->PluginLinkList(
                AppointmentID => $Appointment{AppointmentID},
                PluginKey     => $PluginKey,
                UserID        => $Param{UserID},
            );
            my @LinkArray;
            for my $LinkID ( sort keys %{$LinkList} ) {
                push @LinkArray, $LinkList->{$LinkID}->{LinkID};
            }

            if (@LinkArray) {
                $ICalEvent->add_properties(
                    "x-otrs-plugin-$PluginKey" => join( ',', @LinkArray ),
                );
            }
        }

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

        # add repeatable properties
        for my $Repeatable (@ICalRepeatableProperties) {
            $ICalEvent->add_properties(
                $Repeatable->{Property} => $Repeatable->{Value},
            );
        }

        $ICalCalendar->add_entry($ICalEvent);
    }

    return $ICalCalendar->as_string();
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
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut

1;
