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
my %Calendar1 = $CalendarObject->CalendarCreate(
    CalendarName => 'Test calendar',
    GroupID      => $GroupID,
    UserID       => $UserID,
);

$Self->True(
    $Calendar1{CalendarID},
    "CalendarCreate( CalendarName => 'Test calendar', GroupID => $GroupID, UserID => $UserID ) - CalendarID",
);

# only required fields
my $AppointmentID1 = $AppointmentObject->AppointmentCreate(
    CalendarID => $Calendar1{CalendarID},
    Title      => 'Webinar',
    StartTime  => '2016-01-01 16:00:00',
    EndTime    => '2016-01-01 17:00:00',
    TimezoneID => 1,
    UserID     => $UserID,
);

$Self->True(
    $AppointmentID1,
    'AppointmentCreate #1',
);

# no CalendarID
my $AppointmentID2 = $AppointmentObject->AppointmentCreate(
    Title      => 'Webinar',
    StartTime  => '2016-01-01 16:00:00',
    EndTime    => '2016-01-01 17:00:00',
    TimezoneID => 1,
    UserID     => $UserID,
);

$Self->False(
    $AppointmentID2,
    'AppointmentCreate #2',
);

# no Title
my $AppointmentID3 = $AppointmentObject->AppointmentCreate(
    CalendarID => $Calendar1{CalendarID},
    StartTime  => '2016-01-01 16:00:00',
    EndTime    => '2016-01-01 17:00:00',
    TimezoneID => 1,
    UserID     => $UserID,
);

$Self->False(
    $AppointmentID3,
    'AppointmentCreate #3',
);

# no StartTime
my $AppointmentID4 = $AppointmentObject->AppointmentCreate(
    CalendarID => $Calendar1{CalendarID},
    Title      => 'Webinar',
    EndTime    => '2016-01-01 17:00:00',
    TimezoneID => 1,
    UserID     => $UserID,
);

$Self->False(
    $AppointmentID4,
    'AppointmentCreate #4',
);

# no EndTime
my $AppointmentID5 = $AppointmentObject->AppointmentCreate(
    CalendarID => $Calendar1{CalendarID},
    Title      => 'Webinar',
    StartTime  => '2016-01-01 16:00:00',
    TimezoneID => 1,
    UserID     => $UserID,
);

$Self->False(
    $AppointmentID5,
    'AppointmentCreate #5',
);

# no TimezoneID
my $AppointmentID6 = $AppointmentObject->AppointmentCreate(
    CalendarID => $Calendar1{CalendarID},
    Title      => 'Webinar',
    StartTime  => '2016-01-01 16:00:00',
    EndTime    => '2016-01-01 17:00:00',
    UserID     => $UserID,
);

$Self->False(
    $AppointmentID6,
    'AppointmentCreate #6',
);

# no UserID
my $AppointmentID7 = $AppointmentObject->AppointmentCreate(
    CalendarID => $Calendar1{CalendarID},
    Title      => 'Webinar',
    StartTime  => '2016-01-01 16:00:00',
    EndTime    => '2016-01-01 17:00:00',
    TimezoneID => 1,
);

$Self->False(
    $AppointmentID7,
    'AppointmentCreate #7',
);

my $AppointmentID8 = $AppointmentObject->AppointmentCreate(
    CalendarID          => $Calendar1{CalendarID},
    Title               => 'Title',
    Description         => 'Description',
    Location            => 'Germany',
    StartTime           => '2016-01-01 16:00:00',
    EndTime             => '2016-01-01 17:00:00',
    AllDay              => 1,
    TimezoneID          => 0,                        # this must be accepted (UTC)
    RecurrenceFrequency => 1,
    RecurrenceCount     => 1,
    UserID              => $UserID,
);
$Self->True(
    $AppointmentID8,
    'AppointmentCreate #8',
);

my @Appointments1 = $AppointmentObject->AppointmentList(
    CalendarID => $Calendar1{CalendarID},
    StartTime  => '2016-01-01 16:00:00',             # Try at this point of time (at this second)
    EndTime    => '2016-02-01 00:00:00',
);

$Self->Is(
    scalar @Appointments1,
    2,
    'AppointmentList() #1',
);

