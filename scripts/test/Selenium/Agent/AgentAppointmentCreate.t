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

# override local time zone for duration of the test
local $ENV{TZ} = 'UTC';

# get selenium object
my $Selenium = $Kernel::OM->Get('Kernel::System::UnitTest::Selenium');

$Selenium->RunTest(
    sub {

        # get needed objects
        my $Helper               = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
        my $AppointmentObject    = $Kernel::OM->Get('Kernel::System::Calendar::Appointment');
        my $GroupObject          = $Kernel::OM->Get('Kernel::System::Group');
        my $CalendarObject       = $Kernel::OM->Get('Kernel::System::Calendar');
        my $CalendarHelperObject = $Kernel::OM->Get('Kernel::System::Calendar::Helper');
        my $UserObject           = $Kernel::OM->Get('Kernel::System::User');

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

        # get current system time
        my $SystemTime = $CalendarHelperObject->CurrentSystemTime();

        # add 1 month
        $SystemTime = $CalendarHelperObject->AddPeriod(
            Time   => $SystemTime,
            Months => 1,
        );

        # get date info (Second, Minute, Hour, Day, Month, Year, DayOfWeek)
        my @DateInfo = $CalendarHelperObject->DateGet(
            SystemTime => $SystemTime,
        );

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

        # create a few test calendars
        my %Calendar1 = $CalendarObject->CalendarCreate(
            CalendarName => "My Calendar $RandomID",
            Color        => '#3A87AD',
            GroupID      => $GroupID,
            UserID       => $UserID,
            ValidID      => 1,
        );

        # go to calendar overview page
        $Selenium->VerifiedGet("${ScriptAlias}index.pl?Action=AgentAppointmentCalendarOverview");

        # wait for AJAX to finish
        $Selenium->WaitFor( JavaScript => 'return typeof($) === "function" && !$(".CalendarWidget.Loading").length' );

        # click on the month view
        $Selenium->find_element( '.fc-month-button', 'css' )->VerifiedClick();

        # wait for AJAX to finish
        $Selenium->WaitFor( JavaScript => 'return typeof($) === "function" && !$(".CalendarWidget.Loading").length' );

        # go to next month in order to disable realtime notification dialog
        $Selenium->find_element( '.fc-toolbar .fc-next-button', 'css' )->VerifiedClick();

        # wait for AJAX to finish
        $Selenium->WaitFor( JavaScript => 'return typeof($) === "function" && !$(".CalendarWidget.Loading").length' );

        # get date info (Second, Minute, Hour, Day, Month, Year, DayOfWeek)
        my $DataDate = "$DateInfo[5]-";
        if ( $DateInfo[4] < 10 ) {
            $DataDate .= "0";
        }
        $DataDate .= "$DateInfo[4]-01";

        # create every day appointment
        $Selenium->find_element( ".fc-widget-content td[data-date=\"$DataDate\"]", 'css' )->VerifiedClick();

        # wait until form and overlay has loaded, if neccessary
        $Selenium->WaitFor( JavaScript => "return typeof(\$) === 'function' && \$('#Title').length" );

        # enter some data
        $Selenium->find_element( 'Title', 'name' )->send_keys('Every day');
        $Selenium->execute_script(
            "return \$('#CalendarID').val("
                . $Calendar1{CalendarID}
                . ").trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->execute_script(
            "return \$('#RecurrenceType').val('Daily').trigger('redraw.InputField').trigger('change');"
        );

        # click on Save
        $Selenium->find_element( '#EditFormSubmit', 'css' )->VerifiedClick();

        # wait for dialog to close and AJAX to finish
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && !$(".Dialog:visible").length && !$(".CalendarWidget.Loading").length'
        );

        my @Appointments1 = $AppointmentObject->AppointmentList(
            CalendarID => $Calendar1{CalendarID},
            Result     => 'HASH',
        );

        # make sure there are 4 appointments
        $Self->Is(
            scalar @Appointments1,
            4,
            "Create daily recurring appointment."
        );

        my $Delete1 = $AppointmentObject->AppointmentDelete(
            AppointmentID => $Appointments1[0]->{AppointmentID},
            UserID        => $UserID,
        );

        # delete appointments
        $Self->True(
            $Delete1,
            "Delete daily recurring appointments.",
        );

        # create every week appointment
        $Selenium->find_element( ".fc-widget-content td[data-date=\"$DataDate\"]", 'css' )->VerifiedClick();

        # wait until form and overlay has loaded, if neccessary
        $Selenium->WaitFor( JavaScript => "return typeof(\$) === 'function' && \$('#Title').length" );

        # enter some data
        $Selenium->find_element( 'Title', 'name' )->send_keys('Every week');
        $Selenium->execute_script(
            "return \$('#CalendarID').val("
                . $Calendar1{CalendarID}
                . ").trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->execute_script(
            "return \$('#RecurrenceType').val('Weekly').trigger('redraw.InputField').trigger('change');"
        );

        # create 3 appointment
        $Selenium->execute_script(
            "return \$('#RecurrenceLimit').val('2').trigger('redraw.InputField').trigger('change');"
        );

        # enter some data
        $Selenium->find_element( 'RecurrenceCount', 'name' )->send_keys('3');

        # click on Save
        $Selenium->find_element( '#EditFormSubmit', 'css' )->VerifiedClick();

        # wait for AJAX to finish
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && !$(".Dialog:visible").length && !$(".CalendarWidget.Loading").length'
        );

        my @Appointments2 = $AppointmentObject->AppointmentList(
            CalendarID => $Calendar1{CalendarID},
            Result     => 'HASH',
        );

        # make sure there are 3 appointments
        $Self->Is(
            scalar @Appointments2,
            3,
            "Create weekly recurring appointment."
        );

        my $StartAppointment       = "$DataDate 00:00:00";
        my $StartAppointmentSystem = $CalendarHelperObject->SystemTimeGet(
            String => $StartAppointment,
        );

        my @Appointment2StartTimes = (
            $StartAppointment,
            $CalendarHelperObject->TimestampGet(
                SystemTime => $StartAppointmentSystem + 7 * 24 * 3600,
            ),
            $CalendarHelperObject->TimestampGet(
                SystemTime => $StartAppointmentSystem + 14 * 24 * 3600,
            ),
        );

        for my $Index ( 0 .. 2 ) {
            $Self->Is(
                $Appointments2[$Index]->{StartTime},
                $Appointment2StartTimes[$Index],
                "Check start time #$Index",
            );
        }

        # delete appointments
        my $Delete2 = $AppointmentObject->AppointmentDelete(
            AppointmentID => $Appointments2[0]->{AppointmentID},
            UserID        => $UserID,
        );

        # delete appointments
        $Self->True(
            $Delete2,
            "Delete weekly recurring appointments.",
        );

        # create every month appointment
        $Selenium->find_element( ".fc-widget-content td[data-date=\"$DataDate\"]", 'css' )->VerifiedClick();

        # wait until form and overlay has loaded, if neccessary
        $Selenium->WaitFor( JavaScript => "return typeof(\$) === 'function' && \$('#Title').length" );

        # enter some data
        $Selenium->find_element( 'Title', 'name' )->send_keys('Every month');
        $Selenium->execute_script(
            "return \$('#CalendarID').val("
                . $Calendar1{CalendarID}
                . ").trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->execute_script(
            "return \$('#RecurrenceType').val('Monthly').trigger('redraw.InputField').trigger('change');"
        );

        # create 3 appointment
        $Selenium->execute_script(
            "return \$('#RecurrenceLimit').val('2').trigger('redraw.InputField').trigger('change');"
        );

        # enter some data
        $Selenium->find_element( 'RecurrenceCount', 'name' )->send_keys('3');

        # click on Save
        $Selenium->find_element( '#EditFormSubmit', 'css' )->VerifiedClick();

        # wait for AJAX to finish
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && !$(".Dialog:visible").length && !$(".CalendarWidget.Loading").length'
        );

        my @Appointments3 = $AppointmentObject->AppointmentList(
            CalendarID => $Calendar1{CalendarID},
            Result     => 'HASH',
        );

        # make sure there are 3 appointments
        $Self->Is(
            scalar @Appointments3,
            3,
            "Create monthly recurring appointment."
        );

        my @Appointment3StartTimes = (
            $StartAppointment,
            $CalendarHelperObject->TimestampGet(
                SystemTime => $CalendarHelperObject->AddPeriod(
                    Months => 1,
                    Time   => $StartAppointmentSystem,
                ),
            ),
            $CalendarHelperObject->TimestampGet(
                SystemTime => $CalendarHelperObject->AddPeriod(
                    Months => 2,
                    Time   => $StartAppointmentSystem,
                ),
            ),
        );

        for my $Index ( 0 .. 2 ) {
            $Self->Is(
                $Appointments3[$Index]->{StartTime},
                $Appointment3StartTimes[$Index],
                "Check start time #$Index",
            );
        }

        # delete appointments
        my $Delete3 = $AppointmentObject->AppointmentDelete(
            AppointmentID => $Appointments3[0]->{AppointmentID},
            UserID        => $UserID,
        );

        # delete appointments
        $Self->True(
            $Delete3,
            "Delete monthly recurring appointments.",
        );

        # create every year appointment
        $Selenium->find_element( ".fc-widget-content td[data-date=\"$DataDate\"]", 'css' )->VerifiedClick();

        # wait until form and overlay has loaded, if neccessary
        $Selenium->WaitFor( JavaScript => "return typeof(\$) === 'function' && \$('#Title').length" );

        # enter some data
        $Selenium->find_element( 'Title', 'name' )->send_keys('Every year');
        $Selenium->execute_script(
            "return \$('#CalendarID').val("
                . $Calendar1{CalendarID}
                . ").trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->execute_script(
            "return \$('#RecurrenceType').val('Yearly').trigger('redraw.InputField').trigger('change');"
        );

        # create 3 appointment
        $Selenium->execute_script(
            "return \$('#RecurrenceLimit').val('2').trigger('redraw.InputField').trigger('change');"
        );

        # enter some data
        $Selenium->find_element( 'RecurrenceCount', 'name' )->send_keys('3');

        # click on Save
        $Selenium->find_element( '#EditFormSubmit', 'css' )->VerifiedClick();

        # wait for AJAX to finish
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && !$(".Dialog:visible").length && !$(".CalendarWidget.Loading").length'
        );

        my @Appointments4 = $AppointmentObject->AppointmentList(
            CalendarID => $Calendar1{CalendarID},
            Result     => 'HASH',
        );

        # make sure there are 3 appointments
        $Self->Is(
            scalar @Appointments4,
            3,
            "Create yearly recurring appointment."
        );

        my @Appointment4StartTimes = (
            $StartAppointment,
            $CalendarHelperObject->TimestampGet(
                SystemTime => $CalendarHelperObject->AddPeriod(
                    Years => 1,
                    Time  => $StartAppointmentSystem,
                ),
            ),
            $CalendarHelperObject->TimestampGet(
                SystemTime => $CalendarHelperObject->AddPeriod(
                    Years => 2,
                    Time  => $StartAppointmentSystem,
                ),
            ),
        );

        for my $Index ( 0 .. 2 ) {
            $Self->Is(
                $Appointments4[$Index]->{StartTime},
                $Appointment4StartTimes[$Index],
                "Check start time #$Index",
            );
        }

        # delete appointments
        my $Delete4 = $AppointmentObject->AppointmentDelete(
            AppointmentID => $Appointments4[0]->{AppointmentID},
            UserID        => $UserID,
        );

        # delete appointments
        $Self->True(
            $Delete4,
            "Delete yearly recurring appointments.",
        );

        # create appointment every second day
        $Selenium->find_element( ".fc-widget-content td[data-date=\"$DataDate\"]", 'css' )->VerifiedClick();

        # wait until form and overlay has loaded, if neccessary
        $Selenium->WaitFor( JavaScript => "return typeof(\$) === 'function' && \$('#Title').length" );

        # enter some data
        $Selenium->find_element( 'Title', 'name' )->send_keys('Every 2nd day');
        $Selenium->execute_script(
            "return \$('#CalendarID').val("
                . $Calendar1{CalendarID}
                . ").trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->execute_script(
            "return \$('#RecurrenceType').val('Custom').trigger('redraw.InputField').trigger('change');"
        );

        # wait until js shows Interval
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && $("#RecurrenceInterval:visible").length'
        );

        # set each 2nd day
        $Selenium->execute_script(
            "return \$('#RecurrenceInterval').val(2);"
        );

        # create 3 appointment
        $Selenium->execute_script(
            "return \$('#RecurrenceLimit').val('2').trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->find_element( 'RecurrenceCount', 'name' )->send_keys('3');

        # click on Save
        $Selenium->find_element( '#EditFormSubmit', 'css' )->VerifiedClick();

        # wait for dialog to close and AJAX to finish
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && !$(".Dialog:visible").length && !$(".CalendarWidget.Loading").length'
        );

        my @Appointments5 = $AppointmentObject->AppointmentList(
            CalendarID => $Calendar1{CalendarID},
            Result     => 'HASH',
        );

        # make sure there are 3 appointments
        $Self->Is(
            scalar @Appointments5,
            3,
            "Create custom daily recurring appointment."
        );

        my @Appointment5StartTimes = (
            $StartAppointment,
            $CalendarHelperObject->TimestampGet(
                SystemTime => $StartAppointmentSystem + 2 * 24 * 3600,
            ),
            $CalendarHelperObject->TimestampGet(
                SystemTime => $StartAppointmentSystem + 4 * 24 * 3600,
            ),
        );

        for my $Index ( 0 .. 2 ) {
            $Self->Is(
                $Appointments5[$Index]->{StartTime},
                $Appointment5StartTimes[$Index],
                "Check start time #$Index",
            );
        }

        my $Delete5 = $AppointmentObject->AppointmentDelete(
            AppointmentID => $Appointments5[0]->{AppointmentID},
            UserID        => $UserID,
        );

        # delete appointments
        $Self->True(
            $Delete5,
            "Delete custom daily recurring appointments.",
        );

        # create custom weekly recurring appointment
        $Selenium->find_element( ".fc-widget-content td[data-date=\"$DataDate\"]", 'css' )->VerifiedClick();

        # wait until form and overlay has loaded, if neccessary
        $Selenium->WaitFor( JavaScript => "return typeof(\$) === 'function' && \$('#Title').length" );

        # enter some data
        $Selenium->find_element( 'Title', 'name' )->send_keys('Every 2nd Monday, Wednesday and Sunday');
        $Selenium->execute_script(
            "return \$('#CalendarID').val("
                . $Calendar1{CalendarID}
                . ").trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->execute_script(
            "return \$('#RecurrenceType').val('Custom').trigger('redraw.InputField').trigger('change');"
        );

        # wait until js shows Interval
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && $("#RecurrenceInterval:visible").length'
        );

        $Selenium->execute_script(
            "return \$('#RecurrenceCustomType').val('CustomWeekly').trigger('redraw.InputField').trigger('change');"
        );

        # wait for js
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && $("#RecurrenceCustomWeeklyDiv:visible").length'
        );

        # deselect selected day
        $Selenium->execute_script(
            "return \$('#RecurrenceCustomWeeklyDiv button.fc-state-active').click();"
        );

        # make sure it's deselected
        my $Deselected6 = $Selenium->WaitFor(
            JavaScript =>
                'return !$("#RecurrenceCustomWeeklyDiv button.fc-state-active").length;'
        );
        $Self->True(
            $Deselected6,
            "Check if nothing is selected (#6)."
        );

        # select Mon
        $Selenium->execute_script(
            "\$('#RecurrenceCustomWeeklyDiv button[value=\"1\"]').click();"
        );

        # check if selected successful
        my $Wait6For1 = $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && $("#RecurrenceCustomWeeklyDiv button[value=\"1\"]").hasClass("fc-state-active")'
        );
        $Self->True(
            $Wait6For1,
            "Custom weekly appointment - check if Monday is selected."
        );

        # select Wed
        $Selenium->execute_script(
            "\$('#RecurrenceCustomWeeklyDiv button[value=\"3\"]').click();"
        );

        # check if selected successful
        my $Wait6For3 = $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && $("#RecurrenceCustomWeeklyDiv button[value=\"3\"]").hasClass("fc-state-active")'
        );
        $Self->True(
            $Wait6For3,
            "Custom weekly appointment - check if Wednesday is selected."
        );

        # select Sun
        $Selenium->execute_script(
            "\$('#RecurrenceCustomWeeklyDiv button[value=\"7\"]').click();"
        );

        # check if selected successful
        my $Wait6For7 = $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && $("#RecurrenceCustomWeeklyDiv button[value=\"7\"]").hasClass("fc-state-active")'
        );
        $Self->True(
            $Wait6For7,
            "Custom weekly appointment - check if Sunday is selected."
        );

        # set each 2nd week
        $Selenium->execute_script(
            "return \$('#RecurrenceInterval').val(2);"
        );

        # create 6 appointments
        $Selenium->execute_script(
            "return \$('#RecurrenceLimit').val('2').trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->find_element( 'RecurrenceCount', 'name' )->send_keys('6');

        # click on Save
        $Selenium->find_element( '#EditFormSubmit', 'css' )->VerifiedClick();

        # wait for dialog to close and AJAX to finish
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && !$(".Dialog:visible").length && !$(".CalendarWidget.Loading").length'
        );

        my @Appointments6 = $AppointmentObject->AppointmentList(
            CalendarID => $Calendar1{CalendarID},
            Result     => 'HASH',
        );

        # make sure there are 6 appointments
        $Self->Is(
            scalar @Appointments6,
            6,
            "Create custom weekly recurring appointment."
        );

        my @Appointment6StartTimes;
        my $SystemTime6 = $CalendarHelperObject->SystemTimeGet(
            String => "$DataDate 00:00:00",
        );

        my $LastCW6;

        while ( scalar @Appointment6StartTimes != 6 ) {
            my ( $Second, $Minute, $Hour, $Day, $Month, $Year, $DayOfWeek ) = $CalendarHelperObject->DateGet(
                SystemTime => $SystemTime6,
            );

            my ( $Tmp, $CW6 ) = $CalendarHelperObject->WeekDetailsGet(
                SystemTime => $SystemTime6,
            );

            # add current day
            if ( !$LastCW6 ) {
                push @Appointment6StartTimes, $CalendarHelperObject->TimestampGet(
                    SystemTime => $SystemTime6,
                );
                $LastCW6 = $CW6;
            }
            elsif (
                ( grep { $DayOfWeek == $_ } ( 1, 3, 7 ) )    # check if day is valid
                && ( ( $CW6 - $LastCW6 ) % 2 == 0 )          # check if Interval matches
                )
            {
                push @Appointment6StartTimes, $CalendarHelperObject->TimestampGet(
                    SystemTime => $SystemTime6,
                );
                $LastCW6 = $CW6;
            }

            # add one day
            $SystemTime6 += 24 * 3600;
        }

        for my $Index ( 0 .. 5 ) {
            $Self->Is(
                $Appointments6[$Index]->{StartTime},
                $Appointment6StartTimes[$Index],
                "Check start time #$Index",
            );
        }

        my $Delete6 = $AppointmentObject->AppointmentDelete(
            AppointmentID => $Appointments6[0]->{AppointmentID},
            UserID        => $UserID,
        );

        # delete appointments
        $Self->True(
            $Delete6,
            "Delete custom weekly recurring appointments.",
        );

        # create custom weekly recurring appointment(without anything selected)
        $Selenium->find_element( ".fc-widget-content td[data-date=\"$DataDate\"]", 'css' )->VerifiedClick();

        # wait until form and overlay has loaded, if neccessary
        $Selenium->WaitFor( JavaScript => "return typeof(\$) === 'function' && \$('#Title').length" );

        # enter some data
        $Selenium->find_element( 'Title', 'name' )->send_keys('Custom weekly without anything selected');
        $Selenium->execute_script(
            "return \$('#CalendarID').val("
                . $Calendar1{CalendarID}
                . ").trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->execute_script(
            "return \$('#RecurrenceType').val('Custom').trigger('redraw.InputField').trigger('change');"
        );

        # wait until js shows Interval
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && $("#RecurrenceInterval:visible").length'
        );

        $Selenium->execute_script(
            "return \$('#RecurrenceCustomType').val('CustomWeekly').trigger('redraw.InputField').trigger('change');"
        );

        # wait for js
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && $("#RecurrenceCustomWeeklyDiv:visible").length'
        );

        # deselect selected day
        $Selenium->execute_script(
            "return \$('#RecurrenceCustomWeeklyDiv button.fc-state-active').click();"
        );

        # make sure it's deselected
        my $Deselected7 = $Selenium->WaitFor(
            JavaScript =>
                'return !$("#RecurrenceCustomWeeklyDiv button.fc-state-active").length;'
        );
        $Self->True(
            $Deselected7,
            "Check if nothing is selected (#7)."
        );

        # set each 2nd week
        $Selenium->execute_script(
            "return \$('#RecurrenceInterval').val(2);"
        );

        # create 3 appointments
        $Selenium->execute_script(
            "return \$('#RecurrenceLimit').val('2').trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->find_element( 'RecurrenceCount', 'name' )->send_keys('3');

        # click on Save
        $Selenium->find_element( '#EditFormSubmit', 'css' )->VerifiedClick();

        # wait for dialog to close and AJAX to finish
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && !$(".Dialog:visible").length && !$(".CalendarWidget.Loading").length'
        );

        my @Appointments7 = $AppointmentObject->AppointmentList(
            CalendarID => $Calendar1{CalendarID},
            Result     => 'HASH',
        );

        # make sure there are 3 appointments
        $Self->Is(
            scalar @Appointments7,
            3,
            "Create custom weekly recurring appointment(without any day selected)."
        );

        my @Appointment7StartTimes;
        my $SystemTime7 = $CalendarHelperObject->SystemTimeGet(
            String => "$DataDate 00:00:00",
        );

        my $LastCW7;
        my $DayOfWeek7;

        while ( scalar @Appointment7StartTimes != 3 ) {
            my ( $Second, $Minute, $Hour, $Day, $Month, $Year, $DayOfWeek ) = $CalendarHelperObject->DateGet(
                SystemTime => $SystemTime7,
            );

            my ( $Tmp, $CW7 ) = $CalendarHelperObject->WeekDetailsGet(
                SystemTime => $SystemTime7,
            );

            # add current day
            if ( !$LastCW7 ) {
                push @Appointment7StartTimes, $CalendarHelperObject->TimestampGet(
                    SystemTime => $SystemTime7,
                );
                $LastCW7    = $CW7;
                $DayOfWeek7 = $DayOfWeek
            }
            elsif (
                ( $DayOfWeek == $DayOfWeek7 )    # check if day is valid
                && ( ( $CW7 - $LastCW7 ) % 2 == 0 )    # check if Interval matches
                )
            {
                push @Appointment7StartTimes, $CalendarHelperObject->TimestampGet(
                    SystemTime => $SystemTime7,
                );
                $LastCW7 = $CW7;
            }

            # add one day
            $SystemTime7 += 24 * 3600;
        }

        for my $Index ( 0 .. 2 ) {
            $Self->Is(
                $Appointments7[$Index]->{StartTime},
                $Appointment7StartTimes[$Index],
                "Check start time #$Index",
            );
        }

        my $Delete7 = $AppointmentObject->AppointmentDelete(
            AppointmentID => $Appointments7[0]->{AppointmentID},
            UserID        => $UserID,
        );

        # delete appointments
        $Self->True(
            $Delete7,
            "Delete custom weekly recurring appointments.",
        );

        # create custom monthly recurring appointment
        $Selenium->find_element( ".fc-widget-content td[data-date=\"$DataDate\"]", 'css' )->VerifiedClick();

        # wait until form and overlay has loaded, if neccessary
        $Selenium->WaitFor( JavaScript => "return typeof(\$) === 'function' && \$('#Title').length" );

        # enter some data
        $Selenium->find_element( 'Title', 'name' )->send_keys('Every 2nd month, on 3th, 10th and 31th of month.');
        $Selenium->execute_script(
            "return \$('#CalendarID').val("
                . $Calendar1{CalendarID}
                . ").trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->execute_script(
            "return \$('#RecurrenceType').val('Custom').trigger('redraw.InputField').trigger('change');"
        );

        # wait until js shows Interval
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && $("#RecurrenceInterval:visible").length'
        );

        $Selenium->execute_script(
            "return \$('#RecurrenceCustomType').val('CustomMonthly').trigger('redraw.InputField').trigger('change');"
        );

        # wait for js
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && $("#RecurrenceCustomMonthlyDiv:visible").length'
        );

        # deselect selected day
        $Selenium->execute_script(
            "return \$('#RecurrenceCustomMonthlyDiv button.fc-state-active').click();"
        );

        # make sure it's deselected
        my $Deselected8 = $Selenium->WaitFor(
            JavaScript =>
                'return !$("#RecurrenceCustomMonthlyDiv button.fc-state-active").length;'
        );
        $Self->True(
            $Deselected8,
            "Check if nothing is selected (#8)."
        );

        # select 3th
        $Selenium->execute_script(
            "\$('#RecurrenceCustomMonthlyDiv button[value=\"3\"]').click();"
        );

        # check if selected successful
        my $Wait8For3 = $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && $("#RecurrenceCustomMonthlyDiv button[value=\"3\"]").hasClass("fc-state-active")'
        );
        $Self->True(
            $Wait8For3,
            "Custom monthly appointment - check if 3 is selected."
        );

        # select 10th
        $Selenium->execute_script(
            "\$('#RecurrenceCustomMonthlyDiv button[value=\"10\"]').click();"
        );

        # check if selected successful
        my $Wait8For10 = $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && $("#RecurrenceCustomMonthlyDiv button[value=\"10\"]").hasClass("fc-state-active")'
        );
        $Self->True(
            $Wait8For10,
            "Custom monthly appointment - check if 10 is selected."
        );

        # select 31
        $Selenium->execute_script(
            "\$('#RecurrenceCustomMonthlyDiv button[value=\"31\"]').click();"
        );

        # check if selected successful
        my $Wait8For31 = $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && $("#RecurrenceCustomMonthlyDiv button[value=\"31\"]").hasClass("fc-state-active")'
        );
        $Self->True(
            $Wait8For31,
            "Custom monthly appointment - check if 31 is selected."
        );

        # set each 2nd week
        $Selenium->execute_script(
            "return \$('#RecurrenceInterval').val(2);"
        );

        # create 20 appointments
        $Selenium->execute_script(
            "return \$('#RecurrenceLimit').val('2').trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->find_element( 'RecurrenceCount', 'name' )->send_keys('20');

        # click on Save
        $Selenium->find_element( '#EditFormSubmit', 'css' )->VerifiedClick();

        # wait for dialog to close and AJAX to finish
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && !$(".Dialog:visible").length && !$(".CalendarWidget.Loading").length'
        );

        my @Appointments8 = $AppointmentObject->AppointmentList(
            CalendarID => $Calendar1{CalendarID},
            Result     => 'HASH',
        );

        # make sure there are 20 appointments
        $Self->Is(
            scalar @Appointments8,
            20,
            "Create custom monthly recurring appointment."
        );

        my @Appointment8StartTimes;
        my $SystemTime8 = $CalendarHelperObject->SystemTimeGet(
            String => "$DataDate 00:00:00",
        );

        my $LastMonth8;

        while ( scalar @Appointment8StartTimes != 20 ) {
            my ( $Second, $Minute, $Hour, $Day, $Month, $Year, $DayOfWeek ) = $CalendarHelperObject->DateGet(
                SystemTime => $SystemTime8,
            );

            if ( !$LastMonth8 ) {
                push @Appointment8StartTimes, $CalendarHelperObject->TimestampGet(
                    SystemTime => $SystemTime8,
                );
                $LastMonth8 = $Month;
            }
            elsif (
                ( grep { $Day == $_ } ( 3, 10, 31 ) )    # check if day is valid
                && (
                    ( $Month - $LastMonth8 ) % 2 == 0    # check if Interval matches
                )
                )
            {
                push @Appointment8StartTimes, $CalendarHelperObject->TimestampGet(
                    SystemTime => $SystemTime8,
                );
            }

            # add one day
            $SystemTime8 += 24 * 3600;
        }

        for my $Index ( 0 .. 19 ) {
            $Self->Is(
                $Appointments8[$Index]->{StartTime},
                $Appointment8StartTimes[$Index],
                "Check start time #$Index",
            );
        }

        my $Delete8 = $AppointmentObject->AppointmentDelete(
            AppointmentID => $Appointments8[0]->{AppointmentID},
            UserID        => $UserID,
        );

        # delete appointments
        $Self->True(
            $Delete8,
            "Delete custom monthly recurring appointments.",
        );

        # create custom weekly recurring appointment(without anything selected)
        $Selenium->find_element( ".fc-widget-content td[data-date=\"$DataDate\"]", 'css' )->VerifiedClick();

        # wait until form and overlay has loaded, if neccessary
        $Selenium->WaitFor( JavaScript => "return typeof(\$) === 'function' && \$('#Title').length" );

        # enter some data
        $Selenium->find_element( 'Title', 'name' )->send_keys('Custom monthly without anything selected');
        $Selenium->execute_script(
            "return \$('#CalendarID').val("
                . $Calendar1{CalendarID}
                . ").trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->execute_script(
            "return \$('#RecurrenceType').val('Custom').trigger('redraw.InputField').trigger('change');"
        );

        # wait until js shows Interval
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && $("#RecurrenceInterval:visible").length'
        );

        $Selenium->execute_script(
            "return \$('#RecurrenceCustomType').val('CustomMonthly').trigger('redraw.InputField').trigger('change');"
        );

        # wait for js
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && $("#RecurrenceCustomMonthlyDiv:visible").length'
        );

        # deselect selected day
        $Selenium->execute_script(
            "return \$('#RecurrenceCustomMonthlyDiv button.fc-state-active').click();"
        );

        # make sure it's deselected
        my $Deselected9 = $Selenium->WaitFor(
            JavaScript =>
                'return !$("#RecurrenceCustomMonthlyDiv button.fc-state-active").length;'
        );
        $Self->True(
            $Deselected9,
            "Check if nothing is selected (#9)."
        );

        # set each 2nd year
        $Selenium->execute_script(
            "return \$('#RecurrenceInterval').val(2);"
        );

        # create 3 appointments
        $Selenium->execute_script(
            "return \$('#RecurrenceLimit').val('2').trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->find_element( 'RecurrenceCount', 'name' )->send_keys('3');

        # click on Save
        $Selenium->find_element( '#EditFormSubmit', 'css' )->VerifiedClick();

        # wait for dialog to close and AJAX to finish
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && !$(".Dialog:visible").length && !$(".CalendarWidget.Loading").length'
        );

        my @Appointments9 = $AppointmentObject->AppointmentList(
            CalendarID => $Calendar1{CalendarID},
            Result     => 'HASH',
        );

        # make sure there are 3 appointments
        $Self->Is(
            scalar @Appointments9,
            3,
            "Create custom monthly recurring appointment(without any day selected)."
        );

        my @Appointment9StartTimes;
        my $SystemTime9 = $CalendarHelperObject->SystemTimeGet(
            String => "$DataDate 00:00:00",
        );

        my $LastMonth9;
        my $Day9;

        while ( scalar @Appointment9StartTimes != 3 ) {
            my ( $Second, $Minute, $Hour, $Day, $Month, $Year, $DayOfWeek ) = $CalendarHelperObject->DateGet(
                SystemTime => $SystemTime9,
            );

            # add current day
            if ( !$LastMonth9 ) {
                push @Appointment9StartTimes, $CalendarHelperObject->TimestampGet(
                    SystemTime => $SystemTime9,
                );
                $LastMonth9 = $Month;
                $Day9       = $Day;
            }
            elsif (
                ( $Day == $Day9 )    # check if day is valid
                && ( ( $Month - $LastMonth9 ) % 2 == 0 )    # check if Interval matches
                )
            {
                push @Appointment9StartTimes, $CalendarHelperObject->TimestampGet(
                    SystemTime => $SystemTime9,
                );
                $LastMonth9 = $Month;
            }

            # add one day
            $SystemTime9 += 24 * 3600;
        }

        for my $Index ( 0 .. 2 ) {
            $Self->Is(
                $Appointments9[$Index]->{StartTime},
                $Appointment9StartTimes[$Index],
                "Check start time #$Index",
            );
        }

        my $Delete9 = $AppointmentObject->AppointmentDelete(
            AppointmentID => $Appointments9[0]->{AppointmentID},
            UserID        => $UserID,
        );

        # delete appointments
        $Self->True(
            $Delete9,
            "Delete custom weekly recurring appointments.",
        );

        # create custom yearly recurring appointment
        $Selenium->find_element( ".fc-widget-content td[data-date=\"$DataDate\"]", 'css' )->VerifiedClick();

        # wait until form and overlay has loaded, if neccessary
        $Selenium->WaitFor( JavaScript => "return typeof(\$) === 'function' && \$('#Title').length" );

        # enter some data
        $Selenium->find_element( 'Title', 'name' )->send_keys('Every 2nd year, in February, October and December.');
        $Selenium->execute_script(
            "return \$('#CalendarID').val("
                . $Calendar1{CalendarID}
                . ").trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->execute_script(
            "return \$('#RecurrenceType').val('Custom').trigger('redraw.InputField').trigger('change');"
        );

        # wait until js shows Interval
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && $("#RecurrenceInterval:visible").length'
        );

        $Selenium->execute_script(
            "return \$('#RecurrenceCustomType').val('CustomYearly').trigger('redraw.InputField').trigger('change');"
        );

        # wait for js
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && $("#RecurrenceCustomYearlyDiv:visible").length'
        );

        # deselect selected month
        $Selenium->execute_script(
            "return \$('#RecurrenceCustomYearlyDiv button.fc-state-active').click();"
        );

        # make sure it's deselected
        my $Deselected10 = $Selenium->WaitFor(
            JavaScript =>
                'return !$("#RecurrenceCustomYearlyDiv button.fc-state-active").length;'
        );
        $Self->True(
            $Deselected10,
            "Check if nothing is selected (#10)."
        );

        # select February
        $Selenium->execute_script(
            "\$('#RecurrenceCustomYearlyDiv button[value=\"2\"]').click();"
        );

        # check if selected successful
        my $Wait10For2 = $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && $("#RecurrenceCustomYearlyDiv button[value=\"2\"]").hasClass("fc-state-active")'
        );
        $Self->True(
            $Wait10For2,
            "Custom yearly appointment - check if February is selected."
        );

        # select October
        $Selenium->execute_script(
            "\$('#RecurrenceCustomYearlyDiv button[value=\"10\"]').click();"
        );

        # check if selected successful
        my $Wait10For10 = $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && $("#RecurrenceCustomYearlyDiv button[value=\"10\"]").hasClass("fc-state-active")'
        );
        $Self->True(
            $Wait10For10,
            "Custom yearly appointment - check if October is selected."
        );

        # select December
        $Selenium->execute_script(
            "\$('#RecurrenceCustomYearlyDiv button[value=\"12\"]').click();"
        );

        # check if selected successful
        my $Wait10For12 = $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && $("#RecurrenceCustomYearlyDiv button[value=\"12\"]").hasClass("fc-state-active")'
        );
        $Self->True(
            $Wait10For12,
            "Custom yearly appointment - check if December is selected."
        );

        # set each 2nd week
        $Selenium->execute_script(
            "return \$('#RecurrenceInterval').val(2);"
        );

        # create 6 appointments
        $Selenium->execute_script(
            "return \$('#RecurrenceLimit').val('2').trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->find_element( 'RecurrenceCount', 'name' )->send_keys('6');

        # click on Save
        $Selenium->find_element( '#EditFormSubmit', 'css' )->VerifiedClick();

        # wait for dialog to close and AJAX to finish
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && !$(".Dialog:visible").length && !$(".CalendarWidget.Loading").length'
        );

        my @Appointments10 = $AppointmentObject->AppointmentList(
            CalendarID => $Calendar1{CalendarID},
            Result     => 'HASH',
        );

        # make sure there are 6 appointments
        $Self->Is(
            scalar @Appointments10,
            6,
            "Create custom yearly recurring appointment."
        );

        my @Appointment10StartTimes;
        my $SystemTime10 = $CalendarHelperObject->SystemTimeGet(
            String => "$DataDate 00:00:00",
        );

        my $LastYear10;
        my $Day10;

        while ( scalar @Appointment10StartTimes != 6 ) {
            my ( $Second, $Minute, $Hour, $Day, $Month, $Year, $DayOfWeek ) = $CalendarHelperObject->DateGet(
                SystemTime => $SystemTime10,
            );

            if ( !$LastYear10 ) {
                push @Appointment10StartTimes, $CalendarHelperObject->TimestampGet(
                    SystemTime => $SystemTime10,
                );
                $LastYear10 = $Year;
                $Day10      = $Day;
            }
            elsif (
                $Day == $Day10
                && ( grep { $Month == $_ } ( 2, 10, 12 ) )    # check if day is valid
                && ( ( $Year - $LastYear10 ) % 2 == 0 )       # check if Interval matches
                )
            {
                push @Appointment10StartTimes, $CalendarHelperObject->TimestampGet(
                    SystemTime => $SystemTime10,
                );
            }

            # add one day
            $SystemTime10 += 24 * 3600;
        }

        for my $Index ( 0 .. 5 ) {
            $Self->Is(
                $Appointments10[$Index]->{StartTime},
                $Appointment10StartTimes[$Index],
                "Check start time #$Index",
            );
        }

        my $Delete10 = $AppointmentObject->AppointmentDelete(
            AppointmentID => $Appointments10[0]->{AppointmentID},
            UserID        => $UserID,
        );

        # delete appointments
        $Self->True(
            $Delete10,
            "Delete custom monthly recurring appointments.",
        );

        # create custom weekly recurring appointment(without anything selected)
        $Selenium->find_element( ".fc-widget-content td[data-date=\"$DataDate\"]", 'css' )->VerifiedClick();

        # wait until form and overlay has loaded, if neccessary
        $Selenium->WaitFor( JavaScript => "return typeof(\$) === 'function' && \$('#Title').length" );

        # enter some data
        $Selenium->find_element( 'Title', 'name' )->send_keys('Custom yearly without anything selected');
        $Selenium->execute_script(
            "return \$('#CalendarID').val("
                . $Calendar1{CalendarID}
                . ").trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->execute_script(
            "return \$('#RecurrenceType').val('Custom').trigger('redraw.InputField').trigger('change');"
        );

        # wait until js shows Interval
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && $("#RecurrenceInterval:visible").length'
        );

        $Selenium->execute_script(
            "return \$('#RecurrenceCustomType').val('CustomYearly').trigger('redraw.InputField').trigger('change');"
        );

        # wait for js
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && $("#RecurrenceCustomYearlyDiv:visible").length'
        );

        # deselect selected month
        $Selenium->execute_script(
            "return \$('#RecurrenceCustomYearlyDiv button.fc-state-active').click();"
        );

        # make sure it's deselected
        my $Deselected11 = $Selenium->WaitFor(
            JavaScript =>
                'return !$("#RecurrenceCustomYearlyDiv button.fc-state-active").length;'
        );
        $Self->True(
            $Deselected11,
            "Check if nothing is selected (#11)."
        );

        # set each 2nd year
        $Selenium->execute_script(
            "return \$('#RecurrenceInterval').val(2);"
        );

        # create 3 appointments
        $Selenium->execute_script(
            "return \$('#RecurrenceLimit').val('2').trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->find_element( 'RecurrenceCount', 'name' )->send_keys('3');

        # click on Save
        $Selenium->find_element( '#EditFormSubmit', 'css' )->VerifiedClick();

        # wait for dialog to close and AJAX to finish
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && !$(".Dialog:visible").length && !$(".CalendarWidget.Loading").length'
        );

        my @Appointments11 = $AppointmentObject->AppointmentList(
            CalendarID => $Calendar1{CalendarID},
            Result     => 'HASH',
        );

        # make sure there are 3 appointments
        $Self->Is(
            scalar @Appointments11,
            3,
            "Create custom yearly recurring appointment(without any month selected)."
        );

        my @Appointment11StartTimes;
        my $SystemTime11 = $CalendarHelperObject->SystemTimeGet(
            String => "$DataDate 00:00:00",
        );

        my $LastYear11;
        my $Day11;
        my $Month11;

        while ( scalar @Appointment11StartTimes != 3 ) {
            my ( $Second, $Minute, $Hour, $Day, $Month, $Year, $DayOfWeek ) = $CalendarHelperObject->DateGet(
                SystemTime => $SystemTime11,
            );

            # add current day
            if ( !$LastYear11 ) {
                push @Appointment11StartTimes, $CalendarHelperObject->TimestampGet(
                    SystemTime => $SystemTime11,
                );
                $LastYear11 = $Year;
                $Day11      = $Day;
                $Month11    = $Month;
            }
            elsif (
                ( $Day == $Day11 )    # check if day is valid
                && $Month == $Month11
                && ( ( $Year - $LastYear11 ) % 2 == 0 )    # check if Interval matches
                )
            {
                push @Appointment11StartTimes, $CalendarHelperObject->TimestampGet(
                    SystemTime => $SystemTime11,
                );
            }

            # add one day
            $SystemTime11 += 24 * 3600;
        }

        for my $Index ( 0 .. 2 ) {
            $Self->Is(
                $Appointments11[$Index]->{StartTime},
                $Appointment11StartTimes[$Index],
                "Check start time #$Index",
            );
        }

        my $Delete11 = $AppointmentObject->AppointmentDelete(
            AppointmentID => $Appointments11[0]->{AppointmentID},
            UserID        => $UserID,
        );

        # delete appointments
        $Self->True(
            $Delete11,
            "Delete custom yearly recurring appointments(without any month selected).",
        );
    },
);

1;
