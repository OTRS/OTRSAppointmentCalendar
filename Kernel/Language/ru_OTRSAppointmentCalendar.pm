# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::ru_OTRSAppointmentCalendar;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    # Template: AAANotification
    $Self->{Translation}->{'Appointment reminder notification'} = 'Уведомление о напоминании о мероприятии';
    $Self->{Translation}->{'You will receive a notification each time a reminder time is reached for one of your appointments.'} =
        'Вы получите такое уведомление всякий раз когда наступит срок напоминания по одному из ваших мероприятий.';

    # Template: AdminAppointmentNotificationEvent
    $Self->{Translation}->{'Appointment Notification Management'} = 'Управление уведомлениями о мероприятиях';
    $Self->{Translation}->{'Here you can upload a configuration file to import appointment notifications to your system. The file needs to be in .yml format as exported by the appointment notification module.'} =
        'Здесь вы можете загрузить конфигурационный файл для импорта уведомлений о мероприятиях в вашу систему. Файл должен быть в формате .yml в котором экспортируются из модуля уведомлений о мероприятиях.';
    $Self->{Translation}->{'Here you can choose which events will trigger this notification. An additional appointment filter can be applied below to only send for appointments with certain criteria.'} =
        'Здесь вы можете выбрать какие события будут включать это уведомление. Дополнительный фильтр может быть применён ниже для их отправки для мероприятий, удовлетворяющих заданному условию.';
    $Self->{Translation}->{'Appointment Filter'} = 'Фильтр мероприятий.';
    $Self->{Translation}->{'Team'} = 'Команда';
    $Self->{Translation}->{'Resource'} = 'Ресурсы';
    $Self->{Translation}->{'Notify user just once per day about a single appointment using a selected transport.'} =
        'Уведомить пользователя только раз в день для каждого отдельного мероприятия, используя указанный способ доставки.';
    $Self->{Translation}->{'Notifications are sent to an agent.'} = 'Уведомления направляются к агенту.';
    $Self->{Translation}->{'To get the first 20 character of the appointment title.'} = 'Чтобы получить первые 20 символов темы мероприятия.';
    $Self->{Translation}->{'To get the appointment attribute'} = 'Чтобы получить атрибут мероприятия';
    $Self->{Translation}->{'To get the calendar attribute'} = 'Чтобы получить атрибут календаря';

    # Template: AgentAppointmentAgendaOverview
    $Self->{Translation}->{'Agenda Overview'} = 'Обзор повестки дня';
    $Self->{Translation}->{'Manage Calendars'} = 'Управлять календарями';
    $Self->{Translation}->{'Add Appointment'} = 'Добавить мероприятие';
    $Self->{Translation}->{'Color'} = 'Цвет';
    $Self->{Translation}->{'End date'} = 'Дата окончания';
    $Self->{Translation}->{'Repeat'} = 'Повторение';
    $Self->{Translation}->{'No calendars found. Please add a calendar first by using Manage Calendars page.'} =
        'Не назначен календарь. Добавьте календарь используя экран управления календарями.';
    $Self->{Translation}->{'Appointment'} = 'Мероприятие';
    $Self->{Translation}->{'This is a repeating appointment'} = 'Это повторяющееся мероприятие';
    $Self->{Translation}->{'Would you like to edit just this occurrence or all occurrences?'} =
        'Вы желаете редактировать только текущее мероприятие или все его повторения';
    $Self->{Translation}->{'All occurrences'} = 'Все вхождения/копии';
    $Self->{Translation}->{'Just this occurrence'} = 'Только эту копию';

    # Template: AgentAppointmentCalendarManage
    $Self->{Translation}->{'Calendar Management'} = 'Управление календарями';
    $Self->{Translation}->{'Calendar Overview'} = 'Обзор календарей';
    $Self->{Translation}->{'Add new Calendar'} = 'Добавить новый календарь';
    $Self->{Translation}->{'Add Calendar'} = 'Добавить календарь';
    $Self->{Translation}->{'Import Appointments'} = 'Импортировать мероприятия';
    $Self->{Translation}->{'Calendar Import'} = 'Импорт календаря';
    $Self->{Translation}->{'Here you can upload a configuration file to import a calendar to your system. The file needs to be in .yml format as exported by calendar management module.'} =
        'Здесь вы можете загрузить файл конфигурации для импорта календаря в вашу систему. Файл должен быть в формате .yml файл экспорта из модуля управления календарями.';
    $Self->{Translation}->{'Upload calendar configuration'} = 'Загрузить конфигурацию календаря';
    $Self->{Translation}->{'Import Calendar'} = 'Импортировать календарь';
    $Self->{Translation}->{'Filter for calendars'} = 'Фильтр для Календарей';
    $Self->{Translation}->{'Depending on the group field, the system will allow users the access to the calendar according to their permission level.'} =
        'В зависимости от значения в поле group, система предоставляет агентам доступ к календарю в в соответствии с уровнем его полномочий.';
    $Self->{Translation}->{'Read only: users can see and export all appointments in the calendar.'} =
        'Только чтение: пользователи могут смотреть и экспортировать все мероприятия календаря.';
    $Self->{Translation}->{'Move into: users can modify appointments in the calendar, but without changing the calendar selection.'} =
        'Переместить в: пользователи могут изменять мероприятия в календаре, но без выбора календаря ';
    $Self->{Translation}->{'Create: users can create and delete appointments in the calendar.'} =
        'Создать: пользователи могут создавать и удалять мероприятия в календаре.';
    $Self->{Translation}->{'Read/write: users can manage the calendar itself.'} = 'Запись/чтение: пользователи имеют полное управление календарем.';
    $Self->{Translation}->{'URL'} = 'URL';
    $Self->{Translation}->{'Export calendar'} = 'Экспорт календаря';
    $Self->{Translation}->{'Download calendar'} = 'Загрузка календаря';
    $Self->{Translation}->{'Copy public calendar URL'} = 'Копировать публичный URL календаря';
    $Self->{Translation}->{'Calendar name'} = 'Имя календаря';
    $Self->{Translation}->{'Calendar with same name already exists.'} = 'Календарь с таким именем уже существует.';
    $Self->{Translation}->{'Permission group'} = 'Групповые права';
    $Self->{Translation}->{'Ticket Appointments'} = 'Мероприятия заявки';
    $Self->{Translation}->{'Rule'} = 'Правило';
    $Self->{Translation}->{'Use options below to narrow down for which tickets appointments will be automatically created.'} =
        'Используйте опции ниже, чтобы указать, какие мероприятия заявок будут созданы автоматически.';
    $Self->{Translation}->{'Please select a valid queue.'} = 'Выберите правильную очередь.';
    $Self->{Translation}->{'Search attributes'} = 'Атрибуты поиска';
    $Self->{Translation}->{'Define rules for creating automatic appointments in this calendar based on ticket data.'} =
        'Задать правила для автоматического создания мероприятий в этом календаре, основанных на данных заявки.';
    $Self->{Translation}->{'Add Rule'} = 'Добавить правило';
    $Self->{Translation}->{'More'} = 'Более';
    $Self->{Translation}->{'Less'} = 'Менее';

    # Template: AgentAppointmentCalendarOverview
    $Self->{Translation}->{'Add new Appointment'} = 'Добавить новое мероприятие';
    $Self->{Translation}->{'Calendars'} = 'Календари';
    $Self->{Translation}->{'This is an overview page for the Appointment Calendar.'} = 'Это страница обзора Мероприятий календаря.';
    $Self->{Translation}->{'Too many active calendars'} = 'Слишком много активных календарей';
    $Self->{Translation}->{'Please either turn some off first or increase the limit in configuration.'} =
        'Пожалуйста или отключите некоторые или увеличьте предельное количество в настройках.';
    $Self->{Translation}->{'Week'} = 'Неделя';
    $Self->{Translation}->{'Timeline Month'} = 'Месячный график';
    $Self->{Translation}->{'Timeline Week'} = 'Недельный график';
    $Self->{Translation}->{'Timeline Day'} = 'График дня';
    $Self->{Translation}->{'Jump'} = 'Перейти';
    $Self->{Translation}->{'Dismiss'} = 'Отклонить';
    $Self->{Translation}->{'Show'} = 'Показать';
    $Self->{Translation}->{'Basic information'} = 'Основные данные';
    $Self->{Translation}->{'Date/Time'} = 'Дата/Время';

    # Template: AgentAppointmentEdit
    $Self->{Translation}->{'Please set this to value before End date.'} = 'Пожалуйста, установите это значение до времени окончания.';
    $Self->{Translation}->{'Please set this to value after Start date.'} = 'Пожалуйста, установите это значение после времени начала.';
    $Self->{Translation}->{'This an occurrence of a repeating appointment.'} = 'Это ряд повторяющихся мероприятий.';
    $Self->{Translation}->{'Click here to see the parent appointment.'} = 'Кликните сюда чтобы открыть родительское мероприятие.';
    $Self->{Translation}->{'Click here to edit the parent appointment.'} = 'Кликните сюда чтобы редактировать родительское мероприятие.';
    $Self->{Translation}->{'Frequency'} = 'Частота';
    $Self->{Translation}->{'Every'} = 'Каждые';
    $Self->{Translation}->{'Relative point of time'} = 'Относительная точка времени';
    $Self->{Translation}->{'Are you sure you want to delete this appointment? This operation cannot be undone.'} =
        'Вы действительно желаете удалить это мероприятие? Эта операция не может быть отменена.';

    # Template: AgentAppointmentImport
    $Self->{Translation}->{'Appointment Import'} = 'Импорт мероприятий';
    $Self->{Translation}->{'Uploaded file must be in valid iCal format (.ics).'} = 'Загружаемый файл должен иметь правильный iCal формат (.ics).';
    $Self->{Translation}->{'If desired Calendar is not listed here, please make sure that you have at least \'create\' permissions.'} =
        'Если желаемый календарь отсутствует в списке, убедитесь, что у вас есть хотя бы права на создание - \'create\'.';
    $Self->{Translation}->{'Update existing appointments?'} = 'Обновить существующее мероприятие?';
    $Self->{Translation}->{'All existing appointments in the calendar with same UniqueID will be overwritten.'} =
        'Все существующие мероприятия в календаре с одинаковым UniqueID будут перезаписаны.';
    $Self->{Translation}->{'Upload calendar'} = 'Загрузить календарь';
    $Self->{Translation}->{'Import appointments'} = 'Импортировать мероприятия';

    # Template: AgentDashboardAppointmentCalendar
    $Self->{Translation}->{'New Appointment'} = 'Новое мероприятие';
    $Self->{Translation}->{'Soon'} = 'Скоро';
    $Self->{Translation}->{'5 days'} = '5 дней';

    # Perl Module: Kernel/Modules/AdminAppointmentNotificationEvent.pm
    $Self->{Translation}->{'Notification name already exists!'} = 'Уведомление с таким именем уже существует!';
    $Self->{Translation}->{'Agent (resources), who are selected within the appointment'} = 'Агент (ресурс), который выбран в мероприятии';
    $Self->{Translation}->{'All agents with (at least) read permission for the appointment (calendar)'} =
        'Все агенты с правом чтения (как минимум) для мероприятия (календаря)';
    $Self->{Translation}->{'All agents with write permission for the appointment (calendar)'} =
        'Все агенты с правом -w/записи на заявку для мероприятия (календаря)';

    # Perl Module: Kernel/Modules/AgentAppointmentCalendarManage.pm
    $Self->{Translation}->{'System was unable to create Calendar!'} = 'Системе не удалось создать календарь!';
    $Self->{Translation}->{'No CalendarID!'} = 'Отсутствует CalendarID!';
    $Self->{Translation}->{'You have no access to this calendar!'} = 'У вас нет прав на доступ к этому календарю!';
    $Self->{Translation}->{'Edit Calendar'} = 'Редактировать календарь';
    $Self->{Translation}->{'Error updating the calendar!'} = 'Ошибки при обновлении календаря!';
    $Self->{Translation}->{'Couldn\'t read calendar configuration file.'} = 'Невозможно прочитать файл настроек календаря.';
    $Self->{Translation}->{'Please make sure your file is valid.'} = 'Убедитесь, пожалуйста, что файл имеет правильный формат.';
    $Self->{Translation}->{'Could not import the calendar!'} = 'Невозможно импортировать календарь!';
    $Self->{Translation}->{'Calendar imported!'} = 'Календарь импортирован!';
    $Self->{Translation}->{'Need CalendarID!'} = 'Требуется CalendarID!';
    $Self->{Translation}->{'Could not retrieve data for given CalendarID'} = 'Невозможно получить данные для указанного CalendarID';
    $Self->{Translation}->{'Successfully imported %s appointment(s) to calendar %s.'} = 'Успешно импортированы %s мероприятий в календарь %s.';
    $Self->{Translation}->{'+5 minutes'} = ' +5 минут';
    $Self->{Translation}->{'+15 minutes'} = '+15 минут';
    $Self->{Translation}->{'+30 minutes'} = '+30 минут';
    $Self->{Translation}->{'+1 hour'} = '+1 час';

    # Perl Module: Kernel/Modules/AgentAppointmentCalendarOverview.pm
    $Self->{Translation}->{'All appointments'} = 'Все мероприятия';
    $Self->{Translation}->{'Appointments assigned to me'} = 'Мероприятия назначенные мне';
    $Self->{Translation}->{'Showing only appointments assigned to you! Change settings'} = 'Показаны только мероприятия назначенные Вам! Измените настройки';

    # Perl Module: Kernel/Modules/AgentAppointmentEdit.pm
    $Self->{Translation}->{'Appointment not found!'} = 'Мероприятия не найдены!';
    $Self->{Translation}->{'Never'} = 'Никогда';
    $Self->{Translation}->{'Every Day'} = 'Каждый день';
    $Self->{Translation}->{'Every Week'} = 'Каждую неделю';
    $Self->{Translation}->{'Every Month'} = 'Каждый месяц';
    $Self->{Translation}->{'Every Year'} = 'Каждый год';
    $Self->{Translation}->{'Custom'} = 'Пользовательский';
    $Self->{Translation}->{'Daily'} = 'Ежедневно';
    $Self->{Translation}->{'Weekly'} = 'Еженедельно';
    $Self->{Translation}->{'Monthly'} = 'Ежемесячно';
    $Self->{Translation}->{'Yearly'} = 'Ежегодно';
    $Self->{Translation}->{'every'} = 'каждые';
    $Self->{Translation}->{'for %s time(s)'} = 'повторить %s раз(а)';
    $Self->{Translation}->{'until ...'} = 'до ...';
    $Self->{Translation}->{'for ... time(s)'} = 'повторить ... раз(а)';
    $Self->{Translation}->{'until %s'} = 'до %s';
    $Self->{Translation}->{'No notification'} = 'Не уведомлять';
    $Self->{Translation}->{'%s minute(s) before'} = 'за %s минут(у) до';
    $Self->{Translation}->{'%s hour(s) before'} = 'за %s час(ов) до';
    $Self->{Translation}->{'%s day(s) before'} = 'за %s день(дней) до';
    $Self->{Translation}->{'%s week before'} = 'за %s неделю до';
    $Self->{Translation}->{'before the appointment starts'} = 'до начала мероприятия';
    $Self->{Translation}->{'after the appointment has been started'} = 'после начала мероприятия';
    $Self->{Translation}->{'before the appointment ends'} = 'до окончания мероприятия';
    $Self->{Translation}->{'after the appointment has been ended'} = 'после окончания мероприятия';
    $Self->{Translation}->{'No permission!'} = 'Нет прав доступа!';
    $Self->{Translation}->{'Links could not be deleted!'} = 'Связь не может быть удалена!';
    $Self->{Translation}->{'Link could not be created!'} = 'Связь не может быть создана!';
    $Self->{Translation}->{'Cannot delete ticket appointment!'} = 'Невозможно удалить мероприятие заявки!';
    $Self->{Translation}->{'No permissions!'} = 'Нет прав доступа!';

    # Perl Module: Kernel/Modules/AgentAppointmentImport.pm
    $Self->{Translation}->{'No permissions'} = 'Нет прав доступа';
    $Self->{Translation}->{'System was unable to import file!'} = 'Системе не удалось импортировать файл!';
    $Self->{Translation}->{'Please check the log for more information.'} = '';

    # Perl Module: Kernel/Modules/AgentAppointmentList.pm
    $Self->{Translation}->{'+%d more'} = '+%d еще';

    # Perl Module: Kernel/Modules/PublicCalendar.pm
    $Self->{Translation}->{'No %s!'} = 'Отсутствует %s!';
    $Self->{Translation}->{'No such user!'} = 'Такой пользователь не существует!';
    $Self->{Translation}->{'Invalid calendar!'} = 'Недействительный календарь!';
    $Self->{Translation}->{'Invalid URL!'} = 'Неверный URL!';
    $Self->{Translation}->{'There was an error exporting the calendar!'} = 'Произошла ошибка при экспорте календаря!';

    # Perl Module: Kernel/Output/HTML/Dashboard/AppointmentCalendar.pm
    $Self->{Translation}->{'Refresh (minutes)'} = 'Интервал обновления (в минутах)';

    # SysConfig
    $Self->{Translation}->{'Appointment Calendar overview page.'} = 'Страница обзора Календаря мероприятий.';
    $Self->{Translation}->{'Appointment Notifications'} = 'Уведомления о мероприятиях';
    $Self->{Translation}->{'Appointment calendar event module that prepares notification entries for appointments.'} =
        'Модуль управления событиями Календаря мероприятий, который подготавливает уведомления для мероприятий.';
    $Self->{Translation}->{'Appointment calendar event module that updates the ticket with data from ticket appointment.'} =
        'Модуль управления событиями Календаря мероприятий, который обновляет заявки с данными из мероприятий заявки.';
    $Self->{Translation}->{'Appointment edit screen.'} = 'Экран редактирования Мероприятий.';
    $Self->{Translation}->{'Appointment list'} = 'Список мероприятий';
    $Self->{Translation}->{'Appointment list.'} = 'Список мероприятий.';
    $Self->{Translation}->{'Appointment notifications'} = 'Уведомления о мероприятиях';
    $Self->{Translation}->{'Appointments'} = 'Мероприятия';
    $Self->{Translation}->{'Calendar manage screen.'} = 'Экран Управление календарями.';
    $Self->{Translation}->{'Choose for which kind of appointment changes you want to receive notifications.'} =
        'Выберите для какого типа изменений мероприятий вы желаете получать уведомления.';
    $Self->{Translation}->{'Create a new calendar appointment linked to this ticket'} = 'Создать новое мероприятие календаря связанное с этой заявкой';
    $Self->{Translation}->{'Create and manage appointment notifications.'} = 'Создание и управление уведомлениями по мероприятиям.';
    $Self->{Translation}->{'Create new appointment.'} = 'Создать новое мероприятие.';
    $Self->{Translation}->{'Define which columns are shown in the linked appointment widget (LinkObject::ViewMode = "complex"). Possible settings: 0 = Disabled, 1 = Available, 2 = Enabled by default.'} =
        'Задайте, какие колонки отображать в связанном виджете мероприятий (LinkObject::ViewMode = "complex"). Возможные значения: 0 = Отключено, 1 = Да, 2 = Включена по умолчанию.';
    $Self->{Translation}->{'Defines an icon with link to the google map page of the current location in appointment edit screen.'} =
        'Задает иконку со ссылкой на страницу текущего местоположения в Google Map на экране редактирования мероприятий.';
    $Self->{Translation}->{'Defines the event object types that will be handled via AdminAppointmentNotificationEvent.'} =
        'Задает типы событий, которые будут управляться  с помощью AdminAppointmentNotificationEvent.';
    $Self->{Translation}->{'Defines the list of params that can be passed to ticket search function.'} =
        'Задает перечень атрибутов, которые могут использоваться при поиске заявок.';
    $Self->{Translation}->{'Defines the ticket appointment type backend for ticket dynamic field date time.'} =
        'Задает модуль обработки для мероприятий заявки для динамических полей типа дата/время / date time.';
    $Self->{Translation}->{'Defines the ticket appointment type backend for ticket escalation time.'} =
        'Задает модуль обработки для мероприятий заявки по ticket escalation time.';
    $Self->{Translation}->{'Defines the ticket appointment type backend for ticket pending time.'} =
        'Задает модуль обработки для мероприятий заявки по ticket pending time.';
    $Self->{Translation}->{'Defines the ticket plugin for calendar appointments.'} = 'Задает плагин обработки заявок для мероприятий календаря.';
    $Self->{Translation}->{'DynamicField_%s'} = 'DynamicField_%s';
    $Self->{Translation}->{'Edit appointment'} = 'Редактировать мероприятие';
    $Self->{Translation}->{'First response time'} = 'Время до первого ответа';
    $Self->{Translation}->{'Import appointments screen.'} = 'Экран импорта мероприятий.';
    $Self->{Translation}->{'Links appointments and tickets with a "Normal" type link.'} = 'Связывает мероприятия с заявками связью типа "Normal/Обычная".';
    $Self->{Translation}->{'List of all appointment events to be displayed in the GUI.'} = 'Список всех событий, для мероприятий, отображаемых в интерфейсе.';
    $Self->{Translation}->{'List of all calendar events to be displayed in the GUI.'} = 'Список всех событий календаря, отображаемых в интерфейсе.';
    $Self->{Translation}->{'List of colors in hexadecimal RGB which will be available for selection during calendar creation. Make sure the colors are dark enough so white text can be overlayed on them.'} =
        'Список цветов в шестнадцатеричном RGB доступных для выбора при создании календаря. Убедитесь при выборе, что цвет фона достаточно темный, чтобы белый текст был на нем виден/читаем.';
    $Self->{Translation}->{'Manage different calendars.'} = 'Управлять различными календарями.';
    $Self->{Translation}->{'Maximum number of active calendars in overview screens. Please note that large number of active calendars can have a performance impact on your server by making too much simultaneous calls.'} =
        'Максимальное количество активных календарей на экранах обзора. Помните, что большое число активных календарей может оказать влияние на производительность сервера, делая слишком много одновременных вызовов.';
    $Self->{Translation}->{'OTRS doesn\'t support recurring Appointments without end date or number of iterations. During import process, it might happen that ICS file contains such Appointments. Instead, system creates all Appointments in the past, plus Appointments for the next n months (120 months/10 years by default).'} =
        'OTRS не поддерживает повторяющиеся Мероприятия без даты окончания или количества повторений. При импорте может так случиться, что ICS файл содержит подобные мероприятия. В результате может так случиться, что система создаст все мероприятия в прошлом и, дополнительно, для последующих n месяцев (120 месяцев/10 лет по умолчанию).';
    $Self->{Translation}->{'Overview of all appointments.'} = 'Обзор всех мероприятий.';
    $Self->{Translation}->{'Pending time'} = 'Время в ожидании';
    $Self->{Translation}->{'Plugin search'} = 'Поисковый плагин';
    $Self->{Translation}->{'Plugin search module for autocomplete.'} = 'Поисковый плагин для автозавершения.';
    $Self->{Translation}->{'Public Calendar'} = 'Общедоступный календарь';
    $Self->{Translation}->{'Public calendar.'} = 'Общедоступный календарь.';
    $Self->{Translation}->{'Resource Overview'} = 'Обзор ресурсов';
    $Self->{Translation}->{'Resource Overview (OTRS Business Solution™)'} = 'Обзор ресурсов (OTRS Business Solution™)';
    $Self->{Translation}->{'Shows a link in the menu for creating a calendar appointment linked to the ticket directly from the ticket zoom view of the agent interface. Additional access control to show or not show this link can be done by using Key "Group" and Content like "rw:group1;move_into:group2". To cluster menu items use for Key "ClusterName" and for the Content any name you want to see in the UI. Use "ClusterPriority" to configure the order of a certain cluster within the toolbar.'} =
        'Отображает ссылку/пункт меню для создания мероприятия календаря, связанного с заявкой непосредственно из подробного просмотра заявки/TicketZoom в интерфейсе агента. Дополнительно, можно ограничить доступ к этому пункту меню, использованием ключа "Group", где в содержании указывается перечень групп, которым эта кнопка будет доступна "rw:group1;move_into:group2". Для организации пунктов меню в группы/кластеры используйте в качестве ключа "ClusterName" и в содержании укажите то имя, которое желаете увидеть в строке меню. Используйте "ClusterPriority" для настройки порядка отображения групп/кластеров в меню.';
    $Self->{Translation}->{'Solution time'} = 'Время решения';
    $Self->{Translation}->{'Transport selection for appointment notifications.'} = 'Выбор способа отправки для уведомлений по мероприятиям.';
    $Self->{Translation}->{'Triggers add or update of automatic calendar appointments based on certain ticket times.'} =
        'Переключает добавить или изменить автоматическое создание мероприятий календаря, основанное на определенных временНых параметрах заявки';
    $Self->{Translation}->{'Update time'} = 'Время изменения заявки';

}

1;