for my $Appointment (@Appointments1) {

    # checks
    $Self->True(
        $Appointment->{AppointmentID},
        'AppointmentID present',
    );
    $Self->True(
        $Appointment->{CalendarID},
        'CalendarID present',
    );
    $Self->True(
        $Appointment->{UniqueID},
        'UniqueID present',
    );
    $Self->True(
        $Appointment->{Title},
        'Title present',
    );
    $Self->True(
        $Appointment->{StartTime},
        'StartTime present',
    );
    $Self->True(
        $Appointment->{EndTime},
        'EndTime present',
    );
}

# before any appointment
my @Appointments2 = $AppointmentObject->AppointmentList(
    CalendarID => $Calendar1{CalendarID},
    EndTime    => '2015-12-31 00:00:00',
);

$Self->Is(
    scalar @Appointments2,
    0,
    'AppointmentList() #2',
);

# after appointment
my @Appointments3 = $AppointmentObject->AppointmentList(
    CalendarID => $Calendar1{CalendarID},
    StartTime  => '2016-03-23 00:00:00',
);

$Self->Is(
    scalar @Appointments3,
    0,
    'AppointmentList() #3',
);

# missing CalendarID
my @Appointments4 = $AppointmentObject->AppointmentList();
$Self->Is(
    scalar @Appointments4,
    0,
    'AppointmentList() #4',
);

my @Appointments5 = $AppointmentObject->AppointmentList(
    CalendarID => $Calendar1{CalendarID},
    StartTime  => '2016-01-01 00:00:00',
);

$Self->Is(
    scalar @Appointments5,
    2,
    'AppointmentList() #5',
);

my @Appointments6 = $AppointmentObject->AppointmentList(
    CalendarID => $Calendar1{CalendarID},
    EndTime    => '2016-01-02 00:00:00',
);

$Self->Is(
    scalar @Appointments6,
    2,
    'AppointmentList() #6',
);

my @Appointments7 = $AppointmentObject->AppointmentList(
    CalendarID => $Calendar1{CalendarID},
    StartTime  => '2016-01-01 16:30:00',
);

$Self->Is(
    scalar @Appointments7,
    2,
    'AppointmentList() #7',
);

my @Appointments8 = $AppointmentObject->AppointmentList(
    CalendarID => $Calendar1{CalendarID},
    EndTime    => '2016-01-01 16:30:00',
);

$Self->Is(
    scalar @Appointments8,
    2,
    'AppointmentList() #8',
);

my @Appointments9 = $AppointmentObject->AppointmentList(
    CalendarID => $Calendar1{CalendarID},
    StartTime  => '2016-01-01 16:15:00',
    EndTime    => '2016-01-01 16:30:00',
);

$Self->Is(
    scalar @Appointments9,
    2,
    'AppointmentList() #9',
);

# edge
my @Appointments10 = $AppointmentObject->AppointmentList(
    CalendarID => $Calendar1{CalendarID},
    StartTime  => '2016-01-01 16:00:00',
    EndTime    => '2016-01-01 17:00:00',
);

$Self->Is(
    scalar @Appointments10,
    2,
    'AppointmentList() #10',
);

# add recurring appointment once a day
my $AppointmentIDRec1 = $AppointmentObject->AppointmentCreate(
    CalendarID          => $Calendar1{CalendarID},
    Title               => 'Recurring appointment',
    Description         => 'Description',
    Location            => 'Germany',
    StartTime           => '2016-03-01 16:00:00',
    EndTime             => '2016-03-01 17:00:00',
    AllDay              => 1,
    TimezoneID          => 1,
    Recurring           => 1,
    RecurrenceByDay     => 1,
    RecurrenceFrequency => 1,                         # once per day
    RecurrenceUntil     => '2016-03-06 00:00:00',     # included last day
    UserID              => $UserID,
);
$Self->True(
    $AppointmentIDRec1,
    'Recurring appointment #1 created',
);

# add recurring appointment on Wednesday - recurring Monday and Friday
my $AppointmentIDRec2 = $AppointmentObject->AppointmentCreate(
    CalendarID          => $Calendar1{CalendarID},
    Title               => 'Recurring appointment 2',
    Description         => 'Description',
    Location            => 'Germany',
    StartTime           => '2016-05-04 16:00:00',       # wednesday
    EndTime             => '2016-05-04 17:00:00',
    AllDay              => 1,
    TimezoneID          => 1,
    Recurring           => 1,
    RecurrenceByDay     => 1,
    RecurrenceFrequency => 2,                           # each 2nd
    RecurrenceDays      => [ 1, 5 ],                    # Monday and Friday
    RecurrenceUntil     => '2016-06-05 00:00:00',       # cca 1 month
    UserID              => $UserID,
);
$Self->True(
    $AppointmentIDRec2,
    'Recurring appointment #2 created',
);

