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
        my $Helper         = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
        my $GroupObject    = $Kernel::OM->Get('Kernel::System::Group');
        my $CalendarObject = $Kernel::OM->Get('Kernel::System::Calendar');
        my $TeamObject     = $Kernel::OM->Get('Kernel::System::Calendar::Team');
        my $UserObject     = $Kernel::OM->Get('Kernel::System::User');

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

        # start test
        $Selenium->Login(
            Type     => 'Agent',
            User     => $TestUserLogin,
            Password => $TestUserLogin,
        );

        # create a test calendar
        my %Calendar = $CalendarObject->CalendarCreate(
            CalendarName => "Test Calendar $RandomID",
            Color        => '#3A87AD',
            GroupID      => $GroupID,
            UserID       => $UserID,
            ValidID      => 1,
        );

        # go to team management page
        $Selenium->VerifiedGet("${ScriptAlias}index.pl?Action=AgentAppointmentTeam");

        # click on add team
        $Selenium->find_element( '#TeamAdd', 'css' )->VerifiedClick();

        # populate fields
        $Selenium->find_element( 'Name', 'name' )->send_keys("Test team $RandomID");
        $Selenium->execute_script(
            "return \$('#GroupID').val("
                . $GroupID
                . ").trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->find_element( 'Comment', 'name' )->send_keys('Selenium test team');

        # submit form
        $Selenium->find_element( 'button.Primary', 'css' )->VerifiedClick();

        # click on manage team agents
        $Selenium->find_element( '#TeamUser', 'css' )->VerifiedClick();

        # click on test team
        my $TestTeamLink     = $Selenium->find_element("//a[text()='Test team $RandomID']");
        my $TestTeamLinkHref = $TestTeamLink->get_attribute('href');
        $TestTeamLinkHref =~ /ID=([0-9]+)/;
        my $TeamID = $1;
        $TestTeamLink->VerifiedClick();

        # select test user
        $Selenium->find_element("//input[\@value='$UserID']")->VerifiedClick();

        # submit form
        $Selenium->find_element( 'button.Primary', 'css' )->VerifiedClick();

        # go to resource overview page for test team
        $Selenium->VerifiedGet("${ScriptAlias}index.pl?Action=AgentAppointmentResourceOverview;Team=${TeamID}");

        # wait for AJAX to finish
        $Selenium->WaitFor( JavaScript => 'return typeof($) === "function" && !$(".CalendarWidget.Loading").length' );

        # go to previous week in order to disable realtime notification dialog
        $Selenium->find_element( '.fc-toolbar .fc-prev-button', 'css' )->VerifiedClick();

        # wait for AJAX to finish
        $Selenium->WaitFor( JavaScript => 'return typeof($) === "function" && !$(".CalendarWidget.Loading").length' );

        # click on the timeline view for an appointment dialog
        my $ResourceRow = $Selenium->find_element(
            "//tbody/*//td[contains(\@class, 'fc-time-area')]/*//tr[\@data-resource-id='$UserID']/td"
        );
        $Selenium->move_to(
            element => $ResourceRow,
            xoffset => 150,
            yoffset => 5
        );
        $Selenium->click();

        # wait until form and overlay has loaded, if neccessary
        $Selenium->WaitFor( JavaScript => "return typeof(\$) === 'function' && \$('#Title').length" );

        # verify resource data
        $Self->IsDeeply(
            $Selenium->execute_script(
                "return \$('#TeamID').val();"
            ),
            [$TeamID],
            'Team',
        );
        $Self->IsDeeply(
            $Selenium->execute_script(
                "return \$('#ResourceID').val();"
            ),
            [$UserID],
            'Agent',
        );

        # enter title
        $Selenium->find_element( 'Title', 'name' )->send_keys('Task');

        # select calendar
        $Selenium->execute_script(
            "return \$('#CalendarID').val("
                . $Calendar{CalendarID}
                . ").trigger('redraw.InputField').trigger('change');"
        );

        # click on Save
        $Selenium->find_element( '#EditFormSubmit', 'css' )->VerifiedClick();

        # wait for dialog to close and AJAX to finish
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && !$(".Dialog:visible").length && !$(".CalendarWidget.Loading").length',
        );

        # verify appointment is visible for test user
        $Self->Is(
            $Selenium->execute_script(
                "return \$('tr[data-resource-id=\"$UserID\"] .fc-timeline-event .fc-title').text();"
            ),
            'Task',
            'Appointment visible',
        );

        # go again to team management page
        $Selenium->VerifiedGet("${ScriptAlias}index.pl?Action=AgentAppointmentTeam");

        # filter test team
        $Selenium->find_element( 'input#FilterTeams', 'css' )->send_keys("Test team $RandomID");

        sleep 1;

        # verify only one team is shown
        $Self->Is(
            $Selenium->execute_script(
                "return \$('.ContentColumn table tbody tr:visible').length;",
            ),
            1,
            'Teams are filtered correctly',
        );

        # edit test team
        $Selenium->VerifiedGet("${ScriptAlias}index.pl?Action=AgentAppointmentTeam;Subaction=Change;TeamID=${TeamID}");

        # set it to invalid
        $Selenium->execute_script(
            "return \$('#ValidID').val(2).trigger('redraw.InputField').trigger('change');",
        );

        # submit form
        $Selenium->find_element( 'button.Primary', 'css' )->VerifiedClick();
    },
);

1;
