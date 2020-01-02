# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
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

        my $Helper               = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
        my $ConfigObject         = $Kernel::OM->Get('Kernel::Config');
        my $CalendarObject       = $Kernel::OM->Get('Kernel::System::Calendar');
        my $CalendarHelperObject = $Kernel::OM->Get('Kernel::System::Calendar::Helper');

        my $RandomID = $Helper->GetRandomID();

        # Create test group.
        my $GroupName = "test-calendar-group-$RandomID";
        my $GroupID   = $Kernel::OM->Get('Kernel::System::Group')->GroupAdd(
            Name    => $GroupName,
            ValidID => 1,
            UserID  => 1,
        );

        my $ScriptAlias = $ConfigObject->Get('ScriptAlias');

        # Create test user.
        my $Language      = 'en';
        my $TestUserLogin = $Helper->TestUserCreate(
            Groups   => [ 'users', $GroupName ],
            Language => $Language,
        ) || die "Did not get test user";

        my $UserID = $Kernel::OM->Get('Kernel::System::User')->UserLookup(
            UserLogin => $TestUserLogin,
        );

        # Create test customer user.
        my $TestCustomerUserLogin = $Helper->TestCustomerUserCreate() || die "Did not get test customer user";

        # Login as test user.
        $Selenium->Login(
            Type     => 'Agent',
            User     => $TestUserLogin,
            Password => $TestUserLogin,
        );

        # Create a few test calendars.
        my @Calendars;
        my $Count = 1;
        for my $Color ( '#3A87AD', '#EC9073', '#6BAD54' ) {
            my %Calendar = $CalendarObject->CalendarCreate(
                CalendarName => "Calendar$Count-$RandomID",
                Color        => $Color,
                GroupID      => $GroupID,
                UserID       => $UserID,
                ValidID      => 1,
            );
            push @Calendars, \%Calendar;

            $Count++;
        }

        my $CalendarWeekDayStart = $ConfigObject->Get('CalendarWeekDayStart') || 7;

        # Get start of the week.
        my $StartTime = $CalendarHelperObject->CurrentSystemTime();
        my ( $WeekDay, $CW ) = $CalendarHelperObject->WeekDetailsGet(
            SystemTime => $StartTime,
        );
        while ( $WeekDay != $CalendarWeekDayStart ) {
            $StartTime -= 60 * 60 * 24;
            ( $WeekDay, $CW ) = $CalendarHelperObject->WeekDetailsGet(
                SystemTime => $StartTime,
            );
        }
        my ( $Second, $Minute, $Hour, $Day, $Month, $Year, $DayOfWeek ) = $CalendarHelperObject->DateGet(
            SystemTime => $StartTime,
        );

        # Appointment times will always be the same at the start of the week.
        my %StartTime = (
            Day    => $Day,
            Month  => $Month,
            Year   => $Year,
            Hour   => 12,
            Minute => 15,
        );

        # Define appointment names.
        my @AppointmentNames = ( 'Appointment 1', 'Appointment 2', 'Appointment 3' );

        # Go to agenda overview page.
        $Selenium->VerifiedGet("${ScriptAlias}index.pl?Action=AgentAppointmentAgendaOverview");

        # Click on the appointment create button.
        $Selenium->find_element( '#AppointmentCreateButton', 'css' )->VerifiedClick();

        # Wait until form and overlay has loaded, if neccessary.
        $Selenium->WaitFor(
            JavaScript => "return typeof(\$) === 'function' && \$('#Title').length"
        );

        # Create a regular appointment.
        $Selenium->find_element( 'Title', 'name' )->clear();
        $Selenium->find_element( 'Title', 'name' )->send_keys( $AppointmentNames[0] );
        for my $Group (qw(Start End)) {
            for my $Field (qw(Hour Minute Day Month Year)) {
                $Selenium->execute_script(
                    "\$('#$Group$Field').val($StartTime{$Field}).trigger('change');"
                );
            }
        }
        $Selenium->execute_script(
            "\$('#CalendarID').val("
                . $Calendars[0]->{CalendarID}
                . ").trigger('redraw.InputField').trigger('change');"
        );

        # Save.
        $Selenium->find_element( '#EditFormSubmit', 'css' )->click();
        $Selenium->WaitFor( JavaScript => "return typeof(\$) === 'function' && !\$('.Dialog.Modal').length" );

        # Verify the regular appointment is visible.
        $Self->True(
            $Selenium->execute_script("return \$('tbody tr:contains($AppointmentNames[0])').length;"),
            "First appointment '$AppointmentNames[0]' found in the table"
        );

        # Click on the create button for another appointment dialog.
        $Selenium->find_element( '#AppointmentCreateButton', 'css' )->click();
        $Selenium->WaitFor( JavaScript => "return typeof(\$) === 'function' && \$('#Title').length" );

        # Create an all-day appointment.
        $Selenium->find_element( 'Title',  'name' )->send_keys( $AppointmentNames[1] );
        $Selenium->find_element( 'AllDay', 'name' )->VerifiedClick();
        for my $Group (qw(Start End)) {
            for my $Field (qw(Day Month Year)) {
                $Selenium->execute_script(
                    "\$('#$Group$Field').val($StartTime{$Field}).trigger('change');"
                );
            }
        }
        $Selenium->execute_script(
            "\$('#CalendarID').val("
                . $Calendars[1]->{CalendarID}
                . ").trigger('redraw.InputField').trigger('change');"
        );

        $Selenium->find_element( '#EditFormSubmit', 'css' )->click();
        $Selenium->WaitFor( JavaScript => "return typeof(\$) === 'function' && !\$('.Dialog.Modal').length" );

        # Verify the all-day appointment is visible.
        $Self->True(
            $Selenium->execute_script("return \$('tbody tr:contains($AppointmentNames[1])').length;"),
            "Second appointment '$AppointmentNames[1]' found in the table"
        );

        my $RecurrenceCount = 3;

        # Click again on the create button for an appointment dialog.
        $Selenium->find_element( '#AppointmentCreateButton', 'css' )->click();
        $Selenium->WaitFor( JavaScript => "return typeof(\$) === 'function' && \$('#Title').length" );

        # Create recurring appointment.
        $Selenium->find_element( 'Title', 'name' )->send_keys( $AppointmentNames[2] );
        for my $Group (qw(Start End)) {
            for my $Field (qw(Hour Minute Day Month Year)) {
                $Selenium->execute_script(
                    "\$('#$Group$Field').val($StartTime{$Field}).trigger('change');"
                );
            }
        }
        $Selenium->execute_script(
            "\$('#CalendarID').val("
                . $Calendars[2]->{CalendarID}
                . ").trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->execute_script(
            "\$('#RecurrenceType').val('Daily').trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->execute_script(
            "\$('#RecurrenceLimit').val('2').trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->find_element( 'RecurrenceCount', 'name' )->send_keys($RecurrenceCount);

        $Selenium->find_element( '#EditFormSubmit', 'css' )->click();
        $Selenium->WaitFor( JavaScript => "return typeof(\$) === 'function' && !\$('.Dialog.Modal').length" );
        $Selenium->VerifiedRefresh();

        # Verify all third appointment occurrences are visible.
        $Self->True(
            $Selenium->execute_script(
                "return \$('tbody tr:contains($AppointmentNames[2])').length === $RecurrenceCount;"
            ),
            "All third appointment occurrences found in the table"
        );

        # Delete third appointment master.
        $Selenium->find_element( $AppointmentNames[2], 'link_text' )->click();
        $Selenium->WaitFor(
            JavaScript => "return typeof(\$) === 'function' && \$('#Title').length && \$('#EditFormDelete').length"
        );

        $Selenium->find_element( '#EditFormDelete', 'css' )->click();
        $Selenium->WaitFor( AlertPresent => 1 );
        $Selenium->accept_alert();
        $Selenium->WaitFor(
            JavaScript =>
                "return typeof(\$) === 'function' &&  \$('tbody tr:contains($AppointmentNames[2])').length === 0;"
        );

        # Verify all third appointment occurences have been removed.
        $Self->False(
            $Selenium->execute_script("return \$('tbody tr:contains($AppointmentNames[2])').length;"),
            "All third appointment occurences deleted"
        );
    },
);

1;
