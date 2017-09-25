# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::pl_OTRSAppointmentCalendar;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    # Template: AAANotification
    $Self->{Translation}->{'Appointment reminder notification'} = '';
    $Self->{Translation}->{'You will receive a notification each time a reminder time is reached for one of your appointments.'} =
        '';

    # Template: AdminAppointmentNotificationEvent
    $Self->{Translation}->{'Appointment Notification Management'} = 'Zarządzanie Powiadomieniami Wydarzeń';
    $Self->{Translation}->{'Here you can upload a configuration file to import appointment notifications to your system. The file needs to be in .yml format as exported by the appointment notification module.'} =
        '';
    $Self->{Translation}->{'Here you can choose which events will trigger this notification. An additional appointment filter can be applied below to only send for appointments with certain criteria.'} =
        '';
    $Self->{Translation}->{'Appointment Filter'} = 'Filtr wydarzeń';
    $Self->{Translation}->{'Team'} = 'Zespół';
    $Self->{Translation}->{'Resource'} = 'Zasoby';
    $Self->{Translation}->{'Notify user just once per day about a single appointment using a selected transport.'} =
        'Powiadamiaj użytkownika o pojedynczym wydarzeniu, przy użyciu wybranego transportu, tylko raz dziennie.';
    $Self->{Translation}->{'Notifications are sent to an agent.'} = 'Powiadomienia są wysyłane do agenta.';
    $Self->{Translation}->{'To get the first 20 character of the appointment title.'} = 'By pobrać pierwsze 20 znaków tytułu wydarzenia.';
    $Self->{Translation}->{'To get the appointment attribute'} = 'By pobrać atrybut wydarzenia';
    $Self->{Translation}->{'To get the calendar attribute'} = 'By pobrać atrybut kalendarza';

    # Template: AgentAppointmentAgendaOverview
    $Self->{Translation}->{'Agenda Overview'} = 'Przegląd terminarza';
    $Self->{Translation}->{'Manage Calendars'} = 'Zarządzaj kalendarzami';
    $Self->{Translation}->{'Add Appointment'} = 'Dodaj wydarzenie';
    $Self->{Translation}->{'Color'} = 'Kolor';
    $Self->{Translation}->{'End date'} = 'Data zakończenia';
    $Self->{Translation}->{'Repeat'} = 'Powtarzaj';
    $Self->{Translation}->{'No calendars found. Please add a calendar first by using Manage Calendars page.'} =
        'Nie znaleziono kalendarzy. Proszę dodać najpierw kalendarz używając strony Zarządzanie Kalendarzami.';
    $Self->{Translation}->{'Appointment'} = 'Wydarzenie';
    $Self->{Translation}->{'This is a repeating appointment'} = 'To powtarzające wydarzenie';
    $Self->{Translation}->{'Would you like to edit just this occurrence or all occurrences?'} =
        'Czy chciałbyś edytować tylko to wystąpienie czy wszystkie?';
    $Self->{Translation}->{'All occurrences'} = 'Wszystkie wystąpienia';
    $Self->{Translation}->{'Just this occurrence'} = 'Tylko to wystąpienie';

    # Template: AgentAppointmentCalendarManage
    $Self->{Translation}->{'Calendar Management'} = 'Zarządzanie Kalendarzami';
    $Self->{Translation}->{'Calendar Overview'} = 'Przegląd Kalendarzy';
    $Self->{Translation}->{'Add new Calendar'} = 'Dodaj nowy Kalendarz';
    $Self->{Translation}->{'Add Calendar'} = 'Dodaj Kalendarz';
    $Self->{Translation}->{'Import Appointments'} = 'Zaimportuj Wydarzenia';
    $Self->{Translation}->{'Calendar Import'} = 'Import Kalendarza';
    $Self->{Translation}->{'Here you can upload a configuration file to import a calendar to your system. The file needs to be in .yml format as exported by calendar management module.'} =
        'W tym miejscu możesz załadować plik konfiguracyjny by zaimportować kalendarz to systemu. Plik musi być w formacie .yml, podobnie jak wyeksportowany moduł zarządzania kalendarzem.';
    $Self->{Translation}->{'Upload calendar configuration'} = 'Wczytaj konfigurację kalendarza';
    $Self->{Translation}->{'Import Calendar'} = 'Zaimportuj Kalendarz';
    $Self->{Translation}->{'Filter for calendars'} = 'Filtr dla kalendrzay';
    $Self->{Translation}->{'Depending on the group field, the system will allow users the access to the calendar according to their permission level.'} =
        'W zależności od pola grupy, system udostępni użytkownikom dostęp do kalendarza zgodnie z ich uprawnieniami.';
    $Self->{Translation}->{'Read only: users can see and export all appointments in the calendar.'} =
        'Tylko do odczytu: użytkownicy mogą widzieć i eksportować wszystkie wydarzenia w kalendarzu.';
    $Self->{Translation}->{'Move into: users can modify appointments in the calendar, but without changing the calendar selection.'} =
        'Przenieś na: użytkownicy mogą modyfikować wydarzenia w kalendarzu, jednak bez możliwości zmiany wybranego kalendarza.';
    $Self->{Translation}->{'Create: users can create and delete appointments in the calendar.'} =
        'Utwórz: użytkownicy mogą tworzyć i usuwać wydarzenia w kalendarzu.';
    $Self->{Translation}->{'Read/write: users can manage the calendar itself.'} = 'Czytaj/Zapisz: użytkownicy mogą zarządzać samym kalendarzem.';
    $Self->{Translation}->{'URL'} = 'URL';
    $Self->{Translation}->{'Export calendar'} = 'Wyeksportuj kalendarz';
    $Self->{Translation}->{'Download calendar'} = 'Ściągnij kalendarz';
    $Self->{Translation}->{'Copy public calendar URL'} = 'Skopiuj URL publicznego kalendarza';
    $Self->{Translation}->{'Calendar name'} = 'Nazwa kalendarza';
    $Self->{Translation}->{'Calendar with same name already exists.'} = 'Kalendarz z tą nazwą już istnieje.';
    $Self->{Translation}->{'Permission group'} = 'Grupa uprawnień';
    $Self->{Translation}->{'Ticket Appointments'} = 'Wydarzenia Zgłoszeń';
    $Self->{Translation}->{'Rule'} = 'Reguła';
    $Self->{Translation}->{'Use options below to narrow down for which tickets appointments will be automatically created.'} =
        'Użyj opcji poniżej by zawęzić dla jakich zgłoszeń będą tworzone automatyczne wydarzenai.';
    $Self->{Translation}->{'Please select a valid queue.'} = 'Proszę wybrać ważną kolejkę.';
    $Self->{Translation}->{'Search attributes'} = 'Atrybuty wyszukiwania';
    $Self->{Translation}->{'Define rules for creating automatic appointments in this calendar based on ticket data.'} =
        'Definiuje reguły dla automatycznego tworzenia wydarzeń w tym kalendarzu, w zależności od danych zgłoszenia.';
    $Self->{Translation}->{'Add Rule'} = 'Dodaj regułę';
    $Self->{Translation}->{'More'} = 'Więcej';
    $Self->{Translation}->{'Less'} = 'Mniej';

    # Template: AgentAppointmentCalendarOverview
    $Self->{Translation}->{'Add new Appointment'} = 'Dodaj nowe wydarzenie';
    $Self->{Translation}->{'Calendars'} = 'Kalendarze';
    $Self->{Translation}->{'Too many active calendars'} = 'Zbyt dużo aktywnych kalendarzy';
    $Self->{Translation}->{'Please either turn some off first or increase the limit in configuration.'} =
        'Proszę wyłączyć kilka lub zwiększyć limit w konfiguracji.';
    $Self->{Translation}->{'Week'} = 'Tydzień';
    $Self->{Translation}->{'Timeline Month'} = 'Widok Miesięczny';
    $Self->{Translation}->{'Timeline Week'} = 'Widok Tygodniowy';
    $Self->{Translation}->{'Timeline Day'} = 'Widok Dzienny';
    $Self->{Translation}->{'Jump'} = 'Przejdź';
    $Self->{Translation}->{'Dismiss'} = 'Zwolnij';
    $Self->{Translation}->{'Show'} = 'Pokaż';
    $Self->{Translation}->{'Basic information'} = 'Podstawowe informacje';
    $Self->{Translation}->{'Date/Time'} = 'Data/Czas';

    # Template: AgentAppointmentEdit
    $Self->{Translation}->{'Please set this to value before End date.'} = 'Proszę ustawić tę wartość przed datą zakończenia.';
    $Self->{Translation}->{'Please set this to value after Start date.'} = 'Proszę ustawić tę wartość po dacie rozpoczęcia.';
    $Self->{Translation}->{'This an occurrence of a repeating appointment.'} = 'To jest wystąpienie powtarzalnego wydarzenia.';
    $Self->{Translation}->{'Click here to see the parent appointment.'} = 'Kliknij tutaj by sprawdzić wydarzenie główne.';
    $Self->{Translation}->{'Click here to edit the parent appointment.'} = 'Kliknij tutaj by edytować wydarzenie główne.';
    $Self->{Translation}->{'Frequency'} = 'Częstotliwość';
    $Self->{Translation}->{'Every'} = 'Każdy';
    $Self->{Translation}->{'Relative point of time'} = '';
    $Self->{Translation}->{'Are you sure you want to delete this appointment? This operation cannot be undone.'} =
        'Czy jesteś pewien, że chcesz usunąć to wydarzenie? Tej operacji nie można cofnąć.';

    # Template: AgentAppointmentImport
    $Self->{Translation}->{'Appointment Import'} = 'Import Wydarzeń';
    $Self->{Translation}->{'Uploaded file must be in valid iCal format (.ics).'} = 'Wczytany plik musi posiadać prawidłowy format iCAL (.ics).';
    $Self->{Translation}->{'If desired Calendar is not listed here, please make sure that you have at least \'create\' permissions.'} =
        'Jeśli szukany Kalendarz nie jest tutaj wyświetlony, proszę upewnić się, że posiadasz przy najmniej uprawnienie \'Utwórz\'.';
    $Self->{Translation}->{'Update existing appointments?'} = 'Zaktualizować istniejące wydarzenia?';
    $Self->{Translation}->{'All existing appointments in the calendar with same UniqueID will be overwritten.'} =
        'Wszystkie istniejące wydarzenia w kalendarzu z tym samym UniqueID zostaną nadpisane.';
    $Self->{Translation}->{'Upload calendar'} = 'Wczytaj kalendarz.';
    $Self->{Translation}->{'Import appointments'} = 'Import wydarzeń';

    # Template: AgentDashboardAppointmentCalendar
    $Self->{Translation}->{'New Appointment'} = 'Nowe wydarzenie';
    $Self->{Translation}->{'Soon'} = 'Niebawem';
    $Self->{Translation}->{'5 days'} = '5 dni';

    # Perl Module: Kernel/Modules/AdminAppointmentNotificationEvent.pm
    $Self->{Translation}->{'Notification name already exists!'} = 'Powiadomienie o tej samej nazwie już istnieje!';
    $Self->{Translation}->{'Agent (resources), who are selected within the appointment'} = 'Agenci (zasoby), wybrani w ramach wydarzenia';
    $Self->{Translation}->{'All agents with (at least) read permission for the appointment (calendar)'} =
        'Wszyscy agenci posiadający (przynajmniej) prawo odczytu zdarzenia (kalendarza)';
    $Self->{Translation}->{'All agents with write permission for the appointment (calendar)'} =
        'Wszyscy agenci z prawem zapisu wydarzenia (kalendarza)';

    # Perl Module: Kernel/Modules/AgentAppointmentCalendarManage.pm
    $Self->{Translation}->{'System was unable to create Calendar!'} = 'System nie był w stanie stworzyć Kalendarza.';
    $Self->{Translation}->{'No CalendarID!'} = 'Brak CalendarID!';
    $Self->{Translation}->{'You have no access to this calendar!'} = 'Nie masz dostępu do tego kalendarza!';
    $Self->{Translation}->{'Edit Calendar'} = 'Edytuj Kalendarz';
    $Self->{Translation}->{'Error updating the calendar!'} = 'Błąd aktualizacji kalendarza!';
    $Self->{Translation}->{'Couldn\'t read calendar configuration file.'} = 'Nie można odczytać pliku konfiguracyjnego kalendarza.';
    $Self->{Translation}->{'Please make sure your file is valid.'} = 'Proszę upewnić się, że plik jest właściwy.';
    $Self->{Translation}->{'Could not import the calendar!'} = 'Nie można zaimportować kalendarza!';
    $Self->{Translation}->{'Calendar imported!'} = 'Kalendarz Zaimportowany!';
    $Self->{Translation}->{'Need CalendarID!'} = 'Potrzebne CalendarID!';
    $Self->{Translation}->{'Could not retrieve data for given CalendarID'} = 'Nie można odczytać informacji dla podanego CalendarID';
    $Self->{Translation}->{'Successfully imported %s appointment(s) to calendar %s.'} = 'Poprawnie zaimportowano %s wydarzeń do kalendarza %s.';
    $Self->{Translation}->{'+5 minutes'} = '+5 minut';
    $Self->{Translation}->{'+15 minutes'} = '+15 minut';
    $Self->{Translation}->{'+30 minutes'} = '+30 minut';
    $Self->{Translation}->{'+1 hour'} = '+1 godzina';

    # Perl Module: Kernel/Modules/AgentAppointmentCalendarOverview.pm
    $Self->{Translation}->{'All appointments'} = 'Wszystkie wydarzenia';
    $Self->{Translation}->{'Appointments assigned to me'} = 'Wydarzenia przypisane do mnie';
    $Self->{Translation}->{'Showing only appointments assigned to you! Change settings'} = 'Wyświetlanie wydarzeń przypisanych do Ciebie! Zmień ustawienia';

    # Perl Module: Kernel/Modules/AgentAppointmentEdit.pm
    $Self->{Translation}->{'Appointment not found!'} = 'Wydarzenie nie odnalezione!';
    $Self->{Translation}->{'Never'} = 'Nigdy';
    $Self->{Translation}->{'Every Day'} = 'Codziennie';
    $Self->{Translation}->{'Every Week'} = 'Co tydzeń';
    $Self->{Translation}->{'Every Month'} = 'Co miesiąc';
    $Self->{Translation}->{'Every Year'} = 'Co rok';
    $Self->{Translation}->{'Custom'} = 'Własne';
    $Self->{Translation}->{'Daily'} = 'Dziennie';
    $Self->{Translation}->{'Weekly'} = 'Tygodniowo';
    $Self->{Translation}->{'Monthly'} = 'Miesięcznie';
    $Self->{Translation}->{'Yearly'} = 'Rocznie';
    $Self->{Translation}->{'every'} = 'każde';
    $Self->{Translation}->{'for %s time(s)'} = '';
    $Self->{Translation}->{'until ...'} = 'dopóki ...';
    $Self->{Translation}->{'for ... time(s)'} = '';
    $Self->{Translation}->{'until %s'} = 'aż do %s';
    $Self->{Translation}->{'No notification'} = 'Brak powiadomień';
    $Self->{Translation}->{'%s minute(s) before'} = '%s minut(y) przed';
    $Self->{Translation}->{'%s hour(s) before'} = '%s godzin(y) przed';
    $Self->{Translation}->{'%s day(s) before'} = '%s dni(dzień) przed';
    $Self->{Translation}->{'%s week before'} = '%s tygodnie przed';
    $Self->{Translation}->{'before the appointment starts'} = 'zanim wydarzenie rozpocznie się';
    $Self->{Translation}->{'after the appointment has been started'} = 'po rozpoczęciu wydarzeniu';
    $Self->{Translation}->{'before the appointment ends'} = 'przed zakończeniem wydarzenia';
    $Self->{Translation}->{'after the appointment has been ended'} = 'po zakończeniu wydarzenia';
    $Self->{Translation}->{'No permission!'} = 'Brak uprawnień!';
    $Self->{Translation}->{'Cannot delete ticket appointment!'} = 'Nie można usunąć wydarzenia dla zgłoszenia!';
    $Self->{Translation}->{'No permissions!'} = 'Brak uprawnień!';

    # Perl Module: Kernel/Modules/AgentAppointmentImport.pm
    $Self->{Translation}->{'No permissions'} = 'Brak uprawnień';
    $Self->{Translation}->{'System was unable to import file!'} = 'System nie był w stanie zaimportować pliku!';
    $Self->{Translation}->{'Please check the log for more information.'} = 'Proszę sprawdzić logi dla dokładniejszych informacji.';

    # Perl Module: Kernel/Modules/AgentAppointmentList.pm
    $Self->{Translation}->{'+%d more'} = '+%d więcej';

    # Perl Module: Kernel/Modules/PublicCalendar.pm
    $Self->{Translation}->{'No %s!'} = 'Brak %s!';
    $Self->{Translation}->{'No such user!'} = 'Nie ma takiego użytkownika!';
    $Self->{Translation}->{'Invalid calendar!'} = 'Niewłaściwy kalendarz!';
    $Self->{Translation}->{'Invalid URL!'} = 'Niewłaściwy URL!';
    $Self->{Translation}->{'There was an error exporting the calendar!'} = 'Błąd podczas eksportowania kalendarza!';

    # Perl Module: Kernel/Output/HTML/Dashboard/AppointmentCalendar.pm
    $Self->{Translation}->{'Refresh (minutes)'} = 'Odświeżaj (minuty)';

    # SysConfig
    $Self->{Translation}->{'Appointment Calendar overview page.'} = 'Strona podsumowująca Kalendarz Wydarzeń';
    $Self->{Translation}->{'Appointment Notifications'} = 'Powiadomienia Wydarzeń';
    $Self->{Translation}->{'Appointment calendar event module that prepares notification entries for appointments.'} =
        '';
    $Self->{Translation}->{'Appointment calendar event module that updates the ticket with data from ticket appointment.'} =
        '';
    $Self->{Translation}->{'Appointment edit screen.'} = 'Ekran edycji wydarzeń.';
    $Self->{Translation}->{'Appointment list'} = 'Lista wydarzeń';
    $Self->{Translation}->{'Appointment list.'} = 'Lista wydarzeń.';
    $Self->{Translation}->{'Appointment notifications'} = 'Powiadomienia wydarzeń';
    $Self->{Translation}->{'Appointments'} = 'Wydarzenia';
    $Self->{Translation}->{'Calendar manage screen.'} = 'Ekran zarządzania Kalendarzem';
    $Self->{Translation}->{'Choose for which kind of appointment changes you want to receive notifications.'} =
        'Wybierz, dla jakiego rodzaju zmian w wydarzeniach, chcesz otrzymywać powiadomienia.';
    $Self->{Translation}->{'Create a new calendar appointment linked to this ticket'} = 'Utwórz nowy kalendarz wydarzeń połączony z tym zgłoszeniem';
    $Self->{Translation}->{'Create and manage appointment notifications.'} = 'Utwórz i zarządzaj powiadomieniami wydarzeń.';
    $Self->{Translation}->{'Create new appointment.'} = 'Utwórz nowe wydarzenie.';
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
    $Self->{Translation}->{'DynamicField_%s'} = 'DynamicField_%s';
    $Self->{Translation}->{'Edit appointment'} = 'Edytuj wydarzenie';
    $Self->{Translation}->{'First response time'} = 'Czas pierwszej odpowiedzi';
    $Self->{Translation}->{'Import appointments screen.'} = 'Ekran importu wydarzeń.';
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
    $Self->{Translation}->{'Overview of all appointments.'} = 'Przegląd wszystkich wydarzeń.';
    $Self->{Translation}->{'Pending time'} = 'Czas oczekiwania';
    $Self->{Translation}->{'Plugin search'} = '';
    $Self->{Translation}->{'Plugin search module for autocomplete.'} = '';
    $Self->{Translation}->{'Public Calendar'} = 'Kalendarz Publiczny';
    $Self->{Translation}->{'Public calendar.'} = 'Kalendarz publiczny.';
    $Self->{Translation}->{'Resource Overview'} = 'Przegląd zasobów';
    $Self->{Translation}->{'Resource Overview (OTRS Business Solution™)'} = 'Przegląd zasobów (OTRS Business Solution™)';
    $Self->{Translation}->{'Shows a link in the menu for creating a calendar appointment linked to the ticket directly from the ticket zoom view of the agent interface. Additional access control to show or not show this link can be done by using Key "Group" and Content like "rw:group1;move_into:group2". To cluster menu items use for Key "ClusterName" and for the Content any name you want to see in the UI. Use "ClusterPriority" to configure the order of a certain cluster within the toolbar.'} =
        '';
    $Self->{Translation}->{'Solution time'} = 'Czas rozwiązania';
    $Self->{Translation}->{'Transport selection for appointment notifications.'} = 'Wybór rodzaju transportu dla powiadomień o wydarzeniach.';
    $Self->{Translation}->{'Triggers add or update of automatic calendar appointments based on certain ticket times.'} =
        '';
    $Self->{Translation}->{'Update time'} = 'Czas aktualizacji';

}

1;
