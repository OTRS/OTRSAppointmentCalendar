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

        my $Helper               = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
        my $AppointmentObject    = $Kernel::OM->Get('Kernel::System::Calendar::Appointment');
        my $GroupObject          = $Kernel::OM->Get('Kernel::System::Group');
        my $CalendarObject       = $Kernel::OM->Get('Kernel::System::Calendar');
        my $CalendarHelperObject = $Kernel::OM->Get('Kernel::System::Calendar::Helper');
        my $UserObject           = $Kernel::OM->Get('Kernel::System::User');

        my $RandomID = $Helper->GetRandomID();

        # Create test group.
        my $GroupName = "test-calendar-group-$RandomID";
        my $GroupID   = $GroupObject->GroupAdd(
            Name    => $GroupName,
            ValidID => 1,
            UserID  => 1,
        );

        my $ScriptAlias = $Kernel::OM->Get('Kernel::Config')->Get('ScriptAlias');

        # Get current system time.
        my $SystemTime = $CalendarHelperObject->CurrentSystemTime();

        # Add 1 month.
        $SystemTime = $CalendarHelperObject->AddPeriod(
            Time   => $SystemTime,
            Months => 1,
        );

        # Get date info (Second, Minute, Hour, Day, Month, Year, DayOfWeek).
        my @DateInfo = $CalendarHelperObject->DateGet(
            SystemTime => $SystemTime,
        );

        # Change resolution (desktop mode).
        $Selenium->set_window_size( 768, 1050 );

        # Create test user.
        my $Language      = 'en';
        my $TestUserLogin = $Helper->TestUserCreate(
            Groups   => [ 'users', $GroupName ],
            Language => $Language,
        ) || die "Did not get test user";

        # Get UserID.
        my $UserID = $UserObject->UserLookup(
            UserLogin => $TestUserLogin,
        );

        # Start test.
        $Selenium->Login(
            Type     => 'Agent',
            User     => $TestUserLogin,
            Password => $TestUserLogin,
        );

        # Create a few test calendars.
        my %Calendar1 = $CalendarObject->CalendarCreate(
            CalendarName => "My Calendar $RandomID",
            Color        => '#3A87AD',
            GroupID      => $GroupID,
            UserID       => $UserID,
            ValidID      => 1,
        );

        # Go to calendar overview page.
        $Selenium->VerifiedGet("${ScriptAlias}index.pl?Action=AgentAppointmentCalendarOverview");

        # Wait for AJAX to finish.
        $Selenium->WaitFor( JavaScript => 'return typeof($) === "function" && !$(".CalendarWidget.Loading").length;' );

        # Click on the month view.
        $Selenium->find_element( '.fc-month-button', 'css' )->VerifiedClick();

        # Wait for AJAX to finish.
        $Selenium->WaitFor( JavaScript => 'return typeof($) === "function" && !$(".CalendarWidget.Loading").length;' );

        # Go to next month.
        $Selenium->find_element( '.fc-toolbar .fc-next-button', 'css' )->VerifiedClick();

        # Wait for AJAX to finish.
        $Selenium->WaitFor( JavaScript => 'return typeof($) === "function" && !$(".CalendarWidget.Loading").length;' );

        # Get date info (Second, Minute, Hour, Day, Month, Year, DayOfWeek).
        my $DataDate = "$DateInfo[5]-";
        if ( $DateInfo[4] < 10 ) {
            $DataDate .= "0";
        }
        $DataDate .= "$DateInfo[4]-01";

        #
        # Pre-Defined Templates
        #

        # Define appointment test with pre-defined notification templates.
        my @TemplateCreateTests = (

            # No active notification template.
            {
                Data => {
                    Description          => 'No notification',
                    NotificationTemplate => 0,
                    Offset               => 0,
                },
                Result => {
                    NotificationDate                      => '',
                    NotificationTemplate                  => '',
                    NotificationCustom                    => '',
                    NotificationCustomRelativeUnitCount   => 0,
                    NotificationCustomRelativeUnit        => '',
                    NotificationCustomRelativePointOfTime => '',
                },
            },

            # Notification template start (appointment start time).
            {
                Data => {
                    Description          => 'Appointment start',
                    NotificationTemplate => 'Start',
                    Offset               => 0,
                },
                Result => {
                    NotificationTemplate                  => 'Start',
                    NotificationCustom                    => '',
                    NotificationCustomRelativeUnitCount   => 0,
                    NotificationCustomRelativeUnit        => 'minutes',
                    NotificationCustomRelativePointOfTime => 'beforestart',
                },
            },

            # Notification template 5 minutes before.
            {
                Data => {
                    Description          => '5 minutes before',
                    NotificationTemplate => 300,
                    Offset               => 300,
                },
                Result => {
                    NotificationTemplate                  => 300,
                    NotificationCustom                    => '',
                    NotificationCustomRelativeUnitCount   => 0,
                    NotificationCustomRelativeUnit        => 'minutes',
                    NotificationCustomRelativePointOfTime => 'beforestart',
                },
            },

            # Notification template 15 minutes before.
            {
                Data => {
                    Description          => '15 minutes before',
                    NotificationTemplate => 900,
                    Offset               => 900,
                },
                Result => {
                    NotificationTemplate                  => 900,
                    NotificationCustom                    => '',
                    NotificationCustomRelativeUnitCount   => 0,
                    NotificationCustomRelativeUnit        => 'minutes',
                    NotificationCustomRelativePointOfTime => 'beforestart',
                },
            },

            # Notification template 30 minutes before.
            {
                Data => {
                    Description          => '30 minutes before',
                    NotificationTemplate => 1800,
                    Offset               => 1800,
                },
                Result => {
                    NotificationTemplate                  => 1800,
                    NotificationCustom                    => '',
                    NotificationCustomRelativeUnitCount   => 0,
                    NotificationCustomRelativeUnit        => 'minutes',
                    NotificationCustomRelativePointOfTime => 'beforestart',
                },
            },

            # Notification template 1 hour before.
            {
                Data => {
                    Description          => '1 hour before',
                    NotificationTemplate => 3600,
                    Offset               => 3600,
                },
                Result => {
                    NotificationTemplate                  => 3600,
                    NotificationCustom                    => '',
                    NotificationCustomRelativeUnitCount   => 0,
                    NotificationCustomRelativeUnit        => 'minutes',
                    NotificationCustomRelativePointOfTime => 'beforestart',
                },
            },

            # Notification template 2 hours before.
            {
                Data => {
                    Description          => '2 hours before',
                    NotificationTemplate => 7200,
                    Offset               => 7200,
                },
                Result => {
                    NotificationTemplate                  => 7200,
                    NotificationCustom                    => '',
                    NotificationCustomRelativeUnitCount   => 0,
                    NotificationCustomRelativeUnit        => 'minutes',
                    NotificationCustomRelativePointOfTime => 'beforestart',
                },
            },

            # Notification template 12 hours before.
            {
                Data => {
                    Description          => '12 hours before',
                    NotificationTemplate => 43200,
                    Offset               => 43200,
                },
                Result => {
                    NotificationTemplate                  => 43200,
                    NotificationCustom                    => '',
                    NotificationCustomRelativeUnitCount   => 0,
                    NotificationCustomRelativeUnit        => 'minutes',
                    NotificationCustomRelativePointOfTime => 'beforestart',
                },
            },

            # Notification template 1 day before.
            {
                Data => {
                    Description          => '1 day before',
                    NotificationTemplate => 86400,
                    Offset               => 86400,
                },
                Result => {
                    NotificationTemplate                  => 86400,
                    NotificationCustom                    => '',
                    NotificationCustomRelativeUnitCount   => 0,
                    NotificationCustomRelativeUnit        => 'minutes',
                    NotificationCustomRelativePointOfTime => 'beforestart',
                },
            },

            # Notification template 2 days before.
            {
                Data => {
                    Description          => '2 days before',
                    NotificationTemplate => 172800,
                    Offset               => 172800,
                },
                Result => {
                    NotificationTemplate                  => 172800,
                    NotificationCustom                    => '',
                    NotificationCustomRelativeUnitCount   => 0,
                    NotificationCustomRelativeUnit        => 'minutes',
                    NotificationCustomRelativePointOfTime => 'beforestart',
                },
            },

            # Notification template 1 week before.
            {
                Data => {
                    Description          => '1 week before',
                    NotificationTemplate => 604800,
                    Offset               => 604800,
                },
                Result => {
                    NotificationTemplate                  => 604800,
                    NotificationCustom                    => '',
                    NotificationCustomRelativeUnitCount   => 0,
                    NotificationCustomRelativeUnit        => 'minutes',
                    NotificationCustomRelativePointOfTime => 'beforestart',
                },
            },
        );

        # Notification pre-defined template test execution.
        for my $Test (@TemplateCreateTests) {

            # Create appointment
            $Selenium->find_element( ".fc-widget-content td[data-date=\"$DataDate\"]", 'css' )->VerifiedClick();

            # Wait until form and overlay has loaded, if neccessary
            $Selenium->WaitFor( JavaScript => "return typeof(\$) === 'function' && \$('#Title').length;" );

            # Enter some data.
            $Selenium->find_element( 'Title', 'name' )->send_keys("$Test->{Data}->{Description}");
            $Selenium->execute_script(
                "\$('#CalendarID').val("
                    . $Calendar1{CalendarID}
                    . ").trigger('redraw.InputField').trigger('change');"
            );

            $Selenium->execute_script(
                "\$('#NotificationTemplate').val('$Test->{Data}->{NotificationTemplate}').trigger('redraw.InputField').trigger('change');"
            );

            # Click on Save.
            $Selenium->find_element( '#EditFormSubmit', 'css' )->VerifiedClick();

            # Wait for dialog to close and AJAX to finish.
            $Selenium->WaitFor(
                JavaScript =>
                    'return typeof($) === "function" && !$(".Dialog:visible").length && !$(".CalendarWidget.Loading").length;'
            );

            my @AppointmentList = $AppointmentObject->AppointmentList(
                CalendarID => $Calendar1{CalendarID},
                Result     => 'HASH',
            );

            # Make sure there is an appointment.
            $Self->Is(
                scalar @AppointmentList,
                1,
                "Appointment list verification - $Test->{Data}->{Description} ."
            );

            if ( $Test->{Data}->{NotificationTemplate} ) {

                my $StartAppointment       = "$DataDate 00:00:00";
                my $StartAppointmentSystem = $CalendarHelperObject->SystemTimeGet(
                    String => $StartAppointment,
                );

                my $NotificationDate = $CalendarHelperObject->TimestampGet(
                    SystemTime => ( $StartAppointmentSystem - $Test->{Data}->{Offset} ),
                );

                $Self->Is(
                    $AppointmentList[0]->{NotificationDate},
                    $NotificationDate,
                    "Verify notification date - $Test->{Data}->{Description} ."
                );
            }

            # Verify results.
            for my $ResultKey ( sort keys %{ $Test->{Result} } ) {

                $Self->Is(
                    $AppointmentList[0]->{$ResultKey} // '',
                    $Test->{Result}->{$ResultKey},
                    'Notification appointment result: ' . $ResultKey . ' - ' . $Test->{Data}->{Description},
                );
            }

            my $Delete = $AppointmentObject->AppointmentDelete(
                AppointmentID => $AppointmentList[0]->{AppointmentID},
                UserID        => $UserID,
            );

            # Delete appointment.
            $Self->True(
                $Delete,
                "Delete appointment verification - $Test->{Data}->{Description} .",
            );
        }

        #
        # Custom Relative Templates
        #

        # Define appointment test with custom notification templates.
        my @TemplateCustomRelativeCreateTests = (

            # Custom relative notification 0 minutes before start.
            {
                Data => {
                    Description                           => 'Custom relative 0 minutes before start',
                    NotificationTemplate                  => 'Custom',
                    NotificationCustomRelativeInput       => 1,
                    NotificationCustomDateTimeInput       => 0,
                    NotificationCustomRelativeUnitCount   => 0,
                    NotificationCustomRelativeUnit        => 'minutes',
                    NotificationCustomRelativePointOfTime => 'beforestart',
                    UserID                                => $UserID,
                },
                Result => {
                    NotificationTemplate                  => 'Custom',
                    NotificationCustom                    => 'relative',
                    NotificationCustomRelativeUnitCount   => 0,
                    NotificationCustomRelativeUnit        => 'minutes',
                    NotificationCustomRelativePointOfTime => 'beforestart',
                },
            },

            # Custom relative notification -2 minutes before start.
            {
                Data => {
                    Description                           => 'Custom relative -2 minutes before start',
                    NotificationTemplate                  => 'Custom',
                    NotificationCustomRelativeInput       => 1,
                    NotificationCustomDateTimeInput       => 0,
                    NotificationCustomRelativeUnitCount   => -2,
                    NotificationCustomRelativeUnit        => 'minutes',
                    NotificationCustomRelativePointOfTime => 'beforestart',
                    UserID                                => $UserID,
                },
                Result => {
                    NotificationTemplate                  => 'Custom',
                    NotificationCustom                    => 'relative',
                    NotificationCustomRelativeUnitCount   => 0,
                    NotificationCustomRelativeUnit        => 'minutes',
                    NotificationCustomRelativePointOfTime => 'beforestart',
                },
            },

            # Custom relative notification 2 minutes before start.
            {
                Data => {
                    Description                           => 'Custom relative 2 minutes before start',
                    NotificationTemplate                  => 'Custom',
                    NotificationCustomRelativeInput       => 1,
                    NotificationCustomDateTimeInput       => 0,
                    NotificationCustomRelativeUnitCount   => 2,
                    NotificationCustomRelativeUnit        => 'minutes',
                    NotificationCustomRelativePointOfTime => 'beforestart',
                    UserID                                => $UserID,
                },
                Result => {
                    NotificationTemplate                  => 'Custom',
                    NotificationCustom                    => 'relative',
                    NotificationCustomRelativeUnitCount   => 2,
                    NotificationCustomRelativeUnit        => 'minutes',
                    NotificationCustomRelativePointOfTime => 'beforestart',
                },
            },

            # Custom relative notification 0 minutes after start.
            {
                Data => {
                    Description                           => 'Custom relative 0 minutes after start',
                    NotificationTemplate                  => 'Custom',
                    NotificationCustomRelativeInput       => 1,
                    NotificationCustomDateTimeInput       => 0,
                    NotificationCustomRelativeUnitCount   => 0,
                    NotificationCustomRelativeUnit        => 'minutes',
                    NotificationCustomRelativePointOfTime => 'afterstart',
                    UserID                                => $UserID,
                },
                Result => {
                    NotificationTemplate                  => 'Custom',
                    NotificationCustom                    => 'relative',
                    NotificationCustomRelativeUnitCount   => 0,
                    NotificationCustomRelativeUnit        => 'minutes',
                    NotificationCustomRelativePointOfTime => 'afterstart',
                },
            },

            # Custom relative notification 0 minutes before end.
            {
                Data => {
                    Description                           => 'Custom relative 0 minutes before end',
                    NotificationTemplate                  => 'Custom',
                    NotificationCustomRelativeInput       => 1,
                    NotificationCustomDateTimeInput       => 0,
                    NotificationCustomRelativeUnitCount   => 0,
                    NotificationCustomRelativeUnit        => 'minutes',
                    NotificationCustomRelativePointOfTime => 'beforeend',
                    UserID                                => $UserID,
                },
                Result => {
                    NotificationTemplate                  => 'Custom',
                    NotificationCustom                    => 'relative',
                    NotificationCustomRelativeUnitCount   => 0,
                    NotificationCustomRelativeUnit        => 'minutes',
                    NotificationCustomRelativePointOfTime => 'beforeend',
                },
            },

            # Custom relative notification 0 minutes after end.
            {
                Data => {
                    Description                           => 'Custom relative 0 minutes after end',
                    NotificationTemplate                  => 'Custom',
                    NotificationCustomRelativeInput       => 1,
                    NotificationCustomDateTimeInput       => 0,
                    NotificationCustomRelativeUnitCount   => 0,
                    NotificationCustomRelativeUnit        => 'minutes',
                    NotificationCustomRelativePointOfTime => 'afterend',
                    UserID                                => $UserID,
                },
                Result => {
                    NotificationTemplate                  => 'Custom',
                    NotificationCustom                    => 'relative',
                    NotificationCustomRelativeUnitCount   => 0,
                    NotificationCustomRelativeUnit        => 'minutes',
                    NotificationCustomRelativePointOfTime => 'afterend',
                },
            },
        );

        # Notification custom relative template test execution.
        for my $Test (@TemplateCustomRelativeCreateTests) {

            # Create appointment
            $Selenium->find_element( ".fc-widget-content td[data-date=\"$DataDate\"]", 'css' )->VerifiedClick();

            # Wait until form and overlay has loaded, if neccessary.
            $Selenium->WaitFor( JavaScript => "return typeof(\$) === 'function' && \$('#Title').length;" );

            # Enter some data.
            $Selenium->find_element( 'Title', 'name' )->send_keys("$Test->{Data}->{Description}");
            $Selenium->execute_script(
                "\$('#CalendarID').val("
                    . $Calendar1{CalendarID}
                    . ").trigger('redraw.InputField').trigger('change');"
            );

            # Select custom template.
            $Selenium->execute_script(
                "\$('#NotificationTemplate').val('$Test->{Data}->{NotificationTemplate}').trigger('redraw.InputField').trigger('change');"
            );

            # Activate the relative notifications.
            $Selenium->find_element( "#NotificationCustomRelativeInput", 'css' )->click();

            # Fill out the custom unit count field.
            $Selenium->execute_script(
                "\$('#NotificationCustomRelativeUnitCount').val('$Test->{Data}->{NotificationCustomRelativeUnitCount}');"
            );

            # Fill out the custom unit field.
            $Selenium->execute_script(
                "\$('#NotificationCustomRelativeUnit').val('$Test->{Data}->{NotificationCustomRelativeUnit}').trigger('redraw.InputField').trigger('change');"
            );

            # Fill out the custom unit point of time field.
            $Selenium->execute_script(
                "\$('#NotificationCustomRelativePointOfTime').val('$Test->{Data}->{NotificationCustomRelativePointOfTime}').trigger('redraw.InputField').trigger('change');"
            );

            # Click on Save.
            $Selenium->find_element( '#EditFormSubmit', 'css' )->VerifiedClick();

            # Wait for dialog to close and AJAX to finish.
            $Selenium->WaitFor(
                JavaScript =>
                    'return typeof($) === "function" && !$(".Dialog:visible").length && !$(".CalendarWidget.Loading").length;'
            );

            my @AppointmentList = $AppointmentObject->AppointmentList(
                CalendarID => $Calendar1{CalendarID},
                Result     => 'HASH',
            );

            # Make sure there is an appointment.
            $Self->Is(
                scalar @AppointmentList,
                1,
                "Appointment list verification - $Test->{Data}->{Description} ."
            );

            # Get the needed notification params
            my $CustomUnitCount = $Test->{Data}->{NotificationCustomRelativeUnitCount};

            # The backend treats negative values as 0.
            if ( $CustomUnitCount < 0 ) {
                $CustomUnitCount = 0;
            }

            my $CustomUnit      = $Test->{Data}->{NotificationCustomRelativeUnit};
            my $CustomUnitPoint = $Test->{Data}->{NotificationCustomRelativePointOfTime};

            # Setup the count to compute for the offset.
            my %UnitOffsetCompute = (
                minutes => 60,
                hours   => 3600,
                days    => 86400,
            );

            my $NotificationLocalTime;

            # Compute from start time.
            if ( $CustomUnitPoint eq 'beforestart' || $CustomUnitPoint eq 'afterstart' ) {

                $NotificationLocalTime = $CalendarHelperObject->SystemTimeGet(
                    String => $AppointmentList[0]->{StartTime},
                );
            }

            # Compute from end time.
            elsif ( $CustomUnitPoint eq 'beforeend' || $CustomUnitPoint eq 'afterend' ) {

                $NotificationLocalTime = $CalendarHelperObject->SystemTimeGet(
                    String => $AppointmentList[0]->{EndTime},
                );
            }

            # Compute the offset to be used.
            my $Offset = ( $CustomUnitCount * $UnitOffsetCompute{$CustomUnit} );

            # Save the newly computed notification datetime string.
            my $NotificationDate = '';

            if ( $CustomUnitPoint eq 'beforestart' || $CustomUnitPoint eq 'beforeend' ) {
                $NotificationDate = $CalendarHelperObject->TimestampGet(
                    SystemTime => ( $NotificationLocalTime - $Offset ),
                );
            }
            else {
                $NotificationDate = $CalendarHelperObject->TimestampGet(
                    SystemTime => ( $NotificationLocalTime + $Offset ),
                );
            }

            $Self->Is(
                $AppointmentList[0]->{NotificationDate},
                $NotificationDate,
                "Verify notification date - $Test->{Data}->{Description} ."
            );

            my $Delete = $AppointmentObject->AppointmentDelete(
                AppointmentID => $AppointmentList[0]->{AppointmentID},
                UserID        => $UserID,
            );

            # Delete appointment.
            $Self->True(
                $Delete,
                "Delete appointment verification - $Test->{Data}->{Description} .",
            );
        }

        #
        # Custom DateTime Templates
        #

        # Define appointment test with custom notification templates.
        my @TemplateCustomDateTimeCreateTests = (

            # Custom datetime notification 2016-09-01 10:10:00.
            {
                Data => {
                    Description                           => 'Custom datetime 2016-09-01 10:10:00',
                    NotificationTemplate                  => 'Custom',
                    NotificationCustomRelativeInput       => 0,
                    NotificationCustomDateTimeInput       => 1,
                    NotificationCustomRelativeUnitCount   => 0,
                    NotificationCustomRelativeUnit        => 'minutes',
                    NotificationCustomRelativePointOfTime => 'beforestart',
                    DateTimeDay                           => '1',
                    DateTimeMonth                         => '9',
                    DateTimeYear                          => '2016',
                    DateTimeHour                          => '10',
                    DateTimeMinute                        => '10',
                    UserID                                => $UserID,
                },
                Result => {
                    NotificationDate                      => '2016-09-01 10:10:00',
                    NotificationTemplate                  => 'Custom',
                    NotificationCustom                    => 'datetime',
                    NotificationCustomRelativeUnitCount   => 0,
                    NotificationCustomRelativeUnit        => 'minutes',
                    NotificationCustomRelativePointOfTime => 'beforestart',
                    NotificationCustomDateTime            => '2016-09-01 10:10:00'
                },
            },

            # Custom datetime notification 2016-10-18 00:03:00.
            {
                Data => {
                    Description                           => 'Custom datetime 2016-10-18 01:03:00',
                    NotificationTemplate                  => 'Custom',
                    NotificationCustomRelativeInput       => 0,
                    NotificationCustomDateTimeInput       => 1,
                    NotificationCustomRelativeUnitCount   => 0,
                    NotificationCustomRelativeUnit        => 'minutes',
                    NotificationCustomRelativePointOfTime => 'beforestart',
                    DateTimeDay                           => '18',
                    DateTimeMonth                         => '10',
                    DateTimeYear                          => '2016',
                    DateTimeHour                          => '1',
                    DateTimeMinute                        => '3',
                    UserID                                => $UserID,
                },
                Result => {
                    NotificationDate                      => '2016-10-18 01:03:00',
                    NotificationTemplate                  => 'Custom',
                    NotificationCustom                    => 'datetime',
                    NotificationCustomRelativeUnitCount   => 0,
                    NotificationCustomRelativeUnit        => 'minutes',
                    NotificationCustomRelativePointOfTime => 'beforestart',
                    NotificationCustomDateTime            => '2016-10-18 01:03:00'
                },
            },

            # Custom datetime notification 2017-10-18 00:03:00.
            {
                Data => {
                    Description                           => 'Custom datetime 2017-10-18 03:03:00',
                    NotificationTemplate                  => 'Custom',
                    NotificationCustomRelativeInput       => 0,
                    NotificationCustomDateTimeInput       => 1,
                    NotificationCustomRelativeUnitCount   => 0,
                    NotificationCustomRelativeUnit        => 'minutes',
                    NotificationCustomRelativePointOfTime => 'beforestart',
                    DateTimeDay                           => '18',
                    DateTimeMonth                         => '10',
                    DateTimeYear                          => '2017',
                    DateTimeHour                          => '3',
                    DateTimeMinute                        => '3',
                    UserID                                => $UserID,
                },
                Result => {
                    NotificationDate                      => '2017-10-18 03:03:00',
                    NotificationTemplate                  => 'Custom',
                    NotificationCustom                    => 'datetime',
                    NotificationCustomRelativeUnitCount   => 0,
                    NotificationCustomRelativeUnit        => 'minutes',
                    NotificationCustomRelativePointOfTime => 'beforestart',
                    NotificationCustomDateTime            => '2017-10-18 03:03:00'
                },
            },

            # Custom datetime notification 2016-10-18 02:03:00.
            {
                Data => {
                    Description                           => 'Custom datetime 2016-10-18 02:03:00',
                    NotificationTemplate                  => 'Custom',
                    NotificationCustomRelativeInput       => 0,
                    NotificationCustomDateTimeInput       => 1,
                    NotificationCustomRelativeUnitCount   => 0,
                    NotificationCustomRelativeUnit        => 'minutes',
                    NotificationCustomRelativePointOfTime => 'beforestart',
                    DateTimeDay                           => '18',
                    DateTimeMonth                         => '10',
                    DateTimeYear                          => '2016',
                    DateTimeHour                          => '2',
                    DateTimeMinute                        => '3',
                    UserID                                => $UserID,
                },
                Result => {
                    NotificationDate                      => '2016-10-18 02:03:00',
                    NotificationTemplate                  => 'Custom',
                    NotificationCustom                    => 'datetime',
                    NotificationCustomRelativeUnitCount   => 0,
                    NotificationCustomRelativeUnit        => 'minutes',
                    NotificationCustomRelativePointOfTime => 'beforestart',
                    NotificationCustomDateTime            => '2016-10-18 02:03:00'
                },
            },
        );

        # Notification datetime template test execution.
        for my $Test (@TemplateCustomDateTimeCreateTests) {

            # Create appointment.
            $Selenium->find_element( ".fc-widget-content td[data-date=\"$DataDate\"]", 'css' )->VerifiedClick();

            # Wait until form and overlay has loaded, if neccessary.
            $Selenium->WaitFor( JavaScript => "return typeof(\$) === 'function' && \$('#Title').length;" );

            # Enter some data.
            $Selenium->find_element( 'Title', 'name' )->send_keys("$Test->{Data}->{Description}");
            $Selenium->execute_script(
                "\$('#CalendarID').val("
                    . $Calendar1{CalendarID}
                    . ").trigger('redraw.InputField').trigger('change');"
            );

            # Select custom template.
            $Selenium->execute_script(
                "\$('#NotificationTemplate').val('$Test->{Data}->{NotificationTemplate}').trigger('redraw.InputField').trigger('change');"
            );

            # Activate the relative notifications.
            $Selenium->find_element( "#NotificationCustomDateTimeInput", 'css' )->VerifiedClick();

            # Select day.
            $Selenium->execute_script(
                "\$('#NotificationCustomDateTimeDay').val('$Test->{Data}->{DateTimeDay}').trigger('redraw.InputField').trigger('change');"
            );

            # Select month.
            $Selenium->execute_script(
                "\$('#NotificationCustomDateTimeMonth').val('$Test->{Data}->{DateTimeMonth}').trigger('redraw.InputField').trigger('change');"
            );

            # Select year.
            $Selenium->execute_script(
                "\$('#NotificationCustomDateTimeYear').val('$Test->{Data}->{DateTimeYear}').trigger('redraw.InputField').trigger('change');"
            );

            # Select hour.
            $Selenium->execute_script(
                "\$('#NotificationCustomDateTimeHour').val('$Test->{Data}->{DateTimeHour}').trigger('redraw.InputField').trigger('change');"
            );

            # Select minute.
            $Selenium->execute_script(
                "\$('#NotificationCustomDateTimeMinute').val('$Test->{Data}->{DateTimeMinute}').trigger('redraw.InputField').trigger('change');"
            );

            # Click on Save.
            $Selenium->find_element( '#EditFormSubmit', 'css' )->VerifiedClick();

            # Wait for dialog to close and AJAX to finish.
            $Selenium->WaitFor(
                JavaScript =>
                    'return typeof($) === "function" && !$(".Dialog:visible").length && !$(".CalendarWidget.Loading").length;'
            );

            my @AppointmentList = $AppointmentObject->AppointmentList(
                CalendarID => $Calendar1{CalendarID},
                Result     => 'HASH',
            );

            # Make sure there is an appointment.
            $Self->Is(
                scalar @AppointmentList,
                1,
                "Appointment list verification - $Test->{Data}->{Description} ."
            );

            # Verify results.
            for my $ResultKey ( sort keys %{ $Test->{Result} } ) {

                $Self->Is(
                    $AppointmentList[0]->{$ResultKey},
                    $Test->{Result}->{$ResultKey},
                    'Notification appointment result: ' . $ResultKey . ' - ' . $Test->{Data}->{Description},
                );
            }

            # Delete appointment.
            my $Delete = $AppointmentObject->AppointmentDelete(
                AppointmentID => $AppointmentList[0]->{AppointmentID},
                UserID        => $UserID,
            );

            $Self->True(
                $Delete,
                "Delete appointment verification - $Test->{Data}->{Description} .",
            );
        }
    },
);

1;
