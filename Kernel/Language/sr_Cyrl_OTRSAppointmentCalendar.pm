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

    # Template: AgentAppointmentCalendarManage
    $Self->{Translation}->{'Calendar Management'} = 'Управљање календарима';
    $Self->{Translation}->{'Calendar Overview'} = 'Преглед календара';
    $Self->{Translation}->{'Add new Calendar'} = 'Додај нови календар';
    $Self->{Translation}->{'Calendar Import'} = 'Увоз календара';
    $Self->{Translation}->{'Here you can upload a file to import calendar to your system. The file needs to be in .ics format.'} =
        'Овде можете послати фајл за увоз календара у систем. Фајл мора бити у .ics формату.';
    $Self->{Translation}->{'Upload calendar'} = 'Пошаљи календар';
    $Self->{Translation}->{'Import calendar'} = 'Увези календар';
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
    $Self->{Translation}->{'Calendar imported successfully.'} = 'Календар успешно увезен.';
    $Self->{Translation}->{'Calendar name'} = 'Назив календара';
    $Self->{Translation}->{'Calendar with same name already exists.'} = 'Календар са истим називом већ постоји.';
    $Self->{Translation}->{'Permission group'} = 'Група приступа';

    # Template: AgentAppointmentCalendarOverview
    $Self->{Translation}->{'Manage Calendars'} = 'Управљање календарима';
    $Self->{Translation}->{'Calendars'} = 'Календари';
    $Self->{Translation}->{'This is an overview page for the Appointment Calendar.'} = 'Ова страница служи за преглед календара.';
    $Self->{Translation}->{'No calendars found. Please add a calendar first by using Manage Calendars page.'} =
        'Није пронађен ниједан календар. Молимо прво додајте календар коришћењем екрана Управљање календарима.';
    $Self->{Translation}->{'Week'} = 'Седмица';
    $Self->{Translation}->{'Timeline'} = 'Временска оса';
    $Self->{Translation}->{'Jump'} = 'Скочи';
    $Self->{Translation}->{'Appointment'} = 'Термин';
    $Self->{Translation}->{'This is a repeating appointment'} = 'Овај термин се понавља';
    $Self->{Translation}->{'Would you like to edit just this occurrence or all occurrences?'} =
        'Да ли желите да измени само ово или сва понављања?';
    $Self->{Translation}->{'All occurrences'} = 'Сва понављања';
    $Self->{Translation}->{'Just this occurrence'} = 'Само ово понављање';
    $Self->{Translation}->{'Dismiss'} = 'Поништи';
    $Self->{Translation}->{'Basic information'} = 'Основне информације';
    $Self->{Translation}->{'Date/Time'} = 'Датум/време';
    $Self->{Translation}->{'End date'} = 'Датум краја';
    $Self->{Translation}->{'Repeat'} = 'Понављање';

    # Template: AgentAppointmentCalendarOverviewSeen
    $Self->{Translation}->{'Following appointments have been started'} = 'Следећи термини су започети';
    $Self->{Translation}->{'Start time'} = 'Почетак';
    $Self->{Translation}->{'End time'} = 'Крај';
    $Self->{Translation}->{'Resource'} = 'Ресурс';

    # Template: AgentAppointmentEdit
    $Self->{Translation}->{'Team'} = 'Тим';

    # Template: AgentAppointmentResourceOverview
    $Self->{Translation}->{'Resource Overview'} = 'Преглед ресурса';
    $Self->{Translation}->{'Manage Teams'} = 'Управљање тимовима';
    $Self->{Translation}->{'Manage Team Agents'} = 'Управљање оператерима у тимовима';
    $Self->{Translation}->{'This is a resource overview page.'} = 'Ова страница служи за преглед ресурса.';
    $Self->{Translation}->{'No teams found. Please add a team first by using Manage Teams page.'} =
        'Ниједан тим није пронађен. Молимо прво додајте тим коришћењеем екрана Управљање тимовима';
    $Self->{Translation}->{'No team agents found. Please assign agents to a team first by using Manage Team Agents page.'} =
        'Ниједан оператер није пронађен у тиму. Молимо прво додајте оператера у тим коришћењем Управљање оператерима у тимовима.';
    $Self->{Translation}->{'Timeline Month'} = 'Месечна временска оса';
    $Self->{Translation}->{'Timeline Week'} = 'Седмична временска оса';
    $Self->{Translation}->{'Timeline Day'} = 'Дневна временска оса';
    $Self->{Translation}->{'Resources'} = 'Ресурси';

    # Template: AgentAppointmentTeam
    $Self->{Translation}->{'Add Team'} = 'Додај тим';
    $Self->{Translation}->{'Filter for teams'} = 'Филтер за тимове';
    $Self->{Translation}->{'Edit Team'} = 'Измени тим';
    $Self->{Translation}->{'Team with same name already exists.'} = 'Тим са истим називом већ постоји.';

    # Template: AgentAppointmentTeamUser
    $Self->{Translation}->{'Manage Team-Agent Relations'} = 'Управљање оператерима у тимовима';
    $Self->{Translation}->{'Change Agent Relations for Team'} = 'Измени припадност оператера тиму';

    # Perl Module: Kernel/Modules/AgentAppointmentCalendarManage.pm
    $Self->{Translation}->{'System was unable to create Calendar!'} = 'Систем није успео да креира календар!';
    $Self->{Translation}->{'No CalendarID!'} = 'Нема CalendarID!';
    $Self->{Translation}->{'You have no access to this calendar!'} = 'Немате приступ овом календару!';
    $Self->{Translation}->{'Edit Calendar'} = 'Измени календар';
    $Self->{Translation}->{'Error updating the calendar!'} = 'Грешка приликом измене календара';
    $Self->{Translation}->{'No permissions'} = 'Без дозволе';
    $Self->{Translation}->{'No permissions to create a new calendar!'} = 'Немате дозволу да креирате нови календар!';
    $Self->{Translation}->{'System was unable to create a new calendar!'} = 'Систем није успео да креира нови календар!';
    $Self->{Translation}->{'System was unable to import file!'} = 'Систем није успео да увезе фајл!';

    # Perl Module: Kernel/Modules/AgentAppointmentEdit.pm
    $Self->{Translation}->{'Every Day'} = 'Сваки дан';
    $Self->{Translation}->{'Every Week'} = 'Сваке седмице';
    $Self->{Translation}->{'Every Month'} = 'Сваког месеца';
    $Self->{Translation}->{'Every Year'} = 'Сваке године';
    $Self->{Translation}->{'until ...'} = 'до ...';
    $Self->{Translation}->{'for ... time(s)'} = 'укупно ... пут(а)';
    $Self->{Translation}->{'No permission!'} = 'Без дозволе!';
    $Self->{Translation}->{'Links could not be deleted!'} = 'Везе не могу бити обрисане!';
    $Self->{Translation}->{'Link could not be created!'} = 'Веза није могла бити креирана!';
    $Self->{Translation}->{'No permissions!'} = 'Без дозволе!';

    # Perl Module: Kernel/Modules/AgentAppointmentList.pm
    $Self->{Translation}->{'Ongoing appointments'} = 'Започети термини';

    # Perl Module: Kernel/Modules/AgentAppointmentTeamList.pm
    $Self->{Translation}->{'Unassigned'} = 'Недодељено';

    # Perl Module: Kernel/Modules/PublicCalendar.pm
    $Self->{Translation}->{'There was an error exporting the calendar!'} = 'Грешка приликом експортовања календара!';

    # SysConfig
    $Self->{Translation}->{'Appointment Calendar overview page.'} = 'Страница за преглед календара.';
    $Self->{Translation}->{'Appointment edit screen.'} = 'Страница за измену календара.';
    $Self->{Translation}->{'Appointment list'} = 'Листа термина';
    $Self->{Translation}->{'Appointment list.'} = 'Листа термина.';
    $Self->{Translation}->{'Calendar manage screen.'} = 'Страница за управљање календарима.';
    $Self->{Translation}->{'Defines the ticket number plugin for calendar appointments.'} = 'Дефинише plugin за број тикета у календар терминима.';
    $Self->{Translation}->{'Defines which backend should be used for managing calendars.'} =
        'Дефинише који позадинског модул ће бити коришћен за управљање календарима.';
    $Self->{Translation}->{'Edit appointment'} = 'Измена термина';
    $Self->{Translation}->{'Links appointments and tickets with a "Normal" type link.'} = 'Повезује термине и тикете "Нормалним" врстама веза.';
    $Self->{Translation}->{'List of colors in hexadecimal RGB which will be allocated to different user calendars. Make sure the colors are dark enough so white text can be overlayed on them. If the number of calendars exceeds the number of colors, the list will be reused from the start.'} =
        'Листа боја у хексадецималном RGB запису које ће бити коришћене за приказ календара. Обратите пажњу да боје буду довољно тамне тако да се може приказати бели текст на њима. Уколико број календара пређе преко броја боја, листа ће бити поново искоришћена из почетка.';
    $Self->{Translation}->{'Manage different calendars.'} = 'Управљање различитим календарима.';
    $Self->{Translation}->{'Manage team agents.'} = 'Управљање оператерима у тимовима.';
    $Self->{Translation}->{'Resource overview page.'} = 'Страница за преглед ресурса.';
    $Self->{Translation}->{'Resource overview screen.'} = 'Екран прегледа ресурса.';
    $Self->{Translation}->{'Resources list.'} = 'Листа ресурса.';
    $Self->{Translation}->{'Team agents management screen.'} = 'Екран управљања оператерима у тимовима.';
    $Self->{Translation}->{'Team list'} = 'Листа тимова';
    $Self->{Translation}->{'Team management screen.'} = 'Екран управљања тимовима.';
    $Self->{Translation}->{'Team management.'} = 'Управљање тимовима.';

}

1;
