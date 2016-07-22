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
            CalendarName => "Calendar1 $RandomID",
            Color        => '#3A87AD',
            GroupID      => $GroupID,
            UserID       => $UserID,
            ValidID      => 1,
        );
        my %Calendar2 = $CalendarObject->CalendarCreate(
            CalendarName => "Calendar2 $RandomID",
            Color        => '#EC9073',
            GroupID      => $GroupID,
            UserID       => $UserID,
            ValidID      => 1,
        );
        my %Calendar3 = $CalendarObject->CalendarCreate(
            CalendarName => "Calendar3 $RandomID",
            Color        => '#6BAD54',
            GroupID      => $GroupID,
            UserID       => $UserID,
            ValidID      => 1,
        );

        # go to agenda overview page
        $Selenium->VerifiedGet("${ScriptAlias}index.pl?Action=AgentAppointmentAgendaOverview");

        # click on the appointment create button
        $Selenium->find_element( '#AppointmentCreateButton', 'css' )->click();

        # wait until form and overlay has loaded, if neccessary
        $Selenium->WaitFor(
            JavaScript => "return typeof(\$) === 'function' && \$('#Title').length"
        );

        # enter some data
        $Selenium->find_element( 'Title', 'name' )->send_keys('Appointment 1');
        $Selenium->execute_script(
            "return \$('#CalendarID').val("
                . $Calendar1{CalendarID}
                . ").trigger('redraw.InputField').trigger('change');"
        );

        # click on Save
        $Selenium->find_element( '#EditFormSubmit', 'css' )->click();

        # wait for reload to finish
        $Selenium->WaitFor(
            JavaScript => "return typeof(\$) === 'function' && !\$('.OverviewControl.Loading').length"
        );

        # verify first appointment is visible
        $Self->True(
            index( $Selenium->get_page_source(), 'Appointment 1' ) > -1,
            'First appointment visible',
        );

        # click on the create button for another appointment dialog
        $Selenium->find_element( '#AppointmentCreateButton', 'css' )->click();

        # wait until form and overlay has loaded, if neccessary
        $Selenium->WaitFor(
            JavaScript => "return typeof(\$) === 'function' && \$('#Title').length"
        );

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

        # wait for reload to finish
        $Selenium->WaitFor(
            JavaScript => "return typeof(\$) === 'function' && !\$('.OverviewControl.Loading').length"
        );

        # verify first appointment is visible
        $Self->True(
            index( $Selenium->get_page_source(), 'Appointment 2' ) > -1,
            'Second appointment visible',
        );

        # click again on the create button for an appointment dialog
        $Selenium->find_element( '#AppointmentCreateButton', 'css' )->click();

        # wait until form and overlay has loaded, if neccessary
        $Selenium->WaitFor(
            JavaScript => "return typeof(\$) === 'function' && \$('#Title').length"
        );

        # enter some data
        $Selenium->find_element( 'Title', 'name' )->send_keys('Appointment 3');
        $Selenium->execute_script(
            "return \$('#CalendarID').val("
                . $Calendar3{CalendarID}
                . ").trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->execute_script(
            "return \$('#RecurrenceType').val('Daily').trigger('redraw.InputField').trigger('change');"
        );

        # click on Save
        $Selenium->find_element( '#EditFormSubmit', 'css' )->click();

        # wait for reload to finish
        $Selenium->WaitFor(
            JavaScript => "return typeof(\$) === 'function' && !\$('.OverviewControl.Loading').length"
        );

        # verify first occurrence of the third appointment is visible
        $Self->True(
            index( $Selenium->get_page_source(), 'Appointment 3' ) > -1,
            'Third appointment visible',
        );

        # click on third appointment master
        $Selenium->execute_script(
            "return \$('.MasterActionLink:contains(\"Appointment 3\")').first().click();"
        );

        # wait until form and overlay has loaded, if neccessary
        $Selenium->WaitFor(
            JavaScript => "return typeof(\$) === 'function' && \$('#Title').length"
        );

        # click on Delete
        $Selenium->find_element( '#EditFormDelete', 'css' )->click();

        # confirm
        $Selenium->accept_alert();

        # wait for reload to finish
        $Selenium->WaitFor(
            JavaScript => "return typeof(\$) === 'function' && !\$('.OverviewControl.Loading').length"
        );

        # verify all third appointment occurences have been removed
        $Self->True(
            index( $Selenium->get_page_source(), 'Appointment 3' ) == -1,
            'All third appointment occurrences removed',
        );
    },
);

1;
