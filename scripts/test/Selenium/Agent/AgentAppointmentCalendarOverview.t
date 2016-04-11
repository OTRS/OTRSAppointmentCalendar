# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

use strict;
use warnings;
use utf8;

use vars (qw($Self));

# get selenium object
my $Selenium = $Kernel::OM->Get('Kernel::System::UnitTest::Selenium');

$Selenium->RunTest(
    sub {

        # get needed objects
        $Kernel::OM->ObjectParamAdd(
            'Kernel::System::UnitTest::Helper' => {
                RestoreSystemConfiguration => 1,
            },
        );
        my $Helper          = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
        my $SysConfigObject = $Kernel::OM->Get('Kernel::System::SysConfig');
        my $CalendarObject  = $Kernel::OM->Get('Kernel::System::Calendar');
        my $UserObject      = $Kernel::OM->Get('Kernel::System::User');

        # get script alias
        my $ScriptAlias = $Kernel::OM->Get('Kernel::Config')->Get('ScriptAlias');

        # change resolution (desktop mode)
        $Selenium->set_window_size( 768, 1050 );

        # create test user
        my $Language      = 'en';
        my $TestUserLogin = $Helper->TestUserCreate(
            Groups   => ['users'],
            Language => $Language,
        ) || die "Did not get test user";

        # get UserID
        my $UserID = $UserObject->UserLookup(
            UserLogin => $TestUserLogin,
        );

        # create test customer user
        my $TestCustomerUserLogin = $Helper->TestCustomerUserCreate() || die "Did not get test customer user";

        # start test
        $Selenium->Login(
            Type     => 'Agent',
            User     => $TestUserLogin,
            Password => $TestUserLogin,
        );

        # create a few test calendars
        my %Calendar1 = $CalendarObject->CalendarCreate(
            CalendarName => 'My Calendar',
            UserID       => $UserID,
            ValidID      => 1,
        );
        my %Calendar2 = $CalendarObject->CalendarCreate(
            CalendarName => 'Another Calendar',
            UserID       => $UserID,
            ValidID      => 1,
        );
        my %Calendar3 = $CalendarObject->CalendarCreate(
            CalendarName => 'Yet Another Calendar',
            UserID       => $UserID,
            ValidID      => 1,
        );

        # go to calendar overview page
        $Selenium->VerifiedGet("${ScriptAlias}index.pl?Action=AgentAppointmentCalendarOverview");

        # wait for AJAX to finish
        $Selenium->WaitFor( JavaScript => 'return typeof($) === "function" && !$(".CalendarWidget.Loading").length' );

        # go to previous week in order to disable realtime notification dialog
        $Selenium->find_element( '.fc-toolbar .fc-prev-button', 'css' )->click();

        # wait for AJAX to finish
        $Selenium->WaitFor( JavaScript => 'return typeof($) === "function" && !$(".CalendarWidget.Loading").length' );

        # verify all three calendars are visible
        $Self->Is(
            $Selenium->execute_script(
                "return \$('.CalendarSwitch:visible').length;"
            ),
            3,
            'All three calendars visible',
        );

        # click on the timeline view for an appointment dialog
        $Selenium->find_element( '.fc-timeline-view .fc-slats td.fc-widget-content:nth-child(5)', 'css' )->click();

        # wait until form and overlay has loaded, if neccessary
        $Selenium->WaitFor( JavaScript => "return typeof(\$) === 'function' && \$('#Title').length" );

        # enter some data
        $Selenium->find_element( 'Title', 'name' )->send_keys('Appointment 1');
        $Selenium->execute_script(
            "return \$('#CalendarID').val("
                . $Calendar1{CalendarID}
                . ").trigger('redraw.InputField').trigger('change');"
            ),
            $Selenium->find_element( 'EndHour', 'name' )->send_keys('18');

        # click on Save
        $Selenium->find_element( '#EditFormSubmit', 'css' )->click();

        # wait for dialog to close and AJAX to finish
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && !$(".Dialog:visible").length && !$(".CalendarWidget.Loading").length'
        );

        # verify first appointment is visible
        $Self->Is(
            $Selenium->execute_script(
                "return \$('.fc-timeline-event .fc-title').text();"
            ),
            'Appointment 1',
            'First appointment visible',
        );

        # click again on the timeline view for an appointment dialog
        $Selenium->find_element( '.fc-timeline-view .fc-slats td.fc-widget-content:nth-child(5)', 'css' )->click();

        # wait until form and overlay has loaded, if neccessary
        $Selenium->WaitFor( JavaScript => "return typeof(\$) === 'function' && \$('#Title').length" );

        # enter some data
        $Selenium->find_element( 'Title', 'name' )->send_keys('Appointment 2');
        $Selenium->execute_script(
            "return \$('#CalendarID').val("
                . $Calendar2{CalendarID}
                . ").trigger('redraw.InputField').trigger('change');"
            ),
            $Selenium->find_element( 'AllDay', 'name' )->click();

        # click on Save
        $Selenium->find_element( '#EditFormSubmit', 'css' )->click();

        # wait for dialog to close and AJAX to finish
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && !$(".Dialog:visible").length && !$(".CalendarWidget.Loading").length'
        );

        # hide the first calendar from view
        $Selenium->find_element( 'Calendar' . $Calendar1{CalendarID}, 'id' )->click();

        # verify second appointment is visible
        $Self->Is(
            $Selenium->execute_script(
                "return \$('.fc-timeline-event .fc-title').text();"
            ),
            'Appointment 2',
            'Second appointment visible',
        );

        # verify second appointment is an all day appointment
        $Self->Is(
            $Selenium->execute_script(
                "return \$('.fc-timeline-event.AllDay').length;"
            ),
            '1',
            'Second appointment in an all day appointment',
        );

        # click again on the timeline view for an appointment dialog
        $Selenium->find_element( '.fc-timeline-view .fc-slats td.fc-widget-content:nth-child(5)', 'css' )->click();

        # wait until form and overlay has loaded, if neccessary
        $Selenium->WaitFor( JavaScript => "return typeof(\$) === 'function' && \$('#Title').length" );

        # enter some data
        $Selenium->find_element( 'Title', 'name' )->send_keys('Appointment 3');
        $Selenium->execute_script(
            "return \$('#CalendarID').val("
                . $Calendar3{CalendarID}
                . ").trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->find_element( 'EndHour', 'name' )->send_keys('18');
        $Selenium->execute_script(
            "return \$('#RecurrenceFrequency').val(1).trigger('redraw.InputField').trigger('change');"
        );

        # click on Save
        $Selenium->find_element( '#EditFormSubmit', 'css' )->click();

        # wait for dialog to close and AJAX to finish
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && !$(".Dialog:visible").length && !$(".CalendarWidget.Loading").length'
        );

        # hide the second calendar from view
        $Selenium->find_element( 'Calendar' . $Calendar2{CalendarID}, 'id' )->click();

        # verify all third appointment occurences are visible
        $Self->Is(
            $Selenium->execute_script(
                "return \$('.fc-timeline-event .fc-title').length;"
            ),
            '3',
            'All third appointment occurrences visible',
        );

        # click on an appointment
        $Selenium->find_element( '.fc-timeline-event', 'css' )->click();

        # wait until form and overlay has loaded, if neccessary
        $Selenium->WaitFor( JavaScript => "return typeof(\$) === 'function' && \$('#Title').length" );

        # click on Delete
        $Selenium->find_element( '#EditFormDelete', 'css' )->click();

        # wait for dialog to close and AJAX to finish
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && !$(".Dialog:visible").length && !$(".CalendarWidget.Loading").length'
        );

        # verify all third appointment occurences have been removed
        $Self->Is(
            $Selenium->execute_script(
                "return \$('.fc-timeline-event .fc-title').length;"
            ),
            '0',
            'All third appointment occurrences removed',
        );

        # show all three calendars
        $Selenium->find_element( 'Calendar' . $Calendar1{CalendarID}, 'id' )->click();
        $Selenium->find_element( 'Calendar' . $Calendar2{CalendarID}, 'id' )->click();

        # wait for AJAX to finish
        $Selenium->WaitFor( JavaScript => 'return typeof($) === "function" && !$(".CalendarWidget.Loading").length' );

        # verify only two appointments are visible
        $Self->Is(
            $Selenium->execute_script(
                "return \$('.fc-timeline-event .fc-title').length;"
            ),
            '2',
            'First and second appointment visible',
        );

        # open datepicker
        $Selenium->find_element( '.fc-toolbar .fc-jump-button', 'css' )->click();

        # wait for AJAX to finish
        $Selenium->WaitFor( JavaScript => 'return typeof($) === "function" && !$(".AJAXLoading").length' );

        # verify exactly one day with appointments is highlighted
        $Self->Is(
            $Selenium->execute_script(
                "return \$('.ui-datepicker .ui-datepicker-calendar .Highlight').length;"
            ),
            1,
            'Datepicker properly highlighted',
        );

        # close datepicker
        $Selenium->find_element( 'div#DatepickerOverlay', 'css' )->click();

        # filter just third calendar
        $Selenium->find_element( 'input#FilterCalendars', 'css' )->send_keys('Yet Another Calendar');

        sleep 1;

        # verify only one calendar is shown in the list
        $Self->Is(
            $Selenium->execute_script(
                "return \$('.CalendarSwitch:visible').length;"
            ),
            1,
            'Calendars are filtered correctly',
        );

        }
);

1;
