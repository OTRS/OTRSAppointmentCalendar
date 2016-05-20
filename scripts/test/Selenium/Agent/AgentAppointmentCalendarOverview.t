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

my $ElementDisabled = sub {
    my (%Param) = @_;

    # Value is optional parameter
    for my $Needed (qw(UnitTestObject Element)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    $Param{UnitTestObject}->Is(
        $Selenium->execute_script(
            "return \$('#" . $Param{Element} . ":disabled').length;"
        ),
        $Param{Value},
        "$Param{Element} disabled ($Param{Value})",
    );
};

my $ElementExists = sub {
    my (%Param) = @_;

    # Value is optional parameter
    for my $Needed (qw(UnitTestObject Element)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    my $Length = $Selenium->execute_script(
        "return \$('#" . $Param{Element} . "').length;"
    );

    if ( $Param{Value} ) {
        $Param{UnitTestObject}->True(
            $Length,
            "$Param{Element} exists",
        );
    }
    else {
        $Param{UnitTestObject}->False(
            $Length,
            "$Param{Element} not exists",
        );
    }
};

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
        my $GroupObject     = $Kernel::OM->Get('Kernel::System::Group');
        my $CalendarObject  = $Kernel::OM->Get('Kernel::System::Calendar');
        my $TimeObject      = $Kernel::OM->Get('Kernel::System::Time');
        my $UserObject      = $Kernel::OM->Get('Kernel::System::User');
        my $TicketObject    = $Kernel::OM->Get('Kernel::System::Ticket');

        my $RandomID = $Helper->GetRandomID();

        # create test group
        my $GroupName = "test-calendar-group-$RandomID";
        my $GroupID   = $GroupObject->GroupAdd(
            Name    => $GroupName,
            ValidID => 1,
            UserID  => 1,
        );

        # create test group
        my $GroupName2 = "test-calendar-group2-$RandomID";
        my $GroupID2   = $GroupObject->GroupAdd(
            Name    => $GroupName2,
            ValidID => 1,
            UserID  => 1,
        );

        # add root to the created group
        $GroupObject->PermissionGroupUserAdd(
            GID        => $GroupID2,
            UID        => 1,
            Permission => {
                ro        => 1,
                move_into => 1,
                create    => 1,
                owner     => 1,
                priority  => 1,
                rw        => 1,
            },
            UserID => 1,
        );

        # get script alias
        my $ScriptAlias = $Kernel::OM->Get('Kernel::Config')->Get('ScriptAlias');

        # change resolution (desktop mode)
        $Selenium->set_window_size( 768, 1050 );

        # create test user
        my $Language      = 'en';
        my $TestUserLogin = $Helper->TestUserCreate(
            Groups   => [ 'users', $GroupName ],
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
            CalendarName => "My Calendar $RandomID",
            GroupID      => $GroupID,
            UserID       => $UserID,
            ValidID      => 1,
        );
        my %Calendar2 = $CalendarObject->CalendarCreate(
            CalendarName => "Another Calendar $RandomID",
            GroupID      => $GroupID,
            UserID       => $UserID,
            ValidID      => 1,
        );
        my %Calendar3 = $CalendarObject->CalendarCreate(
            CalendarName => "Yet Another Calendar $RandomID",
            GroupID      => $GroupID,
            UserID       => $UserID,
            ValidID      => 1,
        );
        my %Calendar4 = $CalendarObject->CalendarCreate(
            CalendarName => "Calendar for permissions check $RandomID",
            GroupID      => $GroupID2,
            UserID       => 1,
            ValidID      => 1,
        );

        # create a test ticket
        my $TicketID = $TicketObject->TicketCreate(
            Title        => 'Link Ticket',
            Queue        => 'Raw',
            Lock         => 'unlock',
            Priority     => '3 normal',
            State        => 'open',
            CustomerNo   => '123465',
            CustomerUser => 'customer@example.com',
            OwnerID      => $UserID,
            UserID       => $UserID,
        );
        $Self->True(
            $TicketID,
            "TicketCreate() - $TicketID",
        );
        my $TicketNumber = $TicketObject->TicketNumberLookup(
            TicketID => $TicketID,
            UserID   => $UserID,
        );
        $Self->True(
            $TicketNumber,
            "TicketNumberLookup() - $TicketNumber",
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
        $Selenium->find_element( '.fc-timelineWeek-view .fc-slats td.fc-widget-content:nth-child(5)', 'css' )->click();

        # wait until form and overlay has loaded, if neccessary
        $Selenium->WaitFor( JavaScript => "return typeof(\$) === 'function' && \$('#Title').length" );

        # elements that are not allowed in dialog
        for my $Element (qw(EditFormDelete EditFormCopy)) {
            $ElementExists->(
                UnitTestObject => $Self,
                Element        => $Element,
                Value          => 0,
            );
        }

        # enter some data
        $Selenium->find_element( 'Title', 'name' )->send_keys('Appointment 1');
        $Selenium->execute_script(
            "return \$('#CalendarID').val("
                . $Calendar1{CalendarID}
                . ").trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->find_element( 'EndHour',      'name' )->send_keys('18');
        $Selenium->find_element( '.PluginField', 'css' )->send_keys($TicketNumber);

        # wait for autocomplete to load
        $Selenium->WaitFor(
            JavaScript => 'return typeof($) === "function" && $("li.ui-menu-item:visible").length'
        );

        # link the ticket
        $Selenium->execute_script(
            "return \$('li.ui-menu-item').click();"
        );

        # verify correct ticket is listed
        $Self->Is(
            $Selenium->execute_script(
                "return \$('.PluginContainer div a[target=\"_blank\"]').text();"
            ),
            "$TicketNumber Link Ticket",
            'Link ticket visible',
        );

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

        # go to the ticket zoom screen
        $Selenium->VerifiedGet("${ScriptAlias}index.pl?Action=AgentTicketZoom;TicketID=${TicketID}");

        # find link to the appointment on page
        $Selenium->find_element( 'a.LinkObjectLink', 'css' )->VerifiedClick();

        # wait until form and overlay has loaded, if neccessary
        $Selenium->WaitFor( JavaScript => "return typeof(\$) === 'function' && \$('#Title').length" );

        # check data
        $Self->Is(
            $Selenium->execute_script(
                "return \$('#Title').val();",
            ),
            'Appointment 1',
            'Title matches',
        );
        $Self->Is(
            $Selenium->execute_script(
                "return \$('#CalendarID').val();",
            ),
            $Calendar1{CalendarID},
            'Calendar matches',
        );
        $Self->Is(
            $Selenium->execute_script(
                "return \$('#EndHour').val();",
            ),
            '18',
            'End time matches',
        );
        $Self->Is(
            $Selenium->execute_script(
                "return \$('.PluginContainer div a[target=\"_blank\"]').text();"
            ),
            "$TicketNumber Link Ticket",
            'Link ticket matches',
        );

        # cancel the dialog
        $Selenium->find_element( '#EditFormCancel', 'css' )->click();

        # go to previous week in order to disable realtime notification dialog
        $Selenium->find_element( '.fc-toolbar .fc-prev-button', 'css' )->click();

        # wait for AJAX to finish
        $Selenium->WaitFor( JavaScript => 'return typeof($) === "function" && !$(".CalendarWidget.Loading").length' );

        # click on the timeline view for another appointment dialog
        $Selenium->find_element( '.fc-timelineWeek-view .fc-slats td.fc-widget-content:nth-child(5)', 'css' )->click();

        # wait until form and overlay has loaded, if neccessary
        $Selenium->WaitFor( JavaScript => "return typeof(\$) === 'function' && \$('#Title').length" );

        # enter some data
        $Selenium->find_element( 'Title', 'name' )->send_keys('Appointment 2');
        $Selenium->execute_script(
            "return \$('#CalendarID').val("
                . $Calendar2{CalendarID}
                . ").trigger('redraw.InputField').trigger('change');"
        );
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
        $Selenium->find_element( '.fc-timelineWeek-view .fc-slats td.fc-widget-content:nth-child(5)', 'css' )->click();

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
            "return \$('#RecurrenceType').val('Daily').trigger('redraw.InputField').trigger('change');"
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
            '4',
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
        $Selenium->find_element( 'input#FilterCalendars', 'css' )->send_keys("Yet Another Calendar $RandomID");

        # wait for filter to finish
        $Selenium->WaitFor(
            JavaScript => 'return typeof($) === "function" && !$("input#FilterCalendars.Filtering").length'
        );

        # verify only one calendar is shown in the list
        $Self->Is(
            $Selenium->execute_script(
                "return \$('.CalendarSwitch:visible').length;"
            ),
            1,
            'Calendars are filtered correctly',
        );

        # create new Appointment (with as root)
        my $StartTime       = $TimeObject->CurrentTimestamp();
        my $StartTimeSystem = $TimeObject->TimeStamp2SystemTime(
            String => $StartTime,
        );
        $StartTime = $TimeObject->SystemTime2TimeStamp(
            SystemTime => $StartTimeSystem + 24 * 60 * 60,    # next day
        );

        my $EndTime = $TimeObject->SystemTime2TimeStamp(
            SystemTime => $StartTimeSystem + 26 * 60 * 60,    # 2 hours after start time
        );

        my $AppointmentID = $Kernel::OM->Get('Kernel::System::Calendar::Appointment')->AppointmentCreate(
            CalendarID  => $Calendar4{CalendarID},
            Title       => 'Permissions check appointment',
            Description => 'How to use Process tickets...',
            Location    => 'Straubing',
            StartTime   => $StartTime,
            EndTime     => $EndTime,
            UserID      => 1,
            TimezoneID  => 0,
        );

        $Self->True(
            $AppointmentID,
            "Permission Appointment created.",
        );

        # add ro permissions to the user
        $GroupObject->PermissionGroupUserAdd(
            GID        => $GroupID2,
            UID        => $UserID,
            Permission => {
                ro => 1,
            },
            UserID => 1,
        );

        # reload page
        # go to calendar overview page
        $Selenium->VerifiedGet("${ScriptAlias}index.pl?Action=AgentAppointmentCalendarOverview");

        # wait for AJAX to finish
        $Selenium->WaitFor( JavaScript => 'return typeof($) === "function" && !$(".CalendarWidget.Loading").length' );

        # hide all Calendars except Calendar4
        $Selenium->find_element( 'Calendar' . $Calendar1{CalendarID}, 'id' )->click();
        $Selenium->find_element( 'Calendar' . $Calendar2{CalendarID}, 'id' )->click();
        $Selenium->find_element( 'Calendar' . $Calendar3{CalendarID}, 'id' )->click();

        # click on appointment
        $Selenium->execute_script(
            "return \$('.fc-scrollpane-inner a:first').click();",
        );

        # wait for appointment
        $Selenium->WaitFor( JavaScript => "return typeof(\$) === 'function' && \$('#Title').length" );

        # check if fields are disabled
        for my $Element (
            qw(Title Description Location CalendarID TeamList StartMonth StartDay StartYear StartHour StartMinute
            EndMonth EndDay EndYear EndHour EndMinute AllDay RecurrenceType
            )
            )
        {
            $ElementDisabled->(
                UnitTestObject => $Self,
                Element        => $Element,
                Value          => 1,
            );
        }

        # elements that are not allowed on page
        for my $Element (qw( EditFormSubmit EditFormDelete EditFormCopy )) {
            $ElementExists->(
                UnitTestObject => $Self,
                Element        => $Element,
                Value          => 0,
            );
        }

        # elements that should be on page
        for my $Element (qw( EditFormCancel )) {
            $ElementExists->(
                UnitTestObject => $Self,
                Element        => $Element,
                Value          => 1,
            );
        }

        # click on cancel
        $Selenium->find_element( '#EditFormCancel', 'css' )->click();

        # add move_into permissions to the user
        $GroupObject->PermissionGroupUserAdd(
            GID        => $GroupID2,
            UID        => $UserID,
            Permission => {
                ro        => 1,
                move_into => 1,
            },
            UserID => 1,
        );

        # click on appointment
        $Selenium->execute_script(
            "return \$('.fc-scrollpane-inner a:first').click();",
        );

        # wait for appointment
        $Selenium->WaitFor( JavaScript => "return typeof(\$) === 'function' && \$('#Title').length" );

        # check if fields are disabled
        for my $Element (qw( CalendarID )) {
            $ElementDisabled->(
                UnitTestObject => $Self,
                Element        => $Element,
                Value          => 1,
            );
        }

        # check if fields are enabled
        for my $Element (
            qw( Title Description Location TeamList StartMonth StartDay StartYear StartHour StartMinute
            EndMonth EndDay EndYear EndHour EndMinute AllDay RecurrenceType
            )
            )
        {
            $ElementDisabled->(
                UnitTestObject => $Self,
                Element        => $Element,
                Value          => 0,
            );
        }

        # elements that are not allowed on page
        for my $Element (qw( EditFormDelete EditFormCopy)) {
            $ElementExists->(
                UnitTestObject => $Self,
                Element        => $Element,
                Value          => 0,
            );
        }

        # elements that should be on page
        for my $Element (qw( EditFormSubmit EditFormCancel )) {
            $ElementExists->(
                UnitTestObject => $Self,
                Element        => $Element,
                Value          => 1,
            );
        }

        # click on cancel
        $Selenium->find_element( '#EditFormCancel', 'css' )->click();

        # add create permissions to the user
        $GroupObject->PermissionGroupUserAdd(
            GID        => $GroupID2,
            UID        => $UserID,
            Permission => {
                ro        => 1,
                move_into => 1,
                create    => 1,
            },
            UserID => 1,
        );

        # click on appointment
        $Selenium->execute_script(
            "return \$('.fc-scrollpane-inner a:first').click();",
        );

        # wait for appointment
        $Selenium->WaitFor( JavaScript => "return typeof(\$) === 'function' && \$('#Title').length" );

        # check if fields are enabled
        for my $Element (
            qw( Title Description Location CalendarID TeamList StartMonth StartDay StartYear StartHour StartMinute
            EndMonth EndDay EndYear EndHour EndMinute AllDay RecurrenceType
            )
            )
        {
            $ElementDisabled->(
                UnitTestObject => $Self,
                Element        => $Element,
                Value          => 0,
            );
        }

        # elements that should be on page
        for my $Element (qw( EditFormCopy EditFormSubmit EditFormDelete EditFormCancel )) {
            $ElementExists->(
                UnitTestObject => $Self,
                Element        => $Element,
                Value          => 1,
            );
        }

        # sleep(20);

        }
);

1;
