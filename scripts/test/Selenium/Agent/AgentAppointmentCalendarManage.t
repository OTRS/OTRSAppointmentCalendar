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
        my $Language      = 'de';
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

        print "Done\n";
        }
);

print "All done!\n";
1;
