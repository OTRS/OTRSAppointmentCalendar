# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Kernel::Language::zh_CN_OTRSAppointmentCalendar;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    # Template: AAANotification
    $Self->{Translation}->{'Appointment reminder notification'} = '预约提醒通知。';
    $Self->{Translation}->{'You will receive a notification each time a reminder time is reached for one of your appointments.'} =
        '每当你的一个预约到达提醒时间时，你就会收到一个通知。';

    # Template: AdminAppointmentNotificationEvent
    $Self->{Translation}->{'Appointment Notification Management'} = '预约通知管理';
    $Self->{Translation}->{'Here you can upload a configuration file to import appointment notifications to your system. The file needs to be in .yml format as exported by the appointment notification module.'} =
        '在这里你可以上传一个配置文件以便导入预约通知，必须是与预约通知模块导出的文件一样的.yml格式。';
    $Self->{Translation}->{'Here you can choose which events will trigger this notification. An additional appointment filter can be applied below to only send for appointments with certain criteria.'} =
        '在这里你可以选择哪个事件将会触发这个通知，下面的预约过滤器可以选择符合特定条件的预约。';
    $Self->{Translation}->{'Appointment Filter'} = '过滤预约';
    $Self->{Translation}->{'Team'} = '团队';
    $Self->{Translation}->{'Resource'} = '资源';
    $Self->{Translation}->{'Notify user just once per day about a single appointment using a selected transport.'} =
        '每个预约的通知使用选择的方式一天只发送一次。';
    $Self->{Translation}->{'Notifications are sent to an agent.'} = '发送给服务人员的通知。';
    $Self->{Translation}->{'To get the first 20 character of the appointment title.'} = '获取预约的前20个字符。';
    $Self->{Translation}->{'To get the appointment attribute'} = '获取预约的属性';
    $Self->{Translation}->{'To get the calendar attribute'} = '获取日历的属性';

    # Template: AgentAppointmentAgendaOverview
    $Self->{Translation}->{'Agenda Overview'} = '日程概览';
    $Self->{Translation}->{'Manage Calendars'} = '管理日历';
    $Self->{Translation}->{'Add Appointment'} = '添加预约';
    $Self->{Translation}->{'Color'} = '颜色';
    $Self->{Translation}->{'End date'} = '结束日期';
    $Self->{Translation}->{'Repeat'} = '重复';
    $Self->{Translation}->{'No calendars found. Please add a calendar first by using Manage Calendars page.'} =
        '没有找到日历。请先通过管理日历界面添加一个日历。';
    $Self->{Translation}->{'Appointment'} = '预约';
    $Self->{Translation}->{'This is a repeating appointment'} = '这是一个重复的预约';
    $Self->{Translation}->{'Would you like to edit just this occurrence or all occurrences?'} =
        '你想仅编辑本次预约的时间还是重复预约所有的时间？';
    $Self->{Translation}->{'All occurrences'} = '所有预约';
    $Self->{Translation}->{'Just this occurrence'} = '仅本次';

    # Template: AgentAppointmentCalendarManage
    $Self->{Translation}->{'Calendar Management'} = '日历管理';
    $Self->{Translation}->{'Calendar Overview'} = '日历概览';
    $Self->{Translation}->{'Add new Calendar'} = '添加新的日历';
    $Self->{Translation}->{'Add Calendar'} = '添加日历';
    $Self->{Translation}->{'Import Appointments'} = '导入预约';
    $Self->{Translation}->{'Calendar Import'} = '日历导入';
    $Self->{Translation}->{'Here you can upload a configuration file to import a calendar to your system. The file needs to be in .yml format as exported by calendar management module.'} =
        '你可以在这里上传一个配置文件来导入一个日历到系统中。这个文件必须是类似通过日历管理模块导出的.yml格式。';
    $Self->{Translation}->{'Upload calendar configuration'} = '上传日历配置';
    $Self->{Translation}->{'Import Calendar'} = '导入日历';
    $Self->{Translation}->{'Filter for calendars'} = '过滤日历';
    $Self->{Translation}->{'Depending on the group field, the system will allow users the access to the calendar according to their permission level.'} =
        '根据组字段，系统通过用户的权限级别来允许用户能够访问的日历。';
    $Self->{Translation}->{'Read only: users can see and export all appointments in the calendar.'} =
        '只读：用户可以看到和导出日历中所有的预约。';
    $Self->{Translation}->{'Move into: users can modify appointments in the calendar, but without changing the calendar selection.'} =
        '转移：用户可以修改日历中的预约，但不能修改选择的日历。';
    $Self->{Translation}->{'Create: users can create and delete appointments in the calendar.'} =
        '创建：用户可以创建和删除日历中的预约。';
    $Self->{Translation}->{'Read/write: users can manage the calendar itself.'} = '读写：用户可以管理日历。';
    $Self->{Translation}->{'URL'} = '网址';
    $Self->{Translation}->{'Export calendar'} = '导出日历';
    $Self->{Translation}->{'Download calendar'} = '下载日历';
    $Self->{Translation}->{'Copy public calendar URL'} = '复制公共日历网址';
    $Self->{Translation}->{'Calendar name'} = '日历名称';
    $Self->{Translation}->{'Calendar with same name already exists.'} = '已有同名的日历。';
    $Self->{Translation}->{'Permission group'} = '权限组';
    $Self->{Translation}->{'Ticket Appointments'} = '工单预约';
    $Self->{Translation}->{'Rule'} = '规则';
    $Self->{Translation}->{'Use options below to narrow down for which tickets appointments will be automatically created.'} =
        '使用下面的选项来减少自动创建的工单预约。';
    $Self->{Translation}->{'Please select a valid queue.'} = '请选择一个有效的队列。';
    $Self->{Translation}->{'Search attributes'} = '搜索属性';
    $Self->{Translation}->{'Define rules for creating automatic appointments in this calendar based on ticket data.'} =
        '定义在这个日历中基于工单数据自动创建预约的规则。';
    $Self->{Translation}->{'Add Rule'} = '添加规则';
    $Self->{Translation}->{'More'} = '更多';
    $Self->{Translation}->{'Less'} = '更少';

    # Template: AgentAppointmentCalendarOverview
    $Self->{Translation}->{'Add new Appointment'} = '添加新的预约';
    $Self->{Translation}->{'Calendars'} = '日历';
    $Self->{Translation}->{'Too many active calendars'} = '激活的日历太多';
    $Self->{Translation}->{'Please either turn some off first or increase the limit in configuration.'} =
        '请关闭一些日历或者在配置中增加限制数。';
    $Self->{Translation}->{'Week'} = '周';
    $Self->{Translation}->{'Timeline Month'} = '月时间表';
    $Self->{Translation}->{'Timeline Week'} = '周时间表';
    $Self->{Translation}->{'Timeline Day'} = '每日时间表';
    $Self->{Translation}->{'Jump'} = '跳转';
    $Self->{Translation}->{'Dismiss'} = '取消';
    $Self->{Translation}->{'Show'} = '显示';
    $Self->{Translation}->{'Basic information'} = '基本信息';
    $Self->{Translation}->{'Date/Time'} = '日期 / 时间';

    # Template: AgentAppointmentEdit
    $Self->{Translation}->{'Please set this to value before End date.'} = '请设置这个值为结束日期之前。';
    $Self->{Translation}->{'Please set this to value after Start date.'} = '请设置这个值为开始日期之后。';
    $Self->{Translation}->{'This an occurrence of a repeating appointment.'} = '这是一个重复预约的一次时间。';
    $Self->{Translation}->{'Click here to see the parent appointment.'} = '点击这里查看父预约。';
    $Self->{Translation}->{'Click here to edit the parent appointment.'} = '点击这里编辑父预约。';
    $Self->{Translation}->{'Frequency'} = '频率';
    $Self->{Translation}->{'Every'} = '每';
    $Self->{Translation}->{'Relative point of time'} = '相对的时间';
    $Self->{Translation}->{'Are you sure you want to delete this appointment? This operation cannot be undone.'} =
        '你真的要删除这个预约吗？这个操作无法回退。';

    # Template: AgentAppointmentImport
    $Self->{Translation}->{'Appointment Import'} = '预约导入';
    $Self->{Translation}->{'Uploaded file must be in valid iCal format (.ics).'} = '上传文件必须是有效的iCal格式(.ics)。';
    $Self->{Translation}->{'If desired Calendar is not listed here, please make sure that you have at least \'create\' permissions.'} =
        '如果期望的日历没有在这里，请确保你至少有“创建”权限。';
    $Self->{Translation}->{'Update existing appointments?'} = '更新已有的预约吗？';
    $Self->{Translation}->{'All existing appointments in the calendar with same UniqueID will be overwritten.'} =
        '相同UniqueID的日历中所有已有的预约都会被覆盖。';
    $Self->{Translation}->{'Upload calendar'} = '上传日历';
    $Self->{Translation}->{'Import appointments'} = '导入预约';

    # Template: AgentDashboardAppointmentCalendar
    $Self->{Translation}->{'New Appointment'} = '新的预约';
    $Self->{Translation}->{'Soon'} = '很快';
    $Self->{Translation}->{'5 days'} = '5天';

    # Perl Module: Kernel/Modules/AdminAppointmentNotificationEvent.pm
    $Self->{Translation}->{'Notification name already exists!'} = '这个通知的名字已存在!';
    $Self->{Translation}->{'Agent (resources), who are selected within the appointment'} = '这个预约选择的服务人员（资源）。';
    $Self->{Translation}->{'All agents with (at least) read permission for the appointment (calendar)'} =
        '所有对这个预约（日历）至少有读权限的服务人员。';
    $Self->{Translation}->{'All agents with write permission for the appointment (calendar)'} =
        '所有对这个预约（日历）有写权限的服务人员。';

    # Perl Module: Kernel/Modules/AgentAppointmentCalendarManage.pm
    $Self->{Translation}->{'System was unable to create Calendar!'} = '系统不能创建日历！';
    $Self->{Translation}->{'No CalendarID!'} = '没有日历ID！';
    $Self->{Translation}->{'You have no access to this calendar!'} = '你无权访问这个日历！';
    $Self->{Translation}->{'Edit Calendar'} = '编辑日历';
    $Self->{Translation}->{'Error updating the calendar!'} = '更新日历出错！';
    $Self->{Translation}->{'Couldn\'t read calendar configuration file.'} = '不能读取日历的配置文件。';
    $Self->{Translation}->{'Please make sure your file is valid.'} = '请确保你的文件是有效的。';
    $Self->{Translation}->{'Could not import the calendar!'} = '无法导入这个日历！';
    $Self->{Translation}->{'Calendar imported!'} = '日历已导入！';
    $Self->{Translation}->{'Need CalendarID!'} = '需要日历ID！';
    $Self->{Translation}->{'Could not retrieve data for given CalendarID'} = '无法返回给定的日历ID的数据';
    $Self->{Translation}->{'Successfully imported %s appointment(s) to calendar %s.'} = '成功将预约%s导入到日历%s。';
    $Self->{Translation}->{'+5 minutes'} = '+5分钟';
    $Self->{Translation}->{'+15 minutes'} = '+15分钟';
    $Self->{Translation}->{'+30 minutes'} = '+30分钟';
    $Self->{Translation}->{'+1 hour'} = '+1小时';

    # Perl Module: Kernel/Modules/AgentAppointmentCalendarOverview.pm
    $Self->{Translation}->{'All appointments'} = '所有预约';
    $Self->{Translation}->{'Appointments assigned to me'} = '分配给我的预约';
    $Self->{Translation}->{'Showing only appointments assigned to you! Change settings'} = '仅显示分配给你的预约！修改设置';

    # Perl Module: Kernel/Modules/AgentAppointmentEdit.pm
    $Self->{Translation}->{'Appointment not found!'} = '没有找到预约！';
    $Self->{Translation}->{'Never'} = '永不';
    $Self->{Translation}->{'Every Day'} = '每天';
    $Self->{Translation}->{'Every Week'} = '每周';
    $Self->{Translation}->{'Every Month'} = '每月';
    $Self->{Translation}->{'Every Year'} = '每年';
    $Self->{Translation}->{'Custom'} = '定制';
    $Self->{Translation}->{'Daily'} = '每天一次';
    $Self->{Translation}->{'Weekly'} = '每周一次';
    $Self->{Translation}->{'Monthly'} = '每月一次';
    $Self->{Translation}->{'Yearly'} = '每年一次';
    $Self->{Translation}->{'every'} = '每';
    $Self->{Translation}->{'for %s time(s)'} = '%s次';
    $Self->{Translation}->{'until ...'} = '直到...';
    $Self->{Translation}->{'for ... time(s)'} = '...次';
    $Self->{Translation}->{'until %s'} = '直到%s';
    $Self->{Translation}->{'No notification'} = '没有通知';
    $Self->{Translation}->{'%s minute(s) before'} = '%s分钟前';
    $Self->{Translation}->{'%s hour(s) before'} = '%s小时前';
    $Self->{Translation}->{'%s day(s) before'} = '%s天前';
    $Self->{Translation}->{'%s week before'} = '%s周前';
    $Self->{Translation}->{'before the appointment starts'} = '在预约开始前';
    $Self->{Translation}->{'after the appointment has been started'} = '在预约开始后';
    $Self->{Translation}->{'before the appointment ends'} = '在预约结束前';
    $Self->{Translation}->{'after the appointment has been ended'} = '在预约结束后';
    $Self->{Translation}->{'No permission!'} = '没有权限！';
    $Self->{Translation}->{'Cannot delete ticket appointment!'} = '不能删除工单预约！';
    $Self->{Translation}->{'No permissions!'} = '没有权限！';

    # Perl Module: Kernel/Modules/AgentAppointmentImport.pm
    $Self->{Translation}->{'No permissions'} = '没有权限';
    $Self->{Translation}->{'System was unable to import file!'} = '系统无法导入文件！';
    $Self->{Translation}->{'Please check the log for more information.'} = '更多信息请检查日志。';

    # Perl Module: Kernel/Modules/AgentAppointmentList.pm
    $Self->{Translation}->{'+%d more'} = '多于+%d';

    # Perl Module: Kernel/Modules/PublicCalendar.pm
    $Self->{Translation}->{'No %s!'} = '没有%s!';
    $Self->{Translation}->{'No such user!'} = '没有这个用户！';
    $Self->{Translation}->{'Invalid calendar!'} = '无效日历！';
    $Self->{Translation}->{'Invalid URL!'} = '无效网址！';
    $Self->{Translation}->{'There was an error exporting the calendar!'} = '导出日历时出错！';

    # Perl Module: Kernel/Output/HTML/Dashboard/AppointmentCalendar.pm
    $Self->{Translation}->{'Refresh (minutes)'} = '刷新（分钟）';

    # SysConfig
    $Self->{Translation}->{'Appointment Calendar overview page.'} = '预约日历概览页面。';
    $Self->{Translation}->{'Appointment Notifications'} = '预约通知';
    $Self->{Translation}->{'Appointment calendar event module that prepares notification entries for appointments.'} =
        '预约日历事件模块，准备预约的通知消息。';
    $Self->{Translation}->{'Appointment calendar event module that updates the ticket with data from ticket appointment.'} =
        '预约日历事件模块，更新工单的预约数据。';
    $Self->{Translation}->{'Appointment edit screen.'} = '预约编辑窗口。';
    $Self->{Translation}->{'Appointment list'} = '预约列表';
    $Self->{Translation}->{'Appointment list.'} = '预约列表。';
    $Self->{Translation}->{'Appointment notifications'} = '预约通知';
    $Self->{Translation}->{'Appointments'} = '预约';
    $Self->{Translation}->{'Calendar manage screen.'} = '日历管理窗口。';
    $Self->{Translation}->{'Choose for which kind of appointment changes you want to receive notifications.'} =
        '选择你需要接收哪些预约变动通知消息。';
    $Self->{Translation}->{'Create a new calendar appointment linked to this ticket'} = '创建一个新的日历预约到这个工单。';
    $Self->{Translation}->{'Create and manage appointment notifications.'} = '创建和管理预约通知.';
    $Self->{Translation}->{'Create new appointment.'} = '创建新的预约。';
    $Self->{Translation}->{'Define which columns are shown in the linked appointment widget (LinkObject::ViewMode = "complex"). Possible settings: 0 = Disabled, 1 = Available, 2 = Enabled by default.'} =
        '定义链接的预约小部件(LinkObject::ViewMode = "complex")要显示的列。可用的设置值为：0 = 禁用，1 = 可用， 2 = 默认启用。';
    $Self->{Translation}->{'Defines an icon with link to the google map page of the current location in appointment edit screen.'} =
        '定义一个图标，链接预约编辑窗口中的当前位置到谷歌地图页面。';
    $Self->{Translation}->{'Defines the event object types that will be handled via AdminAppointmentNotificationEvent.'} =
        '定义事件对象类型，以便通过AdminAppointmentNotificationEvent（管理预约通知事件）处理。';
    $Self->{Translation}->{'Defines the list of params that can be passed to ticket search function.'} =
        '定义能传递到工单搜索功能的参数清单。';
    $Self->{Translation}->{'Defines the ticket appointment type backend for ticket dynamic field date time.'} =
        '定义工单预约类型后端，用于工单动态字段日期时间。';
    $Self->{Translation}->{'Defines the ticket appointment type backend for ticket escalation time.'} =
        '定义工单预约类型后端，用于工单升级时间。';
    $Self->{Translation}->{'Defines the ticket appointment type backend for ticket pending time.'} =
        '定义工单预约类型后端，用于工单挂起时间。';
    $Self->{Translation}->{'Defines the ticket plugin for calendar appointments.'} = '定义日历预约的工单插件。';
    $Self->{Translation}->{'DynamicField_%s'} = 'DynamicField_%s';
    $Self->{Translation}->{'Edit appointment'} = '编辑预约';
    $Self->{Translation}->{'First response time'} = '首次响应时间';
    $Self->{Translation}->{'Import appointments screen.'} = '导入预约窗口。';
    $Self->{Translation}->{'Links appointments and tickets with a "Normal" type link.'} = '将预约和工单链接为“普通”类型。';
    $Self->{Translation}->{'List of all appointment events to be displayed in the GUI.'} = '列出要在图形界面显示的所有预约事件。';
    $Self->{Translation}->{'List of all calendar events to be displayed in the GUI.'} = '图形界面显示的所有日历事件列表。';
    $Self->{Translation}->{'List of colors in hexadecimal RGB which will be available for selection during calendar creation. Make sure the colors are dark enough so white text can be overlayed on them.'} =
        '在创建日历时可用于选择的16进制RGB颜色列表。请使用足够深色的颜色，以确保能够显示上面白色的文本。';
    $Self->{Translation}->{'Manage different calendars.'} = '管理不同的日历。';
    $Self->{Translation}->{'Maximum number of active calendars in overview screens. Please note that large number of active calendars can have a performance impact on your server by making too much simultaneous calls.'} =
        '日历概览窗口能激活的日历最大数。请注意：大量的激活日历会对服务器产生太多的同步调用，可能会有性能影响。';
    $Self->{Translation}->{'OTRS doesn\'t support recurring Appointments without end date or number of iterations. During import process, it might happen that ICS file contains such Appointments. Instead, system creates all Appointments in the past, plus Appointments for the next n months (120 months/10 years by default).'} =
        'OTRS不支持对没有结束日期或没有重复次数的预约做循环处理。在导入过程中，可能有ICS文件包含了此类预约。作为替代，系统将所有的此类预约创建为已过去的预约，然后加上接下来的n个月(默认120个月或10年)的重复预约。';
    $Self->{Translation}->{'Overview of all appointments.'} = '所有预约的概览。';
    $Self->{Translation}->{'Pending time'} = '挂起时间';
    $Self->{Translation}->{'Plugin search'} = '搜索插件';
    $Self->{Translation}->{'Plugin search module for autocomplete.'} = '用于自动完成的搜索插件模块。';
    $Self->{Translation}->{'Public Calendar'} = '公共日历';
    $Self->{Translation}->{'Public calendar.'} = '公共日历。';
    $Self->{Translation}->{'Resource Overview'} = '资源概览';
    $Self->{Translation}->{'Resource Overview (OTRS Business Solution™)'} = '资源概览（OTRS商业版）';
    $Self->{Translation}->{'Shows a link in the menu for creating a calendar appointment linked to the ticket directly from the ticket zoom view of the agent interface. Additional access control to show or not show this link can be done by using Key "Group" and Content like "rw:group1;move_into:group2". To cluster menu items use for Key "ClusterName" and for the Content any name you want to see in the UI. Use "ClusterPriority" to configure the order of a certain cluster within the toolbar.'} =
        '在服务人员界面工单详情窗口，在菜单上显示一个链接，以创建一个日历预约并直接链接到此工单。可通过键“Group”和值如“rw:group1;move_into:group2”进行额外的访问控制，以显示或不显示这个链接。如果要放到菜单组中，使用键“ClusterName”，值可以是界面上能看到的任意名称。使用键“ClusterPriority”来配置菜单组在工具栏中显示的顺序。';
    $Self->{Translation}->{'Solution time'} = '解决时间';
    $Self->{Translation}->{'Transport selection for appointment notifications.'} = '预约通知的传输方式选择。';
    $Self->{Translation}->{'Triggers add or update of automatic calendar appointments based on certain ticket times.'} =
        '基于某些工单时间添加或更新自动日历预约的触发器。';
    $Self->{Translation}->{'Update time'} = '更新时间';

}

1;
