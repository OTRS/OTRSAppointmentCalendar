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
        my $GroupObject          = $Kernel::OM->Get('Kernel::System::Group');
        my $CalendarObject       = $Kernel::OM->Get('Kernel::System::Calendar');
        my $AppointmentObject    = $Kernel::OM->Get('Kernel::System::Calendar::Appointment');
        my $CalendarHelperObject = $Kernel::OM->Get('Kernel::System::Calendar::Helper');

        # Dashboard widget config key.
        my $DashboardConfigKey = '0500-AppointmentCalendar';

        # Turn on dashboard widget by default.
        my $DashboardConfig = $Kernel::OM->Get('Kernel::Config')->Get('DashboardBackend')->{$DashboardConfigKey};
        $DashboardConfig->{Default} = 1;
        $Helper->ConfigSettingChange(
            Valid => 1,
            Key   => "DashboardBackend###$DashboardConfigKey",
            Value => $DashboardConfig,
        );

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
            "Created test group - $GroupID",
        );

        # Create test user.
        my $TestUserLogin = $Helper->TestUserCreate(
            Groups => [$GroupName],
        ) || die 'Did not get test user';
        my $UserID = $Kernel::OM->Get('Kernel::System::User')->UserLookup( UserLogin => $TestUserLogin );
        $Self->True(
            $UserID,
            "Created test user - $UserID",
        );

        # Create a test calendar.
        my %Calendar = $CalendarObject->CalendarCreate(
            CalendarName => "Calendar $RandomID",
            Color        => '#3A87AD',
            GroupID      => $GroupID,
            UserID       => $UserID,
            ValidID      => 1,
        );
        $Self->True(
            $Calendar{CalendarID},
            "Created test calendar - $Calendar{CalendarID}",
        );

        # Get current time.
        my $StartTime      = $CalendarHelperObject->CurrentSystemTime();
        my $StartTimestamp = $CalendarHelperObject->TimestampGet(
            SystemTime => $StartTime,
        );

        # Just before midnight today.
        my $Today = substr( $StartTimestamp, 0, 10 ) . ' 23:59:59';

        my $Tomorrow = $CalendarHelperObject->TimestampGet(
            SystemTime => $StartTime + 60 * 60 * 24,    # +24 hours
        );
        my $DayAfterTomorrow = $CalendarHelperObject->TimestampGet(
            SystemTime => $StartTime + 60 * 60 * 48,    # +48 hours
        );
        my $TwoDaysAfterTomorrow = $CalendarHelperObject->TimestampGet(
            SystemTime => $StartTime + 60 * 60 * 72,    # +72 hours
        );

        # Sample appointments.
        my @Appointments = (

            # Today.
            {
                CalendarID => $Calendar{CalendarID},
                StartTime  => $Today,
                EndTime    => $Today,
                Title      => "Today $RandomID",
                UserID     => $UserID,
                Filter     => 'Today',
            },

            # Tomorrow.
            {
                CalendarID => $Calendar{CalendarID},
                StartTime  => $Tomorrow,
                EndTime    => $Tomorrow,
                Title      => "Tomorrow $RandomID",
                UserID     => $UserID,
                Filter     => 'Tomorrow',
            },

            # Day after tomorrow.
            {
                CalendarID => $Calendar{CalendarID},
                StartTime  => $DayAfterTomorrow,
                EndTime    => $DayAfterTomorrow,
                Title      => "Day after tomorrow $RandomID",
                UserID     => $UserID,
                Filter     => 'Soon',
            },

            # Two days after tomorrow.
            {
                CalendarID => $Calendar{CalendarID},
                StartTime  => $TwoDaysAfterTomorrow,
                EndTime    => $TwoDaysAfterTomorrow,
                Title      => "Two days after tomorrow $RandomID",
                UserID     => $UserID,
                Filter     => 'Soon',
            },
        );

        # Create appointments.
        for my $Appointment (@Appointments) {
            my $AppointmentID = $AppointmentObject->AppointmentCreate(
                %{$Appointment},
            );
            $Self->True(
                $AppointmentID,
                "Created test appointment - $AppointmentID",
            );
            $Appointment->{AppointmentID} = $AppointmentID;
        }

        # Login as test user.
        $Selenium->Login(
            Type     => 'Agent',
            User     => $TestUserLogin,
            Password => $TestUserLogin,
        );

        # Verify widget is present.
        $Selenium->find_element( "#Dashboard$DashboardConfigKey", 'css' );

        # Check appointments.
        my %FilterCount;
        for my $Appointment (@Appointments) {

            # Remember filter.
            $FilterCount{ $Appointment->{Filter} } += 1;

            # Switch filter.
            $Selenium->execute_script(
                "\$('.AppointmentFilter #Dashboard${DashboardConfigKey}$Appointment->{Filter}').trigger('click');"
            );

            # Wait until all AJAX calls finished.
            $Selenium->WaitFor( JavaScript => "return \$.active == 0" );

            # Verify appointment is visible.
            $Selenium->find_element("//a[contains(\@href, \'AppointmentID=$Appointment->{AppointmentID}\')]");
        }

        # Check filter count.
        for my $Filter ( sort keys %FilterCount ) {
            my $FilterLink = $Selenium->find_element( "#Dashboard${DashboardConfigKey}${Filter}", 'css' );

            $Self->Is(
                $FilterLink->get_text(),
                "$Filter ($FilterCount{$Filter})",
                "Filter count - $Filter",
            );
        }

        # Delete test appointments.
        for my $Appointment (@Appointments) {
            my $Success = $AppointmentObject->AppointmentDelete(
                AppointmentID => $Appointment->{AppointmentID},
                UserID        => $UserID,
            );
            $Self->True(
                $Success,
                "Deleted test appointment - $Appointment->{AppointmentID}",
            );
        }

        # Delete test calendar.
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

        my $CacheObject = $Kernel::OM->Get('Kernel::System::Cache');

        # Make sure cache is correct.
        for my $Cache (qw(Calendar Appointment)) {
            $CacheObject->CleanUp( Type => $Cache );
        }
    },
);

1;