# add recurring appointment each 3 years, in January and May
my $AppointmentIDRec3 = $AppointmentObject->AppointmentCreate(
    CalendarID          => $Calendar1{CalendarID},
    Title               => 'Recurring appointment 3',
    Description         => 'Description',
    Location            => 'Germany',
    StartTime           => '2016-07-05 16:00:00',       # wednesday
    EndTime             => '2016-07-05 17:00:00',
    AllDay              => 1,
    TimezoneID          => 1,
    Recurring           => 1,
    RecurrenceByDay     => 1,
    RecurrenceFrequency => 3,                           # each 3th year
    RecurrenceMonths    => [ 1, 5 ],                    # January and May
    RecurrenceUntil     => '2020-07-05 00:00:00',       # cca 4 years
    UserID              => $UserID,
);
$Self->True(
    $AppointmentIDRec3,
    'Recurring appointment #3 created',
);

# add recurring appointment each 2nd month on 5th, 10th and 15th day
my $AppointmentIDRec4 = $AppointmentObject->AppointmentCreate(
    CalendarID          => $Calendar1{CalendarID},
    Title               => 'Recurring appointment 4',
    Description         => 'Description',
    Location            => 'Germany',
    StartTime           => '2016-07-05 16:00:00',
    EndTime             => '2016-07-05 17:00:00',
    AllDay              => 1,
    TimezoneID          => 1,
    Recurring           => 1,
    RecurrenceByDay     => 1,
    RecurrenceFrequency => 2,                           # each 2 months
    RecurrenceMonthDays => [ 5, 10, 15 ],               # Days in month
    RecurrenceUntil     => '2017-07-05 00:00:00',       # cca 1 year
    UserID              => $UserID,
);
$Self->True(
    $AppointmentIDRec4,
    'Recurring appointment #4 created',
);

# list recurring appointments
my @AppointmentsRec1 = $AppointmentObject->AppointmentList(
    CalendarID => $Calendar1{CalendarID},
    StartTime  => '2016-03-01 00:00:00',
    EndTime    => '2016-03-06 00:00:00',
);

$Self->Is(
    scalar @AppointmentsRec1,
    6,
    'AppointmentList() - # rec1 ok',
);

# update recurring appointment
my $SuccessRec1 = $AppointmentObject->AppointmentUpdate(
    AppointmentID       => $AppointmentIDRec1,
    CalendarID          => $Calendar1{CalendarID},
    Title               => 'Classes',
    Description         => 'Additional description',
    Location            => 'Germany',
    StartTime           => '2016-03-02 16:00:00',
    EndTime             => '2016-03-02 17:00:00',
    AllDay              => 1,
    TimezoneID          => 1,
    Recurring           => 1,
    RecurrenceByDay     => 1,
    RecurrenceFrequency => 2,                          # each 2 days
    RecurrenceUntil     => '2016-03-10 17:00:00',
    UserID              => $UserID,
);
$Self->True(
    $SuccessRec1,
    'Updated rec #1',
);

# list recurring appointments
@AppointmentsRec1 = $AppointmentObject->AppointmentList(
    CalendarID => $Calendar1{CalendarID},
    StartTime  => '2016-03-01 00:00:00',
    EndTime    => '2016-03-05 00:00:00',
);
$Self->Is(
    scalar @AppointmentsRec1,
    2,
    'Recurring updated - current appointments count check',
);
$Self->Is(
    $AppointmentsRec1[0]->{StartTime},
    '2016-03-02 16:00:00',
    'Recurring updated - #1 start time',
);
$Self->Is(
    $AppointmentsRec1[0]->{EndTime},
    '2016-03-02 17:00:00',
    'Recurring updated - #1 end time',
);
$Self->Is(
    $AppointmentsRec1[1]->{StartTime},
    '2016-03-04 16:00:00',
    'Recurring updated - #1 start time',
);
$Self->Is(
    $AppointmentsRec1[1]->{EndTime},
    '2016-03-04 17:00:00',
    'Recurring updated - #1 end time',
);

my %AppointmentGet1 = $AppointmentObject->AppointmentGet(
    AppointmentID => $AppointmentID8,
);

