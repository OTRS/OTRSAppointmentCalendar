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
    $Self->{Translation}->{'Calendar Management'} = 'Kalenderverwaltung';
    $Self->{Translation}->{'Calendars'} = 'Kalender';
    $Self->{Translation}->{'Filter for calendars'} = 'Filter für Kalender';
    $Self->{Translation}->{'Add new Calendar'} = 'Neuen Kalender anlegen';
    $Self->{Translation}->{'Calendar name'} = 'Kalendername';
    $Self->{Translation}->{'Permission group'} = 'Berechtigungsgruppe';
    $Self->{Translation}->{'Edit Calendar'} = 'Kalender bearbeiten';
    $Self->{Translation}->{'Calendar with same name already exists.'} = 'Ein Kalender mit gleichem Namen existiert bereits.';

    # Template: AgentAppointmentCalendarOverview
    $Self->{Translation}->{'This is an overview page for the Appointment Calendar.'} = 'Dies ist eine Übersicht für die Terminkalender.';
    $Self->{Translation}->{'No calendars found. Please add a calendar first by using Manage Calendars page.'} = 'Keine Kalender gefunden. Bitte legen Sie zuerst einen Kalender über die Kalenderverwaltung an.';
    $Self->{Translation}->{'Week'} = 'Woche';
    $Self->{Translation}->{'Jump'} = 'Springen';
    $Self->{Translation}->{'Timeline'} = 'Zeitleiste';
    $Self->{Translation}->{'This is a repeating appointment'} = 'Dieser Termin wiederholt sich';
    $Self->{Translation}->{'Would you like to edit just this occurrence or all occurrences?'} = 'Möchten Sie nur diesen Termin oder alle Vorkommnisse bearbeiten?';
    $Self->{Translation}->{'All occurrences'} = 'Alle Vorkommnisse';
    $Self->{Translation}->{'Just this occurrence'} = 'Nur diesen Termin';
    $Self->{Translation}->{'Dismiss'} = 'Verwerfen';

    # Template: AgentAppointmentCalendarOverviewSeen
    $Self->{Translation}->{'Ongoing appointments'} = 'Laufende Termine';
    $Self->{Translation}->{'Following appointments have been started'} = 'Die folgenden Termine haben begonnen';
    $Self->{Translation}->{'Start time'} = 'Startzeitpunkt';
    $Self->{Translation}->{'End time'} = 'Endzeitpunkt';

    # Template: AgentAppointmentEdit
    $Self->{Translation}->{'Basic information'} = 'Grundlegende Informationen';
    $Self->{Translation}->{'Date/Time'} = 'Datum/Zeit';
    $Self->{Translation}->{'End date'} = 'Endzeitpunkt';
    $Self->{Translation}->{'Please set this to a value after start date.'} = 'Bitte setzen Sie hier einen Wert nach dem Startzeitpunkt.';
    $Self->{Translation}->{'All-day'} = 'Ganztägig';
    $Self->{Translation}->{'Repeat'} = 'Wiederholung';
    $Self->{Translation}->{'Every Day'} = 'Jeden Tag';
    $Self->{Translation}->{'Every Week'} = 'Jede Woche';
    $Self->{Translation}->{'Every Month'} = 'Jeden Monat';
    $Self->{Translation}->{'Every Year'} = 'Jedes Jahr';

    # Template: AgentAppointmentResourceOverview
    $Self->{Translation}->{'This is a resource overview page.'} = 'Dies ist eine Resourcenübersicht.';
    $Self->{Translation}->{'No teams found. Please add a team first by using Manage Teams page.'} = 'Keine Teams gefunden. Bitte legen Sie zuerst ein Team über die Teamverwaltung an.';
    $Self->{Translation}->{'Timeline Month'} = 'Zeitleiste Monat';
    $Self->{Translation}->{'Timeline Week'} = 'Zeitleiste Woche';
    $Self->{Translation}->{'Timeline Day'} = 'Zeitleiste Tag';
    $Self->{Translation}->{'Resources'} = 'Resourcen';

    # Template: AgentAppointmentTeam
    $Self->{Translation}->{'Add Team'} = 'Team hinzufügen';
    $Self->{Translation}->{'Team added!'} = 'Team hinzugefügt!';
    $Self->{Translation}->{'Edit Team'} = 'Team bearbeiten';

    # Template: AgentAppointmentTeamUser
    $Self->{Translation}->{'Manage Team-Agent Relations'} = 'Team-Agenten-Zuordnungen verwalten';
    $Self->{Translation}->{'Change Agent Relations for Team'} = 'Ändere Agenten-Zuordnungen für Team';

    # Perl Module: Kernel/Modules/AgentAppointmentCalendarManage.pm
    $Self->{Translation}->{'System was unable to create Calendar!'} = 'Das System konnten den Kalender nicht erstellen!';
    $Self->{Translation}->{'Please contact the admin.'} = 'Bitte kontaktieren Sie den Administrator.';
    $Self->{Translation}->{'No CalendarID!'} = 'Keine CalenderID!';
    $Self->{Translation}->{'You have no access to this calendar!'} = 'Sie haben keine Zugriffsberechtigung auf diesen Kalender!';
    $Self->{Translation}->{'Error updating the calendar!'} = 'Fehler beim Aktualisieren des Kalenders!';

    # Perl Module: Kernel/Modules/AgentAppointmentEdit.pm
    $Self->{Translation}->{'until ...'} = 'bis ...';
    $Self->{Translation}->{'for ... time(s)'} = 'für ... Wiederholungen';
    $Self->{Translation}->{'Links could not be deleted!'} = 'Links konnten nicht gelöscht werden!';
    $Self->{Translation}->{'Link could not be created!'} = 'Links konnten nicht erstellt werden!';
    $Self->{Translation}->{'No permissions!'} = 'Keine Berechtigung!';
    $Self->{Translation}->{'No permission!'} = 'Keine Berechtigung!';

    # Perl Module: Kernel/Modules/AgentAppointmentTeamList.pm
    $Self->{Translation}->{'Unassigned'} = 'Nicht zugeordnet';

    # Perl Module: Kernel/Modules/PublicCalendar.pm
    $Self->{Translation}->{'No CalendarID !'} = 'Keine CalenderID!';
    $Self->{Translation}->{'No UserID !'} = 'Keine UserID!';
    $Self->{Translation}->{'There was an error exporting the calendar!'} = 'Es ist ein Fehler beim Exportieren des Kalenders aufgetreten!';

    # SysConfig
    $Self->{Translation}->{'Appointment Calendar overview page.'} = 'Terminkalender Übersicht';
    $Self->{Translation}->{'Calendar Overview'} = 'Kalenderübersicht';
    $Self->{Translation}->{'Resource overview screen.'} = 'Resourcenübersichtsseite';
    $Self->{Translation}->{'Resource Overview'} = 'Resourcenübersicht';
    $Self->{Translation}->{'Resource overview page.'} = 'Resourcenübersichtsseite';
    $Self->{Translation}->{'Appointment edit screen.'} = 'Terminbearbeitungsansicht';
    $Self->{Translation}->{'Edit appointment'} = 'Termin bearbeiten';
    $Self->{Translation}->{'Appointments list.'} = 'Terminliste.';
    $Self->{Translation}->{'Appointment list'} = 'Terminliste';
    $Self->{Translation}->{'Plugin search module for autocomplete.'} = 'Module zur Pluginsuche für die Autovervollständigung.';
    $Self->{Translation}->{'Plugin search'} = 'Pluginsuche';
    $Self->{Translation}->{'Resources list.'} = 'Resourcenliste';
    $Self->{Translation}->{'Team list'} = 'Teamliste';
    $Self->{Translation}->{'Calendar manage screen.'} = 'Kalenderverwaltungsansicht';
    $Self->{Translation}->{'Manage Calendars'} = 'Kalender verwalten';
    $Self->{Translation}->{'Manage different calendars.'} = 'Verschiedene Kalender verwalten';
    $Self->{Translation}->{'Team management screen.'} = 'Teamverwaltungsansicht';
    $Self->{Translation}->{'Manage Teams'} = 'Teams verwalten';
    $Self->{Translation}->{'Team management.'} = 'Teamverwaltung';
    $Self->{Translation}->{'Team agents management screen.'} = 'Team-Agenten Verwaltungsansicht';
    $Self->{Translation}->{'Manage Team Agents'} = 'Team-Agenten verwalten';
    $Self->{Translation}->{'Manage team agents.'} = 'Team-Agenten verwalten';
    $Self->{Translation}->{'List of colors in hexadecimal RGB which will be allocated to different user calendars. Make sure the colors are dark enough so white text can be overlayed on them. If the number of calendars exceeds the number of colors, the list will be reused from the start.'} = 'Liste an Farben in Hexadezimal RGB, welche verschiedenen Benutzerkalendern zugewiesen werden. Stellen Sie sicher, dass die Farben dunkel genug sind, um weißen Text darauf darzustellen. Sofern die Anzahl der Kalender die Anzahl der verfügbaren Farben überschreitet, wird diese Liste erneut von Anfang an genutzt.';
    $Self->{Translation}->{'Defines which backend should be used for managing calendars.'} = 'Legt fest, welches Backend für die Kalenderverwaltung genutzt wird.';
    $Self->{Translation}->{'Defines the ticket number plugin for calendar appointments.'} = 'Legt das Plugin für die Ticketnummern innerhalb von Terminkalendern fest.';
    $Self->{Translation}->{'Ticket Number'} = 'Ticketnummer';
    $Self->{Translation}->{'Links appointments and tickets with a "Normal" type link.'} = 'Verknüpft Termine und Tickets mit dem Typ "Normal".';
}

1;
