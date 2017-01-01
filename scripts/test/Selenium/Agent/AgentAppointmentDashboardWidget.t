# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
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
        my $Helper               = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
        my $GroupObject          = $Kernel::OM->Get('Kernel::System::Group');
        my $CalendarObject       = $Kernel::OM->Get('Kernel::System::Calendar');
        my $AppointmentObject    = $Kernel::OM->Get('Kernel::System::Calendar::Appointment');
        my $CalendarHelperObject = $Kernel::OM->Get('Kernel::System::Calendar::Helper');

        # dashboard widget config key
        my $DashboardConfigKey = '0500-AppointmentCalendar';

        # turn on dashboard widget by default
        my $DashboardConfig = $Kernel::OM->Get('Kernel::Config')->Get('DashboardBackend')->{$DashboardConfigKey};
        $DashboardConfig->{Default} = 1;
        $Helper->ConfigSettingChange(
            Valid => 1,
            Key   => "DashboardBackend###$DashboardConfigKey",
            Value => $DashboardConfig,
        );

        my $RandomID = $Helper->GetRandomID();

        # create test group
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

        # create test user
        my $TestUserLogin = $Helper->TestUserCreate(
            Groups => [$GroupName],
        ) || die 'Did not get test user';
        my $UserID = $Kernel::OM->Get('Kernel::System::User')->UserLookup( UserLogin => $TestUserLogin );
        $Self->True(
            $UserID,
            "Created test user - $UserID",
        );

        # create a test calendar
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

        # get current time
        my $StartTime      = $CalendarHelperObject->CurrentSystemTime();
        my $StartTimestamp = $CalendarHelperObject->TimestampGet(
            SystemTime => $StartTime,
        );

        # just before midnight today
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

        # sample appointments
        my @Appointments = (

            # today
            {
                CalendarID => $Calendar{CalendarID},
                StartTime  => $Today,
                EndTime    => $Today,
                Title      => "Today $RandomID",
                UserID     => $UserID,
                Filter     => 'Today',
            },

            # tomorrow
            {
                CalendarID => $Calendar{CalendarID},
                StartTime  => $Tomorrow,
                EndTime    => $Tomorrow,
                Title      => "Tomorrow $RandomID",
                UserID     => $UserID,
                Filter     => 'Tomorrow',
            },

            # day after tomorrow
            {
                CalendarID => $Calendar{CalendarID},
                StartTime  => $DayAfterTomorrow,
                EndTime    => $DayAfterTomorrow,
                Title      => "Day after tomorrow $RandomID",
                UserID     => $UserID,
                Filter     => 'Soon',
            },

            # two days after tomorrow
            {
                CalendarID => $Calendar{CalendarID},
                StartTime  => $TwoDaysAfterTomorrow,
                EndTime    => $TwoDaysAfterTomorrow,
                Title      => "Two days after tomorrow $RandomID",
                UserID     => $UserID,
                Filter     => 'Soon',
            },
        );

        # create appointments
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

        # change resolution (desktop mode)
        $Selenium->set_window_size( 768, 1050 );

        # login test user
        $Selenium->Login(
            Type     => 'Agent',
            User     => $TestUserLogin,
            Password => $TestUserLogin,
        );

        # verify widget is present
        my $DashboardWidget = $Selenium->find_element( "#Dashboard$DashboardConfigKey", 'css' );
        $Selenium->mouse_move_to_location(
            element => $DashboardWidget,
            xoffset => 0,
            yoffset => 0,
        );

        # check appointments
        my %FilterCount;
        for my $Appointment (@Appointments) {

            # remember filter
            $FilterCount{ $Appointment->{Filter} } += 1;

            # switch filter
            $Selenium->execute_script(
                "\$('.AppointmentFilter #Dashboard${DashboardConfigKey}$Appointment->{Filter}').trigger('click');"
            );

            sleep 2;

            # wait for AJAX
            $Selenium->WaitFor(
                JavaScript => "return typeof(\$) === 'function' && !\$('.WidgetSimple.Loading').length"
            );

            # verify appointment is visible
            $Selenium->find_element("//a[contains(\@href, \'AppointmentID=$Appointment->{AppointmentID}\')]");
        }

        # check filter count
        for my $Filter ( sort keys %FilterCount ) {

            # get filter link
            my $FilterLink = $Selenium->find_element( "#Dashboard${DashboardConfigKey}${Filter}", 'css' );

            $Self->Is(
                $FilterLink->get_text(),
                "$Filter ($FilterCount{$Filter})",
                "Filter count - $Filter",
            );
        }

        # cleanup

        # delete test appointments
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