$Self->Is(
    $AppointmentGet1{AppointmentID},
    $AppointmentID8,
    'AppointmentGet() - ID ok',
);
$Self->Is(
    $AppointmentGet1{CalendarID},
    $Calendar1{CalendarID},
    'AppointmentGet() - CalendarID ok',
);
$Self->True(
    $AppointmentGet1{UniqueID},
    'AppointmentGet() - UniqueID ok',
);
$Self->Is(
    $AppointmentGet1{Title},
    'Title',
    'AppointmentGet() - Title ok',
);
$Self->Is(
    $AppointmentGet1{Description},
    'Description',
    'AppointmentGet() - Description ok',
);
$Self->Is(
    $AppointmentGet1{Location},
    'Germany',
    'AppointmentGet() - Location ok',
);
$Self->Is(
    $AppointmentGet1{StartTime},
    '2016-01-01 16:00:00',
    'AppointmentGet() - StartTime ok',
);
$Self->Is(
    $AppointmentGet1{EndTime},
    '2016-01-01 17:00:00',
    'AppointmentGet() - EndTime ok',
);
$Self->Is(
    $AppointmentGet1{AllDay},
    1,
    'AppointmentGet() - AllDay ok',
);
$Self->Is(
    $AppointmentGet1{TimezoneID},
    0,
    'AppointmentGet() - TimezoneID ok',
);
$Self->Is(
    $AppointmentGet1{RecurrenceFrequency},
    1,
    'AppointmentGet() - RecurrenceFrequency ok',
);
$Self->Is(
    $AppointmentGet1{RecurrenceCount},
    1,
    'AppointmentGet() - RecurrenceCount ok',
);
$Self->True(
    $AppointmentGet1{CreateTime},
    'AppointmentGet() - CreateTime ok',
);
$Self->Is(
    $AppointmentGet1{CreateBy},
    $UserID,
    'AppointmentGet() - CreateBy ok',
);
$Self->True(
    $AppointmentGet1{ChangeTime},
    'AppointmentGet() - ChangeTime ok',
);
$Self->Is(
    $AppointmentGet1{ChangeBy},
    $UserID,
    'AppointmentGet() - ChangeBy ok',
);

my %AppointmentGet2 = $AppointmentObject->AppointmentGet();
$Self->False(
    $AppointmentGet2{AppointmentID},
    'AppointmentGet() - Missing AppointmentID and UniqueID',
);

# Get by UndiqueID
my %AppointmentGet3 = $AppointmentObject->AppointmentGet(
    UniqueID => $AppointmentGet1{UniqueID},
);
$Self->Is(
    $AppointmentGet1{AppointmentID},
    $AppointmentGet3{AppointmentID},
    'AppointmentGet() - UniqueID',
);

my %Calendar2 = $CalendarObject->CalendarCreate(
    CalendarName => 'Test calendar 2',
    GroupID      => $GroupID,
    UserID       => $UserID,
);

my $Update1 = $AppointmentObject->AppointmentUpdate(
    AppointmentID       => $AppointmentID8,
    CalendarID          => $Calendar2{CalendarID},
    Title               => 'Webinar title',
    Description         => 'Description details',
    Location            => 'England',
    StartTime           => '2016-01-02 16:00:00',
    EndTime             => '2016-01-02 17:00:00',
    AllDay              => 0,
    TimezoneID          => 1,
    Recurring           => 1,
    RecurrenceByDay     => 1,
    RecurrenceFrequency => 2,
    RecurrenceCount     => 2,
    UserID              => $UserID,
);
$Self->True(
    $Update1,
    'AppointmentUpdate() - #1',
);

