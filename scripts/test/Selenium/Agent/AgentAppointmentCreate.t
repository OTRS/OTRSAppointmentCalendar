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

# Get selenium object
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

        # Get needed objects
        $Kernel::OM->ObjectParamAdd(
            'Kernel::System::UnitTest::Helper' => {
                RestoreSystemConfiguration => 1,
            },
        );
        my $Helper               = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
        my $AppointmentObject    = $Kernel::OM->Get('Kernel::System::Calendar::Appointment');
        my $SysConfigObject      = $Kernel::OM->Get('Kernel::System::SysConfig');
        my $GroupObject          = $Kernel::OM->Get('Kernel::System::Group');
        my $CalendarObject       = $Kernel::OM->Get('Kernel::System::Calendar');
        my $CalendarHelperObject = $Kernel::OM->Get('Kernel::System::Calendar::Helper');
        my $TimeObject           = $Kernel::OM->Get('Kernel::System::Time');
        my $UserObject           = $Kernel::OM->Get('Kernel::System::User');

        my $RandomID = $Helper->GetRandomID();

        # Create test group
        my $GroupName = "test-calendar-group-$RandomID";
        my $GroupID   = $GroupObject->GroupAdd(
            Name    => $GroupName,
            ValidID => 1,
            UserID  => 1,
        );

        # Get script alias
        my $ScriptAlias = $Kernel::OM->Get('Kernel::Config')->Get('ScriptAlias');

        # Get current system time
        my $SystemTime = $CalendarHelperObject->CurrentSystemTime();

        # Add 1 month
        $SystemTime = $CalendarHelperObject->AddPeriod(
            Time   => $SystemTime,
            Months => 1,
        );

        # Get date info (Second, Minute, Hour, Day, Month, Year, DayOfWeek)
        my @DateInfo = $CalendarHelperObject->DateGet(
            SystemTime => $SystemTime,
        );

        # Change resolution (desktop mode)
        $Selenium->set_window_size( 768, 1050 );

        # Create test user
        my $Language      = 'en';
        my $TestUserLogin = $Helper->TestUserCreate(
            Groups   => [ 'users', $GroupName ],
            Language => $Language,
        ) || die "Did not get test user";

        # Get UserID
        my $UserID = $UserObject->UserLookup(
            UserLogin => $TestUserLogin,
        );

        # Start test
        $Selenium->Login(
            Type     => 'Agent',
            User     => $TestUserLogin,
            Password => $TestUserLogin,
        );

        # Create a few test calendars
        my %Calendar1 = $CalendarObject->CalendarCreate(
            CalendarName => "My Calendar $RandomID",
            Color        => '#3A87AD',
            GroupID      => $GroupID,
            UserID       => $UserID,
            ValidID      => 1,
        );

        # Go to calendar overview page
        $Selenium->VerifiedGet("${ScriptAlias}index.pl?Action=AgentAppointmentCalendarOverview");

        # Wait for AJAX to finish
        $Selenium->WaitFor( JavaScript => 'return typeof($) === "function" && !$(".CalendarWidget.Loading").length' );

        # Click on the month view
        $Selenium->find_element( '.fc-month-button', 'css' )->click();

        # Wait for AJAX to finish
        $Selenium->WaitFor( JavaScript => 'return typeof($) === "function" && !$(".CalendarWidget.Loading").length' );

        # Go to next month in order to disable realtime notification dialog
        $Selenium->find_element( '.fc-toolbar .fc-next-button', 'css' )->click();

        # wait for AJAX to finish
        $Selenium->WaitFor( JavaScript => 'return typeof($) === "function" && !$(".CalendarWidget.Loading").length' );

        # Get date info (Second, Minute, Hour, Day, Month, Year, DayOfWeek)
        my $DataDate = "$DateInfo[5]-";
        if ( $DateInfo[4] < 10 ) {
            $DataDate .= "0";
        }
        $DataDate .= "$DateInfo[4]-01";

        # Create every day appointment
        $Selenium->find_element( ".fc-widget-content td[data-date=\"$DataDate\"]", 'css' )->click();

        # Wait until form and overlay has loaded, if neccessary
        $Selenium->WaitFor( JavaScript => "return typeof(\$) === 'function' && \$('#Title').length" );

        # Enter some data
        $Selenium->find_element( 'Title', 'name' )->send_keys('Every day');
        $Selenium->execute_script(
            "return \$('#CalendarID').val("
                . $Calendar1{CalendarID}
                . ").trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->execute_script(
            "return \$('#RecurrenceType').val('Daily').trigger('redraw.InputField').trigger('change');"
        );

        # Click on Save
        $Selenium->find_element( '#EditFormSubmit', 'css' )->click();

        # Wait for dialog to close and AJAX to finish
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && !$(".Dialog:visible").length && !$(".CalendarWidget.Loading").length'
        );

        my @Appointments1 = $AppointmentObject->AppointmentList(
            CalendarID => $Calendar1{CalendarID},
            Result     => 'HASH',
        );

        # Make sure there are 4 appointments
        $Self->Is(
            scalar @Appointments1,
            4,
            "Create daily recurring appointment."
        );

        my $Delete1 = $AppointmentObject->AppointmentDelete(
            AppointmentID => $Appointments1[0]->{AppointmentID},
            UserID        => $UserID,
        );

        # Delete appointments
        $Self->True(
            $Delete1,
            "Delete daily recurring appointments.",
        );

        # Create every week appointment
        $Selenium->find_element( ".fc-widget-content td[data-date=\"$DataDate\"]", 'css' )->click();

        # Wait until form and overlay has loaded, if neccessary
        $Selenium->WaitFor( JavaScript => "return typeof(\$) === 'function' && \$('#Title').length" );

        # Enter some data
        $Selenium->find_element( 'Title', 'name' )->send_keys('Every week');
        $Selenium->execute_script(
            "return \$('#CalendarID').val("
                . $Calendar1{CalendarID}
                . ").trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->execute_script(
            "return \$('#RecurrenceType').val('Weekly').trigger('redraw.InputField').trigger('change');"
        );

        # Create 3 appointment
        $Selenium->execute_script(
            "return \$('#RecurrenceLimit').val('2').trigger('redraw.InputField').trigger('change');"
        );

        # Enter some data
        $Selenium->find_element( 'RecurrenceCount', 'name' )->send_keys('3');

        # Click on Save
        $Selenium->find_element( '#EditFormSubmit', 'css' )->click();

        # Wait for AJAX to finish
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && !$(".Dialog:visible").length && !$(".CalendarWidget.Loading").length'
        );

        my @Appointments2 = $AppointmentObject->AppointmentList(
            CalendarID => $Calendar1{CalendarID},
            Result     => 'HASH',
        );

        # Make sure there are 3 appointments
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

        # Delete appointments
        my $Delete2 = $AppointmentObject->AppointmentDelete(
            AppointmentID => $Appointments2[0]->{AppointmentID},
            UserID        => $UserID,
        );

        # Delete appointments
        $Self->True(
            $Delete2,
            "Delete weekly recurring appointments.",
        );

        # Create every month appointment
        $Selenium->find_element( ".fc-widget-content td[data-date=\"$DataDate\"]", 'css' )->click();

        # Wait until form and overlay has loaded, if neccessary
        $Selenium->WaitFor( JavaScript => "return typeof(\$) === 'function' && \$('#Title').length" );

        # Enter some data
        $Selenium->find_element( 'Title', 'name' )->send_keys('Every month');
        $Selenium->execute_script(
            "return \$('#CalendarID').val("
                . $Calendar1{CalendarID}
                . ").trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->execute_script(
            "return \$('#RecurrenceType').val('Monthly').trigger('redraw.InputField').trigger('change');"
        );

        # Create 3 appointment
        $Selenium->execute_script(
            "return \$('#RecurrenceLimit').val('2').trigger('redraw.InputField').trigger('change');"
        );

        # Enter some data
        $Selenium->find_element( 'RecurrenceCount', 'name' )->send_keys('3');

        # Click on Save
        $Selenium->find_element( '#EditFormSubmit', 'css' )->click();

        # Wait for AJAX to finish
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && !$(".Dialog:visible").length && !$(".CalendarWidget.Loading").length'
        );

        my @Appointments3 = $AppointmentObject->AppointmentList(
            CalendarID => $Calendar1{CalendarID},
            Result     => 'HASH',
        );

        # Make sure there are 3 appointments
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

        # Delete appointments
        my $Delete3 = $AppointmentObject->AppointmentDelete(
            AppointmentID => $Appointments3[0]->{AppointmentID},
            UserID        => $UserID,
        );

        # Delete appointments
        $Self->True(
            $Delete3,
            "Delete monthly recurring appointments.",
        );

        # Create every year appointment
        $Selenium->find_element( ".fc-widget-content td[data-date=\"$DataDate\"]", 'css' )->click();

        # Wait until form and overlay has loaded, if neccessary
        $Selenium->WaitFor( JavaScript => "return typeof(\$) === 'function' && \$('#Title').length" );

        # Enter some data
        $Selenium->find_element( 'Title', 'name' )->send_keys('Every year');
        $Selenium->execute_script(
            "return \$('#CalendarID').val("
                . $Calendar1{CalendarID}
                . ").trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->execute_script(
            "return \$('#RecurrenceType').val('Yearly').trigger('redraw.InputField').trigger('change');"
        );

        # Create 3 appointment
        $Selenium->execute_script(
            "return \$('#RecurrenceLimit').val('2').trigger('redraw.InputField').trigger('change');"
        );

        # Enter some data
        $Selenium->find_element( 'RecurrenceCount', 'name' )->send_keys('3');

        # Click on Save
        $Selenium->find_element( '#EditFormSubmit', 'css' )->click();

        # Wait for AJAX to finish
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && !$(".Dialog:visible").length && !$(".CalendarWidget.Loading").length'
        );

        my @Appointments4 = $AppointmentObject->AppointmentList(
            CalendarID => $Calendar1{CalendarID},
            Result     => 'HASH',
        );

        # Make sure there are 3 appointments
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

        # Delete appointments
        my $Delete4 = $AppointmentObject->AppointmentDelete(
            AppointmentID => $Appointments4[0]->{AppointmentID},
            UserID        => $UserID,
        );

        # Delete appointments
        $Self->True(
            $Delete4,
            "Delete yearly recurring appointments.",
        );

        # Create appointment every second day
        $Selenium->find_element( ".fc-widget-content td[data-date=\"$DataDate\"]", 'css' )->click();

        # Wait until form and overlay has loaded, if neccessary
        $Selenium->WaitFor( JavaScript => "return typeof(\$) === 'function' && \$('#Title').length" );

        # Enter some data
        $Selenium->find_element( 'Title', 'name' )->send_keys('Every 2nd day');
        $Selenium->execute_script(
            "return \$('#CalendarID').val("
                . $Calendar1{CalendarID}
                . ").trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->execute_script(
            "return \$('#RecurrenceType').val('Custom').trigger('redraw.InputField').trigger('change');"
        );

        # Wait until js shows Interval
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && $("#RecurrenceInterval:visible").length'
        );

        # Set each 2nd day
        $Selenium->execute_script(
            "return \$('#RecurrenceInterval').val(2);"
        );

        # Create 3 appointment
        $Selenium->execute_script(
            "return \$('#RecurrenceLimit').val('2').trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->find_element( 'RecurrenceCount', 'name' )->send_keys('3');

        # Click on Save
        $Selenium->find_element( '#EditFormSubmit', 'css' )->click();

        # Wait for dialog to close and AJAX to finish
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && !$(".Dialog:visible").length && !$(".CalendarWidget.Loading").length'
        );

        my @Appointments5 = $AppointmentObject->AppointmentList(
            CalendarID => $Calendar1{CalendarID},
            Result     => 'HASH',
        );

        # Make sure there are 3 appointments
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

        # Delete appointments
        $Self->True(
            $Delete5,
            "Delete custom daily recurring appointments.",
        );

        # Create custom weekly recurring appointment
        $Selenium->find_element( ".fc-widget-content td[data-date=\"$DataDate\"]", 'css' )->click();

        # Wait until form and overlay has loaded, if neccessary
        $Selenium->WaitFor( JavaScript => "return typeof(\$) === 'function' && \$('#Title').length" );

        # Enter some data
        $Selenium->find_element( 'Title', 'name' )->send_keys('Every 2nd Monday, Wednesday and Sunday');
        $Selenium->execute_script(
            "return \$('#CalendarID').val("
                . $Calendar1{CalendarID}
                . ").trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->execute_script(
            "return \$('#RecurrenceType').val('Custom').trigger('redraw.InputField').trigger('change');"
        );

        # Wait until js shows Interval
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && $("#RecurrenceInterval:visible").length'
        );

        $Selenium->execute_script(
            "return \$('#RecurrenceCustomType').val('CustomWeekly').trigger('redraw.InputField').trigger('change');"
        );

        # Wait for js
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && $("#RecurrenceCustomWeeklyDiv:visible").length'
        );

        # Deselect selected day
        $Selenium->find_element( '#RecurrenceCustomWeeklyDiv button.fc-state-active', 'css' )->click();

        # Now select Mon, Wed and Sun
        $Selenium->find_element( '#RecurrenceCustomWeeklyDiv button[value="1"]', 'css' )->click();
        $Selenium->find_element( '#RecurrenceCustomWeeklyDiv button[value="3"]', 'css' )->click();
        $Selenium->find_element( '#RecurrenceCustomWeeklyDiv button[value="7"]', 'css' )->click();

        # Set each 2nd week
        $Selenium->execute_script(
            "return \$('#RecurrenceInterval').val(2);"
        );

        # Create 6 appointments
        $Selenium->execute_script(
            "return \$('#RecurrenceLimit').val('2').trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->find_element( 'RecurrenceCount', 'name' )->send_keys('6');

        # Click on Save
        $Selenium->find_element( '#EditFormSubmit', 'css' )->click();

        # Wait for dialog to close and AJAX to finish
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && !$(".Dialog:visible").length && !$(".CalendarWidget.Loading").length'
        );

        my @Appointments6 = $AppointmentObject->AppointmentList(
            CalendarID => $Calendar1{CalendarID},
            Result     => 'HASH',
        );

        # Make sure there are 6 appointments
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

            # Add current day
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

            # Add one day
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

        # Delete appointments
        $Self->True(
            $Delete6,
            "Delete custom weekly recurring appointments.",
        );

        # Create custom weekly recurring appointment(without anything selected)
        $Selenium->find_element( ".fc-widget-content td[data-date=\"$DataDate\"]", 'css' )->click();

        # Wait until form and overlay has loaded, if neccessary
        $Selenium->WaitFor( JavaScript => "return typeof(\$) === 'function' && \$('#Title').length" );

        # Enter some data
        $Selenium->find_element( 'Title', 'name' )->send_keys('Custom weekly without anything selected');
        $Selenium->execute_script(
            "return \$('#CalendarID').val("
                . $Calendar1{CalendarID}
                . ").trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->execute_script(
            "return \$('#RecurrenceType').val('Custom').trigger('redraw.InputField').trigger('change');"
        );

        # Wait until js shows Interval
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && $("#RecurrenceInterval:visible").length'
        );

        $Selenium->execute_script(
            "return \$('#RecurrenceCustomType').val('CustomWeekly').trigger('redraw.InputField').trigger('change');"
        );

        # Wait for js
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && $("#RecurrenceCustomWeeklyDiv:visible").length'
        );

        # Deselect selected day
        $Selenium->find_element( '#RecurrenceCustomWeeklyDiv button.fc-state-active', 'css' )->click();

        # Set each 2nd week
        $Selenium->execute_script(
            "return \$('#RecurrenceInterval').val(2);"
        );

        # Create 3 appointments
        $Selenium->execute_script(
            "return \$('#RecurrenceLimit').val('2').trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->find_element( 'RecurrenceCount', 'name' )->send_keys('3');

        # Click on Save
        $Selenium->find_element( '#EditFormSubmit', 'css' )->click();

        # Wait for dialog to close and AJAX to finish
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && !$(".Dialog:visible").length && !$(".CalendarWidget.Loading").length'
        );

        my @Appointments7 = $AppointmentObject->AppointmentList(
            CalendarID => $Calendar1{CalendarID},
            Result     => 'HASH',
        );

        # Make sure there are 3 appointments
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

            # Add current day
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

            # Add one day
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

        # Delete appointments
        $Self->True(
            $Delete7,
            "Delete custom weekly recurring appointments.",
        );

        # Create custom monthly recurring appointment
        $Selenium->find_element( ".fc-widget-content td[data-date=\"$DataDate\"]", 'css' )->click();

        # Wait until form and overlay has loaded, if neccessary
        $Selenium->WaitFor( JavaScript => "return typeof(\$) === 'function' && \$('#Title').length" );

        # Enter some data
        $Selenium->find_element( 'Title', 'name' )->send_keys('Every 2nd month, on 3th, 10th and 31th of month.');
        $Selenium->execute_script(
            "return \$('#CalendarID').val("
                . $Calendar1{CalendarID}
                . ").trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->execute_script(
            "return \$('#RecurrenceType').val('Custom').trigger('redraw.InputField').trigger('change');"
        );

        # Wait until js shows Interval
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && $("#RecurrenceInterval:visible").length'
        );

        $Selenium->execute_script(
            "return \$('#RecurrenceCustomType').val('CustomMonthly').trigger('redraw.InputField').trigger('change');"
        );

        # Wait for js
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && $("#RecurrenceCustomMonthlyDiv:visible").length'
        );

        # Deselect selected day
        $Selenium->find_element( '#RecurrenceCustomMonthlyDiv button.fc-state-active', 'css' )->click();

        # # Now select Mon, Wed and Sun
        $Selenium->find_element( '#RecurrenceCustomMonthlyDiv button[value="3"]',  'css' )->click();
        $Selenium->find_element( '#RecurrenceCustomMonthlyDiv button[value="10"]', 'css' )->click();
        $Selenium->find_element( '#RecurrenceCustomMonthlyDiv button[value="31"]', 'css' )->click();

        # Set each 2nd week
        $Selenium->execute_script(
            "return \$('#RecurrenceInterval').val(2);"
        );

        # Create 20 appointments
        $Selenium->execute_script(
            "return \$('#RecurrenceLimit').val('2').trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->find_element( 'RecurrenceCount', 'name' )->send_keys('20');

        # Click on Save
        $Selenium->find_element( '#EditFormSubmit', 'css' )->click();

        # Wait for dialog to close and AJAX to finish
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && !$(".Dialog:visible").length && !$(".CalendarWidget.Loading").length'
        );

        my @Appointments8 = $AppointmentObject->AppointmentList(
            CalendarID => $Calendar1{CalendarID},
            Result     => 'HASH',
        );

        # Make sure there are 20 appointments
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

            # Add one day
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

        # Delete appointments
        $Self->True(
            $Delete8,
            "Delete custom monthly recurring appointments.",
        );

        # Create custom weekly recurring appointment(without anything selected)
        $Selenium->find_element( ".fc-widget-content td[data-date=\"$DataDate\"]", 'css' )->click();

        # Wait until form and overlay has loaded, if neccessary
        $Selenium->WaitFor( JavaScript => "return typeof(\$) === 'function' && \$('#Title').length" );

        # Enter some data
        $Selenium->find_element( 'Title', 'name' )->send_keys('Custom monthly without anything selected');
        $Selenium->execute_script(
            "return \$('#CalendarID').val("
                . $Calendar1{CalendarID}
                . ").trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->execute_script(
            "return \$('#RecurrenceType').val('Custom').trigger('redraw.InputField').trigger('change');"
        );

        # Wait until js shows Interval
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && $("#RecurrenceInterval:visible").length'
        );

        $Selenium->execute_script(
            "return \$('#RecurrenceCustomType').val('CustomMonthly').trigger('redraw.InputField').trigger('change');"
        );

        # Wait for js
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && $("#RecurrenceCustomMonthlyDiv:visible").length'
        );

        # Deselect selected day
        $Selenium->find_element( '#RecurrenceCustomMonthlyDiv button.fc-state-active', 'css' )->click();

        # Set each 2nd year
        $Selenium->execute_script(
            "return \$('#RecurrenceInterval').val(2);"
        );

        # Create 3 appointments
        $Selenium->execute_script(
            "return \$('#RecurrenceLimit').val('2').trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->find_element( 'RecurrenceCount', 'name' )->send_keys('3');

        # Click on Save
        $Selenium->find_element( '#EditFormSubmit', 'css' )->click();

        # Wait for dialog to close and AJAX to finish
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && !$(".Dialog:visible").length && !$(".CalendarWidget.Loading").length'
        );

        my @Appointments9 = $AppointmentObject->AppointmentList(
            CalendarID => $Calendar1{CalendarID},
            Result     => 'HASH',
        );

        # Make sure there are 3 appointments
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

            # Add current day
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

            # Add one day
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

        # Delete appointments
        $Self->True(
            $Delete9,
            "Delete custom weekly recurring appointments.",
        );

        # Create custom yearly recurring appointment
        $Selenium->find_element( ".fc-widget-content td[data-date=\"$DataDate\"]", 'css' )->click();

        # Wait until form and overlay has loaded, if neccessary
        $Selenium->WaitFor( JavaScript => "return typeof(\$) === 'function' && \$('#Title').length" );

        # Enter some data
        $Selenium->find_element( 'Title', 'name' )->send_keys('Every 2nd year, in February, October and December.');
        $Selenium->execute_script(
            "return \$('#CalendarID').val("
                . $Calendar1{CalendarID}
                . ").trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->execute_script(
            "return \$('#RecurrenceType').val('Custom').trigger('redraw.InputField').trigger('change');"
        );

        # Wait until js shows Interval
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && $("#RecurrenceInterval:visible").length'
        );

        $Selenium->execute_script(
            "return \$('#RecurrenceCustomType').val('CustomYearly').trigger('redraw.InputField').trigger('change');"
        );

        # Wait for js
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && $("#RecurrenceCustomYearlyDiv:visible").length'
        );

        # Deselect selected month
        $Selenium->find_element( '#RecurrenceCustomYearlyDiv button.fc-state-active', 'css' )->click();

        # Now select Feb, Oct and Dec
        $Selenium->execute_script(
            "\$('#RecurrenceCustomYearlyDiv button[value=\"2\"]').trigger('click');"
        );
        $Selenium->execute_script(
            "\$('#RecurrenceCustomYearlyDiv button[value=\"10\"]').trigger('click');"
        );
        $Selenium->execute_script(
            "\$('#RecurrenceCustomYearlyDiv button[value=\"12\"]').trigger('click');"
        );

        # Set each 2nd week
        $Selenium->execute_script(
            "return \$('#RecurrenceInterval').val(2);"
        );

        # Create 6 appointments
        $Selenium->execute_script(
            "return \$('#RecurrenceLimit').val('2').trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->find_element( 'RecurrenceCount', 'name' )->send_keys('6');

        # Click on Save
        $Selenium->find_element( '#EditFormSubmit', 'css' )->click();

        # Wait for dialog to close and AJAX to finish
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && !$(".Dialog:visible").length && !$(".CalendarWidget.Loading").length'
        );

        my @Appointments10 = $AppointmentObject->AppointmentList(
            CalendarID => $Calendar1{CalendarID},
            Result     => 'HASH',
        );

        # Make sure there are 6 appointments
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

            # Add one day
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

        # Delete appointments
        $Self->True(
            $Delete10,
            "Delete custom monthly recurring appointments.",
        );

        # Create custom weekly recurring appointment(without anything selected)
        $Selenium->find_element( ".fc-widget-content td[data-date=\"$DataDate\"]", 'css' )->click();

        # Wait until form and overlay has loaded, if neccessary
        $Selenium->WaitFor( JavaScript => "return typeof(\$) === 'function' && \$('#Title').length" );

        # Enter some data
        $Selenium->find_element( 'Title', 'name' )->send_keys('Custom yearly without anything selected');
        $Selenium->execute_script(
            "return \$('#CalendarID').val("
                . $Calendar1{CalendarID}
                . ").trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->execute_script(
            "return \$('#RecurrenceType').val('Custom').trigger('redraw.InputField').trigger('change');"
        );

        # Wait until js shows Interval
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && $("#RecurrenceInterval:visible").length'
        );

        $Selenium->execute_script(
            "return \$('#RecurrenceCustomType').val('CustomYearly').trigger('redraw.InputField').trigger('change');"
        );

        # Wait for js
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && $("#RecurrenceCustomYearlyDiv:visible").length'
        );

        # Deselect selected month
        $Selenium->find_element( '#RecurrenceCustomYearlyDiv button.fc-state-active', 'css' )->click();

        # Set each 2nd year
        $Selenium->execute_script(
            "return \$('#RecurrenceInterval').val(2);"
        );

        # Create 3 appointments
        $Selenium->execute_script(
            "return \$('#RecurrenceLimit').val('2').trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->find_element( 'RecurrenceCount', 'name' )->send_keys('3');

        # Click on Save
        $Selenium->find_element( '#EditFormSubmit', 'css' )->click();

        # Wait for dialog to close and AJAX to finish
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && !$(".Dialog:visible").length && !$(".CalendarWidget.Loading").length'
        );

        my @Appointments11 = $AppointmentObject->AppointmentList(
            CalendarID => $Calendar1{CalendarID},
            Result     => 'HASH',
        );

        # Make sure there are 3 appointments
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

            # Add current day
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

            # Add one day
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

        # Delete appointments
        $Self->True(
            $Delete11,
            "Delete custom yearly recurring appointments(without any month selected).",
        );

        }
);

1;
