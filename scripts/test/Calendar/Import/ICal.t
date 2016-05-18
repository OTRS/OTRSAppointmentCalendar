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
    UntilLimit => '2017-01-01 00:00:00',
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

        'TeamID'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => undef,

        'Recurring'  => undef,
        'ResourceID' => [
            0
        ],
        'AllDay'      => '1',
        'Location'    => undef,
        'EndTime'     => '2016-04-06 00:00:00',
        'TimezoneID'  => '0',
        'StartTime'   => '2016-04-05 00:00:00',
        'Description' => 'test all day event',
        'Title'       => 'All day'
    },
    {
        'AllDay'     => undef,
        'EndTime'    => '2016-04-12 12:00:00',
        'Location'   => 'Belgrade',
        'ResourceID' => [
            0
        ],
        'Recurring'   => '1',
        'Title'       => 'Once per week',
        'Description' => 'Only once per week',
        'StartTime'   => '2016-04-12 11:30:00',
        'TimezoneID'  => '2',
        'TeamID'      => undef,

        'ParentID'   => undef,
        'CalendarID' => $Calendar{CalendarID},
    },
    {

        'TeamID'     => undef,
        'CalendarID' => $Calendar{CalendarID},

        'ParentID'   => '107',
        'Recurring'  => undef,
        'ResourceID' => [
            0
        ],
        'AllDay'      => undef,
        'EndTime'     => '2016-04-19 12:00:00',
        'Location'    => 'Belgrade',
        'StartTime'   => '2016-04-19 11:30:00',
        'TimezoneID'  => '2',
        'Description' => 'Only once per week',
        'Title'       => 'Once per week'
    },
    {
        'StartTime'   => '2016-04-26 11:30:00',
        'TimezoneID'  => '2',
        'Description' => 'Only once per week',
        'Title'       => 'Once per week',
        'Recurring'   => undef,
        'ResourceID'  => [
            0
        ],
        'AllDay'     => undef,
        'EndTime'    => '2016-04-26 12:00:00',
        'Location'   => 'Belgrade',
        'CalendarID' => $Calendar{CalendarID},

        'ParentID' => '107',

        'TeamID' => undef
    },
    {
        'AllDay'     => undef,
        'Location'   => 'Belgrade',
        'EndTime'    => '2016-05-03 12:00:00',
        'Recurring'  => undef,
        'ResourceID' => [
            0
        ],
        'Description' => 'Only once per week',
        'Title'       => 'Once per week',
        'StartTime'   => '2016-05-03 11:30:00',
        'TimezoneID'  => '2',
        'TeamID'      => undef,

        'ParentID'   => '107',
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'AllDay'     => undef,
        'EndTime'    => '2016-05-10 12:00:00',
        'Location'   => 'Belgrade',
        'ResourceID' => [
            0
        ],
        'Recurring'   => undef,
        'Description' => 'Only once per week',
        'Title'       => 'Once per week',
        'TimezoneID'  => '2',
        'StartTime'   => '2016-05-10 11:30:00',
        'TeamID'      => undef,

        'ParentID' => '107',

        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'TeamID' => undef,

        'ParentID' => '107',

        'CalendarID' => $Calendar{CalendarID},
        'EndTime'    => '2016-05-17 12:00:00',
        'AllDay'     => undef,
        'Location'   => 'Belgrade',
        'ResourceID' => [
            0
        ],
        'Recurring'   => undef,
        'Description' => 'Only once per week',
        'Title'       => 'Once per week',
        'TimezoneID'  => '2',
        'StartTime'   => '2016-05-17 11:30:00'
    },
    {
        'ParentID' => '107',

        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => undef,

        'Title'       => 'Once per week',
        'Description' => 'Only once per week',
        'TimezoneID'  => '2',
        'StartTime'   => '2016-05-24 11:30:00',
        'AllDay'      => undef,
        'EndTime'     => '2016-05-24 12:00:00',
        'Location'    => 'Belgrade',
        'Recurring'   => undef,
        'ResourceID'  => [
            0
            ]
    },
    {
        'Title'       => 'Once per week',
        'Description' => 'Only once per week',
        'StartTime'   => '2016-05-31 11:30:00',
        'TimezoneID'  => '2',
        'Location'    => 'Belgrade',
        'AllDay'      => undef,
        'EndTime'     => '2016-05-31 12:00:00',
        'Recurring'   => undef,
        'ResourceID'  => [
            0
        ],

        'ParentID'   => '107',
        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => undef,

    },
    {
        'Description' => 'Only once per week',
        'Title'       => 'Once per week',
        'StartTime'   => '2016-06-07 11:30:00',
        'TimezoneID'  => '2',
        'Location'    => 'Belgrade',
        'AllDay'      => undef,
        'EndTime'     => '2016-06-07 12:00:00',
        'ResourceID'  => [
            0
        ],
        'Recurring' => undef,

        'ParentID'   => '107',
        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => undef,

    },
    {
        'Description' => 'Once per month',
        'Title'       => 'Monthly meeting',
        'TimezoneID'  => '2',
        'StartTime'   => '2016-04-12 13:15:00',
        'EndTime'     => '2016-04-12 14:00:00',
        'AllDay'      => undef,
        'Location'    => 'Germany',
        'ResourceID'  => [
            0
        ],
        'Recurring' => '1',
        'ParentID'  => undef,

        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => undef,

    },
    {
        'Recurring'  => undef,
        'ResourceID' => [
            0
        ],
        'AllDay'      => undef,
        'Location'    => 'Germany',
        'EndTime'     => '2016-05-12 14:00:00',
        'TimezoneID'  => '2',
        'StartTime'   => '2016-05-12 13:15:00',
        'Description' => 'Once per month',
        'Title'       => 'Monthly meeting',

        'TeamID'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => '116',

    },
    {
        'Recurring'  => undef,
        'ResourceID' => [
            0
        ],
        'AllDay'      => undef,
        'Location'    => 'Germany',
        'EndTime'     => '2016-06-12 14:00:00',
        'StartTime'   => '2016-06-12 13:15:00',
        'TimezoneID'  => '2',
        'Description' => 'Once per month',
        'Title'       => 'Monthly meeting',

        'TeamID'     => undef,
        'CalendarID' => $Calendar{CalendarID},

        'ParentID' => '116'
    },
    {
        'ParentID' => '116',

        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => undef,

        'Title'       => 'Monthly meeting',
        'Description' => 'Once per month',
        'TimezoneID'  => '2',
        'StartTime'   => '2016-07-12 13:15:00',
        'AllDay'      => undef,
        'Location'    => 'Germany',
        'EndTime'     => '2016-07-12 14:00:00',
        'Recurring'   => undef,
        'ResourceID'  => [
            0
            ]
    },
    {
        'TeamID' => undef,

        'ParentID' => '116',

        'CalendarID' => $Calendar{CalendarID},
        'Location'   => 'Germany',
        'AllDay'     => undef,
        'EndTime'    => '2016-08-12 14:00:00',
        'Recurring'  => undef,
        'ResourceID' => [
            0
        ],
        'Description' => 'Once per month',
        'Title'       => 'Monthly meeting',
        'TimezoneID'  => '2',
        'StartTime'   => '2016-08-12 13:15:00'
    },
    {
        'TimezoneID'  => '2',
        'StartTime'   => '2016-09-12 13:15:00',
        'Description' => 'Once per month',
        'Title'       => 'Monthly meeting',
        'ResourceID'  => [
            0
        ],
        'Recurring'  => undef,
        'AllDay'     => undef,
        'EndTime'    => '2016-09-12 14:00:00',
        'Location'   => 'Germany',
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => '116',

        'TeamID' => undef
    },
    {
        'StartTime'   => '2016-10-12 13:15:00',
        'TimezoneID'  => '2',
        'Description' => 'Once per month',
        'Title'       => 'Monthly meeting',
        'Recurring'   => undef,
        'ResourceID'  => [
            0
        ],
        'AllDay'     => undef,
        'Location'   => 'Germany',
        'EndTime'    => '2016-10-12 14:00:00',
        'CalendarID' => $Calendar{CalendarID},

        'ParentID' => '116',

        'TeamID' => undef
    },
    {
        'ParentID' => '116',

        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => undef,

        'Title'       => 'Monthly meeting',
        'Description' => 'Once per month',
        'TimezoneID'  => '2',
        'StartTime'   => '2016-11-12 13:15:00',
        'AllDay'      => undef,
        'EndTime'     => '2016-11-12 14:00:00',
        'Location'    => 'Germany',
        'ResourceID'  => [
            0
        ],
        'Recurring' => undef
    },
    {
        'ResourceID' => [
            0
        ],
        'Recurring'   => undef,
        'Location'    => 'Germany',
        'AllDay'      => undef,
        'EndTime'     => '2016-12-12 14:00:00',
        'TimezoneID'  => '2',
        'StartTime'   => '2016-12-12 13:15:00',
        'Description' => 'Once per month',
        'Title'       => 'Monthly meeting',

        'TeamID'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => '116',

    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => '116',

        'TeamID'      => undef,
        'TimezoneID'  => '2',
        'StartTime'   => '2017-01-12 13:15:00',
        'Description' => 'Once per month',
        'Title'       => 'Monthly meeting',
        'Recurring'   => undef,
        'ResourceID'  => [
            0
        ],
        'AllDay'   => undef,
        'Location' => 'Germany',
        'EndTime'  => '2017-01-12 14:00:00'
    },
    {

        'TeamID'     => undef,
        'CalendarID' => $Calendar{CalendarID},

        'ParentID'   => '116',
        'ResourceID' => [
            0
        ],
        'Recurring'   => undef,
        'AllDay'      => undef,
        'Location'    => 'Germany',
        'EndTime'     => '2017-02-12 14:00:00',
        'StartTime'   => '2017-02-12 13:15:00',
        'TimezoneID'  => '2',
        'Title'       => 'Monthly meeting',
        'Description' => 'Once per month'
    },
    {
        'StartTime'   => '2016-03-31 08:00:00',
        'TimezoneID'  => '2',
        'Description' => undef,
        'Title'       => 'End of the month',
        'Recurring'   => '1',
        'ResourceID'  => [
            0
        ],
        'EndTime'    => '2016-03-31 09:00:00',
        'AllDay'     => undef,
        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},

        'ParentID' => undef,

        'TeamID' => undef
    },
    {
        'Recurring'  => undef,
        'ResourceID' => [
            0
        ],
        'AllDay'      => undef,
        'EndTime'     => '2016-04-30 09:00:00',
        'Location'    => undef,
        'StartTime'   => '2016-04-30 08:00:00',
        'TimezoneID'  => '2',
        'Description' => undef,
        'Title'       => 'End of the month',

        'TeamID'     => undef,
        'CalendarID' => $Calendar{CalendarID},

        'ParentID' => '127'
    },
    {
        'ParentID' => '127',

        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => undef,

        'Description' => undef,
        'Title'       => 'End of the month',
        'TimezoneID'  => '2',
        'StartTime'   => '2016-05-31 08:00:00',
        'AllDay'      => undef,
        'Location'    => undef,
        'EndTime'     => '2016-05-31 09:00:00',
        'ResourceID'  => [
            0
        ],
        'Recurring' => undef
    },
    {
        'Description' => undef,
        'Title'       => 'End of the month',
        'StartTime'   => '2016-06-30 08:00:00',
        'TimezoneID'  => '2',
        'AllDay'      => undef,
        'EndTime'     => '2016-06-30 09:00:00',
        'Location'    => undef,
        'Recurring'   => undef,
        'ResourceID'  => [
            0
        ],

        'ParentID'   => '127',
        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => undef,

    },
    {

        'ParentID'   => '127',
        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => undef,

        'Description' => undef,
        'Title'       => 'End of the month',
        'StartTime'   => '2016-07-31 08:00:00',
        'TimezoneID'  => '2',
        'AllDay'      => undef,
        'EndTime'     => '2016-07-31 09:00:00',
        'Location'    => undef,
        'Recurring'   => undef,
        'ResourceID'  => [
            0
            ]
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => '127',

        'TeamID'      => undef,
        'TimezoneID'  => '2',
        'StartTime'   => '2016-08-31 08:00:00',
        'Description' => undef,
        'Title'       => 'End of the month',
        'Recurring'   => undef,
        'ResourceID'  => [
            0
        ],
        'AllDay'   => undef,
        'Location' => undef,
        'EndTime'  => '2016-08-31 09:00:00'
    },
    {

        'ParentID'   => '127',
        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => undef,

        'Description' => undef,
        'Title'       => 'End of the month',
        'StartTime'   => '2016-09-30 08:00:00',
        'TimezoneID'  => '2',
        'AllDay'      => undef,
        'EndTime'     => '2016-09-30 09:00:00',
        'Location'    => undef,
        'ResourceID'  => [
            0
        ],
        'Recurring' => undef
    },
    {
        'TeamID' => undef,

        'ParentID' => '127',

        'CalendarID' => $Calendar{CalendarID},
        'EndTime'    => '2016-10-31 09:00:00',
        'AllDay'     => undef,
        'Location'   => undef,
        'Recurring'  => undef,
        'ResourceID' => [
            0
        ],
        'Description' => undef,
        'Title'       => 'End of the month',
        'TimezoneID'  => '2',
        'StartTime'   => '2016-10-31 08:00:00'
    },
    {

        'TeamID'     => undef,
        'CalendarID' => $Calendar{CalendarID},

        'ParentID'   => '127',
        'Recurring'  => undef,
        'ResourceID' => [
            0
        ],
        'EndTime'     => '2016-11-30 09:00:00',
        'AllDay'      => undef,
        'Location'    => undef,
        'StartTime'   => '2016-11-30 08:00:00',
        'TimezoneID'  => '2',
        'Description' => undef,
        'Title'       => 'End of the month'
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => '127',

        'TeamID'      => undef,
        'TimezoneID'  => '2',
        'StartTime'   => '2016-12-31 08:00:00',
        'Title'       => 'End of the month',
        'Description' => undef,
        'Recurring'   => undef,
        'ResourceID'  => [
            0
        ],
        'Location' => undef,
        'AllDay'   => undef,
        'EndTime'  => '2016-12-31 09:00:00'
    },
    {

        'ParentID'   => '127',
        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => undef,

        'Description' => undef,
        'Title'       => 'End of the month',
        'StartTime'   => '2017-01-31 08:00:00',
        'TimezoneID'  => '2',
        'AllDay'      => undef,
        'EndTime'     => '2017-01-31 09:00:00',
        'Location'    => undef,
        'ResourceID'  => [
            0
        ],
        'Recurring' => undef
    },
    {
        'ResourceID' => [
            0
        ],
        'Recurring'   => undef,
        'AllDay'      => undef,
        'Location'    => undef,
        'EndTime'     => '2017-02-28 09:00:00',
        'StartTime'   => '2017-02-28 08:00:00',
        'TimezoneID'  => '2',
        'Description' => undef,
        'Title'       => 'End of the month',

        'TeamID'     => undef,
        'CalendarID' => $Calendar{CalendarID},

        'ParentID' => '127'
    },
    {
        'StartTime'   => '2016-01-31 10:00:00',
        'TimezoneID'  => '2',
        'Title'       => 'Each 2 months',
        'Description' => 'test',
        'Recurring'   => '1',
        'ResourceID'  => [
            0
        ],
        'Location'   => 'Test',
        'AllDay'     => undef,
        'EndTime'    => '2016-01-31 11:00:00',
        'CalendarID' => $Calendar{CalendarID},

        'ParentID' => undef,

        'TeamID' => undef
    },
    {

        'TeamID'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => '139',

        'Recurring'  => undef,
        'ResourceID' => [
            0
        ],
        'EndTime'     => '2016-03-31 11:00:00',
        'AllDay'      => undef,
        'Location'    => 'Test',
        'TimezoneID'  => '2',
        'StartTime'   => '2016-03-31 10:00:00',
        'Description' => 'test',
        'Title'       => 'Each 2 months'
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => '139',

        'TeamID'      => undef,
        'TimezoneID'  => '2',
        'StartTime'   => '2016-05-31 10:00:00',
        'Description' => 'test',
        'Title'       => 'Each 2 months',
        'Recurring'   => undef,
        'ResourceID'  => [
            0
        ],
        'AllDay'   => undef,
        'Location' => 'Test',
        'EndTime'  => '2016-05-31 11:00:00'
    },
    {
        'Title'       => 'Each 2 months',
        'Description' => 'test',
        'TimezoneID'  => '2',
        'StartTime'   => '2016-07-31 10:00:00',
        'AllDay'      => undef,
        'EndTime'     => '2016-07-31 11:00:00',
        'Location'    => 'Test',
        'ResourceID'  => [
            0
        ],
        'Recurring' => undef,
        'ParentID'  => '139',

        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => undef,

    },
    {

        'ParentID'   => '139',
        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => undef,

        'Title'       => 'Each 2 months',
        'Description' => 'test',
        'StartTime'   => '2016-09-30 10:00:00',
        'TimezoneID'  => '2',
        'AllDay'      => undef,
        'Location'    => 'Test',
        'EndTime'     => '2016-09-30 11:00:00',
        'Recurring'   => undef,
        'ResourceID'  => [
            0
            ]
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => '139',

        'TeamID'      => undef,
        'TimezoneID'  => '2',
        'StartTime'   => '2016-11-30 10:00:00',
        'Description' => 'test',
        'Title'       => 'Each 2 months',
        'ResourceID'  => [
            0
        ],
        'Recurring' => undef,
        'EndTime'   => '2016-11-30 11:00:00',
        'AllDay'    => undef,
        'Location'  => 'Test'
    },
    {
        'AllDay'     => undef,
        'Location'   => 'Test',
        'EndTime'    => '2017-01-31 11:00:00',
        'Recurring'  => undef,
        'ResourceID' => [
            0
        ],
        'Description' => 'test',
        'Title'       => 'Each 2 months',
        'StartTime'   => '2017-01-31 10:00:00',
        'TimezoneID'  => '2',
        'TeamID'      => undef,

        'ParentID'   => '139',
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'TeamID' => undef,

        'ParentID' => undef,

        'CalendarID' => $Calendar{CalendarID},
        'Location'   => 'Stara Pazova',
        'AllDay'     => undef,
        'EndTime'    => '2016-04-12 10:00:00',
        'ResourceID' => [
            0
        ],
        'Recurring'   => '1',
        'Title'       => 'My event',
        'Description' => 'Test description',
        'TimezoneID'  => '2',
        'StartTime'   => '2016-04-12 09:00:00'
    },
    {
        'EndTime'    => '2016-04-14 10:00:00',
        'AllDay'     => undef,
        'Location'   => 'Stara Pazova',
        'Recurring'  => undef,
        'ResourceID' => [
            0
        ],
        'Description' => 'Test description',
        'Title'       => 'My event',
        'TimezoneID'  => '2',
        'StartTime'   => '2016-04-14 09:00:00',
        'TeamID'      => undef,

        'ParentID' => '146',

        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'AllDay'     => undef,
        'EndTime'    => '2016-04-16 10:00:00',
        'Location'   => 'Stara Pazova',
        'ResourceID' => [
            0
        ],
        'Recurring'   => undef,
        'Description' => 'Test description',
        'Title'       => 'My event',
        'TimezoneID'  => '2',
        'StartTime'   => '2016-04-16 09:00:00',
        'TeamID'      => undef,

        'ParentID' => '146',

        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'Description' => 'Test description',
        'Title'       => 'My event',
        'TimezoneID'  => '2',
        'StartTime'   => '2016-04-18 09:00:00',
        'Location'    => 'Stara Pazova',
        'AllDay'      => undef,
        'EndTime'     => '2016-04-18 10:00:00',
        'Recurring'   => undef,
        'ResourceID'  => [
            0
        ],
        'ParentID' => '146',

        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => undef,

    },
    {
        'StartTime'   => '2016-04-20 09:00:00',
        'TimezoneID'  => '2',
        'Description' => 'Test description',
        'Title'       => 'My event',
        'Recurring'   => undef,
        'ResourceID'  => [
            0
        ],
        'AllDay'     => undef,
        'EndTime'    => '2016-04-20 10:00:00',
        'Location'   => 'Stara Pazova',
        'CalendarID' => $Calendar{CalendarID},

        'ParentID' => '146',

        'TeamID' => undef
    },
    {
        'Recurring'  => undef,
        'ResourceID' => [
            0
        ],
        'EndTime'     => '2016-04-22 10:00:00',
        'AllDay'      => undef,
        'Location'    => 'Stara Pazova',
        'TimezoneID'  => '2',
        'StartTime'   => '2016-04-22 09:00:00',
        'Title'       => 'My event',
        'Description' => 'Test description',

        'TeamID'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => '146',

    },
    {
        'AllDay'     => undef,
        'Location'   => 'Stara Pazova',
        'EndTime'    => '2016-04-24 10:00:00',
        'ResourceID' => [
            0
        ],
        'Recurring'   => undef,
        'Description' => 'Test description',
        'Title'       => 'My event',
        'StartTime'   => '2016-04-24 09:00:00',
        'TimezoneID'  => '2',
        'TeamID'      => undef,

        'ParentID'   => '146',
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'Description' => 'Test description',
        'Title'       => 'My event',
        'TimezoneID'  => '2',
        'StartTime'   => '2016-04-26 09:00:00',
        'Location'    => 'Stara Pazova',
        'AllDay'      => undef,
        'EndTime'     => '2016-04-26 10:00:00',
        'Recurring'   => undef,
        'ResourceID'  => [
            0
        ],
        'ParentID' => '146',

        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => undef,

    },
    {
        'EndTime'    => '2016-04-28 10:00:00',
        'AllDay'     => undef,
        'Location'   => 'Stara Pazova',
        'ResourceID' => [
            0
        ],
        'Recurring'   => undef,
        'Description' => 'Test description',
        'Title'       => 'My event',
        'StartTime'   => '2016-04-28 09:00:00',
        'TimezoneID'  => '2',
        'TeamID'      => undef,

        'ParentID'   => '146',
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'ParentID' => '146',

        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => undef,

        'Description' => 'Test description',
        'Title'       => 'My event',
        'TimezoneID'  => '2',
        'StartTime'   => '2016-04-30 09:00:00',
        'EndTime'     => '2016-04-30 10:00:00',
        'AllDay'      => undef,
        'Location'    => 'Stara Pazova',
        'ResourceID'  => [
            0
        ],
        'Recurring' => undef
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => '146',

        'TeamID'      => undef,
        'TimezoneID'  => '2',
        'StartTime'   => '2016-05-02 09:00:00',
        'Description' => 'Test description',
        'Title'       => 'My event',
        'Recurring'   => undef,
        'ResourceID'  => [
            0
        ],
        'EndTime'  => '2016-05-02 10:00:00',
        'AllDay'   => undef,
        'Location' => 'Stara Pazova'
    },
    {
        'Title'       => 'My event',
        'Description' => 'Test description',
        'StartTime'   => '2016-05-04 09:00:00',
        'TimezoneID'  => '2',
        'EndTime'     => '2016-05-04 10:00:00',
        'AllDay'      => undef,
        'Location'    => 'Stara Pazova',
        'ResourceID'  => [
            0
        ],
        'Recurring' => undef,

        'ParentID'   => '146',
        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => undef,

    },
    {
        'Recurring'  => undef,
        'ResourceID' => [
            0
        ],
        'Location'    => 'Stara Pazova',
        'AllDay'      => undef,
        'EndTime'     => '2016-05-06 10:00:00',
        'StartTime'   => '2016-05-06 09:00:00',
        'TimezoneID'  => '2',
        'Description' => 'Test description',
        'Title'       => 'My event',

        'TeamID'     => undef,
        'CalendarID' => $Calendar{CalendarID},

        'ParentID' => '146'
    },
    {
        'Title'       => 'My event',
        'Description' => 'Test description',
        'TimezoneID'  => '2',
        'StartTime'   => '2016-05-08 09:00:00',
        'Location'    => 'Stara Pazova',
        'AllDay'      => undef,
        'EndTime'     => '2016-05-08 10:00:00',
        'Recurring'   => undef,
        'ResourceID'  => [
            0
        ],
        'ParentID' => '146',

        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => undef,

    },
    {
        'CalendarID' => $Calendar{CalendarID},

        'ParentID' => '146',

        'TeamID'      => undef,
        'StartTime'   => '2016-05-10 09:00:00',
        'TimezoneID'  => '2',
        'Title'       => 'My event',
        'Description' => 'Test description',
        'ResourceID'  => [
            0
        ],
        'Recurring' => undef,
        'Location'  => 'Stara Pazova',
        'AllDay'    => undef,
        'EndTime'   => '2016-05-10 10:00:00'
    },
    {
        'ParentID' => '146',

        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => undef,

        'Description' => 'Test description',
        'Title'       => 'My event',
        'TimezoneID'  => '2',
        'StartTime'   => '2016-05-12 09:00:00',
        'AllDay'      => undef,
        'Location'    => 'Stara Pazova',
        'EndTime'     => '2016-05-12 10:00:00',
        'ResourceID'  => [
            0
        ],
        'Recurring' => undef
    },
    {

        'ParentID'   => '146',
        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => undef,

        'Description' => 'Test description',
        'Title'       => 'My event',
        'StartTime'   => '2016-05-14 09:00:00',
        'TimezoneID'  => '2',
        'Location'    => 'Stara Pazova',
        'AllDay'      => undef,
        'EndTime'     => '2016-05-14 10:00:00',
        'Recurring'   => undef,
        'ResourceID'  => [
            0
            ]
    },
    {

        'TeamID'     => undef,
        'CalendarID' => $Calendar{CalendarID},

        'ParentID'   => '146',
        'ResourceID' => [
            0
        ],
        'Recurring'   => undef,
        'Location'    => 'Stara Pazova',
        'AllDay'      => undef,
        'EndTime'     => '2016-05-16 10:00:00',
        'StartTime'   => '2016-05-16 09:00:00',
        'TimezoneID'  => '2',
        'Description' => 'Test description',
        'Title'       => 'My event'
    },
    {
        'Description' => 'Test description',
        'Title'       => 'My event',
        'TimezoneID'  => '2',
        'StartTime'   => '2016-05-18 09:00:00',
        'Location'    => 'Stara Pazova',
        'AllDay'      => undef,
        'EndTime'     => '2016-05-18 10:00:00',
        'ResourceID'  => [
            0
        ],
        'Recurring' => undef,
        'ParentID'  => '146',

        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => undef,

    },
    {
        'EndTime'    => '2016-05-20 10:00:00',
        'AllDay'     => undef,
        'Location'   => 'Stara Pazova',
        'ResourceID' => [
            0
        ],
        'Recurring'   => undef,
        'Description' => 'Test description',
        'Title'       => 'My event',
        'StartTime'   => '2016-05-20 09:00:00',
        'TimezoneID'  => '2',
        'TeamID'      => undef,

        'ParentID'   => '146',
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'ResourceID' => [
            0
        ],
        'Recurring'   => undef,
        'EndTime'     => '2016-05-22 10:00:00',
        'AllDay'      => undef,
        'Location'    => 'Stara Pazova',
        'StartTime'   => '2016-05-22 09:00:00',
        'TimezoneID'  => '2',
        'Description' => 'Test description',
        'Title'       => 'My event',

        'TeamID'     => undef,
        'CalendarID' => $Calendar{CalendarID},

        'ParentID' => '146'
    },
    {
        'ResourceID' => [
            0
        ],
        'Recurring'   => undef,
        'Location'    => 'Stara Pazova',
        'AllDay'      => undef,
        'EndTime'     => '2016-05-24 10:00:00',
        'StartTime'   => '2016-05-24 09:00:00',
        'TimezoneID'  => '2',
        'Title'       => 'My event',
        'Description' => 'Test description',

        'TeamID'     => undef,
        'CalendarID' => $Calendar{CalendarID},

        'ParentID' => '146'
    },
    {

        'ParentID'   => '146',
        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => undef,

        'Description' => 'Test description',
        'Title'       => 'My event',
        'StartTime'   => '2016-05-26 09:00:00',
        'TimezoneID'  => '2',
        'AllDay'      => undef,
        'EndTime'     => '2016-05-26 10:00:00',
        'Location'    => 'Stara Pazova',
        'Recurring'   => undef,
        'ResourceID'  => [
            0
            ]
    },
    {
        'TimezoneID'  => '2',
        'StartTime'   => '2016-05-28 09:00:00',
        'Description' => 'Test description',
        'Title'       => 'My event',
        'ResourceID'  => [
            0
        ],
        'Recurring'  => undef,
        'EndTime'    => '2016-05-28 10:00:00',
        'AllDay'     => undef,
        'Location'   => 'Stara Pazova',
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => '146',

        'TeamID' => undef
    },
    {
        'AllDay'     => undef,
        'EndTime'    => '2016-05-30 10:00:00',
        'Location'   => 'Stara Pazova',
        'ResourceID' => [
            0
        ],
        'Recurring'   => undef,
        'Description' => 'Test description',
        'Title'       => 'My event',
        'TimezoneID'  => '2',
        'StartTime'   => '2016-05-30 09:00:00',
        'TeamID'      => undef,

        'ParentID' => '146',

        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'TeamID' => undef,

        'ParentID' => undef,

        'CalendarID' => $Calendar{CalendarID},
        'Location'   => undef,
        'AllDay'     => undef,
        'EndTime'    => '2016-04-01 11:00:00',
        'Recurring'  => '1',
        'ResourceID' => [
            0
        ],
        'Description' => undef,
        'Title'       => 'Each 2 years',
        'TimezoneID'  => '2',
        'StartTime'   => '2016-04-01 10:00:00'
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => '171',

        'TeamID'      => undef,
        'TimezoneID'  => '2',
        'StartTime'   => '2018-04-01 10:00:00',
        'Description' => undef,
        'Title'       => 'Each 2 years',
        'ResourceID'  => [
            0
        ],
        'Recurring' => undef,
        'Location'  => undef,
        'AllDay'    => undef,
        'EndTime'   => '2018-04-01 11:00:00'
    },
    {

        'TeamID'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => '171',

        'ResourceID' => [
            0
        ],
        'Recurring'   => undef,
        'EndTime'     => '2020-04-01 11:00:00',
        'AllDay'      => undef,
        'Location'    => undef,
        'TimezoneID'  => '2',
        'StartTime'   => '2020-04-01 10:00:00',
        'Description' => undef,
        'Title'       => 'Each 2 years'
    },
    {
        'ParentID' => undef,

        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => undef,

        'Description' => undef,
        'Title'       => 'Each 3thd all day',
        'TimezoneID'  => '0',
        'StartTime'   => '2016-04-02 00:00:00',
        'AllDay'      => '1',
        'Location'    => undef,
        'EndTime'     => '2016-04-03 00:00:00',
        'ResourceID'  => [
            0
        ],
        'Recurring' => '1'
    },
    {
        'ParentID' => '174',

        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => undef,

        'Title'       => 'Each 3thd all day',
        'Description' => undef,
        'TimezoneID'  => '0',
        'StartTime'   => '2016-04-05 00:00:00',
        'EndTime'     => '2016-04-06 00:00:00',
        'AllDay'      => '1',
        'Location'    => undef,
        'Recurring'   => undef,
        'ResourceID'  => [
            0
            ]
    },
    {
        'AllDay'     => '1',
        'EndTime'    => '2016-04-09 00:00:00',
        'Location'   => undef,
        'ResourceID' => [
            0
        ],
        'Recurring'   => undef,
        'Description' => undef,
        'Title'       => 'Each 3thd all day',
        'StartTime'   => '2016-04-08 00:00:00',
        'TimezoneID'  => '0',
        'TeamID'      => undef,

        'ParentID'   => '174',
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'Description' => undef,
        'Title'       => 'Each 3thd all day',
        'StartTime'   => '2016-04-11 00:00:00',
        'TimezoneID'  => '0',
        'AllDay'      => '1',
        'EndTime'     => '2016-04-12 00:00:00',
        'Location'    => undef,
        'Recurring'   => undef,
        'ResourceID'  => [
            0
        ],

        'ParentID'   => '174',
        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => undef,

    },
    {
        'TeamID' => undef,

        'ParentID'   => '174',
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => '1',
        'Location'   => undef,
        'EndTime'    => '2016-04-15 00:00:00',
        'Recurring'  => undef,
        'ResourceID' => [
            0
        ],
        'Description' => undef,
        'Title'       => 'Each 3thd all day',
        'StartTime'   => '2016-04-14 00:00:00',
        'TimezoneID'  => '0'
    },
    {
        'ParentID' => '174',

        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => undef,

        'Title'       => 'Each 3thd all day',
        'Description' => undef,
        'TimezoneID'  => '0',
        'StartTime'   => '2016-04-17 00:00:00',
        'AllDay'      => '1',
        'EndTime'     => '2016-04-18 00:00:00',
        'Location'    => undef,
        'Recurring'   => undef,
        'ResourceID'  => [
            0
            ]
    },
    {
        'Title'       => 'Each 3thd all day',
        'Description' => undef,
        'StartTime'   => '2016-04-20 00:00:00',
        'TimezoneID'  => '0',
        'Location'    => undef,
        'AllDay'      => '1',
        'EndTime'     => '2016-04-21 00:00:00',
        'ResourceID'  => [
            0
        ],
        'Recurring' => undef,

        'ParentID'   => '174',
        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => undef,

    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => '174',

        'TeamID'      => undef,
        'TimezoneID'  => '0',
        'StartTime'   => '2016-04-23 00:00:00',
        'Description' => undef,
        'Title'       => 'Each 3thd all day',
        'ResourceID'  => [
            0
        ],
        'Recurring' => undef,
        'Location'  => undef,
        'AllDay'    => '1',
        'EndTime'   => '2016-04-24 00:00:00'
    },
    {
        'TimezoneID'  => '0',
        'StartTime'   => '2016-04-26 00:00:00',
        'Description' => undef,
        'Title'       => 'Each 3thd all day',
        'ResourceID'  => [
            0
        ],
        'Recurring'  => undef,
        'AllDay'     => '1',
        'EndTime'    => '2016-04-27 00:00:00',
        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => '174',

        'TeamID' => undef
    },
    {
        'CalendarID' => $Calendar{CalendarID},

        'ParentID' => '174',

        'TeamID'      => undef,
        'StartTime'   => '2016-04-29 00:00:00',
        'TimezoneID'  => '0',
        'Description' => undef,
        'Title'       => 'Each 3thd all day',
        'Recurring'   => undef,
        'ResourceID'  => [
            0
        ],
        'Location' => undef,
        'AllDay'   => '1',
        'EndTime'  => '2016-04-30 00:00:00'
    },
    {
        'TeamID' => undef,

        'ParentID'   => undef,
        'CalendarID' => $Calendar{CalendarID},
        'EndTime'    => '2016-03-07 17:00:00',
        'AllDay'     => undef,
        'Location'   => undef,
        'Recurring'  => '1',
        'ResourceID' => [
            0
        ],
        'Description' => undef,
        'Title'       => 'First 3 days',
        'StartTime'   => '2016-03-07 16:00:00',
        'TimezoneID'  => '2'
    },
    {

        'TeamID'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => '184',

        'Recurring'  => undef,
        'ResourceID' => [
            0
        ],
        'EndTime'     => '2016-03-08 17:00:00',
        'AllDay'      => undef,
        'Location'    => undef,
        'TimezoneID'  => '2',
        'StartTime'   => '2016-03-08 16:00:00',
        'Description' => undef,
        'Title'       => 'First 3 days'
    },
    {
        'Recurring'  => undef,
        'ResourceID' => [
            0
        ],
        'AllDay'      => undef,
        'EndTime'     => '2016-03-09 17:00:00',
        'Location'    => undef,
        'TimezoneID'  => '2',
        'StartTime'   => '2016-03-09 16:00:00',
        'Title'       => 'First 3 days',
        'Description' => undef,

        'TeamID'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => '184',

    },
    {
        'CalendarID' => $Calendar{CalendarID},

        'ParentID' => undef,

        'TeamID'      => undef,
        'StartTime'   => '2016-03-02 18:00:00',
        'TimezoneID'  => '2',
        'Description' => undef,
        'Title'       => 'Once per next 2 month',
        'Recurring'   => '1',
        'ResourceID'  => [
            0
        ],
        'Location' => undef,
        'AllDay'   => undef,
        'EndTime'  => '2016-03-02 19:00:00'
    },
    {

        'TeamID'     => undef,
        'CalendarID' => $Calendar{CalendarID},

        'ParentID'   => '187',
        'ResourceID' => [
            0
        ],
        'Recurring'   => undef,
        'AllDay'      => undef,
        'Location'    => undef,
        'EndTime'     => '2016-04-02 19:00:00',
        'StartTime'   => '2016-04-02 18:00:00',
        'TimezoneID'  => '2',
        'Description' => undef,
        'Title'       => 'Once per next 2 month'
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => undef,

        'TeamID'      => undef,
        'TimezoneID'  => '2',
        'StartTime'   => '2016-01-03 18:00:00',
        'Description' => undef,
        'Title'       => 'January 3th next 3 years',
        'ResourceID'  => [
            0
        ],
        'Recurring' => '1',
        'AllDay'    => undef,
        'Location'  => undef,
        'EndTime'   => '2016-01-03 19:00:00'
    },
    {

        'TeamID'     => undef,
        'CalendarID' => $Calendar{CalendarID},

        'ParentID'   => '189',
        'Recurring'  => undef,
        'ResourceID' => [
            0
        ],
        'AllDay'      => undef,
        'Location'    => undef,
        'EndTime'     => '2017-01-03 19:00:00',
        'StartTime'   => '2017-01-03 18:00:00',
        'TimezoneID'  => '2',
        'Description' => undef,
        'Title'       => 'January 3th next 3 years'
    },
    {
        'AllDay'     => undef,
        'EndTime'    => '2018-01-03 19:00:00',
        'Location'   => undef,
        'Recurring'  => undef,
        'ResourceID' => [
            0
        ],
        'Description' => undef,
        'Title'       => 'January 3th next 3 years',
        'StartTime'   => '2018-01-03 18:00:00',
        'TimezoneID'  => '2',
        'TeamID'      => undef,

        'ParentID'   => '189',
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'TeamID' => undef,

        'ParentID' => undef,

        'CalendarID' => $Calendar{CalendarID},
        'Location'   => undef,
        'AllDay'     => undef,
        'EndTime'    => '2016-04-12 17:00:00',
        'ResourceID' => [
            0
        ],
        'Recurring'   => '1',
        'Description' => 'Developer meeting each 2nd Tuesday',
        'Title'       => 'Each 2nd week',
        'TimezoneID'  => '2',
        'StartTime'   => '2016-04-12 16:00:00'
    },
    {
        'Description' => 'Developer meeting each 2nd Tuesday',
        'Title'       => 'Each 2nd week',
        'TimezoneID'  => '2',
        'StartTime'   => '2016-06-02 16:00:00',
        'AllDay'      => undef,
        'Location'    => undef,
        'EndTime'     => '2016-06-02 17:00:00',
        'ResourceID'  => [
            0
        ],
        'Recurring' => undef,
        'ParentID'  => '192',

        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => undef,

    },
    {
        'Location'   => undef,
        'AllDay'     => undef,
        'EndTime'    => '2016-08-02 17:00:00',
        'Recurring'  => undef,
        'ResourceID' => [
            0
        ],
        'Description' => 'Developer meeting each 2nd Tuesday',
        'Title'       => 'Each 2nd week',
        'StartTime'   => '2016-08-02 16:00:00',
        'TimezoneID'  => '2',
        'TeamID'      => undef,

        'ParentID'   => '192',
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'StartTime'   => '2016-10-02 16:00:00',
        'TimezoneID'  => '2',
        'Description' => 'Developer meeting each 2nd Tuesday',
        'Title'       => 'Each 2nd week',
        'Recurring'   => undef,
        'ResourceID'  => [
            0
        ],
        'EndTime'    => '2016-10-02 17:00:00',
        'AllDay'     => undef,
        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},

        'ParentID' => '192',

        'TeamID' => undef
    },
    {
        'AllDay'     => undef,
        'EndTime'    => '2016-12-02 17:00:00',
        'Location'   => undef,
        'Recurring'  => undef,
        'ResourceID' => [
            0
        ],
        'Title'       => 'Each 2nd week',
        'Description' => 'Developer meeting each 2nd Tuesday',
        'StartTime'   => '2016-12-02 16:00:00',
        'TimezoneID'  => '2',
        'TeamID'      => undef,

        'ParentID'   => '192',
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'TimezoneID'  => '2',
        'StartTime'   => '2016-01-11 09:00:00',
        'Description' => 'Start at Monday and repeat each 2nd Wednesday and Sunday.',
        'Title'       => 'Custom 1',
        'Recurring'   => '1',
        'ResourceID'  => [
            0
        ],
        'EndTime'    => '2016-01-11 10:00:00',
        'AllDay'     => undef,
        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => undef,

        'TeamID' => undef
    },
    {
        'StartTime'   => '2016-03-03 09:00:00',
        'TimezoneID'  => '2',
        'Title'       => 'Custom 1',
        'Description' => 'Start at Monday and repeat each 2nd Wednesday and Sunday.',
        'Recurring'   => undef,
        'ResourceID'  => [
            0
        ],
        'Location'   => undef,
        'AllDay'     => undef,
        'EndTime'    => '2016-03-03 10:00:00',
        'CalendarID' => $Calendar{CalendarID},

        'ParentID' => '197',

        'TeamID' => undef
    },
    {
        'TeamID' => undef,

        'ParentID'   => undef,
        'CalendarID' => $Calendar{CalendarID},
        'Location'   => undef,
        'AllDay'     => undef,
        'EndTime'    => '2016-01-12 10:00:00',
        'Recurring'  => '1',
        'ResourceID' => [
            0
        ],
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'Title'       => 'Custom 2',
        'StartTime'   => '2016-01-12 09:00:00',
        'TimezoneID'  => '2'
    },
    {
        'AllDay'     => undef,
        'EndTime'    => '2016-02-12 10:00:00',
        'Location'   => undef,
        'ResourceID' => [
            0
        ],
        'Recurring'   => undef,
        'Title'       => 'Custom 2',
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'TimezoneID'  => '2',
        'StartTime'   => '2016-02-12 09:00:00',
        'TeamID'      => undef,

        'ParentID' => '199',

        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'Recurring'  => undef,
        'ResourceID' => [
            0
        ],
        'EndTime'     => '2016-03-12 10:00:00',
        'AllDay'      => undef,
        'Location'    => undef,
        'TimezoneID'  => '2',
        'StartTime'   => '2016-03-12 09:00:00',
        'Title'       => 'Custom 2',
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',

        'TeamID'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => '199',

    },
    {
        'CalendarID' => $Calendar{CalendarID},

        'ParentID' => '199',

        'TeamID'      => undef,
        'StartTime'   => '2016-04-12 09:00:00',
        'TimezoneID'  => '2',
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'Title'       => 'Custom 2',
        'ResourceID'  => [
            0
        ],
        'Recurring' => undef,
        'AllDay'    => undef,
        'Location'  => undef,
        'EndTime'   => '2016-04-12 10:00:00'
    },
    {
        'TeamID' => undef,

        'ParentID' => '199',

        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'Location'   => undef,
        'EndTime'    => '2016-05-12 10:00:00',
        'Recurring'  => undef,
        'ResourceID' => [
            0
        ],
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'Title'       => 'Custom 2',
        'TimezoneID'  => '2',
        'StartTime'   => '2016-05-12 09:00:00'
    },
    {
        'TeamID' => undef,

        'ParentID' => '199',

        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'EndTime'    => '2016-06-12 10:00:00',
        'Location'   => undef,
        'Recurring'  => undef,
        'ResourceID' => [
            0
        ],
        'Title'       => 'Custom 2',
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'TimezoneID'  => '2',
        'StartTime'   => '2016-06-12 09:00:00'
    },
    {
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'Title'       => 'Custom 2',
        'StartTime'   => '2016-07-12 09:00:00',
        'TimezoneID'  => '2',
        'AllDay'      => undef,
        'Location'    => undef,
        'EndTime'     => '2016-07-12 10:00:00',
        'Recurring'   => undef,
        'ResourceID'  => [
            0
        ],

        'ParentID'   => '199',
        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => undef,

    },
    {
        'TeamID' => undef,

        'ParentID' => '199',

        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'Location'   => undef,
        'EndTime'    => '2016-08-12 10:00:00',
        'ResourceID' => [
            0
        ],
        'Recurring'   => undef,
        'Title'       => 'Custom 2',
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'TimezoneID'  => '2',
        'StartTime'   => '2016-08-12 09:00:00'
    },
    {
        'TimezoneID'  => '2',
        'StartTime'   => '2016-09-12 09:00:00',
        'Title'       => 'Custom 2',
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'Recurring'   => undef,
        'ResourceID'  => [
            0
        ],
        'AllDay'     => undef,
        'EndTime'    => '2016-09-12 10:00:00',
        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => '199',

        'TeamID' => undef
    },
    {
        'Recurring'  => undef,
        'ResourceID' => [
            0
        ],
        'EndTime'     => '2016-10-12 10:00:00',
        'AllDay'      => undef,
        'Location'    => undef,
        'TimezoneID'  => '2',
        'StartTime'   => '2016-10-12 09:00:00',
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'Title'       => 'Custom 2',

        'TeamID'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => '199',

    },
    {
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'Title'       => 'Custom 2',
        'TimezoneID'  => '2',
        'StartTime'   => '2016-11-12 09:00:00',
        'EndTime'     => '2016-11-12 10:00:00',
        'AllDay'      => undef,
        'Location'    => undef,
        'Recurring'   => undef,
        'ResourceID'  => [
            0
        ],
        'ParentID' => '199',

        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => undef,

    },
    {
        'ResourceID' => [
            0
        ],
        'Recurring'   => undef,
        'Location'    => undef,
        'AllDay'      => undef,
        'EndTime'     => '2016-12-12 10:00:00',
        'TimezoneID'  => '2',
        'StartTime'   => '2016-12-12 09:00:00',
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'Title'       => 'Custom 2',

        'TeamID'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'ParentID'   => '199',

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
