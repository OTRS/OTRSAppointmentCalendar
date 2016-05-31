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
            Groups   => [$GroupName],
            Language => $Language,
        ) || die 'Did not get test user';

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
        $Selenium->find_element( 'form#CalendarFrom input#CalendarName', 'css' )->send_keys("Calendar $RandomID");

        # set it to test group
        $Selenium->execute_script(
            "return \$('#GroupID').val($GroupID).trigger('redraw.InputField').trigger('change');"
        );

        # submit
        $Selenium->find_element( 'form#CalendarFrom button#Submit', 'css' )->VerifiedClick();

        #
        # let's try to add calendar with same name
        #
        # click Add new calendar
        $Selenium->find_element( '.SidebarColumn ul.ActionList a#Add', 'css' )->VerifiedClick();

        # write calendar name
        $Selenium->find_element( 'form#CalendarFrom input#CalendarName', 'css' )->send_keys("Calendar $RandomID");

        # set it to test group
        $Selenium->execute_script(
            "return \$('#GroupID').val($GroupID).trigger('redraw.InputField').trigger('change');"
        );

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
        $Selenium->send_keys_to_active_element(' 2');

        # set it to invalid
        $Selenium->execute_script(
            "return \$('#ValidID').val(2).trigger('redraw.InputField').trigger('change');"
        );

        # submit
        $Selenium->find_element( 'form#CalendarFrom button#Submit', 'css' )->VerifiedClick();

        # verify two calendars are shown
        $Self->Is(
            $Selenium->execute_script(
                "return \$('.ContentColumn table tbody tr:visible').length;"
            ),
            2,
            'All calendars are displayed',
        );

        # filter just added calendar
        $Selenium->find_element( 'input#FilterCalendars', 'css' )->send_keys("Calendar $RandomID 2");

        sleep 1;

        # verify only one calendar is shown
        $Self->Is(
            $Selenium->execute_script(
                "return \$('.ContentColumn table tbody tr:visible').length;"
            ),
            1,
            'Calendars are filtered correctly',
        );

        # verify the calendar is invalid
        my $LanguageObject = Kernel::Language->new(
            UserLanguage => $Language,
        );
        $Self->Is(
            $Selenium->find_element( '.ContentColumn table tbody tr:nth-of-type(2) td:nth-of-type(4)', 'css' )
                ->get_text(),
            $LanguageObject->Translate('invalid'),
            'Calendar is marked invalid',
        );

        # edit invalid calendar
        $Selenium->find_element( '.ContentColumn table tbody tr:nth-of-type(2) td a', 'css' )->VerifiedClick();

        # set it to invalid-temporarily
        $Selenium->execute_script(
            "return \$('#ValidID').val(3).trigger('redraw.InputField').trigger('change');"
        );

        # submit
        $Selenium->find_element( 'form#CalendarFrom button#Submit', 'css' )->VerifiedClick();

        # verify the calendar is invalid temporarily
        $Self->Is(
            $Selenium->find_element( '.ContentColumn table tbody tr:nth-of-type(2) td:nth-of-type(4)', 'css' )
                ->get_text(),
            $LanguageObject->Translate('invalid-temporarily'),
            'Calendar is marked invalid temporarily',
        );

        }
);

1;
