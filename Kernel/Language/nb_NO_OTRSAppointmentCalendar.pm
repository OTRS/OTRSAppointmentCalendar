# --
# Copyright (C) 2001-2019 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Kernel::Language::nb_NO_OTRSAppointmentCalendar;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    # Template: AAANotification
    $Self->{Translation}->{'Appointment reminder notification'} = 'Varsel med påminnelse om avtale';
    $Self->{Translation}->{'You will receive a notification each time a reminder time is reached for one of your appointments.'} =
        'Du vil motta en varsel hver gang påminnelsestidspunktet nåes for en av dine avtaler.';

    # Template: AdminAppointmentNotificationEvent
    $Self->{Translation}->{'Appointment Notification Management'} = 'Administrer varsler om avtale';
    $Self->{Translation}->{'Here you can upload a configuration file to import appointment notifications to your system. The file needs to be in .yml format as exported by the appointment notification module.'} =
        '';
    $Self->{Translation}->{'Here you can choose which events will trigger this notification. An additional appointment filter can be applied below to only send for appointments with certain criteria.'} =
        '';
    $Self->{Translation}->{'Appointment Filter'} = 'Avtalefilter';
    $Self->{Translation}->{'Team'} = 'Gruppe';
    $Self->{Translation}->{'Resource'} = 'Ressurs';
    $Self->{Translation}->{'Notify user just once per day about a single appointment using a selected transport.'} =
        '';
    $Self->{Translation}->{'Notifications are sent to an agent.'} = 'Varslinger sendes til en saksbehandler.';
    $Self->{Translation}->{'To get the first 20 character of the appointment title.'} = 'For å hente de første 20 tegnene i avtaleoverskriften.';
    $Self->{Translation}->{'To get the appointment attribute'} = 'For å hente avtaleattributtet';
    $Self->{Translation}->{'To get the calendar attribute'} = 'For å hente kalenderattributtet';

    # Template: AgentAppointmentAgendaOverview
    $Self->{Translation}->{'Agenda Overview'} = 'Agendaoversikt';
    $Self->{Translation}->{'Manage Calendars'} = 'Kalenderadministrasjon';
    $Self->{Translation}->{'Add Appointment'} = 'Legg til avtale';
    $Self->{Translation}->{'Color'} = 'Farge';
    $Self->{Translation}->{'End date'} = 'Sluttdato';
    $Self->{Translation}->{'Repeat'} = 'Gjenta';
    $Self->{Translation}->{'No calendars found. Please add a calendar first by using Manage Calendars page.'} =
        'Ingen kalendere funnet. Vær vennlig å legge til en kalender først ved å benytte siden for kalenderadministrasjon.';
    $Self->{Translation}->{'Appointment'} = 'Avtale';
    $Self->{Translation}->{'This is a repeating appointment'} = 'Dette er en gjentagende avtale';
    $Self->{Translation}->{'Would you like to edit just this occurrence or all occurrences?'} =
        'Ønsker du kun å redigere denne avtalen eller alle forekomstene? ';
    $Self->{Translation}->{'All occurrences'} = 'Alle forekomster';
    $Self->{Translation}->{'Just this occurrence'} = 'Bare denne avtalen';

    # Template: AgentAppointmentCalendarManage
    $Self->{Translation}->{'Calendar Management'} = 'Kalenderadministrasjon';
    $Self->{Translation}->{'Calendar Overview'} = 'Kalenderoversikt';
    $Self->{Translation}->{'Add new Calendar'} = 'Legg til ny kalender';
    $Self->{Translation}->{'Add Calendar'} = 'Legg til kalender';
    $Self->{Translation}->{'Import Appointments'} = 'Importer avtaler';
    $Self->{Translation}->{'Calendar Import'} = 'Kalenderimport';
    $Self->{Translation}->{'Here you can upload a configuration file to import a calendar to your system. The file needs to be in .yml format as exported by calendar management module.'} =
        '';
    $Self->{Translation}->{'Upload calendar configuration'} = 'Last opp kalenderkonfigurasjon';
    $Self->{Translation}->{'Import Calendar'} = 'Importer kalender';
    $Self->{Translation}->{'Filter for calendars'} = 'Filter for kalendere';
    $Self->{Translation}->{'Depending on the group field, the system will allow users the access to the calendar according to their permission level.'} =
        '';
    $Self->{Translation}->{'Read only: users can see and export all appointments in the calendar.'} =
        'Skrivebeskyttet: brukere kan se og eksportere alle avtaler i kalenderen.';
    $Self->{Translation}->{'Move into: users can modify appointments in the calendar, but without changing the calendar selection.'} =
        '';
    $Self->{Translation}->{'Create: users can create and delete appointments in the calendar.'} =
        'Opprett: brukere kan opprette og slette avtaler i kalenderen.';
    $Self->{Translation}->{'Read/write: users can manage the calendar itself.'} = 'Les/skriv: brukere kan selv administrere kalenderen.';
    $Self->{Translation}->{'URL'} = 'URL';
    $Self->{Translation}->{'Export calendar'} = 'Eksporter kalender';
    $Self->{Translation}->{'Download calendar'} = 'Last ned kalender';
    $Self->{Translation}->{'Copy public calendar URL'} = 'Kopier offentlig kalender URL';
    $Self->{Translation}->{'Calendar name'} = 'Kalendernavn';
    $Self->{Translation}->{'Calendar with same name already exists.'} = 'Kalender med samme navn eksisterer allerede.';
    $Self->{Translation}->{'Permission group'} = 'Rettighetersgruppe';
    $Self->{Translation}->{'Ticket Appointments'} = 'Avtaler tilknyttet saker';
    $Self->{Translation}->{'Rule'} = 'Regel';
    $Self->{Translation}->{'Use options below to narrow down for which tickets appointments will be automatically created.'} =
        '';
    $Self->{Translation}->{'Please select a valid queue.'} = '';
    $Self->{Translation}->{'Search attributes'} = 'Søkeatributter';
    $Self->{Translation}->{'Define rules for creating automatic appointments in this calendar based on ticket data.'} =
        '';
    $Self->{Translation}->{'Add Rule'} = 'Legg til regel';
    $Self->{Translation}->{'More'} = 'Flere';
    $Self->{Translation}->{'Less'} = 'Færre';

    # Template: AgentAppointmentCalendarOverview
    $Self->{Translation}->{'Add new Appointment'} = 'Legg til ny avtale';
    $Self->{Translation}->{'Calendars'} = 'Kalendere';
    $Self->{Translation}->{'Too many active calendars'} = 'For mange aktive kalendere';
    $Self->{Translation}->{'Please either turn some off first or increase the limit in configuration.'} =
        '';
    $Self->{Translation}->{'Week'} = 'Uke';
    $Self->{Translation}->{'Timeline Month'} = '';
    $Self->{Translation}->{'Timeline Week'} = '';
    $Self->{Translation}->{'Timeline Day'} = '';
    $Self->{Translation}->{'Jump'} = 'Hopp';
    $Self->{Translation}->{'Dismiss'} = '';
    $Self->{Translation}->{'Show'} = 'Vis';
    $Self->{Translation}->{'Basic information'} = '';
    $Self->{Translation}->{'Date/Time'} = '';

    # Template: AgentAppointmentEdit
    $Self->{Translation}->{'Please set this to value before End date.'} = '';
    $Self->{Translation}->{'Please set this to value after Start date.'} = '';
    $Self->{Translation}->{'This an occurrence of a repeating appointment.'} = '';
    $Self->{Translation}->{'Click here to see the parent appointment.'} = '';
    $Self->{Translation}->{'Click here to edit the parent appointment.'} = '';
    $Self->{Translation}->{'Frequency'} = 'Frekvens';
    $Self->{Translation}->{'Every'} = 'Hver';
    $Self->{Translation}->{'Relative point of time'} = '';
    $Self->{Translation}->{'Are you sure you want to delete this appointment? This operation cannot be undone.'} =
        '';

    # Template: AgentAppointmentImport
    $Self->{Translation}->{'Appointment Import'} = 'Avtaleimport';
    $Self->{Translation}->{'Uploaded file must be in valid iCal format (.ics).'} = '';
    $Self->{Translation}->{'If desired Calendar is not listed here, please make sure that you have at least \'create\' permissions.'} =
        '';
    $Self->{Translation}->{'Update existing appointments?'} = '';
    $Self->{Translation}->{'All existing appointments in the calendar with same UniqueID will be overwritten.'} =
        '';
    $Self->{Translation}->{'Upload calendar'} = 'Last opp kalender';
    $Self->{Translation}->{'Import appointments'} = 'Importer avtaler';

    # Template: AgentDashboardAppointmentCalendar
    $Self->{Translation}->{'New Appointment'} = 'Ny avtale';
    $Self->{Translation}->{'Soon'} = 'Snart';
    $Self->{Translation}->{'5 days'} = '5 dager';

    # Perl Module: Kernel/Modules/AdminAppointmentNotificationEvent.pm
    $Self->{Translation}->{'Notification name already exists!'} = '';
    $Self->{Translation}->{'Agent (resources), who are selected within the appointment'} = '';
    $Self->{Translation}->{'All agents with (at least) read permission for the appointment (calendar)'} =
        '';
    $Self->{Translation}->{'All agents with write permission for the appointment (calendar)'} =
        '';

    # Perl Module: Kernel/Modules/AgentAppointmentCalendarManage.pm
    $Self->{Translation}->{'System was unable to create Calendar!'} = '';
    $Self->{Translation}->{'No CalendarID!'} = '';
    $Self->{Translation}->{'You have no access to this calendar!'} = '';
    $Self->{Translation}->{'Edit Calendar'} = '';
    $Self->{Translation}->{'Error updating the calendar!'} = '';
    $Self->{Translation}->{'Couldn\'t read calendar configuration file.'} = '';
    $Self->{Translation}->{'Please make sure your file is valid.'} = '';
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
    $Self->{Translation}->{'All appointments'} = '';
    $Self->{Translation}->{'Appointments assigned to me'} = '';
    $Self->{Translation}->{'Showing only appointments assigned to you! Change settings'} = '';

    # Perl Module: Kernel/Modules/AgentAppointmentEdit.pm
    $Self->{Translation}->{'Appointment not found!'} = '';
    $Self->{Translation}->{'Never'} = 'Aldri';
    $Self->{Translation}->{'Every Day'} = 'Hver dag';
    $Self->{Translation}->{'Every Week'} = 'Hver uke';
    $Self->{Translation}->{'Every Month'} = 'Hver måned';
    $Self->{Translation}->{'Every Year'} = 'Hvert år';
    $Self->{Translation}->{'Custom'} = 'Tilpasset';
    $Self->{Translation}->{'Daily'} = 'Daglig';
    $Self->{Translation}->{'Weekly'} = 'Ukentlig';
    $Self->{Translation}->{'Monthly'} = 'Månedlig';
    $Self->{Translation}->{'Yearly'} = 'Årlig';
    $Self->{Translation}->{'every'} = 'hver';
    $Self->{Translation}->{'for %s time(s)'} = '%s gang(er)';
    $Self->{Translation}->{'until ...'} = 'til';
    $Self->{Translation}->{'for ... time(s)'} = '... gang(er)';
    $Self->{Translation}->{'until %s'} = 'til %s';
    $Self->{Translation}->{'No notification'} = 'Ingen varsling';
    $Self->{Translation}->{'%s minute(s) before'} = '%s minutt(er) før';
    $Self->{Translation}->{'%s hour(s) before'} = '%s time(r) før';
    $Self->{Translation}->{'%s day(s) before'} = '%s dag(er) før';
    $Self->{Translation}->{'%s week before'} = '%s uke(r) før';
    $Self->{Translation}->{'before the appointment starts'} = 'før avtalen begynner';
    $Self->{Translation}->{'after the appointment has been started'} = 'etter at avtalen har begynt';
    $Self->{Translation}->{'before the appointment ends'} = 'før avtalen slutter';
    $Self->{Translation}->{'after the appointment has been ended'} = 'etter at avtalen er slutt';
    $Self->{Translation}->{'No permission!'} = '';
    $Self->{Translation}->{'Cannot delete ticket appointment!'} = '';
    $Self->{Translation}->{'No permissions!'} = '';

    # Perl Module: Kernel/Modules/AgentAppointmentImport.pm
    $Self->{Translation}->{'No permissions'} = 'Ingen rettigheter';
    $Self->{Translation}->{'System was unable to import file!'} = '';
    $Self->{Translation}->{'Please check the log for more information.'} = '';

    # Perl Module: Kernel/Modules/AgentAppointmentList.pm
    $Self->{Translation}->{'+%d more'} = '';

    # Perl Module: Kernel/Modules/PublicCalendar.pm
    $Self->{Translation}->{'No %s!'} = '';
    $Self->{Translation}->{'No such user!'} = '';
    $Self->{Translation}->{'Invalid calendar!'} = '';
    $Self->{Translation}->{'Invalid URL!'} = '';
    $Self->{Translation}->{'There was an error exporting the calendar!'} = '';

    # Perl Module: Kernel/Output/HTML/Dashboard/AppointmentCalendar.pm
    $Self->{Translation}->{'Refresh (minutes)'} = '';

    # SysConfig
    $Self->{Translation}->{'Appointment Calendar overview page.'} = 'Oversiktsside for avtalekalender.';
    $Self->{Translation}->{'Appointment Notifications'} = 'Varsler om avtale';
    $Self->{Translation}->{'Appointment calendar event module that prepares notification entries for appointments.'} =
        '';
    $Self->{Translation}->{'Appointment calendar event module that updates the ticket with data from ticket appointment.'} =
        '';
    $Self->{Translation}->{'Appointment edit screen.'} = 'Side for avtaleregistrering.';
    $Self->{Translation}->{'Appointment list'} = 'Avtaleliste';
    $Self->{Translation}->{'Appointment list.'} = 'Avtaleliste.';
    $Self->{Translation}->{'Appointment notifications'} = 'Varsler om avtale';
    $Self->{Translation}->{'Appointments'} = 'Avtaler';
    $Self->{Translation}->{'Calendar manage screen.'} = 'Side for kalenderadministrasjon';
    $Self->{Translation}->{'Choose for which kind of appointment changes you want to receive notifications.'} =
        'Velg hvilke typer avtaler som du vil motta varsler om.';
    $Self->{Translation}->{'Create a new calendar appointment linked to this ticket'} = 'Opprett en avtale somer koblet til denne saken';
    $Self->{Translation}->{'Create and manage appointment notifications.'} = 'Administrasjon av avtalevarslinger.';
    $Self->{Translation}->{'Create new appointment.'} = 'Opprett en ny avtale.';
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
    $Self->{Translation}->{'Edit appointment'} = 'Endre avtale';
    $Self->{Translation}->{'First response time'} = 'Første responstid';
    $Self->{Translation}->{'Import appointments screen.'} = 'Side for avtaleimport.';
    $Self->{Translation}->{'Links appointments and tickets with a "Normal" type link.'} = 'Koble avtaler og saker med en "normal" lenke.';
    $Self->{Translation}->{'List of all appointment events to be displayed in the GUI.'} = '';
    $Self->{Translation}->{'List of all calendar events to be displayed in the GUI.'} = '';
    $Self->{Translation}->{'List of colors in hexadecimal RGB which will be available for selection during calendar creation. Make sure the colors are dark enough so white text can be overlayed on them.'} =
        '';
    $Self->{Translation}->{'Manage different calendars.'} = 'Administrere ulike kalendere.';
    $Self->{Translation}->{'Maximum number of active calendars in overview screens. Please note that large number of active calendars can have a performance impact on your server by making too much simultaneous calls.'} =
        '';
    $Self->{Translation}->{'OTRS doesn\'t support recurring Appointments without end date or number of iterations. During import process, it might happen that ICS file contains such Appointments. Instead, system creates all Appointments in the past, plus Appointments for the next n months (120 months/10 years by default).'} =
        '';
    $Self->{Translation}->{'Overview of all appointments.'} = 'Oversikt over alle avtaler.';
    $Self->{Translation}->{'Pending time'} = 'Ventetidspunkt';
    $Self->{Translation}->{'Plugin search'} = '';
    $Self->{Translation}->{'Plugin search module for autocomplete.'} = '';
    $Self->{Translation}->{'Public Calendar'} = 'Offentlig kalender';
    $Self->{Translation}->{'Public calendar.'} = 'Offentlig kalender.';
    $Self->{Translation}->{'Resource Overview'} = 'Ressursoversikt';
    $Self->{Translation}->{'Resource Overview (OTRS Business Solution™)'} = 'Ressursoversikt (OTRS Business Solution™)';
    $Self->{Translation}->{'Shows a link in the menu for creating a calendar appointment linked to the ticket directly from the ticket zoom view of the agent interface. Additional access control to show or not show this link can be done by using Key "Group" and Content like "rw:group1;move_into:group2". To cluster menu items use for Key "ClusterName" and for the Content any name you want to see in the UI. Use "ClusterPriority" to configure the order of a certain cluster within the toolbar.'} =
        '';
    $Self->{Translation}->{'Solution time'} = 'Løsningstid';
    $Self->{Translation}->{'Transport selection for appointment notifications.'} = '';
    $Self->{Translation}->{'Triggers add or update of automatic calendar appointments based on certain ticket times.'} =
        '';
    $Self->{Translation}->{'Update time'} = 'Oppdateringstid';

}

1;
