# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Calendar::Export::ICal;

## nofilter(TidyAll::Plugin::OTRS::Perl::SyntaxCheck)

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
        CalendarID => 1,    # (required) Valid CalendarID
        UserID     => 1,    # (required) UserID
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
    );
    return if !%Calendar;

    my $ICal = Data::ICal->new(
        calname => $Calendar{CalendarName},
    );

    # my $ical_date = Date::ICal->new(
    #     year => 2013,
    #     month => 9,
    #     day => 6,
    # );
    #
    # my $event = Data::ICal::Entry::Event->new();
    # $event->add_properties(
    #     summary => "my party",
    #     description => "I'll cry if I want to",
    #     dtstart => $ical_date->ical(),
    # );
    #
    # $calendar->add_entry($event);

    return $ICal->as_string();
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not
