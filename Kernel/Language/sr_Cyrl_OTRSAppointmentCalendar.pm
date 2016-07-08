# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::sr_Cyrl_OTRSAppointmentCalendar;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    # Template: AgentAppointmentCalendarImport
    $Self->{Translation}->{'Calendar Import'} = 'Увоз календара';
    $Self->{Translation}->{'Uploaded file must be in valid iCal format (.ics).'} = 'Послати фајл мора бити у исправном iCal формату (.ics).';
    $Self->{Translation}->{'If desired Calendar is not listed here, please make sure that you have at least \'create\' permissions.'} =
        'Уколико жељени календар није излистан, проверите да ли имате ниво приступа \'креирање\' за групу календара.';
    $Self->{Translation}->{'Upload'} = 'Пошаљи';
    $Self->{Translation}->{'Update existing appointments?'} = 'Освежи постојеће термине?';
    $Self->{Translation}->{'All existing appointments in the calendar with same UniqueID will be overwritten.'} =
        'Сви постојећи термини у календару са истим UniqueID пољем ће бити пребрисани.';
    $Self->{Translation}->{'Upload calendar'} = 'Пошаљи календар';
    $Self->{Translation}->{'Import calendar'} = 'Увези календар';

    # Template: AgentAppointmentCalendarManage
    $Self->{Translation}->{'Successfully imported %s appointment(s) to calendar %s.'} = 'Успешно увезено %s термин(а) у календар %s.';
    $Self->{Translation}->{'Calendar Management'} = 'Управљање календарима';
    $Self->{Translation}->{'Calendar Overview'} = 'Преглед календара';
    $Self->{Translation}->{'Add Calendar'} = 'Додај календар';
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
    $Self->{Translation}->{'Copy public calendar URL'} = 'Ископирај јавну адресу календара (URL)';
    $Self->{Translation}->{'Calendar name'} = 'Назив календара';
    $Self->{Translation}->{'Calendar with same name already exists.'} = 'Календар са истим називом већ постоји.';
    $Self->{Translation}->{'Color'} = 'Боја';
    $Self->{Translation}->{'Permission group'} = 'Група приступа';
    $Self->{Translation}->{'More'} = 'Више';
    $Self->{Translation}->{'Less'} = 'Мање';

    # Template: AgentAppointmentCalendarOverview
    $Self->{Translation}->{'Manage Calendars'} = 'Управљање календарима';
    $Self->{Translation}->{'Calendars'} = 'Календари';
    $Self->{Translation}->{'This is an overview page for the Appointment Calendar.'} = 'Ова страница служи за преглед календара.';
    $Self->{Translation}->{'No calendars found. Please add a calendar first by using Manage Calendars page.'} =
        'Није пронађен ниједан календар. Молимо прво додајте календар коришћењем екрана Управљање календарима.';
    $Self->{Translation}->{'Too many active calendars'} = 'Превише активних календара';
    $Self->{Translation}->{'Please either turn some off first or increase the limit in configuration.'} =
        'Или прво искључите приказ неког календара или повећајте лимит у конфигурацији.';
    $Self->{Translation}->{'Week'} = 'Седмица';
    $Self->{Translation}->{'Timeline Month'} = 'Месечна оса';
    $Self->{Translation}->{'Timeline Week'} = 'Седмична оса';
    $Self->{Translation}->{'Timeline Day'} = 'Дневна оса';
    $Self->{Translation}->{'Jump'} = 'Скочи';
    $Self->{Translation}->{'Appointment'} = 'Термин';
    $Self->{Translation}->{'This is a repeating appointment'} = 'Овај термин се понавља';
    $Self->{Translation}->{'Would you like to edit just this occurrence or all occurrences?'} =
        'Да ли желите да измени само ово или сва понављања?';
    $Self->{Translation}->{'All occurrences'} = 'Сва понављања';
    $Self->{Translation}->{'Just this occurrence'} = 'Само ово понављање';
    $Self->{Translation}->{'Dismiss'} = 'Поништи';
    $Self->{Translation}->{'Basic information'} = 'Основне информације';
    $Self->{Translation}->{'Location'} = 'Локација';
    $Self->{Translation}->{'Resource'} = 'Ресурс';
    $Self->{Translation}->{'Team'} = 'Тим';
    $Self->{Translation}->{'Date/Time'} = 'Датум/време';
    $Self->{Translation}->{'End date'} = 'Датум краја';
    $Self->{Translation}->{'Repeat'} = 'Понављање';

    # Template: AgentAppointmentCalendarOverviewSeen
    $Self->{Translation}->{'Following appointments have been started'} = 'Следећи термини су започети';
    $Self->{Translation}->{'Start time'} = 'Почетак';
    $Self->{Translation}->{'End time'} = 'Крај';

    # Template: AgentAppointmentEdit
    $Self->{Translation}->{'Please set this to value before End date.'} = 'Молимо поставите овај датум пре краја.';
    $Self->{Translation}->{'Please set this to value after Start date.'} = 'Молимо поставите овај датум после почетка.';
    $Self->{Translation}->{'This an ocurrence of a repeating appointment.'} = 'Ово је термин који се понавља.';
    $Self->{Translation}->{'Click here to edit the parent appointment.'} = 'Кликните овде за измену матичног термина.';
    $Self->{Translation}->{'Frequency'} = 'Учесталост';
    $Self->{Translation}->{'Every'} = 'Сваког(е)';
    $Self->{Translation}->{'Never'} = 'Никада';

    # Template: AgentAppointmentResourceOverview
    $Self->{Translation}->{'Resource Overview'} = 'Преглед ресурса';
    $Self->{Translation}->{'Manage Teams'} = 'Управљање тимовима';
    $Self->{Translation}->{'Manage Team Agents'} = 'Управљање оператерима у тимовима';
    $Self->{Translation}->{'This is a resource overview page.'} = 'Ова страница служи за преглед ресурса.';
    $Self->{Translation}->{'No teams found. Please add a team first by using Manage Teams page.'} =
        'Ниједан тим није пронађен. Молимо прво додајте тим коришћењеем екрана Управљање тимовима';
    $Self->{Translation}->{'No team agents found. Please assign agents to a team first by using Manage Team Agents page.'} =
        'Ниједан оператер није пронађен у тиму. Молимо прво додајте оператера у тим коришћењем Управљање оператерима у тимовима.';
    $Self->{Translation}->{'Restore default settings'} = 'Вратите подразумевана подешавања';
    $Self->{Translation}->{'Resources'} = 'Ресурси';
    $Self->{Translation}->{'Shown resources'} = 'Приказани ресурси';
    $Self->{Translation}->{'Available Resources'} = 'Доступни ресурси';
    $Self->{Translation}->{'Filter available resources'} = 'Филтер за доступне ресурсе';
    $Self->{Translation}->{'Visible Resources (order by drag & drop)'} = 'Видљиви ресурси (редослед према превуци и пусти)';

    # Template: AgentAppointmentTeam
    $Self->{Translation}->{'Add Team'} = 'Додај тим';
    $Self->{Translation}->{'Team Import'} = 'Увоз тима';
    $Self->{Translation}->{'Here you can upload a configuration file to import a team to your system. The file needs to be in .yml format as exported by team management module.'} =
        'Овде можете послати конфигурациони фајл за увоз тима у ваш систем. Фајл мора бити у истом .yml формату који је могуће добити извозом у екрану управљања тимовима.';
    $Self->{Translation}->{'Import team'} = 'Увези тим';
    $Self->{Translation}->{'Filter for teams'} = 'Филтер за тимове';
    $Self->{Translation}->{'Export team'} = 'Извези тим';
    $Self->{Translation}->{'Edit Team'} = 'Измени тим';
    $Self->{Translation}->{'Team with same name already exists.'} = 'Тим са истим називом већ постоји.';

    # Template: AgentAppointmentTeamUser
    $Self->{Translation}->{'Filter for agents'} = 'Филтер за оператере';
    $Self->{Translation}->{'Teams'} = 'Тимови';
    $Self->{Translation}->{'Manage Team-Agent Relations'} = 'Управљање оператерима у тимовима';
    $Self->{Translation}->{'Change Agent Relations for Team'} = 'Измени припадност оператера тиму';
    $Self->{Translation}->{'Change Team Relations for Agent'} = 'Измени припадност тиму оператерима';

    # Perl Module: Kernel/Modules/AgentAppointmentCalendarImport.pm
    $Self->{Translation}->{'No permissions'} = 'Без дозволе';
    $Self->{Translation}->{'System was unable to import file!'} = 'Систем није успео да увезе фајл!';

    # Perl Module: Kernel/Modules/AgentAppointmentCalendarManage.pm
    $Self->{Translation}->{'System was unable to create Calendar!'} = 'Систем није успео да креира календар!';
    $Self->{Translation}->{'No CalendarID!'} = 'Нема CalendarID!';
    $Self->{Translation}->{'You have no access to this calendar!'} = 'Немате приступ овом календару!';
    $Self->{Translation}->{'Edit Calendar'} = 'Измени календар';
    $Self->{Translation}->{'Error updating the calendar!'} = 'Грешка приликом измене календара';

    # Perl Module: Kernel/Modules/AgentAppointmentEdit.pm
    $Self->{Translation}->{'Appointment not found!'} = 'Термин није пронађен!';
    $Self->{Translation}->{'Every Day'} = 'Сваки дан';
    $Self->{Translation}->{'Every Week'} = 'Сваке седмице';
    $Self->{Translation}->{'Every Month'} = 'Сваког месеца';
    $Self->{Translation}->{'Every Year'} = 'Сваке године';
    $Self->{Translation}->{'Custom'} = 'Прилагођено';
    $Self->{Translation}->{'Daily'} = 'Дневно';
    $Self->{Translation}->{'Weekly'} = 'Седмично';
    $Self->{Translation}->{'Monthly'} = 'Месечно';
    $Self->{Translation}->{'Yearly'} = 'Годишње';
    $Self->{Translation}->{'until ...'} = 'до ...';
    $Self->{Translation}->{'for ... time(s)'} = 'укупно ... пут(а)';
    $Self->{Translation}->{'No permission!'} = 'Без дозволе!';
    $Self->{Translation}->{'Links could not be deleted!'} = 'Везе не могу бити обрисане!';
    $Self->{Translation}->{'Link could not be created!'} = 'Веза није могла бити креирана!';
    $Self->{Translation}->{'No permissions!'} = 'Без дозволе!';

    # Perl Module: Kernel/Modules/AgentAppointmentList.pm
    $Self->{Translation}->{'Ongoing appointments'} = 'Започети термини';

    # Perl Module: Kernel/Modules/AgentAppointmentTeam.pm
    $Self->{Translation}->{'Need TeamID!'} = 'Нема TeamID!';
    $Self->{Translation}->{'Could not retrieve data for given TeamID'} = 'За дати TeamID нема података';

    # Perl Module: Kernel/Modules/AgentAppointmentTeamList.pm
    $Self->{Translation}->{'Unassigned'} = 'Недодељено';

    # Perl Module: Kernel/Modules/PublicCalendar.pm
    $Self->{Translation}->{'No such user!'} = 'Непознат корисник!';
    $Self->{Translation}->{'Invalid calendar!'} = 'Неисправан календар!';
    $Self->{Translation}->{'Invalid URL!'} = 'Неисправна адреса!';
    $Self->{Translation}->{'There was an error exporting the calendar!'} = 'Грешка приликом експортовања календара!';

    # SysConfig
    $Self->{Translation}->{'Appointment Calendar overview page.'} = 'Страница за преглед календара.';
    $Self->{Translation}->{'Appointment edit screen.'} = 'Страница за измену календара.';
    $Self->{Translation}->{'Appointment list'} = 'Листа термина';
    $Self->{Translation}->{'Appointment list.'} = 'Листа термина.';
    $Self->{Translation}->{'CalDav'} = '';
    $Self->{Translation}->{'Calendar manage screen.'} = 'Страница за управљање календарима.';
    $Self->{Translation}->{'Create a new calendar appointment linked to this ticket'} = 'Креира нови термин у календару повезан са овим тикетом';
    $Self->{Translation}->{'Create new appointment.'} = 'Креира нови термин.';
    $Self->{Translation}->{'Defines the ticket plugin for calendar appointments.'} = 'Дефинише тикет модул за календарске термине.';
    $Self->{Translation}->{'Defines which backend should be used for managing calendars.'} =
        'Дефинише који позадински модул ће бити коришћен за управљање календарима.';
    $Self->{Translation}->{'Edit appointment'} = 'Измена термина';
    $Self->{Translation}->{'Import Calendar screen.'} = 'Екран за увоз календара.';
    $Self->{Translation}->{'Links appointments and tickets with a "Normal" type link.'} = 'Повезује термине и тикете "Нормалним" врстама веза.';
    $Self->{Translation}->{'List of colors in hexadecimal RGB which will be available for selection during calendar creation. Make sure the colors are dark enough so white text can be overlayed on them.'} =
        'Листа боја у хексадецималном RGB запису које ће бити доступне за избор приликом прављења календара. Обратите пажњу да су боје довољно тамне тако да бели текст може бити исписан на њима.';
    $Self->{Translation}->{'Manage different calendars.'} = 'Управљање различитим календарима.';
    $Self->{Translation}->{'Manage team agents.'} = 'Управљање оператерима у тимовима.';
    $Self->{Translation}->{'Maximum number of active calendars in overview screens. Please note that large number of active calendars can have a performance impact on your server by making too much simultaneous calls.'} =
        'Максимални број активних календара у екранима за преглед. Обратите пажњу да велики број активних календара може имати утицај на перформансе вашег сервера прављењем превише симултаних захтева.';
    $Self->{Translation}->{'New Appointment'} = 'Нови термин';
    $Self->{Translation}->{'OTRS doesn\'t support recurring Appointments without end date or number of iterrations. During import process, it might happen that ICS file contains such Appointments. Instead, system creates all Appointments in the past, plus Appointments for the next n months(120 months/10 years by default).'} =
        'OTRS не подржава термине који се понављају без крајњег датума или броја итерација. Приликом увоза календара, може се догодити да ICS фајл садржи такве \'бесконачне\' термине. Уместо таквог понашања, систем ће креирати све термине из прошлости, као и термине за следећи n број месеци (подразумевано 120 месеци/10 година).';
    $Self->{Translation}->{'Plugin search'} = 'Модул претраге';
    $Self->{Translation}->{'Plugin search module for autocomplete.'} = 'Модул претраге за аутоматско допуњавање.';
    $Self->{Translation}->{'Resource overview page.'} = 'Страница за преглед ресурса.';
    $Self->{Translation}->{'Resource overview screen.'} = 'Екран прегледа ресурса.';
    $Self->{Translation}->{'Resources list.'} = 'Листа ресурса.';
    $Self->{Translation}->{'Shows a link in the menu for creating a calendar appointment linked to the ticket directly from the ticket zoom view of the agent interface. Additional access control to show or not show this link can be done by using Key "Group" and Content like "rw:group1;move_into:group2". To cluster menu items use for Key "ClusterName" and for the Content any name you want to see in the UI. Use "ClusterPriority" to configure the order of a certain cluster within the toolbar.'} =
        'Приказује везу у менију тикета за креирање термина у календару повезаног са тим тикетом. Додатна контрола приказа ове везе може се постићи коришћењем кључа "Group" са садржајем "rw:group1;move_into:group2". За здруживање веза у менију подесите кључ "ClusterName" са садржајем који ће бити назив који желите да видите у интерфејсу. Користите кључ "ClusterPriority" за измену редоследа група у менију.';
    $Self->{Translation}->{'Team agents management screen.'} = 'Екран управљања оператерима у тимовима.';
    $Self->{Translation}->{'Team list'} = 'Листа тимова';
    $Self->{Translation}->{'Team management screen.'} = 'Екран управљања тимовима.';
    $Self->{Translation}->{'Team management.'} = 'Управљање тимовима.';

}

1;