my %AppointmentGet4 = $AppointmentObject->AppointmentGet(
    AppointmentID => $AppointmentID8,
);
$Self->Is(
    $AppointmentGet4{AppointmentID},
    $AppointmentID8,
    'AppointmentUpdate() - AppointmentID ok',
);
$Self->Is(
    $AppointmentGet4{CalendarID},
    $Calendar2{CalendarID},
    'AppointmentUpdate() - CalendarID ok',
);
$Self->True(
    $AppointmentGet4{UniqueID},
    'AppointmentUpdate() - UniqueID ok',
);
$Self->Is(
    $AppointmentGet4{Title},
    'Webinar title',
    'AppointmentUpdate() - Title ok',
);
$Self->Is(
    $AppointmentGet4{Description},
    'Description details',
    'AppointmentUpdate() - Description ok',
);
$Self->Is(
    $AppointmentGet4{Location},
    'England',
    'AppointmentUpdate() - Location ok',
);
$Self->Is(
    $AppointmentGet4{StartTime},
    '2016-01-02 16:00:00',
    'AppointmentUpdate() - StartTime ok',
);
$Self->Is(
    $AppointmentGet4{EndTime},
    '2016-01-02 17:00:00',
    'AppointmentUpdate() - EndTime ok',
);
$Self->False(
    $AppointmentGet4{AllDay},
    'AppointmentUpdate() - AllDay ok',
);
$Self->Is(
    $AppointmentGet4{TimezoneID},
    1,
    'AppointmentUpdate() - TimezoneID ok',
);
$Self->Is(
    $AppointmentGet4{RecurrenceFrequency},
    2,
    'AppointmentUpdate() - RecurrenceFrequency ok',
);
$Self->Is(
    $AppointmentGet4{RecurrenceCount},
    2,
    'AppointmentUpdate() - RecurrenceCount ok',
);
$Self->Is(
    $AppointmentGet4{CreateBy},
    $UserID,
    'AppointmentUpdate() - CreateBy ok',
);
$Self->Is(
    $AppointmentGet4{ChangeBy},
    $UserID,
    'AppointmentUpdate() - ChangeBy ok',
);

# missing AppointmentID
my $Update2 = $AppointmentObject->AppointmentUpdate(
    CalendarID => $Calendar2{CalendarID},
    Title      => 'Webinar title',
    StartTime  => '2016-01-02 16:00:00',
    EndTime    => '2016-01-03 17:00:00',
    TimezoneID => 1,
    UserID     => $UserID,
);
$Self->False(
    $Update2,
    'AppointmentUpdate() - #2 no AppointmentID',
);

# no CalendarID
my $Update3 = $AppointmentObject->AppointmentUpdate(
    AppointmentID => $AppointmentID8,
    Title         => 'Webinar title',
    StartTime     => '2016-01-02 16:00:00',
    EndTime       => '2016-01-03 17:00:00',
    TimezoneID    => 1,
    UserID        => $UserID,
);
$Self->False(
    $Update3,
    'AppointmentUpdate() - #3 no CalendarID',
);

# no title
my $Update4 = $AppointmentObject->AppointmentUpdate(
    AppointmentID => $AppointmentID8,
    CalendarID    => $Calendar2{CalendarID},
    StartTime     => '2016-01-02 16:00:00',
    EndTime       => '2016-01-03 17:00:00',
    TimezoneID    => 1,
    UserID        => $UserID,
);
$Self->False(
    $Update4,
    'AppointmentUpdate() - #4 no Title',
);

# no StartTime
my $Update5 = $AppointmentObject->AppointmentUpdate(
    AppointmentID => $AppointmentID8,
    CalendarID    => $Calendar2{CalendarID},
    Title         => 'Webinar title',
    EndTime       => '2016-01-03 17:00:00',
    TimezoneID    => 1,
    UserID        => $UserID,
);
$Self->False(
    $Update5,
    'AppointmentUpdate() - #5 no StartTime',
);

# no EndTime
my $Update6 = $AppointmentObject->AppointmentUpdate(
    AppointmentID => $AppointmentID8,
    CalendarID    => $Calendar2{CalendarID},
    Title         => 'Webinar title',
    StartTime     => '2016-01-02 16:00:00',
    TimezoneID    => 1,
    UserID        => $UserID,
);
$Self->False(
    $Update6,
    'AppointmentUpdate() - #6 no EndTime',
);

# no UserID
my $Update7 = $AppointmentObject->AppointmentUpdate(
    AppointmentID => $AppointmentID8,
    CalendarID    => $Calendar2{CalendarID},
    Title         => 'Webinar title',
    StartTime     => '2016-01-02 16:00:00',
    EndTime       => '2016-01-02 16:15:00',
    TimezoneID    => 1,
);
$Self->False(
    $Update7,
    'AppointmentUpdate() - #8 no UserID',
);

my $Delete1 = $AppointmentObject->AppointmentDelete(
    UserID => $UserID,
);
$Self->False(
    $Delete1,
    'AppointmentDelete() - #1 without AppointmentID',
);

my $Delete2 = $AppointmentObject->AppointmentDelete(
    AppointmentID => $AppointmentID8,
);
$Self->False(
    $Delete2,
    'AppointmentDelete() - #2 without UserID',
);

