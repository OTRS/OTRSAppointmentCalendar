# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::de_OTRSAppointmentCalendar;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    # Template: AgentAppointmentCalendarManage
    $Self->{Translation}->{'Ticket Created'} = 'Ticket erstellt';

    # Template: AgentAppointmentCalendarOverview
    $Self->{Translation}->{'Manage Chat Channels'} = 'Chat-Kanäle verwalten';

    # Template: AgentAppointmentDispatchOverview
    $Self->{Translation}->{'SMS (Short Message Service)'} = 'SMS (Short Message Service)';

    # Template: AgentAppointmentEdit
    $Self->{Translation}->{'Contact with data management'} = 'Kundenverwaltung';
    $Self->{Translation}->{'Add contact with data'} = 'Einen Kontakt hinzufügen';
    $Self->{Translation}->{'Please enter a search term to look for contacts with data.'} = 'Bitte geben Sie einen Suchbegriff ein, um nach Kunden zu suchen.';
    $Self->{Translation}->{'Edit contact with data'} = 'Einen Kontakt bearbeiten';

    # Template: AgentAppointmentTeam
    $Self->{Translation}->{'These are the possible data attributes for contacts.'} = 'Die folgenden Attribute sind für Kontakte möglich.';

    # Template: AgentAppointmentTeamUser
    $Self->{Translation}->{'Datatype'} = 'Datentyp';

    # Template: PublicCalendar
    $Self->{Translation}->{'Recipient SMS numbers'} = 'Empfänger-SMS-Nummern';

    # Perl Module: Kernel/Modules/AdminChatChannel.pm
    $Self->{Translation}->{'Chat Channel %s added'} = 'Chat-Kanal %s hinzugefügt';
    $Self->{Translation}->{'Chat channel %s edited'} = 'Chat-Kanal %s bearbeitet';

    # SysConfig
    $Self->{Translation}->{'Appointment Calendar overview page.'} = 'Terminkalender Übersicht';
    $Self->{Translation}->{'Calendar Overview'} = 'Kalender Übersicht';
    $Self->{Translation}->{'Dispatch overview screen.'} = 'Kalender Übersicht';
    $Self->{Translation}->{'Dispatch Overview'} = 'Kalender Übersicht';
    $Self->{Translation}->{'Dispatch overview page.'} = 'Kalender Übersicht';
    $Self->{Translation}->{'Appointment edit screen.'} = 'Kalender Übersicht';
    $Self->{Translation}->{'Edit appointment'} = 'Kalender Übersicht';
    $Self->{Translation}->{'Appointments list.'} = 'Kalender Übersicht';
    $Self->{Translation}->{'Appointment list'} = 'Kalender Übersicht';
    $Self->{Translation}->{'Plugin search module for autocomplete.'} = 'Kalender Übersicht';
    $Self->{Translation}->{'Plugin search'} = 'Kalender Übersicht';
    $Self->{Translation}->{'Resources list.'} = 'Kalender Übersicht';
    $Self->{Translation}->{'Team list'} = 'Kalender Übersicht';
    $Self->{Translation}->{'Calendar manage screen.'} = 'Kalender Übersicht';
    $Self->{Translation}->{'Manage Calendars'} = 'Kalender Übersicht';
    $Self->{Translation}->{'Manage different calendars.'} = 'Kalender Übersicht';
    $Self->{Translation}->{'Team management screen.'} = 'Kalender Übersicht';
    $Self->{Translation}->{'Manage Teams'} = 'Kalender Übersicht';
    $Self->{Translation}->{'Team management.'} = 'Kalender Übersicht';
    $Self->{Translation}->{'Team agents management screen.'} = 'Kalender Übersicht';
    $Self->{Translation}->{'Manage Team Agents'} = 'Kalender Übersicht';
    $Self->{Translation}->{'Manage team agents.'} = 'Kalender Übersicht';
    $Self->{Translation}->{'List of colors in hexadecimal RGB which will be allocated to different user calendars. Make sure the colors are dark enough so white text can be overlayed on them. If the number of calendars exceeds the number of colors, the list will be reused from the start.'} = 'Kalender Übersicht';
    $Self->{Translation}->{'Defines which backend should be used for managing calendars.'} = 'Kalender Übersicht';
    $Self->{Translation}->{'Defines the ticket number plugin for calendar appointments.'} = 'Kalender Übersicht';
    $Self->{Translation}->{'Ticket Number'} = 'Kalender Übersicht';
    $Self->{Translation}->{'Links appointments and tickets with a "Normal" type link.'} = 'Kalender Übersicht';
}

1;
