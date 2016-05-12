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
use Kernel::System::VariableCheck qw(:all);

# get needed objects
my $CalendarObject    = $Kernel::OM->Get('Kernel::System::Calendar');
my $AppointmentObject = $Kernel::OM->Get('Kernel::System::Calendar::Appointment');

# get helper object
$Kernel::OM->ObjectParamAdd(
    'Kernel::System::UnitTest::Helper' => {
        RestoreDatabase => 1,
    },
);
my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');

# get needed objects
my $GroupObject = $Kernel::OM->Get('Kernel::System::Group');
my $UserObject  = $Kernel::OM->Get('Kernel::System::User');

# create test user
my $UserLogin = $Helper->TestUserCreate();
my $UserID = $UserObject->UserLookup( UserLogin => $UserLogin );

$Self->True(
    $UserID,
    "Test user $UserID created",
);

# create test group
my $GroupName = 'test-calendar-group-' . $Helper->GetRandomID();
my $GroupID   = $GroupObject->GroupAdd(
    Name    => $GroupName,
    ValidID => 1,
    UserID  => 1,
);

$Self->True(
    $GroupID,
    "Test group $UserID created",
);

# add test user to test group
my $Success = $GroupObject->PermissionGroupUserAdd(
    GID        => $GroupID,
    UID        => $UserID,
    Permission => {
        ro        => 1,
        move_into => 1,
        create    => 1,
        owner     => 1,
        priority  => 1,
        rw        => 1,
    },
    UserID => 1,
);

$Self->True(
    $Success,
    "Test user $UserID added to test group $GroupID",
);

# this will be ok
my %Calendar = $CalendarObject->CalendarCreate(
    CalendarName => 'Test calendar',
    GroupID      => $GroupID,
    UserID       => $UserID,
);

$Self->True(
    $Calendar{CalendarID},
    "CalendarCreate( CalendarName => 'Test calendar', GroupID => $GroupID, UserID => $UserID ) - CalendarID",
);

# read sample .ics file
my $Content = $Kernel::OM->Get('Kernel::System::Main')->FileRead(
    Directory => $Kernel::OM->Get('Kernel::Config')->{Home} . '/scripts/test/sample/Calendar/',
    Filename  => 'SampleCalendar.ics',
);

$Self->True(
    ${$Content},
    ".ics string loaded.",
);

my $ImportSuccess = $Kernel::OM->Get('Kernel::System::Calendar::Import::ICal')->Import(
    CalendarID => $Calendar{CalendarID},
    ICal       => ${$Content},
    UserID     => $UserID,
);

$Self->True(
    $ImportSuccess,
    "Import success",
);

my @Appointments = $AppointmentObject->AppointmentList(
    CalendarID => $Calendar{CalendarID},
    Result     => 'HASH',
);

$Self->Is(
    scalar @Appointments,
    105,
    "Appointment count",
);