# add create permissions to the user
$GroupObject->PermissionGroupUserAdd(
    GID        => $Calendar2{GroupID},
    UID        => $UserID,
    Permission => {
        ro => 1,
    },
    UserID => 1,
);
my $Delete3 = $AppointmentObject->AppointmentDelete(
    AppointmentID => $AppointmentID8,
    UserID        => $UserID,
);
$Self->False(
    $Delete3,
    'AppointmentDelete() - #3 ro permissions',
);

# add create permissions to the user
$GroupObject->PermissionGroupUserAdd(
    GID        => $Calendar2{GroupID},
    UID        => $UserID,
    Permission => {
        ro        => 1,
        move_into => 1,
    },
    UserID => 1,
);
my $Delete4 = $AppointmentObject->AppointmentDelete(
    AppointmentID => $AppointmentID8,
    UserID        => $UserID,
);
$Self->False(
    $Delete4,
    'AppointmentDelete() - #4 move_into permissions',
);

# add create permissions to the user
$GroupObject->PermissionGroupUserAdd(
    GID        => $Calendar2{GroupID},
    UID        => $UserID,
    Permission => {
        ro        => 1,
        move_into => 1,
        create    => 1,
    },
    UserID => 1,
);
my $Delete5 = $AppointmentObject->AppointmentDelete(
    AppointmentID => $AppointmentID8,
    UserID        => $UserID,
);
$Self->True(
    $Delete5,
    'AppointmentDelete() - #5 create permissions',
);

my %AppointmentGet5 = $AppointmentObject->AppointmentGet(
    AppointmentID => $AppointmentID8,
    UserID        => $UserID,
);
$Self->False(
    $AppointmentGet5{AppointmentID},
    'AppointmentDelete() - #4 check if really deleted',
);

# Create a long appointment
my $AppointmentID9 = $AppointmentObject->AppointmentCreate(
    CalendarID  => $Calendar1{CalendarID},
    Title       => 'Long appointment',
    Description => 'Test',
    Location    => 'Straubing',
    StartTime   => '2016-01-28 12:00:00',
    EndTime     => '2016-03-02 17:00:00',
    AllDay      => 1,
    TimezoneID  => 1,
    UserID      => $UserID,
);

my $AppointmentID10 = $AppointmentObject->AppointmentCreate(
    CalendarID  => $Calendar1{CalendarID},
    Title       => 'Long appointment 2',
    Description => 'Test',
    Location    => 'Straubing',
    StartTime   => '2016-02-02 12:00:00',
    EndTime     => '2016-03-05 17:00:00',
    AllDay      => 1,
    TimezoneID  => 1,
    UserID      => $UserID,
);

# recurring appointment without additional recurring parameter
my $AppointmentID11 = $AppointmentObject->AppointmentCreate(
    CalendarID  => $Calendar1{CalendarID},
    Title       => 'Bad recurring',
    Description => 'How to use Process tickets...',
    StartTime   => '2016-01-01 15:00:00',
    EndTime     => '2016-01-01 16:00:00',
    TimezoneID  => 0,
    Recurring   => 1,
    UserID      => $UserID,
);
$Self->False(
    $AppointmentID11,
    "AppointmentCreate #11"
);

# Create new calendar
my %Calendar3 = $CalendarObject->CalendarCreate(
    CalendarName => 'Test calendar 3',
    GroupID      => $GroupID,
    UserID       => $UserID,
);
$Self->True(
    $Calendar3{CalendarID},
    "CalendarCreate( CalendarName => 'Test calendar 3', UserID => $UserID )",
);

# recurring once per month
my $AppointmentID12 = $AppointmentObject->AppointmentCreate(
    CalendarID          => $Calendar3{CalendarID},
    Title               => 'Monthly recurring',
    Description         => 'How to use Process tickets...',
    StartTime           => '2016-01-31 15:00:00',
    EndTime             => '2016-01-31 16:00:00',
    Recurring           => 1,
    RecurrenceByMonth   => 1,
    RecurrenceFrequency => 1,
    RecurrenceUntil     => '2017-01-03 16:00:00',
    TimezoneID          => 0,
    UserID              => $UserID,
);
$Self->True(
    $AppointmentID12,
    "AppointmentCreate #12"
);

# check values
my @Appointments12 = $AppointmentObject->AppointmentList(
    CalendarID => $Calendar3{CalendarID},
    StartTime  => '2016-01-01 00:00:00',
    EndTime    => '2017-02-01 00:00:00',
    Result     => 'HASH',
);
$Self->Is(
    scalar @Appointments12,
    12,
    "AppointmentCreate #12 - count"
);

