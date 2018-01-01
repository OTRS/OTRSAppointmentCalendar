# --
# Copyright (C) 2001-2018 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::ja_OTRSAppointmentCalendar;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    # Template: AAANotification
    $Self->{Translation}->{'Appointment reminder notification'} = '予約リマインダーの通知';
    $Self->{Translation}->{'You will receive a notification each time a reminder time is reached for one of your appointments.'} =
        '';

    # Template: AdminAppointmentNotificationEvent
    $Self->{Translation}->{'Appointment Notification Management'} = '予約通知の管理';
    $Self->{Translation}->{'Here you can upload a configuration file to import appointment notifications to your system. The file needs to be in .yml format as exported by the appointment notification module.'} =
        '';
    $Self->{Translation}->{'Here you can choose which events will trigger this notification. An additional appointment filter can be applied below to only send for appointments with certain criteria.'} =
        '';
    $Self->{Translation}->{'Appointment Filter'} = '予約のフィルター';
    $Self->{Translation}->{'Team'} = 'チーム';
    $Self->{Translation}->{'Resource'} = 'リソース';
    $Self->{Translation}->{'Notify user just once per day about a single appointment using a selected transport.'} =
        '';
    $Self->{Translation}->{'Notifications are sent to an agent.'} = '通知は担当者へ送信されます。';
    $Self->{Translation}->{'To get the first 20 character of the appointment title.'} = '';
    $Self->{Translation}->{'To get the appointment attribute'} = '予定の属性を取得すること';
    $Self->{Translation}->{'To get the calendar attribute'} = 'カレンダーの属性を取得すること';

    # Template: AgentAppointmentAgendaOverview
    $Self->{Translation}->{'Agenda Overview'} = 'アジェンダ表示';
    $Self->{Translation}->{'Manage Calendars'} = 'カレンダー管理';
    $Self->{Translation}->{'Add Appointment'} = '予約の登録';
    $Self->{Translation}->{'Color'} = '色';
    $Self->{Translation}->{'End date'} = '終了日時';
    $Self->{Translation}->{'Repeat'} = '繰り返し';
    $Self->{Translation}->{'No calendars found. Please add a calendar first by using Manage Calendars page.'} =
        '';
    $Self->{Translation}->{'Appointment'} = '予約';
    $Self->{Translation}->{'This is a repeating appointment'} = 'これは繰り返しの予定です。';
    $Self->{Translation}->{'Would you like to edit just this occurrence or all occurrences?'} =
        'この発生またはすべて発生だけを編集しますか？';
    $Self->{Translation}->{'All occurrences'} = '全ての発生';
    $Self->{Translation}->{'Just this occurrence'} = 'この発生時点';

    # Template: AgentAppointmentCalendarManage
    $Self->{Translation}->{'Calendar Management'} = 'カレンダー管理';
    $Self->{Translation}->{'Calendar Overview'} = 'カレンダー表示';
    $Self->{Translation}->{'Add new Calendar'} = 'カレンダーの登録';
    $Self->{Translation}->{'Add Calendar'} = 'カレンダーの登録';
    $Self->{Translation}->{'Import Appointments'} = '予約のインポート';
    $Self->{Translation}->{'Calendar Import'} = 'カレンダーをインポート';
    $Self->{Translation}->{'Here you can upload a configuration file to import a calendar to your system. The file needs to be in .yml format as exported by calendar management module.'} =
        'ここでカレンダーの設定ファイルをアップロードすることができます。ファイルはカレンダー管理モジュールがエクスポートした".yml"フォーマットである必要があります。';
    $Self->{Translation}->{'Upload calendar configuration'} = 'カレンダー設定をアップロードする';
    $Self->{Translation}->{'Import Calendar'} = 'カレンダーをインポート';
    $Self->{Translation}->{'Filter for calendars'} = 'カレンダーでフィルター';
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
    $Self->{Translation}->{'Export calendar'} = 'カレンダーのエクスポート';
    $Self->{Translation}->{'Download calendar'} = 'カレンダーのダウンロード';
    $Self->{Translation}->{'Copy public calendar URL'} = '公開カレンダーのURLをコピーする';
    $Self->{Translation}->{'Calendar name'} = 'カレンダー名';
    $Self->{Translation}->{'Calendar with same name already exists.'} = '同じ名前のカレンダーは既に存在します。';
    $Self->{Translation}->{'Permission group'} = '権限グループ';
    $Self->{Translation}->{'Ticket Appointments'} = 'チケットの予約';
    $Self->{Translation}->{'Rule'} = 'ルール';
    $Self->{Translation}->{'Use options below to narrow down for which tickets appointments will be automatically created.'} =
        '';
    $Self->{Translation}->{'Please select a valid queue.'} = '有効なキューを選択して下さい。';
    $Self->{Translation}->{'Search attributes'} = '検索属性';
    $Self->{Translation}->{'Define rules for creating automatic appointments in this calendar based on ticket data.'} =
        'チケットデータに基づいてこのカレンダーで自動予定を作成するためのルールを定義します。';
    $Self->{Translation}->{'Add Rule'} = 'ルールを追加';
    $Self->{Translation}->{'More'} = 'もっと多く';
    $Self->{Translation}->{'Less'} = 'もっと少なく';

    # Template: AgentAppointmentCalendarOverview
    $Self->{Translation}->{'Add new Appointment'} = '予約の登録';
    $Self->{Translation}->{'Calendars'} = 'カレンダー';
    $Self->{Translation}->{'Too many active calendars'} = '有効化されたカレンダーが多すぎます';
    $Self->{Translation}->{'Please either turn some off first or increase the limit in configuration.'} =
        '';
    $Self->{Translation}->{'Week'} = '週';
    $Self->{Translation}->{'Timeline Month'} = '月間タイムライン';
    $Self->{Translation}->{'Timeline Week'} = '週間タイムライン';
    $Self->{Translation}->{'Timeline Day'} = '日中タイムライン';
    $Self->{Translation}->{'Jump'} = 'カレンダー';
    $Self->{Translation}->{'Dismiss'} = '削除';
    $Self->{Translation}->{'Show'} = '表示';
    $Self->{Translation}->{'Basic information'} = '基本情報';
    $Self->{Translation}->{'Date/Time'} = '日にち/時間';

    # Template: AgentAppointmentEdit
    $Self->{Translation}->{'Please set this to value before End date.'} = '';
    $Self->{Translation}->{'Please set this to value after Start date.'} = '';
    $Self->{Translation}->{'This an occurrence of a repeating appointment.'} = '';
    $Self->{Translation}->{'Click here to see the parent appointment.'} = '';
    $Self->{Translation}->{'Click here to edit the parent appointment.'} = '';
    $Self->{Translation}->{'Frequency'} = '頻度';
    $Self->{Translation}->{'Every'} = '';
    $Self->{Translation}->{'Relative point of time'} = '';
    $Self->{Translation}->{'Are you sure you want to delete this appointment? This operation cannot be undone.'} =
        '';

    # Template: AgentAppointmentImport
    $Self->{Translation}->{'Appointment Import'} = '予約のインポート';
    $Self->{Translation}->{'Uploaded file must be in valid iCal format (.ics).'} = '';
    $Self->{Translation}->{'If desired Calendar is not listed here, please make sure that you have at least \'create\' permissions.'} =
        '';
    $Self->{Translation}->{'Update existing appointments?'} = '';
    $Self->{Translation}->{'All existing appointments in the calendar with same UniqueID will be overwritten.'} =
        '';
    $Self->{Translation}->{'Upload calendar'} = 'カレンダーをアップロード';
    $Self->{Translation}->{'Import appointments'} = '予約のインポート';

    # Template: AgentDashboardAppointmentCalendar
    $Self->{Translation}->{'New Appointment'} = '予約の登録';
    $Self->{Translation}->{'Soon'} = '';
    $Self->{Translation}->{'5 days'} = '5日';

    # Perl Module: Kernel/Modules/AdminAppointmentNotificationEvent.pm
    $Self->{Translation}->{'Notification name already exists!'} = '';
    $Self->{Translation}->{'Agent (resources), who are selected within the appointment'} = '';
    $Self->{Translation}->{'All agents with (at least) read permission for the appointment (calendar)'} =
        '';
    $Self->{Translation}->{'All agents with write permission for the appointment (calendar)'} =
        '';

    # Perl Module: Kernel/Modules/AgentAppointmentCalendarManage.pm
    $Self->{Translation}->{'System was unable to create Calendar!'} = '';
    $Self->{Translation}->{'No CalendarID!'} = 'CalendarIDがない!';
    $Self->{Translation}->{'You have no access to this calendar!'} = 'あなたはこのカレンダーにアクセスできません！';
    $Self->{Translation}->{'Edit Calendar'} = 'カレンダーを編集';
    $Self->{Translation}->{'Error updating the calendar!'} = 'カレンダーの更新中にエラーが発生しました!';
    $Self->{Translation}->{'Couldn\'t read calendar configuration file.'} = 'カレンダー設定ファイルを読み込めませんでした。';
    $Self->{Translation}->{'Please make sure your file is valid.'} = 'あなたのファイルが有効であることを確認して下さい。';
    $Self->{Translation}->{'Could not import the calendar!'} = 'カレンダーをインポートできませんでした!';
    $Self->{Translation}->{'Calendar imported!'} = 'カレンダーをインポート!';
    $Self->{Translation}->{'Need CalendarID!'} = 'CalendarIDが必要!';
    $Self->{Translation}->{'Could not retrieve data for given CalendarID'} = '';
    $Self->{Translation}->{'Successfully imported %s appointment(s) to calendar %s.'} = '';
    $Self->{Translation}->{'+5 minutes'} = '+5分';
    $Self->{Translation}->{'+15 minutes'} = '+15分';
    $Self->{Translation}->{'+30 minutes'} = '+30分';
    $Self->{Translation}->{'+1 hour'} = '+1時間';

    # Perl Module: Kernel/Modules/AgentAppointmentCalendarOverview.pm
    $Self->{Translation}->{'All appointments'} = '全ての予約';
    $Self->{Translation}->{'Appointments assigned to me'} = '私に割り当てられた予定';
    $Self->{Translation}->{'Showing only appointments assigned to you! Change settings'} = 'あなたに割り当てられた予約だけを表示する！ 設定を変更して下さい。';

    # Perl Module: Kernel/Modules/AgentAppointmentEdit.pm
    $Self->{Translation}->{'Appointment not found!'} = '予約が見つかりません！';
    $Self->{Translation}->{'Never'} = 'なし';
    $Self->{Translation}->{'Every Day'} = '毎日';
    $Self->{Translation}->{'Every Week'} = '毎週';
    $Self->{Translation}->{'Every Month'} = '毎月';
    $Self->{Translation}->{'Every Year'} = '毎年';
    $Self->{Translation}->{'Custom'} = 'カスタム';
    $Self->{Translation}->{'Daily'} = '毎日';
    $Self->{Translation}->{'Weekly'} = '毎週';
    $Self->{Translation}->{'Monthly'} = '毎月';
    $Self->{Translation}->{'Yearly'} = '毎年';
    $Self->{Translation}->{'every'} = '';
    $Self->{Translation}->{'for %s time(s)'} = 'for %s time(s)';
    $Self->{Translation}->{'until ...'} = '';
    $Self->{Translation}->{'for ... time(s)'} = '';
    $Self->{Translation}->{'until %s'} = '%s まで';
    $Self->{Translation}->{'No notification'} = '通知なし';
    $Self->{Translation}->{'%s minute(s) before'} = '%s 分前';
    $Self->{Translation}->{'%s hour(s) before'} = '%s 時間前';
    $Self->{Translation}->{'%s day(s) before'} = '%s 日前';
    $Self->{Translation}->{'%s week before'} = '%s 週間前';
    $Self->{Translation}->{'before the appointment starts'} = '';
    $Self->{Translation}->{'after the appointment has been started'} = '';
    $Self->{Translation}->{'before the appointment ends'} = '';
    $Self->{Translation}->{'after the appointment has been ended'} = '';
    $Self->{Translation}->{'No permission!'} = '権限がない!';
    $Self->{Translation}->{'Cannot delete ticket appointment!'} = 'チケット予約を削除できません！';
    $Self->{Translation}->{'No permissions!'} = '権限がない!';

    # Perl Module: Kernel/Modules/AgentAppointmentImport.pm
    $Self->{Translation}->{'No permissions'} = '権限がない!';
    $Self->{Translation}->{'System was unable to import file!'} = '';
    $Self->{Translation}->{'Please check the log for more information.'} = '';

    # Perl Module: Kernel/Modules/AgentAppointmentList.pm
    $Self->{Translation}->{'+%d more'} = '';

    # Perl Module: Kernel/Modules/PublicCalendar.pm
    $Self->{Translation}->{'No %s!'} = '%sがありません！';
    $Self->{Translation}->{'No such user!'} = 'そのようなユーザーはありません！';
    $Self->{Translation}->{'Invalid calendar!'} = '無効なカレンダー';
    $Self->{Translation}->{'Invalid URL!'} = '無効なURL';
    $Self->{Translation}->{'There was an error exporting the calendar!'} = '';

    # Perl Module: Kernel/Output/HTML/Dashboard/AppointmentCalendar.pm
    $Self->{Translation}->{'Refresh (minutes)'} = '更新 (分)';

    # SysConfig
    $Self->{Translation}->{'Appointment Calendar overview page.'} = '予約カレンダーの表示';
    $Self->{Translation}->{'Appointment Notifications'} = '予約の通知';
    $Self->{Translation}->{'Appointment calendar event module that prepares notification entries for appointments.'} =
        '';
    $Self->{Translation}->{'Appointment calendar event module that updates the ticket with data from ticket appointment.'} =
        '';
    $Self->{Translation}->{'Appointment edit screen.'} = '';
    $Self->{Translation}->{'Appointment list'} = '予約リスト';
    $Self->{Translation}->{'Appointment list.'} = '予約リスト';
    $Self->{Translation}->{'Appointment notifications'} = '予約通知';
    $Self->{Translation}->{'Appointments'} = '予約';
    $Self->{Translation}->{'Calendar manage screen.'} = 'カレンダー管理の画面';
    $Self->{Translation}->{'Choose for which kind of appointment changes you want to receive notifications.'} =
        '';
    $Self->{Translation}->{'Create a new calendar appointment linked to this ticket'} = '';
    $Self->{Translation}->{'Create and manage appointment notifications.'} = '';
    $Self->{Translation}->{'Create new appointment.'} = '予約を登録';
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
    $Self->{Translation}->{'Edit appointment'} = '予約の編集';
    $Self->{Translation}->{'First response time'} = '初回応答期限';
    $Self->{Translation}->{'Import appointments screen.'} = '予約画面をインポート';
    $Self->{Translation}->{'Links appointments and tickets with a "Normal" type link.'} = '';
    $Self->{Translation}->{'List of all appointment events to be displayed in the GUI.'} = '';
    $Self->{Translation}->{'List of all calendar events to be displayed in the GUI.'} = '';
    $Self->{Translation}->{'List of colors in hexadecimal RGB which will be available for selection during calendar creation. Make sure the colors are dark enough so white text can be overlayed on them.'} =
        '';
    $Self->{Translation}->{'Manage different calendars.'} = '様々なカレンダーを管理します。';
    $Self->{Translation}->{'Maximum number of active calendars in overview screens. Please note that large number of active calendars can have a performance impact on your server by making too much simultaneous calls.'} =
        '';
    $Self->{Translation}->{'OTRS doesn\'t support recurring Appointments without end date or number of iterations. During import process, it might happen that ICS file contains such Appointments. Instead, system creates all Appointments in the past, plus Appointments for the next n months (120 months/10 years by default).'} =
        '';
    $Self->{Translation}->{'Overview of all appointments.'} = '全ての予約の一覧';
    $Self->{Translation}->{'Pending time'} = '保留期限';
    $Self->{Translation}->{'Plugin search'} = 'プラグイン検索';
    $Self->{Translation}->{'Plugin search module for autocomplete.'} = 'オートコンプリート用のプラグイン検索モジュール';
    $Self->{Translation}->{'Public Calendar'} = '公開するカレンダー';
    $Self->{Translation}->{'Public calendar.'} = '公開するカレンダー';
    $Self->{Translation}->{'Resource Overview'} = 'リソース表示';
    $Self->{Translation}->{'Resource Overview (OTRS Business Solution™)'} = 'リソース表示 (OTRS Business Solution™)';
    $Self->{Translation}->{'Shows a link in the menu for creating a calendar appointment linked to the ticket directly from the ticket zoom view of the agent interface. Additional access control to show or not show this link can be done by using Key "Group" and Content like "rw:group1;move_into:group2". To cluster menu items use for Key "ClusterName" and for the Content any name you want to see in the UI. Use "ClusterPriority" to configure the order of a certain cluster within the toolbar.'} =
        '';
    $Self->{Translation}->{'Solution time'} = '解決期限';
    $Self->{Translation}->{'Transport selection for appointment notifications.'} = '';
    $Self->{Translation}->{'Triggers add or update of automatic calendar appointments based on certain ticket times.'} =
        '';
    $Self->{Translation}->{'Update time'} = '更新日時';

}

1;
