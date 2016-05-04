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
    107,
    "Appointment count",
);

my @Result = (
    {
        'TimezoneID'  => '2',
        'Recurring'   => undef,
        'Description' => undef,
        'StartTime'   => '2016-07-14 11:00:00',
        'EndTime'     => '2016-07-14 12:00:00',
        'Location'    => undef,
        'ParentID'    => undef,
        'TeamID'      => undef,
        'ResourceID'  => [
            0
        ],
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Marco',
        'AllDay'     => undef,
    },
    {
        'ResourceID' => [
            0
        ],
        'Title'       => 'All day',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => '1',
        'TimezoneID'  => '0',
        'Recurring'   => undef,
        'Location'    => undef,
        'EndTime'     => '2016-04-06 00:00:00',
        'TeamID'      => undef,
        'ParentID'    => undef,
        'Description' => 'test all day event',
        'StartTime'   => '2016-04-05 00:00:00'
    },
    {
        'Recurring'   => '1',
        'TimezoneID'  => '2',
        'Description' => 'Only once per week',
        'StartTime'   => '2016-04-12 11:30:00',
        'EndTime'     => '2016-04-12 12:00:00',
        'Location'    => 'Belgrade',
        'ParentID'    => undef,
        'TeamID'      => undef,
        'ResourceID'  => [
            0
        ],
        'Title'      => 'Once per week',
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
    },
    {
        'Recurring'   => undef,
        'TimezoneID'  => '2',
        'EndTime'     => '2016-04-19 12:00:00',
        'Location'    => 'Belgrade',
        'ParentID'    => '1250',
        'TeamID'      => undef,
        'Description' => 'Only once per week',
        'StartTime'   => '2016-04-19 11:30:00',
        'ResourceID'  => [
            0
        ],
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Once per week',
        'AllDay'     => undef
    },
    {
        'StartTime'   => '2016-04-26 11:30:00',
        'Description' => 'Only once per week',
        'TeamID'      => undef,
        'ParentID'    => '1250',
        'EndTime'     => '2016-04-26 12:00:00',
        'Location'    => 'Belgrade',

        'Recurring'  => undef,
        'TimezoneID' => '2',
        'AllDay'     => undef,

        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Once per week',
        'ResourceID' => [
            0
            ]
    },
    {
        'TimezoneID' => '2',
        'Recurring'  => undef,
        'TeamID'     => undef,
        'ParentID'   => '1250',
        'EndTime'    => '2016-05-03 12:00:00',

        'Location'    => 'Belgrade',
        'StartTime'   => '2016-05-03 11:30:00',
        'Description' => 'Only once per week',
        'CalendarID'  => $Calendar{CalendarID},
        'Title'       => 'Once per week',
        'ResourceID'  => [
            0
        ],

        'AllDay' => undef
    },
    {
        'Description' => 'Only once per week',
        'StartTime'   => '2016-05-10 11:30:00',
        'EndTime'     => '2016-05-10 12:00:00',

        'Location'   => 'Belgrade',
        'ParentID'   => '1250',
        'TeamID'     => undef,
        'Recurring'  => undef,
        'TimezoneID' => '2',
        'AllDay'     => undef,

        'ResourceID' => [
            0
        ],
        'Title'      => 'Once per week',
        'CalendarID' => $Calendar{CalendarID},
    },
    {

        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Once per week',
        'ResourceID' => [
            0
        ],
        'TeamID'   => undef,
        'ParentID' => '1250',
        'Location' => 'Belgrade',
        'EndTime'  => '2016-05-17 12:00:00',

        'StartTime'   => '2016-05-17 11:30:00',
        'Description' => 'Only once per week',
        'TimezoneID'  => '2',
        'Recurring'   => undef
    },
    {
        'Recurring'   => undef,
        'TimezoneID'  => '2',
        'Description' => 'Only once per week',
        'StartTime'   => '2016-05-24 11:30:00',
        'EndTime'     => '2016-05-24 12:00:00',
        'Location'    => 'Belgrade',

        'TeamID'     => undef,
        'ParentID'   => '1250',
        'ResourceID' => [
            0
        ],
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Once per week',
        'AllDay'     => undef,

    },
    {
        'TimezoneID'  => '2',
        'Recurring'   => undef,
        'StartTime'   => '2016-05-31 11:30:00',
        'Description' => 'Only once per week',
        'TeamID'      => undef,
        'ParentID'    => '1250',

        'EndTime'    => '2016-05-31 12:00:00',
        'Location'   => 'Belgrade',
        'Title'      => 'Once per week',
        'CalendarID' => $Calendar{CalendarID},
        'ResourceID' => [
            0
        ],
        'AllDay' => undef,

    },
    {
        'Recurring'   => undef,
        'TimezoneID'  => '2',
        'StartTime'   => '2016-06-07 11:30:00',
        'Description' => 'Only once per week',
        'ParentID'    => '1250',
        'TeamID'      => undef,

        'EndTime'    => '2016-06-07 12:00:00',
        'Location'   => 'Belgrade',
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Once per week',
        'ResourceID' => [
            0
        ],
        'AllDay' => undef,

    },
    {
        'Title'      => 'Monthly meeting',
        'CalendarID' => $Calendar{CalendarID},
        'ResourceID' => [
            0
        ],
        'AllDay' => undef,

        'Recurring'   => '1',
        'TimezoneID'  => '2',
        'StartTime'   => '2016-04-12 13:15:00',
        'Description' => 'Once per month',
        'ParentID'    => undef,
        'TeamID'      => undef,
        'EndTime'     => '2016-04-12 14:00:00',

        'Location' => 'Germany'
    },
    {

        'AllDay'     => undef,
        'ResourceID' => [
            0
        ],
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Monthly meeting',
        'EndTime'    => '2016-05-12 14:00:00',
        'Location'   => 'Germany',

        'ParentID'    => '1259',
        'TeamID'      => undef,
        'Description' => 'Once per month',
        'StartTime'   => '2016-05-12 13:15:00',
        'Recurring'   => undef,
        'TimezoneID'  => '2'
    },
    {
        'Recurring'   => undef,
        'TimezoneID'  => '2',
        'Description' => 'Once per month',
        'StartTime'   => '2016-06-12 13:15:00',

        'EndTime'    => '2016-06-12 14:00:00',
        'Location'   => 'Germany',
        'TeamID'     => undef,
        'ParentID'   => '1259',
        'ResourceID' => [
            0
        ],
        'Title'      => 'Monthly meeting',
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,

    },
    {
        'Title'      => 'Monthly meeting',
        'CalendarID' => $Calendar{CalendarID},
        'ResourceID' => [
            0
        ],
        'AllDay' => undef,

        'TimezoneID'  => '2',
        'Recurring'   => undef,
        'StartTime'   => '2016-07-12 13:15:00',
        'Description' => 'Once per month',
        'ParentID'    => '1259',
        'TeamID'      => undef,
        'EndTime'     => '2016-07-12 14:00:00',
        'Location'    => 'Germany',

    },
    {
        'AllDay' => undef,

        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Monthly meeting',
        'ResourceID' => [
            0
        ],
        'StartTime'   => '2016-08-12 13:15:00',
        'Description' => 'Once per month',
        'TeamID'      => undef,
        'ParentID'    => '1259',

        'EndTime'    => '2016-08-12 14:00:00',
        'Location'   => 'Germany',
        'TimezoneID' => '2',
        'Recurring'  => undef
    },
    {
        'TimezoneID'  => '2',
        'Recurring'   => undef,
        'StartTime'   => '2016-09-12 13:15:00',
        'Description' => 'Once per month',
        'ParentID'    => '1259',
        'TeamID'      => undef,
        'EndTime'     => '2016-09-12 14:00:00',
        'Location'    => 'Germany',

        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Monthly meeting',
        'ResourceID' => [
            0
        ],
        'AllDay' => undef,

    },
    {
        'Location' => 'Germany',
        'EndTime'  => '2016-10-12 14:00:00',

        'TeamID'      => undef,
        'ParentID'    => '1259',
        'Description' => 'Once per month',
        'StartTime'   => '2016-10-12 13:15:00',
        'TimezoneID'  => '2',
        'Recurring'   => undef,

        'AllDay'     => undef,
        'ResourceID' => [
            0
        ],
        'Title'      => 'Monthly meeting',
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'Title'      => 'Monthly meeting',
        'CalendarID' => $Calendar{CalendarID},
        'ResourceID' => [
            0
        ],

        'AllDay'     => undef,
        'TimezoneID' => '2',
        'Recurring'  => undef,
        'TeamID'     => undef,
        'ParentID'   => '1259',
        'Location'   => 'Germany',
        'EndTime'    => '2016-11-12 14:00:00',

        'StartTime'   => '2016-11-12 13:15:00',
        'Description' => 'Once per month'
    },
    {

        'EndTime'     => '2016-12-12 14:00:00',
        'Location'    => 'Germany',
        'ParentID'    => '1259',
        'TeamID'      => undef,
        'Description' => 'Once per month',
        'StartTime'   => '2016-12-12 13:15:00',
        'Recurring'   => undef,
        'TimezoneID'  => '2',

        'AllDay'     => undef,
        'ResourceID' => [
            0
        ],
        'Title'      => 'Monthly meeting',
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'ParentID' => '1259',
        'TeamID'   => undef,
        'Location' => 'Germany',
        'EndTime'  => '2017-01-12 14:00:00',

        'StartTime'   => '2017-01-12 13:15:00',
        'Description' => 'Once per month',
        'Recurring'   => undef,
        'TimezoneID'  => '2',

        'AllDay'     => undef,
        'Title'      => 'Monthly meeting',
        'CalendarID' => $Calendar{CalendarID},
        'ResourceID' => [
            0
            ]
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Monthly meeting',
        'ResourceID' => [
            0
        ],

        'AllDay'     => undef,
        'TimezoneID' => '2',
        'Recurring'  => undef,
        'ParentID'   => '1259',
        'TeamID'     => undef,
        'EndTime'    => '2017-02-12 14:00:00',
        'Location'   => 'Germany',

        'StartTime'   => '2017-02-12 13:15:00',
        'Description' => 'Once per month'
    },
    {
        'Description' => undef,
        'StartTime'   => '2016-03-31 08:00:00',

        'EndTime'    => '2016-03-31 09:00:00',
        'Location'   => undef,
        'ParentID'   => undef,
        'TeamID'     => undef,
        'Recurring'  => '1',
        'TimezoneID' => '2',
        'AllDay'     => undef,

        'ResourceID' => [
            0
        ],
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'End of the month'
    },
    {
        'AllDay' => undef,

        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'End of the month',
        'ResourceID' => [
            0
        ],
        'StartTime'   => '2016-04-30 08:00:00',
        'Description' => undef,
        'ParentID'    => '1270',
        'TeamID'      => undef,

        'EndTime'    => '2016-04-30 09:00:00',
        'Location'   => undef,
        'TimezoneID' => '2',
        'Recurring'  => undef
    },
    {
        'Description' => undef,
        'StartTime'   => '2016-05-31 08:00:00',
        'EndTime'     => '2016-05-31 09:00:00',

        'Location'   => undef,
        'TeamID'     => undef,
        'ParentID'   => '1270',
        'Recurring'  => undef,
        'TimezoneID' => '2',
        'AllDay'     => undef,

        'ResourceID' => [
            0
        ],
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'End of the month'
    },
    {
        'AllDay' => undef,

        'ResourceID' => [
            0
        ],
        'Title'       => 'End of the month',
        'CalendarID'  => $Calendar{CalendarID},
        'Description' => undef,
        'StartTime'   => '2016-06-30 08:00:00',
        'EndTime'     => '2016-06-30 09:00:00',

        'Location'   => undef,
        'ParentID'   => '1270',
        'TeamID'     => undef,
        'TimezoneID' => '2',
        'Recurring'  => undef
    },
    {

        'AllDay'     => undef,
        'Title'      => 'End of the month',
        'CalendarID' => $Calendar{CalendarID},
        'ResourceID' => [
            0
        ],
        'ParentID' => '1270',
        'TeamID'   => undef,
        'Location' => undef,
        'EndTime'  => '2016-07-31 09:00:00',

        'StartTime'   => '2016-07-31 08:00:00',
        'Description' => undef,
        'Recurring'   => undef,
        'TimezoneID'  => '2'
    },
    {
        'Title'      => 'End of the month',
        'CalendarID' => $Calendar{CalendarID},
        'ResourceID' => [
            0
        ],

        'AllDay'     => undef,
        'TimezoneID' => '2',
        'Recurring'  => undef,
        'ParentID'   => '1270',
        'TeamID'     => undef,
        'EndTime'    => '2016-08-31 09:00:00',

        'Location'    => undef,
        'StartTime'   => '2016-08-31 08:00:00',
        'Description' => undef
    },
    {

        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'End of the month',
        'ResourceID' => [
            0
        ],
        'ParentID' => '1270',
        'TeamID'   => undef,
        'EndTime'  => '2016-09-30 09:00:00',
        'Location' => undef,

        'StartTime'   => '2016-09-30 08:00:00',
        'Description' => undef,
        'Recurring'   => undef,
        'TimezoneID'  => '2'
    },
    {
        'Description' => undef,
        'StartTime'   => '2016-10-31 08:00:00',
        'EndTime'     => '2016-10-31 09:00:00',
        'Location'    => undef,

        'TeamID'     => undef,
        'ParentID'   => '1270',
        'Recurring'  => undef,
        'TimezoneID' => '2',
        'AllDay'     => undef,

        'ResourceID' => [
            0
        ],
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'End of the month'
    },
    {

        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'End of the month',
        'ResourceID' => [
            0
        ],
        'ParentID' => '1270',
        'TeamID'   => undef,

        'EndTime'     => '2016-11-30 09:00:00',
        'Location'    => undef,
        'StartTime'   => '2016-11-30 08:00:00',
        'Description' => undef,
        'Recurring'   => undef,
        'TimezoneID'  => '2'
    },
    {
        'ResourceID' => [
            0
        ],
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'End of the month',

        'AllDay'     => undef,
        'Recurring'  => undef,
        'TimezoneID' => '2',

        'EndTime'     => '2016-12-31 09:00:00',
        'Location'    => undef,
        'ParentID'    => '1270',
        'TeamID'      => undef,
        'Description' => undef,
        'StartTime'   => '2016-12-31 08:00:00'
    },
    {

        'AllDay'     => undef,
        'ResourceID' => [
            0
        ],
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'End of the month',
        'EndTime'    => '2017-01-31 09:00:00',
        'Location'   => undef,

        'TeamID'      => undef,
        'ParentID'    => '1270',
        'Description' => undef,
        'StartTime'   => '2017-01-31 08:00:00',
        'Recurring'   => undef,
        'TimezoneID'  => '2'
    },
    {
        'AllDay' => undef,

        'ResourceID' => [
            0
        ],
        'CalendarID'  => $Calendar{CalendarID},
        'Title'       => 'End of the month',
        'Description' => undef,
        'StartTime'   => '2017-02-28 08:00:00',
        'EndTime'     => '2017-02-28 09:00:00',
        'Location'    => undef,

        'ParentID'   => '1270',
        'TeamID'     => undef,
        'Recurring'  => undef,
        'TimezoneID' => '2'
    },
    {
        'ParentID' => undef,
        'TeamID'   => undef,
        'EndTime'  => '2016-01-31 11:00:00',

        'Location'    => 'Test',
        'StartTime'   => '2016-01-31 10:00:00',
        'Description' => 'test',
        'TimezoneID'  => '2',
        'Recurring'   => '1',

        'AllDay'     => undef,
        'Title'      => 'Each 2 months',
        'CalendarID' => $Calendar{CalendarID},
        'ResourceID' => [
            0
            ]
    },
    {
        'Recurring'   => undef,
        'TimezoneID'  => '2',
        'StartTime'   => '2016-03-31 10:00:00',
        'Description' => 'test',
        'ParentID'    => '1282',
        'TeamID'      => undef,
        'EndTime'     => '2016-03-31 11:00:00',

        'Location'   => 'Test',
        'Title'      => 'Each 2 months',
        'CalendarID' => $Calendar{CalendarID},
        'ResourceID' => [
            0
        ],
        'AllDay' => undef,

    },
    {
        'TeamID'   => undef,
        'ParentID' => '1282',
        'EndTime'  => '2016-05-31 11:00:00',
        'Location' => 'Test',

        'StartTime'   => '2016-05-31 10:00:00',
        'Description' => 'test',
        'TimezoneID'  => '2',
        'Recurring'   => undef,

        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 2 months',
        'ResourceID' => [
            0
            ]
    },
    {
        'EndTime' => '2016-07-31 11:00:00',

        'Location'    => 'Test',
        'TeamID'      => undef,
        'ParentID'    => '1282',
        'Description' => 'test',
        'StartTime'   => '2016-07-31 10:00:00',
        'TimezoneID'  => '2',
        'Recurring'   => undef,

        'AllDay'     => undef,
        'ResourceID' => [
            0
        ],
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 2 months'
    },
    {

        'AllDay'     => undef,
        'Title'      => 'Each 2 months',
        'CalendarID' => $Calendar{CalendarID},
        'ResourceID' => [
            0
        ],
        'ParentID' => '1282',
        'TeamID'   => undef,
        'EndTime'  => '2016-09-30 11:00:00',

        'Location'    => 'Test',
        'StartTime'   => '2016-09-30 10:00:00',
        'Description' => 'test',
        'Recurring'   => undef,
        'TimezoneID'  => '2'
    },
    {
        'ParentID' => '1282',
        'TeamID'   => undef,
        'EndTime'  => '2016-11-30 11:00:00',

        'Location'    => 'Test',
        'StartTime'   => '2016-11-30 10:00:00',
        'Description' => 'test',
        'TimezoneID'  => '2',
        'Recurring'   => undef,

        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 2 months',
        'ResourceID' => [
            0
            ]
    },
    {
        'AllDay' => undef,

        'ResourceID' => [
            0
        ],
        'Title'       => 'Each 2 months',
        'CalendarID'  => $Calendar{CalendarID},
        'Description' => 'test',
        'StartTime'   => '2017-01-31 10:00:00',

        'EndTime'    => '2017-01-31 11:00:00',
        'Location'   => 'Test',
        'ParentID'   => '1282',
        'TeamID'     => undef,
        'TimezoneID' => '2',
        'Recurring'  => undef
    },
    {

        'AllDay'     => undef,
        'ResourceID' => [
            0
        ],
        'Title'      => 'My event',
        'CalendarID' => $Calendar{CalendarID},
        'EndTime'    => '2016-04-12 10:00:00',
        'Location'   => 'Stara Pazova',

        'ParentID'    => undef,
        'TeamID'      => undef,
        'Description' => 'Test description',
        'StartTime'   => '2016-04-12 09:00:00',
        'TimezoneID'  => '2',
        'Recurring'   => '1'
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'My event',
        'ResourceID' => [
            0
        ],

        'AllDay'     => undef,
        'Recurring'  => undef,
        'TimezoneID' => '2',
        'TeamID'     => undef,
        'ParentID'   => '1289',
        'EndTime'    => '2016-04-14 10:00:00',
        'Location'   => 'Stara Pazova',

        'StartTime'   => '2016-04-14 09:00:00',
        'Description' => 'Test description'
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'My event',
        'ResourceID' => [
            0
        ],
        'AllDay' => undef,

        'TimezoneID'  => '2',
        'Recurring'   => undef,
        'StartTime'   => '2016-04-16 09:00:00',
        'Description' => 'Test description',
        'TeamID'      => undef,
        'ParentID'    => '1289',
        'EndTime'     => '2016-04-16 10:00:00',

        'Location' => 'Stara Pazova'
    },
    {
        'Recurring'  => undef,
        'TimezoneID' => '2',
        'Location'   => 'Stara Pazova',
        'EndTime'    => '2016-04-18 10:00:00',

        'ParentID'    => '1289',
        'TeamID'      => undef,
        'Description' => 'Test description',
        'StartTime'   => '2016-04-18 09:00:00',
        'ResourceID'  => [
            0
        ],
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'My event',

        'AllDay' => undef
    },
    {
        'TeamID'   => undef,
        'ParentID' => '1289',
        'Location' => 'Stara Pazova',
        'EndTime'  => '2016-04-20 10:00:00',

        'StartTime'   => '2016-04-20 09:00:00',
        'Description' => 'Test description',
        'TimezoneID'  => '2',
        'Recurring'   => undef,

        'AllDay'     => undef,
        'Title'      => 'My event',
        'CalendarID' => $Calendar{CalendarID},
        'ResourceID' => [
            0
            ]
    },
    {
        'Recurring'   => undef,
        'TimezoneID'  => '2',
        'Description' => 'Test description',
        'StartTime'   => '2016-04-22 09:00:00',
        'EndTime'     => '2016-04-22 10:00:00',
        'Location'    => 'Stara Pazova',

        'TeamID'     => undef,
        'ParentID'   => '1289',
        'ResourceID' => [
            0
        ],
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'My event',
        'AllDay'     => undef,

    },
    {
        'StartTime'   => '2016-04-24 09:00:00',
        'Description' => 'Test description',
        'ParentID'    => '1289',
        'TeamID'      => undef,
        'EndTime'     => '2016-04-24 10:00:00',

        'Location'   => 'Stara Pazova',
        'TimezoneID' => '2',
        'Recurring'  => undef,
        'AllDay'     => undef,

        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'My event',
        'ResourceID' => [
            0
            ]
    },
    {
        'ResourceID' => [
            0
        ],
        'Title'      => 'My event',
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,

        'Recurring'   => undef,
        'TimezoneID'  => '2',
        'Description' => 'Test description',
        'StartTime'   => '2016-04-26 09:00:00',
        'EndTime'     => '2016-04-26 10:00:00',

        'Location' => 'Stara Pazova',
        'TeamID'   => undef,
        'ParentID' => '1289'
    },
    {
        'Recurring'   => undef,
        'TimezoneID'  => '2',
        'StartTime'   => '2016-04-28 09:00:00',
        'Description' => 'Test description',
        'TeamID'      => undef,
        'ParentID'    => '1289',
        'EndTime'     => '2016-04-28 10:00:00',
        'Location'    => 'Stara Pazova',

        'Title'      => 'My event',
        'CalendarID' => $Calendar{CalendarID},
        'ResourceID' => [
            0
        ],
        'AllDay' => undef,

    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'My event',
        'ResourceID' => [
            0
        ],
        'AllDay' => undef,

        'Recurring'   => undef,
        'TimezoneID'  => '2',
        'StartTime'   => '2016-04-30 09:00:00',
        'Description' => 'Test description',
        'TeamID'      => undef,
        'ParentID'    => '1289',
        'Location'    => 'Stara Pazova',
        'EndTime'     => '2016-04-30 10:00:00',

    },
    {
        'Recurring'   => undef,
        'TimezoneID'  => '2',
        'Description' => 'Test description',
        'StartTime'   => '2016-05-02 09:00:00',
        'Location'    => 'Stara Pazova',
        'EndTime'     => '2016-05-02 10:00:00',

        'ParentID'   => '1289',
        'TeamID'     => undef,
        'ResourceID' => [
            0
        ],
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'My event',
        'AllDay'     => undef,

    },
    {
        'ResourceID' => [
            0
        ],
        'Title'      => 'My event',
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,

        'TimezoneID'  => '2',
        'Recurring'   => undef,
        'Description' => 'Test description',
        'StartTime'   => '2016-05-04 09:00:00',

        'EndTime'  => '2016-05-04 10:00:00',
        'Location' => 'Stara Pazova',
        'ParentID' => '1289',
        'TeamID'   => undef
    },
    {
        'ResourceID' => [
            0
        ],
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'My event',

        'AllDay'     => undef,
        'TimezoneID' => '2',
        'Recurring'  => undef,

        'EndTime'     => '2016-05-06 10:00:00',
        'Location'    => 'Stara Pazova',
        'ParentID'    => '1289',
        'TeamID'      => undef,
        'Description' => 'Test description',
        'StartTime'   => '2016-05-06 09:00:00'
    },
    {
        'StartTime'   => '2016-05-08 09:00:00',
        'Description' => 'Test description',
        'ParentID'    => '1289',
        'TeamID'      => undef,
        'EndTime'     => '2016-05-08 10:00:00',
        'Location'    => 'Stara Pazova',

        'Recurring'  => undef,
        'TimezoneID' => '2',
        'AllDay'     => undef,

        'Title'      => 'My event',
        'CalendarID' => $Calendar{CalendarID},
        'ResourceID' => [
            0
            ]
    },
    {
        'Recurring'   => undef,
        'TimezoneID'  => '2',
        'StartTime'   => '2016-05-10 09:00:00',
        'Description' => 'Test description',
        'ParentID'    => '1289',
        'TeamID'      => undef,
        'EndTime'     => '2016-05-10 10:00:00',

        'Location'   => 'Stara Pazova',
        'Title'      => 'My event',
        'CalendarID' => $Calendar{CalendarID},
        'ResourceID' => [
            0
        ],
        'AllDay' => undef,

    },
    {

        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'My event',
        'ResourceID' => [
            0
        ],
        'ParentID' => '1289',
        'TeamID'   => undef,
        'EndTime'  => '2016-05-12 10:00:00',
        'Location' => 'Stara Pazova',

        'StartTime'   => '2016-05-12 09:00:00',
        'Description' => 'Test description',
        'Recurring'   => undef,
        'TimezoneID'  => '2'
    },
    {
        'Recurring'   => undef,
        'TimezoneID'  => '2',
        'Description' => 'Test description',
        'StartTime'   => '2016-05-14 09:00:00',
        'EndTime'     => '2016-05-14 10:00:00',
        'Location'    => 'Stara Pazova',

        'ParentID'   => '1289',
        'TeamID'     => undef,
        'ResourceID' => [
            0
        ],
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'My event',
        'AllDay'     => undef,

    },
    {

        'AllDay'     => undef,
        'Title'      => 'My event',
        'CalendarID' => $Calendar{CalendarID},
        'ResourceID' => [
            0
        ],
        'TeamID'   => undef,
        'ParentID' => '1289',
        'Location' => 'Stara Pazova',
        'EndTime'  => '2016-05-16 10:00:00',

        'StartTime'   => '2016-05-16 09:00:00',
        'Description' => 'Test description',
        'Recurring'   => undef,
        'TimezoneID'  => '2'
    },
    {
        'Description' => 'Test description',
        'StartTime'   => '2016-05-18 09:00:00',
        'EndTime'     => '2016-05-18 10:00:00',

        'Location'   => 'Stara Pazova',
        'ParentID'   => '1289',
        'TeamID'     => undef,
        'TimezoneID' => '2',
        'Recurring'  => undef,
        'AllDay'     => undef,

        'ResourceID' => [
            0
        ],
        'Title'      => 'My event',
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'My event',
        'ResourceID' => [
            0
        ],

        'AllDay'     => undef,
        'Recurring'  => undef,
        'TimezoneID' => '2',
        'TeamID'     => undef,
        'ParentID'   => '1289',
        'Location'   => 'Stara Pazova',
        'EndTime'    => '2016-05-20 10:00:00',

        'StartTime'   => '2016-05-20 09:00:00',
        'Description' => 'Test description'
    },
    {
        'AllDay' => undef,

        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'My event',
        'ResourceID' => [
            0
        ],
        'StartTime'   => '2016-05-22 09:00:00',
        'Description' => 'Test description',
        'ParentID'    => '1289',
        'TeamID'      => undef,
        'Location'    => 'Stara Pazova',
        'EndTime'     => '2016-05-22 10:00:00',

        'TimezoneID' => '2',
        'Recurring'  => undef
    },
    {
        'ResourceID' => [
            0
        ],
        'Title'      => 'My event',
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,

        'Recurring'   => undef,
        'TimezoneID'  => '2',
        'Description' => 'Test description',
        'StartTime'   => '2016-05-24 09:00:00',
        'EndTime'     => '2016-05-24 10:00:00',

        'Location' => 'Stara Pazova',
        'ParentID' => '1289',
        'TeamID'   => undef
    },
    {
        'TimezoneID'  => '2',
        'Recurring'   => undef,
        'Description' => 'Test description',
        'StartTime'   => '2016-05-26 09:00:00',
        'Location'    => 'Stara Pazova',
        'EndTime'     => '2016-05-26 10:00:00',

        'TeamID'     => undef,
        'ParentID'   => '1289',
        'ResourceID' => [
            0
        ],
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'My event',
        'AllDay'     => undef,

    },
    {
        'EndTime' => '2016-05-28 10:00:00',

        'Location'    => 'Stara Pazova',
        'TeamID'      => undef,
        'ParentID'    => '1289',
        'Description' => 'Test description',
        'StartTime'   => '2016-05-28 09:00:00',
        'Recurring'   => undef,
        'TimezoneID'  => '2',

        'AllDay'     => undef,
        'ResourceID' => [
            0
        ],
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'My event'
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'My event',
        'ResourceID' => [
            0
        ],

        'AllDay'     => undef,
        'TimezoneID' => '2',
        'Recurring'  => undef,
        'TeamID'     => undef,
        'ParentID'   => '1289',
        'EndTime'    => '2016-05-30 10:00:00',

        'Location'    => 'Stara Pazova',
        'StartTime'   => '2016-05-30 09:00:00',
        'Description' => 'Test description'
    },
    {

        'AllDay'     => undef,
        'ResourceID' => [
            0
        ],
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 2 years',

        'EndTime'     => '2016-04-01 11:00:00',
        'Location'    => undef,
        'TeamID'      => undef,
        'ParentID'    => undef,
        'Description' => undef,
        'StartTime'   => '2016-04-01 10:00:00',
        'Recurring'   => '1',
        'TimezoneID'  => '2'
    },
    {
        'TimezoneID'  => '2',
        'Recurring'   => undef,
        'StartTime'   => '2018-04-01 10:00:00',
        'Description' => undef,
        'ParentID'    => '1314',
        'TeamID'      => undef,
        'EndTime'     => '2018-04-01 11:00:00',

        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 2 years',
        'ResourceID' => [
            0
        ],
        'AllDay' => undef,

    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 2 years',
        'ResourceID' => [
            0
        ],

        'AllDay'     => undef,
        'TimezoneID' => '2',
        'Recurring'  => undef,
        'ParentID'   => '1314',
        'TeamID'     => undef,

        'EndTime'     => '2020-04-01 11:00:00',
        'Location'    => undef,
        'StartTime'   => '2020-04-01 10:00:00',
        'Description' => undef
    },
    {
        'StartTime'   => '2016-04-02 00:00:00',
        'Description' => undef,
        'ParentID'    => undef,
        'TeamID'      => undef,

        'EndTime'    => '2016-04-03 00:00:00',
        'Location'   => undef,
        'Recurring'  => '1',
        'TimezoneID' => '0',
        'AllDay'     => '1',

        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 3thd all day',
        'ResourceID' => [
            0
            ]
    },
    {
        'ParentID' => '1317',
        'TeamID'   => undef,
        'Location' => undef,
        'EndTime'  => '2016-04-06 00:00:00',

        'StartTime'   => '2016-04-05 00:00:00',
        'Description' => undef,
        'TimezoneID'  => '0',
        'Recurring'   => undef,

        'AllDay'     => '1',
        'Title'      => 'Each 3thd all day',
        'CalendarID' => $Calendar{CalendarID},
        'ResourceID' => [
            0
            ]
    },
    {
        'ResourceID' => [
            0
        ],
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 3thd all day',

        'AllDay'     => '1',
        'TimezoneID' => '0',
        'Recurring'  => undef,
        'EndTime'    => '2016-04-09 00:00:00',

        'Location'    => undef,
        'TeamID'      => undef,
        'ParentID'    => '1317',
        'Description' => undef,
        'StartTime'   => '2016-04-08 00:00:00'
    },
    {
        'AllDay' => '1',

        'ResourceID' => [
            0
        ],
        'CalendarID'  => $Calendar{CalendarID},
        'Title'       => 'Each 3thd all day',
        'Description' => undef,
        'StartTime'   => '2016-04-11 00:00:00',
        'EndTime'     => '2016-04-12 00:00:00',
        'Location'    => undef,

        'ParentID'   => '1317',
        'TeamID'     => undef,
        'TimezoneID' => '0',
        'Recurring'  => undef
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 3thd all day',
        'ResourceID' => [
            0
        ],
        'AllDay' => '1',

        'Recurring'   => undef,
        'TimezoneID'  => '0',
        'StartTime'   => '2016-04-14 00:00:00',
        'Description' => undef,
        'ParentID'    => '1317',
        'TeamID'      => undef,
        'EndTime'     => '2016-04-15 00:00:00',

        'Location' => undef
    },
    {
        'EndTime' => '2016-04-18 00:00:00',

        'Location'    => undef,
        'TeamID'      => undef,
        'ParentID'    => '1317',
        'Description' => undef,
        'StartTime'   => '2016-04-17 00:00:00',
        'Recurring'   => undef,
        'TimezoneID'  => '0',

        'AllDay'     => '1',
        'ResourceID' => [
            0
        ],
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 3thd all day'
    },
    {
        'Recurring'  => undef,
        'TimezoneID' => '0',
        'Location'   => undef,
        'EndTime'    => '2016-04-21 00:00:00',

        'ParentID'    => '1317',
        'TeamID'      => undef,
        'Description' => undef,
        'StartTime'   => '2016-04-20 00:00:00',
        'ResourceID'  => [
            0
        ],
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 3thd all day',

        'AllDay' => '1'
    },
    {
        'EndTime' => '2016-04-24 00:00:00',

        'Location'    => undef,
        'ParentID'    => '1317',
        'TeamID'      => undef,
        'Description' => undef,
        'StartTime'   => '2016-04-23 00:00:00',
        'Recurring'   => undef,
        'TimezoneID'  => '0',

        'AllDay'     => '1',
        'ResourceID' => [
            0
        ],
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 3thd all day'
    },
    {
        'AllDay' => '1',

        'ResourceID' => [
            0
        ],
        'Title'       => 'Each 3thd all day',
        'CalendarID'  => $Calendar{CalendarID},
        'Description' => undef,
        'StartTime'   => '2016-04-26 00:00:00',
        'EndTime'     => '2016-04-27 00:00:00',
        'Location'    => undef,

        'ParentID'   => '1317',
        'TeamID'     => undef,
        'Recurring'  => undef,
        'TimezoneID' => '0'
    },
    {
        'TimezoneID'  => '0',
        'Recurring'   => undef,
        'StartTime'   => '2016-04-29 00:00:00',
        'Description' => undef,
        'ParentID'    => '1317',
        'TeamID'      => undef,
        'EndTime'     => '2016-04-30 00:00:00',
        'Location'    => undef,

        'Title'      => 'Each 3thd all day',
        'CalendarID' => $Calendar{CalendarID},
        'ResourceID' => [
            0
        ],
        'AllDay' => '1',

    },
    {
        'AllDay' => undef,

        'ResourceID' => [
            0
        ],
        'CalendarID'  => $Calendar{CalendarID},
        'Title'       => 'First 3 days',
        'Description' => undef,
        'StartTime'   => '2016-03-07 16:00:00',
        'EndTime'     => '2016-03-07 17:00:00',
        'Location'    => undef,

        'TeamID'     => undef,
        'ParentID'   => undef,
        'TimezoneID' => '2',
        'Recurring'  => '1'
    },
    {
        'Recurring'  => undef,
        'TimezoneID' => '2',
        'TeamID'     => undef,
        'ParentID'   => '1327',

        'EndTime'     => '2016-03-08 17:00:00',
        'Location'    => undef,
        'StartTime'   => '2016-03-08 16:00:00',
        'Description' => undef,
        'Title'       => 'First 3 days',
        'CalendarID'  => $Calendar{CalendarID},
        'ResourceID'  => [
            0
        ],

        'AllDay' => undef
    },
    {
        'Location' => undef,
        'EndTime'  => '2016-03-09 17:00:00',

        'TeamID'      => undef,
        'ParentID'    => '1327',
        'Description' => undef,
        'StartTime'   => '2016-03-09 16:00:00',
        'Recurring'   => undef,
        'TimezoneID'  => '2',

        'AllDay'     => undef,
        'ResourceID' => [
            0
        ],
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'First 3 days'
    },
    {
        'AllDay' => undef,

        'ResourceID' => [
            0
        ],
        'CalendarID'  => $Calendar{CalendarID},
        'Title'       => 'Once per next 2 month',
        'Description' => undef,
        'StartTime'   => '2016-03-02 18:00:00',
        'EndTime'     => '2016-03-02 19:00:00',

        'Location'   => undef,
        'TeamID'     => undef,
        'ParentID'   => undef,
        'TimezoneID' => '2',
        'Recurring'  => '1'
    },
    {
        'AllDay' => undef,

        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Once per next 2 month',
        'ResourceID' => [
            0
        ],
        'StartTime'   => '2016-04-02 18:00:00',
        'Description' => undef,
        'ParentID'    => '1330',
        'TeamID'      => undef,
        'Location'    => undef,
        'EndTime'     => '2016-04-02 19:00:00',

        'Recurring'  => undef,
        'TimezoneID' => '2'
    },
    {
        'TeamID'   => undef,
        'ParentID' => undef,
        'Location' => undef,
        'EndTime'  => '2016-01-03 19:00:00',

        'StartTime'   => '2016-01-03 18:00:00',
        'Description' => undef,
        'TimezoneID'  => '2',
        'Recurring'   => '1',

        'AllDay'     => undef,
        'Title'      => 'January 3th next 3 years',
        'CalendarID' => $Calendar{CalendarID},
        'ResourceID' => [
            0
            ]
    },
    {
        'Title'      => 'January 3th next 3 years',
        'CalendarID' => $Calendar{CalendarID},
        'ResourceID' => [
            0
        ],

        'AllDay'     => undef,
        'TimezoneID' => '2',
        'Recurring'  => undef,
        'ParentID'   => '1332',
        'TeamID'     => undef,
        'Location'   => undef,
        'EndTime'    => '2017-01-03 19:00:00',

        'StartTime'   => '2017-01-03 18:00:00',
        'Description' => undef
    },
    {
        'ResourceID' => [
            0
        ],
        'Title'      => 'January 3th next 3 years',
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,

        'Recurring'   => undef,
        'TimezoneID'  => '2',
        'Description' => undef,
        'StartTime'   => '2018-01-03 18:00:00',
        'EndTime'     => '2018-01-03 19:00:00',
        'Location'    => undef,

        'TeamID'   => undef,
        'ParentID' => '1332'
    },
    {
        'TeamID'   => undef,
        'ParentID' => undef,
        'EndTime'  => '2016-05-02 16:30:00',
        'Location' => 'Skype Video Call',

        'StartTime'   => '2016-05-02 16:00:00',
        'Description' => "Ein Einzeltermin des folgenden Sitzungstermins wurde ge\x{e4}ndert:

Betreff: R&D Team Weekly Strategy Call
Organisator: Martin Gruner <martin.gruner\@otrs.com>
Ort: Skype Video Call
Uhrzeit: Montag, 2. Mai 2016, 16:00:00 MESZ - 16:30:00 MESZ
Eingeladene Teilnehmer: Carlos Garcia <carlos.garcia\@otrs.com>, Carlos Rodriguez <carlos.rodriguez\@otrs.com>, Dusan Vuckovic <dusan.vuckovic\@otrs.com>, Jan Steinweg <jan.steinweg\@otrs.com>, Jaroslav Balaz <jaroslav.balaz\@otrs.com>, Jens Pfeifer <jens.pfeifer\@otrs.com>, Marc Bonsels <marc.bonsels\@otrs.com>, Marc Nilius <marc.nilius\@otrs.com>
*~*~*~*~*~*~*~*~*~*
",
        'TimezoneID' => '2',
        'Recurring'  => undef,

        'AllDay'     => undef,
        'Title'      => 'R&D Team Weekly Strategy Call',
        'CalendarID' => $Calendar{CalendarID},
        'ResourceID' => [
            0
            ]
    },
    {
        'Recurring'  => '1',
        'TimezoneID' => '2',
        'Location'   => undef,
        'EndTime'    => '2016-04-12 17:00:00',

        'ParentID'    => undef,
        'TeamID'      => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'StartTime'   => '2016-04-12 16:00:00',
        'ResourceID'  => [
            0
        ],
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 2nd week',

        'AllDay' => undef
    },
    {
        'TimezoneID'  => '2',
        'Recurring'   => undef,
        'StartTime'   => '2016-04-26 16:00:00',
        'Description' => 'Developer meeting each 2nd Tuesday',
        'ParentID'    => '1336',
        'TeamID'      => undef,

        'EndTime'    => '2016-04-26 17:00:00',
        'Location'   => undef,
        'Title'      => 'Each 2nd week',
        'CalendarID' => $Calendar{CalendarID},
        'ResourceID' => [
            0
        ],
        'AllDay' => undef,

    },
    {
        'ResourceID' => [
            0
        ],
        'Title'      => 'Each 2nd week',
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,

        'Recurring'   => undef,
        'TimezoneID'  => '2',
        'Description' => 'Developer meeting each 2nd Tuesday',
        'StartTime'   => '2016-05-10 16:00:00',
        'EndTime'     => '2016-05-10 17:00:00',
        'Location'    => undef,

        'ParentID' => '1336',
        'TeamID'   => undef
    },
    {
        'Title'      => 'Each 2nd week',
        'CalendarID' => $Calendar{CalendarID},
        'ResourceID' => [
            0
        ],
        'AllDay' => undef,

        'TimezoneID'  => '2',
        'Recurring'   => undef,
        'StartTime'   => '2016-05-24 16:00:00',
        'Description' => 'Developer meeting each 2nd Tuesday',
        'TeamID'      => undef,
        'ParentID'    => '1336',
        'Location'    => undef,
        'EndTime'     => '2016-05-24 17:00:00',

    },
    {
        'TimezoneID'  => '2',
        'Recurring'   => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'StartTime'   => '2016-06-07 16:00:00',

        'EndTime'    => '2016-06-07 17:00:00',
        'Location'   => undef,
        'ParentID'   => '1336',
        'TeamID'     => undef,
        'ResourceID' => [
            0
        ],
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 2nd week',
        'AllDay'     => undef,

    },
    {
        'TimezoneID' => '2',
        'Recurring'  => undef,
        'ParentID'   => '1336',
        'TeamID'     => undef,
        'EndTime'    => '2016-06-21 17:00:00',

        'Location'    => undef,
        'StartTime'   => '2016-06-21 16:00:00',
        'Description' => 'Developer meeting each 2nd Tuesday',
        'CalendarID'  => $Calendar{CalendarID},
        'Title'       => 'Each 2nd week',
        'ResourceID'  => [
            0
        ],

        'AllDay' => undef
    },
    {
        'ResourceID' => [
            0
        ],
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 2nd week',

        'AllDay'     => undef,
        'Recurring'  => undef,
        'TimezoneID' => '2',
        'Location'   => undef,
        'EndTime'    => '2016-07-05 17:00:00',

        'TeamID'      => undef,
        'ParentID'    => '1336',
        'Description' => 'Developer meeting each 2nd Tuesday',
        'StartTime'   => '2016-07-05 16:00:00'
    },
    {
        'StartTime'   => '2016-07-19 16:00:00',
        'Description' => 'Developer meeting each 2nd Tuesday',
        'ParentID'    => '1336',
        'TeamID'      => undef,
        'EndTime'     => '2016-07-19 17:00:00',
        'Location'    => undef,

        'Recurring'  => undef,
        'TimezoneID' => '2',
        'AllDay'     => undef,

        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 2nd week',
        'ResourceID' => [
            0
            ]
    },
    {
        'ResourceID' => [
            0
        ],
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 2nd week',
        'AllDay'     => undef,

        'Recurring'   => undef,
        'TimezoneID'  => '2',
        'Description' => 'Developer meeting each 2nd Tuesday',
        'StartTime'   => '2016-08-02 16:00:00',
        'Location'    => undef,
        'EndTime'     => '2016-08-02 17:00:00',

        'TeamID'   => undef,
        'ParentID' => '1336'
    },
    {
        'TimezoneID' => '2',
        'Recurring'  => undef,
        'EndTime'    => '2016-08-16 17:00:00',
        'Location'   => undef,

        'ParentID'    => '1336',
        'TeamID'      => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'StartTime'   => '2016-08-16 16:00:00',
        'ResourceID'  => [
            0
        ],
        'Title'      => 'Each 2nd week',
        'CalendarID' => $Calendar{CalendarID},

        'AllDay' => undef
    },
    {
        'StartTime'   => '2016-08-30 16:00:00',
        'Description' => 'Developer meeting each 2nd Tuesday',
        'ParentID'    => '1336',
        'TeamID'      => undef,

        'EndTime'    => '2016-08-30 17:00:00',
        'Location'   => undef,
        'TimezoneID' => '2',
        'Recurring'  => undef,
        'AllDay'     => undef,

        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 2nd week',
        'ResourceID' => [
            0
            ]
    },
    {
        'EndTime'  => '2016-09-13 17:00:00',
        'Location' => undef,

        'TeamID'      => undef,
        'ParentID'    => '1336',
        'Description' => 'Developer meeting each 2nd Tuesday',
        'StartTime'   => '2016-09-13 16:00:00',
        'TimezoneID'  => '2',
        'Recurring'   => undef,

        'AllDay'     => undef,
        'ResourceID' => [
            0
        ],
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 2nd week'
    },
    {
        'Recurring'  => undef,
        'TimezoneID' => '2',
        'Location'   => undef,
        'EndTime'    => '2016-09-27 17:00:00',

        'ParentID'    => '1336',
        'TeamID'      => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'StartTime'   => '2016-09-27 16:00:00',
        'ResourceID'  => [
            0
        ],
        'Title'      => 'Each 2nd week',
        'CalendarID' => $Calendar{CalendarID},

        'AllDay' => undef
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 2nd week',
        'ResourceID' => [
            0
        ],

        'AllDay'     => undef,
        'Recurring'  => undef,
        'TimezoneID' => '2',
        'ParentID'   => '1336',
        'TeamID'     => undef,
        'Location'   => undef,
        'EndTime'    => '2016-10-11 17:00:00',

        'StartTime'   => '2016-10-11 16:00:00',
        'Description' => 'Developer meeting each 2nd Tuesday'
    },
    {
        'StartTime'   => '2016-10-25 16:00:00',
        'Description' => 'Developer meeting each 2nd Tuesday',
        'TeamID'      => undef,
        'ParentID'    => '1336',
        'Location'    => undef,
        'EndTime'     => '2016-10-25 17:00:00',

        'TimezoneID' => '2',
        'Recurring'  => undef,
        'AllDay'     => undef,

        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 2nd week',
        'ResourceID' => [
            0
            ]
    },
    {
        'StartTime'   => '2016-11-08 16:00:00',
        'Description' => 'Developer meeting each 2nd Tuesday',
        'ParentID'    => '1336',
        'TeamID'      => undef,
        'Location'    => undef,
        'EndTime'     => '2016-11-08 17:00:00',

        'TimezoneID' => '2',
        'Recurring'  => undef,
        'AllDay'     => undef,

        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 2nd week',
        'ResourceID' => [
            0
            ]
    },
    {

        'AllDay'     => undef,
        'Title'      => 'Each 2nd week',
        'CalendarID' => $Calendar{CalendarID},
        'ResourceID' => [
            0
        ],
        'TeamID'   => undef,
        'ParentID' => '1336',
        'EndTime'  => '2016-11-22 17:00:00',

        'Location'    => undef,
        'StartTime'   => '2016-11-22 16:00:00',
        'Description' => 'Developer meeting each 2nd Tuesday',
        'TimezoneID'  => '2',
        'Recurring'   => undef
    },
    {
        'TeamID'   => undef,
        'ParentID' => '1336',
        'EndTime'  => '2016-12-06 17:00:00',

        'Location'    => undef,
        'StartTime'   => '2016-12-06 16:00:00',
        'Description' => 'Developer meeting each 2nd Tuesday',
        'Recurring'   => undef,
        'TimezoneID'  => '2',

        'AllDay'     => undef,
        'Title'      => 'Each 2nd week',
        'CalendarID' => $Calendar{CalendarID},
        'ResourceID' => [
            0
            ]
    },
    {
        'Description' => 'Developer meeting each 2nd Tuesday',
        'StartTime'   => '2016-12-20 16:00:00',
        'EndTime'     => '2016-12-20 17:00:00',
        'Location'    => undef,

        'ParentID'   => '1336',
        'TeamID'     => undef,
        'Recurring'  => undef,
        'TimezoneID' => '2',
        'AllDay'     => undef,

        'ResourceID' => [
            0
        ],
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 2nd week'
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
