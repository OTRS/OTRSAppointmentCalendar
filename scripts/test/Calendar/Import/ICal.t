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
my $TeamObject  = $Kernel::OM->Get('Kernel::System::Calendar::Team');

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

# create test team
$Success = $TeamObject->TeamAdd(
    Name    => 'Test Team',
    GroupID => 1,             # admin
    ValidID => 1,
    UserID  => 1,             # root
);

$Self->True(
    $Success,
    'TeamAdd() - Test team created',
);

my %Team = $TeamObject->TeamGet(
    Name   => 'Test Team',
    UserID => 1,
);

$Success = $TeamObject->TeamUserAdd(
    TeamID     => $Team{ID},
    TeamUserID => 1,           # root
    UserID     => 1,
);

$Self->True(
    $Success,
    'TeamUserAdd() - Added root user to test team',
);

# this will be ok
my %Calendar = $CalendarObject->CalendarCreate(
    CalendarName => 'Test calendar',
    Color        => '#3A87AD',
    GroupID      => $GroupID,
    UserID       => $UserID,
);

$Self->True(
    $Calendar{CalendarID},
    "CalendarCreate( CalendarName => 'Test calendar', Color => '#3A87AD', GroupID => $GroupID, UserID => $UserID ) - CalendarID",
);

# read sample .ics file
my $Content = $Kernel::OM->Get('Kernel::System::Main')->FileRead(
    Directory => $Kernel::OM->Get('Kernel::Config')->{Home} . '/scripts/test/sample/Calendar/',
    Filename  => 'SampleCalendar.ics',
);

$Self->True(
    ${$Content},
    '.ics string loaded',
);

my $ImportSuccess = $Kernel::OM->Get('Kernel::System::Calendar::Import::ICal')->Import(
    CalendarID => $Calendar{CalendarID},
    ICal       => ${$Content},
    UserID     => $UserID,
    UntilLimit => '2018-01-01 00:00:00',
);

$Self->True(
    $ImportSuccess,
    'Import success',
);

my @Appointments = $AppointmentObject->AppointmentList(
    CalendarID => $Calendar{CalendarID},
    Result     => 'HASH',
);

$Self->Is(
    scalar @Appointments,
    171,
    'Appointment count',
);

