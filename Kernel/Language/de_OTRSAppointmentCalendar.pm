# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
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

    # Template: AAANotification
    $Self->{Translation}->{'Appointment reminder notification'} = 'Benachrichtigung über Erreichen der Erinnerungszeit von Terminen';
    $Self->{Translation}->{'You will receive a notification each time a reminder time is reached for one of your appointments.'} =
        'Sie erhalten immer dann eine Benachrichtigung, wenn der Benachrichtigungszeitpunkt für einen Ihrer Termine erreicht wurde.';

    # Template: AdminAppointmentNotificationEvent
    $Self->{Translation}->{'Appointment Notification Management'} = 'Verwaltung von Terminbenachrichtigungen';
    $Self->{Translation}->{'Here you can upload a configuration file to import appointment notifications to your system. The file needs to be in .yml format as exported by the appointment notification module.'} =
        'Hier können Sie eine Konfigurationsdatei hochladen, mit der Terminbenachrichtigungen im System importiert werden können. Die Datei muss im .yml-Format vorliegen, so wie sie auch vom Terminbenachrichtigungsmodul exportiert wird.';
    $Self->{Translation}->{'Here you can choose which events will trigger this notification. An additional appointment filter can be applied below to only send for appointments with certain criteria.'} =
        'Hier können Sie auswählen, welche Ereignisse diese Benachrichtigung auslösen. Ein zusätzlicher Terminfilter kann weiter unten eingestellt werden, um die Benachrichtigungen nur für Termine mit bestimmten Merkmalen zu versenden.';
    $Self->{Translation}->{'Appointment Filter'} = 'Terminfilter';
    $Self->{Translation}->{'Team'} = 'Team';
    $Self->{Translation}->{'Resource'} = 'Resource';
    $Self->{Translation}->{'Notify user just once per day about a single appointment using a selected transport.'} =
        'Nur einmal am Tag pro Termin und Benachrichtigungs-Transportmethode versenden.';
    $Self->{Translation}->{'Notifications are sent to an agent.'} = 'Benachrichtigungen wurden an einen Agenten versendet.';
    $Self->{Translation}->{'To get the first 20 character of the appointment title.'} = 'Die ersten 20 Zeichen des Terminbetreffs.';
    $Self->{Translation}->{'To get the appointment attribute'} = 'Die Termin-Attribute';
    $Self->{Translation}->{'To get the calendar attribute'} = 'Die Kalender-Attribute';

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
    $Self->{Translation}->{'Import Appointments'} = 'Termine importieren';
    $Self->{Translation}->{'Calendar Import'} = 'Kalender importieren';
    $Self->{Translation}->{'Here you can upload a configuration file to import a calendar to your system. The file needs to be in .yml format as exported by calendar management module.'} =
        'Hier können Sie eine Konfigurationsdatei hochladen, um einen Kalender in Ihr System zu importieren. Die Datei muss im .yml Format vorliegen, so wie sie in der Kalenderverwaltung exportiert wurde.';
    $Self->{Translation}->{'Upload calendar configuration'} = 'Kalender-Konfiguration hochladen';
    $Self->{Translation}->{'Import Calendar'} = 'Kalender importieren';
    $Self->{Translation}->{'Filter for calendars'} = 'Filter für Kalender';
    $Self->{Translation}->{'Depending on the group field, the system will allow users the access to the calendar according to their permission level.'} =
        'Abhängig von der Gruppenzugehörigkeit wird das System Benutzern den Zugriff anhand ihrer Berechtigungen erlauben bzw. verweigern.';
    $Self->{Translation}->{'Read only: users can see and export all appointments in the calendar.'} =
        'RO: Benutzer können Termine sehen und Kalender exportieren.';
    $Self->{Translation}->{'Move into: users can modify appointments in the calendar, but without changing the calendar selection.'} =
        'Verschieben in: Benutzer können Termine innerhalb eines Kalenders bearbeiten, diese jedoch nicht in andere Kalender verschieben.';
    $Self->{Translation}->{'Create: users can create and delete appointments in the calendar.'} =
        'Erstellen: Benutzer können Termine im Kalender erstellen und löschen.';
    $Self->{Translation}->{'Read/write: users can manage the calendar itself.'} = 'rw: Benutzer können die Kalender an sich verwalten.';
    $Self->{Translation}->{'URL'} = 'URL';
    $Self->{Translation}->{'Export calendar'} = 'Kalender exportieren';
    $Self->{Translation}->{'Download calendar'} = 'Kalender herunterladen';
    $Self->{Translation}->{'Copy public calendar URL'} = 'Öffentliche Kalender URL kopieren';
    $Self->{Translation}->{'Calendar name'} = 'Kalendername';
    $Self->{Translation}->{'Calendar with same name already exists.'} = 'Ein Kalender mit gleichem Namen existiert bereits.';
    $Self->{Translation}->{'Permission group'} = 'Berechtigungsgruppe';
    $Self->{Translation}->{'Ticket Appointments'} = 'Ticket Termine';
    $Self->{Translation}->{'Rule'} = 'Regel';
    $Self->{Translation}->{'Use options below to narrow down for which tickets appointments will be automatically created.'} =
        'Verwenden Sie die folgenden Optionen,  um einzugrenzen welche Ticket-Termine automatisch erstellt werden sollen.';
    $Self->{Translation}->{'Please select a valid queue.'} = 'Bitte wählen Sie eine gültige Queue aus.';
    $Self->{Translation}->{'Search attributes'} = 'Suchattribute';
    $Self->{Translation}->{'Define rules for creating automatic appointments in this calendar based on ticket data.'} =
        'Definition von Regeln, um automatisch Termine in diesem Kalender zu erstellen, welche auf Ticketdaten basieren.';
    $Self->{Translation}->{'Add Rule'} = 'Regel hinzufügen';
    $Self->{Translation}->{'More'} = 'Mehr';
    $Self->{Translation}->{'Less'} = 'Weniger';

    # Template: AgentAppointmentCalendarOverview
    $Self->{Translation}->{'Add new Appointment'} = 'Einen neuen Termin anlegen';
    $Self->{Translation}->{'Calendars'} = 'Kalender';
    $Self->{Translation}->{'Too many active calendars'} = 'Zuviele aktive Kalender';
    $Self->{Translation}->{'Please either turn some off first or increase the limit in configuration.'} =
        'Bitte deaktivieren Sie zuerst einige oder erhöhen Sie das Limit in der Konfiguration.';
    $Self->{Translation}->{'Week'} = 'Woche';
    $Self->{Translation}->{'Timeline Month'} = 'Zeitstrahl Monat';
    $Self->{Translation}->{'Timeline Week'} = 'Zeitstrahl Woche';
    $Self->{Translation}->{'Timeline Day'} = 'Zeitstrahl Tag';
    $Self->{Translation}->{'Jump'} = 'Springen';
    $Self->{Translation}->{'Dismiss'} = 'Verwerfen';
    $Self->{Translation}->{'Show'} = 'Anzeigen';
    $Self->{Translation}->{'Basic information'} = 'Grundlegende Informationen';
    $Self->{Translation}->{'Date/Time'} = 'Datum/Zeit';

    # Template: AgentAppointmentEdit
    $Self->{Translation}->{'Please set this to value before End date.'} = 'Bitte setzen Sie einen Wert vor dem Enddatum.';
    $Self->{Translation}->{'Please set this to value after Start date.'} = 'Bitte setzen Sie einen Wert nach dem Startdatum.';
    $Self->{Translation}->{'This an occurrence of a repeating appointment.'} = 'Dies ist ein Vorkommnis eines sich wiederholenden Termins.';
    $Self->{Translation}->{'Click here to see the parent appointment.'} = 'Klicken Sie hier, um den Eltern-Termin anzuzeigen.';
    $Self->{Translation}->{'Click here to edit the parent appointment.'} = 'Klicken Sie hier, um den Eltern-Termin zu bearbeiten.';
    $Self->{Translation}->{'Frequency'} = 'Frequenz';
    $Self->{Translation}->{'Every'} = 'Alle';
    $Self->{Translation}->{'Relative point of time'} = 'Relativer Zeitpunkt';
    $Self->{Translation}->{'Are you sure you want to delete this appointment? This operation cannot be undone.'} =
        'Möchten Sie diesen Termin wirklich löschen? Diese Änderung kann nicht rückgängig gemacht werden.';

    # Template: AgentAppointmentImport
    $Self->{Translation}->{'Appointment Import'} = 'Termine importieren';
    $Self->{Translation}->{'Uploaded file must be in valid iCal format (.ics).'} = 'Die hochgeladene Datei muss in einem gültigen iCal-Format (.ics) vorliegen.';
    $Self->{Translation}->{'If desired Calendar is not listed here, please make sure that you have at least \'create\' permissions.'} =
        'Sollte ein gewünschter Kalender hier nicht aufgelistet sein, stellen Sie bitte sicher, dass Sie mindestens die Berechtigung zum Erstellen von Kalendern besitzen.';
    $Self->{Translation}->{'Update existing appointments?'} = 'Existierende Termine überschreiben?';
    $Self->{Translation}->{'All existing appointments in the calendar with same UniqueID will be overwritten.'} =
        'Alle existierenden Termine mit der selben "UniqueID" im entsprechenden Kalender werden überschrieben.';
    $Self->{Translation}->{'Upload calendar'} = 'Kalender hochladen';
    $Self->{Translation}->{'Import appointments'} = 'Termine importieren';

    # Template: AgentDashboardAppointmentCalendar
    $Self->{Translation}->{'New Appointment'} = 'Neuer Termin';
    $Self->{Translation}->{'Soon'} = 'Demnächst';
    $Self->{Translation}->{'5 days'} = '5 Tage';

    # Perl Module: Kernel/Modules/AdminAppointmentNotificationEvent.pm
    $Self->{Translation}->{'Notification name already exists!'} = 'Benachrichtigungsname existiert bereits!';
    $Self->{Translation}->{'Agent (resources), who are selected within the appointment'} = 'Agenten (Resourcen), welche innerhalb des Termins ausgewählt wurden';
    $Self->{Translation}->{'All agents with (at least) read permission for the appointment (calendar)'} =
        'Alle Agenten mit (mindestens) Leseberechtigung für den Termin(kalender)';
    $Self->{Translation}->{'All agents with write permission for the appointment (calendar)'} =
        'Alle Agenten mit Schreibberechtigung für den Termin(kalender)';

    # Perl Module: Kernel/Modules/AgentAppointmentCalendarManage.pm
    $Self->{Translation}->{'System was unable to create Calendar!'} = 'Das System konnten den Kalender nicht erstellen!';
    $Self->{Translation}->{'No CalendarID!'} = 'Keine CalenderID!';
    $Self->{Translation}->{'You have no access to this calendar!'} = 'Sie haben keine Zugriffsberechtigung auf diesen Kalender!';
    $Self->{Translation}->{'Edit Calendar'} = 'Kalender bearbeiten';
    $Self->{Translation}->{'Error updating the calendar!'} = 'Fehler beim Aktualisieren des Kalenders!';
    $Self->{Translation}->{'Couldn\'t read calendar configuration file.'} = 'Kalender Konfigurationsdatei konnte nicht gelesen werden.';
    $Self->{Translation}->{'Please make sure your file is valid.'} = 'Bitte stellen Sie sicher, dass die Datei gültig ist.';
    $Self->{Translation}->{'Could not import the calendar!'} = 'Kalender konnte nicht importiert werden!';
    $Self->{Translation}->{'Calendar imported!'} = 'Kalender wurde importiert!';
    $Self->{Translation}->{'Need CalendarID!'} = 'CalendarID wird benötigt!';
    $Self->{Translation}->{'Could not retrieve data for given CalendarID'} = 'Daten konnten nicht abgerufen werden für CalendarID';
    $Self->{Translation}->{'Successfully imported %s appointment(s) to calendar %s.'} = 'Es wurde(n) %s Termin(e) erfolgreich in Kalender %s importiert.';
    $Self->{Translation}->{'+5 minutes'} = '+5 Minuten';
    $Self->{Translation}->{'+15 minutes'} = '+15 Minuten';
    $Self->{Translation}->{'+30 minutes'} = '+30 Minuten';
    $Self->{Translation}->{'+1 hour'} = '+1 Stunde';

    # Perl Module: Kernel/Modules/AgentAppointmentCalendarOverview.pm
    $Self->{Translation}->{'All appointments'} = 'Alle Termine';
    $Self->{Translation}->{'Appointments assigned to me'} = 'Mir zugewiesene Termine';
    $Self->{Translation}->{'Showing only appointments assigned to you! Change settings'} = 'Es werden nur Termine angezeigt, die Ihnen zugewiesen sind! Einstellungen ändern';

    # Perl Module: Kernel/Modules/AgentAppointmentEdit.pm
    $Self->{Translation}->{'Appointment not found!'} = 'Termin wurde nicht gefunden!';
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
    $Self->{Translation}->{'Cannot delete ticket appointment!'} = 'Ticket-Termin konnte nicht gelöscht werden!';
    $Self->{Translation}->{'No permissions!'} = 'Keine Berechtigung!';

    # Perl Module: Kernel/Modules/AgentAppointmentImport.pm
    $Self->{Translation}->{'No permissions'} = 'Keine Berechtigung';
    $Self->{Translation}->{'System was unable to import file!'} = 'Das System konnte die Datei nicht importieren!';
    $Self->{Translation}->{'Please check the log for more information.'} = 'Bitte prüfen Sie das Systemprotokoll für weitere Informationen.';

    # Perl Module: Kernel/Modules/AgentAppointmentList.pm
    $Self->{Translation}->{'+%d more'} = '+%d mehr';

    # Perl Module: Kernel/Modules/PublicCalendar.pm
    $Self->{Translation}->{'No %s!'} = 'Kein %s!';
    $Self->{Translation}->{'No such user!'} = 'Kein Benutzer gefunden!';
    $Self->{Translation}->{'Invalid calendar!'} = 'Ungültiger Kalender!';
    $Self->{Translation}->{'Invalid URL!'} = 'Ungültige URL!';
    $Self->{Translation}->{'There was an error exporting the calendar!'} = 'Es ist ein Fehler beim Exportieren des Kalenders aufgetreten!';

    # Perl Module: Kernel/Output/HTML/Dashboard/AppointmentCalendar.pm
    $Self->{Translation}->{'Refresh (minutes)'} = 'Aktualisierung (Minuten)';

    # SysConfig
    $Self->{Translation}->{'Appointment Calendar overview page.'} = 'Terminkalender Übersicht';
    $Self->{Translation}->{'Appointment Notifications'} = 'Terminbenachrichtigungen';
    $Self->{Translation}->{'Appointment calendar event module that prepares notification entries for appointments.'} =
        'Terminkalender Event-Modul, welches Benachrichtigungseinträge für Termine vorbereitet.';
    $Self->{Translation}->{'Appointment calendar event module that updates the ticket with data from ticket appointment.'} =
        'Termin-Kalender Eventmodul, welches Tickets mit Daten aus Ticket-Terminen aktualisiert.';
    $Self->{Translation}->{'Appointment edit screen.'} = 'Terminbearbeitungsansicht';
    $Self->{Translation}->{'Appointment list'} = 'Terminliste';
    $Self->{Translation}->{'Appointment list.'} = 'Terminliste.';
    $Self->{Translation}->{'Appointment notifications'} = 'Terminbenachrichtigungen';
    $Self->{Translation}->{'Appointments'} = 'Termine';
    $Self->{Translation}->{'Calendar manage screen.'} = 'Kalenderverwaltungsansicht';
    $Self->{Translation}->{'Choose for which kind of appointment changes you want to receive notifications.'} =
        'Für welche Veränderungen an Terminen möchten Sie Benachrichtigungen erhalten?';
    $Self->{Translation}->{'Create a new calendar appointment linked to this ticket'} = 'Erstellt einen neuen Termin in einem Kalender, welcher direkt mit diesem Ticket verknüpft ist';
    $Self->{Translation}->{'Create and manage appointment notifications.'} = 'Terminbenachrichtigungen erstellen und verwalten.';
    $Self->{Translation}->{'Create new appointment.'} = 'Einen neuen Termin erstellen';
    $Self->{Translation}->{'Define which columns are shown in the linked appointment widget (LinkObject::ViewMode = "complex"). Possible settings: 0 = Disabled, 1 = Available, 2 = Enabled by default.'} =
        'Legt fest welche Spalten im Terminverknüpfungs-Widget angezeigt werden (LinkObject::ViewMode = "complex"). Mögliche Einstellungen: 0 = Deaktiviert, 1 = Verfügbar, 2 = Standardmäßig aktiviert.';
    $Self->{Translation}->{'Defines an icon with link to the google map page of the current location in appointment edit screen.'} =
        'Beschreibt ein Symbol mit Verknüpfung zur Google Maps Webseite mit dem aktuellen Standort als entsprechendes Ziel in der Terminbearbeitungs-Oberfläche.';
    $Self->{Translation}->{'Defines the event object types that will be handled via AdminAppointmentNotificationEvent.'} =
        'Legt die Event-Objekttypen fest, welche via AdminAppointmentNotificationEvent verarbeitet werden.';
    $Self->{Translation}->{'Defines the list of params that can be passed to ticket search function.'} =
        'Legt die Liste der Parameter fest, welche mit der Ticketsuchfunktion verwendet werden kann.';
    $Self->{Translation}->{'Defines the ticket appointment type backend for ticket dynamic field date time.'} =
        'Beschreibt den Ticket-Termin-Backend Typ für Datum/Uhrzeit durch dynamische Felder.';
    $Self->{Translation}->{'Defines the ticket appointment type backend for ticket escalation time.'} =
        'Beschreibt den Ticket-Termin-Backend Typ für Ticketeskalationen.';
    $Self->{Translation}->{'Defines the ticket appointment type backend for ticket pending time.'} =
        'Beschreibt den Ticket-Termin-Backend Typ für Ticketpendingzeiten.';
    $Self->{Translation}->{'Defines the ticket plugin for calendar appointments.'} = 'Legt das Ticket-Plugin für Termine fest.';
    $Self->{Translation}->{'DynamicField_%s'} = 'DynamicField_%s';
    $Self->{Translation}->{'Edit appointment'} = 'Termin bearbeiten';
    $Self->{Translation}->{'First response time'} = 'Zeit für erste Reaktion';
    $Self->{Translation}->{'Import appointments screen.'} = 'Termin-Import Oberfläche';
    $Self->{Translation}->{'Links appointments and tickets with a "Normal" type link.'} = 'Verknüpft Termine und Tickets mit einem Link vom Typ "Normal".';
    $Self->{Translation}->{'List of all appointment events to be displayed in the GUI.'} = 'Liste aller Termin-Events, welche in der GUI angezeigt werden.';
    $Self->{Translation}->{'List of all calendar events to be displayed in the GUI.'} = 'Liste aller Kalenderereignisse, welche in der grafischen Benutzeroberfläche angezeigt werden sollen.';
    $Self->{Translation}->{'List of colors in hexadecimal RGB which will be available for selection during calendar creation. Make sure the colors are dark enough so white text can be overlayed on them.'} =
        'Liste an Farben in Hexadezimal RGB, welche verschiedenen Benutzerkalendern zugewiesen werden. Stellen Sie sicher, dass die Farben dunkel genug sind, um weißen Text darauf darzustellen. Sofern die Anzahl der Kalender die Anzahl der verfügbaren Farben überschreitet, wird diese Liste erneut von Anfang an genutzt.';
    $Self->{Translation}->{'Manage different calendars.'} = 'Verschiedene Kalender verwalten';
    $Self->{Translation}->{'Maximum number of active calendars in overview screens. Please note that large number of active calendars can have a performance impact on your server by making too much simultaneous calls.'} =
        'Maximale Anzahl an aktiven Kalendern in der Kalenderübersicht oder Resourcenübersicht. Bitte beachten Sie, dass sich zuviele gleichzeitig aktive Kalender aufgrund vieler gleichzeitiger Anfragen auf die Performance des Systems auswirken kann.';
    $Self->{Translation}->{'OTRS doesn\'t support recurring Appointments without end date or number of iterations. During import process, it might happen that ICS file contains such Appointments. Instead, system creates all Appointments in the past, plus Appointments for the next n months (120 months/10 years by default).'} =
        'OTRS unterstützt keine wiederholenden Termine ohne Enddatum oder Anzahl der Durchläufe. Während des Importierungsprozesses kann es vorkommen, dass die entsprechende ICS-Datei solche Termin enthält. Stattdessen wird das System alle vergangenen Termine erstellen, sowie zusätzlich Termine für die kommenden n Monate (120 Monate / 10 Jahre standardmäßig).';
    $Self->{Translation}->{'Overview of all appointments.'} = 'Übersicht aller Termine';
    $Self->{Translation}->{'Pending time'} = 'Warten bis';
    $Self->{Translation}->{'Plugin search'} = 'Pluginsuche';
    $Self->{Translation}->{'Plugin search module for autocomplete.'} = 'Module zur Pluginsuche für die Autovervollständigung.';
    $Self->{Translation}->{'Public Calendar'} = 'Öffentlicher Kalender';
    $Self->{Translation}->{'Public calendar.'} = 'Öffentlicher Kalender';
    $Self->{Translation}->{'Resource Overview'} = 'Resourcenübersicht';
    $Self->{Translation}->{'Resource Overview (OTRS Business Solution™)'} = 'Resourcenübersicht (OTRS Business Solution™)';
    $Self->{Translation}->{'Shows a link in the menu for creating a calendar appointment linked to the ticket directly from the ticket zoom view of the agent interface. Additional access control to show or not show this link can be done by using Key "Group" and Content like "rw:group1;move_into:group2". To cluster menu items use for Key "ClusterName" and for the Content any name you want to see in the UI. Use "ClusterPriority" to configure the order of a certain cluster within the toolbar.'} =
        'Zeigt einen Link im Menü der TicketZoom-Ansicht im Agenten-Interface an, um Termine zu erstellen, welche direkt mit dem entsprechenden Ticket verknüpft sind. Zusätzliche Zugriffskontrolle, ob der Menüpunkt angezeigt wird oder nicht, kann mit dem Schlüssel "Gruppe" und "Inhalt" wie z.B. ("rw:group1;move_into:group2") erreicht werden. Um Menüeinträge zu gruppieren, verwenden Sie den Schlüssel "ClusterName" und im Inhalt den Namen, welchen Sie in der Ansicht verwenden möchten. Verwenden Sie "ClusterPriority" um die Reihenfolge in der jeweiligen Gruppierung zu beeinflussen.';
    $Self->{Translation}->{'Solution time'} = 'Lösungszeit';
    $Self->{Translation}->{'Transport selection for appointment notifications.'} = 'Transportauswahl für Terminbenachrichtigungen';
    $Self->{Translation}->{'Triggers add or update of automatic calendar appointments based on certain ticket times.'} =
        'Stößt das Hinzufügen oder Aktualisieren von automatischen Terminen an, basierend auf Ticketzeiten.';
    $Self->{Translation}->{'Update time'} = 'Aktualisierungszeit';

}

1;
