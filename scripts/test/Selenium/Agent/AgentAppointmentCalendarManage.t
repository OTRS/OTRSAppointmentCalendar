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

        # create test customer user
        my $TestCustomerUserLogin = $Helper->TestCustomerUserCreate() || die "Did not get test customer user";

        #-- start test
        $Selenium->Login(
            Type     => 'Agent',
            User     => $TestUserLogin,
            Password => $TestUserLogin,
        );

        # Open AgentAppointmentCalendarManage page
        $Selenium->VerifiedGet("${ScriptAlias}index.pl?Action=AgentAppointmentCalendarManage");

        # expand Calendar menu
        $Selenium->find_element( "#NavigationContainer li#nav-Calendar a", "css" )->click();

        # Click Manage calendars
        $Selenium->find_element( "#NavigationContainer li#nav-Calendar ul li#nav-Calendar-ManageCalendars a", "css" )
            ->click();

        # Click Add new calendar
        $Selenium->find_element( ".SidebarColumn ul.ActionList a#Add", "css" )->click();

        # Write calendar name
        $Selenium->find_element( "form#CalendarFrom input#CalendarName", "css" )->click();
        $Selenium->send_keys_to_active_element("Personal calendar");

        # Submit
        $Selenium->find_element( "form#CalendarFrom button#Submit", "css" )->click();

        #
        # Let's try to add calendar with same name
        #
        # Click Add new calendar
        $Selenium->find_element( ".SidebarColumn ul.ActionList a#Add", "css" )->click();

        # Write calendar name
        $Selenium->find_element( "form#CalendarFrom input#CalendarName", "css" )->click();
        $Selenium->send_keys_to_active_element("Personal calendar");

        # Submit
        $Selenium->find_element( "form#CalendarFrom button#Submit", "css" )->click();

        # Wait for server side error
        $Selenium->WaitFor(
            JavaScript => "return typeof(\$) === 'function' && \$('div.Dialog button#DialogButton1').length"
        );

        # Click ok to dismiss
        $Selenium->find_element( "div.Dialog button#DialogButton1", "css" )->click();

        # Wait for tooltip message
        $Selenium->WaitFor(
            JavaScript => "return typeof(\$) === 'function' && \$('div#OTRS_UI_Tooltips_ErrorTooltip').length"
        );

        # Update calendar name
        $Selenium->find_element( "form#CalendarFrom input#CalendarName", "css" )->click();
        $Selenium->send_keys_to_active_element("2");

        # Set it to invalid
        $Selenium->find_element( "form input#ValidID_Search", "css" )->click();
        $Selenium->WaitFor(
            JavaScript =>
                "return typeof(\$) === 'function' && \$('div.InputField_ListContainer li[data-id=\"2\"]').length"
        );
        $Selenium->find_element( "div.InputField_ListContainer li[data-id=\"2\"]", "css" )->click();

        # Submit
        sleep(1);
        $Selenium->find_element( "form#CalendarFrom button#Submit", "css" )->click();

        # Edit calendar (invalid)
        $Selenium->WaitFor(
            JavaScript => "return typeof(\$) === 'function' && \$('.ContentColumn table').length"
        );
        $Selenium->find_element( ".ContentColumn table tbody tr:nth-of-type(2) a", "css" )->click();

        # Set it to invalid-temporary
        $Selenium->WaitFor(
            JavaScript => "return typeof(\$) === 'function' && \$('form input#ValidID_Search').length"
        );
        $Selenium->find_element( "form input#ValidID_Search", "css" )->click();
        $Selenium->WaitFor(
            JavaScript =>
                "return typeof(\$) === 'function' && \$('div.InputField_ListContainer li[data-id=\"3\"]').length"
        );
        $Selenium->find_element( "div.InputField_ListContainer li[data-id=\"3\"]", "css" )->click();

        # Submit
        sleep(1);
        $Selenium->find_element( "form#CalendarFrom button#Submit", "css" )->click();

        print "Done\n";
        }
);

print "All done!\n";
1;
