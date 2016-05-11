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
    123,
    "Appointment count",
);

my @Result = (
    {
        'StartTime'   => '2016-04-05 00:00:00',
        'CalendarID'  => $Calendar{CalendarID},
        'Description' => 'test all day event',
        'AllDay'      => '1',
        'ParentID'    => undef,
        'TeamID'      => undef,

        'Location' => undef,

        'Recurring'  => undef,
        'Title'      => 'All day',
        'TimezoneID' => '0',
        'EndTime'    => '2016-04-06 00:00:00',
        'ResourceID' => [
            0
            ]
    },
    {
        'ResourceID' => [
            0
        ],
        'EndTime'    => '2016-04-12 12:00:00',
        'TimezoneID' => '2',
        'Title'      => 'Once per week',
        'Recurring'  => '1',

        'Location'    => 'Belgrade',
        'TeamID'      => undef,
        'ParentID'    => undef,
        'Description' => 'Only once per week',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'StartTime'   => '2016-04-12 11:30:00'
    },
    {
        'TeamID'    => undef,
        'ParentID'  => '1969',
        'Recurring' => undef,

        'Location'    => 'Belgrade',
        'StartTime'   => '2016-04-19 11:30:00',
        'Description' => 'Only once per week',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'ResourceID'  => [
            0
        ],
        'EndTime'    => '2016-04-19 12:00:00',
        'Title'      => 'Once per week',
        'TimezoneID' => '2'
    },
    {
        'Title'      => 'Once per week',
        'TimezoneID' => '2',
        'ResourceID' => [
            0
        ],
        'EndTime'     => '2016-04-26 12:00:00',
        'StartTime'   => '2016-04-26 11:30:00',
        'AllDay'      => undef,
        'Description' => 'Only once per week',
        'CalendarID'  => $Calendar{CalendarID},
        'TeamID'      => undef,
        'ParentID'    => '1969',

        'Recurring' => undef,
        'Location'  => 'Belgrade',

    },
    {
        'Description' => 'Only once per week',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'StartTime'   => '2016-05-03 11:30:00',

        'Recurring' => undef,
        'Location'  => 'Belgrade',

        'TeamID'     => undef,
        'ParentID'   => '1969',
        'TimezoneID' => '2',
        'Title'      => 'Once per week',
        'ResourceID' => [
            0
        ],
        'EndTime' => '2016-05-03 12:00:00'
    },
    {
        'Title'      => 'Once per week',
        'TimezoneID' => '2',
        'EndTime'    => '2016-05-10 12:00:00',
        'ResourceID' => [
            0
        ],
        'StartTime'   => '2016-05-10 11:30:00',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'Description' => 'Only once per week',
        'ParentID'    => '1969',
        'TeamID'      => undef,
        'Location'    => 'Belgrade',

        'Recurring' => undef
    },
    {
        'Recurring' => undef,

        'Location' => 'Belgrade',

        'TeamID'      => undef,
        'ParentID'    => '1969',
        'Description' => 'Only once per week',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'StartTime'   => '2016-05-17 11:30:00',
        'ResourceID'  => [
            0
        ],
        'EndTime'    => '2016-05-17 12:00:00',
        'TimezoneID' => '2',
        'Title'      => 'Once per week'
    },
    {
        'ParentID' => '1969',
        'TeamID'   => undef,

        'Location' => 'Belgrade',

        'Recurring'   => undef,
        'StartTime'   => '2016-05-24 11:30:00',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'Description' => 'Only once per week',
        'EndTime'     => '2016-05-24 12:00:00',
        'ResourceID'  => [
            0
        ],
        'Title'      => 'Once per week',
        'TimezoneID' => '2'
    },
    {
        'CalendarID'  => $Calendar{CalendarID},
        'Description' => 'Only once per week',
        'AllDay'      => undef,
        'StartTime'   => '2016-05-31 11:30:00',
        'Location'    => 'Belgrade',

        'Recurring'  => undef,
        'ParentID'   => '1969',
        'TeamID'     => undef,
        'TimezoneID' => '2',
        'Title'      => 'Once per week',
        'EndTime'    => '2016-05-31 12:00:00',
        'ResourceID' => [
            0
            ]
    },
    {
        'EndTime'    => '2016-06-07 12:00:00',
        'ResourceID' => [
            0
        ],
        'Title'      => 'Once per week',
        'TimezoneID' => '2',
        'ParentID'   => '1969',
        'TeamID'     => undef,

        'Location'  => 'Belgrade',
        'Recurring' => undef,

        'StartTime'   => '2016-06-07 11:30:00',
        'CalendarID'  => $Calendar{CalendarID},
        'Description' => 'Only once per week',
        'AllDay'      => undef
    },
    {
        'CalendarID'  => $Calendar{CalendarID},
        'Description' => 'Once per month',
        'AllDay'      => undef,
        'StartTime'   => '2016-04-12 13:15:00',

        'Location' => 'Germany',

        'Recurring'  => '1',
        'ParentID'   => undef,
        'TeamID'     => undef,
        'TimezoneID' => '2',
        'Title'      => 'Monthly meeting',
        'EndTime'    => '2016-04-12 14:00:00',
        'ResourceID' => [
            0
            ]
    },
    {
        'TimezoneID' => '2',
        'Title'      => 'Monthly meeting',
        'EndTime'    => '2016-05-12 14:00:00',
        'ResourceID' => [
            0
        ],
        'CalendarID'  => $Calendar{CalendarID},
        'Description' => 'Once per month',
        'AllDay'      => undef,
        'StartTime'   => '2016-05-12 13:15:00',
        'Location'    => 'Germany',

        'Recurring' => undef,

        'ParentID' => '1978',
        'TeamID'   => undef
    },
    {
        'TimezoneID' => '2',
        'Title'      => 'Monthly meeting',
        'ResourceID' => [
            0
        ],
        'EndTime'     => '2016-06-12 14:00:00',
        'AllDay'      => undef,
        'Description' => 'Once per month',
        'CalendarID'  => $Calendar{CalendarID},
        'StartTime'   => '2016-06-12 13:15:00',

        'Recurring' => undef,

        'Location' => 'Germany',
        'TeamID'   => undef,
        'ParentID' => '1978'
    },
    {
        'EndTime'    => '2016-07-12 14:00:00',
        'ResourceID' => [
            0
        ],
        'TimezoneID' => '2',
        'Title'      => 'Monthly meeting',
        'Location'   => 'Germany',

        'Recurring'   => undef,
        'ParentID'    => '1978',
        'TeamID'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'Description' => 'Once per month',
        'AllDay'      => undef,
        'StartTime'   => '2016-07-12 13:15:00'
    },
    {
        'ParentID' => '1978',
        'TeamID'   => undef,
        'Location' => 'Germany',

        'Recurring' => undef,

        'StartTime'   => '2016-08-12 13:15:00',
        'CalendarID'  => $Calendar{CalendarID},
        'Description' => 'Once per month',
        'AllDay'      => undef,
        'EndTime'     => '2016-08-12 14:00:00',
        'ResourceID'  => [
            0
        ],
        'Title'      => 'Monthly meeting',
        'TimezoneID' => '2'
    },
    {
        'TimezoneID' => '2',
        'Title'      => 'Monthly meeting',
        'EndTime'    => '2016-09-12 14:00:00',
        'ResourceID' => [
            0
        ],
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'Description' => 'Once per month',
        'StartTime'   => '2016-09-12 13:15:00',

        'Location' => 'Germany',

        'Recurring' => undef,
        'ParentID'  => '1978',
        'TeamID'    => undef
    },
    {
        'TeamID'    => undef,
        'ParentID'  => '1978',
        'Recurring' => undef,

        'Location'    => 'Germany',
        'StartTime'   => '2016-10-12 13:15:00',
        'Description' => 'Once per month',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'ResourceID'  => [
            0
        ],
        'EndTime'    => '2016-10-12 14:00:00',
        'Title'      => 'Monthly meeting',
        'TimezoneID' => '2'
    },
    {
        'Title'      => 'Monthly meeting',
        'TimezoneID' => '2',
        'ResourceID' => [
            0
        ],
        'EndTime'     => '2016-11-12 14:00:00',
        'StartTime'   => '2016-11-12 13:15:00',
        'Description' => 'Once per month',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'TeamID'      => undef,
        'ParentID'    => '1978',

        'Recurring' => undef,

        'Location' => 'Germany'
    },
    {
        'EndTime'    => '2016-12-12 14:00:00',
        'ResourceID' => [
            0
        ],
        'TimezoneID' => '2',
        'Title'      => 'Monthly meeting',

        'Location' => 'Germany',

        'Recurring'   => undef,
        'ParentID'    => '1978',
        'TeamID'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'Description' => 'Once per month',
        'StartTime'   => '2016-12-12 13:15:00'
    },
    {
        'Title'      => 'Monthly meeting',
        'TimezoneID' => '2',
        'EndTime'    => '2017-01-12 14:00:00',
        'ResourceID' => [
            0
        ],
        'StartTime'   => '2017-01-12 13:15:00',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'Description' => 'Once per month',
        'ParentID'    => '1978',
        'TeamID'      => undef,
        'Location'    => 'Germany',

        'Recurring' => undef,

    },
    {
        'StartTime'   => '2017-02-12 13:15:00',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'Description' => 'Once per month',
        'ParentID'    => '1978',
        'TeamID'      => undef,
        'Location'    => 'Germany',

        'Recurring' => undef,

        'Title'      => 'Monthly meeting',
        'TimezoneID' => '2',
        'EndTime'    => '2017-02-12 14:00:00',
        'ResourceID' => [
            0
            ]
    },
    {
        'AllDay'      => undef,
        'Description' => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'StartTime'   => '2016-03-31 08:00:00',
        'Recurring'   => '1',

        'Location' => undef,

        'TeamID'     => undef,
        'ParentID'   => undef,
        'TimezoneID' => '2',
        'Title'      => 'End of the month',
        'ResourceID' => [
            0
        ],
        'EndTime' => '2016-03-31 09:00:00'
    },
    {
        'StartTime'   => '2016-04-30 08:00:00',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'Description' => undef,
        'ParentID'    => '1989',
        'TeamID'      => undef,

        'Location'  => undef,
        'Recurring' => undef,

        'Title'      => 'End of the month',
        'TimezoneID' => '2',
        'EndTime'    => '2016-04-30 09:00:00',
        'ResourceID' => [
            0
            ]
    },
    {
        'TeamID'   => undef,
        'ParentID' => '1989',

        'Recurring' => undef,
        'Location'  => undef,

        'StartTime'   => '2016-05-31 08:00:00',
        'Description' => undef,
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'ResourceID'  => [
            0
        ],
        'EndTime'    => '2016-05-31 09:00:00',
        'Title'      => 'End of the month',
        'TimezoneID' => '2'
    },
    {
        'ResourceID' => [
            0
        ],
        'EndTime'    => '2016-06-30 09:00:00',
        'TimezoneID' => '2',
        'Title'      => 'End of the month',

        'Recurring' => undef,
        'Location'  => undef,

        'TeamID'      => undef,
        'ParentID'    => '1989',
        'Description' => undef,
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'StartTime'   => '2016-06-30 08:00:00'
    },
    {
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'Description' => undef,
        'StartTime'   => '2016-07-31 08:00:00',

        'Location'  => undef,
        'Recurring' => undef,

        'ParentID'   => '1989',
        'TeamID'     => undef,
        'TimezoneID' => '2',
        'Title'      => 'End of the month',
        'EndTime'    => '2016-07-31 09:00:00',
        'ResourceID' => [
            0
            ]
    },
    {
        'Title'      => 'End of the month',
        'TimezoneID' => '2',
        'ResourceID' => [
            0
        ],
        'EndTime'     => '2016-08-31 09:00:00',
        'StartTime'   => '2016-08-31 08:00:00',
        'AllDay'      => undef,
        'Description' => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'TeamID'      => undef,
        'ParentID'    => '1989',
        'Recurring'   => undef,

        'Location' => undef,

    },
    {
        'Title'      => 'End of the month',
        'TimezoneID' => '2',
        'ResourceID' => [
            0
        ],
        'EndTime'     => '2016-09-30 09:00:00',
        'StartTime'   => '2016-09-30 08:00:00',
        'AllDay'      => undef,
        'Description' => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'TeamID'      => undef,
        'ParentID'    => '1989',

        'Recurring' => undef,

        'Location' => undef
    },
    {
        'ParentID' => '1989',
        'TeamID'   => undef,

        'Location' => undef,

        'Recurring'   => undef,
        'StartTime'   => '2016-10-31 08:00:00',
        'CalendarID'  => $Calendar{CalendarID},
        'Description' => undef,
        'AllDay'      => undef,
        'EndTime'     => '2016-10-31 09:00:00',
        'ResourceID'  => [
            0
        ],
        'Title'      => 'End of the month',
        'TimezoneID' => '2'
    },
    {
        'Title'      => 'End of the month',
        'TimezoneID' => '2',
        'ResourceID' => [
            0
        ],
        'EndTime'     => '2016-11-30 09:00:00',
        'StartTime'   => '2016-11-30 08:00:00',
        'Description' => undef,
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'TeamID'      => undef,
        'ParentID'    => '1989',

        'Recurring' => undef,
        'Location'  => undef,

    },
    {
        'CalendarID'  => $Calendar{CalendarID},
        'Description' => undef,
        'AllDay'      => undef,
        'StartTime'   => '2016-12-31 08:00:00',
        'Location'    => undef,

        'Recurring'  => undef,
        'ParentID'   => '1989',
        'TeamID'     => undef,
        'TimezoneID' => '2',
        'Title'      => 'End of the month',
        'EndTime'    => '2016-12-31 09:00:00',
        'ResourceID' => [
            0
            ]
    },
    {
        'Description' => undef,
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'StartTime'   => '2017-01-31 08:00:00',
        'Recurring'   => undef,

        'Location' => undef,

        'TeamID'     => undef,
        'ParentID'   => '1989',
        'TimezoneID' => '2',
        'Title'      => 'End of the month',
        'ResourceID' => [
            0
        ],
        'EndTime' => '2017-01-31 09:00:00'
    },
    {
        'TeamID'    => undef,
        'ParentID'  => '1989',
        'Recurring' => undef,

        'Location'    => undef,
        'StartTime'   => '2017-02-28 08:00:00',
        'Description' => undef,
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'ResourceID'  => [
            0
        ],
        'EndTime'    => '2017-02-28 09:00:00',
        'Title'      => 'End of the month',
        'TimezoneID' => '2'
    },
    {
        'Title'      => 'Each 2 months',
        'TimezoneID' => '2',
        'ResourceID' => [
            0
        ],
        'EndTime'     => '2016-01-31 11:00:00',
        'StartTime'   => '2016-01-31 10:00:00',
        'AllDay'      => undef,
        'Description' => 'test',
        'CalendarID'  => $Calendar{CalendarID},
        'TeamID'      => undef,
        'ParentID'    => undef,
        'Recurring'   => '1',

        'Location' => 'Test',

    },
    {
        'ResourceID' => [
            0
        ],
        'EndTime'    => '2016-03-31 11:00:00',
        'Title'      => 'Each 2 months',
        'TimezoneID' => '2',
        'TeamID'     => undef,
        'ParentID'   => '2001',

        'Recurring' => undef,
        'Location'  => 'Test',

        'StartTime'   => '2016-03-31 10:00:00',
        'Description' => 'test',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
    },
    {
        'StartTime'   => '2016-05-31 10:00:00',
        'AllDay'      => undef,
        'Description' => 'test',
        'CalendarID'  => $Calendar{CalendarID},
        'TeamID'      => undef,
        'ParentID'    => '2001',

        'Recurring' => undef,

        'Location'   => 'Test',
        'Title'      => 'Each 2 months',
        'TimezoneID' => '2',
        'ResourceID' => [
            0
        ],
        'EndTime' => '2016-05-31 11:00:00'
    },
    {
        'ParentID' => '2001',
        'TeamID'   => undef,

        'Location' => 'Test',

        'Recurring'   => undef,
        'StartTime'   => '2016-07-31 10:00:00',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'Description' => 'test',
        'EndTime'     => '2016-07-31 11:00:00',
        'ResourceID'  => [
            0
        ],
        'Title'      => 'Each 2 months',
        'TimezoneID' => '2'
    },
    {
        'Location' => 'Test',

        'Recurring'   => undef,
        'ParentID'    => '2001',
        'TeamID'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'Description' => 'test',
        'StartTime'   => '2016-09-30 10:00:00',
        'EndTime'     => '2016-09-30 11:00:00',
        'ResourceID'  => [
            0
        ],
        'TimezoneID' => '2',
        'Title'      => 'Each 2 months'
    },
    {
        'Title'      => 'Each 2 months',
        'TimezoneID' => '2',
        'ResourceID' => [
            0
        ],
        'EndTime'     => '2016-11-30 11:00:00',
        'StartTime'   => '2016-11-30 10:00:00',
        'AllDay'      => undef,
        'Description' => 'test',
        'CalendarID'  => $Calendar{CalendarID},
        'TeamID'      => undef,
        'ParentID'    => '2001',
        'Recurring'   => undef,

        'Location' => 'Test',

    },
    {
        'EndTime'    => '2017-01-31 11:00:00',
        'ResourceID' => [
            0
        ],
        'Title'      => 'Each 2 months',
        'TimezoneID' => '2',
        'ParentID'   => '2001',
        'TeamID'     => undef,

        'Location'  => 'Test',
        'Recurring' => undef,

        'StartTime'   => '2017-01-31 10:00:00',
        'CalendarID'  => $Calendar{CalendarID},
        'Description' => 'test',
        'AllDay'      => undef
    },
    {
        'Title'      => 'My event',
        'TimezoneID' => '2',
        'ResourceID' => [
            0
        ],
        'EndTime'     => '2016-04-12 10:00:00',
        'StartTime'   => '2016-04-12 09:00:00',
        'AllDay'      => undef,
        'Description' => 'Test description',
        'CalendarID'  => $Calendar{CalendarID},
        'TeamID'      => undef,
        'ParentID'    => undef,

        'Recurring' => '1',
        'Location'  => 'Stara Pazova',

    },
    {
        'ParentID' => '2008',
        'TeamID'   => undef,
        'Location' => 'Stara Pazova',

        'Recurring'   => undef,
        'StartTime'   => '2016-04-14 09:00:00',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'Description' => 'Test description',
        'EndTime'     => '2016-04-14 10:00:00',
        'ResourceID'  => [
            0
        ],
        'Title'      => 'My event',
        'TimezoneID' => '2'
    },
    {
        'ResourceID' => [
            0
        ],
        'EndTime'    => '2016-04-16 10:00:00',
        'TimezoneID' => '2',
        'Title'      => 'My event',

        'Recurring' => undef,
        'Location'  => 'Stara Pazova',

        'TeamID'      => undef,
        'ParentID'    => '2008',
        'AllDay'      => undef,
        'Description' => 'Test description',
        'CalendarID'  => $Calendar{CalendarID},
        'StartTime'   => '2016-04-16 09:00:00'
    },
    {
        'ParentID' => '2008',
        'TeamID'   => undef,

        'Location' => 'Stara Pazova',

        'Recurring'   => undef,
        'StartTime'   => '2016-04-18 09:00:00',
        'CalendarID'  => $Calendar{CalendarID},
        'Description' => 'Test description',
        'AllDay'      => undef,
        'EndTime'     => '2016-04-18 10:00:00',
        'ResourceID'  => [
            0
        ],
        'Title'      => 'My event',
        'TimezoneID' => '2'
    },
    {
        'ParentID' => '2008',
        'TeamID'   => undef,
        'Location' => 'Stara Pazova',

        'Recurring' => undef,

        'StartTime'   => '2016-04-20 09:00:00',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'Description' => 'Test description',
        'EndTime'     => '2016-04-20 10:00:00',
        'ResourceID'  => [
            0
        ],
        'Title'      => 'My event',
        'TimezoneID' => '2'
    },
    {
        'StartTime'   => '2016-04-22 09:00:00',
        'AllDay'      => undef,
        'Description' => 'Test description',
        'CalendarID'  => $Calendar{CalendarID},
        'TeamID'      => undef,
        'ParentID'    => '2008',
        'Recurring'   => undef,

        'Location' => 'Stara Pazova',

        'Title'      => 'My event',
        'TimezoneID' => '2',
        'ResourceID' => [
            0
        ],
        'EndTime' => '2016-04-22 10:00:00'
    },
    {
        'TimezoneID' => '2',
        'Title'      => 'My event',
        'ResourceID' => [
            0
        ],
        'EndTime'     => '2016-04-24 10:00:00',
        'Description' => 'Test description',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'StartTime'   => '2016-04-24 09:00:00',
        'Recurring'   => undef,

        'Location' => 'Stara Pazova',

        'TeamID'   => undef,
        'ParentID' => '2008'
    },
    {
        'ResourceID' => [
            0
        ],
        'EndTime'    => '2016-04-26 10:00:00',
        'TimezoneID' => '2',
        'Title'      => 'My event',

        'Recurring' => undef,

        'Location'    => 'Stara Pazova',
        'TeamID'      => undef,
        'ParentID'    => '2008',
        'AllDay'      => undef,
        'Description' => 'Test description',
        'CalendarID'  => $Calendar{CalendarID},
        'StartTime'   => '2016-04-26 09:00:00'
    },
    {
        'StartTime'   => '2016-04-28 09:00:00',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'Description' => 'Test description',
        'ParentID'    => '2008',
        'TeamID'      => undef,

        'Location'  => 'Stara Pazova',
        'Recurring' => undef,

        'Title'      => 'My event',
        'TimezoneID' => '2',
        'EndTime'    => '2016-04-28 10:00:00',
        'ResourceID' => [
            0
            ]
    },
    {
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'Description' => 'Test description',
        'StartTime'   => '2016-04-30 09:00:00',
        'Location'    => 'Stara Pazova',

        'Recurring'  => undef,
        'ParentID'   => '2008',
        'TeamID'     => undef,
        'TimezoneID' => '2',
        'Title'      => 'My event',
        'EndTime'    => '2016-04-30 10:00:00',
        'ResourceID' => [
            0
            ]
    },
    {
        'ResourceID' => [
            0
        ],
        'EndTime'    => '2016-05-02 10:00:00',
        'TimezoneID' => '2',
        'Title'      => 'My event',
        'Recurring'  => undef,

        'Location'    => 'Stara Pazova',
        'TeamID'      => undef,
        'ParentID'    => '2008',
        'AllDay'      => undef,
        'Description' => 'Test description',
        'CalendarID'  => $Calendar{CalendarID},
        'StartTime'   => '2016-05-02 09:00:00'
    },
    {
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'Description' => 'Test description',
        'StartTime'   => '2016-05-04 09:00:00',

        'Location' => 'Stara Pazova',

        'Recurring'  => undef,
        'ParentID'   => '2008',
        'TeamID'     => undef,
        'TimezoneID' => '2',
        'Title'      => 'My event',
        'EndTime'    => '2016-05-04 10:00:00',
        'ResourceID' => [
            0
            ]
    },
    {
        'StartTime'   => '2016-05-06 09:00:00',
        'CalendarID'  => $Calendar{CalendarID},
        'Description' => 'Test description',
        'AllDay'      => undef,
        'ParentID'    => '2008',
        'TeamID'      => undef,
        'Location'    => 'Stara Pazova',

        'Recurring' => undef,

        'Title'      => 'My event',
        'TimezoneID' => '2',
        'EndTime'    => '2016-05-06 10:00:00',
        'ResourceID' => [
            0
            ]
    },
    {
        'TimezoneID' => '2',
        'Title'      => 'My event',
        'EndTime'    => '2016-05-08 10:00:00',
        'ResourceID' => [
            0
        ],
        'CalendarID'  => $Calendar{CalendarID},
        'Description' => 'Test description',
        'AllDay'      => undef,
        'StartTime'   => '2016-05-08 09:00:00',

        'Location' => 'Stara Pazova',

        'Recurring' => undef,
        'ParentID'  => '2008',
        'TeamID'    => undef
    },
    {
        'ResourceID' => [
            0
        ],
        'EndTime'    => '2016-05-10 10:00:00',
        'TimezoneID' => '2',
        'Title'      => 'My event',

        'Recurring' => undef,
        'Location'  => 'Stara Pazova',

        'TeamID'      => undef,
        'ParentID'    => '2008',
        'Description' => 'Test description',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'StartTime'   => '2016-05-10 09:00:00'
    },
    {
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'Description' => 'Test description',
        'StartTime'   => '2016-05-12 09:00:00',
        'Location'    => 'Stara Pazova',

        'Recurring' => undef,

        'ParentID'   => '2008',
        'TeamID'     => undef,
        'TimezoneID' => '2',
        'Title'      => 'My event',
        'EndTime'    => '2016-05-12 10:00:00',
        'ResourceID' => [
            0
            ]
    },
    {
        'AllDay'      => undef,
        'Description' => 'Test description',
        'CalendarID'  => $Calendar{CalendarID},
        'StartTime'   => '2016-05-14 09:00:00',

        'Recurring' => undef,
        'Location'  => 'Stara Pazova',

        'TeamID'     => undef,
        'ParentID'   => '2008',
        'TimezoneID' => '2',
        'Title'      => 'My event',
        'ResourceID' => [
            0
        ],
        'EndTime' => '2016-05-14 10:00:00'
    },
    {
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'Description' => 'Test description',
        'StartTime'   => '2016-05-16 09:00:00',
        'Location'    => 'Stara Pazova',

        'Recurring' => undef,

        'ParentID'   => '2008',
        'TeamID'     => undef,
        'TimezoneID' => '2',
        'Title'      => 'My event',
        'EndTime'    => '2016-05-16 10:00:00',
        'ResourceID' => [
            0
            ]
    },
    {
        'StartTime'   => '2016-05-18 09:00:00',
        'Description' => 'Test description',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'TeamID'      => undef,
        'ParentID'    => '2008',

        'Recurring' => undef,

        'Location'   => 'Stara Pazova',
        'Title'      => 'My event',
        'TimezoneID' => '2',
        'ResourceID' => [
            0
        ],
        'EndTime' => '2016-05-18 10:00:00'
    },
    {
        'StartTime'   => '2016-05-20 09:00:00',
        'AllDay'      => undef,
        'Description' => 'Test description',
        'CalendarID'  => $Calendar{CalendarID},
        'TeamID'      => undef,
        'ParentID'    => '2008',
        'Recurring'   => undef,

        'Location'   => 'Stara Pazova',
        'Title'      => 'My event',
        'TimezoneID' => '2',
        'ResourceID' => [
            0
        ],
        'EndTime' => '2016-05-20 10:00:00'
    },
    {
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'Description' => 'Test description',
        'StartTime'   => '2016-05-22 09:00:00',
        'Location'    => 'Stara Pazova',

        'Recurring'  => undef,
        'ParentID'   => '2008',
        'TeamID'     => undef,
        'TimezoneID' => '2',
        'Title'      => 'My event',
        'EndTime'    => '2016-05-22 10:00:00',
        'ResourceID' => [
            0
            ]
    },
    {
        'Title'      => 'My event',
        'TimezoneID' => '2',
        'ResourceID' => [
            0
        ],
        'EndTime'     => '2016-05-24 10:00:00',
        'StartTime'   => '2016-05-24 09:00:00',
        'AllDay'      => undef,
        'Description' => 'Test description',
        'CalendarID'  => $Calendar{CalendarID},
        'TeamID'      => undef,
        'ParentID'    => '2008',
        'Recurring'   => undef,

        'Location' => 'Stara Pazova',

    },
    {
        'EndTime'    => '2016-05-26 10:00:00',
        'ResourceID' => [
            0
        ],
        'TimezoneID' => '2',
        'Title'      => 'My event',

        'Location'  => 'Stara Pazova',
        'Recurring' => undef,

        'ParentID'    => '2008',
        'TeamID'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'Description' => 'Test description',
        'AllDay'      => undef,
        'StartTime'   => '2016-05-26 09:00:00'
    },
    {
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'Description' => 'Test description',
        'StartTime'   => '2016-05-28 09:00:00',
        'Location'    => 'Stara Pazova',

        'Recurring'  => undef,
        'ParentID'   => '2008',
        'TeamID'     => undef,
        'TimezoneID' => '2',
        'Title'      => 'My event',
        'EndTime'    => '2016-05-28 10:00:00',
        'ResourceID' => [
            0
            ]
    },
    {
        'TeamID'   => undef,
        'ParentID' => '2008',

        'Recurring' => undef,

        'Location'    => 'Stara Pazova',
        'StartTime'   => '2016-05-30 09:00:00',
        'Description' => 'Test description',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'ResourceID'  => [
            0
        ],
        'EndTime'    => '2016-05-30 10:00:00',
        'Title'      => 'My event',
        'TimezoneID' => '2'
    },
    {

        'Location'  => undef,
        'Recurring' => '1',

        'ParentID'    => undef,
        'TeamID'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'Description' => undef,
        'StartTime'   => '2016-04-01 10:00:00',
        'EndTime'     => '2016-04-01 11:00:00',
        'ResourceID'  => [
            0
        ],
        'TimezoneID' => '2',
        'Title'      => 'Each 2 years'
    },
    {
        'StartTime'   => '2018-04-01 10:00:00',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'Description' => undef,
        'ParentID'    => '2033',
        'TeamID'      => undef,
        'Location'    => undef,

        'Recurring'  => undef,
        'Title'      => 'Each 2 years',
        'TimezoneID' => '2',
        'EndTime'    => '2018-04-01 11:00:00',
        'ResourceID' => [
            0
            ]
    },
    {
        'StartTime'   => '2020-04-01 10:00:00',
        'AllDay'      => undef,
        'Description' => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'TeamID'      => undef,
        'ParentID'    => '2033',

        'Recurring' => undef,
        'Location'  => undef,

        'Title'      => 'Each 2 years',
        'TimezoneID' => '2',
        'ResourceID' => [
            0
        ],
        'EndTime' => '2020-04-01 11:00:00'
    },
    {
        'Description' => undef,
        'AllDay'      => '1',
        'CalendarID'  => $Calendar{CalendarID},
        'StartTime'   => '2016-04-02 00:00:00',
        'Recurring'   => '1',

        'Location' => undef,

        'TeamID'     => undef,
        'ParentID'   => undef,
        'TimezoneID' => '0',
        'Title'      => 'Each 3thd all day',
        'ResourceID' => [
            0
        ],
        'EndTime' => '2016-04-03 00:00:00'
    },
    {
        'Title'      => 'Each 3thd all day',
        'TimezoneID' => '0',
        'EndTime'    => '2016-04-06 00:00:00',
        'ResourceID' => [
            0
        ],
        'StartTime'   => '2016-04-05 00:00:00',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => '1',
        'Description' => undef,
        'ParentID'    => '2036',
        'TeamID'      => undef,
        'Location'    => undef,

        'Recurring' => undef
    },
    {
        'ResourceID' => [
            0
        ],
        'EndTime'    => '2016-04-09 00:00:00',
        'Title'      => 'Each 3thd all day',
        'TimezoneID' => '0',
        'TeamID'     => undef,
        'ParentID'   => '2036',
        'Recurring'  => undef,

        'Location' => undef,

        'StartTime'   => '2016-04-08 00:00:00',
        'AllDay'      => '1',
        'Description' => undef,
        'CalendarID'  => $Calendar{CalendarID},
    },
    {
        'EndTime'    => '2016-04-12 00:00:00',
        'ResourceID' => [
            0
        ],
        'TimezoneID' => '0',
        'Title'      => 'Each 3thd all day',

        'Location'  => undef,
        'Recurring' => undef,

        'ParentID'    => '2036',
        'TeamID'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'Description' => undef,
        'AllDay'      => '1',
        'StartTime'   => '2016-04-11 00:00:00'
    },
    {
        'AllDay'      => '1',
        'Description' => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'StartTime'   => '2016-04-14 00:00:00',

        'Recurring' => undef,

        'Location'   => undef,
        'TeamID'     => undef,
        'ParentID'   => '2036',
        'TimezoneID' => '0',
        'Title'      => 'Each 3thd all day',
        'ResourceID' => [
            0
        ],
        'EndTime' => '2016-04-15 00:00:00'
    },
    {
        'ParentID' => '2036',
        'TeamID'   => undef,

        'Location' => undef,

        'Recurring'   => undef,
        'StartTime'   => '2016-04-17 00:00:00',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => '1',
        'Description' => undef,
        'EndTime'     => '2016-04-18 00:00:00',
        'ResourceID'  => [
            0
        ],
        'Title'      => 'Each 3thd all day',
        'TimezoneID' => '0'
    },
    {
        'ResourceID' => [
            0
        ],
        'EndTime'    => '2016-04-21 00:00:00',
        'Title'      => 'Each 3thd all day',
        'TimezoneID' => '0',
        'TeamID'     => undef,
        'ParentID'   => '2036',
        'Recurring'  => undef,

        'Location' => undef,

        'StartTime'   => '2016-04-20 00:00:00',
        'AllDay'      => '1',
        'Description' => undef,
        'CalendarID'  => $Calendar{CalendarID},
    },
    {
        'ResourceID' => [
            0
        ],
        'EndTime'    => '2016-04-24 00:00:00',
        'TimezoneID' => '0',
        'Title'      => 'Each 3thd all day',
        'Recurring'  => undef,

        'Location' => undef,

        'TeamID'      => undef,
        'ParentID'    => '2036',
        'AllDay'      => '1',
        'Description' => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'StartTime'   => '2016-04-23 00:00:00'
    },
    {
        'Title'      => 'Each 3thd all day',
        'TimezoneID' => '0',
        'ResourceID' => [
            0
        ],
        'EndTime'     => '2016-04-27 00:00:00',
        'StartTime'   => '2016-04-26 00:00:00',
        'Description' => undef,
        'AllDay'      => '1',
        'CalendarID'  => $Calendar{CalendarID},
        'TeamID'      => undef,
        'ParentID'    => '2036',
        'Recurring'   => undef,

        'Location' => undef,

    },
    {
        'ResourceID' => [
            0
        ],
        'EndTime'    => '2016-04-30 00:00:00',
        'Title'      => 'Each 3thd all day',
        'TimezoneID' => '0',
        'TeamID'     => undef,
        'ParentID'   => '2036',

        'Recurring' => undef,
        'Location'  => undef,

        'StartTime'   => '2016-04-29 00:00:00',
        'AllDay'      => '1',
        'Description' => undef,
        'CalendarID'  => $Calendar{CalendarID},
    },
    {
        'ResourceID' => [
            0
        ],
        'EndTime'    => '2016-03-07 17:00:00',
        'TimezoneID' => '2',
        'Title'      => 'First 3 days',

        'Recurring' => '1',
        'Location'  => undef,

        'TeamID'      => undef,
        'ParentID'    => undef,
        'Description' => undef,
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'StartTime'   => '2016-03-07 16:00:00'
    },
    {
        'ParentID' => '2046',
        'TeamID'   => undef,
        'Location' => undef,

        'Recurring' => undef,

        'StartTime'   => '2016-03-08 16:00:00',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'Description' => undef,
        'EndTime'     => '2016-03-08 17:00:00',
        'ResourceID'  => [
            0
        ],
        'Title'      => 'First 3 days',
        'TimezoneID' => '2'
    },
    {
        'Title'      => 'First 3 days',
        'TimezoneID' => '2',
        'EndTime'    => '2016-03-09 17:00:00',
        'ResourceID' => [
            0
        ],
        'StartTime'   => '2016-03-09 16:00:00',
        'CalendarID'  => $Calendar{CalendarID},
        'Description' => undef,
        'AllDay'      => undef,
        'ParentID'    => '2046',
        'TeamID'      => undef,

        'Location' => undef,

        'Recurring' => undef
    },
    {
        'ResourceID' => [
            0
        ],
        'EndTime'    => '2016-03-02 19:00:00',
        'Title'      => 'Once per next 2 month',
        'TimezoneID' => '2',
        'TeamID'     => undef,
        'ParentID'   => undef,

        'Recurring' => '1',
        'Location'  => undef,

        'StartTime'   => '2016-03-02 18:00:00',
        'Description' => undef,
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
    },
    {

        'Location'  => undef,
        'Recurring' => undef,

        'ParentID'    => '2049',
        'TeamID'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'Description' => undef,
        'StartTime'   => '2016-04-02 18:00:00',
        'EndTime'     => '2016-04-02 19:00:00',
        'ResourceID'  => [
            0
        ],
        'TimezoneID' => '2',
        'Title'      => 'Once per next 2 month'
    },
    {
        'Title'      => 'January 3th next 3 years',
        'TimezoneID' => '2',
        'ResourceID' => [
            0
        ],
        'EndTime'     => '2016-01-03 19:00:00',
        'StartTime'   => '2016-01-03 18:00:00',
        'Description' => undef,
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'TeamID'      => undef,
        'ParentID'    => undef,
        'Recurring'   => '1',

        'Location' => undef
    },
    {
        'StartTime'   => '2017-01-03 18:00:00',
        'Description' => undef,
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'TeamID'      => undef,
        'ParentID'    => '2051',

        'Recurring' => undef,

        'Location'   => undef,
        'Title'      => 'January 3th next 3 years',
        'TimezoneID' => '2',
        'ResourceID' => [
            0
        ],
        'EndTime' => '2017-01-03 19:00:00'
    },
    {
        'Title'      => 'January 3th next 3 years',
        'TimezoneID' => '2',
        'EndTime'    => '2018-01-03 19:00:00',
        'ResourceID' => [
            0
        ],
        'StartTime'   => '2018-01-03 18:00:00',
        'CalendarID'  => $Calendar{CalendarID},
        'Description' => undef,
        'AllDay'      => undef,
        'ParentID'    => '2051',
        'TeamID'      => undef,

        'Location'  => undef,
        'Recurring' => undef,

    },
    {
        'ResourceID' => [
            0
        ],
        'EndTime'    => '2016-04-12 17:00:00',
        'TimezoneID' => '2',
        'Title'      => 'Each 2nd week',
        'Recurring'  => '1',

        'Location' => undef,

        'TeamID'      => undef,
        'ParentID'    => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'StartTime'   => '2016-04-12 16:00:00'
    },
    {
        'EndTime'    => '2016-04-26 17:00:00',
        'ResourceID' => [
            0
        ],
        'TimezoneID' => '2',
        'Title'      => 'Each 2nd week',
        'Location'   => undef,

        'Recurring' => undef,

        'ParentID'    => '2054',
        'TeamID'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'StartTime'   => '2016-04-26 16:00:00'
    },
    {
        'TeamID'   => undef,
        'ParentID' => '2054',

        'Recurring' => undef,

        'Location'    => undef,
        'StartTime'   => '2016-05-10 16:00:00',
        'Description' => 'Developer meeting each 2nd Tuesday',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'ResourceID'  => [
            0
        ],
        'EndTime'    => '2016-05-10 17:00:00',
        'Title'      => 'Each 2nd week',
        'TimezoneID' => '2'
    },
    {
        'ParentID' => '2054',
        'TeamID'   => undef,

        'Location'  => undef,
        'Recurring' => undef,

        'StartTime'   => '2016-05-24 16:00:00',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'EndTime'     => '2016-05-24 17:00:00',
        'ResourceID'  => [
            0
        ],
        'Title'      => 'Each 2nd week',
        'TimezoneID' => '2'
    },
    {
        'TeamID'   => undef,
        'ParentID' => '2054',

        'Recurring' => undef,
        'Location'  => undef,

        'StartTime'   => '2016-06-07 16:00:00',
        'Description' => 'Developer meeting each 2nd Tuesday',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'ResourceID'  => [
            0
        ],
        'EndTime'    => '2016-06-07 17:00:00',
        'Title'      => 'Each 2nd week',
        'TimezoneID' => '2'
    },
    {
        'ResourceID' => [
            0
        ],
        'EndTime'    => '2016-06-21 17:00:00',
        'TimezoneID' => '2',
        'Title'      => 'Each 2nd week',

        'Recurring' => undef,

        'Location'    => undef,
        'TeamID'      => undef,
        'ParentID'    => '2054',
        'Description' => 'Developer meeting each 2nd Tuesday',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'StartTime'   => '2016-06-21 16:00:00'
    },
    {
        'Title'      => 'Each 2nd week',
        'TimezoneID' => '2',
        'EndTime'    => '2016-07-05 17:00:00',
        'ResourceID' => [
            0
        ],
        'StartTime'   => '2016-07-05 16:00:00',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'ParentID'    => '2054',
        'TeamID'      => undef,
        'Location'    => undef,

        'Recurring' => undef
    },
    {
        'Description' => 'Developer meeting each 2nd Tuesday',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'StartTime'   => '2016-07-19 16:00:00',
        'Recurring'   => undef,

        'Location' => undef,

        'TeamID'     => undef,
        'ParentID'   => '2054',
        'TimezoneID' => '2',
        'Title'      => 'Each 2nd week',
        'ResourceID' => [
            0
        ],
        'EndTime' => '2016-07-19 17:00:00'
    },
    {
        'ResourceID' => [
            0
        ],
        'EndTime'    => '2016-08-02 17:00:00',
        'Title'      => 'Each 2nd week',
        'TimezoneID' => '2',
        'TeamID'     => undef,
        'ParentID'   => '2054',
        'Recurring'  => undef,

        'Location' => undef,

        'StartTime'   => '2016-08-02 16:00:00',
        'AllDay'      => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'CalendarID'  => $Calendar{CalendarID},
    },
    {
        'AllDay'      => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'CalendarID'  => $Calendar{CalendarID},
        'StartTime'   => '2016-08-16 16:00:00',
        'Recurring'   => undef,

        'Location' => undef,

        'TeamID'     => undef,
        'ParentID'   => '2054',
        'TimezoneID' => '2',
        'Title'      => 'Each 2nd week',
        'ResourceID' => [
            0
        ],
        'EndTime' => '2016-08-16 17:00:00'
    },
    {
        'TimezoneID' => '2',
        'Title'      => 'Each 2nd week',
        'ResourceID' => [
            0
        ],
        'EndTime'     => '2016-08-30 17:00:00',
        'AllDay'      => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'CalendarID'  => $Calendar{CalendarID},
        'StartTime'   => '2016-08-30 16:00:00',

        'Recurring' => undef,
        'Location'  => undef,

        'TeamID'   => undef,
        'ParentID' => '2054'
    },
    {
        'ResourceID' => [
            0
        ],
        'EndTime'    => '2016-09-13 17:00:00',
        'TimezoneID' => '2',
        'Title'      => 'Each 2nd week',
        'Recurring'  => undef,

        'Location' => undef,

        'TeamID'      => undef,
        'ParentID'    => '2054',
        'AllDay'      => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'CalendarID'  => $Calendar{CalendarID},
        'StartTime'   => '2016-09-13 16:00:00'
    },
    {
        'TimezoneID' => '2',
        'Title'      => 'Each 2nd week',
        'ResourceID' => [
            0
        ],
        'EndTime'     => '2016-09-27 17:00:00',
        'Description' => 'Developer meeting each 2nd Tuesday',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'StartTime'   => '2016-09-27 16:00:00',
        'Recurring'   => undef,

        'Location' => undef,
        'TeamID'   => undef,
        'ParentID' => '2054'
    },
    {
        'Recurring' => undef,

        'Location'    => undef,
        'TeamID'      => undef,
        'ParentID'    => '2054',
        'AllDay'      => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'CalendarID'  => $Calendar{CalendarID},
        'StartTime'   => '2016-10-11 16:00:00',
        'ResourceID'  => [
            0
        ],
        'EndTime'    => '2016-10-11 17:00:00',
        'TimezoneID' => '2',
        'Title'      => 'Each 2nd week'
    },
    {
        'AllDay'      => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'CalendarID'  => $Calendar{CalendarID},
        'StartTime'   => '2016-10-25 16:00:00',

        'Recurring' => undef,

        'Location'   => undef,
        'TeamID'     => undef,
        'ParentID'   => '2054',
        'TimezoneID' => '2',
        'Title'      => 'Each 2nd week',
        'ResourceID' => [
            0
        ],
        'EndTime' => '2016-10-25 17:00:00'
    },
    {

        'Location' => undef,

        'Recurring'   => undef,
        'ParentID'    => '2054',
        'TeamID'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'StartTime'   => '2016-11-08 16:00:00',
        'EndTime'     => '2016-11-08 17:00:00',
        'ResourceID'  => [
            0
        ],
        'TimezoneID' => '2',
        'Title'      => 'Each 2nd week'
    },
    {
        'Title'      => 'Each 2nd week',
        'TimezoneID' => '2',
        'ResourceID' => [
            0
        ],
        'EndTime'     => '2016-11-22 17:00:00',
        'StartTime'   => '2016-11-22 16:00:00',
        'Description' => 'Developer meeting each 2nd Tuesday',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'TeamID'      => undef,
        'ParentID'    => '2054',
        'Recurring'   => undef,

        'Location' => undef
    },
    {
        'ResourceID' => [
            0
        ],
        'EndTime'    => '2016-12-06 17:00:00',
        'TimezoneID' => '2',
        'Title'      => 'Each 2nd week',
        'Recurring'  => undef,

        'Location'    => undef,
        'TeamID'      => undef,
        'ParentID'    => '2054',
        'Description' => 'Developer meeting each 2nd Tuesday',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'StartTime'   => '2016-12-06 16:00:00'
    },
    {
        'EndTime'    => '2016-12-20 17:00:00',
        'ResourceID' => [
            0
        ],
        'Title'      => 'Each 2nd week',
        'TimezoneID' => '2',
        'ParentID'   => '2054',
        'TeamID'     => undef,

        'Location' => undef,

        'Recurring'   => undef,
        'StartTime'   => '2016-12-20 16:00:00',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'Description' => 'Developer meeting each 2nd Tuesday'
    },
    {
        'Title'      => 'Custom 1',
        'TimezoneID' => '2',
        'ResourceID' => [
            0
        ],
        'EndTime'     => '2016-01-11 10:00:00',
        'StartTime'   => '2016-01-11 09:00:00',
        'AllDay'      => undef,
        'Description' => 'Start at Monday and repeat each 2nd Wednesday and Sunday.',
        'CalendarID'  => $Calendar{CalendarID},
        'TeamID'      => undef,
        'ParentID'    => undef,

        'Recurring' => '1',
        'Location'  => undef,

    },
    {
        'StartTime'   => '2016-01-25 09:00:00',
        'AllDay'      => undef,
        'Description' => 'Start at Monday and repeat each 2nd Wednesday and Sunday.',
        'CalendarID'  => $Calendar{CalendarID},
        'TeamID'      => undef,
        'ParentID'    => '2073',
        'Recurring'   => undef,

        'Location'   => undef,
        'Title'      => 'Custom 1',
        'TimezoneID' => '2',
        'ResourceID' => [
            0
        ],
        'EndTime' => '2016-01-25 10:00:00'
    },
    {
        'ResourceID' => [
            0
        ],
        'EndTime'    => '2016-02-08 10:00:00',
        'Title'      => 'Custom 1',
        'TimezoneID' => '2',
        'TeamID'     => undef,
        'ParentID'   => '2073',
        'Recurring'  => undef,

        'Location' => undef,

        'StartTime'   => '2016-02-08 09:00:00',
        'Description' => 'Start at Monday and repeat each 2nd Wednesday and Sunday.',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
    },
    {
        'Title'      => 'Custom 1',
        'TimezoneID' => '2',
        'EndTime'    => '2016-02-22 10:00:00',
        'ResourceID' => [
            0
        ],
        'StartTime'   => '2016-02-22 09:00:00',
        'CalendarID'  => $Calendar{CalendarID},
        'Description' => 'Start at Monday and repeat each 2nd Wednesday and Sunday.',
        'AllDay'      => undef,
        'ParentID'    => '2073',
        'TeamID'      => undef,

        'Location'  => undef,
        'Recurring' => undef,

    },
    {

        'Recurring' => undef,

        'Location'    => undef,
        'TeamID'      => undef,
        'ParentID'    => '2073',
        'Description' => 'Start at Monday and repeat each 2nd Wednesday and Sunday.',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'StartTime'   => '2016-03-07 09:00:00',
        'ResourceID'  => [
            0
        ],
        'EndTime'    => '2016-03-07 10:00:00',
        'TimezoneID' => '2',
        'Title'      => 'Custom 1'
    },
    {
        'TimezoneID' => '2',
        'Title'      => 'Custom 1',
        'ResourceID' => [
            0
        ],
        'EndTime'     => '2016-03-21 10:00:00',
        'Description' => 'Start at Monday and repeat each 2nd Wednesday and Sunday.',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'StartTime'   => '2016-03-21 09:00:00',

        'Recurring' => undef,
        'Location'  => undef,

        'TeamID'   => undef,
        'ParentID' => '2073'
    },
    {

        'Location'  => undef,
        'Recurring' => '1',

        'ParentID'    => undef,
        'TeamID'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'AllDay'      => undef,
        'StartTime'   => '2016-01-12 09:00:00',
        'EndTime'     => '2016-01-12 10:00:00',
        'ResourceID'  => [
            0
        ],
        'TimezoneID' => '2',
        'Title'      => 'Custom 2'
    },
    {

        'Recurring' => undef,
        'Location'  => undef,

        'TeamID'      => undef,
        'ParentID'    => '2079',
        'AllDay'      => undef,
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'CalendarID'  => $Calendar{CalendarID},
        'StartTime'   => '2016-02-12 09:00:00',
        'ResourceID'  => [
            0
        ],
        'EndTime'    => '2016-02-12 10:00:00',
        'TimezoneID' => '2',
        'Title'      => 'Custom 2'
    },
    {
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'StartTime'   => '2016-03-12 09:00:00',
        'Recurring'   => undef,

        'Location'   => undef,
        'TeamID'     => undef,
        'ParentID'   => '2079',
        'TimezoneID' => '2',
        'Title'      => 'Custom 2',
        'ResourceID' => [
            0
        ],
        'EndTime' => '2016-03-12 10:00:00'
    },
    {
        'ResourceID' => [
            0
        ],
        'EndTime'    => '2016-04-12 10:00:00',
        'Title'      => 'Custom 2',
        'TimezoneID' => '2',
        'TeamID'     => undef,
        'ParentID'   => '2079',

        'Recurring' => undef,
        'Location'  => undef,

        'StartTime'   => '2016-04-12 09:00:00',
        'AllDay'      => undef,
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'CalendarID'  => $Calendar{CalendarID},
    },
    {
        'EndTime'    => '2016-05-12 10:00:00',
        'ResourceID' => [
            0
        ],
        'Title'      => 'Custom 2',
        'TimezoneID' => '2',
        'ParentID'   => '2079',
        'TeamID'     => undef,
        'Location'   => undef,

        'Recurring'   => undef,
        'StartTime'   => '2016-05-12 09:00:00',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.'
    },
    {
        'TeamID'    => undef,
        'ParentID'  => '2079',
        'Recurring' => undef,

        'Location' => undef,

        'StartTime'   => '2016-06-12 09:00:00',
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'ResourceID'  => [
            0
        ],
        'EndTime'    => '2016-06-12 10:00:00',
        'Title'      => 'Custom 2',
        'TimezoneID' => '2'
    },
    {

        'Location' => undef,

        'Recurring'   => undef,
        'ParentID'    => '2079',
        'TeamID'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'AllDay'      => undef,
        'StartTime'   => '2016-07-12 09:00:00',
        'EndTime'     => '2016-07-12 10:00:00',
        'ResourceID'  => [
            0
        ],
        'TimezoneID' => '2',
        'Title'      => 'Custom 2'
    },
    {

        'Location'  => undef,
        'Recurring' => undef,

        'ParentID'    => '2079',
        'TeamID'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'AllDay'      => undef,
        'StartTime'   => '2016-08-12 09:00:00',
        'EndTime'     => '2016-08-12 10:00:00',
        'ResourceID'  => [
            0
        ],
        'TimezoneID' => '2',
        'Title'      => 'Custom 2'
    },
    {
        'ParentID' => '2079',
        'TeamID'   => undef,

        'Location' => undef,

        'Recurring'   => undef,
        'StartTime'   => '2016-09-12 09:00:00',
        'CalendarID'  => $Calendar{CalendarID},
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'AllDay'      => undef,
        'EndTime'     => '2016-09-12 10:00:00',
        'ResourceID'  => [
            0
        ],
        'Title'      => 'Custom 2',
        'TimezoneID' => '2'
    },
    {
        'StartTime'   => '2016-10-12 09:00:00',
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'AllDay'      => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'TeamID'      => undef,
        'ParentID'    => '2079',
        'Recurring'   => undef,

        'Location'   => undef,
        'Title'      => 'Custom 2',
        'TimezoneID' => '2',
        'ResourceID' => [
            0
        ],
        'EndTime' => '2016-10-12 10:00:00'
    },
    {
        'ParentID' => '2079',
        'TeamID'   => undef,

        'Location' => undef,

        'Recurring'   => undef,
        'StartTime'   => '2016-11-12 09:00:00',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'EndTime'     => '2016-11-12 10:00:00',
        'ResourceID'  => [
            0
        ],
        'Title'      => 'Custom 2',
        'TimezoneID' => '2'
    },
    {
        'ParentID' => '2079',
        'TeamID'   => undef,
        'Location' => undef,

        'Recurring'   => undef,
        'StartTime'   => '2016-12-12 09:00:00',
        'CalendarID'  => $Calendar{CalendarID},
        'AllDay'      => undef,
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'EndTime'     => '2016-12-12 10:00:00',
        'ResourceID'  => [
            0
        ],
        'Title'      => 'Custom 2',
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
