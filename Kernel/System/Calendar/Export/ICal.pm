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
    'Kernel::System::DB',
    'Kernel::System::Log',
    'Kernel::System::Time',
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
        UserTimeZone => 1,    # (optional) Time zone offset
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

    # time zone offset
    $Param{UserTimeZone} = $Param{UserTimeZone} ? int $Param{UserTimeZone} : 0;

    # needed objects
    my $CalendarObject    = $Kernel::OM->Get('Kernel::System::Calendar');
    my $AppointmentObject = $Kernel::OM->Get('Kernel::System::Calendar::Appointment');

    my %Calendar = $CalendarObject->CalendarGet(
        CalendarID => $Param{CalendarID},
    );
    return if !$Calendar{CalendarID};

    my @AppointmentIDs = $AppointmentObject->AppointmentList(
        CalendarID => $Calendar{CalendarID},
    );
    return if !( scalar @AppointmentIDs );

    my $ICalCalendar = Data::ICal->new(
        calname => $Calendar{CalendarName},
    );

    for my $AppointmentID (@AppointmentIDs) {
        my %Appointment = $AppointmentObject->AppointmentGet(
            AppointmentID => $AppointmentID,
        );
        return if !$Appointment{ID};

        # get time object
        my $TimeObject = $Kernel::OM->Get('Kernel::System::Time');

        # check end time
        my $ICalEndTime;
        if ( $Appointment{EndTime} ) {
            my $EndTime = $TimeObject->TimeStamp2SystemTime(
                String => $Appointment{EndTime},
            );
            $ICalEndTime = Date::ICal->new(
                epoch => $EndTime - ( $Param{UserTimeZone} * 3600 ),
            );
        }

        # calculate start time
        my $ICalStartTime;
        my $StartTime = $TimeObject->TimeStamp2SystemTime(
            String => $Appointment{StartTime},
        );
        if ($ICalEndTime) {
            $ICalStartTime = Date::ICal->new(
                epoch => $StartTime - ( $Param{UserTimeZone} * 3600 ),
            );
        }
        else {
            my ( $Sec, $Min, $Hour, $Day, $Month, $Year ) = $TimeObject->SystemTime2Date(
                SystemTime => $StartTime,
            );
            $ICalStartTime = Date::ICal->new(
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
        if ($ICalEndTime) {
            $ICalEventProperties{dtend} = $ICalEndTime->ical();
        }

        # add both required and optional properties
        $ICalEvent->add_properties(
            summary => $Appointment{Title},
            dtstart => $ICalEndTime ? $ICalStartTime->ical() : substr( $ICalStartTime->ical(), 0, -1 ),
            %ICalEventProperties,
        );

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
did not
