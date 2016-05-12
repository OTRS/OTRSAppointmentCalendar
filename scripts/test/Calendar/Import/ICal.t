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
        'TeamID'   => undef,
        'Location' => 'Belgrade',
        'EndTime'  => '2016-04-12 12:00:00',
        'ParentID' => undef,

        'Description' => 'Only once per week',
        'ResourceID'  => [
            0
        ],
        'StartTime'  => '2016-04-12 11:30:00',
        'Recurring'  => '1',
        'TimezoneID' => '2',
        'Title'      => 'Once per week',

        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef
    },
    {
        'ResourceID' => [
            0
        ],
        'Description' => 'Once per month',
        'ParentID'    => undef,

        'Location'   => 'Germany',
        'TeamID'     => undef,
        'EndTime'    => '2016-04-12 14:00:00',
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'Title'      => 'Monthly meeting',

        'TimezoneID' => '2',
        'StartTime'  => '2016-04-12 13:15:00',
        'Recurring'  => '1'
    },
    {
        'ResourceID' => [
            0
        ],
        'Description' => undef,

        'ParentID'   => undef,
        'EndTime'    => '2016-03-31 09:00:00',
        'TeamID'     => undef,
        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,

        'Title'      => 'End of the month',
        'TimezoneID' => '2',
        'Recurring'  => '1',
        'StartTime'  => '2016-03-31 08:00:00'
    },
    {
        'ResourceID' => [
            0
        ],
        'Description' => 'Developer meeting each 2nd Tuesday',
        'ParentID'    => undef,

        'TeamID'     => undef,
        'Location'   => undef,
        'EndTime'    => '2016-04-12 17:00:00',
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'Title'      => 'Each 2nd week',

        'TimezoneID' => '2',
        'StartTime'  => '2016-04-12 16:00:00',
        'Recurring'  => '1'
    },
    {
        'ParentID' => undef,

        'EndTime'    => '2016-01-31 11:00:00',
        'TeamID'     => undef,
        'Location'   => 'Test',
        'ResourceID' => [
            0
        ],
        'Description' => 'test',
        'TimezoneID'  => '2',
        'StartTime'   => '2016-01-31 10:00:00',
        'Recurring'   => '1',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'Title'       => 'Each 2 months',

    },
    {
        'Description' => 'Test description',
        'ResourceID'  => [
            0
        ],
        'TeamID'   => undef,
        'Location' => 'Stara Pazova',
        'EndTime'  => '2016-04-12 10:00:00',
        'ParentID' => undef,

        'Title' => 'My event',

        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'StartTime'  => '2016-04-12 09:00:00',
        'Recurring'  => '1',
        'TimezoneID' => '2'
    },
    {
        'Description' => undef,
        'ResourceID'  => [
            0
        ],
        'TeamID'   => undef,
        'Location' => undef,
        'EndTime'  => '2016-04-01 11:00:00',
        'ParentID' => undef,

        'Title' => 'Each 2 years',

        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'StartTime'  => '2016-04-01 10:00:00',
        'Recurring'  => '1',
        'TimezoneID' => '2'
    },
    {
        'Recurring'  => undef,
        'StartTime'  => '2016-04-05 00:00:00',
        'TimezoneID' => '0',

        'Title'      => 'All day',
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => '1',
        'TeamID'     => undef,
        'Location'   => undef,
        'EndTime'    => '2016-04-06 00:00:00',

        'ParentID'    => undef,
        'Description' => 'test all day event',
        'ResourceID'  => [
            0
            ]
    },
    {
        'Location' => 'Belgrade',
        'TeamID'   => undef,
        'EndTime'  => '2016-04-19 12:00:00',
        'ParentID' => '3325',

        'Description' => 'Only once per week',
        'ResourceID'  => [
            0
        ],
        'StartTime'  => '2016-04-19 11:30:00',
        'Recurring'  => undef,
        'TimezoneID' => '2',
        'Title'      => 'Once per week',

        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef
    },
    {
        'Title' => 'Once per week',

        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'StartTime'   => '2016-04-26 11:30:00',
        'Recurring'   => undef,
        'TimezoneID'  => '2',
        'Description' => 'Only once per week',
        'ResourceID'  => [
            0
        ],
        'Location' => 'Belgrade',
        'TeamID'   => undef,
        'EndTime'  => '2016-04-26 12:00:00',
        'ParentID' => '3325',

    },
    {

        'ParentID'   => '3325',
        'TeamID'     => undef,
        'EndTime'    => '2016-05-03 12:00:00',
        'Location'   => 'Belgrade',
        'ResourceID' => [
            0
        ],
        'Description' => 'Only once per week',
        'TimezoneID'  => '2',
        'Recurring'   => undef,
        'StartTime'   => '2016-05-03 11:30:00',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,

        'Title' => 'Once per week'
    },
    {
        'ResourceID' => [
            0
        ],
        'Description' => 'Only once per week',
        'ParentID'    => '3325',

        'EndTime'    => '2016-05-10 12:00:00',
        'TeamID'     => undef,
        'Location'   => 'Belgrade',
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Once per week',

        'TimezoneID' => '2',
        'StartTime'  => '2016-05-10 11:30:00',
        'Recurring'  => undef
    },
    {
        'TeamID'   => undef,
        'EndTime'  => '2016-05-17 12:00:00',
        'Location' => 'Belgrade',
        'ParentID' => '3325',

        'Description' => 'Only once per week',
        'ResourceID'  => [
            0
        ],
        'StartTime'  => '2016-05-17 11:30:00',
        'Recurring'  => undef,
        'TimezoneID' => '2',

        'Title'      => 'Once per week',
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'TimezoneID' => '2',
        'StartTime'  => '2016-05-24 11:30:00',
        'Recurring'  => undef,
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'Title'      => 'Once per week',

        'ParentID' => '3325',

        'TeamID'     => undef,
        'Location'   => 'Belgrade',
        'EndTime'    => '2016-05-24 12:00:00',
        'ResourceID' => [
            0
        ],
        'Description' => 'Only once per week'
    },
    {
        'Description' => 'Only once per week',
        'ResourceID'  => [
            0
        ],
        'Location' => 'Belgrade',
        'TeamID'   => undef,
        'EndTime'  => '2016-05-31 12:00:00',

        'ParentID' => '3325',

        'Title'      => 'Once per week',
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'Recurring'  => undef,
        'StartTime'  => '2016-05-31 11:30:00',
        'TimezoneID' => '2'
    },
    {
        'Description' => 'Only once per week',
        'ResourceID'  => [
            0
        ],
        'TeamID'   => undef,
        'Location' => 'Belgrade',
        'EndTime'  => '2016-06-07 12:00:00',

        'ParentID' => '3325',
        'Title'    => 'Once per week',

        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'Recurring'  => undef,
        'StartTime'  => '2016-06-07 11:30:00',
        'TimezoneID' => '2'
    },
    {
        'Title' => 'Monthly meeting',

        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'Recurring'   => undef,
        'StartTime'   => '2016-05-12 13:15:00',
        'TimezoneID'  => '2',
        'Description' => 'Once per month',
        'ResourceID'  => [
            0
        ],
        'Location' => 'Germany',
        'TeamID'   => undef,
        'EndTime'  => '2016-05-12 14:00:00',

        'ParentID' => '3334'
    },
    {
        'Description' => 'Once per month',
        'ResourceID'  => [
            0
        ],
        'Location' => 'Germany',
        'TeamID'   => undef,
        'EndTime'  => '2016-06-12 14:00:00',

        'ParentID' => '3334',

        'Title'      => 'Monthly meeting',
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'Recurring'  => undef,
        'StartTime'  => '2016-06-12 13:15:00',
        'TimezoneID' => '2'
    },
    {
        'EndTime'  => '2016-07-12 14:00:00',
        'TeamID'   => undef,
        'Location' => 'Germany',

        'ParentID'    => '3334',
        'Description' => 'Once per month',
        'ResourceID'  => [
            0
        ],
        'Recurring'  => undef,
        'StartTime'  => '2016-07-12 13:15:00',
        'TimezoneID' => '2',

        'Title'      => 'Monthly meeting',
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef
    },
    {

        'Title'       => 'Monthly meeting',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'Recurring'   => undef,
        'StartTime'   => '2016-08-12 13:15:00',
        'TimezoneID'  => '2',
        'Description' => 'Once per month',
        'ResourceID'  => [
            0
        ],
        'TeamID'   => undef,
        'EndTime'  => '2016-08-12 14:00:00',
        'Location' => 'Germany',

        'ParentID' => '3334'
    },
    {
        'TeamID'   => undef,
        'EndTime'  => '2016-09-12 14:00:00',
        'Location' => 'Germany',
        'ParentID' => '3334',

        'Description' => 'Once per month',
        'ResourceID'  => [
            0
        ],
        'StartTime'  => '2016-09-12 13:15:00',
        'Recurring'  => undef,
        'TimezoneID' => '2',
        'Title'      => 'Monthly meeting',

        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'Description' => 'Once per month',
        'ResourceID'  => [
            0
        ],
        'TeamID'   => undef,
        'Location' => 'Germany',
        'EndTime'  => '2016-10-12 14:00:00',

        'ParentID' => '3334',
        'Title'    => 'Monthly meeting',

        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'Recurring'  => undef,
        'StartTime'  => '2016-10-12 13:15:00',
        'TimezoneID' => '2'
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,

        'Title'      => 'Monthly meeting',
        'TimezoneID' => '2',
        'StartTime'  => '2016-11-12 13:15:00',
        'Recurring'  => undef,
        'ResourceID' => [
            0
        ],
        'Description' => 'Once per month',
        'ParentID'    => '3334',

        'TeamID'   => undef,
        'EndTime'  => '2016-11-12 14:00:00',
        'Location' => 'Germany'
    },
    {

        'Title'       => 'Monthly meeting',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'StartTime'   => '2016-12-12 13:15:00',
        'Recurring'   => undef,
        'TimezoneID'  => '2',
        'Description' => 'Once per month',
        'ResourceID'  => [
            0
        ],
        'Location' => 'Germany',
        'TeamID'   => undef,
        'EndTime'  => '2016-12-12 14:00:00',
        'ParentID' => '3334',

    },
    {
        'TeamID'   => undef,
        'EndTime'  => '2017-01-12 14:00:00',
        'Location' => 'Germany',
        'ParentID' => '3334',

        'Description' => 'Once per month',
        'ResourceID'  => [
            0
        ],
        'StartTime'  => '2017-01-12 13:15:00',
        'Recurring'  => undef,
        'TimezoneID' => '2',

        'Title'      => 'Monthly meeting',
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef
    },
    {
        'ParentID' => '3334',

        'EndTime'    => '2017-02-12 14:00:00',
        'TeamID'     => undef,
        'Location'   => 'Germany',
        'ResourceID' => [
            0
        ],
        'Description' => 'Once per month',
        'TimezoneID'  => '2',
        'StartTime'   => '2017-02-12 13:15:00',
        'Recurring'   => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'Title'       => 'Monthly meeting',

    },
    {
        'Description' => undef,
        'ResourceID'  => [
            0
        ],
        'Location' => undef,
        'TeamID'   => undef,
        'EndTime'  => '2016-04-30 09:00:00',

        'ParentID' => '3658',
        'Title'    => 'End of the month',

        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'Recurring'  => undef,
        'StartTime'  => '2016-04-30 08:00:00',
        'TimezoneID' => '2'
    },
    {
        'EndTime'  => '2016-05-31 09:00:00',
        'TeamID'   => undef,
        'Location' => undef,
        'ParentID' => '3658',

        'Description' => undef,
        'ResourceID'  => [
            0
        ],
        'StartTime'  => '2016-05-31 08:00:00',
        'Recurring'  => undef,
        'TimezoneID' => '2',
        'Title'      => 'End of the month',

        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'Description' => undef,
        'ResourceID'  => [
            0
        ],
        'EndTime'  => '2016-06-30 09:00:00',
        'TeamID'   => undef,
        'Location' => undef,
        'ParentID' => '3658',

        'Title'      => 'End of the month',
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'StartTime'  => '2016-06-30 08:00:00',
        'Recurring'  => undef,
        'TimezoneID' => '2'
    },
    {
        'Title' => 'End of the month',

        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'Recurring'   => undef,
        'StartTime'   => '2016-07-31 08:00:00',
        'TimezoneID'  => '2',
        'Description' => undef,
        'ResourceID'  => [
            0
        ],
        'EndTime'  => '2016-07-31 09:00:00',
        'TeamID'   => undef,
        'Location' => undef,

        'ParentID' => '3658'
    },
    {
        'TimezoneID' => '2',
        'StartTime'  => '2016-08-31 08:00:00',
        'Recurring'  => undef,
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'End of the month',

        'ParentID' => '3658',

        'EndTime'    => '2016-08-31 09:00:00',
        'TeamID'     => undef,
        'Location'   => undef,
        'ResourceID' => [
            0
        ],
        'Description' => undef
    },
    {
        'ResourceID' => [
            0
        ],
        'Description' => undef,
        'ParentID'    => '3658',

        'TeamID'     => undef,
        'Location'   => undef,
        'EndTime'    => '2016-09-30 09:00:00',
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'End of the month',

        'TimezoneID' => '2',
        'StartTime'  => '2016-09-30 08:00:00',
        'Recurring'  => undef
    },
    {
        'Title' => 'End of the month',

        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'StartTime'   => '2016-10-31 08:00:00',
        'Recurring'   => undef,
        'TimezoneID'  => '2',
        'Description' => undef,
        'ResourceID'  => [
            0
        ],
        'Location' => undef,
        'TeamID'   => undef,
        'EndTime'  => '2016-10-31 09:00:00',
        'ParentID' => '3658',

    },
    {
        'ResourceID' => [
            0
        ],
        'Description' => undef,
        'ParentID'    => '3658',

        'TeamID'     => undef,
        'EndTime'    => '2016-11-30 09:00:00',
        'Location'   => undef,
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},

        'Title'      => 'End of the month',
        'TimezoneID' => '2',
        'StartTime'  => '2016-11-30 08:00:00',
        'Recurring'  => undef
    },
    {
        'Recurring'  => undef,
        'StartTime'  => '2016-12-31 08:00:00',
        'TimezoneID' => '2',

        'Title'      => 'End of the month',
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => undef,
        'Location'   => undef,
        'EndTime'    => '2016-12-31 09:00:00',

        'ParentID'    => '3658',
        'Description' => undef,
        'ResourceID'  => [
            0
            ]
    },
    {

        'Title'       => 'End of the month',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'Recurring'   => undef,
        'StartTime'   => '2017-01-31 08:00:00',
        'TimezoneID'  => '2',
        'Description' => undef,
        'ResourceID'  => [
            0
        ],
        'EndTime'  => '2017-01-31 09:00:00',
        'TeamID'   => undef,
        'Location' => undef,

        'ParentID' => '3658'
    },
    {
        'StartTime'  => '2017-02-28 08:00:00',
        'Recurring'  => undef,
        'TimezoneID' => '2',
        'Title'      => 'End of the month',

        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => undef,
        'Location'   => undef,
        'EndTime'    => '2017-02-28 09:00:00',
        'ParentID'   => '3658',

        'Description' => undef,
        'ResourceID'  => [
            0
            ]
    },
    {

        'Title'       => 'Each 2 months',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'Recurring'   => undef,
        'StartTime'   => '2016-03-31 10:00:00',
        'TimezoneID'  => '2',
        'Description' => 'test',
        'ResourceID'  => [
            0
        ],
        'TeamID'   => undef,
        'EndTime'  => '2016-03-31 11:00:00',
        'Location' => 'Test',

        'ParentID' => '4023'
    },
    {
        'Title' => 'Each 2 months',

        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'Recurring'   => undef,
        'StartTime'   => '2016-05-31 10:00:00',
        'TimezoneID'  => '2',
        'Description' => 'test',
        'ResourceID'  => [
            0
        ],
        'EndTime'  => '2016-05-31 11:00:00',
        'TeamID'   => undef,
        'Location' => 'Test',

        'ParentID' => '4023'
    },
    {
        'EndTime'  => '2016-07-31 11:00:00',
        'TeamID'   => undef,
        'Location' => 'Test',

        'ParentID'    => '4023',
        'Description' => 'test',
        'ResourceID'  => [
            0
        ],
        'Recurring'  => undef,
        'StartTime'  => '2016-07-31 10:00:00',
        'TimezoneID' => '2',

        'Title'      => 'Each 2 months',
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'ResourceID' => [
            0
        ],
        'Description' => 'test',
        'ParentID'    => '4023',

        'Location'   => 'Test',
        'TeamID'     => undef,
        'EndTime'    => '2016-09-30 11:00:00',
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},

        'Title'      => 'Each 2 months',
        'TimezoneID' => '2',
        'StartTime'  => '2016-09-30 10:00:00',
        'Recurring'  => undef
    },
    {
        'StartTime'  => '2016-11-30 10:00:00',
        'Recurring'  => undef,
        'TimezoneID' => '2',
        'Title'      => 'Each 2 months',

        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'Location'   => 'Test',
        'TeamID'     => undef,
        'EndTime'    => '2016-11-30 11:00:00',
        'ParentID'   => '4023',

        'Description' => 'test',
        'ResourceID'  => [
            0
            ]
    },
    {
        'TimezoneID' => '2',
        'Recurring'  => undef,
        'StartTime'  => '2017-01-31 10:00:00',
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'Title'      => 'Each 2 months',

        'ParentID'   => '4023',
        'EndTime'    => '2017-01-31 11:00:00',
        'TeamID'     => undef,
        'Location'   => 'Test',
        'ResourceID' => [
            0
        ],
        'Description' => 'test'
    },
    {
        'Description' => 'Test description',
        'ResourceID'  => [
            0
        ],
        'Location' => 'Stara Pazova',
        'TeamID'   => undef,
        'EndTime'  => '2016-04-14 10:00:00',

        'ParentID' => '4207',
        'Title'    => 'My event',

        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'Recurring'  => undef,
        'StartTime'  => '2016-04-14 09:00:00',
        'TimezoneID' => '2'
    },
    {
        'Recurring'  => undef,
        'StartTime'  => '2016-04-16 09:00:00',
        'TimezoneID' => '2',

        'Title'      => 'My event',
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'TeamID'     => undef,
        'EndTime'    => '2016-04-16 10:00:00',
        'Location'   => 'Stara Pazova',

        'ParentID'    => '4207',
        'Description' => 'Test description',
        'ResourceID'  => [
            0
            ]
    },
    {
        'Location' => 'Stara Pazova',
        'TeamID'   => undef,
        'EndTime'  => '2016-04-18 10:00:00',
        'ParentID' => '4207',

        'Description' => 'Test description',
        'ResourceID'  => [
            0
        ],
        'StartTime'  => '2016-04-18 09:00:00',
        'Recurring'  => undef,
        'TimezoneID' => '2',
        'Title'      => 'My event',

        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,

        'Title'      => 'My event',
        'TimezoneID' => '2',
        'StartTime'  => '2016-04-20 09:00:00',
        'Recurring'  => undef,
        'ResourceID' => [
            0
        ],
        'Description' => 'Test description',
        'ParentID'    => '4207',

        'TeamID'   => undef,
        'EndTime'  => '2016-04-20 10:00:00',
        'Location' => 'Stara Pazova'
    },
    {
        'ResourceID' => [
            0
        ],
        'Description' => 'Test description',

        'ParentID'   => '4207',
        'EndTime'    => '2016-04-22 10:00:00',
        'TeamID'     => undef,
        'Location'   => 'Stara Pazova',
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'My event',

        'TimezoneID' => '2',
        'Recurring'  => undef,
        'StartTime'  => '2016-04-22 09:00:00'
    },
    {
        'ParentID' => '4207',

        'EndTime'    => '2016-04-24 10:00:00',
        'TeamID'     => undef,
        'Location'   => 'Stara Pazova',
        'ResourceID' => [
            0
        ],
        'Description' => 'Test description',
        'TimezoneID'  => '2',
        'StartTime'   => '2016-04-24 09:00:00',
        'Recurring'   => undef,
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},

        'Title' => 'My event'
    },
    {
        'Location' => 'Stara Pazova',
        'TeamID'   => undef,
        'EndTime'  => '2016-04-26 10:00:00',
        'ParentID' => '4207',

        'Description' => 'Test description',
        'ResourceID'  => [
            0
        ],
        'StartTime'  => '2016-04-26 09:00:00',
        'Recurring'  => undef,
        'TimezoneID' => '2',
        'Title'      => 'My event',

        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
    },
    {

        'Title'       => 'My event',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'Recurring'   => undef,
        'StartTime'   => '2016-04-28 09:00:00',
        'TimezoneID'  => '2',
        'Description' => 'Test description',
        'ResourceID'  => [
            0
        ],
        'Location' => 'Stara Pazova',
        'TeamID'   => undef,
        'EndTime'  => '2016-04-28 10:00:00',

        'ParentID' => '4207'
    },
    {
        'TimezoneID' => '2',
        'StartTime'  => '2016-04-30 09:00:00',
        'Recurring'  => undef,
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'My event',

        'ParentID' => '4207',

        'Location'   => 'Stara Pazova',
        'TeamID'     => undef,
        'EndTime'    => '2016-04-30 10:00:00',
        'ResourceID' => [
            0
        ],
        'Description' => 'Test description'
    },
    {
        'ResourceID' => [
            0
        ],
        'Description' => 'Test description',
        'ParentID'    => '4207',

        'EndTime'    => '2016-05-02 10:00:00',
        'TeamID'     => undef,
        'Location'   => 'Stara Pazova',
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,

        'Title'      => 'My event',
        'TimezoneID' => '2',
        'StartTime'  => '2016-05-02 09:00:00',
        'Recurring'  => undef
    },
    {
        'TimezoneID' => '2',
        'StartTime'  => '2016-05-04 09:00:00',
        'Recurring'  => undef,
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'Title'      => 'My event',

        'ParentID' => '4207',

        'TeamID'     => undef,
        'EndTime'    => '2016-05-04 10:00:00',
        'Location'   => 'Stara Pazova',
        'ResourceID' => [
            0
        ],
        'Description' => 'Test description'
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'Title'      => 'My event',

        'TimezoneID' => '2',
        'StartTime'  => '2016-05-06 09:00:00',
        'Recurring'  => undef,
        'ResourceID' => [
            0
        ],
        'Description' => 'Test description',
        'ParentID'    => '4207',

        'EndTime'  => '2016-05-06 10:00:00',
        'TeamID'   => undef,
        'Location' => 'Stara Pazova'
    },
    {

        'ParentID'   => '4207',
        'TeamID'     => undef,
        'Location'   => 'Stara Pazova',
        'EndTime'    => '2016-05-08 10:00:00',
        'ResourceID' => [
            0
        ],
        'Description' => 'Test description',
        'TimezoneID'  => '2',
        'Recurring'   => undef,
        'StartTime'   => '2016-05-08 09:00:00',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'Title'       => 'My event',

    },
    {

        'Title'       => 'My event',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'Recurring'   => undef,
        'StartTime'   => '2016-05-10 09:00:00',
        'TimezoneID'  => '2',
        'Description' => 'Test description',
        'ResourceID'  => [
            0
        ],
        'TeamID'   => undef,
        'EndTime'  => '2016-05-10 10:00:00',
        'Location' => 'Stara Pazova',

        'ParentID' => '4207'
    },
    {
        'Recurring'  => undef,
        'StartTime'  => '2016-05-12 09:00:00',
        'TimezoneID' => '2',

        'Title'      => 'My event',
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => undef,
        'EndTime'    => '2016-05-12 10:00:00',
        'Location'   => 'Stara Pazova',

        'ParentID'    => '4207',
        'Description' => 'Test description',
        'ResourceID'  => [
            0
            ]
    },
    {
        'Description' => 'Test description',
        'ResourceID'  => [
            0
        ],
        'TeamID'   => undef,
        'Location' => 'Stara Pazova',
        'EndTime'  => '2016-05-14 10:00:00',

        'ParentID' => '4207',
        'Title'    => 'My event',

        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'Recurring'  => undef,
        'StartTime'  => '2016-05-14 09:00:00',
        'TimezoneID' => '2'
    },
    {
        'TimezoneID' => '2',
        'StartTime'  => '2016-05-16 09:00:00',
        'Recurring'  => undef,
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},

        'Title'    => 'My event',
        'ParentID' => '4207',

        'TeamID'     => undef,
        'Location'   => 'Stara Pazova',
        'EndTime'    => '2016-05-16 10:00:00',
        'ResourceID' => [
            0
        ],
        'Description' => 'Test description'
    },
    {
        'TeamID'   => undef,
        'Location' => 'Stara Pazova',
        'EndTime'  => '2016-05-18 10:00:00',
        'ParentID' => '4207',

        'Description' => 'Test description',
        'ResourceID'  => [
            0
        ],
        'StartTime'  => '2016-05-18 09:00:00',
        'Recurring'  => undef,
        'TimezoneID' => '2',
        'Title'      => 'My event',

        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef
    },
    {
        'ResourceID' => [
            0
        ],
        'Description' => 'Test description',
        'ParentID'    => '4207',

        'TeamID'     => undef,
        'Location'   => 'Stara Pazova',
        'EndTime'    => '2016-05-20 10:00:00',
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},

        'Title'      => 'My event',
        'TimezoneID' => '2',
        'StartTime'  => '2016-05-20 09:00:00',
        'Recurring'  => undef
    },
    {
        'ResourceID' => [
            0
        ],
        'Description' => 'Test description',
        'ParentID'    => '4207',

        'EndTime'    => '2016-05-22 10:00:00',
        'TeamID'     => undef,
        'Location'   => 'Stara Pazova',
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'Title'      => 'My event',

        'TimezoneID' => '2',
        'StartTime'  => '2016-05-22 09:00:00',
        'Recurring'  => undef
    },
    {
        'TimezoneID' => '2',
        'Recurring'  => undef,
        'StartTime'  => '2016-05-24 09:00:00',
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'My event',

        'ParentID'   => '4207',
        'EndTime'    => '2016-05-24 10:00:00',
        'TeamID'     => undef,
        'Location'   => 'Stara Pazova',
        'ResourceID' => [
            0
        ],
        'Description' => 'Test description'
    },
    {
        'Description' => 'Test description',
        'ResourceID'  => [
            0
        ],
        'EndTime'  => '2016-05-26 10:00:00',
        'TeamID'   => undef,
        'Location' => 'Stara Pazova',
        'ParentID' => '4207',

        'Title'      => 'My event',
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'StartTime'  => '2016-05-26 09:00:00',
        'Recurring'  => undef,
        'TimezoneID' => '2'
    },
    {

        'ParentID'   => '4207',
        'Location'   => 'Stara Pazova',
        'TeamID'     => undef,
        'EndTime'    => '2016-05-28 10:00:00',
        'ResourceID' => [
            0
        ],
        'Description' => 'Test description',
        'TimezoneID'  => '2',
        'Recurring'   => undef,
        'StartTime'   => '2016-05-28 09:00:00',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},

        'Title' => 'My event'
    },
    {
        'Title' => 'My event',

        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'StartTime'   => '2016-05-30 09:00:00',
        'Recurring'   => undef,
        'TimezoneID'  => '2',
        'Description' => 'Test description',
        'ResourceID'  => [
            0
        ],
        'TeamID'   => undef,
        'EndTime'  => '2016-05-30 10:00:00',
        'Location' => 'Stara Pazova',
        'ParentID' => '4207',

    },
    {
        'TimezoneID' => '2',
        'Recurring'  => undef,
        'StartTime'  => '2018-04-01 10:00:00',
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},

        'Title' => 'Each 2 years',

        'ParentID'   => '4232',
        'EndTime'    => '2018-04-01 11:00:00',
        'TeamID'     => undef,
        'Location'   => undef,
        'ResourceID' => [
            0
        ],
        'Description' => undef
    },
    {
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 2 years',

        'TimezoneID' => '2',
        'Recurring'  => undef,
        'StartTime'  => '2020-04-01 10:00:00',
        'ResourceID' => [
            0
        ],
        'Description' => undef,

        'ParentID' => '4232',
        'Location' => undef,
        'TeamID'   => undef,
        'EndTime'  => '2020-04-01 11:00:00'
    },
    {
        'TimezoneID' => '0',
        'Recurring'  => '1',
        'StartTime'  => '2016-04-02 00:00:00',
        'AllDay'     => '1',
        'CalendarID' => $Calendar{CalendarID},

        'Title' => 'Each 3thd all day',

        'ParentID'   => undef,
        'EndTime'    => '2016-04-03 00:00:00',
        'TeamID'     => undef,
        'Location'   => undef,
        'ResourceID' => [
            0
        ],
        'Description' => undef
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => '1',

        'Title'      => 'Each 3thd all day',
        'TimezoneID' => '0',
        'Recurring'  => undef,
        'StartTime'  => '2016-04-05 00:00:00',
        'ResourceID' => [
            0
        ],
        'Description' => undef,

        'ParentID' => '5476',
        'TeamID'   => undef,
        'EndTime'  => '2016-04-06 00:00:00',
        'Location' => undef
    },
    {

        'Title'       => 'Each 3thd all day',
        'AllDay'      => '1',
        'CalendarID'  => $Calendar{CalendarID},
        'StartTime'   => '2016-04-08 00:00:00',
        'Recurring'   => undef,
        'TimezoneID'  => '0',
        'Description' => undef,
        'ResourceID'  => [
            0
        ],
        'EndTime'  => '2016-04-09 00:00:00',
        'TeamID'   => undef,
        'Location' => undef,
        'ParentID' => '5476',

    },
    {

        'ParentID'   => '5476',
        'EndTime'    => '2016-04-12 00:00:00',
        'TeamID'     => undef,
        'Location'   => undef,
        'ResourceID' => [
            0
        ],
        'Description' => undef,
        'TimezoneID'  => '0',
        'Recurring'   => undef,
        'StartTime'   => '2016-04-11 00:00:00',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => '1',
        'Title'       => 'Each 3thd all day',

    },
    {
        'Description' => undef,
        'ResourceID'  => [
            0
        ],
        'EndTime'  => '2016-04-15 00:00:00',
        'TeamID'   => undef,
        'Location' => undef,

        'ParentID' => '5476',
        'Title'    => 'Each 3thd all day',

        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => '1',
        'Recurring'  => undef,
        'StartTime'  => '2016-04-14 00:00:00',
        'TimezoneID' => '0'
    },
    {
        'Description' => undef,
        'ResourceID'  => [
            0
        ],
        'TeamID'   => undef,
        'EndTime'  => '2016-04-18 00:00:00',
        'Location' => undef,

        'ParentID' => '5476',
        'Title'    => 'Each 3thd all day',

        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => '1',
        'Recurring'  => undef,
        'StartTime'  => '2016-04-17 00:00:00',
        'TimezoneID' => '0'
    },
    {
        'StartTime'  => '2016-04-20 00:00:00',
        'Recurring'  => undef,
        'TimezoneID' => '0',

        'Title'      => 'Each 3thd all day',
        'AllDay'     => '1',
        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => undef,
        'EndTime'    => '2016-04-21 00:00:00',
        'Location'   => undef,
        'ParentID'   => '5476',

        'Description' => undef,
        'ResourceID'  => [
            0
            ]
    },
    {
        'ParentID' => '5476',

        'Location'   => undef,
        'TeamID'     => undef,
        'EndTime'    => '2016-04-24 00:00:00',
        'ResourceID' => [
            0
        ],
        'Description' => undef,
        'TimezoneID'  => '0',
        'StartTime'   => '2016-04-23 00:00:00',
        'Recurring'   => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => '1',
        'Title'       => 'Each 3thd all day',

    },
    {
        'TimezoneID' => '0',
        'StartTime'  => '2016-04-26 00:00:00',
        'Recurring'  => undef,
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => '1',
        'Title'      => 'Each 3thd all day',

        'ParentID' => '5476',

        'Location'   => undef,
        'TeamID'     => undef,
        'EndTime'    => '2016-04-27 00:00:00',
        'ResourceID' => [
            0
        ],
        'Description' => undef
    },
    {
        'StartTime'  => '2016-04-29 00:00:00',
        'Recurring'  => undef,
        'TimezoneID' => '0',

        'Title'      => 'Each 3thd all day',
        'AllDay'     => '1',
        'CalendarID' => $Calendar{CalendarID},
        'EndTime'    => '2016-04-30 00:00:00',
        'TeamID'     => undef,
        'Location'   => undef,
        'ParentID'   => '5476',

        'Description' => undef,
        'ResourceID'  => [
            0
            ]
    },
    {
        'TeamID'   => undef,
        'EndTime'  => '2016-03-07 17:00:00',
        'Location' => undef,
        'ParentID' => undef,

        'Description' => undef,
        'ResourceID'  => [
            0
        ],
        'StartTime'  => '2016-03-07 16:00:00',
        'Recurring'  => '1',
        'TimezoneID' => '2',

        'Title'      => 'First 3 days',
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'ParentID' => '5486',

        'TeamID'     => undef,
        'Location'   => undef,
        'EndTime'    => '2016-03-08 17:00:00',
        'ResourceID' => [
            0
        ],
        'Description' => undef,
        'TimezoneID'  => '2',
        'StartTime'   => '2016-03-08 16:00:00',
        'Recurring'   => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,

        'Title' => 'First 3 days'
    },
    {
        'Location' => undef,
        'TeamID'   => undef,
        'EndTime'  => '2016-03-09 17:00:00',
        'ParentID' => '5486',

        'Description' => undef,
        'ResourceID'  => [
            0
        ],
        'StartTime'  => '2016-03-09 16:00:00',
        'Recurring'  => undef,
        'TimezoneID' => '2',
        'Title'      => 'First 3 days',

        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'TimezoneID' => '2',
        'Recurring'  => '1',
        'StartTime'  => '2016-03-02 18:00:00',
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,

        'Title' => 'Once per next 2 month',

        'ParentID'   => undef,
        'TeamID'     => undef,
        'Location'   => undef,
        'EndTime'    => '2016-03-02 19:00:00',
        'ResourceID' => [
            0
        ],
        'Description' => undef
    },
    {
        'TimezoneID' => '2',
        'Recurring'  => undef,
        'StartTime'  => '2016-04-02 18:00:00',
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},

        'Title' => 'Once per next 2 month',

        'ParentID'   => '5489',
        'Location'   => undef,
        'TeamID'     => undef,
        'EndTime'    => '2016-04-02 19:00:00',
        'ResourceID' => [
            0
        ],
        'Description' => undef
    },
    {

        'Title'       => 'January 3th next 3 years',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'StartTime'   => '2016-01-03 18:00:00',
        'Recurring'   => '1',
        'TimezoneID'  => '2',
        'Description' => undef,
        'ResourceID'  => [
            0
        ],
        'TeamID'   => undef,
        'Location' => undef,
        'EndTime'  => '2016-01-03 19:00:00',
        'ParentID' => undef,

    },
    {
        'TeamID'   => undef,
        'EndTime'  => '2017-01-03 19:00:00',
        'Location' => undef,

        'ParentID'    => '5491',
        'Description' => undef,
        'ResourceID'  => [
            0
        ],
        'Recurring'  => undef,
        'StartTime'  => '2017-01-03 18:00:00',
        'TimezoneID' => '2',

        'Title'      => 'January 3th next 3 years',
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'StartTime'  => '2018-01-03 18:00:00',
        'Recurring'  => undef,
        'TimezoneID' => '2',
        'Title'      => 'January 3th next 3 years',

        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'TeamID'     => undef,
        'Location'   => undef,
        'EndTime'    => '2018-01-03 19:00:00',
        'ParentID'   => '5491',

        'Description' => undef,
        'ResourceID'  => [
            0
            ]
    },
    {
        'StartTime'  => '2016-06-02 16:00:00',
        'Recurring'  => undef,
        'TimezoneID' => '2',

        'Title'      => 'Each 2nd week',
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => undef,
        'Location'   => undef,
        'EndTime'    => '2016-06-02 17:00:00',
        'ParentID'   => '4004',

        'Description' => 'Developer meeting each 2nd Tuesday',
        'ResourceID'  => [
            0
            ]
    },
    {
        'TeamID'   => undef,
        'Location' => undef,
        'EndTime'  => '2016-08-02 17:00:00',

        'ParentID'    => '4004',
        'Description' => 'Developer meeting each 2nd Tuesday',
        'ResourceID'  => [
            0
        ],
        'Recurring'  => undef,
        'StartTime'  => '2016-08-02 16:00:00',
        'TimezoneID' => '2',

        'Title'      => 'Each 2nd week',
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'Description' => 'Developer meeting each 2nd Tuesday',
        'ResourceID'  => [
            0
        ],
        'TeamID'   => undef,
        'EndTime'  => '2016-10-02 17:00:00',
        'Location' => undef,
        'ParentID' => '4004',

        'Title' => 'Each 2nd week',

        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'StartTime'  => '2016-10-02 16:00:00',
        'Recurring'  => undef,
        'TimezoneID' => '2'
    },
    {
        'Description' => 'Developer meeting each 2nd Tuesday',
        'ResourceID'  => [
            0
        ],
        'TeamID'   => undef,
        'Location' => undef,
        'EndTime'  => '2016-12-02 17:00:00',

        'ParentID' => '4004',

        'Title'      => 'Each 2nd week',
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'Recurring'  => undef,
        'StartTime'  => '2016-12-02 16:00:00',
        'TimezoneID' => '2'
    },
    {
        'Location' => undef,
        'TeamID'   => undef,
        'EndTime'  => '2016-01-11 10:00:00',
        'ParentID' => undef,

        'Description' => 'Start at Monday and repeat each 2nd Wednesday and Sunday.',
        'ResourceID'  => [
            0
        ],
        'StartTime'  => '2016-01-11 09:00:00',
        'Recurring'  => '1',
        'TimezoneID' => '2',

        'Title'      => 'Custom 1',
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'ResourceID' => [
            0
        ],
        'Description' => 'Start at Monday and repeat each 2nd Wednesday and Sunday.',
        'ParentID'    => '5498',

        'TeamID'     => undef,
        'EndTime'    => '2016-03-03 10:00:00',
        'Location'   => undef,
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,

        'Title'      => 'Custom 1',
        'TimezoneID' => '2',
        'StartTime'  => '2016-03-03 09:00:00',
        'Recurring'  => undef
    },
    {
        'Title' => 'Custom 2',

        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'Recurring'   => '1',
        'StartTime'   => '2016-01-12 09:00:00',
        'TimezoneID'  => '2',
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'ResourceID'  => [
            0
        ],
        'EndTime'  => '2016-01-12 10:00:00',
        'TeamID'   => undef,
        'Location' => undef,

        'ParentID' => undef
    },
    {
        'StartTime'  => '2016-02-12 09:00:00',
        'Recurring'  => undef,
        'TimezoneID' => '2',

        'Title'      => 'Custom 2',
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'TeamID'     => undef,
        'EndTime'    => '2016-02-12 10:00:00',
        'Location'   => undef,
        'ParentID'   => '5500',

        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'ResourceID'  => [
            0
            ]
    },
    {
        'TimezoneID' => '2',
        'Recurring'  => undef,
        'StartTime'  => '2016-03-12 09:00:00',
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,

        'Title' => 'Custom 2',

        'ParentID'   => '5500',
        'TeamID'     => undef,
        'Location'   => undef,
        'EndTime'    => '2016-03-12 10:00:00',
        'ResourceID' => [
            0
        ],
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.'
    },
    {
        'Location' => undef,
        'TeamID'   => undef,
        'EndTime'  => '2016-04-12 10:00:00',

        'ParentID'    => '5500',
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'ResourceID'  => [
            0
        ],
        'Recurring'  => undef,
        'StartTime'  => '2016-04-12 09:00:00',
        'TimezoneID' => '2',

        'Title'      => 'Custom 2',
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'TimezoneID' => '2',
        'StartTime'  => '2016-05-12 09:00:00',
        'Recurring'  => undef,
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},

        'Title'    => 'Custom 2',
        'ParentID' => '5500',

        'Location'   => undef,
        'TeamID'     => undef,
        'EndTime'    => '2016-05-12 10:00:00',
        'ResourceID' => [
            0
        ],
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.'
    },
    {
        'TimezoneID' => '2',
        'StartTime'  => '2016-06-12 09:00:00',
        'Recurring'  => undef,
        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},

        'Title'    => 'Custom 2',
        'ParentID' => '5500',

        'TeamID'     => undef,
        'EndTime'    => '2016-06-12 10:00:00',
        'Location'   => undef,
        'ResourceID' => [
            0
        ],
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.'
    },
    {
        'Title' => 'Custom 2',

        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'Recurring'   => undef,
        'StartTime'   => '2016-07-12 09:00:00',
        'TimezoneID'  => '2',
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'ResourceID'  => [
            0
        ],
        'TeamID'   => undef,
        'Location' => undef,
        'EndTime'  => '2016-07-12 10:00:00',

        'ParentID' => '5500'
    },
    {
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'ResourceID'  => [
            0
        ],
        'EndTime'  => '2016-08-12 10:00:00',
        'TeamID'   => undef,
        'Location' => undef,

        'ParentID' => '5500',
        'Title'    => 'Custom 2',

        'AllDay'     => undef,
        'CalendarID' => $Calendar{CalendarID},
        'Recurring'  => undef,
        'StartTime'  => '2016-08-12 09:00:00',
        'TimezoneID' => '2'
    },
    {
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'ResourceID'  => [
            0
        ],
        'TeamID'   => undef,
        'EndTime'  => '2016-09-12 10:00:00',
        'Location' => undef,
        'ParentID' => '5500',

        'Title' => 'Custom 2',

        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'StartTime'  => '2016-09-12 09:00:00',
        'Recurring'  => undef,
        'TimezoneID' => '2'
    },
    {
        'Title' => 'Custom 2',

        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'Recurring'   => undef,
        'StartTime'   => '2016-10-12 09:00:00',
        'TimezoneID'  => '2',
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'ResourceID'  => [
            0
        ],
        'Location' => undef,
        'TeamID'   => undef,
        'EndTime'  => '2016-10-12 10:00:00',

        'ParentID' => '5500'
    },
    {
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'ResourceID'  => [
            0
        ],
        'Location' => undef,
        'TeamID'   => undef,
        'EndTime'  => '2016-11-12 10:00:00',
        'ParentID' => '5500',

        'Title'      => 'Custom 2',
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'StartTime'  => '2016-11-12 09:00:00',
        'Recurring'  => undef,
        'TimezoneID' => '2'
    },
    {
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'ResourceID'  => [
            0
        ],
        'Location' => undef,
        'TeamID'   => undef,
        'EndTime'  => '2016-12-12 10:00:00',

        'ParentID' => '5500',

        'Title'      => 'Custom 2',
        'CalendarID' => $Calendar{CalendarID},
        'AllDay'     => undef,
        'Recurring'  => undef,
        'StartTime'  => '2016-12-12 09:00:00',
        'TimezoneID' => '2'
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
