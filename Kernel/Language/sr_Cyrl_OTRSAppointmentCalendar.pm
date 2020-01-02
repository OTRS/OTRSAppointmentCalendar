# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Kernel::Language::sr_Cyrl_OTRSAppointmentCalendar;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    # Template: AAANotification
    $Self->{Translation}->{'Appointment reminder notification'} = 'Обавештење подсетника о термину';
    $Self->{Translation}->{'You will receive a notification each time a reminder time is reached for one of your appointments.'} =
        'Добићете обавештење сваки пут кадa дође до времена подсетника за неки од ваших термина.';

    # Template: AdminAppointmentNotificationEvent
    $Self->{Translation}->{'Appointment Notification Management'} = 'Управљање обавештењима о терминима';
    $Self->{Translation}->{'Here you can upload a configuration file to import appointment notifications to your system. The file needs to be in .yml format as exported by the appointment notification module.'} =
        'Овде можете послати конфигурациону датотеку за увоз обавештења о термину у ваш систем. Датотека мора бити у истом .yml формату који је могуће добити извозом у екрану управљања обавештењима о терминима.';
    $Self->{Translation}->{'Here you can choose which events will trigger this notification. An additional appointment filter can be applied below to only send for appointments with certain criteria.'} =
        'Овде можете изабрати који догађаји ће покренути обавештавање. Додатни филтер за термине може бити примењен ради слања само за термине по одређеном критеријуму.';
    $Self->{Translation}->{'Appointment Filter'} = 'Филтер термина';
    $Self->{Translation}->{'Team'} = 'Тим';
    $Self->{Translation}->{'Resource'} = 'Ресурс';
    $Self->{Translation}->{'Notify user just once per day about a single appointment using a selected transport.'} =
        'Обавести корисника само једном дневно о појединачном термину коришћењем изабраног транспорта.';
    $Self->{Translation}->{'Notifications are sent to an agent.'} = 'Обавештење ће бити послато оператеру.';
    $Self->{Translation}->{'To get the first 20 character of the appointment title.'} = 'Да видите првих 20 карактера наслова термина.';
    $Self->{Translation}->{'To get the appointment attribute'} = 'Да видите атрибуте термина';
    $Self->{Translation}->{'To get the calendar attribute'} = 'Да видите атрибуте календара';

    # Template: AgentAppointmentAgendaOverview
    $Self->{Translation}->{'Agenda Overview'} = 'Преглед дневног реда';
    $Self->{Translation}->{'Manage Calendars'} = 'Управљање календарима';
    $Self->{Translation}->{'Add Appointment'} = 'Додај термин';
    $Self->{Translation}->{'Color'} = 'Боја';
    $Self->{Translation}->{'End date'} = 'Датум краја';
    $Self->{Translation}->{'Repeat'} = 'Понављање';
    $Self->{Translation}->{'No calendars found. Please add a calendar first by using Manage Calendars page.'} =
        'Није пронађен ниједан календар. Молимо прво додајте календар коришћењем екрана Управљање календарима.';
    $Self->{Translation}->{'Appointment'} = 'Термин';
    $Self->{Translation}->{'This is a repeating appointment'} = 'Овај термин се понавља';
    $Self->{Translation}->{'Would you like to edit just this occurrence or all occurrences?'} =
        'Да ли желите да измени само ово или сва понављања?';
    $Self->{Translation}->{'All occurrences'} = 'Сва понављања';
    $Self->{Translation}->{'Just this occurrence'} = 'Само ово понављање';

    # Template: AgentAppointmentCalendarManage
    $Self->{Translation}->{'Calendar Management'} = 'Управљање календарима';
    $Self->{Translation}->{'Calendar Overview'} = 'Преглед календара';
    $Self->{Translation}->{'Add new Calendar'} = 'Додај нови календар';
    $Self->{Translation}->{'Add Calendar'} = 'Додај календар';
    $Self->{Translation}->{'Import Appointments'} = 'Увези термине';
    $Self->{Translation}->{'Calendar Import'} = 'Увоз календара';
    $Self->{Translation}->{'Here you can upload a configuration file to import a calendar to your system. The file needs to be in .yml format as exported by calendar management module.'} =
        'Овде можете учитати конфигурациону датотеку за увоз календара у ваш систем. Датотека мора бити у .yml формату извезена од стране модула за управљање календарима.';
    $Self->{Translation}->{'Upload calendar configuration'} = 'Учитај конфигурацију календара';
    $Self->{Translation}->{'Import Calendar'} = 'Увези календар';
    $Self->{Translation}->{'Filter for calendars'} = 'Филтер за календаре';
    $Self->{Translation}->{'Depending on the group field, the system will allow users the access to the calendar according to their permission level.'} =
        'У зависности од поља групе, систем ће дозволити приступ календару оператерима према њиховом нивоу приступа.';
    $Self->{Translation}->{'Read only: users can see and export all appointments in the calendar.'} =
        'RO: оператери могу прегледати и експортовати све термине у календару.';
    $Self->{Translation}->{'Move into: users can modify appointments in the calendar, but without changing the calendar selection.'} =
        'Премести у: оператери могу модификовати термине у календару, али без промене ком календару припадају.';
    $Self->{Translation}->{'Create: users can create and delete appointments in the calendar.'} =
        'Креирање: оператери могу креирати и брисати термине у календару.';
    $Self->{Translation}->{'Read/write: users can manage the calendar itself.'} = 'RW: оператери могу администрирати и сам календар.';
    $Self->{Translation}->{'URL'} = 'Адреса';
    $Self->{Translation}->{'Export calendar'} = 'Извези календар';
    $Self->{Translation}->{'Download calendar'} = 'Преузми календар';
    $Self->{Translation}->{'Copy public calendar URL'} = 'Ископирај јавну адресу календара (URL)';
    $Self->{Translation}->{'Calendar name'} = 'Назив календара';
    $Self->{Translation}->{'Calendar with same name already exists.'} = 'Календар са истим називом већ постоји.';
    $Self->{Translation}->{'Permission group'} = 'Група приступа';
    $Self->{Translation}->{'Ticket Appointments'} = 'Термини тикета';
    $Self->{Translation}->{'Rule'} = 'Правило';
    $Self->{Translation}->{'Use options below to narrow down for which tickets appointments will be automatically created.'} =
        'Користећи опције испод изаберите за које тикете ће термини бити аутоматски креирани.';
    $Self->{Translation}->{'Please select a valid queue.'} = 'Молимо да одаберете важећи ред.';
    $Self->{Translation}->{'Search attributes'} = 'Атрибути претраге';
    $Self->{Translation}->{'Define rules for creating automatic appointments in this calendar based on ticket data.'} =
        'Дефинишите правила за креирање аутоматских термина у овом календару на основу тикета.';
    $Self->{Translation}->{'Add Rule'} = 'Додај правило';
    $Self->{Translation}->{'More'} = 'Више';
    $Self->{Translation}->{'Less'} = 'Мање';

    # Template: AgentAppointmentCalendarOverview
    $Self->{Translation}->{'Add new Appointment'} = 'Додај нови термин';
    $Self->{Translation}->{'Calendars'} = 'Календари';
    $Self->{Translation}->{'Too many active calendars'} = 'Превише активних календара';
    $Self->{Translation}->{'Please either turn some off first or increase the limit in configuration.'} =
        'Или прво искључите приказ неког календара или повећајте лимит у конфигурацији.';
    $Self->{Translation}->{'Week'} = 'Седмица';
    $Self->{Translation}->{'Timeline Month'} = 'Месечна оса';
    $Self->{Translation}->{'Timeline Week'} = 'Седмична оса';
    $Self->{Translation}->{'Timeline Day'} = 'Дневна оса';
    $Self->{Translation}->{'Jump'} = 'Скочи';
    $Self->{Translation}->{'Dismiss'} = 'Поништи';
    $Self->{Translation}->{'Show'} = 'Прикажи';
    $Self->{Translation}->{'Basic information'} = 'Основне информације';
    $Self->{Translation}->{'Date/Time'} = 'Датум/време';

    # Template: AgentAppointmentEdit
    $Self->{Translation}->{'Please set this to value before End date.'} = 'Молимо поставите овај датум пре краја.';
    $Self->{Translation}->{'Please set this to value after Start date.'} = 'Молимо поставите овај датум после почетка.';
    $Self->{Translation}->{'This an occurrence of a repeating appointment.'} = 'Ово је термин који се понавља.';
    $Self->{Translation}->{'Click here to see the parent appointment.'} = 'Кликните овде за преглед матичног термина.';
    $Self->{Translation}->{'Click here to edit the parent appointment.'} = 'Кликните овде за измену матичног термина.';
    $Self->{Translation}->{'Frequency'} = 'Учесталост';
    $Self->{Translation}->{'Every'} = 'Сваког(е)';
    $Self->{Translation}->{'Relative point of time'} = 'Релативно време';
    $Self->{Translation}->{'Are you sure you want to delete this appointment? This operation cannot be undone.'} =
        'Да ли сте сигурни да желите да избришете овај термин? Ову операцију није могуће опозвати.';

    # Template: AgentAppointmentImport
    $Self->{Translation}->{'Appointment Import'} = 'Увоз термина';
    $Self->{Translation}->{'Uploaded file must be in valid iCal format (.ics).'} = 'Послати фајл мора бити у исправном iCal формату (.ics).';
    $Self->{Translation}->{'If desired Calendar is not listed here, please make sure that you have at least \'create\' permissions.'} =
        'Уколико жељени календар није излистан, проверите да ли имате ниво приступа \'креирање\' за групу календара.';
    $Self->{Translation}->{'Update existing appointments?'} = 'Освежи постојеће термине?';
    $Self->{Translation}->{'All existing appointments in the calendar with same UniqueID will be overwritten.'} =
        'Сви постојећи термини у календару са истим UniqueID пољем ће бити пребрисани.';
    $Self->{Translation}->{'Upload calendar'} = 'Пошаљи календар';
    $Self->{Translation}->{'Import appointments'} = 'Увези термине';

    # Template: AgentDashboardAppointmentCalendar
    $Self->{Translation}->{'New Appointment'} = 'Нови термин';
    $Self->{Translation}->{'Soon'} = 'Ускоро';
    $Self->{Translation}->{'5 days'} = '5 дана';

    # Perl Module: Kernel/Modules/AdminAppointmentNotificationEvent.pm
    $Self->{Translation}->{'Notification name already exists!'} = 'Обавештење са овим називом већ постоји!';
    $Self->{Translation}->{'Agent (resources), who are selected within the appointment'} = 'Оператер (ресурс), који је изабран у термину';
    $Self->{Translation}->{'All agents with (at least) read permission for the appointment (calendar)'} =
        'Сви оператери са (најмање) дозволом прегледа термина (календара)';
    $Self->{Translation}->{'All agents with write permission for the appointment (calendar)'} =
        'Сви оператери са дозволом писања у термину (календару)';

    # Perl Module: Kernel/Modules/AgentAppointmentCalendarManage.pm
    $Self->{Translation}->{'System was unable to create Calendar!'} = 'Систем није успео да креира календар!';
    $Self->{Translation}->{'No CalendarID!'} = 'Нема CalendarID!';
    $Self->{Translation}->{'You have no access to this calendar!'} = 'Немате приступ овом календару!';
    $Self->{Translation}->{'Edit Calendar'} = 'Измени календар';
    $Self->{Translation}->{'Error updating the calendar!'} = 'Грешка приликом измене календара';
    $Self->{Translation}->{'Couldn\'t read calendar configuration file.'} = 'Учитавање конфигурације календара није било могуће.';
    $Self->{Translation}->{'Please make sure your file is valid.'} = 'Молимо вас да проверите да ли је ваш фајл исправан.';
    $Self->{Translation}->{'Could not import the calendar!'} = 'Није могућ увоз календара!';
    $Self->{Translation}->{'Calendar imported!'} = 'Календар је увезен!';
    $Self->{Translation}->{'Need CalendarID!'} = 'Потребан ИД календара!';
    $Self->{Translation}->{'Could not retrieve data for given CalendarID'} = 'Не могу прибавити податке за дати CalendarID';
    $Self->{Translation}->{'Successfully imported %s appointment(s) to calendar %s.'} = 'Успешно увезено %s термин(а) у календар %s.';
    $Self->{Translation}->{'+5 minutes'} = '+5 минута';
    $Self->{Translation}->{'+15 minutes'} = '+15 минута';
    $Self->{Translation}->{'+30 minutes'} = '+30 минута';
    $Self->{Translation}->{'+1 hour'} = '+1 сат';

    # Perl Module: Kernel/Modules/AgentAppointmentCalendarOverview.pm
    $Self->{Translation}->{'All appointments'} = 'Сви термини';
    $Self->{Translation}->{'Appointments assigned to me'} = 'Термини додељени мени';
    $Self->{Translation}->{'Showing only appointments assigned to you! Change settings'} = 'Приказ само термина додељених вама! Измените подешавања';

    # Perl Module: Kernel/Modules/AgentAppointmentEdit.pm
    $Self->{Translation}->{'Appointment not found!'} = 'Термин није пронађен!';
    $Self->{Translation}->{'Never'} = 'Никада';
    $Self->{Translation}->{'Every Day'} = 'Сваки дан';
    $Self->{Translation}->{'Every Week'} = 'Сваке седмице';
    $Self->{Translation}->{'Every Month'} = 'Сваког месеца';
    $Self->{Translation}->{'Every Year'} = 'Сваке године';
    $Self->{Translation}->{'Custom'} = 'Прилагођено';
    $Self->{Translation}->{'Daily'} = 'Дневно';
    $Self->{Translation}->{'Weekly'} = 'Седмично';
    $Self->{Translation}->{'Monthly'} = 'Месечно';
    $Self->{Translation}->{'Yearly'} = 'Годишње';
    $Self->{Translation}->{'every'} = 'сваког(е)';
    $Self->{Translation}->{'for %s time(s)'} = 'укупно %s пут(а)';
    $Self->{Translation}->{'until ...'} = 'до ...';
    $Self->{Translation}->{'for ... time(s)'} = 'укупно ... пут(а)';
    $Self->{Translation}->{'until %s'} = 'до %s';
    $Self->{Translation}->{'No notification'} = 'Без обавештења';
    $Self->{Translation}->{'%s minute(s) before'} = '%s минут(а) пре';
    $Self->{Translation}->{'%s hour(s) before'} = '%s сат(а) пре';
    $Self->{Translation}->{'%s day(s) before'} = '%s дан(а) пре';
    $Self->{Translation}->{'%s week before'} = '%s недеља пре';
    $Self->{Translation}->{'before the appointment starts'} = 'пре него што термин започне';
    $Self->{Translation}->{'after the appointment has been started'} = 'пошто термин започне';
    $Self->{Translation}->{'before the appointment ends'} = 'пре него што се термин заврши';
    $Self->{Translation}->{'after the appointment has been ended'} = 'пошто се термин заврши';
    $Self->{Translation}->{'No permission!'} = 'Без дозволе!';
    $Self->{Translation}->{'Cannot delete ticket appointment!'} = 'Није могуће обрисати термин тикета!';
    $Self->{Translation}->{'No permissions!'} = 'Без дозволе!';

    # Perl Module: Kernel/Modules/AgentAppointmentImport.pm
    $Self->{Translation}->{'No permissions'} = 'Без дозволе';
    $Self->{Translation}->{'System was unable to import file!'} = 'Систем није успео да увезе фајл!';
    $Self->{Translation}->{'Please check the log for more information.'} = 'Молимо проверите лог за више информација.';

    # Perl Module: Kernel/Modules/AgentAppointmentList.pm
    $Self->{Translation}->{'+%d more'} = '+%d више';

    # Perl Module: Kernel/Modules/PublicCalendar.pm
    $Self->{Translation}->{'No %s!'} = 'Без %s!';
    $Self->{Translation}->{'No such user!'} = 'Непознат корисник!';
    $Self->{Translation}->{'Invalid calendar!'} = 'Неисправан календар!';
    $Self->{Translation}->{'Invalid URL!'} = 'Неисправна адреса!';
    $Self->{Translation}->{'There was an error exporting the calendar!'} = 'Грешка приликом експортовања календара!';

    # Perl Module: Kernel/Output/HTML/Dashboard/AppointmentCalendar.pm
    $Self->{Translation}->{'Refresh (minutes)'} = 'Освежи (минута)';

    # SysConfig
    $Self->{Translation}->{'Appointment Calendar overview page.'} = 'Страница за преглед календара.';
    $Self->{Translation}->{'Appointment Notifications'} = 'Обавештења о термину';
    $Self->{Translation}->{'Appointment calendar event module that prepares notification entries for appointments.'} =
        'Модул догађаја календара за припрему обавештења о терминима.';
    $Self->{Translation}->{'Appointment calendar event module that updates the ticket with data from ticket appointment.'} =
        'Модул догађаја календара за освежавање тикета подацима из термина.';
    $Self->{Translation}->{'Appointment edit screen.'} = 'Страница за измену календара.';
    $Self->{Translation}->{'Appointment list'} = 'Листа термина';
    $Self->{Translation}->{'Appointment list.'} = 'Листа термина.';
    $Self->{Translation}->{'Appointment notifications'} = 'Обавештења о термину';
    $Self->{Translation}->{'Appointments'} = 'Термини';
    $Self->{Translation}->{'Calendar manage screen.'} = 'Страница за управљање календарима.';
    $Self->{Translation}->{'Choose for which kind of appointment changes you want to receive notifications.'} =
        'Изабери за какве промене термина желиш да примиш обавештења.';
    $Self->{Translation}->{'Create a new calendar appointment linked to this ticket'} = 'Креира нови термин у календару повезан са овим тикетом';
    $Self->{Translation}->{'Create and manage appointment notifications.'} = 'Креирање и управљање обавештењима за термине.';
    $Self->{Translation}->{'Create new appointment.'} = 'Креира нови термин.';
    $Self->{Translation}->{'Define which columns are shown in the linked appointment widget (LinkObject::ViewMode = "complex"). Possible settings: 0 = Disabled, 1 = Available, 2 = Enabled by default.'} =
        'Дефинише које колоне ће бити приказане у апликативном додатку линкованих термина (LinkObject::ViewMode = "complex"). Могућа подешавања: 0 = Онемогућено, 1 = Омогућено, 2 = Подразумевано омогућено.';
    $Self->{Translation}->{'Defines an icon with link to the google map page of the current location in appointment edit screen.'} =
        'Дефинише икону са линком на Google мапу тренутне локације у екрану за измену термина.';
    $Self->{Translation}->{'Defines the event object types that will be handled via AdminAppointmentNotificationEvent.'} =
        'Дефинише типове објекта догађаја који ће бити процесирани путем AdminAppointmentNotificationEvent.';
    $Self->{Translation}->{'Defines the list of params that can be passed to ticket search function.'} =
        'Дефинише листу параметара који могу бити прослеђени функцији претраге тикета.';
    $Self->{Translation}->{'Defines the ticket appointment type backend for ticket dynamic field date time.'} =
        'Дефинише позадински модул термина тикета за динамичко поље датума.';
    $Self->{Translation}->{'Defines the ticket appointment type backend for ticket escalation time.'} =
        'Дефинише позадински модул термина тикета за време ескалације.';
    $Self->{Translation}->{'Defines the ticket appointment type backend for ticket pending time.'} =
        'Дефинише позадински модул термина тикета за време чекања.';
    $Self->{Translation}->{'Defines the ticket plugin for calendar appointments.'} = 'Дефинише тикет модул за календарске термине.';
    $Self->{Translation}->{'DynamicField_%s'} = 'DynamicField_%s';
    $Self->{Translation}->{'Edit appointment'} = 'Измена термина';
    $Self->{Translation}->{'First response time'} = 'Време првог одговора';
    $Self->{Translation}->{'Import appointments screen.'} = 'Екран за увоз термина.';
    $Self->{Translation}->{'Links appointments and tickets with a "Normal" type link.'} = 'Повезује термине и тикете "Нормалним" врстама веза.';
    $Self->{Translation}->{'List of all appointment events to be displayed in the GUI.'} = 'Листа свих обавештења о терминима за приказ у интерфејсу.';
    $Self->{Translation}->{'List of all calendar events to be displayed in the GUI.'} = 'Листа свих догађаја на календарима која ће бити приказана у интерфејсу.';
    $Self->{Translation}->{'List of colors in hexadecimal RGB which will be available for selection during calendar creation. Make sure the colors are dark enough so white text can be overlayed on them.'} =
        'Листа боја у хексадецималном RGB запису које ће бити доступне за избор приликом прављења календара. Обратите пажњу да су боје довољно тамне тако да бели текст може бити исписан на њима.';
    $Self->{Translation}->{'Manage different calendars.'} = 'Управљање различитим календарима.';
    $Self->{Translation}->{'Maximum number of active calendars in overview screens. Please note that large number of active calendars can have a performance impact on your server by making too much simultaneous calls.'} =
        'Максимални број активних календара у екранима за преглед. Обратите пажњу да велики број активних календара може имати утицај на перформансе вашег сервера прављењем превише симултаних захтева.';
    $Self->{Translation}->{'OTRS doesn\'t support recurring Appointments without end date or number of iterations. During import process, it might happen that ICS file contains such Appointments. Instead, system creates all Appointments in the past, plus Appointments for the next n months (120 months/10 years by default).'} =
        'OTRS не подржава термине који се понављају без крајњег датума или броја итерација. Приликом увоза календара, може се догодити да ICS фајл садржи такве \'бесконачне\' термине. Уместо таквог понашања, систем ће креирати све термине из прошлости, као и термине за следећи n број месеци (подразумевано 120 месеци/10 година).';
    $Self->{Translation}->{'Overview of all appointments.'} = 'Преглед свих термина.';
    $Self->{Translation}->{'Pending time'} = 'Време чекања';
    $Self->{Translation}->{'Plugin search'} = 'Модул претраге';
    $Self->{Translation}->{'Plugin search module for autocomplete.'} = 'Модул претраге за аутоматско допуњавање.';
    $Self->{Translation}->{'Public Calendar'} = 'Јавни календар';
    $Self->{Translation}->{'Public calendar.'} = 'Јавни календар.';
    $Self->{Translation}->{'Resource Overview'} = 'Преглед ресурса';
    $Self->{Translation}->{'Resource Overview (OTRS Business Solution™)'} = 'Преглед ресурса (OTRS Business Solution™)';
    $Self->{Translation}->{'Shows a link in the menu for creating a calendar appointment linked to the ticket directly from the ticket zoom view of the agent interface. Additional access control to show or not show this link can be done by using Key "Group" and Content like "rw:group1;move_into:group2". To cluster menu items use for Key "ClusterName" and for the Content any name you want to see in the UI. Use "ClusterPriority" to configure the order of a certain cluster within the toolbar.'} =
        'Приказује везу у менију тикета за креирање термина у календару повезаног са тим тикетом. Додатна контрола приказа ове везе може се постићи коришћењем кључа "Group" са садржајем "rw:group1;move_into:group2". За здруживање веза у менију подесите кључ "ClusterName" са садржајем који ће бити назив који желите да видите у интерфејсу. Користите кључ "ClusterPriority" за измену редоследа група у менију.';
    $Self->{Translation}->{'Solution time'} = 'Време решавања';
    $Self->{Translation}->{'Transport selection for appointment notifications.'} = 'Избор транспорта за обавештења о термину.';
    $Self->{Translation}->{'Triggers add or update of automatic calendar appointments based on certain ticket times.'} =
        'Активира додавање или освежавање аутоматских термина на основу времена тикета.';
    $Self->{Translation}->{'Update time'} = 'Време ажурирања';

}

1;
