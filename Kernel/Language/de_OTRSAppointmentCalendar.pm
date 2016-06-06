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

    # Template: AgentAppointmentCalendarImport
    $Self->{Translation}->{'Uploaded file must be in valid iCal format (.ics).'} = 'Die hochgeladene Datei muss in einem gültigen iCal-Format (.ics) vorliegen.';
    $Self->{Translation}->{"If desired Calendar is not listed here, please make sure that you have at least 'create' permissions."} = 'Sollte ein gewünschter Kalender hier nicht aufgelistet sein, stellen Sie bitte sicher, dass Sie mindestens die Berechtigung zum Erstellen von Kalendern besitzen.';
    $Self->{Translation}->{'Update existing appointments?'} = 'Existierende Termine überschreiben?';
    $Self->{Translation}->{'All existing appointments in the calendar with same UniqueID will be overwritten.'} = 'Alle existierenden Termine mit der selben "UniqueID" im entsprechenden Kalender werden überschrieben.';

    # Template: AgentAppointmentCalendarManage
    $Self->{Translation}->{'Calendar Management'} = 'Kalenderverwaltung';
    $Self->{Translation}->{'Calendar Overview'} = 'Kalenderübersicht';
    $Self->{Translation}->{'Add new Calendar'} = 'Neuen Kalender anlegen';
    $Self->{Translation}->{'Calendar Import'} = 'Kalender importieren';
    $Self->{Translation}->{'Here you can upload a file to import calendar to your system. The file needs to be in .ics format.'} =
        'An dieser Stelle können Sie eine Datei hochladen, um Kalender in Ihr System zu importieren. Die Datei muss im ICS-Format vorliegen.';
    $Self->{Translation}->{'Upload calendar'} = 'Kalender hochladen';
    $Self->{Translation}->{'Import calendar'} = 'Kalender importieren';
    $Self->{Translation}->{'Import Calendar'} = 'Kalender importieren';
    $Self->{Translation}->{'Filter for calendars'} = 'Filter für Kalender';
    $Self->{Translation}->{'Depending on the group field, the system will allow users the access to the calendar according to their permission level.'} =
        'Abhängig von der Gruppenzugehörigkeit wird das System Benutzern den Zugriff anhand ihrer Berechtigungen erlauben bzw. verweigern.';
    $Self->{Translation}->{'Read only: users can see and export all appointments in the calendar.'} =
        'RO: Benutzer können Termine sehen und Kalender exportieren.';
    $Self->{Translation}->{'Move into: users can modify appointments in the calendar, but without changing the calendar selection.'} =
        'Verschieben in: Benutzer können Termine innerhalb eines Kalenders bearbeiten, diese jedoch nicht in andere Kalender verschieben.';
    $Self->{Translation}->{'Erstellen: users can create and delete appointments in the calendar.'} =
        'Benutzer können Termine erstellen und löschen.';
    $Self->{Translation}->{'Read/write: users can manage the calendar itself.'} = 'RO: Benutzer können die Kalender an sich verwalten.';
    $Self->{Translation}->{'Calendar imported successfully.'} = 'Kalender erfolgreich importiert.';
    $Self->{Translation}->{'Calendar name'} = 'Kalendername';
    $Self->{Translation}->{'Calendar with same name already exists.'} = 'Ein Kalender mit gleichem Namen existiert bereits.';
    $Self->{Translation}->{'Permission group'} = 'Berechtigungsgruppe';
    $Self->{Translation}->{'Color'} = 'Farbe';

    # Template: AgentAppointmentCalendarOverview
    $Self->{Translation}->{'Manage Calendars'} = 'Kalender verwalten';
    $Self->{Translation}->{'Calendars'} = 'Kalender';
    $Self->{Translation}->{'This is an overview page for the Appointment Calendar.'} = 'Dies ist eine Übersicht für die Terminkalender.';
    $Self->{Translation}->{'No calendars found. Please add a calendar first by using Manage Calendars page.'} =
        'Keine Kalender gefunden. Bitte legen Sie zuerst einen Kalender über die Kalenderverwaltung an.';
    $Self->{Translation}->{'Week'} = 'Woche';
    $Self->{Translation}->{'Timeline'} = 'Zeitleiste';
    $Self->{Translation}->{'Jump'} = 'Springen';
    $Self->{Translation}->{'Appointment'} = 'Termin';
    $Self->{Translation}->{'This is a repeating appointment'} = 'Dieser Termin wiederholt sich';
    $Self->{Translation}->{'Would you like to edit just this occurrence or all occurrences?'} =
        'Möchten Sie nur diesen Termin oder alle Vorkommnisse bearbeiten?';
    $Self->{Translation}->{'All occurrences'} = 'Alle Vorkommnisse';
    $Self->{Translation}->{'Just this occurrence'} = 'Nur diesen Termin';
    $Self->{Translation}->{'Dismiss'} = 'Verwerfen';
    $Self->{Translation}->{'Basic information'} = 'Grundlegende Informationen';
    $Self->{Translation}->{'Date/Time'} = 'Datum/Zeit';
    $Self->{Translation}->{'End date'} = 'Endzeitpunkt';
    $Self->{Translation}->{'Repeat'} = 'Wiederholung';

    # Template: AgentAppointmentCalendarOverviewSeen
    $Self->{Translation}->{'Following appointments have been started'} = 'Die folgenden Termine haben begonnen';
    $Self->{Translation}->{'Start time'} = 'Startzeitpunkt';
    $Self->{Translation}->{'End time'} = 'Endzeitpunkt';
    $Self->{Translation}->{'Resource'} = 'Resource';

    # Template: AgentAppointmentEdit
    $Self->{Translation}->{'Team'} = 'Team';

    # Template: AgentAppointmentResourceOverview
    $Self->{Translation}->{'Resource Overview'} = 'Resourcenübersicht';
    $Self->{Translation}->{'Manage Teams'} = 'Teams verwalten';
    $Self->{Translation}->{'Manage Team Agents'} = 'Team-Agenten verwalten';
    $Self->{Translation}->{'This is a resource overview page.'} = 'Dies ist eine Resourcenübersicht.';
    $Self->{Translation}->{'No teams found. Please add a team first by using Manage Teams page.'} =
        'Keine Teams gefunden. Bitte legen Sie zuerst ein Team über die Teamverwaltung an.';
    $Self->{Translation}->{'No team agents found. Please assign agents to a team first by using Manage Team Agents page.'} =
        'Keine Team-Agent gefunden. Bitte weisen Sie über die Team-Agenten-Verwaltung zuerst Agenten zum Team hinzu.';
    $Self->{Translation}->{'Timeline Month'} = 'Zeitleiste Monat';
    $Self->{Translation}->{'Timeline Week'} = 'Zeitleiste Woche';
    $Self->{Translation}->{'Timeline Day'} = 'Zeitleiste Tag';
    $Self->{Translation}->{'Resources'} = 'Resourcen';

    # Template: AgentAppointmentTeam
    $Self->{Translation}->{'Add Team'} = 'Team hinzufügen';
    $Self->{Translation}->{'Filter for teams'} = 'Filter für Teams';
    $Self->{Translation}->{'Edit Team'} = 'Team bearbeiten';
    $Self->{Translation}->{'Team with same name already exists.'} = 'Ein Team mit dem selben Namen existiert bereits.';
    $Self->{Translation}->{'Export'} = 'Exportieren';
    $Self->{Translation}->{'Export team'} = 'Team exportieren';
    $Self->{Translation}->{'Here you can upload a configuration file to import a team to your system. The file needs to be in .yml format as exported by team management module.'} = 'Hier können Sie eine Konfigurationsdatei hochladen, um ein Team in Ihr System zu importieren. Die Datei muss im YAML-Formal (.yml) vorliegen, wie sie im Team-Management-Modul exportiert wurde.';
    $Self->{Translation}->{'Import team'} = 'Team importieren';
    $Self->{Translation}->{'Team imported!'} = 'Team importiert!';

    # Template: AgentAppointmentTeamUser
    $Self->{Translation}->{'Manage Team-Agent Relations'} = 'Team-Agenten-Zuordnungen verwalten';
    $Self->{Translation}->{'Change Agent Relations for Team'} = 'Ändere Agenten-Zuordnungen für Team';
    $Self->{Translation}->{'Change Team Relations for Agent'} = 'Ändere Team-Zuordnungen für Agent';
    $Self->{Translation}->{'Filter for agents'} = 'Filter für Agenten';

    # Perl Module: Kernel/Modules/AgentAppointmentCalendarManage.pm
    $Self->{Translation}->{'System was unable to create Calendar!'} = 'Das System konnten den Kalender nicht erstellen!';
    $Self->{Translation}->{'No CalendarID!'} = 'Keine CalenderID!';
    $Self->{Translation}->{'You have no access to this calendar!'} = 'Sie haben keine Zugriffsberechtigung auf diesen Kalender!';
    $Self->{Translation}->{'Edit Calendar'} = 'Kalender bearbeiten';
    $Self->{Translation}->{'Error updating the calendar!'} = 'Fehler beim Aktualisieren des Kalenders!';
    $Self->{Translation}->{'No permissions'} = 'Keine Berechtigung';
    $Self->{Translation}->{'No permissions to create a new calendar!'} = 'Keine Berechtigung um einen neuen Kalender zu erstellen!';
    $Self->{Translation}->{'System was unable to create a new calendar!'} = 'Das System konnten den neuen Kalender nicht erstellen!';
    $Self->{Translation}->{'System was unable to import file!'} = 'Das System konnte die Datei nicht importieren!';

    # Perl Module: Kernel/Modules/AgentAppointmentEdit.pm
    $Self->{Translation}->{'Every Day'} = 'Jeden Tag';
    $Self->{Translation}->{'Every Week'} = 'Jede Woche';
    $Self->{Translation}->{'Every Month'} = 'Jeden Monat';
    $Self->{Translation}->{'Every Year'} = 'Jedes Jahr';
    $Self->{Translation}->{'Custom'} = 'Benutzerdefiniert';
    $Self->{Translation}->{'until ...'} = 'bis ...';
    $Self->{Translation}->{'for ... time(s)'} = 'für ... Wiederholungen';
    $Self->{Translation}->{'No permission!'} = 'Keine Berechtigung!';
    $Self->{Translation}->{'Links could not be deleted!'} = 'Links konnten nicht gelöscht werden!';
    $Self->{Translation}->{'Link could not be created!'} = 'Links konnten nicht erstellt werden!';
    $Self->{Translation}->{'No permissions!'} = 'Keine Berechtigung!';
    $Self->{Translation}->{'Frequency'} = 'Frequenz';
    $Self->{Translation}->{'Daily'} = 'täglich';
    $Self->{Translation}->{'Weekly'} = 'wöchentlich';
    $Self->{Translation}->{'Monthly'} = 'monatlich';
    $Self->{Translation}->{'Yearly'} = 'jährlich';
    $Self->{Translation}->{'Every'} = 'Alle';
    $Self->{Translation}->{'On'} = 'Am';
    $Self->{Translation}->{'minutes before'} = 'Minuten vorher';
    $Self->{Translation}->{'hour before'} = 'Stunde vorher';
    $Self->{Translation}->{'hours before'} = 'Stunden vorher';
    $Self->{Translation}->{'day before'} = 'Tag vorher';
    $Self->{Translation}->{'days before'} = 'Tage vorher';
    $Self->{Translation}->{'week before'} = 'Woche vorher';
    $Self->{Translation}->{'No notification'} = 'Keine Benachrichtigung';
    $Self->{Translation}->{'Relative point of time'} = 'Relativer Zeitpunkt';
    $Self->{Translation}->{'before the appointment starts'} = 'bevor der Termin beginnt';
    $Self->{Translation}->{'after the appointment has been started'} = 'nachdem der Termin begonnen hat';
    $Self->{Translation}->{'before the appointment ends'} = 'bevor der Termin endet';
    $Self->{Translation}->{'after the appointment has been ended'} = 'nachdem der Termin geendet hat';

    # Perl Module: Kernel/Modules/AgentAppointmentList.pm
    $Self->{Translation}->{'Ongoing appointments'} = 'Laufende Termine';

    # Perl Module: Kernel/Modules/AgentAppointmentTeamList.pm
    $Self->{Translation}->{'Unassigned'} = 'Nicht zugeordnet';

    # Perl Module: Kernel/Modules/PublicCalendar.pm
    $Self->{Translation}->{'There was an error exporting the calendar!'} = 'Es ist ein Fehler beim Exportieren des Kalenders aufgetreten!';

    # SysConfig
    $Self->{Translation}->{'Appointment Calendar overview page.'} = 'Terminkalender Übersicht';
    $Self->{Translation}->{'Appointment edit screen.'} = 'Terminbearbeitungsansicht';
    $Self->{Translation}->{'Appointment list'} = 'Terminliste';
    $Self->{Translation}->{'Appointment list.'} = 'Terminliste.';
    $Self->{Translation}->{'CalDav'} = 'CalDav';
    $Self->{Translation}->{'Calendar manage screen.'} = 'Kalenderverwaltungsansicht';
    $Self->{Translation}->{'Defines the ticket number plugin for calendar appointments.'} = 'Legt das Plugin für die Ticketnummern innerhalb von Terminkalendern fest.';
    $Self->{Translation}->{'Defines which backend should be used for managing calendars.'} =
        'Legt fest, welches Backend für die Kalenderverwaltung genutzt wird.';
    $Self->{Translation}->{'Edit appointment'} = 'Termin bearbeiten';
    $Self->{Translation}->{'Links appointments and tickets with a "Normal" type link.'} = 'Verknüpft Termine und Tickets mit dem Typ "Normal".';
    $Self->{Translation}->{'List of colors in hexadecimal RGB which will be available for selection during calendar creation. Make sure the colors are dark enough so white text can be overlayed on them.'} =
        'Liste an Farben in Hexadezimal RGB, welche verschiedenen Benutzerkalendern zugewiesen werden. Stellen Sie sicher, dass die Farben dunkel genug sind, um weißen Text darauf darzustellen. Sofern die Anzahl der Kalender die Anzahl der verfügbaren Farben überschreitet, wird diese Liste erneut von Anfang an genutzt.';
    $Self->{Translation}->{'Manage different calendars.'} = 'Verschiedene Kalender verwalten';
    $Self->{Translation}->{'Manage team agents.'} = 'Team-Agenten verwalten';
    $Self->{Translation}->{'Plugin search'} = 'Pluginsuche';
    $Self->{Translation}->{'Plugin search module for autocomplete.'} = 'Module zur Pluginsuche für die Autovervollständigung.';
    $Self->{Translation}->{'Resource overview page.'} = 'Resourcenübersichtsseite';
    $Self->{Translation}->{'Resource overview screen.'} = 'Resourcenübersichtsseite';
    $Self->{Translation}->{'Resources list.'} = 'Resourcenliste';
    $Self->{Translation}->{'Team agents management screen.'} = 'Team-Agenten Verwaltungsansicht';
    $Self->{Translation}->{'Team list'} = 'Teamliste';
    $Self->{Translation}->{'Team management screen.'} = 'Teamverwaltungsansicht';
    $Self->{Translation}->{'Team management.'} = 'Teamverwaltung';
    $Self->{Translation}->{'Defines the ticket plugin for calendar appointments.'} = 'Legt das Ticket-Plugin für Termine fest.';
    $Self->{Translation}->{'Links appointments and tickets with a "Normal" type link.'} = 'Verknüpft Termine und Tickets mit einem Link vom Typ "Normal".';
    $Self->{Translation}->{"OTRS doesn't support recurring Appointments without end date or number of iterrations. During import process, it might happen that ICS file contains such Appointments. Instead, system creates all Appointments in the past, plus Appointments for the next n months(120 months/10 years by default)."} = "OTRS unterstützt keine wiederholenden Termine oder Enddatum oder Anzahl an Iterationen. Während Import-Prozessen kann es passieren, dass ICS-Dateien solche Termine enthalten. OTRS wird stattdessen alle vergangenen Termine sowie alle Termine der kommenden n Monate (120 Monate / 10 Jahre standardmäßig) erstellen.";
    $Self->{Translation}->{'Shows a link in the menu for creating a calendar appointment linked to the ticket directly from the ticket zoom view of the agent interface. Additional access control to show or not show this link can be done by using Key "Group" and Content like "rw:group1;move_into:group2". To cluster menu items use for Key "ClusterName" and for the Content any name you want to see in the UI. Use "ClusterPriority" to configure the order of a certain cluster within the toolbar.'} = 'Zeigt einen Link im Menü der TicketZoom-Ansicht im Agenten-Interface an, um Termine zu erstellen, welche direkt mit dem entsprechenden Ticket verknüpft sind. Zusätzliche Zugriffskontrolle, ob der Menüpunkt angezeigt wird oder nicht, kann mit dem Schlüssel "Gruppe" und "Inhalt" wie z.B. ("rw:group1;move_into:group2") erreicht werden. Um Menüeinträge zu gruppieren, verwenden Sie den Schlüssel "ClusterName" und im Inhalt den Namen, welchen Sie in der Ansicht verwenden möchten. Verwenden Sie "ClusterPriority" um die Reihenfolge in der jeweiligen Gruppierung zu beeinflussen.';
    $Self->{Translation}->{'New Appointment'} = 'Neuer Termin';
    $Self->{Translation}->{'Create new appointment.'} = 'Einen neuen Termin erstellen';
    $Self->{Translation}->{'Maximum number of active calendars in overview screens. Please note that large number of active calendars can have a performance impact on your server by making too much simultaneous calls.'} = 'Maximale Anzahl an aktiven Kalendern in der Kalenderübersicht oder Resourcenübersicht. Bitte beachten Sie, dass sich zuviele gleichzeitig aktive Kalender aufgrund vieler gleichzeitiger Anfragen auf die Performance des Systems auswirken kann.';
    $Self->{Translation}->{'Create a new calendar appointment linked to this ticket'} = 'Erstellt einen neuen Termin in einem Kalender, welcher direkt mit diesem Ticket verknüpft ist';

}

1;
