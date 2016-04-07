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
        ) || die 'Did not get test user';

        # create test customer user
        my $TestCustomerUserLogin = $Helper->TestCustomerUserCreate() || die 'Did not get test customer user';

        # start test
        $Selenium->Login(
            Type     => 'Agent',
            User     => $TestUserLogin,
            Password => $TestUserLogin,
        );

        # open AgentAppointmentCalendarManage page
        $Selenium->VerifiedGet("${ScriptAlias}index.pl?Action=AgentAppointmentCalendarManage");

        # click Add new calendar
        $Selenium->find_element( '.SidebarColumn ul.ActionList a#Add', 'css' )->click();

        # write calendar name
        $Selenium->find_element( 'form#CalendarFrom input#CalendarName', 'css' )->send_keys('Personal calendar');

        # submit
        $Selenium->find_element( 'form#CalendarFrom button#Submit', 'css' )->VerifiedClick();

        #
        # let's try to add calendar with same name
        #
        # click Add new calendar
        $Selenium->find_element( '.SidebarColumn ul.ActionList a#Add', 'css' )->VerifiedClick();

        # write calendar name
        $Selenium->find_element( 'form#CalendarFrom input#CalendarName', 'css' )->send_keys('Personal calendar');

        # submit
        $Selenium->find_element( 'form#CalendarFrom button#Submit', 'css' )->VerifiedClick();

        # wait for server side error
        $Selenium->WaitFor(
            JavaScript => "return typeof(\$) === 'function' && \$('div.Dialog button#DialogButton1').length"
        );

        # click ok to dismiss
        $Selenium->find_element( 'div.Dialog button#DialogButton1', 'css' )->click();

        # wait for tooltip message
        $Selenium->WaitFor(
            JavaScript => "return typeof(\$) === 'function' && \$('div#OTRS_UI_Tooltips_ErrorTooltip').length"
        );

        # update calendar name
        $Selenium->find_element( 'form#CalendarFrom input#CalendarName', 'css' )->click();
        $Selenium->send_keys_to_active_element('2');

        # set it to invalid
        $Selenium->execute_script(
            "return \$('#ValidID').val(2).trigger('redraw.InputField').trigger('change');"
        );

        # submit
        $Selenium->find_element( 'form#CalendarFrom button#Submit', 'css' )->VerifiedClick();

        # filter just added calendar
        $Selenium->find_element( 'input#FilterCalendars', 'css' )->send_keys('Personal calendar2');

        # verify the calendar is invalid
        $Self->Is(
            $Selenium->find_element( '.ContentColumn table tbody tr:nth-of-type(2) td:nth-of-type(2)', 'css' )
                ->get_text(),
            'invalid',
            'Calendar is marked invalid',
        );

        # edit invalid calendar
        $Selenium->find_element( '.ContentColumn table tbody tr:nth-of-type(2) a', 'css' )->VerifiedClick();

        # set it to invalid-temporarily
        $Selenium->execute_script(
            "return \$('#ValidID').val(3).trigger('redraw.InputField').trigger('change');"
        );

        # submit
        $Selenium->find_element( 'form#CalendarFrom button#Submit', 'css' )->VerifiedClick();

        # verify the calendar is invalid temporarily
        $Self->Is(
            $Selenium->find_element( '.ContentColumn table tbody tr:nth-of-type(2) td:nth-of-type(2)', 'css' )
                ->get_text(),
            'invalid-temporarily',
            'Calendar is marked invalid temporarily',
        );

        }
);

1;
