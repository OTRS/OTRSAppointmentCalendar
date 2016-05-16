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
    137,
    "Appointment count",
);

my @Result = (
    {
        'TeamID' => undef,
        'Title'  => 'All day',

        'ResourceID' => [
            0
        ],

        'ParentID'    => undef,
        'Description' => 'test all day event',
        'Recurring'   => undef,
        'EndTime'     => '2016-04-06 00:00:00',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => '1',
        'StartTime'   => '2016-04-05 00:00:00',
        'Location'    => undef,
        'TimezoneID'  => '0'
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'StartTime'  => '2016-04-12 11:30:00',
        'Location'   => 'Belgrade',
        'TimezoneID' => '2',
        'Title'      => 'Once per week',
        'TeamID'     => undef,

        'ResourceID' => [
            0
        ],

        'ParentID'    => undef,
        'Recurring'   => '1',
        'Description' => 'Only once per week',
        'EndTime'     => '2016-04-12 12:00:00'
    },
    {
        'EndTime'     => '2016-04-19 12:00:00',
        'Recurring'   => undef,
        'Description' => 'Only once per week',
        'ParentID'    => '413',

        'ResourceID' => [
            0
        ],
        'Title'  => 'Once per week',
        'TeamID' => undef,

        'TimezoneID' => '2',
        'Location'   => 'Belgrade',
        'StartTime'  => '2016-04-19 11:30:00',
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'Location'   => 'Belgrade',
        'TimezoneID' => '2',
        'StartTime'  => '2016-04-26 11:30:00',

        'ParentID' => '413',
        'TeamID'   => undef,

        'Title'      => 'Once per week',
        'ResourceID' => [
            0
        ],
        'Description' => 'Only once per week',
        'Recurring'   => undef,
        'EndTime'     => '2016-04-26 12:00:00'
    },
    {

        'ParentID' => '413',
        'TeamID'   => undef,
        'Title'    => 'Once per week',

        'ResourceID' => [
            0
        ],
        'Recurring'   => undef,
        'Description' => 'Only once per week',
        'EndTime'     => '2016-05-03 12:00:00',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'Location'    => 'Belgrade',
        'TimezoneID'  => '2',
        'StartTime'   => '2016-05-03 11:30:00'
    },
    {

        'ParentID' => '413',

        'TeamID'     => undef,
        'Title'      => 'Once per week',
        'ResourceID' => [
            0
        ],
        'Description' => 'Only once per week',
        'Recurring'   => undef,
        'EndTime'     => '2016-05-10 12:00:00',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'Location'    => 'Belgrade',
        'TimezoneID'  => '2',
        'StartTime'   => '2016-05-10 11:30:00'
    },
    {

        'ParentID' => '413',
        'TeamID'   => undef,

        'Title'      => 'Once per week',
        'ResourceID' => [
            0
        ],
        'Recurring'   => undef,
        'Description' => 'Only once per week',
        'EndTime'     => '2016-05-17 12:00:00',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'Location'    => 'Belgrade',
        'TimezoneID'  => '2',
        'StartTime'   => '2016-05-17 11:30:00'
    },
    {
        'EndTime'     => '2016-05-24 12:00:00',
        'Description' => 'Only once per week',
        'Recurring'   => undef,
        'ParentID'    => '413',

        'ResourceID' => [
            0
        ],
        'TeamID' => undef,

        'Title'      => 'Once per week',
        'TimezoneID' => '2',
        'Location'   => 'Belgrade',
        'StartTime'  => '2016-05-24 11:30:00',
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'EndTime'     => '2016-05-31 12:00:00',
        'Description' => 'Only once per week',
        'Recurring'   => undef,
        'ParentID'    => '413',

        'ResourceID' => [
            0
        ],
        'TeamID' => undef,
        'Title'  => 'Once per week',

        'TimezoneID' => '2',
        'Location'   => 'Belgrade',
        'StartTime'  => '2016-05-31 11:30:00',
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'StartTime'   => '2016-06-07 11:30:00',
        'TimezoneID'  => '2',
        'Location'    => 'Belgrade',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'EndTime'     => '2016-06-07 12:00:00',
        'Description' => 'Only once per week',
        'Recurring'   => undef,
        'ResourceID'  => [
            0
        ],

        'TeamID'   => undef,
        'Title'    => 'Once per week',
        'ParentID' => '413',

    },
    {
        'StartTime'   => '2016-04-12 13:15:00',
        'TimezoneID'  => '2',
        'Location'    => 'Germany',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'EndTime'     => '2016-04-12 14:00:00',
        'Recurring'   => '1',
        'Description' => 'Once per month',
        'ResourceID'  => [
            0
        ],
        'TeamID' => undef,
        'Title'  => 'Monthly meeting',

        'ParentID' => undef,

    },
    {
        'StartTime'   => '2016-05-12 13:15:00',
        'Location'    => 'Germany',
        'TimezoneID'  => '2',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'Recurring'   => undef,
        'Description' => 'Once per month',
        'EndTime'     => '2016-05-12 14:00:00',
        'TeamID'      => undef,
        'Title'       => 'Monthly meeting',

        'ResourceID' => [
            0
        ],

        'ParentID' => '422'
    },
    {
        'StartTime'   => '2016-06-12 13:15:00',
        'TimezoneID'  => '2',
        'Location'    => 'Germany',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'EndTime'     => '2016-06-12 14:00:00',
        'Description' => 'Once per month',
        'Recurring'   => undef,
        'ResourceID'  => [
            0
        ],
        'TeamID' => undef,
        'Title'  => 'Monthly meeting',

        'ParentID' => '422',

    },
    {
        'EndTime'     => '2016-07-12 14:00:00',
        'Recurring'   => undef,
        'Description' => 'Once per month',
        'ResourceID'  => [
            0
        ],
        'TeamID' => undef,
        'Title'  => 'Monthly meeting',

        'ParentID' => '422',

        'StartTime'  => '2016-07-12 13:15:00',
        'TimezoneID' => '2',
        'Location'   => 'Germany',
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'StartTime'  => '2016-08-12 13:15:00',
        'Location'   => 'Germany',
        'TimezoneID' => '2',
        'TeamID'     => undef,
        'Title'      => 'Monthly meeting',

        'ResourceID' => [
            0
        ],

        'ParentID'    => '422',
        'Recurring'   => undef,
        'Description' => 'Once per month',
        'EndTime'     => '2016-08-12 14:00:00'
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'StartTime'  => '2016-09-12 13:15:00',
        'Location'   => 'Germany',
        'TimezoneID' => '2',
        'TeamID'     => undef,
        'Title'      => 'Monthly meeting',

        'ResourceID' => [
            0
        ],

        'ParentID'    => '422',
        'Recurring'   => undef,
        'Description' => 'Once per month',
        'EndTime'     => '2016-09-12 14:00:00'
    },
    {
        'ParentID' => '422',

        'ResourceID' => [
            0
        ],
        'TeamID' => undef,
        'Title'  => 'Monthly meeting',

        'EndTime'     => '2016-10-12 14:00:00',
        'Description' => 'Once per month',
        'Recurring'   => undef,
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'TimezoneID'  => '2',
        'Location'    => 'Germany',
        'StartTime'   => '2016-10-12 13:15:00'
    },
    {
        'ParentID' => '422',

        'ResourceID' => [
            0
        ],
        'Title'  => 'Monthly meeting',
        'TeamID' => undef,

        'EndTime'     => '2016-11-12 14:00:00',
        'Description' => 'Once per month',
        'Recurring'   => undef,
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'TimezoneID'  => '2',
        'Location'    => 'Germany',
        'StartTime'   => '2016-11-12 13:15:00'
    },
    {
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'Location'   => 'Germany',
        'TimezoneID' => '2',
        'StartTime'  => '2016-12-12 13:15:00',

        'ParentID' => '422',
        'TeamID'   => undef,

        'Title'      => 'Monthly meeting',
        'ResourceID' => [
            0
        ],
        'Recurring'   => undef,
        'Description' => 'Once per month',
        'EndTime'     => '2016-12-12 14:00:00'
    },
    {
        'Location'    => 'Germany',
        'TimezoneID'  => '2',
        'StartTime'   => '2017-01-12 13:15:00',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'Description' => 'Once per month',
        'Recurring'   => undef,
        'EndTime'     => '2017-01-12 14:00:00',

        'ParentID' => '422',
        'Title'    => 'Monthly meeting',
        'TeamID'   => undef,

        'ResourceID' => [
            0
            ]
    },
    {

        'ParentID' => '422',
        'TeamID'   => undef,
        'Title'    => 'Monthly meeting',

        'ResourceID' => [
            0
        ],
        'Description' => 'Once per month',
        'Recurring'   => undef,
        'EndTime'     => '2017-02-12 14:00:00',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'Location'    => 'Germany',
        'TimezoneID'  => '2',
        'StartTime'   => '2017-02-12 13:15:00'
    },
    {
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'TimezoneID' => '2',
        'Location'   => undef,
        'StartTime'  => '2016-03-31 08:00:00',
        'ParentID'   => undef,

        'ResourceID' => [
            0
        ],
        'TeamID' => undef,
        'Title'  => 'End of the month',

        'EndTime'     => '2016-03-31 09:00:00',
        'Recurring'   => '1',
        'Description' => undef
    },
    {
        'EndTime'     => '2016-04-30 09:00:00',
        'Description' => undef,
        'Recurring'   => undef,
        'ParentID'    => '433',

        'ResourceID' => [
            0
        ],
        'TeamID' => undef,

        'Title'      => 'End of the month',
        'TimezoneID' => '2',
        'Location'   => undef,
        'StartTime'  => '2016-04-30 08:00:00',
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'EndTime'     => '2016-05-31 09:00:00',
        'Recurring'   => undef,
        'Description' => undef,
        'ResourceID'  => [
            0
        ],
        'Title'  => 'End of the month',
        'TeamID' => undef,

        'ParentID' => '433',

        'StartTime'  => '2016-05-31 08:00:00',
        'TimezoneID' => '2',
        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef
    },
    {
        'StartTime'   => '2016-06-30 08:00:00',
        'TimezoneID'  => '2',
        'Location'    => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'EndTime'     => '2016-06-30 09:00:00',
        'Description' => undef,
        'Recurring'   => undef,
        'ResourceID'  => [
            0
        ],
        'Title'  => 'End of the month',
        'TeamID' => undef,

        'ParentID' => '433',

    },
    {

        'ParentID' => '433',
        'Title'    => 'End of the month',
        'TeamID'   => undef,

        'ResourceID' => [
            0
        ],
        'Recurring'   => undef,
        'Description' => undef,
        'EndTime'     => '2016-07-31 09:00:00',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'Location'    => undef,
        'TimezoneID'  => '2',
        'StartTime'   => '2016-07-31 08:00:00'
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'StartTime'  => '2016-08-31 08:00:00',
        'TimezoneID' => '2',
        'Location'   => undef,
        'ResourceID' => [
            0
        ],
        'Title'  => 'End of the month',
        'TeamID' => undef,

        'ParentID' => '433',

        'EndTime'     => '2016-08-31 09:00:00',
        'Description' => undef,
        'Recurring'   => undef
    },
    {
        'ParentID' => '433',

        'ResourceID' => [
            0
        ],
        'TeamID' => undef,
        'Title'  => 'End of the month',

        'EndTime'     => '2016-09-30 09:00:00',
        'Recurring'   => undef,
        'Description' => undef,
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'TimezoneID'  => '2',
        'Location'    => undef,
        'StartTime'   => '2016-09-30 08:00:00'
    },
    {
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'TimezoneID' => '2',
        'Location'   => undef,
        'StartTime'  => '2016-10-31 08:00:00',
        'ParentID'   => '433',

        'ResourceID' => [
            0
        ],
        'TeamID' => undef,

        'Title'       => 'End of the month',
        'EndTime'     => '2016-10-31 09:00:00',
        'Description' => undef,
        'Recurring'   => undef
    },
    {
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'TimezoneID' => '2',
        'Location'   => undef,
        'StartTime'  => '2016-11-30 08:00:00',
        'ParentID'   => '433',

        'ResourceID' => [
            0
        ],

        'TeamID'      => undef,
        'Title'       => 'End of the month',
        'EndTime'     => '2016-11-30 09:00:00',
        'Description' => undef,
        'Recurring'   => undef
    },
    {
        'EndTime'     => '2016-12-31 09:00:00',
        'Recurring'   => undef,
        'Description' => undef,
        'ResourceID'  => [
            0
        ],
        'TeamID' => undef,

        'Title'    => 'End of the month',
        'ParentID' => '433',

        'StartTime'  => '2016-12-31 08:00:00',
        'TimezoneID' => '2',
        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef
    },
    {
        'StartTime'   => '2017-01-31 08:00:00',
        'TimezoneID'  => '2',
        'Location'    => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'EndTime'     => '2017-01-31 09:00:00',
        'Description' => undef,
        'Recurring'   => undef,
        'ResourceID'  => [
            0
        ],
        'TeamID' => undef,

        'Title'    => 'End of the month',
        'ParentID' => '433',

    },
    {
        'ParentID' => '433',

        'ResourceID' => [
            0
        ],
        'Title'  => 'End of the month',
        'TeamID' => undef,

        'EndTime'     => '2017-02-28 09:00:00',
        'Recurring'   => undef,
        'Description' => undef,
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'TimezoneID'  => '2',
        'Location'    => undef,
        'StartTime'   => '2017-02-28 08:00:00'
    },
    {
        'StartTime'   => '2016-01-31 10:00:00',
        'TimezoneID'  => '2',
        'Location'    => 'Test',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'EndTime'     => '2016-01-31 11:00:00',
        'Description' => 'test',
        'Recurring'   => '1',
        'ResourceID'  => [
            0
        ],
        'TeamID' => undef,

        'Title'    => 'Each 2 months',
        'ParentID' => undef,

    },
    {
        'StartTime'   => '2016-03-31 10:00:00',
        'TimezoneID'  => '2',
        'Location'    => 'Test',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'EndTime'     => '2016-03-31 11:00:00',
        'Recurring'   => undef,
        'Description' => 'test',
        'ResourceID'  => [
            0
        ],
        'TeamID' => undef,
        'Title'  => 'Each 2 months',

        'ParentID' => '445',

    },
    {
        'ParentID' => '445',

        'ResourceID' => [
            0
        ],

        'TeamID'      => undef,
        'Title'       => 'Each 2 months',
        'EndTime'     => '2016-05-31 11:00:00',
        'Description' => 'test',
        'Recurring'   => undef,
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'TimezoneID'  => '2',
        'Location'    => 'Test',
        'StartTime'   => '2016-05-31 10:00:00'
    },
    {

        'TeamID'     => undef,
        'Title'      => 'Each 2 months',
        'ResourceID' => [
            0
        ],

        'ParentID'    => '445',
        'Description' => 'test',
        'Recurring'   => undef,
        'EndTime'     => '2016-07-31 11:00:00',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'StartTime'   => '2016-07-31 10:00:00',
        'Location'    => 'Test',
        'TimezoneID'  => '2'
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'StartTime'  => '2017-01-31 10:00:00',
        'Location'   => 'Test',
        'TimezoneID' => '2',

        'TeamID'     => undef,
        'Title'      => 'Each 2 months',
        'ResourceID' => [
            0
        ],

        'ParentID'    => '445',
        'Recurring'   => undef,
        'Description' => 'test',
        'EndTime'     => '2017-01-31 11:00:00'
    },
    {
        'Description' => 'Test description',
        'Recurring'   => '1',
        'EndTime'     => '2016-04-12 10:00:00',

        'TeamID'     => undef,
        'Title'      => 'My event',
        'ResourceID' => [
            0
        ],

        'ParentID'   => undef,
        'StartTime'  => '2016-04-12 09:00:00',
        'Location'   => 'Stara Pazova',
        'TimezoneID' => '2',
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef
    },
    {
        'ParentID' => '450',

        'ResourceID' => [
            0
        ],
        'Title'  => 'My event',
        'TeamID' => undef,

        'EndTime'     => '2016-04-14 10:00:00',
        'Description' => 'Test description',
        'Recurring'   => undef,
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'TimezoneID'  => '2',
        'Location'    => 'Stara Pazova',
        'StartTime'   => '2016-04-14 09:00:00'
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'StartTime'  => '2016-04-16 09:00:00',
        'Location'   => 'Stara Pazova',
        'TimezoneID' => '2',
        'Title'      => 'My event',
        'TeamID'     => undef,

        'ResourceID' => [
            0
        ],

        'ParentID'    => '450',
        'Description' => 'Test description',
        'Recurring'   => undef,
        'EndTime'     => '2016-04-16 10:00:00'
    },
    {
        'EndTime'     => '2016-04-18 10:00:00',
        'Recurring'   => undef,
        'Description' => 'Test description',
        'ParentID'    => '450',

        'ResourceID' => [
            0
        ],
        'TeamID' => undef,
        'Title'  => 'My event',

        'TimezoneID' => '2',
        'Location'   => 'Stara Pazova',
        'StartTime'  => '2016-04-18 09:00:00',
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'Recurring'   => undef,
        'Description' => 'Test description',
        'EndTime'     => '2016-04-20 10:00:00',
        'Title'       => 'My event',
        'TeamID'      => undef,

        'ResourceID' => [
            0
        ],

        'ParentID'   => '450',
        'StartTime'  => '2016-04-20 09:00:00',
        'Location'   => 'Stara Pazova',
        'TimezoneID' => '2',
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'StartTime'  => '2016-04-22 09:00:00',
        'Location'   => 'Stara Pazova',
        'TimezoneID' => '2',
        'TeamID'     => undef,
        'Title'      => 'My event',

        'ResourceID' => [
            0
        ],

        'ParentID'    => '450',
        'Description' => 'Test description',
        'Recurring'   => undef,
        'EndTime'     => '2016-04-22 10:00:00'
    },
    {
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'TimezoneID' => '2',
        'Location'   => 'Stara Pazova',
        'StartTime'  => '2016-04-24 09:00:00',
        'ParentID'   => '450',

        'ResourceID' => [
            0
        ],
        'TeamID' => undef,
        'Title'  => 'My event',

        'EndTime'     => '2016-04-24 10:00:00',
        'Recurring'   => undef,
        'Description' => 'Test description'
    },
    {
        'TimezoneID'  => '2',
        'Location'    => 'Stara Pazova',
        'StartTime'   => '2016-04-26 09:00:00',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'EndTime'     => '2016-04-26 10:00:00',
        'Description' => 'Test description',
        'Recurring'   => undef,
        'ParentID'    => '450',

        'ResourceID' => [
            0
        ],
        'Title'  => 'My event',
        'TeamID' => undef,

    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'StartTime'  => '2016-04-28 09:00:00',
        'TimezoneID' => '2',
        'Location'   => 'Stara Pazova',
        'ResourceID' => [
            0
        ],

        'TeamID'   => undef,
        'Title'    => 'My event',
        'ParentID' => '450',

        'EndTime'     => '2016-04-28 10:00:00',
        'Recurring'   => undef,
        'Description' => 'Test description'
    },
    {
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'Location'   => 'Stara Pazova',
        'TimezoneID' => '2',
        'StartTime'  => '2016-04-30 09:00:00',

        'ParentID' => '450',
        'TeamID'   => undef,

        'Title'      => 'My event',
        'ResourceID' => [
            0
        ],
        'Recurring'   => undef,
        'Description' => 'Test description',
        'EndTime'     => '2016-04-30 10:00:00'
    },
    {
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'TimezoneID' => '2',
        'Location'   => 'Stara Pazova',
        'StartTime'  => '2016-05-02 09:00:00',
        'ParentID'   => '450',

        'ResourceID' => [
            0
        ],
        'TeamID' => undef,

        'Title'       => 'My event',
        'EndTime'     => '2016-05-02 10:00:00',
        'Recurring'   => undef,
        'Description' => 'Test description'
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'StartTime'  => '2016-05-04 09:00:00',
        'TimezoneID' => '2',
        'Location'   => 'Stara Pazova',
        'ResourceID' => [
            0
        ],

        'TeamID'   => undef,
        'Title'    => 'My event',
        'ParentID' => '450',

        'EndTime'     => '2016-05-04 10:00:00',
        'Recurring'   => undef,
        'Description' => 'Test description'
    },
    {
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'TimezoneID' => '2',
        'Location'   => 'Stara Pazova',
        'StartTime'  => '2016-05-06 09:00:00',
        'ParentID'   => '450',

        'ResourceID' => [
            0
        ],
        'Title'  => 'My event',
        'TeamID' => undef,

        'EndTime'     => '2016-05-06 10:00:00',
        'Description' => 'Test description',
        'Recurring'   => undef
    },
    {
        'Recurring'   => undef,
        'Description' => 'Test description',
        'EndTime'     => '2016-05-08 10:00:00',
        'TeamID'      => undef,
        'Title'       => 'My event',

        'ResourceID' => [
            0
        ],

        'ParentID'   => '450',
        'StartTime'  => '2016-05-08 09:00:00',
        'Location'   => 'Stara Pazova',
        'TimezoneID' => '2',
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'StartTime'  => '2016-05-10 09:00:00',
        'TimezoneID' => '2',
        'Location'   => 'Stara Pazova',
        'ResourceID' => [
            0
        ],
        'Title'  => 'My event',
        'TeamID' => undef,

        'ParentID' => '450',

        'EndTime'     => '2016-05-10 10:00:00',
        'Recurring'   => undef,
        'Description' => 'Test description'
    },
    {
        'Description' => 'Test description',
        'Recurring'   => undef,
        'EndTime'     => '2016-05-12 10:00:00',

        'ParentID' => '450',
        'Title'    => 'My event',
        'TeamID'   => undef,

        'ResourceID' => [
            0
        ],
        'Location'   => 'Stara Pazova',
        'TimezoneID' => '2',
        'StartTime'  => '2016-05-12 09:00:00',
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'Description' => 'Test description',
        'Recurring'   => undef,
        'EndTime'     => '2016-05-14 10:00:00',

        'ParentID' => '450',
        'Title'    => 'My event',
        'TeamID'   => undef,

        'ResourceID' => [
            0
        ],
        'Location'   => 'Stara Pazova',
        'TimezoneID' => '2',
        'StartTime'  => '2016-05-14 09:00:00',
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'TimezoneID' => '2',
        'Location'   => 'Stara Pazova',
        'StartTime'  => '2016-05-16 09:00:00',
        'ParentID'   => '450',

        'ResourceID' => [
            0
        ],
        'TeamID' => undef,

        'Title'       => 'My event',
        'EndTime'     => '2016-05-16 10:00:00',
        'Description' => 'Test description',
        'Recurring'   => undef
    },
    {
        'ParentID' => '450',

        'ResourceID' => [
            0
        ],
        'Title'  => 'My event',
        'TeamID' => undef,

        'EndTime'     => '2016-05-18 10:00:00',
        'Description' => 'Test description',
        'Recurring'   => undef,
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'TimezoneID'  => '2',
        'Location'    => 'Stara Pazova',
        'StartTime'   => '2016-05-18 09:00:00'
    },
    {
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'TimezoneID' => '2',
        'Location'   => 'Stara Pazova',
        'StartTime'  => '2016-05-20 09:00:00',
        'ParentID'   => '450',

        'ResourceID' => [
            0
        ],
        'Title'  => 'My event',
        'TeamID' => undef,

        'EndTime'     => '2016-05-20 10:00:00',
        'Description' => 'Test description',
        'Recurring'   => undef
    },
    {
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'Location'   => 'Stara Pazova',
        'TimezoneID' => '2',
        'StartTime'  => '2016-05-22 09:00:00',

        'ParentID' => '450',
        'TeamID'   => undef,
        'Title'    => 'My event',

        'ResourceID' => [
            0
        ],
        'Recurring'   => undef,
        'Description' => 'Test description',
        'EndTime'     => '2016-05-22 10:00:00'
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'StartTime'  => '2016-05-24 09:00:00',
        'TimezoneID' => '2',
        'Location'   => 'Stara Pazova',
        'ResourceID' => [
            0
        ],
        'Title'  => 'My event',
        'TeamID' => undef,

        'ParentID' => '450',

        'EndTime'     => '2016-05-24 10:00:00',
        'Description' => 'Test description',
        'Recurring'   => undef
    },
    {
        'EndTime'     => '2016-05-26 10:00:00',
        'Recurring'   => undef,
        'Description' => 'Test description',
        'ResourceID'  => [
            0
        ],

        'TeamID'   => undef,
        'Title'    => 'My event',
        'ParentID' => '450',

        'StartTime'  => '2016-05-26 09:00:00',
        'TimezoneID' => '2',
        'Location'   => 'Stara Pazova',
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'StartTime'  => '2016-05-28 09:00:00',
        'TimezoneID' => '2',
        'Location'   => 'Stara Pazova',
        'ResourceID' => [
            0
        ],

        'TeamID'   => undef,
        'Title'    => 'My event',
        'ParentID' => '450',

        'EndTime'     => '2016-05-28 10:00:00',
        'Description' => 'Test description',
        'Recurring'   => undef
    },
    {
        'Description' => 'Test description',
        'Recurring'   => undef,
        'EndTime'     => '2016-05-30 10:00:00',

        'ParentID' => '450',

        'TeamID'     => undef,
        'Title'      => 'My event',
        'ResourceID' => [
            0
        ],
        'Location'   => 'Stara Pazova',
        'TimezoneID' => '2',
        'StartTime'  => '2016-05-30 09:00:00',
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'StartTime'   => '2016-06-01 09:00:00',
        'Location'    => 'Stara Pazova',
        'TimezoneID'  => '2',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'Description' => 'Test description',
        'Recurring'   => undef,
        'EndTime'     => '2016-06-01 10:00:00',
        'TeamID'      => undef,

        'Title'      => 'My event',
        'ResourceID' => [
            0
        ],

        'ParentID' => '450'
    },
    {
        'Recurring'   => '1',
        'Description' => undef,
        'EndTime'     => '2016-04-01 11:00:00',

        'ParentID' => undef,
        'TeamID'   => undef,
        'Title'    => 'Each 2 years',

        'ResourceID' => [
            0
        ],
        'Location'   => undef,
        'TimezoneID' => '2',
        'StartTime'  => '2016-04-01 10:00:00',
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'ResourceID' => [
            0
        ],
        'Title'  => 'Each 2 years',
        'TeamID' => undef,

        'ParentID' => '476',

        'EndTime'     => '2018-04-01 11:00:00',
        'Description' => undef,
        'Recurring'   => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'StartTime'   => '2018-04-01 10:00:00',
        'TimezoneID'  => '2',
        'Location'    => undef
    },
    {
        'ResourceID' => [
            0
        ],
        'TeamID' => undef,
        'Title'  => 'Each 2 years',

        'ParentID' => '476',

        'EndTime'     => '2020-04-01 11:00:00',
        'Recurring'   => undef,
        'Description' => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'StartTime'   => '2020-04-01 10:00:00',
        'TimezoneID'  => '2',
        'Location'    => undef
    },
    {
        'StartTime'   => '2016-04-02 00:00:00',
        'Location'    => undef,
        'TimezoneID'  => '0',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => '1',
        'Description' => undef,
        'Recurring'   => '1',
        'EndTime'     => '2016-04-03 00:00:00',
        'Title'       => 'Each 3thd all day',
        'TeamID'      => undef,

        'ResourceID' => [
            0
        ],

        'ParentID' => undef
    },
    {
        'EndTime'     => '2016-04-06 00:00:00',
        'Description' => undef,
        'Recurring'   => undef,
        'ParentID'    => '479',

        'ResourceID' => [
            0
        ],
        'TeamID' => undef,
        'Title'  => 'Each 3thd all day',

        'TimezoneID' => '0',
        'Location'   => undef,
        'StartTime'  => '2016-04-05 00:00:00',
        'AllDay'     => '1',
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'AllDay'     => '1',
        'CalendarID' => $Calendar{CalendarID},
        'Location'   => undef,
        'TimezoneID' => '0',
        'StartTime'  => '2016-04-08 00:00:00',

        'ParentID' => '479',

        'TeamID'     => undef,
        'Title'      => 'Each 3thd all day',
        'ResourceID' => [
            0
        ],
        'Recurring'   => undef,
        'Description' => undef,
        'EndTime'     => '2016-04-09 00:00:00'
    },
    {
        'EndTime'     => '2016-04-12 00:00:00',
        'Recurring'   => undef,
        'Description' => undef,
        'ResourceID'  => [
            0
        ],

        'TeamID'   => undef,
        'Title'    => 'Each 3thd all day',
        'ParentID' => '479',

        'StartTime'  => '2016-04-11 00:00:00',
        'TimezoneID' => '0',
        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => '1'
    },
    {
        'TeamID' => undef,

        'Title'      => 'Each 3thd all day',
        'ResourceID' => [
            0
        ],

        'ParentID'    => '479',
        'Recurring'   => undef,
        'Description' => undef,
        'EndTime'     => '2016-04-15 00:00:00',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => '1',
        'StartTime'   => '2016-04-14 00:00:00',
        'Location'    => undef,
        'TimezoneID'  => '0'
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => '1',
        'StartTime'  => '2016-04-17 00:00:00',
        'Location'   => undef,
        'TimezoneID' => '0',
        'TeamID'     => undef,

        'Title'      => 'Each 3thd all day',
        'ResourceID' => [
            0
        ],

        'ParentID'    => '479',
        'Recurring'   => undef,
        'Description' => undef,
        'EndTime'     => '2016-04-18 00:00:00'
    },
    {
        'AllDay'     => '1',
        'CalendarID' => $Calendar{CalendarID},
        'Location'   => undef,
        'TimezoneID' => '0',
        'StartTime'  => '2016-04-20 00:00:00',

        'ParentID' => '479',
        'Title'    => 'Each 3thd all day',
        'TeamID'   => undef,

        'ResourceID' => [
            0
        ],
        'Description' => undef,
        'Recurring'   => undef,
        'EndTime'     => '2016-04-21 00:00:00'
    },
    {
        'TimezoneID'  => '0',
        'Location'    => undef,
        'StartTime'   => '2016-04-23 00:00:00',
        'AllDay'      => '1',
        'CalendarID'  => $Calendar{CalendarID},
        'EndTime'     => '2016-04-24 00:00:00',
        'Recurring'   => undef,
        'Description' => undef,
        'ParentID'    => '479',

        'ResourceID' => [
            0
        ],
        'TeamID' => undef,

        'Title' => 'Each 3thd all day'
    },
    {
        'StartTime'   => '2016-04-26 00:00:00',
        'Location'    => undef,
        'TimezoneID'  => '0',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => '1',
        'Recurring'   => undef,
        'Description' => undef,
        'EndTime'     => '2016-04-27 00:00:00',
        'TeamID'      => undef,
        'Title'       => 'Each 3thd all day',

        'ResourceID' => [
            0
        ],

        'ParentID' => '479'
    },
    {
        'TimezoneID'  => '0',
        'Location'    => undef,
        'StartTime'   => '2016-04-29 00:00:00',
        'AllDay'      => '1',
        'CalendarID'  => $Calendar{CalendarID},
        'EndTime'     => '2016-04-30 00:00:00',
        'Description' => undef,
        'Recurring'   => undef,
        'ParentID'    => '479',

        'ResourceID' => [
            0
        ],
        'TeamID' => undef,

        'Title' => 'Each 3thd all day'
    },
    {
        'ParentID' => undef,

        'ResourceID' => [
            0
        ],
        'TeamID' => undef,

        'Title'       => 'First 3 days',
        'EndTime'     => '2016-03-07 17:00:00',
        'Description' => undef,
        'Recurring'   => '1',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'TimezoneID'  => '2',
        'Location'    => undef,
        'StartTime'   => '2016-03-07 16:00:00'
    },
    {
        'Recurring'   => undef,
        'Description' => undef,
        'EndTime'     => '2016-03-08 17:00:00',

        'ParentID' => '489',
        'Title'    => 'First 3 days',
        'TeamID'   => undef,

        'ResourceID' => [
            0
        ],
        'Location'   => undef,
        'TimezoneID' => '2',
        'StartTime'  => '2016-03-08 16:00:00',
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'StartTime'  => '2016-03-09 16:00:00',
        'Location'   => undef,
        'TimezoneID' => '2',
        'TeamID'     => undef,

        'Title'      => 'First 3 days',
        'ResourceID' => [
            0
        ],

        'ParentID'    => '489',
        'Recurring'   => undef,
        'Description' => undef,
        'EndTime'     => '2016-03-09 17:00:00'
    },
    {
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'Location'   => undef,
        'TimezoneID' => '2',
        'StartTime'  => '2016-03-02 18:00:00',

        'ParentID' => undef,

        'TeamID'     => undef,
        'Title'      => 'Once per next 2 month',
        'ResourceID' => [
            0
        ],
        'Description' => undef,
        'Recurring'   => '1',
        'EndTime'     => '2016-03-02 19:00:00'
    },
    {
        'ParentID' => '492',

        'ResourceID' => [
            0
        ],
        'TeamID' => undef,
        'Title'  => 'Once per next 2 month',

        'EndTime'     => '2016-04-02 19:00:00',
        'Description' => undef,
        'Recurring'   => undef,
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'TimezoneID'  => '2',
        'Location'    => undef,
        'StartTime'   => '2016-04-02 18:00:00'
    },
    {
        'EndTime'     => '2016-01-03 19:00:00',
        'Recurring'   => '1',
        'Description' => undef,
        'ResourceID'  => [
            0
        ],
        'TeamID' => undef,

        'Title'    => 'January 3th next 3 years',
        'ParentID' => undef,

        'StartTime'  => '2016-01-03 18:00:00',
        'TimezoneID' => '2',
        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef
    },
    {
        'Description' => undef,
        'Recurring'   => undef,
        'EndTime'     => '2017-01-03 19:00:00',

        'ParentID' => '494',
        'TeamID'   => undef,
        'Title'    => 'January 3th next 3 years',

        'ResourceID' => [
            0
        ],
        'Location'   => undef,
        'TimezoneID' => '2',
        'StartTime'  => '2017-01-03 18:00:00',
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'StartTime'   => '2018-01-03 18:00:00',
        'Location'    => undef,
        'TimezoneID'  => '2',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'Description' => undef,
        'Recurring'   => undef,
        'EndTime'     => '2018-01-03 19:00:00',

        'TeamID'     => undef,
        'Title'      => 'January 3th next 3 years',
        'ResourceID' => [
            0
        ],

        'ParentID' => '494'
    },
    {

        'ParentID' => undef,

        'TeamID'     => undef,
        'Title'      => 'Each 2nd week',
        'ResourceID' => [
            0
        ],
        'Description' => 'Developer meeting each 2nd Tuesday',
        'Recurring'   => '1',
        'EndTime'     => '2016-04-12 17:00:00',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'Location'    => undef,
        'TimezoneID'  => '2',
        'StartTime'   => '2016-04-12 16:00:00'
    },
    {

        'TeamID'     => undef,
        'Title'      => 'Each 2nd week',
        'ResourceID' => [
            0
        ],

        'ParentID'    => '497',
        'Recurring'   => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'EndTime'     => '2016-04-26 17:00:00',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'StartTime'   => '2016-04-26 16:00:00',
        'Location'    => undef,
        'TimezoneID'  => '2'
    },
    {
        'Description' => 'Developer meeting each 2nd Tuesday',
        'Recurring'   => undef,
        'EndTime'     => '2016-05-10 17:00:00',

        'TeamID'     => undef,
        'Title'      => 'Each 2nd week',
        'ResourceID' => [
            0
        ],

        'ParentID'   => '497',
        'StartTime'  => '2016-05-10 16:00:00',
        'Location'   => undef,
        'TimezoneID' => '2',
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'StartTime'  => '2016-05-24 16:00:00',
        'TimezoneID' => '2',
        'Location'   => undef,
        'ResourceID' => [
            0
        ],
        'Title'  => 'Each 2nd week',
        'TeamID' => undef,

        'ParentID' => '497',

        'EndTime'     => '2016-05-24 17:00:00',
        'Description' => 'Developer meeting each 2nd Tuesday',
        'Recurring'   => undef
    },
    {
        'Recurring'   => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'EndTime'     => '2016-06-07 17:00:00',

        'ParentID' => '497',
        'TeamID'   => undef,

        'Title'      => 'Each 2nd week',
        'ResourceID' => [
            0
        ],
        'Location'   => undef,
        'TimezoneID' => '2',
        'StartTime'  => '2016-06-07 16:00:00',
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'EndTime'     => '2016-06-21 17:00:00',
        'Recurring'   => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'ResourceID'  => [
            0
        ],
        'Title'  => 'Each 2nd week',
        'TeamID' => undef,

        'ParentID' => '497',

        'StartTime'  => '2016-06-21 16:00:00',
        'TimezoneID' => '2',
        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef
    },
    {
        'EndTime'     => '2016-07-05 17:00:00',
        'Description' => 'Developer meeting each 2nd Tuesday',
        'Recurring'   => undef,
        'ResourceID'  => [
            0
        ],
        'TeamID' => undef,
        'Title'  => 'Each 2nd week',

        'ParentID' => '497',

        'StartTime'  => '2016-07-05 16:00:00',
        'TimezoneID' => '2',
        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'StartTime'  => '2016-07-19 16:00:00',
        'Location'   => undef,
        'TimezoneID' => '2',

        'TeamID'     => undef,
        'Title'      => 'Each 2nd week',
        'ResourceID' => [
            0
        ],

        'ParentID'    => '497',
        'Recurring'   => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'EndTime'     => '2016-07-19 17:00:00'
    },
    {
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'TimezoneID' => '2',
        'Location'   => undef,
        'StartTime'  => '2016-08-02 16:00:00',
        'ParentID'   => '497',

        'ResourceID' => [
            0
        ],

        'TeamID'      => undef,
        'Title'       => 'Each 2nd week',
        'EndTime'     => '2016-08-02 17:00:00',
        'Recurring'   => undef,
        'Description' => 'Developer meeting each 2nd Tuesday'
    },
    {
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'Location'   => undef,
        'TimezoneID' => '2',
        'StartTime'  => '2016-08-16 16:00:00',

        'ParentID' => '497',

        'TeamID'     => undef,
        'Title'      => 'Each 2nd week',
        'ResourceID' => [
            0
        ],
        'Recurring'   => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'EndTime'     => '2016-08-16 17:00:00'
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'StartTime'  => '2016-08-30 16:00:00',
        'Location'   => undef,
        'TimezoneID' => '2',
        'TeamID'     => undef,

        'Title'      => 'Each 2nd week',
        'ResourceID' => [
            0
        ],

        'ParentID'    => '497',
        'Description' => 'Developer meeting each 2nd Tuesday',
        'Recurring'   => undef,
        'EndTime'     => '2016-08-30 17:00:00'
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'StartTime'  => '2016-09-13 16:00:00',
        'Location'   => undef,
        'TimezoneID' => '2',
        'TeamID'     => undef,

        'Title'      => 'Each 2nd week',
        'ResourceID' => [
            0
        ],

        'ParentID'    => '497',
        'Description' => 'Developer meeting each 2nd Tuesday',
        'Recurring'   => undef,
        'EndTime'     => '2016-09-13 17:00:00'
    },
    {
        'Description' => 'Developer meeting each 2nd Tuesday',
        'Recurring'   => undef,
        'EndTime'     => '2016-09-27 17:00:00',
        'TeamID'      => undef,
        'Title'       => 'Each 2nd week',

        'ResourceID' => [
            0
        ],

        'ParentID'   => '497',
        'StartTime'  => '2016-09-27 16:00:00',
        'Location'   => undef,
        'TimezoneID' => '2',
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef
    },
    {
        'Description' => 'Developer meeting each 2nd Tuesday',
        'Recurring'   => undef,
        'EndTime'     => '2016-10-11 17:00:00',
        'TeamID'      => undef,

        'Title'      => 'Each 2nd week',
        'ResourceID' => [
            0
        ],

        'ParentID'   => '497',
        'StartTime'  => '2016-10-11 16:00:00',
        'Location'   => undef,
        'TimezoneID' => '2',
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'StartTime'  => '2016-10-25 16:00:00',
        'Location'   => undef,
        'TimezoneID' => '2',

        'TeamID'     => undef,
        'Title'      => 'Each 2nd week',
        'ResourceID' => [
            0
        ],

        'ParentID'    => '497',
        'Recurring'   => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'EndTime'     => '2016-10-25 17:00:00'
    },
    {
        'ResourceID' => [
            0
        ],

        'TeamID'   => undef,
        'Title'    => 'Each 2nd week',
        'ParentID' => '497',

        'EndTime'     => '2016-11-08 17:00:00',
        'Recurring'   => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'StartTime'   => '2016-11-08 16:00:00',
        'TimezoneID'  => '2',
        'Location'    => undef
    },
    {
        'Recurring'   => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'EndTime'     => '2016-11-22 17:00:00',
        'TeamID'      => undef,
        'Title'       => 'Each 2nd week',

        'ResourceID' => [
            0
        ],

        'ParentID'   => '497',
        'StartTime'  => '2016-11-22 16:00:00',
        'Location'   => undef,
        'TimezoneID' => '2',
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef
    },
    {
        'EndTime'     => '2016-12-06 17:00:00',
        'Recurring'   => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'ResourceID'  => [
            0
        ],
        'TeamID' => undef,

        'Title'    => 'Each 2nd week',
        'ParentID' => '497',

        'StartTime'  => '2016-12-06 16:00:00',
        'TimezoneID' => '2',
        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'StartTime'  => '2016-12-20 16:00:00',
        'TimezoneID' => '2',
        'Location'   => undef,
        'ResourceID' => [
            0
        ],
        'TeamID' => undef,
        'Title'  => 'Each 2nd week',

        'ParentID' => '497',

        'EndTime'     => '2016-12-20 17:00:00',
        'Recurring'   => undef,
        'Description' => 'Developer meeting each 2nd Tuesday'
    },
    {
        'Location'    => undef,
        'TimezoneID'  => '2',
        'StartTime'   => '2016-01-11 09:00:00',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'Recurring'   => '1',
        'Description' => 'Start at Monday and repeat each 2nd Wednesday and Sunday.',
        'EndTime'     => '2016-01-11 10:00:00',

        'ParentID' => undef,
        'TeamID'   => undef,

        'Title'      => 'Custom 1',
        'ResourceID' => [
            0
            ]
    },
    {
        'Title'  => 'Custom 1',
        'TeamID' => undef,

        'ResourceID' => [
            0
        ],

        'ParentID'    => '516',
        'Description' => 'Start at Monday and repeat each 2nd Wednesday and Sunday.',
        'Recurring'   => undef,
        'EndTime'     => '2016-01-13 10:00:00',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'StartTime'   => '2016-01-13 09:00:00',
        'Location'    => undef,
        'TimezoneID'  => '2'
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'StartTime'  => '2016-01-17 09:00:00',
        'Location'   => undef,
        'TimezoneID' => '2',
        'TeamID'     => undef,
        'Title'      => 'Custom 1',

        'ResourceID' => [
            0
        ],

        'ParentID'    => '516',
        'Description' => 'Start at Monday and repeat each 2nd Wednesday and Sunday.',
        'Recurring'   => undef,
        'EndTime'     => '2016-01-17 10:00:00'
    },
    {
        'EndTime'     => '2016-01-27 10:00:00',
        'Recurring'   => undef,
        'Description' => 'Start at Monday and repeat each 2nd Wednesday and Sunday.',
        'ResourceID'  => [
            0
        ],
        'TeamID' => undef,
        'Title'  => 'Custom 1',

        'ParentID' => '516',

        'StartTime'  => '2016-01-27 09:00:00',
        'TimezoneID' => '2',
        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'StartTime'  => '2016-01-31 09:00:00',
        'TimezoneID' => '2',
        'Location'   => undef,
        'ResourceID' => [
            0
        ],
        'TeamID' => undef,
        'Title'  => 'Custom 1',

        'ParentID' => '516',

        'EndTime'     => '2016-01-31 10:00:00',
        'Recurring'   => undef,
        'Description' => 'Start at Monday and repeat each 2nd Wednesday and Sunday.'
    },
    {
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'Location'   => undef,
        'TimezoneID' => '2',
        'StartTime'  => '2016-02-10 09:00:00',

        'ParentID' => '516',
        'TeamID'   => undef,

        'Title'      => 'Custom 1',
        'ResourceID' => [
            0
        ],
        'Description' => 'Start at Monday and repeat each 2nd Wednesday and Sunday.',
        'Recurring'   => undef,
        'EndTime'     => '2016-02-10 10:00:00'
    },
    {
        'StartTime'   => '2016-02-14 09:00:00',
        'TimezoneID'  => '2',
        'Location'    => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'EndTime'     => '2016-02-14 10:00:00',
        'Recurring'   => undef,
        'Description' => 'Start at Monday and repeat each 2nd Wednesday and Sunday.',
        'ResourceID'  => [
            0
        ],

        'TeamID'   => undef,
        'Title'    => 'Custom 1',
        'ParentID' => '516',

    },
    {

        'ParentID' => '516',

        'TeamID'     => undef,
        'Title'      => 'Custom 1',
        'ResourceID' => [
            0
        ],
        'Description' => 'Start at Monday and repeat each 2nd Wednesday and Sunday.',
        'Recurring'   => undef,
        'EndTime'     => '2016-02-24 10:00:00',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'Location'    => undef,
        'TimezoneID'  => '2',
        'StartTime'   => '2016-02-24 09:00:00'
    },
    {
        'Location'    => undef,
        'TimezoneID'  => '2',
        'StartTime'   => '2016-02-28 09:00:00',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'Recurring'   => undef,
        'Description' => 'Start at Monday and repeat each 2nd Wednesday and Sunday.',
        'EndTime'     => '2016-02-28 10:00:00',

        'ParentID' => '516',

        'TeamID'     => undef,
        'Title'      => 'Custom 1',
        'ResourceID' => [
            0
            ]
    },
    {
        'EndTime'     => '2016-03-09 10:00:00',
        'Description' => 'Start at Monday and repeat each 2nd Wednesday and Sunday.',
        'Recurring'   => undef,
        'ResourceID'  => [
            0
        ],

        'TeamID'   => undef,
        'Title'    => 'Custom 1',
        'ParentID' => '516',

        'StartTime'  => '2016-03-09 09:00:00',
        'TimezoneID' => '2',
        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef
    },
    {

        'ParentID' => '516',
        'TeamID'   => undef,
        'Title'    => 'Custom 1',

        'ResourceID' => [
            0
        ],
        'Description' => 'Start at Monday and repeat each 2nd Wednesday and Sunday.',
        'Recurring'   => undef,
        'EndTime'     => '2016-03-13 10:00:00',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'Location'    => undef,
        'TimezoneID'  => '2',
        'StartTime'   => '2016-03-13 09:00:00'
    },
    {

        'ParentID' => '516',
        'TeamID'   => undef,

        'Title'      => 'Custom 1',
        'ResourceID' => [
            0
        ],
        'Description' => 'Start at Monday and repeat each 2nd Wednesday and Sunday.',
        'Recurring'   => undef,
        'EndTime'     => '2016-03-23 10:00:00',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'Location'    => undef,
        'TimezoneID'  => '2',
        'StartTime'   => '2016-03-23 09:00:00'
    },
    {
        'Description' => 'Start at Monday and repeat each 2nd Wednesday and Sunday.',
        'Recurring'   => undef,
        'EndTime'     => '2016-03-27 10:00:00',
        'TeamID'      => undef,

        'Title'      => 'Custom 1',
        'ResourceID' => [
            0
        ],

        'ParentID'   => '516',
        'StartTime'  => '2016-03-27 09:00:00',
        'Location'   => undef,
        'TimezoneID' => '2',
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef
    },
    {

        'ParentID' => undef,
        'TeamID'   => undef,

        'Title'      => 'Custom 2',
        'ResourceID' => [
            0
        ],
        'Recurring'   => '1',
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'EndTime'     => '2016-01-12 10:00:00',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'Location'    => undef,
        'TimezoneID'  => '2',
        'StartTime'   => '2016-01-12 09:00:00'
    },
    {
        'Location'    => undef,
        'TimezoneID'  => '2',
        'StartTime'   => '2016-01-16 09:00:00',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'Recurring'   => undef,
        'EndTime'     => '2016-01-16 10:00:00',

        'ParentID' => '529',

        'TeamID'     => undef,
        'Title'      => 'Custom 2',
        'ResourceID' => [
            0
            ]
    },
    {

        'ParentID' => '529',
        'TeamID'   => undef,

        'Title'      => 'Custom 2',
        'ResourceID' => [
            0
        ],
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'Recurring'   => undef,
        'EndTime'     => '2016-01-31 10:00:00',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'Location'    => undef,
        'TimezoneID'  => '2',
        'StartTime'   => '2016-01-31 09:00:00'
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'StartTime'  => '2016-02-16 09:00:00',
        'Location'   => undef,
        'TimezoneID' => '2',
        'TeamID'     => undef,

        'Title'      => 'Custom 2',
        'ResourceID' => [
            0
        ],

        'ParentID'    => '529',
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'Recurring'   => undef,
        'EndTime'     => '2016-02-16 10:00:00'
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'StartTime'  => '2016-03-16 09:00:00',
        'Location'   => undef,
        'TimezoneID' => '2',
        'Title'      => 'Custom 2',
        'TeamID'     => undef,

        'ResourceID' => [
            0
        ],

        'ParentID'    => '529',
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'Recurring'   => undef,
        'EndTime'     => '2016-03-16 10:00:00'
    },
    {

        'TeamID'     => undef,
        'Title'      => 'Custom 2',
        'ResourceID' => [
            0
        ],

        'ParentID'    => '529',
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'Recurring'   => undef,
        'EndTime'     => '2016-03-31 10:00:00',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'StartTime'   => '2016-03-31 09:00:00',
        'Location'    => undef,
        'TimezoneID'  => '2'
    },
    {
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'TimezoneID' => '2',
        'Location'   => undef,
        'StartTime'  => '2016-04-16 09:00:00',
        'ParentID'   => '529',

        'ResourceID' => [
            0
        ],
        'Title'  => 'Custom 2',
        'TeamID' => undef,

        'EndTime'     => '2016-04-16 10:00:00',
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'Recurring'   => undef
    },
    {
        'StartTime'   => '2016-05-16 09:00:00',
        'TimezoneID'  => '2',
        'Location'    => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'EndTime'     => '2016-05-16 10:00:00',
        'Recurring'   => undef,
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'ResourceID'  => [
            0
        ],

        'TeamID'   => undef,
        'Title'    => 'Custom 2',
        'ParentID' => '529',

    },
    {

        'ParentID' => '529',
        'Title'    => 'Custom 2',
        'TeamID'   => undef,

        'ResourceID' => [
            0
        ],
        'Recurring'   => undef,
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'EndTime'     => '2016-05-31 10:00:00',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'Location'    => undef,
        'TimezoneID'  => '2',
        'StartTime'   => '2016-05-31 09:00:00'
    },
    {
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'Location'   => undef,
        'TimezoneID' => '2',
        'StartTime'  => '2016-06-16 09:00:00',

        'ParentID' => '529',
        'TeamID'   => undef,
        'Title'    => 'Custom 2',

        'ResourceID' => [
            0
        ],
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'Recurring'   => undef,
        'EndTime'     => '2016-06-16 10:00:00'
    },
    {
        'Recurring'   => undef,
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'EndTime'     => '2016-07-16 10:00:00',

        'ParentID' => '529',
        'TeamID'   => undef,
        'Title'    => 'Custom 2',

        'ResourceID' => [
            0
        ],
        'Location'   => undef,
        'TimezoneID' => '2',
        'StartTime'  => '2016-07-16 09:00:00',
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'EndTime'     => '2016-07-31 10:00:00',
        'Recurring'   => undef,
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'ResourceID'  => [
            0
        ],
        'Title'  => 'Custom 2',
        'TeamID' => undef,

        'ParentID' => '529',

        'StartTime'  => '2016-07-31 09:00:00',
        'TimezoneID' => '2',
        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef
    },
    {
        'EndTime'     => '2016-08-16 10:00:00',
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'Recurring'   => undef,
        'ResourceID'  => [
            0
        ],
        'TeamID' => undef,

        'Title'    => 'Custom 2',
        'ParentID' => '529',

        'StartTime'  => '2016-08-16 09:00:00',
        'TimezoneID' => '2',
        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef
    },
    {
        'StartTime'   => '2016-08-31 09:00:00',
        'Location'    => undef,
        'TimezoneID'  => '2',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'Recurring'   => undef,
        'EndTime'     => '2016-08-31 10:00:00',
        'Title'       => 'Custom 2',
        'TeamID'      => undef,

        'ResourceID' => [
            0
        ],

        'ParentID' => '529'
    },
    {
        'ResourceID' => [
            0
        ],
        'TeamID' => undef,
        'Title'  => 'Custom 2',

        'ParentID' => '529',

        'EndTime'     => '2016-09-16 10:00:00',
        'Recurring'   => undef,
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'StartTime'   => '2016-09-16 09:00:00',
        'TimezoneID'  => '2',
        'Location'    => undef
    },
    {
        'Recurring'   => undef,
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'EndTime'     => '2016-10-16 10:00:00',

        'ParentID' => '529',

        'TeamID'     => undef,
        'Title'      => 'Custom 2',
        'ResourceID' => [
            0
        ],
        'Location'   => undef,
        'TimezoneID' => '2',
        'StartTime'  => '2016-10-16 09:00:00',
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'ResourceID' => [
            0
        ],
        'Title'  => 'Custom 2',
        'TeamID' => undef,

        'ParentID' => '529',

        'EndTime'     => '2016-10-31 10:00:00',
        'Recurring'   => undef,
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'StartTime'   => '2016-10-31 09:00:00',
        'TimezoneID'  => '2',
        'Location'    => undef
    },
    {
        'ResourceID' => [
            0
        ],

        'TeamID'   => undef,
        'Title'    => 'Custom 2',
        'ParentID' => '529',

        'EndTime'     => '2016-11-16 10:00:00',
        'Recurring'   => undef,
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'StartTime'   => '2016-11-16 09:00:00',
        'TimezoneID'  => '2',
        'Location'    => undef
    },
    {
        'Location'    => undef,
        'TimezoneID'  => '2',
        'StartTime'   => '2016-12-16 09:00:00',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'Recurring'   => undef,
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'EndTime'     => '2016-12-16 10:00:00',

        'ParentID' => '529',
        'Title'    => 'Custom 2',
        'TeamID'   => undef,

        'ResourceID' => [
            0
            ]
    },
    {
        'ResourceID' => [
            0
        ],
        'TeamID' => undef,
        'Title'  => 'Custom 2',

        'ParentID' => '529',

        'EndTime'     => '2016-12-31 10:00:00',
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'Recurring'   => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'StartTime'   => '2016-12-31 09:00:00',
        'TimezoneID'  => '2',
        'Location'    => undef
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