my @Result = (
    {
        'CalendarID' => $Calendar{CalendarID},
        'Location'   => undef,
        'Recurring'  => undef,
        'TeamID'     => undef,
        'AllDay'     => '1',
        'ParentID'   => undef,
        'Title'      => 'All day',
        'EndTime'    => '2016-04-06 00:00:00',
        'TimezoneID' => '0',
        'StartTime'  => '2016-04-05 00:00:00',

        'Description' => 'test all day event',
        'ResourceID'  => [
            0
        ],

    },
    {
        'Title'      => 'Once per week',
        'EndTime'    => '2016-04-12 12:00:00',
        'TimezoneID' => '2',

        'StartTime'   => '2016-04-12 11:30:00',
        'Description' => 'Only once per week',
        'ResourceID'  => [
            0
        ],

        'CalendarID' => $Calendar{CalendarID},
        'Location'   => 'Belgrade',
        'Recurring'  => '1',
        'TeamID'     => undef,
        'AllDay'     => undef,
        'ParentID'   => undef
    },
    {
        'Title'       => 'Once per week',
        'EndTime'     => '2016-04-19 12:00:00',
        'Description' => 'Only once per week',
        'StartTime'   => '2016-04-19 11:30:00',

        'TimezoneID' => '2',
        'ResourceID' => [
            0
        ],

        'CalendarID' => $Calendar{CalendarID},
        'Location'   => 'Belgrade',
        'AllDay'     => undef,
        'Recurring'  => undef,
        'TeamID'     => undef,
        'ParentID'   => '2837'
    },
    {
        'ParentID'   => '2837',
        'TeamID'     => undef,
        'Recurring'  => undef,
        'AllDay'     => undef,
        'Location'   => 'Belgrade',
        'CalendarID' => $Calendar{CalendarID},
        'ResourceID' => [
            0
        ],

        'StartTime'   => '2016-04-26 11:30:00',
        'Description' => 'Only once per week',
        'TimezoneID'  => '2',
        'EndTime'     => '2016-04-26 12:00:00',
        'Title'       => 'Once per week'
    },
    {
        'EndTime' => '2016-05-03 12:00:00',
        'Title'   => 'Once per week',

        'ResourceID' => [
            0
        ],
        'TimezoneID'  => '2',
        'StartTime'   => '2016-05-03 11:30:00',
        'Description' => 'Only once per week',

        'Location'   => 'Belgrade',
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => '2837',
        'AllDay'     => undef,
        'Recurring'  => undef,
        'TeamID'     => undef
    },
    {
        'CalendarID'  => $Calendar{CalendarID},
        'Location'    => 'Belgrade',
        'Recurring'   => undef,
        'AllDay'      => undef,
        'TeamID'      => undef,
        'ParentID'    => '2837',
        'Title'       => 'Once per week',
        'EndTime'     => '2016-05-10 12:00:00',
        'StartTime'   => '2016-05-10 11:30:00',
        'Description' => 'Only once per week',

        'TimezoneID' => '2',
        'ResourceID' => [
            0
        ],

    },
    {

        'ResourceID' => [
            0
        ],
        'TimezoneID'  => '2',
        'Description' => 'Only once per week',
        'StartTime'   => '2016-05-17 11:30:00',

        'EndTime'    => '2016-05-17 12:00:00',
        'Title'      => 'Once per week',
        'ParentID'   => '2837',
        'Recurring'  => undef,
        'AllDay'     => undef,
        'TeamID'     => undef,
        'Location'   => 'Belgrade',
        'CalendarID' => $Calendar{CalendarID},
    },
    {

        'ResourceID' => [
            0
        ],
        'TimezoneID'  => '2',
        'StartTime'   => '2016-05-24 11:30:00',
        'Description' => 'Only once per week',

        'EndTime'    => '2016-05-24 12:00:00',
        'Title'      => 'Once per week',
        'ParentID'   => '2837',
        'AllDay'     => undef,
        'Recurring'  => undef,
        'TeamID'     => undef,
        'Location'   => 'Belgrade',
        'CalendarID' => $Calendar{CalendarID},
    },
    {

        'ResourceID' => [
            0
        ],
        'TimezoneID'  => '2',
        'StartTime'   => '2016-05-31 11:30:00',
        'Description' => 'Only once per week',

        'EndTime'    => '2016-05-31 12:00:00',
        'Title'      => 'Once per week',
        'ParentID'   => '2837',
        'TeamID'     => undef,
        'Recurring'  => undef,
        'AllDay'     => undef,
        'Location'   => 'Belgrade',
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'Location'   => 'Belgrade',
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => '2837',
        'TeamID'     => undef,
        'Recurring'  => undef,
        'AllDay'     => undef,
        'EndTime'    => '2016-06-07 12:00:00',
        'Title'      => 'Once per week',

        'ResourceID' => [
            0
        ],
        'Description' => 'Only once per week',
        'StartTime'   => '2016-06-07 11:30:00',

        'TimezoneID' => '2'
    },
    {
        'TimezoneID' => '2',
        'StartTime'  => '2016-04-12 13:15:00',

        'Description' => 'Once per month',
        'ResourceID'  => [
            0
        ],

        'Title'      => 'Monthly meeting',
        'EndTime'    => '2016-04-12 14:00:00',
        'Recurring'  => '1',
        'TeamID'     => undef,
        'AllDay'     => undef,
        'ParentID'   => undef,
        'CalendarID' => $Calendar{CalendarID},
        'Location'   => 'Germany'
    },
    {
        'ResourceID' => [
            0
        ],

        'StartTime'   => '2016-05-12 13:15:00',
        'Description' => 'Once per month',

        'TimezoneID' => '2',
        'EndTime'    => '2016-05-12 14:00:00',
        'Title'      => 'Monthly meeting',
        'ParentID'   => '2846',
        'TeamID'     => undef,
        'Recurring'  => undef,
        'AllDay'     => undef,
        'Location'   => 'Germany',
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'AllDay'      => undef,
        'Recurring'   => undef,
        'TeamID'      => undef,
        'ParentID'    => '2846',
        'CalendarID'  => $Calendar{CalendarID},
        'Location'    => 'Germany',
        'StartTime'   => '2016-06-12 13:15:00',
        'Description' => 'Once per month',

        'TimezoneID' => '2',
        'ResourceID' => [
            0
        ],

        'Title'   => 'Monthly meeting',
        'EndTime' => '2016-06-12 14:00:00'
    },
    {
        'TeamID'      => undef,
        'Recurring'   => undef,
        'AllDay'      => undef,
        'ParentID'    => '2846',
        'CalendarID'  => $Calendar{CalendarID},
        'Location'    => 'Germany',
        'StartTime'   => '2016-07-12 13:15:00',
        'Description' => 'Once per month',

        'TimezoneID' => '2',

        'ResourceID' => [
            0
        ],
        'Title'   => 'Monthly meeting',
        'EndTime' => '2016-07-12 14:00:00'
    },
    {
        'Description' => 'Once per month',
        'StartTime'   => '2016-08-12 13:15:00',

        'TimezoneID' => '2',

        'ResourceID' => [
            0
        ],
        'Title'      => 'Monthly meeting',
        'EndTime'    => '2016-08-12 14:00:00',
        'Recurring'  => undef,
        'TeamID'     => undef,
        'AllDay'     => undef,
        'ParentID'   => '2846',
        'CalendarID' => $Calendar{CalendarID},
        'Location'   => 'Germany'
    },
    {
        'CalendarID'  => $Calendar{CalendarID},
        'Location'    => 'Germany',
        'Recurring'   => undef,
        'TeamID'      => undef,
        'AllDay'      => undef,
        'ParentID'    => '2846',
        'Title'       => 'Monthly meeting',
        'EndTime'     => '2016-09-12 14:00:00',
        'TimezoneID'  => '2',
        'Description' => 'Once per month',
        'StartTime'   => '2016-09-12 13:15:00',

        'ResourceID' => [
            0
        ],

    },
    {
        'Location'   => 'Germany',
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => '2846',
        'AllDay'     => undef,
        'Recurring'  => undef,
        'TeamID'     => undef,
        'EndTime'    => '2016-10-12 14:00:00',
        'Title'      => 'Monthly meeting',

        'ResourceID' => [
            0
        ],
        'TimezoneID'  => '2',
        'StartTime'   => '2016-10-12 13:15:00',
        'Description' => 'Once per month',

    },
    {
        'Location'   => 'Germany',
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => '2846',
        'Recurring'  => undef,
        'AllDay'     => undef,
        'TeamID'     => undef,
        'EndTime'    => '2016-11-12 14:00:00',
        'Title'      => 'Monthly meeting',

        'ResourceID' => [
            0
        ],
        'TimezoneID'  => '2',
        'Description' => 'Once per month',
        'StartTime'   => '2016-11-12 13:15:00',

    },
    {
        'EndTime'    => '2016-12-12 14:00:00',
        'Title'      => 'Monthly meeting',
        'ResourceID' => [
            0
        ],

        'TimezoneID'  => '2',
        'StartTime'   => '2016-12-12 13:15:00',
        'Description' => 'Once per month',

        'Location'   => 'Germany',
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => '2846',
        'TeamID'     => undef,
        'Recurring'  => undef,
        'AllDay'     => undef
    },
    {
        'Location'   => 'Germany',
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => '2846',
        'AllDay'     => undef,
        'Recurring'  => undef,
        'TeamID'     => undef,
        'EndTime'    => '2017-01-12 14:00:00',
        'Title'      => 'Monthly meeting',
        'ResourceID' => [
            0
        ],

        'TimezoneID'  => '2',
        'Description' => 'Once per month',
        'StartTime'   => '2017-01-12 13:15:00',

    },
    {
        'ParentID'   => '2846',
        'TeamID'     => undef,
        'Recurring'  => undef,
        'AllDay'     => undef,
        'Location'   => 'Germany',
        'CalendarID' => $Calendar{CalendarID},

        'ResourceID' => [
            0
        ],
        'TimezoneID'  => '2',
        'StartTime'   => '2017-02-12 13:15:00',
        'Description' => 'Once per month',

        'EndTime' => '2017-02-12 14:00:00',
        'Title'   => 'Monthly meeting'
    },
    {
        'ParentID'   => undef,
        'AllDay'     => undef,
        'Recurring'  => '1',
        'TeamID'     => undef,
        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},
        'ResourceID' => [
            0
        ],

        'Description' => undef,
        'StartTime'   => '2016-03-31 08:00:00',

        'TimezoneID' => '2',
        'EndTime'    => '2016-03-31 09:00:00',
        'Title'      => 'End of the month'
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'Location'   => undef,
        'AllDay'     => undef,
        'Recurring'  => undef,
        'TeamID'     => undef,
        'ParentID'   => '2857',
        'Title'      => 'End of the month',
        'EndTime'    => '2016-04-30 09:00:00',
        'TimezoneID' => '2',

        'StartTime'   => '2016-04-30 08:00:00',
        'Description' => undef,

        'ResourceID' => [
            0
            ]
    },
    {
        'TimezoneID'  => '2',
        'StartTime'   => '2016-05-31 08:00:00',
        'Description' => undef,

        'ResourceID' => [
            0
        ],
        'Title'      => 'End of the month',
        'EndTime'    => '2016-05-31 09:00:00',
        'Recurring'  => undef,
        'TeamID'     => undef,
        'AllDay'     => undef,
        'ParentID'   => '2857',
        'CalendarID' => $Calendar{CalendarID},
        'Location'   => undef
    },
    {
        'EndTime'    => '2016-06-30 09:00:00',
        'Title'      => 'End of the month',
        'ResourceID' => [
            0
        ],

        'StartTime' => '2016-06-30 08:00:00',

        'Description' => undef,
        'TimezoneID'  => '2',
        'Location'    => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'ParentID'    => '2857',
        'Recurring'   => undef,
        'TeamID'      => undef,
        'AllDay'      => undef
    },
    {
        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => '2857',
        'Recurring'  => undef,
        'AllDay'     => undef,
        'TeamID'     => undef,
        'EndTime'    => '2016-07-31 09:00:00',
        'Title'      => 'End of the month',
        'ResourceID' => [
            0
        ],

        'TimezoneID'  => '2',
        'StartTime'   => '2016-07-31 08:00:00',
        'Description' => undef,

    },
    {
        'ParentID'   => '2857',
        'Recurring'  => undef,
        'AllDay'     => undef,
        'TeamID'     => undef,
        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},
        'ResourceID' => [
            0
        ],

        'TimezoneID' => '2',

        'StartTime'   => '2016-08-31 08:00:00',
        'Description' => undef,
        'EndTime'     => '2016-08-31 09:00:00',
        'Title'       => 'End of the month'
    },
    {
        'ResourceID' => [
            0
        ],

        'StartTime'   => '2016-09-30 08:00:00',
        'Description' => undef,
        'TimezoneID'  => '2',
        'EndTime'     => '2016-09-30 09:00:00',
        'Title'       => 'End of the month',
        'ParentID'    => '2857',
        'TeamID'      => undef,
        'Recurring'   => undef,
        'AllDay'      => undef,
        'Location'    => undef,
        'CalendarID'  => $Calendar{CalendarID},
    },
    {
        'ParentID'   => '2857',
        'TeamID'     => undef,
        'Recurring'  => undef,
        'AllDay'     => undef,
        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},

        'ResourceID' => [
            0
        ],
        'TimezoneID' => '2',
        'StartTime'  => '2016-10-31 08:00:00',

        'Description' => undef,
        'EndTime'     => '2016-10-31 09:00:00',
        'Title'       => 'End of the month'
    },
    {
        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => '2857',
        'TeamID'     => undef,
        'Recurring'  => undef,
        'AllDay'     => undef,
        'EndTime'    => '2016-11-30 09:00:00',
        'Title'      => 'End of the month',

        'ResourceID' => [
            0
        ],
        'StartTime'   => '2016-11-30 08:00:00',
        'Description' => undef,

        'TimezoneID' => '2'
    },
    {
        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => '2857',
        'AllDay'     => undef,
        'Recurring'  => undef,
        'TeamID'     => undef,
        'EndTime'    => '2016-12-31 09:00:00',
        'Title'      => 'End of the month',

        'ResourceID' => [
            0
        ],

        'StartTime'   => '2016-12-31 08:00:00',
        'Description' => undef,
        'TimezoneID'  => '2'
    },
    {
        'ParentID'   => '2857',
        'Recurring'  => undef,
        'AllDay'     => undef,
        'TeamID'     => undef,
        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},
        'ResourceID' => [
            0
        ],

        'TimezoneID' => '2',

        'StartTime'   => '2017-01-31 08:00:00',
        'Description' => undef,
        'EndTime'     => '2017-01-31 09:00:00',
        'Title'       => 'End of the month'
    },
    {
        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => '2857',
        'TeamID'     => undef,
        'Recurring'  => undef,
        'AllDay'     => undef,
        'EndTime'    => '2017-02-28 09:00:00',
        'Title'      => 'End of the month',
        'ResourceID' => [
            0
        ],

        'TimezoneID'  => '2',
        'Description' => undef,
        'StartTime'   => '2017-02-28 08:00:00',

    },
    {
        'Title'      => 'Each 2 months',
        'EndTime'    => '2016-01-31 11:00:00',
        'TimezoneID' => '2',

        'StartTime'   => '2016-01-31 10:00:00',
        'Description' => 'test',

        'ResourceID' => [
            0
        ],
        'CalendarID' => $Calendar{CalendarID},
        'Location'   => 'Test',
        'TeamID'     => undef,
        'Recurring'  => '1',
        'AllDay'     => undef,
        'ParentID'   => undef
    },
    {
        'CalendarID'  => $Calendar{CalendarID},
        'Location'    => 'Test',
        'AllDay'      => undef,
        'Recurring'   => undef,
        'TeamID'      => undef,
        'ParentID'    => '2869',
        'Title'       => 'Each 2 months',
        'EndTime'     => '2016-03-31 11:00:00',
        'Description' => 'test',
        'StartTime'   => '2016-03-31 10:00:00',

        'TimezoneID' => '2',

        'ResourceID' => [
            0
            ]
    },
    {
        'TeamID'      => undef,
        'Recurring'   => undef,
        'AllDay'      => undef,
        'ParentID'    => '2869',
        'CalendarID'  => $Calendar{CalendarID},
        'Location'    => 'Test',
        'TimezoneID'  => '2',
        'Description' => 'test',
        'StartTime'   => '2016-05-31 10:00:00',

        'ResourceID' => [
            0
        ],

        'Title'   => 'Each 2 months',
        'EndTime' => '2016-05-31 11:00:00'
    },
    {
        'CalendarID'  => $Calendar{CalendarID},
        'Location'    => 'Test',
        'Recurring'   => undef,
        'AllDay'      => undef,
        'TeamID'      => undef,
        'ParentID'    => '2869',
        'Title'       => 'Each 2 months',
        'EndTime'     => '2016-07-31 11:00:00',
        'TimezoneID'  => '2',
        'StartTime'   => '2016-07-31 10:00:00',
        'Description' => 'test',

        'ResourceID' => [
            0
            ]
    },
    {
        'TimezoneID' => '2',
        'StartTime'  => '2016-09-30 10:00:00',

        'Description' => 'test',
        'ResourceID'  => [
            0
        ],

        'Title'      => 'Each 2 months',
        'EndTime'    => '2016-09-30 11:00:00',
        'Recurring'  => undef,
        'AllDay'     => undef,
        'TeamID'     => undef,
        'ParentID'   => '2869',
        'CalendarID' => $Calendar{CalendarID},
        'Location'   => 'Test'
    },
    {

        'StartTime'   => '2016-11-30 10:00:00',
        'Description' => 'test',
        'TimezoneID'  => '2',

        'ResourceID' => [
            0
        ],
        'Title'      => 'Each 2 months',
        'EndTime'    => '2016-11-30 11:00:00',
        'Recurring'  => undef,
        'AllDay'     => undef,
        'TeamID'     => undef,
        'ParentID'   => '2869',
        'CalendarID' => $Calendar{CalendarID},
        'Location'   => 'Test'
    },
    {

        'ResourceID' => [
            0
        ],
        'TimezoneID'  => '2',
        'Description' => 'test',
        'StartTime'   => '2017-01-31 10:00:00',

        'EndTime'    => '2017-01-31 11:00:00',
        'Title'      => 'Each 2 months',
        'ParentID'   => '2869',
        'AllDay'     => undef,
        'Recurring'  => undef,
        'TeamID'     => undef,
        'Location'   => 'Test',
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'Title'       => 'My event',
        'EndTime'     => '2016-04-12 10:00:00',
        'Description' => 'Test description',
        'StartTime'   => '2016-04-12 09:00:00',

        'TimezoneID' => '2',
        'ResourceID' => [
            0
        ],

        'CalendarID' => $Calendar{CalendarID},
        'Location'   => 'Stara Pazova',
        'Recurring'  => '1',
        'AllDay'     => undef,
        'TeamID'     => undef,
        'ParentID'   => undef
    },
    {
        'Recurring'  => undef,
        'TeamID'     => undef,
        'AllDay'     => undef,
        'ParentID'   => '2876',
        'CalendarID' => $Calendar{CalendarID},
        'Location'   => 'Stara Pazova',

        'StartTime'   => '2016-04-14 09:00:00',
        'Description' => 'Test description',
        'TimezoneID'  => '2',

        'ResourceID' => [
            0
        ],
        'Title'   => 'My event',
        'EndTime' => '2016-04-14 10:00:00'
    },
    {
        'StartTime' => '2016-04-16 09:00:00',

        'Description' => 'Test description',
        'TimezoneID'  => '2',
        'ResourceID'  => [
            0
        ],

        'Title'      => 'My event',
        'EndTime'    => '2016-04-16 10:00:00',
        'Recurring'  => undef,
        'AllDay'     => undef,
        'TeamID'     => undef,
        'ParentID'   => '2876',
        'CalendarID' => $Calendar{CalendarID},
        'Location'   => 'Stara Pazova'
    },
    {
        'Title'       => 'My event',
        'EndTime'     => '2016-04-18 10:00:00',
        'StartTime'   => '2016-04-18 09:00:00',
        'Description' => 'Test description',

        'TimezoneID' => '2',

        'ResourceID' => [
            0
        ],
        'CalendarID' => $Calendar{CalendarID},
        'Location'   => 'Stara Pazova',
        'Recurring'  => undef,
        'TeamID'     => undef,
        'AllDay'     => undef,
        'ParentID'   => '2876'
    },
    {
        'EndTime'    => '2016-04-20 10:00:00',
        'Title'      => 'My event',
        'ResourceID' => [
            0
        ],

        'TimezoneID' => '2',

        'StartTime'   => '2016-04-20 09:00:00',
        'Description' => 'Test description',
        'Location'    => 'Stara Pazova',
        'CalendarID'  => $Calendar{CalendarID},
        'ParentID'    => '2876',
        'Recurring'   => undef,
        'TeamID'      => undef,
        'AllDay'      => undef
    },
    {
        'ParentID'   => '2876',
        'Recurring'  => undef,
        'TeamID'     => undef,
        'AllDay'     => undef,
        'Location'   => 'Stara Pazova',
        'CalendarID' => $Calendar{CalendarID},
        'ResourceID' => [
            0
        ],

        'StartTime' => '2016-04-22 09:00:00',

        'Description' => 'Test description',
        'TimezoneID'  => '2',
        'EndTime'     => '2016-04-22 10:00:00',
        'Title'       => 'My event'
    },
    {
        'TeamID'      => undef,
        'Recurring'   => undef,
        'AllDay'      => undef,
        'ParentID'    => '2876',
        'CalendarID'  => $Calendar{CalendarID},
        'Location'    => 'Stara Pazova',
        'StartTime'   => '2016-04-24 09:00:00',
        'Description' => 'Test description',

        'TimezoneID' => '2',
        'ResourceID' => [
            0
        ],

        'Title'   => 'My event',
        'EndTime' => '2016-04-24 10:00:00'
    },
    {
        'TimezoneID'  => '2',
        'StartTime'   => '2016-04-26 09:00:00',
        'Description' => 'Test description',

        'ResourceID' => [
            0
        ],
        'Title'      => 'My event',
        'EndTime'    => '2016-04-26 10:00:00',
        'TeamID'     => undef,
        'Recurring'  => undef,
        'AllDay'     => undef,
        'ParentID'   => '2876',
        'CalendarID' => $Calendar{CalendarID},
        'Location'   => 'Stara Pazova'
    },
    {
        'TeamID'      => undef,
        'Recurring'   => undef,
        'AllDay'      => undef,
        'ParentID'    => '2876',
        'CalendarID'  => $Calendar{CalendarID},
        'Location'    => 'Stara Pazova',
        'TimezoneID'  => '2',
        'StartTime'   => '2016-04-28 09:00:00',
        'Description' => 'Test description',

        'ResourceID' => [
            0
        ],

        'Title'   => 'My event',
        'EndTime' => '2016-04-28 10:00:00'
    },
    {
        'Recurring'   => undef,
        'TeamID'      => undef,
        'AllDay'      => undef,
        'ParentID'    => '2876',
        'CalendarID'  => $Calendar{CalendarID},
        'Location'    => 'Stara Pazova',
        'TimezoneID'  => '2',
        'Description' => 'Test description',
        'StartTime'   => '2016-04-30 09:00:00',

        'ResourceID' => [
            0
        ],

        'Title'   => 'My event',
        'EndTime' => '2016-04-30 10:00:00'
    },
    {
        'CalendarID'  => $Calendar{CalendarID},
        'Location'    => 'Stara Pazova',
        'AllDay'      => undef,
        'Recurring'   => undef,
        'TeamID'      => undef,
        'ParentID'    => '2876',
        'Title'       => 'My event',
        'EndTime'     => '2016-05-02 10:00:00',
        'StartTime'   => '2016-05-02 09:00:00',
        'Description' => 'Test description',

        'TimezoneID' => '2',
        'ResourceID' => [
            0
        ],

    },
    {
        'AllDay'     => undef,
        'Recurring'  => undef,
        'TeamID'     => undef,
        'ParentID'   => '2876',
        'CalendarID' => $Calendar{CalendarID},
        'Location'   => 'Stara Pazova',

        'StartTime'   => '2016-05-04 09:00:00',
        'Description' => 'Test description',
        'TimezoneID'  => '2',
        'ResourceID'  => [
            0
        ],

        'Title'   => 'My event',
        'EndTime' => '2016-05-04 10:00:00'
    },
    {
        'EndTime'    => '2016-05-06 10:00:00',
        'Title'      => 'My event',
        'ResourceID' => [
            0
        ],

        'StartTime' => '2016-05-06 09:00:00',

        'Description' => 'Test description',
        'TimezoneID'  => '2',
        'Location'    => 'Stara Pazova',
        'CalendarID'  => $Calendar{CalendarID},
        'ParentID'    => '2876',
        'Recurring'   => undef,
        'TeamID'      => undef,
        'AllDay'      => undef
    },
    {
        'Title'       => 'My event',
        'EndTime'     => '2016-05-08 10:00:00',
        'Description' => 'Test description',
        'StartTime'   => '2016-05-08 09:00:00',

        'TimezoneID' => '2',
        'ResourceID' => [
            0
        ],

        'CalendarID' => $Calendar{CalendarID},
        'Location'   => 'Stara Pazova',
        'AllDay'     => undef,
        'Recurring'  => undef,
        'TeamID'     => undef,
        'ParentID'   => '2876'
    },
    {
        'Recurring'  => undef,
        'TeamID'     => undef,
        'AllDay'     => undef,
        'ParentID'   => '2876',
        'CalendarID' => $Calendar{CalendarID},
        'Location'   => 'Stara Pazova',
        'TimezoneID' => '2',
        'StartTime'  => '2016-05-10 09:00:00',

        'Description' => 'Test description',
        'ResourceID'  => [
            0
        ],

        'Title'   => 'My event',
        'EndTime' => '2016-05-10 10:00:00'
    },
    {
        'ResourceID' => [
            0
        ],

        'TimezoneID' => '2',

        'StartTime'   => '2016-05-12 09:00:00',
        'Description' => 'Test description',
        'EndTime'     => '2016-05-12 10:00:00',
        'Title'       => 'My event',
        'ParentID'    => '2876',
        'AllDay'      => undef,
        'Recurring'   => undef,
        'TeamID'      => undef,
        'Location'    => 'Stara Pazova',
        'CalendarID'  => $Calendar{CalendarID},
    },
    {
        'ParentID'   => '2876',
        'TeamID'     => undef,
        'Recurring'  => undef,
        'AllDay'     => undef,
        'Location'   => 'Stara Pazova',
        'CalendarID' => $Calendar{CalendarID},
        'ResourceID' => [
            0
        ],

        'StartTime' => '2016-05-14 09:00:00',

        'Description' => 'Test description',
        'TimezoneID'  => '2',
        'EndTime'     => '2016-05-14 10:00:00',
        'Title'       => 'My event'
    },
    {

        'ResourceID' => [
            0
        ],

        'StartTime'   => '2016-05-16 09:00:00',
        'Description' => 'Test description',
        'TimezoneID'  => '2',
        'EndTime'     => '2016-05-16 10:00:00',
        'Title'       => 'My event',
        'ParentID'    => '2876',
        'Recurring'   => undef,
        'TeamID'      => undef,
        'AllDay'      => undef,
        'Location'    => 'Stara Pazova',
        'CalendarID'  => $Calendar{CalendarID},
    },
    {
        'CalendarID'  => $Calendar{CalendarID},
        'Location'    => 'Stara Pazova',
        'TeamID'      => undef,
        'Recurring'   => undef,
        'AllDay'      => undef,
        'ParentID'    => '2876',
        'Title'       => 'My event',
        'EndTime'     => '2016-05-18 10:00:00',
        'StartTime'   => '2016-05-18 09:00:00',
        'Description' => 'Test description',

        'TimezoneID' => '2',
        'ResourceID' => [
            0
        ],

    },
    {
        'ParentID'   => '2876',
        'AllDay'     => undef,
        'Recurring'  => undef,
        'TeamID'     => undef,
        'Location'   => 'Stara Pazova',
        'CalendarID' => $Calendar{CalendarID},

        'ResourceID' => [
            0
        ],
        'StartTime' => '2016-05-20 09:00:00',

        'Description' => 'Test description',
        'TimezoneID'  => '2',
        'EndTime'     => '2016-05-20 10:00:00',
        'Title'       => 'My event'
    },
    {
        'TeamID'      => undef,
        'Recurring'   => undef,
        'AllDay'      => undef,
        'ParentID'    => '2876',
        'CalendarID'  => $Calendar{CalendarID},
        'Location'    => 'Stara Pazova',
        'TimezoneID'  => '2',
        'Description' => 'Test description',
        'StartTime'   => '2016-05-22 09:00:00',

        'ResourceID' => [
            0
        ],

        'Title'   => 'My event',
        'EndTime' => '2016-05-22 10:00:00'
    },
    {
        'ParentID'   => '2876',
        'Recurring'  => undef,
        'TeamID'     => undef,
        'AllDay'     => undef,
        'Location'   => 'Stara Pazova',
        'CalendarID' => $Calendar{CalendarID},

        'ResourceID' => [
            0
        ],
        'StartTime' => '2016-05-24 09:00:00',

        'Description' => 'Test description',
        'TimezoneID'  => '2',
        'EndTime'     => '2016-05-24 10:00:00',
        'Title'       => 'My event'
    },
    {
        'ParentID'   => '2876',
        'AllDay'     => undef,
        'Recurring'  => undef,
        'TeamID'     => undef,
        'Location'   => 'Stara Pazova',
        'CalendarID' => $Calendar{CalendarID},

        'ResourceID' => [
            0
        ],
        'TimezoneID' => '2',

        'StartTime'   => '2016-05-26 09:00:00',
        'Description' => 'Test description',
        'EndTime'     => '2016-05-26 10:00:00',
        'Title'       => 'My event'
    },
    {
        'Location'   => 'Stara Pazova',
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => '2876',
        'Recurring'  => undef,
        'TeamID'     => undef,
        'AllDay'     => undef,
        'EndTime'    => '2016-05-28 10:00:00',
        'Title'      => 'My event',

        'ResourceID' => [
            0
        ],

        'StartTime'   => '2016-05-28 09:00:00',
        'Description' => 'Test description',
        'TimezoneID'  => '2'
    },
    {
        'Description' => 'Test description',
        'StartTime'   => '2016-05-30 09:00:00',

        'TimezoneID' => '2',
        'ResourceID' => [
            0
        ],

        'Title'      => 'My event',
        'EndTime'    => '2016-05-30 10:00:00',
        'TeamID'     => undef,
        'Recurring'  => undef,
        'AllDay'     => undef,
        'ParentID'   => '2876',
        'CalendarID' => $Calendar{CalendarID},
        'Location'   => 'Stara Pazova'
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'Location'   => undef,
        'TeamID'     => undef,
        'Recurring'  => '1',
        'AllDay'     => undef,
        'ParentID'   => undef,
        'Title'      => 'Each 2 years',
        'EndTime'    => '2016-04-01 11:00:00',

        'StartTime'   => '2016-04-01 10:00:00',
        'Description' => undef,
        'TimezoneID'  => '2',
        'ResourceID'  => [
            0
        ],

    },
    {
        'EndTime'    => '2018-04-01 11:00:00',
        'Title'      => 'Each 2 years',
        'ResourceID' => [
            0
        ],

        'TimezoneID'  => '2',
        'Description' => undef,
        'StartTime'   => '2018-04-01 10:00:00',

        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => '2901',
        'AllDay'     => undef,
        'Recurring'  => undef,
        'TeamID'     => undef
    },
    {
        'ParentID'   => '2901',
        'Recurring'  => undef,
        'TeamID'     => undef,
        'AllDay'     => undef,
        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},
        'ResourceID' => [
            0
        ],

        'StartTime'   => '2020-04-01 10:00:00',
        'Description' => undef,

        'TimezoneID' => '2',
        'EndTime'    => '2020-04-01 11:00:00',
        'Title'      => 'Each 2 years'
    },
    {
        'ParentID'   => undef,
        'TeamID'     => undef,
        'Recurring'  => '1',
        'AllDay'     => '1',
        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},

        'ResourceID' => [
            0
        ],
        'StartTime' => '2016-04-02 00:00:00',

        'Description' => undef,
        'TimezoneID'  => '0',
        'EndTime'     => '2016-04-03 00:00:00',
        'Title'       => 'Each 3thd all day'
    },
    {
        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => '2904',
        'TeamID'     => undef,
        'Recurring'  => undef,
        'AllDay'     => '1',
        'EndTime'    => '2016-04-06 00:00:00',
        'Title'      => 'Each 3thd all day',
        'ResourceID' => [
            0
        ],

        'StartTime' => '2016-04-05 00:00:00',

        'Description' => undef,
        'TimezoneID'  => '0'
    },
    {
        'ParentID'   => '2904',
        'TeamID'     => undef,
        'Recurring'  => undef,
        'AllDay'     => '1',
        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},
        'ResourceID' => [
            0
        ],

        'Description' => undef,
        'StartTime'   => '2016-04-08 00:00:00',

        'TimezoneID' => '0',
        'EndTime'    => '2016-04-09 00:00:00',
        'Title'      => 'Each 3thd all day'
    },
    {
        'AllDay'      => '1',
        'Recurring'   => undef,
        'TeamID'      => undef,
        'ParentID'    => '2904',
        'CalendarID'  => $Calendar{CalendarID},
        'Location'    => undef,
        'Description' => undef,
        'StartTime'   => '2016-04-11 00:00:00',

        'TimezoneID' => '0',

        'ResourceID' => [
            0
        ],
        'Title'   => 'Each 3thd all day',
        'EndTime' => '2016-04-12 00:00:00'
    },
    {
        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => '2904',
        'TeamID'     => undef,
        'Recurring'  => undef,
        'AllDay'     => '1',
        'EndTime'    => '2016-04-15 00:00:00',
        'Title'      => 'Each 3thd all day',
        'ResourceID' => [
            0
        ],

        'StartTime'   => '2016-04-14 00:00:00',
        'Description' => undef,
        'TimezoneID'  => '0'
    },
    {

        'ResourceID' => [
            0
        ],
        'TimezoneID'  => '0',
        'Description' => undef,
        'StartTime'   => '2016-04-17 00:00:00',

        'EndTime'    => '2016-04-18 00:00:00',
        'Title'      => 'Each 3thd all day',
        'ParentID'   => '2904',
        'TeamID'     => undef,
        'Recurring'  => undef,
        'AllDay'     => '1',
        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'ParentID'   => '2904',
        'Recurring'  => undef,
        'AllDay'     => '1',
        'TeamID'     => undef,
        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},
        'ResourceID' => [
            0
        ],

        'TimezoneID' => '0',
        'StartTime'  => '2016-04-20 00:00:00',

        'Description' => undef,
        'EndTime'     => '2016-04-21 00:00:00',
        'Title'       => 'Each 3thd all day'
    },
    {
        'EndTime'    => '2016-04-24 00:00:00',
        'Title'      => 'Each 3thd all day',
        'ResourceID' => [
            0
        ],

        'TimezoneID'  => '0',
        'Description' => undef,
        'StartTime'   => '2016-04-23 00:00:00',

        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => '2904',
        'Recurring'  => undef,
        'AllDay'     => '1',
        'TeamID'     => undef
    },
    {
        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => '2904',
        'TeamID'     => undef,
        'Recurring'  => undef,
        'AllDay'     => '1',
        'EndTime'    => '2016-04-27 00:00:00',
        'Title'      => 'Each 3thd all day',
        'ResourceID' => [
            0
        ],

        'TimezoneID' => '0',

        'StartTime'   => '2016-04-26 00:00:00',
        'Description' => undef
    },
    {
        'EndTime' => '2016-04-30 00:00:00',
        'Title'   => 'Each 3thd all day',

        'ResourceID' => [
            0
        ],

        'StartTime'   => '2016-04-29 00:00:00',
        'Description' => undef,
        'TimezoneID'  => '0',
        'Location'    => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'ParentID'    => '2904',
        'Recurring'   => undef,
        'TeamID'      => undef,
        'AllDay'      => '1'
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'Location'   => undef,
        'AllDay'     => undef,
        'Recurring'  => '1',
        'TeamID'     => undef,
        'ParentID'   => undef,
        'Title'      => 'First 3 days',
        'EndTime'    => '2016-03-07 17:00:00',

        'StartTime'   => '2016-03-07 16:00:00',
        'Description' => undef,
        'TimezoneID'  => '2',

        'ResourceID' => [
            0
            ]
    },
    {
        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => '2914',
        'Recurring'  => undef,
        'TeamID'     => undef,
        'AllDay'     => undef,
        'EndTime'    => '2016-03-08 17:00:00',
        'Title'      => 'First 3 days',

        'ResourceID' => [
            0
        ],
        'TimezoneID' => '2',

        'StartTime'   => '2016-03-08 16:00:00',
        'Description' => undef
    },
    {
        'AllDay'      => undef,
        'Recurring'   => undef,
        'TeamID'      => undef,
        'ParentID'    => '2914',
        'CalendarID'  => $Calendar{CalendarID},
        'Location'    => undef,
        'TimezoneID'  => '2',
        'StartTime'   => '2016-03-09 16:00:00',
        'Description' => undef,

        'ResourceID' => [
            0
        ],

        'Title'   => 'First 3 days',
        'EndTime' => '2016-03-09 17:00:00'
    },
    {
        'Recurring'  => '1',
        'TeamID'     => undef,
        'AllDay'     => undef,
        'ParentID'   => undef,
        'CalendarID' => $Calendar{CalendarID},
        'Location'   => undef,
        'TimezoneID' => '2',

        'StartTime'   => '2016-03-02 18:00:00',
        'Description' => undef,

        'ResourceID' => [
            0
        ],
        'Title'   => 'Once per next 2 month',
        'EndTime' => '2016-03-02 19:00:00'
    },
    {
        'EndTime'    => '2016-04-02 19:00:00',
        'Title'      => 'Once per next 2 month',
        'ResourceID' => [
            0
        ],

        'TimezoneID'  => '2',
        'Description' => undef,
        'StartTime'   => '2016-04-02 18:00:00',

        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => '2917',
        'AllDay'     => undef,
        'Recurring'  => undef,
        'TeamID'     => undef
    },
    {
        'EndTime'    => '2016-01-03 19:00:00',
        'Title'      => 'January 3th next 3 years',
        'ResourceID' => [
            0
        ],

        'TimezoneID'  => '2',
        'Description' => undef,
        'StartTime'   => '2016-01-03 18:00:00',

        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => undef,
        'TeamID'     => undef,
        'Recurring'  => '1',
        'AllDay'     => undef
    },
    {
        'ResourceID' => [
            0
        ],

        'StartTime' => '2017-01-03 18:00:00',

        'Description' => undef,
        'TimezoneID'  => '2',
        'EndTime'     => '2017-01-03 19:00:00',
        'Title'       => 'January 3th next 3 years',
        'ParentID'    => '2919',
        'Recurring'   => undef,
        'TeamID'      => undef,
        'AllDay'      => undef,
        'Location'    => undef,
        'CalendarID'  => $Calendar{CalendarID},
    },
    {
        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => '2919',
        'AllDay'     => undef,
        'Recurring'  => undef,
        'TeamID'     => undef,
        'EndTime'    => '2018-01-03 19:00:00',
        'Title'      => 'January 3th next 3 years',
        'ResourceID' => [
            0
        ],

        'TimezoneID' => '2',
        'StartTime'  => '2018-01-03 18:00:00',

        'Description' => undef
    },
    {
        'Title'      => 'Each 2nd week',
        'EndTime'    => '2016-04-12 17:00:00',
        'TimezoneID' => '2',

        'StartTime'   => '2016-04-12 16:00:00',
        'Description' => 'Developer meeting each 2nd Tuesday',

        'ResourceID' => [
            0
        ],
        'CalendarID' => $Calendar{CalendarID},
        'Location'   => undef,
        'Recurring'  => '1',
        'TeamID'     => undef,
        'AllDay'     => undef,
        'ParentID'   => undef
    },
    {
        'Title'       => 'Each 2nd week',
        'EndTime'     => '2016-06-02 17:00:00',
        'TimezoneID'  => '2',
        'Description' => 'Developer meeting each 2nd Tuesday',
        'StartTime'   => '2016-06-02 16:00:00',

        'ResourceID' => [
            0
        ],

        'CalendarID' => $Calendar{CalendarID},
        'Location'   => undef,
        'TeamID'     => undef,
        'Recurring'  => undef,
        'AllDay'     => undef,
        'ParentID'   => '2922'
    },
    {
        'EndTime'    => '2016-08-02 17:00:00',
        'Title'      => 'Each 2nd week',
        'ResourceID' => [
            0
        ],

        'TimezoneID' => '2',

        'StartTime'   => '2016-08-02 16:00:00',
        'Description' => 'Developer meeting each 2nd Tuesday',
        'Location'    => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'ParentID'    => '2922',
        'AllDay'      => undef,
        'Recurring'   => undef,
        'TeamID'      => undef
    },
    {
        'TimezoneID'  => '2',
        'Description' => 'Developer meeting each 2nd Tuesday',
        'StartTime'   => '2016-10-02 16:00:00',

        'ResourceID' => [
            0
        ],

        'Title'      => 'Each 2nd week',
        'EndTime'    => '2016-10-02 17:00:00',
        'Recurring'  => undef,
        'TeamID'     => undef,
        'AllDay'     => undef,
        'ParentID'   => '2922',
        'CalendarID' => $Calendar{CalendarID},
        'Location'   => undef
    },
    {
        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => '2922',
        'Recurring'  => undef,
        'TeamID'     => undef,
        'AllDay'     => undef,
        'EndTime'    => '2016-12-02 17:00:00',
        'Title'      => 'Each 2nd week',

        'ResourceID' => [
            0
        ],

        'StartTime'   => '2016-12-02 16:00:00',
        'Description' => 'Developer meeting each 2nd Tuesday',
        'TimezoneID'  => '2'
    },
    {
        'Title'   => 'Custom 1',
        'EndTime' => '2016-01-11 10:00:00',

        'StartTime'   => '2016-01-11 09:00:00',
        'Description' => 'Start at Monday and repeat each 2nd Wednesday and Sunday.',
        'TimezoneID'  => '2',
        'ResourceID'  => [
            0
        ],

        'CalendarID' => $Calendar{CalendarID},
        'Location'   => undef,
        'TeamID'     => undef,
        'Recurring'  => '1',
        'AllDay'     => undef,
        'ParentID'   => undef
    },
    {
        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => '2927',
        'TeamID'     => undef,
        'Recurring'  => undef,
        'AllDay'     => undef,
        'EndTime'    => '2016-03-03 10:00:00',
        'Title'      => 'Custom 1',
        'ResourceID' => [
            0
        ],

        'TimezoneID' => '2',

        'StartTime'   => '2016-03-03 09:00:00',
        'Description' => 'Start at Monday and repeat each 2nd Wednesday and Sunday.'
    },
    {
        'CalendarID'  => $Calendar{CalendarID},
        'Location'    => undef,
        'Recurring'   => '1',
        'AllDay'      => undef,
        'TeamID'      => undef,
        'ParentID'    => undef,
        'Title'       => 'Custom 2',
        'EndTime'     => '2016-01-12 10:00:00',
        'StartTime'   => '2016-01-12 09:00:00',
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',

        'TimezoneID' => '2',
        'ResourceID' => [
            0
        ],

    },
    {
        'ParentID'   => '2929',
        'Recurring'  => undef,
        'AllDay'     => undef,
        'TeamID'     => undef,
        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},
        'ResourceID' => [
            0
        ],

        'StartTime'   => '2016-02-12 09:00:00',
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'TimezoneID'  => '2',
        'EndTime'     => '2016-02-12 10:00:00',
        'Title'       => 'Custom 2'
    },
    {
        'EndTime' => '2016-03-12 10:00:00',
        'Title'   => 'Custom 2',

        'ResourceID' => [
            0
        ],
        'TimezoneID'  => '2',
        'StartTime'   => '2016-03-12 09:00:00',
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',

        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => '2929',
        'Recurring'  => undef,
        'TeamID'     => undef,
        'AllDay'     => undef
    },
    {
        'ResourceID' => [
            0
        ],

        'StartTime'   => '2016-04-12 09:00:00',
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'TimezoneID'  => '2',
        'EndTime'     => '2016-04-12 10:00:00',
        'Title'       => 'Custom 2',
        'ParentID'    => '2929',
        'AllDay'      => undef,
        'Recurring'   => undef,
        'TeamID'      => undef,
        'Location'    => undef,
        'CalendarID'  => $Calendar{CalendarID},
    },
    {
        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => '2929',
        'Recurring'  => undef,
        'AllDay'     => undef,
        'TeamID'     => undef,
        'EndTime'    => '2016-05-12 10:00:00',
        'Title'      => 'Custom 2',

        'ResourceID' => [
            0
        ],

        'StartTime'   => '2016-05-12 09:00:00',
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'TimezoneID'  => '2'
    },
    {

        'ResourceID' => [
            0
        ],
        'TimezoneID' => '2',

        'StartTime'   => '2016-06-12 09:00:00',
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'EndTime'     => '2016-06-12 10:00:00',
        'Title'       => 'Custom 2',
        'ParentID'    => '2929',
        'AllDay'      => undef,
        'Recurring'   => undef,
        'TeamID'      => undef,
        'Location'    => undef,
        'CalendarID'  => $Calendar{CalendarID},
    },
    {
        'Title'     => 'Custom 2',
        'EndTime'   => '2016-07-12 10:00:00',
        'StartTime' => '2016-07-12 09:00:00',

        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'TimezoneID'  => '2',

        'ResourceID' => [
            0
        ],
        'CalendarID' => $Calendar{CalendarID},
        'Location'   => undef,
        'AllDay'     => undef,
        'Recurring'  => undef,
        'TeamID'     => undef,
        'ParentID'   => '2929'
    },
    {
        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => '2929',
        'AllDay'     => undef,
        'Recurring'  => undef,
        'TeamID'     => undef,
        'EndTime'    => '2016-08-12 10:00:00',
        'Title'      => 'Custom 2',

        'ResourceID' => [
            0
        ],
        'TimezoneID'  => '2',
        'StartTime'   => '2016-08-12 09:00:00',
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',

    },
    {
        'TimezoneID'  => '2',
        'StartTime'   => '2016-09-12 09:00:00',
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',

        'ResourceID' => [
            0
        ],
        'Title'      => 'Custom 2',
        'EndTime'    => '2016-09-12 10:00:00',
        'TeamID'     => undef,
        'Recurring'  => undef,
        'AllDay'     => undef,
        'ParentID'   => '2929',
        'CalendarID' => $Calendar{CalendarID},
        'Location'   => undef
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'Location'   => undef,
        'AllDay'     => undef,
        'Recurring'  => undef,
        'TeamID'     => undef,
        'ParentID'   => '2929',
        'Title'      => 'Custom 2',
        'EndTime'    => '2016-10-12 10:00:00',
        'TimezoneID' => '2',
        'StartTime'  => '2016-10-12 09:00:00',

        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'ResourceID'  => [
            0
        ],

    },
    {
        'TimezoneID'  => '2',
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'StartTime'   => '2016-11-12 09:00:00',

        'ResourceID' => [
            0
        ],

        'Title'      => 'Custom 2',
        'EndTime'    => '2016-11-12 10:00:00',
        'Recurring'  => undef,
        'AllDay'     => undef,
        'TeamID'     => undef,
        'ParentID'   => '2929',
        'CalendarID' => $Calendar{CalendarID},
        'Location'   => undef
    },
    {
        'Title'   => 'Custom 2',
        'EndTime' => '2016-12-12 10:00:00',

        'StartTime'   => '2016-12-12 09:00:00',
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'TimezoneID'  => '2',
        'ResourceID'  => [
            0
        ],

        'CalendarID' => $Calendar{CalendarID},
        'Location'   => undef,
        'Recurring'  => undef,
        'AllDay'     => undef,
        'TeamID'     => undef,
        'ParentID'   => '2929'
    }
);

LOOP:
for ( my $Index = 0; $Index < scalar @Appointments; $Index++ ) {
    KEY:
    for my $Key ( sort keys %{ $Result[$Index] } ) {

        # check if undef
        if ( !defined $Result[$Index]->{$Key} ) {

            $Self->Is(
                $Appointments[$Index]->{$Key},
                undef,
                "Check if $Key is undef.",
            );
        }
        elsif ( IsArrayRefWithData( $Result[$Index]->{$Key} ) ) {
            my %Items = ();
            $Items{$_} += 1 foreach ( @{ $Result[$Index]->{$Key} } );
            $Items{$_} -= 1 foreach ( @{ $Appointments[$Index]->{$Key} } );

            $Self->True(
                !( grep { $_ != 0 } values %Items ),
                "Check if array $Key is OK.",
            );
        }
        elsif ( IsStringWithData( $Result[$Index]->{$Key} ) ) {

            # Skip ParentID since this value can't match AppointmentID (every time is different)
            next KEY if $Key eq 'ParentID';

            $Self->Is(
                $Appointments[$Index]->{$Key},
                $Result[$Index]->{$Key},
                "Check if $Key value is OK.",
            );
        }
    }
}

1;
