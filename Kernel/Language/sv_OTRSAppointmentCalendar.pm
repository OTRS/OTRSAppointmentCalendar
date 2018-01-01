# --
# Copyright (C) 2001-2018 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::sv_OTRSAppointmentCalendar;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    # Template: AAANotification
    $Self->{Translation}->{'Appointment reminder notification'} = 'Kalenderhändelsepåminnelse';
    $Self->{Translation}->{'You will receive a notification each time a reminder time is reached for one of your appointments.'} =
        'Du får en notifiering för varje påminnelsetid för dina kalenderhändelser. ';

    # Template: AdminAppointmentNotificationEvent
    $Self->{Translation}->{'Appointment Notification Management'} = 'Kalenderhändelsepåminnelsehantering';
    $Self->{Translation}->{'Here you can upload a configuration file to import appointment notifications to your system. The file needs to be in .yml format as exported by the appointment notification module.'} =
        'Du kan läsa in en konfigurationsfil med kalenderhändelsepåminnelser. Filen behöver vara på det  .yml-format som du får vid export från kalenderhändelsepåminnelse-vyn.';
    $Self->{Translation}->{'Here you can choose which events will trigger this notification. An additional appointment filter can be applied below to only send for appointments with certain criteria.'} =
        'Bestäm vilka händelser som aktiverar denna påminnelsenotifiering. Ytterligare filter kan appliceras för att endast skicka påminnelser för kalenderhändelser som uppfyller filterkriterierna. ';
    $Self->{Translation}->{'Appointment Filter'} = 'Kalenderhändelsfilter';
    $Self->{Translation}->{'Team'} = 'Grupp';
    $Self->{Translation}->{'Resource'} = 'Resurs';
    $Self->{Translation}->{'Notify user just once per day about a single appointment using a selected transport.'} =
        '';
    $Self->{Translation}->{'Notifications are sent to an agent.'} = 'Påminnelser skickas till handläggare.';
    $Self->{Translation}->{'To get the first 20 character of the appointment title.'} = '';
    $Self->{Translation}->{'To get the appointment attribute'} = '';
    $Self->{Translation}->{'To get the calendar attribute'} = '';

    # Template: AgentAppointmentAgendaOverview
    $Self->{Translation}->{'Agenda Overview'} = 'Dagordningsvy';
    $Self->{Translation}->{'Manage Calendars'} = 'Hantera kalendrar';
    $Self->{Translation}->{'Add Appointment'} = 'Lägg till händelse';
    $Self->{Translation}->{'Color'} = 'Färg';
    $Self->{Translation}->{'End date'} = 'Slutdatum';
    $Self->{Translation}->{'Repeat'} = 'Upprepa';
    $Self->{Translation}->{'No calendars found. Please add a calendar first by using Manage Calendars page.'} =
        'Hittar ingen kalender. Lägg till en kalender under Hantera kalendrar.';
    $Self->{Translation}->{'Appointment'} = 'Kalenderhändelse';
    $Self->{Translation}->{'This is a repeating appointment'} = 'Upprepad kalenderhändelse';
    $Self->{Translation}->{'Would you like to edit just this occurrence or all occurrences?'} =
        '';
    $Self->{Translation}->{'All occurrences'} = 'Alla förekomster';
    $Self->{Translation}->{'Just this occurrence'} = 'Endast denna händelse';

    # Template: AgentAppointmentCalendarManage
    $Self->{Translation}->{'Calendar Management'} = 'Kalenderhantering';
    $Self->{Translation}->{'Calendar Overview'} = 'Kalenderöversikt';
    $Self->{Translation}->{'Add new Calendar'} = 'Lägg till kalender';
    $Self->{Translation}->{'Add Calendar'} = 'Lägg till kalender';
    $Self->{Translation}->{'Import Appointments'} = 'Importera kalenderhändelser';
    $Self->{Translation}->{'Calendar Import'} = 'Importera kalendrar ';
    $Self->{Translation}->{'Here you can upload a configuration file to import a calendar to your system. The file needs to be in .yml format as exported by calendar management module.'} =
        '';
    $Self->{Translation}->{'Upload calendar configuration'} = 'Läs in kalenderkonfiguration';
    $Self->{Translation}->{'Import Calendar'} = 'Importera kalender';
    $Self->{Translation}->{'Filter for calendars'} = 'Kalenderfilter';
    $Self->{Translation}->{'Depending on the group field, the system will allow users the access to the calendar according to their permission level.'} =
        '';
    $Self->{Translation}->{'Read only: users can see and export all appointments in the calendar.'} =
        '';
    $Self->{Translation}->{'Move into: users can modify appointments in the calendar, but without changing the calendar selection.'} =
        '';
    $Self->{Translation}->{'Create: users can create and delete appointments in the calendar.'} =
        '';
    $Self->{Translation}->{'Read/write: users can manage the calendar itself.'} = '';
    $Self->{Translation}->{'URL'} = 'URL';
    $Self->{Translation}->{'Export calendar'} = 'Exportera kalendern';
    $Self->{Translation}->{'Download calendar'} = 'Hämta kalendern';
    $Self->{Translation}->{'Copy public calendar URL'} = 'Kopiera kalenderns publika URL';
    $Self->{Translation}->{'Calendar name'} = 'Kalendernamn';
    $Self->{Translation}->{'Calendar with same name already exists.'} = '';
    $Self->{Translation}->{'Permission group'} = '';
    $Self->{Translation}->{'Ticket Appointments'} = '';
    $Self->{Translation}->{'Rule'} = 'Regel';
    $Self->{Translation}->{'Use options below to narrow down for which tickets appointments will be automatically created.'} =
        '';
    $Self->{Translation}->{'Please select a valid queue.'} = '';
    $Self->{Translation}->{'Search attributes'} = '';
    $Self->{Translation}->{'Define rules for creating automatic appointments in this calendar based on ticket data.'} =
        '';
    $Self->{Translation}->{'Add Rule'} = 'Lägg till regel';
    $Self->{Translation}->{'More'} = 'Mer';
    $Self->{Translation}->{'Less'} = 'Mindre';

    # Template: AgentAppointmentCalendarOverview
    $Self->{Translation}->{'Add new Appointment'} = 'Lägg till ny kalenderhändelse';
    $Self->{Translation}->{'Calendars'} = 'Kalendrar';
    $Self->{Translation}->{'Too many active calendars'} = 'För många aktiva kalendrar';
    $Self->{Translation}->{'Please either turn some off first or increase the limit in configuration.'} =
        '';
    $Self->{Translation}->{'Week'} = 'Vecka';
    $Self->{Translation}->{'Timeline Month'} = 'Månadsvy';
    $Self->{Translation}->{'Timeline Week'} = 'Veckovy';
    $Self->{Translation}->{'Timeline Day'} = 'Dagsvy';
    $Self->{Translation}->{'Jump'} = 'Hoppa';
    $Self->{Translation}->{'Dismiss'} = 'Avfärda';
    $Self->{Translation}->{'Show'} = 'Visa';
    $Self->{Translation}->{'Basic information'} = '';
    $Self->{Translation}->{'Date/Time'} = 'Datum/tid';

    # Template: AgentAppointmentEdit
    $Self->{Translation}->{'Please set this to value before End date.'} = '';
    $Self->{Translation}->{'Please set this to value after Start date.'} = '';
    $Self->{Translation}->{'This an occurrence of a repeating appointment.'} = '';
    $Self->{Translation}->{'Click here to see the parent appointment.'} = '';
    $Self->{Translation}->{'Click here to edit the parent appointment.'} = '';
    $Self->{Translation}->{'Frequency'} = '';
    $Self->{Translation}->{'Every'} = '';
    $Self->{Translation}->{'Relative point of time'} = '';
    $Self->{Translation}->{'Are you sure you want to delete this appointment? This operation cannot be undone.'} =
        '';

    # Template: AgentAppointmentImport
    $Self->{Translation}->{'Appointment Import'} = 'Kalenderhändelseimport';
    $Self->{Translation}->{'Uploaded file must be in valid iCal format (.ics).'} = 'Inlästa filer måste vara iCal-filer (.ics).';
    $Self->{Translation}->{'If desired Calendar is not listed here, please make sure that you have at least \'create\' permissions.'} =
        '';
    $Self->{Translation}->{'Update existing appointments?'} = 'Uppdatera nuvarande kalenderhändelser?';
    $Self->{Translation}->{'All existing appointments in the calendar with same UniqueID will be overwritten.'} =
        'Alla nuvarande kalenderhändelser med samma ID skrivs över.';
    $Self->{Translation}->{'Upload calendar'} = 'Läs in en kalender';
    $Self->{Translation}->{'Import appointments'} = 'Importera kalenderhändelser';

    # Template: AgentDashboardAppointmentCalendar
    $Self->{Translation}->{'New Appointment'} = 'Ny kalenderhändelse';
    $Self->{Translation}->{'Soon'} = 'Snart';
    $Self->{Translation}->{'5 days'} = '5 dagar';

    # Perl Module: Kernel/Modules/AdminAppointmentNotificationEvent.pm
    $Self->{Translation}->{'Notification name already exists!'} = 'Påminnelsenamnet finns redan!';
    $Self->{Translation}->{'Agent (resources), who are selected within the appointment'} = '';
    $Self->{Translation}->{'All agents with (at least) read permission for the appointment (calendar)'} =
        'Alla handläggare med (åtminstone) läsrättigheter för kalenderhändelsen (kalendern)';
    $Self->{Translation}->{'All agents with write permission for the appointment (calendar)'} =
        'Alla handläggare med skrivrättigheter för kalenderhändelsen (kalendern)';

    # Perl Module: Kernel/Modules/AgentAppointmentCalendarManage.pm
    $Self->{Translation}->{'System was unable to create Calendar!'} = 'Kunde inte skapa kalendern!';
    $Self->{Translation}->{'No CalendarID!'} = 'Kalender-ID saknas!';
    $Self->{Translation}->{'You have no access to this calendar!'} = 'Du har ingen åtkomst till kalendern!';
    $Self->{Translation}->{'Edit Calendar'} = 'Redigera kalender';
    $Self->{Translation}->{'Error updating the calendar!'} = 'Kunde inte uppdatera kalendern!';
    $Self->{Translation}->{'Couldn\'t read calendar configuration file.'} = 'Kalenderkonfigurationsfilen kunde inte läsas.';
    $Self->{Translation}->{'Please make sure your file is valid.'} = '';
    $Self->{Translation}->{'Could not import the calendar!'} = 'Kunde inte importera kalendern!';
    $Self->{Translation}->{'Calendar imported!'} = 'Kalender importerad!';
    $Self->{Translation}->{'Need CalendarID!'} = 'Kalender-ID krävs!';
    $Self->{Translation}->{'Could not retrieve data for given CalendarID'} = 'Inga data hittades för kalender-ID:t';
    $Self->{Translation}->{'Successfully imported %s appointment(s) to calendar %s.'} = 'Lyckades importera %s kalenderhändelse(r) till kalender %s.';
    $Self->{Translation}->{'+5 minutes'} = '+5 minuter';
    $Self->{Translation}->{'+15 minutes'} = '+15 minuter';
    $Self->{Translation}->{'+30 minutes'} = '+30 minuter';
    $Self->{Translation}->{'+1 hour'} = '+1 timme';

    # Perl Module: Kernel/Modules/AgentAppointmentCalendarOverview.pm
    $Self->{Translation}->{'All appointments'} = 'Alla kalenderhändelser';
    $Self->{Translation}->{'Appointments assigned to me'} = 'Mina kalenderhändelser';
    $Self->{Translation}->{'Showing only appointments assigned to you! Change settings'} = '';

    # Perl Module: Kernel/Modules/AgentAppointmentEdit.pm
    $Self->{Translation}->{'Appointment not found!'} = '';
    $Self->{Translation}->{'Never'} = 'Aldrig';
    $Self->{Translation}->{'Every Day'} = 'Varje dag';
    $Self->{Translation}->{'Every Week'} = 'Varje vecka';
    $Self->{Translation}->{'Every Month'} = 'Varje månad';
    $Self->{Translation}->{'Every Year'} = 'Varje år';
    $Self->{Translation}->{'Custom'} = 'Anpassat';
    $Self->{Translation}->{'Daily'} = 'Daglig';
    $Self->{Translation}->{'Weekly'} = 'Veckovis';
    $Self->{Translation}->{'Monthly'} = 'Månadsvis';
    $Self->{Translation}->{'Yearly'} = 'Årlig';
    $Self->{Translation}->{'every'} = 'varje';
    $Self->{Translation}->{'for %s time(s)'} = '%s gång(er)';
    $Self->{Translation}->{'until ...'} = 'tills ...';
    $Self->{Translation}->{'for ... time(s)'} = '... gång(er)';
    $Self->{Translation}->{'until %s'} = 'tills %s';
    $Self->{Translation}->{'No notification'} = 'Ingen påminnelse';
    $Self->{Translation}->{'%s minute(s) before'} = '%s minut(er) innan';
    $Self->{Translation}->{'%s hour(s) before'} = '%s timme/timmar innan';
    $Self->{Translation}->{'%s day(s) before'} = '%s dag(ar) innan';
    $Self->{Translation}->{'%s week before'} = '%s vecka/veckor innan';
    $Self->{Translation}->{'before the appointment starts'} = 'innan händelsen';
    $Self->{Translation}->{'after the appointment has been started'} = 'efter händelsen börjat';
    $Self->{Translation}->{'before the appointment ends'} = 'innan händelsen slutar';
    $Self->{Translation}->{'after the appointment has been ended'} = 'efter händelsen har slutat';
    $Self->{Translation}->{'No permission!'} = 'Saknar rättigheter!';
    $Self->{Translation}->{'Cannot delete ticket appointment!'} = 'Kunde inte ta bort kalenderhändelsen!';
    $Self->{Translation}->{'No permissions!'} = 'Rättigheter saknas!';

    # Perl Module: Kernel/Modules/AgentAppointmentImport.pm
    $Self->{Translation}->{'No permissions'} = 'Rättigheter saknas';
    $Self->{Translation}->{'System was unable to import file!'} = 'Kunde inte importera filen!';
    $Self->{Translation}->{'Please check the log for more information.'} = '';

    # Perl Module: Kernel/Modules/AgentAppointmentList.pm
    $Self->{Translation}->{'+%d more'} = '+%d fler';

    # Perl Module: Kernel/Modules/PublicCalendar.pm
    $Self->{Translation}->{'No %s!'} = 'Inga %s!';
    $Self->{Translation}->{'No such user!'} = 'Okänd användare!';
    $Self->{Translation}->{'Invalid calendar!'} = 'Ogiltig kalender!';
    $Self->{Translation}->{'Invalid URL!'} = 'Ogiltig URL!';
    $Self->{Translation}->{'There was an error exporting the calendar!'} = 'Kalendern kunde inte exporteras!';

    # Perl Module: Kernel/Output/HTML/Dashboard/AppointmentCalendar.pm
    $Self->{Translation}->{'Refresh (minutes)'} = 'Förnya (minuter)';

    # SysConfig
    $Self->{Translation}->{'Appointment Calendar overview page.'} = 'Kalenderhändelseöversikt.';
    $Self->{Translation}->{'Appointment Notifications'} = 'Kalenderhändelsepåminnelser';
    $Self->{Translation}->{'Appointment calendar event module that prepares notification entries for appointments.'} =
        '';
    $Self->{Translation}->{'Appointment calendar event module that updates the ticket with data from ticket appointment.'} =
        '';
    $Self->{Translation}->{'Appointment edit screen.'} = 'Redigera kalenderhändelse-vy.';
    $Self->{Translation}->{'Appointment list'} = 'Kalenderhändelser';
    $Self->{Translation}->{'Appointment list.'} = 'Kalenderhändelser.';
    $Self->{Translation}->{'Appointment notifications'} = 'Kalenderhändelsepåminnelser';
    $Self->{Translation}->{'Appointments'} = 'Kalenderhändelser';
    $Self->{Translation}->{'Calendar manage screen.'} = 'Hantera kalendrar-vy.';
    $Self->{Translation}->{'Choose for which kind of appointment changes you want to receive notifications.'} =
        '';
    $Self->{Translation}->{'Create a new calendar appointment linked to this ticket'} = '';
    $Self->{Translation}->{'Create and manage appointment notifications.'} = '';
    $Self->{Translation}->{'Create new appointment.'} = 'Lägg till kalenderhändelse.';
    $Self->{Translation}->{'Define which columns are shown in the linked appointment widget (LinkObject::ViewMode = "complex"). Possible settings: 0 = Disabled, 1 = Available, 2 = Enabled by default.'} =
        '';
    $Self->{Translation}->{'Defines an icon with link to the google map page of the current location in appointment edit screen.'} =
        '';
    $Self->{Translation}->{'Defines the event object types that will be handled via AdminAppointmentNotificationEvent.'} =
        '';
    $Self->{Translation}->{'Defines the list of params that can be passed to ticket search function.'} =
        '';
    $Self->{Translation}->{'Defines the ticket appointment type backend for ticket dynamic field date time.'} =
        '';
    $Self->{Translation}->{'Defines the ticket appointment type backend for ticket escalation time.'} =
        '';
    $Self->{Translation}->{'Defines the ticket appointment type backend for ticket pending time.'} =
        '';
    $Self->{Translation}->{'Defines the ticket plugin for calendar appointments.'} = '';
    $Self->{Translation}->{'DynamicField_%s'} = '';
    $Self->{Translation}->{'Edit appointment'} = 'Redigera kalenderhändelse';
    $Self->{Translation}->{'First response time'} = '';
    $Self->{Translation}->{'Import appointments screen.'} = 'Importera kalenderhändelse-vy.';
    $Self->{Translation}->{'Links appointments and tickets with a "Normal" type link.'} = '';
    $Self->{Translation}->{'List of all appointment events to be displayed in the GUI.'} = '';
    $Self->{Translation}->{'List of all calendar events to be displayed in the GUI.'} = '';
    $Self->{Translation}->{'List of colors in hexadecimal RGB which will be available for selection during calendar creation. Make sure the colors are dark enough so white text can be overlayed on them.'} =
        '';
    $Self->{Translation}->{'Manage different calendars.'} = '';
    $Self->{Translation}->{'Maximum number of active calendars in overview screens. Please note that large number of active calendars can have a performance impact on your server by making too much simultaneous calls.'} =
        '';
    $Self->{Translation}->{'OTRS doesn\'t support recurring Appointments without end date or number of iterations. During import process, it might happen that ICS file contains such Appointments. Instead, system creates all Appointments in the past, plus Appointments for the next n months (120 months/10 years by default).'} =
        '';
    $Self->{Translation}->{'Overview of all appointments.'} = 'Kalenderhändelseöversikt.';
    $Self->{Translation}->{'Pending time'} = '';
    $Self->{Translation}->{'Plugin search'} = '';
    $Self->{Translation}->{'Plugin search module for autocomplete.'} = '';
    $Self->{Translation}->{'Public Calendar'} = 'Öppen kalender';
    $Self->{Translation}->{'Public calendar.'} = 'Öppen kalender.';
    $Self->{Translation}->{'Resource Overview'} = 'Resursöversikt';
    $Self->{Translation}->{'Resource Overview (OTRS Business Solution™)'} = '';
    $Self->{Translation}->{'Shows a link in the menu for creating a calendar appointment linked to the ticket directly from the ticket zoom view of the agent interface. Additional access control to show or not show this link can be done by using Key "Group" and Content like "rw:group1;move_into:group2". To cluster menu items use for Key "ClusterName" and for the Content any name you want to see in the UI. Use "ClusterPriority" to configure the order of a certain cluster within the toolbar.'} =
        '';
    $Self->{Translation}->{'Solution time'} = '';
    $Self->{Translation}->{'Transport selection for appointment notifications.'} = '';
    $Self->{Translation}->{'Triggers add or update of automatic calendar appointments based on certain ticket times.'} =
        '';
    $Self->{Translation}->{'Update time'} = '';

}

1;
