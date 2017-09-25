# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::uk_OTRSAppointmentCalendar;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    # Template: AAANotification
    $Self->{Translation}->{'Appointment reminder notification'} = 'повідомлення нагадування про Подію';
    $Self->{Translation}->{'You will receive a notification each time a reminder time is reached for one of your appointments.'} =
        'Ви будете отримувати повідомлення щоразу, як наставатиме визначений час (для Вашої Події)';

    # Template: AdminAppointmentNotificationEvent
    $Self->{Translation}->{'Appointment Notification Management'} = 'Управління повідомленнями Подій';
    $Self->{Translation}->{'Here you can upload a configuration file to import appointment notifications to your system. The file needs to be in .yml format as exported by the appointment notification module.'} =
        '';
    $Self->{Translation}->{'Here you can choose which events will trigger this notification. An additional appointment filter can be applied below to only send for appointments with certain criteria.'} =
        '';
    $Self->{Translation}->{'Appointment Filter'} = 'Фільтр Подій';
    $Self->{Translation}->{'Team'} = 'Команда';
    $Self->{Translation}->{'Resource'} = 'Ресурс';
    $Self->{Translation}->{'Notify user just once per day about a single appointment using a selected transport.'} =
        'Повідомляти користувача тільки один раз в день по одній події з використанням обраного способу';
    $Self->{Translation}->{'Notifications are sent to an agent.'} = 'Повідомлення, що надсилаються агенту';
    $Self->{Translation}->{'To get the first 20 character of the appointment title.'} = 'Для отримання перших 20-ти символів заголовку Події';
    $Self->{Translation}->{'To get the appointment attribute'} = 'Для отримання атрибуту Події';
    $Self->{Translation}->{'To get the calendar attribute'} = 'Для отримання аатрибутів календаря';

    # Template: AgentAppointmentAgendaOverview
    $Self->{Translation}->{'Agenda Overview'} = 'Огляд порядку денного';
    $Self->{Translation}->{'Manage Calendars'} = 'керувати календарями';
    $Self->{Translation}->{'Add Appointment'} = 'Додати подію';
    $Self->{Translation}->{'Color'} = 'Колір';
    $Self->{Translation}->{'End date'} = 'Кінцева дата';
    $Self->{Translation}->{'Repeat'} = 'Повторити';
    $Self->{Translation}->{'No calendars found. Please add a calendar first by using Manage Calendars page.'} =
        'Календарі не знайдені. Будь ласка, спочатку додайте календар за допомогою сторінки Управління календарями';
    $Self->{Translation}->{'Appointment'} = 'Подія';
    $Self->{Translation}->{'This is a repeating appointment'} = 'Це повторювана подія';
    $Self->{Translation}->{'Would you like to edit just this occurrence or all occurrences?'} =
        'Ви хочете змінити тільки цей випадок чи всі випадки?';
    $Self->{Translation}->{'All occurrences'} = 'Всі випадки';
    $Self->{Translation}->{'Just this occurrence'} = 'Лише цей випадок';

    # Template: AgentAppointmentCalendarManage
    $Self->{Translation}->{'Calendar Management'} = 'Керування календарем';
    $Self->{Translation}->{'Calendar Overview'} = 'Перегляд календаря';
    $Self->{Translation}->{'Add new Calendar'} = 'Додати новий календар';
    $Self->{Translation}->{'Add Calendar'} = 'Додати календар';
    $Self->{Translation}->{'Import Appointments'} = 'Імпортувати Події';
    $Self->{Translation}->{'Calendar Import'} = 'Імпорт календаря';
    $Self->{Translation}->{'Here you can upload a configuration file to import a calendar to your system. The file needs to be in .yml format as exported by calendar management module.'} =
        'Тут ви можете завантажити файл конфігурації, щоб імпортувати календар до Вашої системи.Файл повинен бути в .yml форматі, що експортуються модулем управління календаря';
    $Self->{Translation}->{'Upload calendar configuration'} = 'Завантажити конфігурацію календаря';
    $Self->{Translation}->{'Import Calendar'} = 'Імпорт календаря';
    $Self->{Translation}->{'Filter for calendars'} = 'Фільтр для календаря';
    $Self->{Translation}->{'Depending on the group field, the system will allow users the access to the calendar according to their permission level.'} =
        'Залежно від поля групи, система надасть користувачам доступ до календаря відповідно до їх рівня доступу';
    $Self->{Translation}->{'Read only: users can see and export all appointments in the calendar.'} =
        'Тільки для читання: користувачі зможуть переглядати та експортувати всі події в календарі';
    $Self->{Translation}->{'Move into: users can modify appointments in the calendar, but without changing the calendar selection.'} =
        'Перемістити в: користувачі можуть змінювати події в календарі, але без зміни вибору календаря';
    $Self->{Translation}->{'Create: users can create and delete appointments in the calendar.'} =
        'Створити: користувачі можуть створювати і видаляти зустрічі в календарі';
    $Self->{Translation}->{'Read/write: users can manage the calendar itself.'} = 'Читання/запис: користувачі можуть управляти календарем самостійно';
    $Self->{Translation}->{'URL'} = 'шлях URL';
    $Self->{Translation}->{'Export calendar'} = 'Експортувати календар';
    $Self->{Translation}->{'Download calendar'} = 'Завантажити календар';
    $Self->{Translation}->{'Copy public calendar URL'} = 'Копіювати URL публічного календаря';
    $Self->{Translation}->{'Calendar name'} = 'Імя календаря';
    $Self->{Translation}->{'Calendar with same name already exists.'} = 'Календар з таким імям уже існує';
    $Self->{Translation}->{'Permission group'} = 'Група дозволів';
    $Self->{Translation}->{'Ticket Appointments'} = 'Події заявки';
    $Self->{Translation}->{'Rule'} = 'Правило';
    $Self->{Translation}->{'Use options below to narrow down for which tickets appointments will be automatically created.'} =
        'Використовуйте опції нижче, щоб звузити, для яких тікетів події будуть створені автоматично.';
    $Self->{Translation}->{'Please select a valid queue.'} = 'Будь ласка виберіть дійсну чергу';
    $Self->{Translation}->{'Search attributes'} = 'Пошук атрибутів';
    $Self->{Translation}->{'Define rules for creating automatic appointments in this calendar based on ticket data.'} =
        'Визначення правил для створення автоматичних подій в цьому календарі на підставі даних заявки';
    $Self->{Translation}->{'Add Rule'} = 'Додати правило';
    $Self->{Translation}->{'More'} = 'Більше';
    $Self->{Translation}->{'Less'} = 'Менше';

    # Template: AgentAppointmentCalendarOverview
    $Self->{Translation}->{'Add new Appointment'} = 'Додати нову Подію';
    $Self->{Translation}->{'Calendars'} = 'Календарі';
    $Self->{Translation}->{'Too many active calendars'} = 'Дуже багато активних календарів';
    $Self->{Translation}->{'Please either turn some off first or increase the limit in configuration.'} =
        'Будь ласка вимкніть деякі або збільшіть ліміт в конфігурації';
    $Self->{Translation}->{'Week'} = 'Тиждень';
    $Self->{Translation}->{'Timeline Month'} = 'Огляд місяця';
    $Self->{Translation}->{'Timeline Week'} = 'Огляд тижня';
    $Self->{Translation}->{'Timeline Day'} = 'Огляд дня';
    $Self->{Translation}->{'Jump'} = 'Перейти';
    $Self->{Translation}->{'Dismiss'} = 'Відхилити';
    $Self->{Translation}->{'Show'} = 'Показати';
    $Self->{Translation}->{'Basic information'} = 'Базова інформація';
    $Self->{Translation}->{'Date/Time'} = 'Дата/Час';

    # Template: AgentAppointmentEdit
    $Self->{Translation}->{'Please set this to value before End date.'} = 'Будь ласка встановіть це перед датою заершення';
    $Self->{Translation}->{'Please set this to value after Start date.'} = 'Будь ласка встановіть це перед датою початку';
    $Self->{Translation}->{'This an occurrence of a repeating appointment.'} = 'Цей випадок повторюваної події';
    $Self->{Translation}->{'Click here to see the parent appointment.'} = 'Натисніть сюди, щоб побачити батьківську Подію';
    $Self->{Translation}->{'Click here to edit the parent appointment.'} = 'Натисніть тут для редагування батьківського календаря';
    $Self->{Translation}->{'Frequency'} = 'Частота';
    $Self->{Translation}->{'Every'} = 'Кожні';
    $Self->{Translation}->{'Relative point of time'} = 'Відносна часова точка';
    $Self->{Translation}->{'Are you sure you want to delete this appointment? This operation cannot be undone.'} =
        'Ви впевнені, що хочете видалити цю подію? Ця операція не може бути скасована';

    # Template: AgentAppointmentImport
    $Self->{Translation}->{'Appointment Import'} = 'Імпортувати Подію';
    $Self->{Translation}->{'Uploaded file must be in valid iCal format (.ics).'} = 'Завантажений файл повинен бути в правильному ical форматі (.ics)';
    $Self->{Translation}->{'If desired Calendar is not listed here, please make sure that you have at least \'create\' permissions.'} =
        'Якщо обраний календар не в списку, переконайтеся будь ласка, що у вас є повноваження на створення';
    $Self->{Translation}->{'Update existing appointments?'} = 'Оновити існуючі Події';
    $Self->{Translation}->{'All existing appointments in the calendar with same UniqueID will be overwritten.'} =
        'Всі існуючі події в календарі з таким же UniqueID будуть перезаписані';
    $Self->{Translation}->{'Upload calendar'} = 'Завантажити календар';
    $Self->{Translation}->{'Import appointments'} = 'Імпортувати Події';

    # Template: AgentDashboardAppointmentCalendar
    $Self->{Translation}->{'New Appointment'} = 'Нова Подія';
    $Self->{Translation}->{'Soon'} = 'Скоро';
    $Self->{Translation}->{'5 days'} = '5 днів';

    # Perl Module: Kernel/Modules/AdminAppointmentNotificationEvent.pm
    $Self->{Translation}->{'Notification name already exists!'} = 'Імя нагадування вже існує';
    $Self->{Translation}->{'Agent (resources), who are selected within the appointment'} = 'Агент (ресурси), які вибираються в рамках події';
    $Self->{Translation}->{'All agents with (at least) read permission for the appointment (calendar)'} =
        'Всі агенти з дозволом на читання для події (календар)';
    $Self->{Translation}->{'All agents with write permission for the appointment (calendar)'} =
        'Всі агенти, які мають дозвіл на запис для подій (календар)';

    # Perl Module: Kernel/Modules/AgentAppointmentCalendarManage.pm
    $Self->{Translation}->{'System was unable to create Calendar!'} = 'Система не може створити календар!';
    $Self->{Translation}->{'No CalendarID!'} = 'Немає CalendarID';
    $Self->{Translation}->{'You have no access to this calendar!'} = 'Ви не маєте доступу до цього календаря!';
    $Self->{Translation}->{'Edit Calendar'} = 'Редагувати календар';
    $Self->{Translation}->{'Error updating the calendar!'} = 'Помилка при оновлденні календаря';
    $Self->{Translation}->{'Couldn\'t read calendar configuration file.'} = 'Не можливо прочитати файл конфігурації календаря';
    $Self->{Translation}->{'Please make sure your file is valid.'} = 'Будь ласка переконайтесь, що фай файл не пошкоджений';
    $Self->{Translation}->{'Could not import the calendar!'} = 'Не можливо імпортувати календар';
    $Self->{Translation}->{'Calendar imported!'} = 'Календар імпортовано';
    $Self->{Translation}->{'Need CalendarID!'} = 'Потреьується CalendarID';
    $Self->{Translation}->{'Could not retrieve data for given CalendarID'} = 'Не можливо отримати дані для CalendarID';
    $Self->{Translation}->{'Successfully imported %s appointment(s) to calendar %s.'} = 'Успішно імпортовано %s подій в календар %s';
    $Self->{Translation}->{'+5 minutes'} = '+5 хвилин';
    $Self->{Translation}->{'+15 minutes'} = '+15 хвилин';
    $Self->{Translation}->{'+30 minutes'} = '+30 хвилин';
    $Self->{Translation}->{'+1 hour'} = '+1 година';

    # Perl Module: Kernel/Modules/AgentAppointmentCalendarOverview.pm
    $Self->{Translation}->{'All appointments'} = 'Всі події';
    $Self->{Translation}->{'Appointments assigned to me'} = 'Події, повязані зі мною';
    $Self->{Translation}->{'Showing only appointments assigned to you! Change settings'} = 'Показуються тільки повязані з вами події. Змінити налаштуванння.';

    # Perl Module: Kernel/Modules/AgentAppointmentEdit.pm
    $Self->{Translation}->{'Appointment not found!'} = 'Подія не знайдена!';
    $Self->{Translation}->{'Never'} = 'Ніколи';
    $Self->{Translation}->{'Every Day'} = 'Щодня';
    $Self->{Translation}->{'Every Week'} = 'Щотижня';
    $Self->{Translation}->{'Every Month'} = 'Щомісяця';
    $Self->{Translation}->{'Every Year'} = 'Щороку';
    $Self->{Translation}->{'Custom'} = 'Користувацький вибір';
    $Self->{Translation}->{'Daily'} = 'Щоденно';
    $Self->{Translation}->{'Weekly'} = 'Щотижнево';
    $Self->{Translation}->{'Monthly'} = 'Щомісячно';
    $Self->{Translation}->{'Yearly'} = 'Щорічно';
    $Self->{Translation}->{'every'} = 'кожні';
    $Self->{Translation}->{'for %s time(s)'} = 'для %s разу(ів)';
    $Self->{Translation}->{'until ...'} = 'доки...';
    $Self->{Translation}->{'for ... time(s)'} = 'до ... разу(ів)';
    $Self->{Translation}->{'until %s'} = 'доки %s';
    $Self->{Translation}->{'No notification'} = 'Немає повідомлень';
    $Self->{Translation}->{'%s minute(s) before'} = '%s хвилин до';
    $Self->{Translation}->{'%s hour(s) before'} = '%s годин до';
    $Self->{Translation}->{'%s day(s) before'} = '%s дні(ів) до';
    $Self->{Translation}->{'%s week before'} = '%s тижнів до';
    $Self->{Translation}->{'before the appointment starts'} = 'перед початком події';
    $Self->{Translation}->{'after the appointment has been started'} = 'після початку події';
    $Self->{Translation}->{'before the appointment ends'} = 'перед завершенням події';
    $Self->{Translation}->{'after the appointment has been ended'} = 'після завершення події';
    $Self->{Translation}->{'No permission!'} = 'Немає повноважень!';
    $Self->{Translation}->{'Cannot delete ticket appointment!'} = 'Не можливо видалити подію заявки';
    $Self->{Translation}->{'No permissions!'} = 'Немає повновавжень!';

    # Perl Module: Kernel/Modules/AgentAppointmentImport.pm
    $Self->{Translation}->{'No permissions'} = 'Немає повноважень';
    $Self->{Translation}->{'System was unable to import file!'} = 'Система не може імпортувати файл';
    $Self->{Translation}->{'Please check the log for more information.'} = 'Будь ласка перевірте лог для додаткової інформації';

    # Perl Module: Kernel/Modules/AgentAppointmentList.pm
    $Self->{Translation}->{'+%d more'} = '+%d більше';

    # Perl Module: Kernel/Modules/PublicCalendar.pm
    $Self->{Translation}->{'No %s!'} = 'немає %s';
    $Self->{Translation}->{'No such user!'} = 'Відсутній такий користувач';
    $Self->{Translation}->{'Invalid calendar!'} = 'Хибний календар';
    $Self->{Translation}->{'Invalid URL!'} = 'Хибне посилання';
    $Self->{Translation}->{'There was an error exporting the calendar!'} = 'Сталась помилка під час експорту календаря';

    # Perl Module: Kernel/Output/HTML/Dashboard/AppointmentCalendar.pm
    $Self->{Translation}->{'Refresh (minutes)'} = 'Оновлення (хвилини)';

    # SysConfig
    $Self->{Translation}->{'Appointment Calendar overview page.'} = 'Сторінка перегляду Подій календаря';
    $Self->{Translation}->{'Appointment Notifications'} = 'Повідомлення по події';
    $Self->{Translation}->{'Appointment calendar event module that prepares notification entries for appointments.'} =
        'модуль подій календаря, який готує записи повідомлення для подій';
    $Self->{Translation}->{'Appointment calendar event module that updates the ticket with data from ticket appointment.'} =
        'модуль подій календаря, який оновлює тікет з даними від подій заявки';
    $Self->{Translation}->{'Appointment edit screen.'} = 'Екран редагування подій';
    $Self->{Translation}->{'Appointment list'} = 'Перелік подій';
    $Self->{Translation}->{'Appointment list.'} = 'Перелік подій';
    $Self->{Translation}->{'Appointment notifications'} = 'Повідомлення по події';
    $Self->{Translation}->{'Appointments'} = 'Події';
    $Self->{Translation}->{'Calendar manage screen.'} = 'Екран керування календарем';
    $Self->{Translation}->{'Choose for which kind of appointment changes you want to receive notifications.'} =
        'Вибрати який вид повідомлення про зміни події Ви хочете отримувати';
    $Self->{Translation}->{'Create a new calendar appointment linked to this ticket'} = 'Створити новий календар подій повязаний з цією заявкою';
    $Self->{Translation}->{'Create and manage appointment notifications.'} = 'Створити і керувати повідомленнями про події';
    $Self->{Translation}->{'Create new appointment.'} = 'Створити нову подію';
    $Self->{Translation}->{'Define which columns are shown in the linked appointment widget (LinkObject::ViewMode = "complex"). Possible settings: 0 = Disabled, 1 = Available, 2 = Enabled by default.'} =
        'Задає які колонки будуть показані в повязааному віджеті подій(LinkObject::ViewMode = "complex"). Possible settings: 0 = Disabled, 1 = Available, 2 = Enabled by default.';
    $Self->{Translation}->{'Defines an icon with link to the google map page of the current location in appointment edit screen.'} =
        'Визначає іконку з посиланням на сторінку карт Google з поточним місцезнаходженням у вікні редагування події';
    $Self->{Translation}->{'Defines the event object types that will be handled via AdminAppointmentNotificationEvent.'} =
        'Визначає типи обєктів подій, які будуть оброблятися за допомогою AdminAppointmentNotificationEvent';
    $Self->{Translation}->{'Defines the list of params that can be passed to ticket search function.'} =
        'Визнгачає перелік пораметрів які можуть бути в опціях пошуку по заявці';
    $Self->{Translation}->{'Defines the ticket appointment type backend for ticket dynamic field date time.'} =
        '';
    $Self->{Translation}->{'Defines the ticket appointment type backend for ticket escalation time.'} =
        '';
    $Self->{Translation}->{'Defines the ticket appointment type backend for ticket pending time.'} =
        '';
    $Self->{Translation}->{'Defines the ticket plugin for calendar appointments.'} = '';
    $Self->{Translation}->{'DynamicField_%s'} = 'DynamicField_%s';
    $Self->{Translation}->{'Edit appointment'} = 'Редагувати подію';
    $Self->{Translation}->{'First response time'} = 'Час першої відповіді';
    $Self->{Translation}->{'Import appointments screen.'} = 'Імпортувати еркан подій';
    $Self->{Translation}->{'Links appointments and tickets with a "Normal" type link.'} = 'Повязати події і заявки з "Normal" типом звязку ';
    $Self->{Translation}->{'List of all appointment events to be displayed in the GUI.'} = 'Перелік всіх подій для відображаються в GUI';
    $Self->{Translation}->{'List of all calendar events to be displayed in the GUI.'} = 'Перелік всіх подій календаря для відображення в GUI';
    $Self->{Translation}->{'List of colors in hexadecimal RGB which will be available for selection during calendar creation. Make sure the colors are dark enough so white text can be overlayed on them.'} =
        '';
    $Self->{Translation}->{'Manage different calendars.'} = 'Керувати різнимим календарями';
    $Self->{Translation}->{'Maximum number of active calendars in overview screens. Please note that large number of active calendars can have a performance impact on your server by making too much simultaneous calls.'} =
        '';
    $Self->{Translation}->{'OTRS doesn\'t support recurring Appointments without end date or number of iterations. During import process, it might happen that ICS file contains such Appointments. Instead, system creates all Appointments in the past, plus Appointments for the next n months (120 months/10 years by default).'} =
        '';
    $Self->{Translation}->{'Overview of all appointments.'} = 'Переглянути всі події';
    $Self->{Translation}->{'Pending time'} = 'час, що залишився';
    $Self->{Translation}->{'Plugin search'} = 'Пошук утиліти';
    $Self->{Translation}->{'Plugin search module for autocomplete.'} = 'Утиліта пошуку модуля для автозаповнення';
    $Self->{Translation}->{'Public Calendar'} = 'Публічний календар';
    $Self->{Translation}->{'Public calendar.'} = 'Публічний календар';
    $Self->{Translation}->{'Resource Overview'} = 'Перегляд ресурсів';
    $Self->{Translation}->{'Resource Overview (OTRS Business Solution™)'} = 'Перегляд ресурів (OTRS Business Solution™)';
    $Self->{Translation}->{'Shows a link in the menu for creating a calendar appointment linked to the ticket directly from the ticket zoom view of the agent interface. Additional access control to show or not show this link can be done by using Key "Group" and Content like "rw:group1;move_into:group2". To cluster menu items use for Key "ClusterName" and for the Content any name you want to see in the UI. Use "ClusterPriority" to configure the order of a certain cluster within the toolbar.'} =
        '';
    $Self->{Translation}->{'Solution time'} = 'Час вирішення';
    $Self->{Translation}->{'Transport selection for appointment notifications.'} = 'Вибір способу для відправки повідомлень по подіях';
    $Self->{Translation}->{'Triggers add or update of automatic calendar appointments based on certain ticket times.'} =
        'Тригери для додавання чи автоматичного оновлення подій на основі певних часів тікету';
    $Self->{Translation}->{'Update time'} = 'Час оновлення';

}

1;
