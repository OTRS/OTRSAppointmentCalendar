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

    # Template: AdminAppointmentNotificationEvent
    $Self->{Translation}->{'Appointment Filter'} = 'Terminfilter';
    $Self->{Translation}->{'Notify user just once per day about a single appointment using a selected transport.'} = 'Nur einmal am Tag pro Termin und Benachrichtigungs-Transportmethode versenden.';
    $Self->{Translation}->{'Here you can choose which events will trigger this notification. An additional appointment filter can be applied below to only send for appointments with certain criteria.'} = 'Hier können Sie auswählen, welche Ereignisse diese Benachrichtigung auslösen. Ein zusätzlicher Termin-Filter kann weiter unten eingestellt werden, um die Benachrichtigung nur für Termine mit bestimmten Merkmalen zu versenden.';

    # Template: AgentAppointmentAgendaOverview
    $Self->{Translation}->{'Agenda Overview'} = 'Agendaübersicht';
    $Self->{Translation}->{'Manage Calendars'} = 'Kalender verwalten';
    $Self->{Translation}->{'Add Appointment'} = 'Termin hinzufügen';
    $Self->{Translation}->{'Color'} = 'Farbe';
    $Self->{Translation}->{'End date'} = 'Endzeitpunkt';
    $Self->{Translation}->{'Repeat'} = 'Wiederholung';
    $Self->{Translation}->{'No calendars found. Please add a calendar first by using Manage Calendars page.'} =
        'Keine Kalender gefunden. Bitte legen Sie zuerst einen Kalender über die Kalenderverwaltung an.';
    $Self->{Translation}->{'Appointment'} = 'Termin';
    $Self->{Translation}->{'This is a repeating appointment'} = 'Dieser Termin wiederholt sich';
    $Self->{Translation}->{'Would you like to edit just this occurrence or all occurrences?'} =
        'Möchten Sie nur diesen Termin oder alle Vorkommnisse bearbeiten?';
    $Self->{Translation}->{'All occurrences'} = 'Alle Vorkommnisse';
    $Self->{Translation}->{'Just this occurrence'} = 'Nur diesen Termin';

    # Template: AgentAppointmentCalendarManage
    $Self->{Translation}->{'Calendar Management'} = 'Kalenderverwaltung';
    $Self->{Translation}->{'Calendar Overview'} = 'Kalenderübersicht';
    $Self->{Translation}->{'Add new Calendar'} = 'Einen neuen Kalender anlegen';
    $Self->{Translation}->{'Add Calendar'} = 'Neuen Kalender anlegen';
    $Self->{Translation}->{'Import Appointments'} = '';
    $Self->{Translation}->{'Calendar Import'} = 'Kalender importieren';
    $Self->{Translation}->{'Here you can upload a configuration file to import a calendar to your system. The file needs to be in .yml format as exported by calendar management module.'} =
        '';
    $Self->{Translation}->{'Upload calendar configuration'} = '';
    $Self->{Translation}->{'Import Calendar'} = 'Kalender importieren';
    $Self->{Translation}->{'Filter for calendars'} = 'Filter für Kalender';
    $Self->{Translation}->{'Depending on the group field, the system will allow users the access to the calendar according to their permission level.'} =
        'Abhängig von der Gruppenzugehörigkeit wird das System Benutzern den Zugriff anhand ihrer Berechtigungen erlauben bzw. verweigern.';
    $Self->{Translation}->{'Read only: users can see and export all appointments in the calendar.'} =
        'RO: Benutzer können Termine sehen und Kalender exportieren.';
    $Self->{Translation}->{'Move into: users can modify appointments in the calendar, but without changing the calendar selection.'} =
        'Verschieben in: Benutzer können Termine innerhalb eines Kalenders bearbeiten, diese jedoch nicht in andere Kalender verschieben.';
    $Self->{Translation}->{'Create: users can create and delete appointments in the calendar.'} =
        '';
    $Self->{Translation}->{'Read/write: users can manage the calendar itself.'} = 'RO: Benutzer können die Kalender an sich verwalten.';
    $Self->{Translation}->{'URL'} = '';
    $Self->{Translation}->{'Export calendar'} = '';
    $Self->{Translation}->{'Download calendar'} = '';
    $Self->{Translation}->{'Copy public calendar URL'} = 'Öffentliche Kalender URL kopieren';
    $Self->{Translation}->{'Calendar name'} = 'Kalendername';
    $Self->{Translation}->{'Calendar with same name already exists.'} = 'Ein Kalender mit gleichem Namen existiert bereits.';
    $Self->{Translation}->{'Permission group'} = 'Berechtigungsgruppe';
    $Self->{Translation}->{'Ticket Appointments'} = '';
    $Self->{Translation}->{'Rule'} = '';
    $Self->{Translation}->{'Use options below to narrow down for which tickets appointments will be automatically created.'} =
        '';
    $Self->{Translation}->{'Please select a valid queue.'} = '';
    $Self->{Translation}->{'Search attributes'} = '';
    $Self->{Translation}->{'Define rules for creating automatic appointments in this calendar based on ticket data.'} =
        '';
    $Self->{Translation}->{'Add Rule'} = '';
    $Self->{Translation}->{'More'} = 'Mehr';
    $Self->{Translation}->{'Less'} = 'Weniger';

    # Template: AgentAppointmentCalendarOverview
    $Self->{Translation}->{'Add new Appointment'} = 'Einen neuen Termin anlegen';
    $Self->{Translation}->{'Calendars'} = 'Kalender';
    $Self->{Translation}->{'This is an overview page for the Appointment Calendar.'} = 'Dies ist eine Übersicht für die Terminkalender.';
    $Self->{Translation}->{'Too many active calendars'} = '';
    $Self->{Translation}->{'Please either turn some off first or increase the limit in configuration.'} =
        '';
    $Self->{Translation}->{'Week'} = 'Woche';
    $Self->{Translation}->{'Timeline Month'} = '';
    $Self->{Translation}->{'Timeline Week'} = '';
    $Self->{Translation}->{'Timeline Day'} = '';
    $Self->{Translation}->{'Jump'} = 'Springen';
    $Self->{Translation}->{'Dismiss'} = 'Verwerfen';
    $Self->{Translation}->{'Show'} = 'Anzeigen';
    $Self->{Translation}->{'Basic information'} = 'Grundlegende Informationen';
    $Self->{Translation}->{'Resource'} = 'Resource';
    $Self->{Translation}->{'Team'} = 'Team';
    $Self->{Translation}->{'Date/Time'} = 'Datum/Zeit';

    # Template: AgentAppointmentCalendarOverviewSeen
    $Self->{Translation}->{'Following appointments have been started'} = 'Die folgenden Termine haben begonnen';
    $Self->{Translation}->{'Start time'} = 'Startzeitpunkt';
    $Self->{Translation}->{'End time'} = 'Endzeitpunkt';

    # Template: AgentAppointmentEdit
    $Self->{Translation}->{'Please set this to value before End date.'} = '';
    $Self->{Translation}->{'Please set this to value after Start date.'} = '';
    $Self->{Translation}->{'This an ocurrence of a repeating appointment.'} = '';
    $Self->{Translation}->{'Click here to see the parent appointment.'} = 'Klicken Sie hier, um den Eltern-Termin anzuzeigen.';
    $Self->{Translation}->{'Click here to edit the parent appointment.'} = '';
    $Self->{Translation}->{'Frequency'} = 'Frequenz';
    $Self->{Translation}->{'Every'} = 'Alle';
    $Self->{Translation}->{'Relative point of time'} = 'Relativer Zeitpunkt';
    $Self->{Translation}->{'Are you sure you want to delete this appointment? This operation cannot be undone.'} =
        'Möchten Sie diesen Termin wirklich löschen? Diese Änderung kann nicht rückgängig gemacht werden.';

    # Template: AgentAppointmentImport
    $Self->{Translation}->{'Appointment Import'} = '';
    $Self->{Translation}->{'Uploaded file must be in valid iCal format (.ics).'} = 'Die hochgeladene Datei muss in einem gültigen iCal-Format (.ics) vorliegen.';
    $Self->{Translation}->{'If desired Calendar is not listed here, please make sure that you have at least \'create\' permissions.'} =
        'Sollte ein gewünschter Kalender hier nicht aufgelistet sein, stellen Sie bitte sicher, dass Sie mindestens die Berechtigung zum Erstellen von Kalendern besitzen.';
    $Self->{Translation}->{'Update existing appointments?'} = 'Existierende Termine überschreiben?';
    $Self->{Translation}->{'All existing appointments in the calendar with same UniqueID will be overwritten.'} =
        'Alle existierenden Termine mit der selben "UniqueID" im entsprechenden Kalender werden überschrieben.';
    $Self->{Translation}->{'Upload calendar'} = 'Kalender hochladen';
    $Self->{Translation}->{'Import appointments'} = '';

    # Template: AgentDashboardAppointmentCalendar
    $Self->{Translation}->{'New Appointment'} = 'Neuer Termin';
    $Self->{Translation}->{'Soon'} = 'Demnächst';
    $Self->{Translation}->{'5 days'} = '5 Tage';

    # Perl Module: Kernel/Modules/AgentAppointmentCalendarManage.pm
    $Self->{Translation}->{'System was unable to create Calendar!'} = 'Das System konnten den Kalender nicht erstellen!';
    $Self->{Translation}->{'No CalendarID!'} = 'Keine CalenderID!';
    $Self->{Translation}->{'You have no access to this calendar!'} = 'Sie haben keine Zugriffsberechtigung auf diesen Kalender!';
    $Self->{Translation}->{'Edit Calendar'} = 'Kalender bearbeiten';
    $Self->{Translation}->{'Error updating the calendar!'} = 'Fehler beim Aktualisieren des Kalenders!';
    $Self->{Translation}->{'Could not import the calendar!'} = '';
    $Self->{Translation}->{'Calendar imported!'} = '';
    $Self->{Translation}->{'Need CalendarID!'} = '';
    $Self->{Translation}->{'Could not retrieve data for given CalendarID'} = '';
    $Self->{Translation}->{'Successfully imported %s appointment(s) to calendar %s.'} = '';
    $Self->{Translation}->{'+5 minutes'} = '';
    $Self->{Translation}->{'+15 minutes'} = '';
    $Self->{Translation}->{'+30 minutes'} = '';
    $Self->{Translation}->{'+1 hour'} = '';

    # Perl Module: Kernel/Modules/AgentAppointmentCalendarOverview.pm
    $Self->{Translation}->{'All appointments'} = 'Alle Termine';
    $Self->{Translation}->{'Appointments assigned to me'} = 'Mir zugewiesene Termine';
    $Self->{Translation}->{'Showing only appointments assigned to you! Change settings'} = 'Es werden nur Termine angezeigt, die Ihnen zugewiesen sind! Einstellungen ändern';

    # Perl Module: Kernel/Modules/AgentAppointmentEdit.pm
    $Self->{Translation}->{'Appointment not found!'} = '';
    $Self->{Translation}->{'Never'} = 'Niemals';
    $Self->{Translation}->{'Every Day'} = 'Jeden Tag';
    $Self->{Translation}->{'Every Week'} = 'Jede Woche';
    $Self->{Translation}->{'Every Month'} = 'Jeden Monat';
    $Self->{Translation}->{'Every Year'} = 'Jedes Jahr';
    $Self->{Translation}->{'Custom'} = 'Benutzerdefiniert';
    $Self->{Translation}->{'Daily'} = 'täglich';
    $Self->{Translation}->{'Weekly'} = 'wöchentlich';
    $Self->{Translation}->{'Monthly'} = 'monatlich';
    $Self->{Translation}->{'Yearly'} = 'jährlich';
    $Self->{Translation}->{'every'} = 'alle';
    $Self->{Translation}->{'for %s time(s)'} = 'für %s Wiederholungen';
    $Self->{Translation}->{'until ...'} = 'bis ...';
    $Self->{Translation}->{'for ... time(s)'} = 'für ... Wiederholungen';
    $Self->{Translation}->{'until %s'} = 'bis %s';
    $Self->{Translation}->{'No notification'} = 'Keine Benachrichtigung';
    $Self->{Translation}->{'%s minute(s) before'} = '%s Minute(n) vorher';
    $Self->{Translation}->{'%s hour(s) before'} = '%s Stunde(n) vorher';
    $Self->{Translation}->{'%s day(s) before'} = '%s Tag(e) vorher';
    $Self->{Translation}->{'%s week before'} = '%s Woche(n) vorher';
    $Self->{Translation}->{'before the appointment starts'} = 'bevor der Termin beginnt';
    $Self->{Translation}->{'after the appointment has been started'} = 'nachdem der Termin begonnen hat';
    $Self->{Translation}->{'before the appointment ends'} = 'bevor der Termin endet';
    $Self->{Translation}->{'after the appointment has been ended'} = 'nachdem der Termin geendet hat';
    $Self->{Translation}->{'No permission!'} = 'Keine Berechtigung!';
    $Self->{Translation}->{'Links could not be deleted!'} = 'Links konnten nicht gelöscht werden!';
    $Self->{Translation}->{'Link could not be created!'} = 'Links konnten nicht erstellt werden!';
    $Self->{Translation}->{'Cannot delete ticket appointment!'} = '';
    $Self->{Translation}->{'No permissions!'} = 'Keine Berechtigung!';

    # Perl Module: Kernel/Modules/AgentAppointmentImport.pm
    $Self->{Translation}->{'No permissions'} = 'Keine Berechtigung';
    $Self->{Translation}->{'System was unable to import file!'} = 'Das System konnte die Datei nicht importieren!';

    # Perl Module: Kernel/Modules/AgentAppointmentList.pm
    $Self->{Translation}->{'+%d more'} = '+%d mehr';
    $Self->{Translation}->{'Ongoing appointments'} = 'Laufende Termine';

    # Perl Module: Kernel/Modules/PublicCalendar.pm
    $Self->{Translation}->{'No such user!'} = '';
    $Self->{Translation}->{'Invalid calendar!'} = '';
    $Self->{Translation}->{'Invalid URL!'} = '';
    $Self->{Translation}->{'There was an error exporting the calendar!'} = 'Es ist ein Fehler beim Exportieren des Kalenders aufgetreten!';

    # Perl Module: Kernel/Output/HTML/Dashboard/AppointmentCalendar.pm
    $Self->{Translation}->{'Refresh (minutes)'} = 'Aktualisierung (Minuten)';

    # SysConfig
    $Self->{Translation}->{'Appointment Calendar overview page.'} = 'Terminkalender Übersicht';
    $Self->{Translation}->{'Appointment calendar event module that prepares notification entries for appointments.'} =
        'Terminkalender Event-Modul, welches Benachrichtigungseinträge für Termine vorbereitet.';
    $Self->{Translation}->{'Appointment calendar event module that updates the ticket with data from ticket appointment.'} =
        '';
    $Self->{Translation}->{'Appointment edit screen.'} = 'Terminbearbeitungsansicht';
    $Self->{Translation}->{'Appointment list'} = 'Terminliste';
    $Self->{Translation}->{'Appointment list.'} = 'Terminliste.';
    $Self->{Translation}->{'Appointments'} = 'Termine';
    $Self->{Translation}->{'Calendar manage screen.'} = 'Kalenderverwaltungsansicht';
    $Self->{Translation}->{'Create a new calendar appointment linked to this ticket'} = 'Erstellt einen neuen Termin in einem Kalender, welcher direkt mit diesem Ticket verknüpft ist';
    $Self->{Translation}->{'Create new appointment.'} = 'Einen neuen Termin erstellen';
    $Self->{Translation}->{'Defines an icon with link to the google map page of the current location in appointment edit screen.'} =
        '';
    $Self->{Translation}->{'Defines the event object types that will be handled via AdminNotificationEvent.'} =
        '';
    $Self->{Translation}->{'Defines the list of params that can be passed to ticket search function.'} =
        '';
    $Self->{Translation}->{'Defines the ticket appointment type backend for ticket dynamic field date time.'} =
        '';
    $Self->{Translation}->{'Defines the ticket appointment type backend for ticket escalation time.'} =
        '';
    $Self->{Translation}->{'Defines the ticket appointment type backend for ticket pending time.'} =
        '';
    $Self->{Translation}->{'Defines the ticket plugin for calendar appointments.'} = 'Legt das Ticket-Plugin für Termine fest.';
    $Self->{Translation}->{'DynamicField_%s'} = '';
    $Self->{Translation}->{'Edit appointment'} = 'Termin bearbeiten';
    $Self->{Translation}->{'First response time'} = '';
    $Self->{Translation}->{'Import appointments screen.'} = '';
    $Self->{Translation}->{'Links appointments and tickets with a "Normal" type link.'} = 'Verknüpft Termine und Tickets mit einem Link vom Typ "Normal".';
    $Self->{Translation}->{'List of all appointment events to be displayed in the GUI.'} = 'Liste aller Termin-Events, welche in der GUI angezeigt werden.';
    $Self->{Translation}->{'List of colors in hexadecimal RGB which will be available for selection during calendar creation. Make sure the colors are dark enough so white text can be overlayed on them.'} =
        'Liste an Farben in Hexadezimal RGB, welche verschiedenen Benutzerkalendern zugewiesen werden. Stellen Sie sicher, dass die Farben dunkel genug sind, um weißen Text darauf darzustellen. Sofern die Anzahl der Kalender die Anzahl der verfügbaren Farben überschreitet, wird diese Liste erneut von Anfang an genutzt.';
    $Self->{Translation}->{'Manage different calendars.'} = 'Verschiedene Kalender verwalten';
    $Self->{Translation}->{'Maximum number of active calendars in overview screens. Please note that large number of active calendars can have a performance impact on your server by making too much simultaneous calls.'} =
        'Maximale Anzahl an aktiven Kalendern in der Kalenderübersicht oder Resourcenübersicht. Bitte beachten Sie, dass sich zuviele gleichzeitig aktive Kalender aufgrund vieler gleichzeitiger Anfragen auf die Performance des Systems auswirken kann.';
    $Self->{Translation}->{'OTRS doesn\'t support recurring Appointments without end date or number of iterrations. During import process, it might happen that ICS file contains such Appointments. Instead, system creates all Appointments in the past, plus Appointments for the next n months(120 months/10 years by default).'} =
        'OTRS unterstützt keine wiederholenden Termine oder Enddatum oder Anzahl an Iterationen. Während Import-Prozessen kann es passieren, dass ICS-Dateien solche Termine enthalten. OTRS wird stattdessen alle vergangenen Termine sowie alle Termine der kommenden n Monate (120 Monate / 10 Jahre standardmäßig) erstellen.';
    $Self->{Translation}->{'Overview of all appointments.'} = 'Übersicht aller Termine';
    $Self->{Translation}->{'Pending time'} = '';
    $Self->{Translation}->{'Plugin search'} = 'Pluginsuche';
    $Self->{Translation}->{'Plugin search module for autocomplete.'} = 'Module zur Pluginsuche für die Autovervollständigung.';
    $Self->{Translation}->{'Resource Overview'} = 'Resourcenübersicht';
    $Self->{Translation}->{'Resource Overview (OTRS Business Solution™)'} = 'Resourcenübersicht (OTRS Business Solution™)';
    $Self->{Translation}->{'Shows a link in the menu for creating a calendar appointment linked to the ticket directly from the ticket zoom view of the agent interface. Additional access control to show or not show this link can be done by using Key "Group" and Content like "rw:group1;move_into:group2". To cluster menu items use for Key "ClusterName" and for the Content any name you want to see in the UI. Use "ClusterPriority" to configure the order of a certain cluster within the toolbar.'} =
        'Zeigt einen Link im Menü der TicketZoom-Ansicht im Agenten-Interface an, um Termine zu erstellen, welche direkt mit dem entsprechenden Ticket verknüpft sind. Zusätzliche Zugriffskontrolle, ob der Menüpunkt angezeigt wird oder nicht, kann mit dem Schlüssel "Gruppe" und "Inhalt" wie z.B. ("rw:group1;move_into:group2") erreicht werden. Um Menüeinträge zu gruppieren, verwenden Sie den Schlüssel "ClusterName" und im Inhalt den Namen, welchen Sie in der Ansicht verwenden möchten. Verwenden Sie "ClusterPriority" um die Reihenfolge in der jeweiligen Gruppierung zu beeinflussen.';
    $Self->{Translation}->{'Solution time'} = '';
    $Self->{Translation}->{'TicketDynamicFieldUpdate_.*'} = '';
    $Self->{Translation}->{'Triggers add or update of automatic calendar appointments based on certain ticket times.'} =
        '';
    $Self->{Translation}->{'Update time'} = '';
}

1;
