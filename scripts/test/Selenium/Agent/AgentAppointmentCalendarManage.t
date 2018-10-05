# --
# Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

use strict;
use warnings;
use utf8;

use vars (qw($Self));

my $Selenium = $Kernel::OM->Get('Kernel::System::UnitTest::Selenium');

$Selenium->RunTest(
    sub {

        my $Helper      = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
        my $GroupObject = $Kernel::OM->Get('Kernel::System::Group');

        my $RandomID = $Helper->GetRandomID();

        # Create test group.
        my $GroupName = "test-calendar-group-$RandomID";
        my $GroupID   = $GroupObject->GroupAdd(
            Name    => $GroupName,
            ValidID => 1,
            UserID  => 1,
        );
        $Self->True(
            $GroupID,
            'Test group created',
        );

        # Create test queue.
        my $QueueID = $Kernel::OM->Get('Kernel::System::Queue')->QueueAdd(
            Name            => "Queue$RandomID",
            ValidID         => 1,
            GroupID         => $GroupID,
            SystemAddressID => 1,
            SalutationID    => 1,
            SignatureID     => 1,
            Comment         => 'Some comment',
            UserID          => 1,
        );
        $Self->True(
            $QueueID,
            'Test queue created',
        );

        my $ScriptAlias = $Kernel::OM->Get('Kernel::Config')->Get('ScriptAlias');

        # Change resolution (desktop mode).
        $Selenium->set_window_size( 768, 1050 );

        # Create test user.
        my $Language      = 'en';
        my $TestUserLogin = $Helper->TestUserCreate(
            Groups   => [$GroupName],
            Language => $Language,
        ) || die 'Did not get test user';

        # Start test.
        $Selenium->Login(
            Type     => 'Agent',
            User     => $TestUserLogin,
            Password => $TestUserLogin,
        );

        # Open AgentAppointmentCalendarManage page.
        $Selenium->VerifiedGet("${ScriptAlias}index.pl?Action=AgentAppointmentCalendarManage");

        # Click Add new calendar.
        $Selenium->find_element( '.SidebarColumn ul.ActionList a#Add', 'css' )->VerifiedClick();

        # Write calendar name.
        $Selenium->find_element( 'form#CalendarFrom input#CalendarName', 'css' )->send_keys("Calendar $RandomID");

        # Set it to test group.
        $Selenium->execute_script(
            "\$('#GroupID').val($GroupID).trigger('redraw.InputField').trigger('change');"
        );

        # Submit.
        $Selenium->find_element( 'form#CalendarFrom button#Submit', 'css' )->VerifiedClick();

        # Verify download and copy-to-clipboard links.
        for my $Class (qw(DownloadLink CopyToClipboard)) {
            my $Element = $Selenium->find_element( ".$Class", 'css' );

            my $URL;
            if ( $Class eq 'DownloadLink' ) {
                $URL = $Element->get_attribute('href');
            }
            elsif ( $Class eq 'CopyToClipboard' ) {
                $URL = $Selenium->execute_script("return \$('.$Class').attr('data-clipboard-text');");
            }

            $Self->True(
                $URL,
                "$Class URL present"
            );

            # URL should not contain OTRS specific URL delimiter of semicolon (;).
            #   For better compatibility, use standard ampersand (&) instead.
            #   Please see bug#12667 for more information.
            $Self->False(
                ( $URL =~ /[;]/ ) ? 1 : 0,
                "$Class URL does not contain forbidden characters"
            );
        }

        #
        # Let's try to add calendar with same name.
        #
        # Click Add new calendar.
        $Selenium->find_element( '.SidebarColumn ul.ActionList a#Add', 'css' )->VerifiedClick();

        # Write calendar name.
        $Selenium->find_element( 'form#CalendarFrom input#CalendarName', 'css' )->send_keys("Calendar $RandomID");

        # Set it to test group.
        $Selenium->execute_script(
            "\$('#GroupID').val($GroupID).trigger('redraw.InputField').trigger('change');"
        );

        # Submit.
        $Selenium->find_element( 'form#CalendarFrom button#Submit', 'css' )->VerifiedClick();

        # Wait for server side error.
        $Selenium->WaitFor(
            JavaScript => "return typeof(\$) === 'function' && \$('div.Dialog button#DialogButton1').length"
        );

        # Click ok to dismiss.
        $Selenium->find_element( 'div.Dialog button#DialogButton1', 'css' )->VerifiedClick();

        # Wait for tooltip message.
        $Selenium->WaitFor(
            JavaScript => "return typeof(\$) === 'function' && \$('div#OTRS_UI_Tooltips_ErrorTooltip').length"
        );

        # Update calendar name.
        $Selenium->find_element( 'form#CalendarFrom input#CalendarName', 'css' )->clear();
        $Selenium->find_element( 'form#CalendarFrom input#CalendarName', 'css' )->send_keys("Calendar $RandomID 2");

        # Set it to invalid.
        $Selenium->execute_script(
            "\$('#ValidID').val(2).trigger('redraw.InputField').trigger('change');"
        );

        # Add ticket appointment rule.
        $Selenium->find_element( '.WidgetSimple.Collapsed .WidgetAction.Toggle a', 'css' )->VerifiedClick();
        $Selenium->find_element( '#AddRuleButton',                                 'css' )->VerifiedClick();

        # Set a queue.
        $Selenium->execute_script(
            "\$('#QueueID_1').val('$QueueID').trigger('redraw.InputField').trigger('change');"
        );

        # Add title as search parameter.
        $Selenium->execute_script(
            "\$('#SearchParams').val('Title').trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->find_element( '.AddButton',           'css' )->VerifiedClick();
        $Selenium->find_element( '#SearchParam_1_Title', 'css' )->send_keys('Test*');

        # Submit.
        $Selenium->find_element( 'form#CalendarFrom button#Submit', 'css' )->VerifiedClick();

        # Verify two calendars are shown.
        $Self->Is(
            $Selenium->execute_script(
                "return \$('.ContentColumn table tbody tr:visible').length;"
            ),
            2,
            'All calendars are displayed',
        );

        # Filter just added calendar.
        $Selenium->find_element( 'input#FilterCalendars', 'css' )->send_keys("Calendar $RandomID 2");

        sleep 1;

        # Verify only one calendar is shown.
        $Self->Is(
            $Selenium->execute_script(
                "return \$('.ContentColumn table tbody tr:visible').length;"
            ),
            1,
            'Calendars are filtered correctly',
        );

        # Verify the calendar is invalid.
        my $LanguageObject = Kernel::Language->new(
            UserLanguage => $Language,
        );
        $Self->Is(
            $Selenium->find_element( '.ContentColumn table tbody tr:nth-of-type(2) td:nth-of-type(4)', 'css' )
                ->get_text(),
            $LanguageObject->Translate('invalid'),
            'Calendar is marked invalid',
        );

        # Edit invalid calendar.
        $Selenium->find_element( '.ContentColumn table tbody tr:nth-of-type(2) td a', 'css' )->VerifiedClick();

        # Set it to invalid-temporarily.
        $Selenium->execute_script(
            "\$('#ValidID').val(3).trigger('redraw.InputField').trigger('change');"
        );

        # Verify rule has been stored properly.
        $Self->IsDeeply(
            $Selenium->execute_script(
                "return \$('select[id*=\"QueueID_\"]').val();"
            ),
            [$QueueID],
            'Queue stored properly',
        );
        $Self->Is(
            $Selenium->execute_script(
                "return \$('input[id*=\"_Title\"]').val();"
            ),
            'Test*',
            'Search param stored properly',
        );

        # Remove the rule.
        $Selenium->find_element( '.RemoveButton', 'css' )->VerifiedClick();

        # Submit.
        $Selenium->find_element( 'form#CalendarFrom button#Submit', 'css' )->VerifiedClick();

        # Verify the calendar is invalid temporarily.
        $Self->Is(
            $Selenium->find_element( '.ContentColumn table tbody tr:nth-of-type(2) td:nth-of-type(4)', 'css' )
                ->get_text(),
            $LanguageObject->Translate('invalid-temporarily'),
            'Calendar is marked invalid temporarily',
        );

        # Cleanup

        my $DBObject          = $Kernel::OM->Get('Kernel::System::DB');
        my $SchedulerDBObject = $Kernel::OM->Get('Kernel::System::Daemon::SchedulerDB');

        # Delete test calendars.
        my $Success = $DBObject->Do(
            SQL  => 'DELETE FROM calendar WHERE name = ? OR name = ?',
            Bind => [ \"Calendar $RandomID", \"Calendar $RandomID 2", ],
        );
        $Self->True(
            $Success,
            "Deleted test calendars - Calendar $RandomID (2)",
        );

        # Delete test queue.
        $Success = $DBObject->Do(
            SQL  => 'DELETE FROM queue WHERE id = ?',
            Bind => [ \$QueueID, ],
        );
        $Self->True(
            $Success,
            "Deleted test queue - $QueueID",
        );

        # Remove scheduled asynchronous tasks from DB, as they may interfere with tests run later.
        my @TaskIDs;
        my @AllTasks = $SchedulerDBObject->TaskList(
            Type => 'AsynchronousExecutor',
        );
        for my $Task (@AllTasks) {
            if ( $Task->{Name} eq 'Kernel::System::Calendar-TicketAppointmentProcessCalendar()' ) {
                push @TaskIDs, $Task->{TaskID};
            }
        }
        for my $TaskID (@TaskIDs) {
            my $Success = $SchedulerDBObject->TaskDelete(
                TaskID => $TaskID,
            );
            $Self->True(
                $Success,
                "TaskDelete - Removed scheduled asynchronous task $TaskID",
            );
        }

        my $CacheObject = $Kernel::OM->Get('Kernel::System::Cache');

        # Make sure cache is correct.
        for my $Cache (qw(Calendar Queue)) {
            $CacheObject->CleanUp( Type => $Cache );
        }
    },
);

1;