my @Result = (
    {
        'TeamID'     => [ $Team{ID} ],
        'StartTime'  => '2016-04-05 00:00:00',
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'All day',
        'TimezoneID' => '0',

        'ResourceID' => [
            '1'
        ],
        'EndTime'     => '2016-04-06 00:00:00',
        'Recurring'   => undef,
        'Description' => 'test all day event',
        'Location'    => undef,
        'AllDay'      => '1',

    },
    {
        'StartTime' => '2016-04-12 11:30:00',

        'TeamID'      => [],
        'TimezoneID'  => '2',
        'Title'       => 'Once per week',
        'CalendarID'  => $Calendar{CalendarID},
        'Description' => 'Only once per week',
        'Location'    => 'Belgrade',

        'ResourceID' => [
            0
        ],
        'EndTime'   => '2016-04-12 12:00:00',
        'Recurring' => '1',

        'AllDay' => undef
    },
    {

        'StartTime'  => '2016-04-19 11:30:00',
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Once per week',
        'TeamID'     => [],
        'TimezoneID' => '2',
        'ResourceID' => [
            0
        ],

        'EndTime'     => '2016-04-19 12:00:00',
        'Recurring'   => undef,
        'Description' => 'Only once per week',
        'Location'    => 'Belgrade',
        'AllDay'      => undef,

    },
    {

        'StartTime'  => '2016-04-26 11:30:00',
        'Title'      => 'Once per week',
        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => [],
        'TimezoneID' => '2',

        'ResourceID' => [
            0
        ],
        'EndTime'     => '2016-04-26 12:00:00',
        'Recurring'   => undef,
        'Description' => 'Only once per week',
        'Location'    => 'Belgrade',
        'AllDay'      => undef,

    },
    {
        'StartTime' => '2016-05-03 11:30:00',

        'TeamID'      => [],
        'TimezoneID'  => '2',
        'CalendarID'  => $Calendar{CalendarID},
        'Title'       => 'Once per week',
        'Description' => 'Only once per week',
        'Location'    => 'Belgrade',
        'ResourceID'  => [
            0
        ],

        'Recurring' => undef,
        'EndTime'   => '2016-05-03 12:00:00',

        'AllDay' => undef
    },
    {
        'AllDay' => undef,

        'Recurring' => undef,
        'EndTime'   => '2016-05-10 12:00:00',

        'ResourceID' => [
            0
        ],
        'Location'    => 'Belgrade',
        'Description' => 'Only once per week',
        'Title'       => 'Once per week',
        'CalendarID'  => $Calendar{CalendarID},
        'TimezoneID'  => '2',
        'TeamID'      => [],

        'StartTime' => '2016-05-10 11:30:00'
    },
    {

        'StartTime'  => '2016-05-17 11:30:00',
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Once per week',
        'TimezoneID' => '2',
        'TeamID'     => [],
        'EndTime'    => '2016-05-17 12:00:00',
        'Recurring'  => undef,

        'ResourceID' => [
            0
        ],
        'Location'    => 'Belgrade',
        'Description' => 'Only once per week',
        'AllDay'      => undef,

    },
    {
        'AllDay' => undef,

        'ResourceID' => [
            0
        ],
        'EndTime'     => '2016-05-24 12:00:00',
        'Recurring'   => undef,
        'Description' => 'Only once per week',
        'Location'    => 'Belgrade',
        'Title'       => 'Once per week',
        'CalendarID'  => $Calendar{CalendarID},
        'TeamID'      => [],
        'TimezoneID'  => '2',

        'StartTime' => '2016-05-24 11:30:00'
    },
    {

        'StartTime'  => '2016-05-31 11:30:00',
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Once per week',
        'TimezoneID' => '2',
        'TeamID'     => [],
        'EndTime'    => '2016-05-31 12:00:00',
        'Recurring'  => undef,
        'ResourceID' => [
            0
        ],

        'Location'    => 'Belgrade',
        'Description' => 'Only once per week',
        'AllDay'      => undef,

    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Once per week',
        'TimezoneID' => '2',
        'TeamID'     => [],

        'StartTime' => '2016-06-07 11:30:00',
        'AllDay'    => undef,

        'EndTime'    => '2016-06-07 12:00:00',
        'Recurring'  => undef,
        'ResourceID' => [
            0
        ],

        'Location'    => 'Belgrade',
        'Description' => 'Only once per week'
    },
    {

        'AllDay'      => undef,
        'Description' => 'Once per month',
        'Location'    => 'Germany',
        'ResourceID'  => [
            0
        ],

        'Recurring'  => '1',
        'EndTime'    => '2016-04-12 14:00:00',
        'TeamID'     => [],
        'TimezoneID' => '2',
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Monthly meeting',
        'StartTime'  => '2016-04-12 13:15:00',

    },
    {
        'StartTime' => '2016-05-12 13:15:00',

        'TimezoneID'  => '2',
        'TeamID'      => [],
        'Title'       => 'Monthly meeting',
        'CalendarID'  => $Calendar{CalendarID},
        'Location'    => 'Germany',
        'Description' => 'Once per month',
        'Recurring'   => undef,
        'EndTime'     => '2016-05-12 14:00:00',

        'ResourceID' => [
            0
        ],

        'AllDay' => undef
    },
    {
        'Title'      => 'Monthly meeting',
        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => [],
        'TimezoneID' => '2',

        'StartTime' => '2016-06-12 13:15:00',
        'AllDay'    => undef,

        'ResourceID' => [
            0
        ],

        'EndTime'     => '2016-06-12 14:00:00',
        'Recurring'   => undef,
        'Description' => 'Once per month',
        'Location'    => 'Germany'
    },
    {
        'Title'      => 'Monthly meeting',
        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => [],
        'TimezoneID' => '2',

        'StartTime' => '2016-07-12 13:15:00',
        'AllDay'    => undef,

        'ResourceID' => [
            0
        ],
        'Recurring'   => undef,
        'EndTime'     => '2016-07-12 14:00:00',
        'Description' => 'Once per month',
        'Location'    => 'Germany'
    },
    {
        'TimezoneID' => '2',
        'TeamID'     => [],
        'Title'      => 'Monthly meeting',
        'CalendarID' => $Calendar{CalendarID},
        'StartTime'  => '2016-08-12 13:15:00',

        'AllDay'      => undef,
        'Location'    => 'Germany',
        'Description' => 'Once per month',
        'EndTime'     => '2016-08-12 14:00:00',
        'Recurring'   => undef,

        'ResourceID' => [
            0
            ]
    },
    {

        'StartTime'  => '2016-09-12 13:15:00',
        'Title'      => 'Monthly meeting',
        'CalendarID' => $Calendar{CalendarID},
        'TimezoneID' => '2',
        'TeamID'     => [],
        'Recurring'  => undef,
        'EndTime'    => '2016-09-12 14:00:00',

        'ResourceID' => [
            0
        ],
        'Location'    => 'Germany',
        'Description' => 'Once per month',
        'AllDay'      => undef,

    },
    {
        'Recurring' => undef,
        'EndTime'   => '2016-10-12 14:00:00',

        'ResourceID' => [
            0
        ],
        'Location'    => 'Germany',
        'Description' => 'Once per month',
        'AllDay'      => undef,

        'StartTime'  => '2016-10-12 13:15:00',
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Monthly meeting',
        'TimezoneID' => '2',
        'TeamID'     => []
    },
    {

        'AllDay'      => undef,
        'Description' => 'Once per month',
        'Location'    => 'Germany',
        'ResourceID'  => [
            0
        ],

        'EndTime'    => '2016-11-12 14:00:00',
        'Recurring'  => undef,
        'TeamID'     => [],
        'TimezoneID' => '2',
        'Title'      => 'Monthly meeting',
        'CalendarID' => $Calendar{CalendarID},
        'StartTime'  => '2016-11-12 13:15:00',

    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Monthly meeting',
        'TeamID'     => [],
        'TimezoneID' => '2',

        'StartTime' => '2016-12-12 13:15:00',
        'AllDay'    => undef,

        'ResourceID' => [
            0
        ],

        'EndTime'     => '2016-12-12 14:00:00',
        'Recurring'   => undef,
        'Description' => 'Once per month',
        'Location'    => 'Germany'
    },
    {

        'StartTime'  => '2017-01-12 13:15:00',
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Monthly meeting',
        'TeamID'     => [],
        'TimezoneID' => '2',
        'ResourceID' => [
            0
        ],

        'EndTime'     => '2017-01-12 14:00:00',
        'Recurring'   => undef,
        'Description' => 'Once per month',
        'Location'    => 'Germany',
        'AllDay'      => undef,

    },
    {

        'AllDay'      => undef,
        'Location'    => 'Germany',
        'Description' => 'Once per month',
        'EndTime'     => '2017-02-12 14:00:00',
        'Recurring'   => undef,
        'ResourceID'  => [
            0
        ],

        'TimezoneID' => '2',
        'TeamID'     => [],
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Monthly meeting',
        'StartTime'  => '2017-02-12 13:15:00',

    },
    {

        'StartTime'  => '2016-03-31 08:00:00',
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'End of the month',
        'TeamID'     => [],
        'TimezoneID' => '2',
        'ResourceID' => [
            0
        ],

        'Recurring'   => '1',
        'EndTime'     => '2016-03-31 09:00:00',
        'Description' => undef,
        'Location'    => undef,
        'AllDay'      => undef,

    },
    {

        'StartTime'  => '2016-04-30 08:00:00',
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'End of the month',
        'TeamID'     => [],
        'TimezoneID' => '2',
        'ResourceID' => [
            0
        ],

        'Recurring'   => undef,
        'EndTime'     => '2016-04-30 09:00:00',
        'Description' => undef,
        'Location'    => undef,
        'AllDay'      => undef,

    },
    {
        'AllDay' => undef,

        'EndTime'   => '2016-05-31 09:00:00',
        'Recurring' => undef,

        'ResourceID' => [
            0
        ],
        'Location'    => undef,
        'Description' => undef,
        'Title'       => 'End of the month',
        'CalendarID'  => $Calendar{CalendarID},
        'TimezoneID'  => '2',
        'TeamID'      => [],

        'StartTime' => '2016-05-31 08:00:00'
    },
    {

        'AllDay'      => undef,
        'Location'    => undef,
        'Description' => undef,
        'Recurring'   => undef,
        'EndTime'     => '2016-06-30 09:00:00',
        'ResourceID'  => [
            0
        ],

        'TimezoneID' => '2',
        'TeamID'     => [],
        'Title'      => 'End of the month',
        'CalendarID' => $Calendar{CalendarID},
        'StartTime'  => '2016-06-30 08:00:00',

    },
    {
        'ResourceID' => [
            0
        ],

        'EndTime'     => '2016-07-31 09:00:00',
        'Recurring'   => undef,
        'Description' => undef,
        'Location'    => undef,
        'AllDay'      => undef,

        'StartTime'  => '2016-07-31 08:00:00',
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'End of the month',
        'TeamID'     => [],
        'TimezoneID' => '2'
    },
    {
        'AllDay' => undef,

        'ResourceID' => [
            0
        ],
        'Recurring'   => undef,
        'EndTime'     => '2016-08-31 09:00:00',
        'Description' => undef,
        'Location'    => undef,
        'Title'       => 'End of the month',
        'CalendarID'  => $Calendar{CalendarID},
        'TeamID'      => [],
        'TimezoneID'  => '2',

        'StartTime' => '2016-08-31 08:00:00'
    },
    {

        'StartTime'  => '2016-09-30 08:00:00',
        'Title'      => 'End of the month',
        'CalendarID' => $Calendar{CalendarID},
        'TimezoneID' => '2',
        'TeamID'     => [],
        'EndTime'    => '2016-09-30 09:00:00',
        'Recurring'  => undef,
        'ResourceID' => [
            0
        ],

        'Location'    => undef,
        'Description' => undef,
        'AllDay'      => undef,

    },
    {
        'Title'      => 'End of the month',
        'CalendarID' => $Calendar{CalendarID},
        'TimezoneID' => '2',
        'TeamID'     => [],

        'StartTime' => '2016-10-31 08:00:00',
        'AllDay'    => undef,

        'Recurring'  => undef,
        'EndTime'    => '2016-10-31 09:00:00',
        'ResourceID' => [
            0
        ],

        'Location'    => undef,
        'Description' => undef
    },
    {
        'ResourceID' => [
            0
        ],

        'Recurring'   => undef,
        'EndTime'     => '2016-11-30 09:00:00',
        'Description' => undef,
        'Location'    => undef,
        'AllDay'      => undef,

        'StartTime'  => '2016-11-30 08:00:00',
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'End of the month',
        'TeamID'     => [],
        'TimezoneID' => '2'
    },
    {
        'StartTime' => '2016-12-31 08:00:00',

        'TeamID'      => [],
        'TimezoneID'  => '2',
        'Title'       => 'End of the month',
        'CalendarID'  => $Calendar{CalendarID},
        'Description' => undef,
        'Location'    => undef,
        'ResourceID'  => [
            0
        ],

        'Recurring' => undef,
        'EndTime'   => '2016-12-31 09:00:00',

        'AllDay' => undef
    },
    {
        'AllDay' => undef,

        'EndTime'   => '2017-01-31 09:00:00',
        'Recurring' => undef,

        'ResourceID' => [
            0
        ],
        'Location'    => undef,
        'Description' => undef,
        'Title'       => 'End of the month',
        'CalendarID'  => $Calendar{CalendarID},
        'TimezoneID'  => '2',
        'TeamID'      => [],

        'StartTime' => '2017-01-31 08:00:00'
    },
    {
        'TeamID'     => [],
        'TimezoneID' => '2',
        'Title'      => 'End of the month',
        'CalendarID' => $Calendar{CalendarID},
        'StartTime'  => '2017-02-28 08:00:00',

        'AllDay'      => undef,
        'Description' => undef,
        'Location'    => undef,
        'ResourceID'  => [
            0
        ],

        'EndTime'   => '2017-02-28 09:00:00',
        'Recurring' => undef
    },
    {
        'StartTime' => '2016-01-31 10:00:00',

        'TimezoneID'  => '2',
        'TeamID'      => [],
        'Title'       => 'Each 2 months',
        'CalendarID'  => $Calendar{CalendarID},
        'Location'    => 'Test',
        'Description' => 'test',
        'Recurring'   => '1',
        'EndTime'     => '2016-01-31 11:00:00',
        'ResourceID'  => [
            0
        ],

        'AllDay' => undef
    },
    {
        'Location'    => 'Test',
        'Description' => 'test',
        'EndTime'     => '2016-03-31 11:00:00',
        'Recurring'   => undef,

        'ResourceID' => [
            0
        ],

        'AllDay'    => undef,
        'StartTime' => '2016-03-31 10:00:00',

        'TimezoneID' => '2',
        'TeamID'     => [],
        'Title'      => 'Each 2 months',
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'AllDay' => undef,

        'ResourceID' => [
            0
        ],
        'Recurring'   => undef,
        'EndTime'     => '2016-05-31 11:00:00',
        'Description' => 'test',
        'Location'    => 'Test',
        'Title'       => 'Each 2 months',
        'CalendarID'  => $Calendar{CalendarID},
        'TeamID'      => [],
        'TimezoneID'  => '2',

        'StartTime' => '2016-05-31 10:00:00'
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 2 months',
        'TimezoneID' => '2',
        'TeamID'     => [],

        'StartTime' => '2016-07-31 10:00:00',
        'AllDay'    => undef,

        'Recurring' => undef,
        'EndTime'   => '2016-07-31 11:00:00',

        'ResourceID' => [
            0
        ],
        'Location'    => 'Test',
        'Description' => 'test'
    },
    {

        'AllDay'      => undef,
        'Description' => 'test',
        'Location'    => 'Test',
        'ResourceID'  => [
            0
        ],

        'Recurring'  => undef,
        'EndTime'    => '2017-01-31 11:00:00',
        'TeamID'     => [],
        'TimezoneID' => '2',
        'Title'      => 'Each 2 months',
        'CalendarID' => $Calendar{CalendarID},
        'StartTime'  => '2017-01-31 10:00:00',

    },
    {
        'AllDay' => undef,

        'ResourceID' => [
            0
        ],

        'Recurring'   => '1',
        'EndTime'     => '2016-04-12 10:00:00',
        'Description' => 'Test description',
        'Location'    => 'Stara Pazova',
        'Title'       => 'My event',
        'CalendarID'  => $Calendar{CalendarID},
        'TeamID'      => [],
        'TimezoneID'  => '2',

        'StartTime' => '2016-04-12 09:00:00'
    },
    {
        'Description' => 'Test description',
        'Location'    => 'Stara Pazova',

        'ResourceID' => [
            0
        ],
        'EndTime'   => '2016-04-14 10:00:00',
        'Recurring' => undef,

        'AllDay'    => undef,
        'StartTime' => '2016-04-14 09:00:00',

        'TeamID'     => [],
        'TimezoneID' => '2',
        'Title'      => 'My event',
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'Description' => 'Test description',
        'Location'    => 'Stara Pazova',
        'ResourceID'  => [
            0
        ],

        'EndTime'   => '2016-04-16 10:00:00',
        'Recurring' => undef,

        'AllDay'    => undef,
        'StartTime' => '2016-04-16 09:00:00',

        'TeamID'     => [],
        'TimezoneID' => '2',
        'Title'      => 'My event',
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'TeamID'     => [],
        'TimezoneID' => '2',
        'Title'      => 'My event',
        'CalendarID' => $Calendar{CalendarID},
        'StartTime'  => '2016-04-18 09:00:00',

        'AllDay'      => undef,
        'Description' => 'Test description',
        'Location'    => 'Stara Pazova',
        'ResourceID'  => [
            0
        ],

        'Recurring' => undef,
        'EndTime'   => '2016-04-18 10:00:00'
    },
    {
        'Location'    => 'Stara Pazova',
        'Description' => 'Test description',
        'Recurring'   => undef,
        'EndTime'     => '2016-04-20 10:00:00',
        'ResourceID'  => [
            0
        ],

        'AllDay'    => undef,
        'StartTime' => '2016-04-20 09:00:00',

        'TimezoneID' => '2',
        'TeamID'     => [],
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'My event'
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'My event',
        'TimezoneID' => '2',
        'TeamID'     => [],

        'StartTime' => '2016-04-22 09:00:00',
        'AllDay'    => undef,

        'Recurring'  => undef,
        'EndTime'    => '2016-04-22 10:00:00',
        'ResourceID' => [
            0
        ],

        'Location'    => 'Stara Pazova',
        'Description' => 'Test description'
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'My event',
        'TimezoneID' => '2',
        'TeamID'     => [],

        'StartTime' => '2016-04-24 09:00:00',
        'AllDay'    => undef,

        'EndTime'   => '2016-04-24 10:00:00',
        'Recurring' => undef,

        'ResourceID' => [
            0
        ],
        'Location'    => 'Stara Pazova',
        'Description' => 'Test description'
    },
    {

        'StartTime'  => '2016-04-26 09:00:00',
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'My event',
        'TimezoneID' => '2',
        'TeamID'     => [],
        'Recurring'  => undef,
        'EndTime'    => '2016-04-26 10:00:00',
        'ResourceID' => [
            0
        ],

        'Location'    => 'Stara Pazova',
        'Description' => 'Test description',
        'AllDay'      => undef,

    },
    {
        'EndTime'   => '2016-04-28 10:00:00',
        'Recurring' => undef,

        'ResourceID' => [
            0
        ],
        'Location'    => 'Stara Pazova',
        'Description' => 'Test description',
        'AllDay'      => undef,

        'StartTime'  => '2016-04-28 09:00:00',
        'Title'      => 'My event',
        'CalendarID' => $Calendar{CalendarID},
        'TimezoneID' => '2',
        'TeamID'     => []
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'My event',
        'TimezoneID' => '2',
        'TeamID'     => [],

        'StartTime' => '2016-04-30 09:00:00',
        'AllDay'    => undef,

        'Recurring' => undef,
        'EndTime'   => '2016-04-30 10:00:00',

        'ResourceID' => [
            0
        ],
        'Location'    => 'Stara Pazova',
        'Description' => 'Test description'
    },
    {
        'AllDay' => undef,

        'ResourceID' => [
            0
        ],

        'EndTime'     => '2016-05-02 10:00:00',
        'Recurring'   => undef,
        'Description' => 'Test description',
        'Location'    => 'Stara Pazova',
        'Title'       => 'My event',
        'CalendarID'  => $Calendar{CalendarID},
        'TeamID'      => [],
        'TimezoneID'  => '2',

        'StartTime' => '2016-05-02 09:00:00'
    },
    {
        'TeamID'     => [],
        'TimezoneID' => '2',
        'Title'      => 'My event',
        'CalendarID' => $Calendar{CalendarID},
        'StartTime'  => '2016-05-04 09:00:00',

        'AllDay'      => undef,
        'Description' => 'Test description',
        'Location'    => 'Stara Pazova',

        'ResourceID' => [
            0
        ],
        'EndTime'   => '2016-05-04 10:00:00',
        'Recurring' => undef
    },
    {
        'Location'    => 'Stara Pazova',
        'Description' => 'Test description',
        'EndTime'     => '2016-05-06 10:00:00',
        'Recurring'   => undef,
        'ResourceID'  => [
            0
        ],

        'AllDay'    => undef,
        'StartTime' => '2016-05-06 09:00:00',

        'TimezoneID' => '2',
        'TeamID'     => [],
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'My event'
    },
    {
        'Title'      => 'My event',
        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => [],
        'TimezoneID' => '2',

        'StartTime' => '2016-05-08 09:00:00',
        'AllDay'    => undef,

        'ResourceID' => [
            0
        ],
        'EndTime'     => '2016-05-08 10:00:00',
        'Recurring'   => undef,
        'Description' => 'Test description',
        'Location'    => 'Stara Pazova'
    },
    {
        'StartTime' => '2016-05-10 09:00:00',

        'TimezoneID'  => '2',
        'TeamID'      => [],
        'CalendarID'  => $Calendar{CalendarID},
        'Title'       => 'My event',
        'Location'    => 'Stara Pazova',
        'Description' => 'Test description',
        'Recurring'   => undef,
        'EndTime'     => '2016-05-10 10:00:00',
        'ResourceID'  => [
            0
        ],

        'AllDay' => undef
    },
    {

        'AllDay'      => undef,
        'Description' => 'Test description',
        'Location'    => 'Stara Pazova',
        'ResourceID'  => [
            0
        ],

        'EndTime'    => '2016-05-12 10:00:00',
        'Recurring'  => undef,
        'TeamID'     => [],
        'TimezoneID' => '2',
        'Title'      => 'My event',
        'CalendarID' => $Calendar{CalendarID},
        'StartTime'  => '2016-05-12 09:00:00',

    },
    {
        'Description' => 'Test description',
        'Location'    => 'Stara Pazova',
        'ResourceID'  => [
            0
        ],

        'Recurring' => undef,
        'EndTime'   => '2016-05-14 10:00:00',

        'AllDay'    => undef,
        'StartTime' => '2016-05-14 09:00:00',

        'TeamID'     => [],
        'TimezoneID' => '2',
        'Title'      => 'My event',
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'My event',
        'TeamID'     => [],
        'TimezoneID' => '2',

        'StartTime' => '2016-05-16 09:00:00',
        'AllDay'    => undef,

        'ResourceID' => [
            0
        ],

        'Recurring'   => undef,
        'EndTime'     => '2016-05-16 10:00:00',
        'Description' => 'Test description',
        'Location'    => 'Stara Pazova'
    },
    {
        'StartTime' => '2016-05-18 09:00:00',

        'TimezoneID'  => '2',
        'TeamID'      => [],
        'CalendarID'  => $Calendar{CalendarID},
        'Title'       => 'My event',
        'Location'    => 'Stara Pazova',
        'Description' => 'Test description',
        'EndTime'     => '2016-05-18 10:00:00',
        'Recurring'   => undef,
        'ResourceID'  => [
            0
        ],

        'AllDay' => undef
    },
    {
        'StartTime' => '2016-05-20 09:00:00',

        'TeamID'      => [],
        'TimezoneID'  => '2',
        'CalendarID'  => $Calendar{CalendarID},
        'Title'       => 'My event',
        'Description' => 'Test description',
        'Location'    => 'Stara Pazova',
        'ResourceID'  => [
            0
        ],

        'Recurring' => undef,
        'EndTime'   => '2016-05-20 10:00:00',

        'AllDay' => undef
    },
    {
        'TeamID'     => [],
        'TimezoneID' => '2',
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'My event',
        'StartTime'  => '2016-05-22 09:00:00',

        'AllDay'      => undef,
        'Description' => 'Test description',
        'Location'    => 'Stara Pazova',

        'ResourceID' => [
            0
        ],
        'Recurring' => undef,
        'EndTime'   => '2016-05-22 10:00:00'
    },
    {
        'EndTime'    => '2016-05-24 10:00:00',
        'Recurring'  => undef,
        'ResourceID' => [
            0
        ],

        'Location'    => 'Stara Pazova',
        'Description' => 'Test description',
        'AllDay'      => undef,

        'StartTime'  => '2016-05-24 09:00:00',
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'My event',
        'TimezoneID' => '2',
        'TeamID'     => []
    },
    {

        'AllDay'      => undef,
        'Description' => 'Test description',
        'Location'    => 'Stara Pazova',

        'ResourceID' => [
            0
        ],
        'Recurring'  => undef,
        'EndTime'    => '2016-05-26 10:00:00',
        'TeamID'     => [],
        'TimezoneID' => '2',
        'Title'      => 'My event',
        'CalendarID' => $Calendar{CalendarID},
        'StartTime'  => '2016-05-26 09:00:00',

    },
    {
        'Location'    => 'Stara Pazova',
        'Description' => 'Test description',
        'EndTime'     => '2016-05-28 10:00:00',
        'Recurring'   => undef,

        'ResourceID' => [
            0
        ],

        'AllDay'    => undef,
        'StartTime' => '2016-05-28 09:00:00',

        'TimezoneID' => '2',
        'TeamID'     => [],
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'My event'
    },
    {

        'StartTime'  => '2016-05-30 09:00:00',
        'Title'      => 'My event',
        'CalendarID' => $Calendar{CalendarID},
        'TimezoneID' => '2',
        'TeamID'     => [],
        'EndTime'    => '2016-05-30 10:00:00',
        'Recurring'  => undef,

        'ResourceID' => [
            0
        ],
        'Location'    => 'Stara Pazova',
        'Description' => 'Test description',
        'AllDay'      => undef,

    },
    {

        'AllDay'      => undef,
        'Description' => 'Test description',
        'Location'    => 'Stara Pazova',

        'ResourceID' => [
            0
        ],
        'EndTime'    => '2016-06-01 10:00:00',
        'Recurring'  => undef,
        'TeamID'     => [],
        'TimezoneID' => '2',
        'Title'      => 'My event',
        'CalendarID' => $Calendar{CalendarID},
        'StartTime'  => '2016-06-01 09:00:00',

    },
    {
        'ResourceID' => [
            0
        ],

        'EndTime'     => '2016-04-01 11:00:00',
        'Recurring'   => '1',
        'Description' => undef,
        'Location'    => undef,
        'AllDay'      => undef,

        'StartTime'  => '2016-04-01 10:00:00',
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 2 years',
        'TeamID'     => [],
        'TimezoneID' => '2'
    },
    {
        'TimezoneID' => '2',
        'TeamID'     => [],
        'Title'      => 'Each 2 years',
        'CalendarID' => $Calendar{CalendarID},
        'StartTime'  => '2018-04-01 10:00:00',

        'AllDay'      => undef,
        'Location'    => undef,
        'Description' => undef,
        'Recurring'   => undef,
        'EndTime'     => '2018-04-01 11:00:00',
        'ResourceID'  => [
            0
        ],

    },
    {
        'TimezoneID' => '2',
        'TeamID'     => [],
        'Title'      => 'Each 2 years',
        'CalendarID' => $Calendar{CalendarID},
        'StartTime'  => '2020-04-01 10:00:00',

        'AllDay'      => undef,
        'Location'    => undef,
        'Description' => undef,
        'EndTime'     => '2020-04-01 11:00:00',
        'Recurring'   => undef,

        'ResourceID' => [
            0
            ]
    },
    {
        'TeamID'     => [],
        'TimezoneID' => '0',
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 3thd all day',
        'StartTime'  => '2016-04-02 00:00:00',

        'AllDay'      => '1',
        'Description' => undef,
        'Location'    => undef,
        'ResourceID'  => [
            0
        ],

        'EndTime'   => '2016-04-03 00:00:00',
        'Recurring' => '1'
    },
    {

        'StartTime'  => '2016-04-05 00:00:00',
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 3thd all day',
        'TimezoneID' => '0',
        'TeamID'     => [],
        'Recurring'  => undef,
        'EndTime'    => '2016-04-06 00:00:00',

        'ResourceID' => [
            0
        ],
        'Location'    => undef,
        'Description' => undef,
        'AllDay'      => '1',

    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 3thd all day',
        'TimezoneID' => '0',
        'TeamID'     => [],

        'StartTime' => '2016-04-08 00:00:00',
        'AllDay'    => '1',

        'Recurring'  => undef,
        'EndTime'    => '2016-04-09 00:00:00',
        'ResourceID' => [
            0
        ],

        'Location'    => undef,
        'Description' => undef
    },
    {

        'AllDay'      => '1',
        'Description' => undef,
        'Location'    => undef,
        'ResourceID'  => [
            0
        ],

        'EndTime'    => '2016-04-12 00:00:00',
        'Recurring'  => undef,
        'TeamID'     => [],
        'TimezoneID' => '0',
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 3thd all day',
        'StartTime'  => '2016-04-11 00:00:00',

    },
    {
        'StartTime' => '2016-04-14 00:00:00',

        'TeamID'      => [],
        'TimezoneID'  => '0',
        'CalendarID'  => $Calendar{CalendarID},
        'Title'       => 'Each 3thd all day',
        'Description' => undef,
        'Location'    => undef,
        'ResourceID'  => [
            0
        ],

        'Recurring' => undef,
        'EndTime'   => '2016-04-15 00:00:00',

        'AllDay' => '1'
    },
    {
        'StartTime' => '2016-04-17 00:00:00',

        'TeamID'      => [],
        'TimezoneID'  => '0',
        'CalendarID'  => $Calendar{CalendarID},
        'Title'       => 'Each 3thd all day',
        'Description' => undef,
        'Location'    => undef,

        'ResourceID' => [
            0
        ],
        'EndTime'   => '2016-04-18 00:00:00',
        'Recurring' => undef,

        'AllDay' => '1'
    },
    {

        'AllDay'      => '1',
        'Location'    => undef,
        'Description' => undef,
        'EndTime'     => '2016-04-21 00:00:00',
        'Recurring'   => undef,
        'ResourceID'  => [
            0
        ],

        'TimezoneID' => '0',
        'TeamID'     => [],
        'Title'      => 'Each 3thd all day',
        'CalendarID' => $Calendar{CalendarID},
        'StartTime'  => '2016-04-20 00:00:00',

    },
    {
        'AllDay' => '1',

        'ResourceID' => [
            0
        ],
        'Recurring'   => undef,
        'EndTime'     => '2016-04-24 00:00:00',
        'Description' => undef,
        'Location'    => undef,
        'Title'       => 'Each 3thd all day',
        'CalendarID'  => $Calendar{CalendarID},
        'TeamID'      => [],
        'TimezoneID'  => '0',

        'StartTime' => '2016-04-23 00:00:00'
    },
    {

        'AllDay'      => '1',
        'Location'    => undef,
        'Description' => undef,
        'Recurring'   => undef,
        'EndTime'     => '2016-04-27 00:00:00',

        'ResourceID' => [
            0
        ],
        'TimezoneID' => '0',
        'TeamID'     => [],
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 3thd all day',
        'StartTime'  => '2016-04-26 00:00:00',

    },
    {
        'Recurring' => undef,
        'EndTime'   => '2016-04-30 00:00:00',

        'ResourceID' => [
            0
        ],
        'Location'    => undef,
        'Description' => undef,
        'AllDay'      => '1',

        'StartTime'  => '2016-04-29 00:00:00',
        'Title'      => 'Each 3thd all day',
        'CalendarID' => $Calendar{CalendarID},
        'TimezoneID' => '0',
        'TeamID'     => []
    },
    {
        'AllDay' => undef,

        'EndTime'    => '2016-03-07 17:00:00',
        'Recurring'  => '1',
        'ResourceID' => [
            0
        ],

        'Location'    => undef,
        'Description' => undef,
        'Title'       => 'First 3 days',
        'CalendarID'  => $Calendar{CalendarID},
        'TimezoneID'  => '2',
        'TeamID'      => [],

        'StartTime' => '2016-03-07 16:00:00'
    },
    {
        'ResourceID' => [
            0
        ],

        'EndTime'     => '2016-03-08 17:00:00',
        'Recurring'   => undef,
        'Description' => undef,
        'Location'    => undef,
        'AllDay'      => undef,

        'StartTime'  => '2016-03-08 16:00:00',
        'Title'      => 'First 3 days',
        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => [],
        'TimezoneID' => '2'
    },
    {
        'Title'      => 'First 3 days',
        'CalendarID' => $Calendar{CalendarID},
        'TimezoneID' => '2',
        'TeamID'     => [],

        'StartTime' => '2016-03-09 16:00:00',
        'AllDay'    => undef,

        'EndTime'    => '2016-03-09 17:00:00',
        'Recurring'  => undef,
        'ResourceID' => [
            0
        ],

        'Location'    => undef,
        'Description' => undef
    },
    {

        'StartTime'  => '2016-03-02 18:00:00',
        'Title'      => 'Once per next 2 month',
        'CalendarID' => $Calendar{CalendarID},
        'TimezoneID' => '2',
        'TeamID'     => [],
        'Recurring'  => '1',
        'EndTime'    => '2016-03-02 19:00:00',

        'ResourceID' => [
            0
        ],
        'Location'    => undef,
        'Description' => undef,
        'AllDay'      => undef,

    },
    {
        'TimezoneID' => '2',
        'TeamID'     => [],
        'Title'      => 'Once per next 2 month',
        'CalendarID' => $Calendar{CalendarID},
        'StartTime'  => '2016-04-02 18:00:00',

        'AllDay'      => undef,
        'Location'    => undef,
        'Description' => undef,
        'EndTime'     => '2016-04-02 19:00:00',
        'Recurring'   => undef,

        'ResourceID' => [
            0
            ]
    },
    {
        'Location'    => undef,
        'Description' => undef,
        'EndTime'     => '2016-01-03 19:00:00',
        'Recurring'   => '1',
        'ResourceID'  => [
            0
        ],

        'AllDay'    => undef,
        'StartTime' => '2016-01-03 18:00:00',

        'TimezoneID' => '2',
        'TeamID'     => [],
        'Title'      => 'January 3th next 3 years',
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'TeamID'     => [],
        'TimezoneID' => '2',
        'Title'      => 'January 3th next 3 years',
        'CalendarID' => $Calendar{CalendarID},
        'StartTime'  => '2017-01-03 18:00:00',

        'AllDay'      => undef,
        'Description' => undef,
        'Location'    => undef,

        'ResourceID' => [
            0
        ],
        'EndTime'   => '2017-01-03 19:00:00',
        'Recurring' => undef
    },
    {
        'ResourceID' => [
            0
        ],

        'Recurring'   => undef,
        'EndTime'     => '2018-01-03 19:00:00',
        'Description' => undef,
        'Location'    => undef,
        'AllDay'      => undef,

        'StartTime'  => '2018-01-03 18:00:00',
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'January 3th next 3 years',
        'TeamID'     => [],
        'TimezoneID' => '2'
    },
    {
        'StartTime' => '2016-04-12 16:00:00',

        'TimezoneID'  => '2',
        'TeamID'      => [],
        'CalendarID'  => $Calendar{CalendarID},
        'Title'       => 'Each 2nd week',
        'Location'    => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'EndTime'     => '2016-04-12 17:00:00',
        'Recurring'   => '1',
        'ResourceID'  => [
            0
        ],

        'AllDay' => undef
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 2nd week',
        'TeamID'     => [],
        'TimezoneID' => '2',

        'StartTime' => '2016-04-26 16:00:00',
        'AllDay'    => undef,

        'ResourceID' => [
            0
        ],

        'Recurring'   => undef,
        'EndTime'     => '2016-04-26 17:00:00',
        'Description' => 'Developer meeting each 2nd Tuesday',
        'Location'    => undef
    },
    {
        'StartTime' => '2016-05-10 16:00:00',

        'TeamID'      => [],
        'TimezoneID'  => '2',
        'Title'       => 'Each 2nd week',
        'CalendarID'  => $Calendar{CalendarID},
        'Description' => 'Developer meeting each 2nd Tuesday',
        'Location'    => undef,

        'ResourceID' => [
            0
        ],
        'EndTime'   => '2016-05-10 17:00:00',
        'Recurring' => undef,

        'AllDay' => undef
    },
    {

        'AllDay'      => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'Location'    => undef,

        'ResourceID' => [
            0
        ],
        'Recurring'  => undef,
        'EndTime'    => '2016-05-24 17:00:00',
        'TeamID'     => [],
        'TimezoneID' => '2',
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 2nd week',
        'StartTime'  => '2016-05-24 16:00:00',

    },
    {
        'StartTime' => '2016-06-07 16:00:00',

        'TeamID'      => [],
        'TimezoneID'  => '2',
        'CalendarID'  => $Calendar{CalendarID},
        'Title'       => 'Each 2nd week',
        'Description' => 'Developer meeting each 2nd Tuesday',
        'Location'    => undef,

        'ResourceID' => [
            0
        ],
        'Recurring' => undef,
        'EndTime'   => '2016-06-07 17:00:00',

        'AllDay' => undef
    },
    {

        'StartTime'  => '2016-06-21 16:00:00',
        'Title'      => 'Each 2nd week',
        'CalendarID' => $Calendar{CalendarID},
        'TimezoneID' => '2',
        'TeamID'     => [],
        'EndTime'    => '2016-06-21 17:00:00',
        'Recurring'  => undef,
        'ResourceID' => [
            0
        ],

        'Location'    => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'AllDay'      => undef,

    },
    {
        'AllDay' => undef,

        'Recurring' => undef,
        'EndTime'   => '2016-07-05 17:00:00',

        'ResourceID' => [
            0
        ],
        'Location'    => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'CalendarID'  => $Calendar{CalendarID},
        'Title'       => 'Each 2nd week',
        'TimezoneID'  => '2',
        'TeamID'      => [],

        'StartTime' => '2016-07-05 16:00:00'
    },
    {
        'TeamID'     => [],
        'TimezoneID' => '2',
        'Title'      => 'Each 2nd week',
        'CalendarID' => $Calendar{CalendarID},
        'StartTime'  => '2016-07-19 16:00:00',

        'AllDay'      => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'Location'    => undef,

        'ResourceID' => [
            0
        ],
        'EndTime'   => '2016-07-19 17:00:00',
        'Recurring' => undef
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 2nd week',
        'TimezoneID' => '2',
        'TeamID'     => [],

        'StartTime' => '2016-08-02 16:00:00',
        'AllDay'    => undef,

        'Recurring' => undef,
        'EndTime'   => '2016-08-02 17:00:00',

        'ResourceID' => [
            0
        ],
        'Location'    => undef,
        'Description' => 'Developer meeting each 2nd Tuesday'
    },
    {
        'ResourceID' => [
            0
        ],

        'Recurring'   => undef,
        'EndTime'     => '2016-08-16 17:00:00',
        'Description' => 'Developer meeting each 2nd Tuesday',
        'Location'    => undef,
        'AllDay'      => undef,

        'StartTime'  => '2016-08-16 16:00:00',
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 2nd week',
        'TeamID'     => [],
        'TimezoneID' => '2'
    },
    {
        'Location'    => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'Recurring'   => undef,
        'EndTime'     => '2016-08-30 17:00:00',
        'ResourceID'  => [
            0
        ],

        'AllDay'    => undef,
        'StartTime' => '2016-08-30 16:00:00',

        'TimezoneID' => '2',
        'TeamID'     => [],
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 2nd week'
    },
    {

        'AllDay'      => undef,
        'Location'    => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'EndTime'     => '2016-09-13 17:00:00',
        'Recurring'   => undef,
        'ResourceID'  => [
            0
        ],

        'TimezoneID' => '2',
        'TeamID'     => [],
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 2nd week',
        'StartTime'  => '2016-09-13 16:00:00',

    },
    {
        'Description' => 'Developer meeting each 2nd Tuesday',
        'Location'    => undef,

        'ResourceID' => [
            0
        ],
        'Recurring' => undef,
        'EndTime'   => '2016-09-27 17:00:00',

        'AllDay'    => undef,
        'StartTime' => '2016-09-27 16:00:00',

        'TeamID'     => [],
        'TimezoneID' => '2',
        'Title'      => 'Each 2nd week',
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'Title'      => 'Each 2nd week',
        'CalendarID' => $Calendar{CalendarID},
        'TimezoneID' => '2',
        'TeamID'     => [],

        'StartTime' => '2016-10-11 16:00:00',
        'AllDay'    => undef,

        'EndTime'    => '2016-10-11 17:00:00',
        'Recurring'  => undef,
        'ResourceID' => [
            0
        ],

        'Location'    => undef,
        'Description' => 'Developer meeting each 2nd Tuesday'
    },
    {
        'Recurring' => undef,
        'EndTime'   => '2016-10-25 17:00:00',

        'ResourceID' => [
            0
        ],
        'Location'    => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'AllDay'      => undef,

        'StartTime'  => '2016-10-25 16:00:00',
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 2nd week',
        'TimezoneID' => '2',
        'TeamID'     => []
    },
    {
        'AllDay' => undef,

        'ResourceID' => [
            0
        ],

        'EndTime'     => '2016-11-08 17:00:00',
        'Recurring'   => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'Location'    => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'Title'       => 'Each 2nd week',
        'TeamID'      => [],
        'TimezoneID'  => '2',

        'StartTime' => '2016-11-08 16:00:00'
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 2nd week',
        'TimezoneID' => '2',
        'TeamID'     => [],

        'StartTime' => '2016-11-22 16:00:00',
        'AllDay'    => undef,

        'EndTime'   => '2016-11-22 17:00:00',
        'Recurring' => undef,

        'ResourceID' => [
            0
        ],
        'Location'    => undef,
        'Description' => 'Developer meeting each 2nd Tuesday'
    },
    {
        'AllDay' => undef,

        'ResourceID' => [
            0
        ],

        'Recurring'   => undef,
        'EndTime'     => '2016-12-06 17:00:00',
        'Description' => 'Developer meeting each 2nd Tuesday',
        'Location'    => undef,
        'Title'       => 'Each 2nd week',
        'CalendarID'  => $Calendar{CalendarID},
        'TeamID'      => [],
        'TimezoneID'  => '2',

        'StartTime' => '2016-12-06 16:00:00'
    },
    {

        'ResourceID' => [
            0
        ],
        'Recurring'   => undef,
        'EndTime'     => '2016-12-20 17:00:00',
        'Description' => 'Developer meeting each 2nd Tuesday',
        'Location'    => undef,
        'AllDay'      => undef,

        'StartTime'  => '2016-12-20 16:00:00',
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 2nd week',
        'TeamID'     => [],
        'TimezoneID' => '2'
    },
    {
        'AllDay' => undef,

        'ResourceID' => [
            0
        ],

        'EndTime'     => '2017-01-03 17:00:00',
        'Recurring'   => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'Location'    => undef,
        'Title'       => 'Each 2nd week',
        'CalendarID'  => $Calendar{CalendarID},
        'TeamID'      => [],
        'TimezoneID'  => '2',

        'StartTime' => '2017-01-03 16:00:00'
    },
    {

        'StartTime'  => '2017-01-17 16:00:00',
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 2nd week',
        'TeamID'     => [],
        'TimezoneID' => '2',
        'ResourceID' => [
            0
        ],

        'Recurring'   => undef,
        'EndTime'     => '2017-01-17 17:00:00',
        'Description' => 'Developer meeting each 2nd Tuesday',
        'Location'    => undef,
        'AllDay'      => undef,

    },
    {
        'EndTime'   => '2017-01-31 17:00:00',
        'Recurring' => undef,

        'ResourceID' => [
            0
        ],
        'Location'    => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'AllDay'      => undef,

        'StartTime'  => '2017-01-31 16:00:00',
        'Title'      => 'Each 2nd week',
        'CalendarID' => $Calendar{CalendarID},
        'TimezoneID' => '2',
        'TeamID'     => []
    },
    {
        'AllDay' => undef,

        'EndTime'   => '2017-02-14 17:00:00',
        'Recurring' => undef,

        'ResourceID' => [
            0
        ],
        'Location'    => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'Title'       => 'Each 2nd week',
        'CalendarID'  => $Calendar{CalendarID},
        'TimezoneID'  => '2',
        'TeamID'      => [],

        'StartTime' => '2017-02-14 16:00:00'
    },
    {

        'AllDay'      => undef,
        'Location'    => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'EndTime'     => '2017-02-28 17:00:00',
        'Recurring'   => undef,
        'ResourceID'  => [
            0
        ],

        'TimezoneID' => '2',
        'TeamID'     => [],
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 2nd week',
        'StartTime'  => '2017-02-28 16:00:00',

    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 2nd week',
        'TeamID'     => [],
        'TimezoneID' => '2',

        'StartTime' => '2017-03-14 16:00:00',
        'AllDay'    => undef,

        'ResourceID' => [
            0
        ],
        'Recurring'   => undef,
        'EndTime'     => '2017-03-14 17:00:00',
        'Description' => 'Developer meeting each 2nd Tuesday',
        'Location'    => undef
    },
    {
        'Description' => 'Developer meeting each 2nd Tuesday',
        'Location'    => undef,
        'ResourceID'  => [
            0
        ],

        'EndTime'   => '2017-03-28 17:00:00',
        'Recurring' => undef,

        'AllDay'    => undef,
        'StartTime' => '2017-03-28 16:00:00',

        'TeamID'     => [],
        'TimezoneID' => '2',
        'Title'      => 'Each 2nd week',
        'CalendarID' => $Calendar{CalendarID},
    },
    {

        'AllDay'      => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'Location'    => undef,

        'ResourceID' => [
            0
        ],
        'EndTime'    => '2017-04-11 17:00:00',
        'Recurring'  => undef,
        'TeamID'     => [],
        'TimezoneID' => '2',
        'Title'      => 'Each 2nd week',
        'CalendarID' => $Calendar{CalendarID},
        'StartTime'  => '2017-04-11 16:00:00',

    },
    {
        'ResourceID' => [
            0
        ],

        'Recurring'   => undef,
        'EndTime'     => '2017-04-25 17:00:00',
        'Description' => 'Developer meeting each 2nd Tuesday',
        'Location'    => undef,
        'AllDay'      => undef,

        'StartTime'  => '2017-04-25 16:00:00',
        'Title'      => 'Each 2nd week',
        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => [],
        'TimezoneID' => '2'
    },
    {
        'Location'    => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'EndTime'     => '2017-05-09 17:00:00',
        'Recurring'   => undef,

        'ResourceID' => [
            0
        ],

        'AllDay'    => undef,
        'StartTime' => '2017-05-09 16:00:00',

        'TimezoneID' => '2',
        'TeamID'     => [],
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 2nd week'
    },
    {

        'AllDay'      => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'Location'    => undef,

        'ResourceID' => [
            0
        ],
        'EndTime'    => '2017-05-23 17:00:00',
        'Recurring'  => undef,
        'TeamID'     => [],
        'TimezoneID' => '2',
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 2nd week',
        'StartTime'  => '2017-05-23 16:00:00',

    },
    {
        'TeamID'     => [],
        'TimezoneID' => '2',
        'Title'      => 'Each 2nd week',
        'CalendarID' => $Calendar{CalendarID},
        'StartTime'  => '2017-06-06 16:00:00',

        'AllDay'      => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'Location'    => undef,
        'ResourceID'  => [
            0
        ],

        'EndTime'   => '2017-06-06 17:00:00',
        'Recurring' => undef
    },
    {

        'AllDay'      => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'Location'    => undef,

        'ResourceID' => [
            0
        ],
        'Recurring'  => undef,
        'EndTime'    => '2017-06-20 17:00:00',
        'TeamID'     => [],
        'TimezoneID' => '2',
        'Title'      => 'Each 2nd week',
        'CalendarID' => $Calendar{CalendarID},
        'StartTime'  => '2017-06-20 16:00:00',

    },
    {
        'TeamID'     => [],
        'TimezoneID' => '2',
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 2nd week',
        'StartTime'  => '2017-07-04 16:00:00',

        'AllDay'      => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'Location'    => undef,
        'ResourceID'  => [
            0
        ],

        'EndTime'   => '2017-07-04 17:00:00',
        'Recurring' => undef
    },
    {
        'StartTime' => '2017-07-18 16:00:00',

        'TimezoneID'  => '2',
        'TeamID'      => [],
        'CalendarID'  => $Calendar{CalendarID},
        'Title'       => 'Each 2nd week',
        'Location'    => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'EndTime'     => '2017-07-18 17:00:00',
        'Recurring'   => undef,

        'ResourceID' => [
            0
        ],

        'AllDay' => undef
    },
    {

        'StartTime'  => '2017-08-01 16:00:00',
        'Title'      => 'Each 2nd week',
        'CalendarID' => $Calendar{CalendarID},
        'TimezoneID' => '2',
        'TeamID'     => [],
        'EndTime'    => '2017-08-01 17:00:00',
        'Recurring'  => undef,

        'ResourceID' => [
            0
        ],
        'Location'    => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'AllDay'      => undef,

    },
    {
        'Location'    => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'EndTime'     => '2017-08-15 17:00:00',
        'Recurring'   => undef,
        'ResourceID'  => [
            0
        ],

        'AllDay'    => undef,
        'StartTime' => '2017-08-15 16:00:00',

        'TimezoneID' => '2',
        'TeamID'     => [],
        'Title'      => 'Each 2nd week',
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'AllDay' => undef,

        'ResourceID' => [
            0
        ],

        'Recurring'   => undef,
        'EndTime'     => '2017-08-29 17:00:00',
        'Description' => 'Developer meeting each 2nd Tuesday',
        'Location'    => undef,
        'Title'       => 'Each 2nd week',
        'CalendarID'  => $Calendar{CalendarID},
        'TeamID'      => [],
        'TimezoneID'  => '2',

        'StartTime' => '2017-08-29 16:00:00'
    },
    {
        'Title'      => 'Each 2nd week',
        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => [],
        'TimezoneID' => '2',

        'StartTime' => '2017-09-12 16:00:00',
        'AllDay'    => undef,

        'ResourceID' => [
            0
        ],
        'EndTime'     => '2017-09-12 17:00:00',
        'Recurring'   => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'Location'    => undef
    },
    {
        'Location'    => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'EndTime'     => '2017-09-26 17:00:00',
        'Recurring'   => undef,
        'ResourceID'  => [
            0
        ],

        'AllDay'    => undef,
        'StartTime' => '2017-09-26 16:00:00',

        'TimezoneID' => '2',
        'TeamID'     => [],
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 2nd week'
    },
    {
        'TeamID'     => [],
        'TimezoneID' => '2',
        'Title'      => 'Each 2nd week',
        'CalendarID' => $Calendar{CalendarID},
        'StartTime'  => '2017-10-10 16:00:00',

        'AllDay'      => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'Location'    => undef,

        'ResourceID' => [
            0
        ],
        'Recurring' => undef,
        'EndTime'   => '2017-10-10 17:00:00'
    },
    {

        'AllDay'      => undef,
        'Location'    => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'Recurring'   => undef,
        'EndTime'     => '2017-10-24 17:00:00',
        'ResourceID'  => [
            0
        ],

        'TimezoneID' => '2',
        'TeamID'     => [],
        'Title'      => 'Each 2nd week',
        'CalendarID' => $Calendar{CalendarID},
        'StartTime'  => '2017-10-24 16:00:00',

    },
    {

        'StartTime'  => '2017-11-07 16:00:00',
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 2nd week',
        'TeamID'     => [],
        'TimezoneID' => '2',
        'ResourceID' => [
            0
        ],

        'EndTime'     => '2017-11-07 17:00:00',
        'Recurring'   => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'Location'    => undef,
        'AllDay'      => undef,

    },
    {
        'AllDay' => undef,

        'ResourceID' => [
            0
        ],

        'Recurring'   => undef,
        'EndTime'     => '2017-11-21 17:00:00',
        'Description' => 'Developer meeting each 2nd Tuesday',
        'Location'    => undef,
        'Title'       => 'Each 2nd week',
        'CalendarID'  => $Calendar{CalendarID},
        'TeamID'      => [],
        'TimezoneID'  => '2',

        'StartTime' => '2017-11-21 16:00:00'
    },
    {
        'AllDay' => undef,

        'ResourceID' => [
            0
        ],

        'Recurring'   => undef,
        'EndTime'     => '2017-12-05 17:00:00',
        'Description' => 'Developer meeting each 2nd Tuesday',
        'Location'    => undef,
        'Title'       => 'Each 2nd week',
        'CalendarID'  => $Calendar{CalendarID},
        'TeamID'      => [],
        'TimezoneID'  => '2',

        'StartTime' => '2017-12-05 16:00:00'
    },
    {

        'AllDay'      => undef,
        'Location'    => undef,
        'Description' => 'Developer meeting each 2nd Tuesday',
        'Recurring'   => undef,
        'EndTime'     => '2017-12-19 17:00:00',
        'ResourceID'  => [
            0
        ],

        'TimezoneID' => '2',
        'TeamID'     => [],
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Each 2nd week',
        'StartTime'  => '2017-12-19 16:00:00',

    },
    {
        'EndTime'   => '2016-01-11 10:00:00',
        'Recurring' => '1',

        'ResourceID' => [
            0
        ],
        'Location'    => undef,
        'Description' => 'Start at Monday and repeat each 2nd Wednesday and Sunday.',
        'AllDay'      => undef,

        'StartTime'  => '2016-01-11 09:00:00',
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Custom 1',
        'TimezoneID' => '2',
        'TeamID'     => []
    },
    {

        'StartTime'  => '2016-01-13 09:00:00',
        'Title'      => 'Custom 1',
        'CalendarID' => $Calendar{CalendarID},
        'TimezoneID' => '2',
        'TeamID'     => [],
        'EndTime'    => '2016-01-13 10:00:00',
        'Recurring'  => undef,

        'ResourceID' => [
            0
        ],
        'Location'    => undef,
        'Description' => 'Start at Monday and repeat each 2nd Wednesday and Sunday.',
        'AllDay'      => undef,

    },
    {

        'AllDay'      => undef,
        'Description' => 'Start at Monday and repeat each 2nd Wednesday and Sunday.',
        'Location'    => undef,

        'ResourceID' => [
            0
        ],
        'Recurring'  => undef,
        'EndTime'    => '2016-01-17 10:00:00',
        'TeamID'     => [],
        'TimezoneID' => '2',
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Custom 1',
        'StartTime'  => '2016-01-17 09:00:00',

    },
    {
        'Description' => 'Start at Monday and repeat each 2nd Wednesday and Sunday.',
        'Location'    => undef,

        'ResourceID' => [
            0
        ],
        'EndTime'   => '2016-01-27 10:00:00',
        'Recurring' => undef,

        'AllDay'    => undef,
        'StartTime' => '2016-01-27 09:00:00',

        'TeamID'     => [],
        'TimezoneID' => '2',
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Custom 1'
    },
    {
        'Description' => 'Start at Monday and repeat each 2nd Wednesday and Sunday.',
        'Location'    => undef,
        'ResourceID'  => [
            0
        ],

        'Recurring' => undef,
        'EndTime'   => '2016-01-31 10:00:00',

        'AllDay'    => undef,
        'StartTime' => '2016-01-31 09:00:00',

        'TeamID'     => [],
        'TimezoneID' => '2',
        'Title'      => 'Custom 1',
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'ResourceID' => [
            0
        ],

        'EndTime'     => '2016-02-10 10:00:00',
        'Recurring'   => undef,
        'Description' => 'Start at Monday and repeat each 2nd Wednesday and Sunday.',
        'Location'    => undef,
        'AllDay'      => undef,

        'StartTime'  => '2016-02-10 09:00:00',
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Custom 1',
        'TeamID'     => [],
        'TimezoneID' => '2'
    },
    {
        'EndTime'    => '2016-02-14 10:00:00',
        'Recurring'  => undef,
        'ResourceID' => [
            0
        ],

        'Location'    => undef,
        'Description' => 'Start at Monday and repeat each 2nd Wednesday and Sunday.',
        'AllDay'      => undef,

        'StartTime'  => '2016-02-14 09:00:00',
        'Title'      => 'Custom 1',
        'CalendarID' => $Calendar{CalendarID},
        'TimezoneID' => '2',
        'TeamID'     => []
    },
    {
        'AllDay' => undef,

        'Recurring'  => undef,
        'EndTime'    => '2016-02-24 10:00:00',
        'ResourceID' => [
            0
        ],

        'Location'    => undef,
        'Description' => 'Start at Monday and repeat each 2nd Wednesday and Sunday.',
        'Title'       => 'Custom 1',
        'CalendarID'  => $Calendar{CalendarID},
        'TimezoneID'  => '2',
        'TeamID'      => [],

        'StartTime' => '2016-02-24 09:00:00'
    },
    {
        'TeamID'     => [],
        'TimezoneID' => '2',
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Custom 1',
        'StartTime'  => '2016-02-28 09:00:00',

        'AllDay'      => undef,
        'Description' => 'Start at Monday and repeat each 2nd Wednesday and Sunday.',
        'Location'    => undef,

        'ResourceID' => [
            0
        ],
        'Recurring' => undef,
        'EndTime'   => '2016-02-28 10:00:00'
    },
    {
        'ResourceID' => [
            0
        ],

        'EndTime'     => '2016-03-09 10:00:00',
        'Recurring'   => undef,
        'Description' => 'Start at Monday and repeat each 2nd Wednesday and Sunday.',
        'Location'    => undef,
        'AllDay'      => undef,

        'StartTime'  => '2016-03-09 09:00:00',
        'Title'      => 'Custom 1',
        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => [],
        'TimezoneID' => '2'
    },
    {
        'StartTime' => '2016-03-13 09:00:00',

        'TeamID'      => [],
        'TimezoneID'  => '2',
        'Title'       => 'Custom 1',
        'CalendarID'  => $Calendar{CalendarID},
        'Description' => 'Start at Monday and repeat each 2nd Wednesday and Sunday.',
        'Location'    => undef,

        'ResourceID' => [
            0
        ],
        'Recurring' => undef,
        'EndTime'   => '2016-03-13 10:00:00',

        'AllDay' => undef
    },
    {

        'AllDay'      => undef,
        'Description' => 'Start at Monday and repeat each 2nd Wednesday and Sunday.',
        'Location'    => undef,
        'ResourceID'  => [
            0
        ],

        'Recurring'  => undef,
        'EndTime'    => '2016-03-23 10:00:00',
        'TeamID'     => [],
        'TimezoneID' => '2',
        'Title'      => 'Custom 1',
        'CalendarID' => $Calendar{CalendarID},
        'StartTime'  => '2016-03-23 09:00:00',

    },
    {

        'StartTime'  => '2016-03-27 09:00:00',
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Custom 1',
        'TimezoneID' => '2',
        'TeamID'     => [],
        'Recurring'  => undef,
        'EndTime'    => '2016-03-27 10:00:00',
        'ResourceID' => [
            0
        ],

        'Location'    => undef,
        'Description' => 'Start at Monday and repeat each 2nd Wednesday and Sunday.',
        'AllDay'      => undef,

    },
    {
        'TeamID'     => [],
        'TimezoneID' => '2',
        'Title'      => 'Custom 2',
        'CalendarID' => $Calendar{CalendarID},
        'StartTime'  => '2016-01-12 09:00:00',

        'AllDay'      => undef,
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'Location'    => undef,

        'ResourceID' => [
            0
        ],
        'Recurring' => '1',
        'EndTime'   => '2016-01-12 10:00:00'
    },
    {

        'StartTime'  => '2016-01-16 09:00:00',
        'Title'      => 'Custom 2',
        'CalendarID' => $Calendar{CalendarID},
        'TimezoneID' => '2',
        'TeamID'     => [],
        'Recurring'  => undef,
        'EndTime'    => '2016-01-16 10:00:00',

        'ResourceID' => [
            0
        ],
        'Location'    => undef,
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'AllDay'      => undef,

    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Custom 2',
        'TeamID'     => [],
        'TimezoneID' => '2',

        'StartTime' => '2016-01-31 09:00:00',
        'AllDay'    => undef,

        'ResourceID' => [
            0
        ],
        'Recurring'   => undef,
        'EndTime'     => '2016-01-31 10:00:00',
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'Location'    => undef
    },
    {

        'AllDay'      => undef,
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'Location'    => undef,
        'ResourceID'  => [
            0
        ],

        'EndTime'    => '2016-02-16 10:00:00',
        'Recurring'  => undef,
        'TeamID'     => [],
        'TimezoneID' => '2',
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Custom 2',
        'StartTime'  => '2016-02-16 09:00:00',

    },
    {
        'Location'    => undef,
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'EndTime'     => '2016-03-16 10:00:00',
        'Recurring'   => undef,

        'ResourceID' => [
            0
        ],

        'AllDay'    => undef,
        'StartTime' => '2016-03-16 09:00:00',

        'TimezoneID' => '2',
        'TeamID'     => [],
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Custom 2'
    },
    {
        'StartTime' => '2016-03-31 09:00:00',

        'TimezoneID'  => '2',
        'TeamID'      => [],
        'Title'       => 'Custom 2',
        'CalendarID'  => $Calendar{CalendarID},
        'Location'    => undef,
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'EndTime'     => '2016-03-31 10:00:00',
        'Recurring'   => undef,

        'ResourceID' => [
            0
        ],

        'AllDay' => undef
    },
    {
        'ResourceID' => [
            0
        ],

        'Recurring'   => undef,
        'EndTime'     => '2016-04-16 10:00:00',
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'Location'    => undef,
        'AllDay'      => undef,

        'StartTime'  => '2016-04-16 09:00:00',
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Custom 2',
        'TeamID'     => [],
        'TimezoneID' => '2'
    },
    {
        'AllDay' => undef,

        'EndTime'   => '2016-05-16 10:00:00',
        'Recurring' => undef,

        'ResourceID' => [
            0
        ],
        'Location'    => undef,
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'CalendarID'  => $Calendar{CalendarID},
        'Title'       => 'Custom 2',
        'TimezoneID'  => '2',
        'TeamID'      => [],

        'StartTime' => '2016-05-16 09:00:00'
    },
    {
        'Location'    => undef,
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'EndTime'     => '2016-05-31 10:00:00',
        'Recurring'   => undef,
        'ResourceID'  => [
            0
        ],

        'AllDay'    => undef,
        'StartTime' => '2016-05-31 09:00:00',

        'TimezoneID' => '2',
        'TeamID'     => [],
        'Title'      => 'Custom 2',
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Custom 2',
        'TimezoneID' => '2',
        'TeamID'     => [],

        'StartTime' => '2016-06-16 09:00:00',
        'AllDay'    => undef,

        'EndTime'    => '2016-06-16 10:00:00',
        'Recurring'  => undef,
        'ResourceID' => [
            0
        ],

        'Location'    => undef,
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.'
    },
    {

        'StartTime'  => '2016-07-16 09:00:00',
        'Title'      => 'Custom 2',
        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => [],
        'TimezoneID' => '2',
        'ResourceID' => [
            0
        ],

        'EndTime'     => '2016-07-16 10:00:00',
        'Recurring'   => undef,
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'Location'    => undef,
        'AllDay'      => undef,

    },
    {

        'ResourceID' => [
            0
        ],
        'EndTime'     => '2016-07-31 10:00:00',
        'Recurring'   => undef,
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'Location'    => undef,
        'AllDay'      => undef,

        'StartTime'  => '2016-07-31 09:00:00',
        'Title'      => 'Custom 2',
        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => [],
        'TimezoneID' => '2'
    },
    {
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'Location'    => undef,

        'ResourceID' => [
            0
        ],
        'EndTime'   => '2016-08-16 10:00:00',
        'Recurring' => undef,

        'AllDay'    => undef,
        'StartTime' => '2016-08-16 09:00:00',

        'TeamID'     => [],
        'TimezoneID' => '2',
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Custom 2'
    },
    {
        'TimezoneID' => '2',
        'TeamID'     => [],
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Custom 2',
        'StartTime'  => '2016-08-31 09:00:00',

        'AllDay'      => undef,
        'Location'    => undef,
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'EndTime'     => '2016-08-31 10:00:00',
        'Recurring'   => undef,
        'ResourceID'  => [
            0
        ],

    },
    {
        'Location'    => undef,
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'EndTime'     => '2016-09-16 10:00:00',
        'Recurring'   => undef,

        'ResourceID' => [
            0
        ],

        'AllDay'    => undef,
        'StartTime' => '2016-09-16 09:00:00',

        'TimezoneID' => '2',
        'TeamID'     => [],
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Custom 2'
    },
    {
        'StartTime' => '2016-10-16 09:00:00',

        'TimezoneID'  => '2',
        'TeamID'      => [],
        'Title'       => 'Custom 2',
        'CalendarID'  => $Calendar{CalendarID},
        'Location'    => undef,
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'EndTime'     => '2016-10-16 10:00:00',
        'Recurring'   => undef,
        'ResourceID'  => [
            0
        ],

        'AllDay' => undef
    },
    {
        'TeamID'     => [],
        'TimezoneID' => '2',
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Custom 2',
        'StartTime'  => '2016-10-31 09:00:00',

        'AllDay'      => undef,
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'Location'    => undef,
        'ResourceID'  => [
            0
        ],

        'Recurring' => undef,
        'EndTime'   => '2016-10-31 10:00:00'
    },
    {
        'ResourceID' => [
            0
        ],

        'EndTime'     => '2016-11-16 10:00:00',
        'Recurring'   => undef,
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'Location'    => undef,
        'AllDay'      => undef,

        'StartTime'  => '2016-11-16 09:00:00',
        'Title'      => 'Custom 2',
        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => [],
        'TimezoneID' => '2'
    },
    {
        'TeamID'     => [],
        'TimezoneID' => '2',
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Custom 2',
        'StartTime'  => '2016-12-16 09:00:00',

        'AllDay'      => undef,
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'Location'    => undef,

        'ResourceID' => [
            0
        ],
        'Recurring' => undef,
        'EndTime'   => '2016-12-16 10:00:00'
    },
    {

        'StartTime'  => '2016-12-31 09:00:00',
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Custom 2',
        'TimezoneID' => '2',
        'TeamID'     => [],
        'EndTime'    => '2016-12-31 10:00:00',
        'Recurring'  => undef,

        'ResourceID' => [
            0
        ],
        'Location'    => undef,
        'Description' => 'Start on jan 12, repeat each month on 16th and 31th.',
        'AllDay'      => undef,

    },
    {

        'ResourceID' => [
            0
        ],
        'Recurring'   => '1',
        'EndTime'     => '2016-01-31 10:00:00',
        'Description' => undef,
        'Location'    => undef,
        'AllDay'      => undef,

        'StartTime'  => '2016-01-31 09:00:00',
        'Title'      => 'Custom 3',
        'CalendarID' => $Calendar{CalendarID},
        'TeamID'     => [],
        'TimezoneID' => '2'
    },
    {
        'TeamID'     => [],
        'TimezoneID' => '2',
        'Title'      => 'Custom 3',
        'CalendarID' => $Calendar{CalendarID},
        'StartTime'  => '2016-02-29 09:00:00',

        'AllDay'      => undef,
        'Description' => undef,
        'Location'    => undef,
        'ResourceID'  => [
            0
        ],

        'EndTime'   => '2016-02-29 10:00:00',
        'Recurring' => undef
    },
    {
        'Location'    => undef,
        'Description' => undef,
        'Recurring'   => undef,
        'EndTime'     => '2016-12-31 10:00:00',
        'ResourceID'  => [
            0
        ],

        'AllDay'    => undef,
        'StartTime' => '2016-12-31 09:00:00',

        'TimezoneID' => '2',
        'TeamID'     => [],
        'Title'      => 'Custom 3',
        'CalendarID' => $Calendar{CalendarID},
    },
    {
        'TeamID'     => [],
        'TimezoneID' => '2',
        'Title'      => 'Custom 4',
        'CalendarID' => $Calendar{CalendarID},
        'StartTime'  => '2016-01-04 16:00:00',

        'AllDay'      => undef,
        'Description' => undef,
        'Location'    => undef,
        'ResourceID'  => [
            0
        ],

        'Recurring' => '1',
        'EndTime'   => '2016-01-04 17:00:00'
    },
    {

        'StartTime'  => '2016-02-04 16:00:00',
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Custom 4',
        'TeamID'     => [],
        'TimezoneID' => '2',
        'ResourceID' => [
            0
        ],

        'EndTime'     => '2016-02-04 17:00:00',
        'Recurring'   => undef,
        'Description' => undef,
        'Location'    => undef,
        'AllDay'      => undef,

    },
    {

        'StartTime'  => '2017-02-04 16:00:00',
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Custom 4',
        'TeamID'     => [],
        'TimezoneID' => '2',
        'ResourceID' => [
            0
        ],

        'EndTime'     => '2017-02-04 17:00:00',
        'Recurring'   => undef,
        'Description' => undef,
        'Location'    => undef,
        'AllDay'      => undef,

    },
    {
        'AllDay' => undef,

        'ResourceID' => [
            0
        ],
        'Recurring'   => '1',
        'EndTime'     => '2016-01-04 17:00:00',
        'Description' => undef,
        'Location'    => undef,
        'CalendarID'  => $Calendar{CalendarID},
        'Title'       => 'Yearly',
        'TeamID'      => [],
        'TimezoneID'  => '2',

        'StartTime' => '2016-01-04 16:00:00'
    },
    {

        'StartTime'  => '2017-01-04 16:00:00',
        'CalendarID' => $Calendar{CalendarID},
        'Title'      => 'Yearly',
        'TimezoneID' => '2',
        'TeamID'     => [],
        'Recurring'  => undef,
        'EndTime'    => '2017-01-04 17:00:00',

        'ResourceID' => [
            0
        ],
        'Location'    => undef,
        'Description' => undef,
        'AllDay'      => undef,

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
            next KEY if $Key eq

                $Self->Is(
                $Appointments[$Index]->{$Key},
                $Result[$Index]->{$Key},
                "Check if $Key value is OK.",
                );
        }
    }
}

1;
