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

# get selenium object
my $Selenium = $Kernel::OM->Get('Kernel::System::UnitTest::Selenium');

$Selenium->RunTest(
    sub {

        # get needed objects
        my $Helper            = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
        my $GroupObject       = $Kernel::OM->Get('Kernel::System::Group');
        my $CalendarObject    = $Kernel::OM->Get('Kernel::System::Calendar');
        my $AppointmentObject = $Kernel::OM->Get('Kernel::System::Calendar::Appointment');
        my $UserObject        = $Kernel::OM->Get('Kernel::System::User');

        # turn on user time zones
        $Helper->ConfigSettingChange(
            Valid => 1,
            Key   => 'TimeZoneUser',
            Value => 0,
        );

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
        ) || die 'Did not get test user';

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
            CalendarName => "Calendar-$RandomID",
            Color        => '#3A87AD',
            GroupID      => $GroupID,
            UserID       => $UserID,
            ValidID      => 1,
        );

        # go to calendar overview page
        $Selenium->VerifiedGet("${ScriptAlias}index.pl?Action=AgentAppointmentCalendarOverview");

        # wait for AJAX to finish
        $Selenium->WaitFor( JavaScript => 'return typeof($) === "function" && !$(".CalendarWidget.Loading").length' );

        # go to previous week
        $Selenium->find_element( '.fc-toolbar .fc-prev-button', 'css' )->VerifiedClick();

        # wait for AJAX to finish
        $Selenium->WaitFor( JavaScript => 'return typeof($) === "function" && !$(".CalendarWidget.Loading").length' );

        # click on the timeline view for an appointment dialog
        $Selenium->find_element( '.fc-timelineWeek-view .fc-slats td.fc-widget-content:nth-child(5)', 'css' )
            ->VerifiedClick();

        # wait until form and overlay has loaded, if neccessary
        $Selenium->WaitFor( JavaScript => "return typeof(\$) === 'function' && \$('#Title').length" );

        # enter some data
        $Selenium->find_element( 'Title', 'name' )->send_keys('Time Zone Appointment');
        $Selenium->execute_script(
            "\$('#CalendarID').val("
                . $Calendar{CalendarID}
                . ").trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->find_element( 'EndHour', 'name' )->send_keys('18');

        # click on Save
        $Selenium->find_element( '#EditFormSubmit', 'css' )->VerifiedClick();

        # wait for dialog to close and AJAX to finish
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && !$(".Dialog:visible").length && !$(".CalendarWidget.Loading").length'
        );

        # verify appointment is visible
        $Self->Is(
            $Selenium->execute_script(
                "return \$('.fc-timeline-event .fc-title').text();"
            ),
            'Time Zone Appointment',
            'Appointment visible (Calendar Overview)',
        );

        # go to agenda overview page
        $Selenium->VerifiedGet("${ScriptAlias}index.pl?Action=AgentAppointmentAgendaOverview;Filter=Week;Jump=Prev");

        sleep 1;

        # verify appointment is visible
        $Self->True(
            index( $Selenium->get_page_source(), 'Time Zone Appointment' ) > -1,
            'Appointment visible (Agenda Overview)',
        );

        # get appointment id
        my $AppointmentID = $Selenium->execute_script(
            "return \$('.MasterActionLink').data('appointmentId');"
        );

        # get displayed start date
        my $StartDate
            = $Selenium->find_element( "//*[\@id='AppointmentID_$AppointmentID']/td[4]", 'xpath' )->get_text();

        # check start time
        $StartDate =~ /(\d{2}:\d{2}:\d{2})$/;
        my $StartTime = $1;
        $Self->Is(
            $StartTime,
            '08:00:00',
            'Start time in local time',
        );

        # turn on user time zones
        $Helper->ConfigSettingChange(
            Valid => 1,
            Key   => 'TimeZoneUser',
            Value => 1,
        );

        # turn off browser auto offset
        $Helper->ConfigSettingChange(
            Valid => 1,
            Key   => 'TimeZoneUserBrowserAutoOffset',
            Value => 0,
        );

        # set user's time zone
        $UserObject->SetPreferences(
            Key    => 'UserTimeZone',
            Value  => '+2',             # Europe/Berlin
            UserID => $UserID,
        ) || die 'Did not set preference UserTimeZone';

        my %Preferences = $UserObject->GetPreferences(
            UserID => $UserID,
        );
        $Self->Is(
            $Preferences{UserTimeZone},
            '+2',
            'Preference UserTimeZone correct',
        );

        # make sure cache is correct
        for my $Cache (qw(Calendar Appointment)) {
            $Kernel::OM->Get('Kernel::System::Cache')->CleanUp( Type => $Cache );
        }

        # log in again
        $Selenium->Login(
            Type     => 'Agent',
            User     => $TestUserLogin,
            Password => $TestUserLogin,
        );

        # go to agenda overview page again
        $Selenium->VerifiedGet("${ScriptAlias}index.pl?Action=AgentAppointmentAgendaOverview;Filter=Week;Jump=Prev");

        sleep 1;

        # get displayed start date
        my $StartDateTZ
            = $Selenium->find_element( "//*[\@id='AppointmentID_$AppointmentID']/td[4]", 'xpath' )->get_text();

        # check start time again
        $StartDateTZ =~ /(\d{2}:\d{2}:\d{2}\s\(\+2\))$/;
        my $StartTimeTZ = $1;
        $Self->Is(
            $StartTimeTZ,
            '10:00:00 (+2)',
            "Start time in user's time zone",
        );

        # go to calendar overview page again
        $Selenium->VerifiedGet("${ScriptAlias}index.pl?Action=AgentAppointmentCalendarOverview");

        # wait for AJAX to finish
        $Selenium->WaitFor( JavaScript => 'return typeof($) === "function" && !$(".CalendarWidget.Loading").length' );
        $Selenium->WaitFor( JavaScript => "return \$.active == 0" );

        # go to previous week
        $Selenium->find_element( '.fc-toolbar .fc-prev-button', 'css' )->VerifiedClick();

        # wait for AJAX to finish
        $Selenium->WaitFor( JavaScript => 'return typeof($) === "function" && !$(".CalendarWidget.Loading").length' );

        # click on an appointment
        $Selenium->find_element( '.fc-timeline-event', 'css' )->click();

        # wait until form and overlay has loaded, if neccessary
        $Selenium->WaitFor(
            JavaScript => "return typeof(\$) === 'function' && \$('.Dialog').length && \$('#StartHour').length"
        );

        # check start hour
        my $StartHourTZ = $Selenium->find_element( 'StartHour', 'name' )->get_value();
        $Self->Is(
            $StartHourTZ,
            10,
            "Start hour in user's time zone",
        );

        # cleanup

        # delete test appointment
        my $Success = $AppointmentObject->AppointmentDelete(
            AppointmentID => $AppointmentID,
            UserID        => $UserID,
        );
        $Self->True(
            $Success,
            "Deleted test appointment - $AppointmentID",
        );

        # delete test calendar
        if ( $Calendar{CalendarID} ) {
            my $Success = $Kernel::OM->Get('Kernel::System::DB')->Do(
                SQL  => 'DELETE FROM calendar WHERE id = ?',
                Bind => [ \$Calendar{CalendarID} ],
            );
            $Self->True(
                $Success,
                "Deleted test calendar - $Calendar{CalendarID}",
            );
        }

        # make sure cache is correct
        for my $Cache (qw(Calendar Appointment)) {
            $Kernel::OM->Get('Kernel::System::Cache')->CleanUp( Type => $Cache );
        }
    },
);

1;