# Problematic test on older Perl systems.
my @Appointments12StartTimes = (
    '2016-01-31 15:00:00',
    '2016-02-29 15:00:00',
    '2016-03-31 15:00:00',
    '2016-04-30 15:00:00',
    '2016-05-31 15:00:00',
    '2016-06-30 15:00:00',
    '2016-07-31 15:00:00',
    '2016-08-31 15:00:00',
    '2016-09-30 15:00:00',
    '2016-10-31 15:00:00',
    '2016-11-30 15:00:00',
    '2016-12-31 15:00:00',
);

for ( my $Index = 0; $Index < 12; $Index++ ) {
    $Self->Is(
        $Appointments12[$Index]->{StartTime},
        $Appointments12StartTimes[$Index],
        "AppointmentCreate #12 - $Index"
    );
}

my %AppointmentDays1 = $AppointmentObject->AppointmentDays(
    StartTime => '2016-01-25 00:00:00',
    EndTime   => '2016-02-01 00:00:00',
    UserID    => $UserID,
);

for my $Date (qw(2016-01-28 2016-01-29 2016-01-30 )) {
    $Self->Is(
        $AppointmentDays1{$Date},
        1,
        "AppointmentDays1 - #$Date",
    );
}

my %AppointmentDays2 = $AppointmentObject->AppointmentDays(
    StartTime => '2016-02-10 00:00:00',
    EndTime   => '2016-02-12 00:00:00',
    UserID    => $UserID,
);

for my $Date (qw(2016-02-10 2016-02-11 )) {
    $Self->Is(
        $AppointmentDays2{$Date},
        2,
        "AppointmentDays2 - #$Date",
    );
}

# Without EndTime
my %AppointmentDays3 = $AppointmentObject->AppointmentDays(
    StartTime => '2016-03-01 00:00:00',
    UserID    => $UserID,
);

for my $Date (qw(2016-03-03 2016-03-05 2016-03-06 2016-03-08 2016-03-10)) {
    $Self->Is(
        $AppointmentDays3{$Date},
        1,
        "AppointmentDays3 - #$Date",
    );
}

for my $Date (qw(2016-03-04 2016-03-01)) {
    $Self->Is(
        $AppointmentDays3{$Date},
        2,
        "AppointmentDays3 - #$Date",
    );
}

for my $Date (qw( 2016-03-02 )) {
    $Self->Is(
        $AppointmentDays3{$Date},
        3,
        "AppointmentDays3 - #$Date",
    );
}

# Without StartTime
my %AppointmentDays4 = $AppointmentObject->AppointmentDays(
    EndTime => '2016-01-05 00:00:00',
    UserID  => $UserID,
);

$Self->Is(
    scalar keys(%AppointmentDays4),
    1,
    "AppointmentDays4 count",
);

$Self->Is(
    $AppointmentDays4{'2016-01-01'},
    1,
    "AppointmentDays4 - 2",
);

# edge
my %AppointmentDays5 = $AppointmentObject->AppointmentDays(
    StartTime => '2016-02-02 12:00:00',
    EndTime   => '2016-03-05 17:00:00',
    UserID    => $UserID,
);

my @Lst = $AppointmentObject->AppointmentList(
    StartTime  => '2016-02-02 12:00:00',
    EndTime    => '2016-03-05 17:00:00',
    UserID     => $UserID,
    CalendarID => $Calendar1{CalendarID},
);

$AppointmentDays5{RR} = \@Lst;

for my $Date (qw(2016-03-03 2016-03-05)) {
    $Self->Is(
        $AppointmentDays5{$Date},
        1,
        "AppointmentDays5 - #$Date",
    );
}
for my $Date (
    qw(2016-02-02 2016-02-03 2016-02-04 2016-02-05 2016-02-06 2016-02-07 2016-02-08 2016-02-09 2016-02-10 2016-02-11 2016-02-12
    2016-02-13 2016-02-14 2016-02-15 2016-02-16 2016-02-17 2016-02-18 2016-02-19 2016-02-20 2016-02-21 2016-02-22 2016-02-23
    2016-02-24 2016-02-25 2016-02-26 2016-02-27 2016-02-28 2016-03-01 2016-03-04)
    )
{
    $Self->Is(
        $AppointmentDays5{$Date},
        2,
        "AppointmentDays5 - #$Date",
    );
}
for my $Date (qw(2016-02-29 2016-03-02 )) {
    $Self->Is(
        $AppointmentDays5{$Date},
        3,
        "AppointmentDays5 - #$Date",
    );
}

$Self->Is(
    scalar keys(%AppointmentDays5),
    34,
    "AppointmentDays5 count",
);

# no UserID
my %AppointmentDays6 = $AppointmentObject->AppointmentDays(
    StartTime => '2016-02-02 12:00:00',
    EndTime   => '2016-03-05 17:00:00',
);

my $AppointmentDaysEmpty6 = 1;
if (%AppointmentDays6) {
    $AppointmentDaysEmpty6 = 0;
}

$Self->True(
    $AppointmentDaysEmpty6,
    "AppointmentDays6 - No UserID",
);

my $Seen1 = $AppointmentObject->AppointmentSeenGet(
    AppointmentID => $AppointmentID1,
    UserID        => $UserID,
);
$Self->False(
    $Seen1,
    "AppointmentSeenGet #1",
);

my $SeenSet1 = $AppointmentObject->AppointmentSeenSet(
    AppointmentID => $AppointmentID1,
    UserID        => $UserID,
);

$Self->True(
    $SeenSet1,
    "AppointmentSeenSet #1",
);

my $Seen2 = $AppointmentObject->AppointmentSeenGet(
    AppointmentID => $AppointmentID1,
    UserID        => $UserID,
);

$Self->True(
    $Seen2,
    "AppointmentSeenGet #2",
);

my $Update9 = $AppointmentObject->AppointmentUpdate(
    AppointmentID => $AppointmentID1,
    CalendarID    => $Calendar1{CalendarID},
    Title         => 'Webinar title',
    StartTime     => '2016-01-02 16:00:00',
    EndTime       => '2016-01-02 16:15:00',
    TimezoneID    => 1,
    UserID        => $UserID,
);
$Self->True(
    $Update9,
    "AppointmentUpdate #9",
);

# Missing TimezoneID
my $Update10 = $AppointmentObject->AppointmentUpdate(
    AppointmentID   => $AppointmentID1,
    CalendarID      => $Calendar1{CalendarID},
    Title           => 'Webinar title',
    StartTime       => '2016-01-02 16:00:00',
    EndTime         => '2016-01-02 16:15:00',
    Recurring       => 1,
    RecurrenceByDay => 1,
    UserID          => $UserID,
);
$Self->False(
    $Update10,
    "AppointmentUpdate #10",
);

my $Seen3 = $AppointmentObject->AppointmentSeenGet(
    AppointmentID => $AppointmentID1,
    UserID        => $UserID,
);
$Self->False(
    $Seen3,
    "AppointmentSeenGet #3",
);

my $SeenSet2 = $AppointmentObject->AppointmentSeenSet(
    AppointmentID => $AppointmentID1,
    UserID        => $UserID,
);
$Self->True(
    $SeenSet2,
    "AppointmentSeenSet #2",
);

my $Seen4 = $AppointmentObject->AppointmentSeenGet(
    AppointmentID => $AppointmentID1,
    UserID        => $UserID,
);

$Self->True(
    $Seen4,
    "AppointmentSeenGet #4",
);

# delete appointment
my $Delete6 = $AppointmentObject->AppointmentDelete(
    AppointmentID => $AppointmentID1,
    UserID        => $UserID,
);

$Self->True(
    $Delete6,
    "Delete #6 - rw permissions",
);

my $Seen5 = $AppointmentObject->AppointmentSeenGet(
    AppointmentID => $AppointmentID1,
    UserID        => $UserID,
);
$Self->False(
    $Seen5,
    "AppointmentSeenGet #5",
);

# missing AppointmentIAppointmentCreate #1
my $Seen6 = $AppointmentObject->AppointmentSeenGet(
    UserID => $UserID,
);
$Self->False(
    defined $Seen6,
    "AppointmentSeenGet #6",
);

# missing UserID
my $Seen7 = $AppointmentObject->AppointmentSeenGet(
    AppointmentID => $AppointmentID1,
);
$Self->False(
    defined $Seen6,
    "AppointmentSeenGet #7",
);

# missing AppointmentID
my $SeenSet3 = $AppointmentObject->AppointmentSeenSet(
    UserID => $UserID,
);
$Self->False(
    defined $SeenSet3,
    "AppointmentSeenSet #3",
);

# missing UserID
my $SeenSet4 = $AppointmentObject->AppointmentSeenSet(
    AppointmentID => $AppointmentID1,
);
$Self->False(
    defined $SeenSet4,
    "AppointmentSeenSet #4",
);

1;
