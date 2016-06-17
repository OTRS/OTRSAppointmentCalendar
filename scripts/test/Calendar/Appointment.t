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
    Color        => '#3A87AD',
    GroupID      => $GroupID,
    UserID       => $UserID,
);

$Self->True(
    $Calendar1{CalendarID},
    "CalendarCreate( CalendarName => 'Test calendar', Color => '#3A87AD', GroupID => $GroupID, UserID => $UserID ) - CalendarID",
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
    CalendarID  => $Calendar1{CalendarID},
    Title       => 'Title',
    Description => 'Description',
    Location    => 'Germany',
    StartTime   => '2016-01-01 16:00:00',
    EndTime     => '2016-01-01 17:00:00',
    AllDay      => 1,
    TimezoneID  => 0,                        # this must be accepted (UTC)
    UserID      => $UserID,
);
$Self->True(
    $AppointmentID8,
    'AppointmentCreate #8',
);

my @Appointments1 = $AppointmentObject->AppointmentList(
    CalendarID => $Calendar1{CalendarID},
    StartTime  => '2016-01-01 16:00:00',     # Try at this point of time (at this second)
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
    CalendarID         => $Calendar1{CalendarID},
    Title              => 'Recurring appointment',
    Description        => 'Description',
    Location           => 'Germany',
    StartTime          => '2016-03-01 16:00:00',
    EndTime            => '2016-03-01 17:00:00',
    AllDay             => 1,
    TimezoneID         => 1,
    Recurring          => 1,
    RecurrenceType     => "Daily",
    RecurrenceInterval => 1,                         # once per day
    RecurrenceUntil    => '2016-03-06 00:00:00',     # included last day
    UserID             => $UserID,
);
$Self->True(
    $AppointmentIDRec1,
    'Recurring appointment #1 created',
);

# missing RecurrenceFrequency
my $AppointmentIDRecPass1 = $AppointmentObject->AppointmentCreate(
    CalendarID         => $Calendar1{CalendarID},
    Title              => 'Recurring appointment',
    Description        => 'Description',
    Location           => 'Germany',
    StartTime          => '2018-03-01 16:00:00',
    EndTime            => '2018-03-01 17:00:00',
    AllDay             => 1,
    TimezoneID         => 1,
    Recurring          => 1,
    RecurrenceType     => "CustomDaily",
    RecurrenceInterval => 1,
    RecurrenceCount    => 2,
    UserID             => $UserID,
);
$Self->True(
    $AppointmentIDRecPass1,
    'Recurring appointment(CustomDaily) - without RecurrenceFrequency',
);

# missing RecurrenceType
my $AppointmentIDRecFail1 = $AppointmentObject->AppointmentCreate(
    CalendarID  => $Calendar1{CalendarID},
    Title       => 'Recurring appointment',
    Description => 'Description',
    Location    => 'Germany',
    StartTime   => '2016-03-01 16:00:00',
    EndTime     => '2016-03-01 17:00:00',
    AllDay      => 1,
    TimezoneID  => 1,
    Recurring   => 1,

    # RecurrenceType     => "Daily",
    RecurrenceInterval => 1,
    RecurrenceUntil    => '2016-03-06 00:00:00',
    UserID             => $UserID,
);
$Self->False(
    $AppointmentIDRecFail1,
    'Recurring appointment without RecurrenceType',
);

# wrong RecurrenceType
my $AppointmentIDRecFail2 = $AppointmentObject->AppointmentCreate(
    CalendarID         => $Calendar1{CalendarID},
    Title              => 'Recurring appointment',
    Description        => 'Description',
    Location           => 'Germany',
    StartTime          => '2016-03-01 16:00:00',
    EndTime            => '2016-03-01 17:00:00',
    AllDay             => 1,
    TimezoneID         => 1,
    Recurring          => 1,
    RecurrenceType     => "WrongDaily",              # WrongDaily is not supported
    RecurrenceInterval => 1,
    RecurrenceUntil    => '2016-03-06 00:00:00',
    UserID             => $UserID,
);
$Self->False(
    $AppointmentIDRecFail2,
    'Recurring appointment - wrong RecurrenceType',
);

# missing RecurrenceFrequency
my $AppointmentIDRecFail3 = $AppointmentObject->AppointmentCreate(
    CalendarID         => $Calendar1{CalendarID},
    Title              => 'Recurring appointment',
    Description        => 'Description',
    Location           => 'Germany',
    StartTime          => '2016-03-01 16:00:00',
    EndTime            => '2016-03-01 17:00:00',
    AllDay             => 1,
    TimezoneID         => 1,
    Recurring          => 1,
    RecurrenceType     => "CustomWeekly",
    RecurrenceInterval => 1,
    RecurrenceUntil    => '2016-03-06 00:00:00',
    UserID             => $UserID,
);
$Self->False(
    $AppointmentIDRecFail3,
    'Recurring appointment(CustomWeekly) - missing RecurrenceFrequency',
);

# missing RecurrenceFrequency
my $AppointmentIDRecFail4 = $AppointmentObject->AppointmentCreate(
    CalendarID         => $Calendar1{CalendarID},
    Title              => 'Recurring appointment',
    Description        => 'Description',
    Location           => 'Germany',
    StartTime          => '2016-03-01 16:00:00',
    EndTime            => '2016-03-01 17:00:00',
    AllDay             => 1,
    TimezoneID         => 1,
    Recurring          => 1,
    RecurrenceType     => "CustomMonthly",
    RecurrenceInterval => 1,
    RecurrenceUntil    => '2016-03-06 00:00:00',
    UserID             => $UserID,
);
$Self->False(
    $AppointmentIDRecFail4,
    'Recurring appointment(CustomMonthly) - missing RecurrenceFrequency',
);

# missing RecurrenceFrequency
my $AppointmentIDRecFail5 = $AppointmentObject->AppointmentCreate(
    CalendarID         => $Calendar1{CalendarID},
    Title              => 'Recurring appointment',
    Description        => 'Description',
    Location           => 'Germany',
    StartTime          => '2016-03-01 16:00:00',
    EndTime            => '2016-03-01 17:00:00',
    AllDay             => 1,
    TimezoneID         => 1,
    Recurring          => 1,
    RecurrenceType     => "CustomYearly",
    RecurrenceInterval => 1,
    RecurrenceUntil    => '2016-03-06 00:00:00',
    UserID             => $UserID,
);
$Self->False(
    $AppointmentIDRecFail5,
    'Recurring appointment(CustomYearly) - missing RecurrenceFrequency',
);

# add recurring appointment once a week
my $AppointmentIDRec2 = $AppointmentObject->AppointmentCreate(
    CalendarID         => $Calendar1{CalendarID},
    Title              => 'Weekly recurring appointment',
    Description        => 'Description',
    Location           => 'Germany',
    StartTime          => '2016-10-01 16:00:00',
    EndTime            => '2016-10-01 17:00:00',
    AllDay             => 1,
    TimezoneID         => 1,
    Recurring          => 1,
    RecurrenceType     => "Weekly",
    RecurrenceInterval => 1,                                # each week
    RecurrenceUntil    => '2016-10-06 00:00:00',            # included last day
    UserID             => $UserID,
);
$Self->True(
    $AppointmentIDRec2,
    'Weekly recurring appointment #2 created',
);

# add recurring appointment once a month
my $AppointmentIDRec3 = $AppointmentObject->AppointmentCreate(
    CalendarID         => $Calendar1{CalendarID},
    Title              => 'Monthly recurring appointment',
    Description        => 'Description',
    Location           => 'Germany',
    StartTime          => '2016-10-07 16:00:00',
    EndTime            => '2016-10-07 17:00:00',
    AllDay             => 1,
    TimezoneID         => 1,
    Recurring          => 1,
    RecurrenceType     => "Monthly",
    RecurrenceInterval => 1,                                 # each month
    RecurrenceCount    => 3,                                 # 3 months
    UserID             => $UserID,
);
$Self->True(
    $AppointmentIDRec3,
    'Monthly recurring appointment #3 created',
);

# add recurring appointment once a month
my $AppointmentIDRec4 = $AppointmentObject->AppointmentCreate(
    CalendarID         => $Calendar1{CalendarID},
    Title              => 'Monthly recurring appointment',
    Description        => 'Description',
    Location           => 'Germany',
    StartTime          => '2016-10-10 16:00:00',
    EndTime            => '2016-10-10 17:00:00',
    AllDay             => 1,
    TimezoneID         => 1,
    Recurring          => 1,
    RecurrenceType     => "Yearly",
    RecurrenceInterval => 1,                                 # each year
    RecurrenceCount    => 3,                                 # 3 years
    UserID             => $UserID,
);
$Self->True(
    $AppointmentIDRec4,
    'Yearly recurring appointment #4 created',
);

# add recurring appointment each 2 days
my $AppointmentIDRec5 = $AppointmentObject->AppointmentCreate(
    CalendarID         => $Calendar1{CalendarID},
    Title              => 'Custom daily recurring appointment',
    Description        => 'Description',
    Location           => 'Germany',
    StartTime          => '2017-01-01 16:00:00',
    EndTime            => '2016-01-01 17:00:00',
    AllDay             => 1,
    TimezoneID         => 1,
    Recurring          => 1,
    RecurrenceType     => 'CustomDaily',
    RecurrenceInterval => 2,
    RecurrenceCount    => 3,                                      # 3 appointments
    UserID             => $UserID,
);
$Self->True(
    $AppointmentIDRec5,
    'Recurring appointment #5 created',
);

# add recurring appointment on Wednesday - recurring Monday and Friday
my $AppointmentIDRec6 = $AppointmentObject->AppointmentCreate(
    CalendarID          => $Calendar1{CalendarID},
    Title               => 'Custom weekly recurring appointment',
    Description         => 'Description',
    Location            => 'Germany',
    StartTime           => '2016-05-04 16:00:00',                   # wednesday
    EndTime             => '2016-05-04 17:00:00',
    AllDay              => 1,
    TimezoneID          => 1,
    Recurring           => 1,
    RecurrenceType      => 'CustomWeekly',
    RecurrenceInterval  => 2,                                       # each 2nd
    RecurrenceFrequency => [ 1, 5 ],                                # Monday and Friday
    RecurrenceCount     => 3,                                       # 3 appointments
    UserID              => $UserID,
);
$Self->True(
    $AppointmentIDRec6,
    'Recurring appointment #6 created',
);

# add recurring appointment each 2nd month on 5th, 10th and 15th day
my $AppointmentIDRec7 = $AppointmentObject->AppointmentCreate(
    CalendarID          => $Calendar1{CalendarID},
    Title               => 'Custom monthly recurring appointment',
    Description         => 'Description',
    Location            => 'Germany',
    StartTime           => '2016-07-05 16:00:00',
    EndTime             => '2016-07-05 17:00:00',
    AllDay              => 1,
    TimezoneID          => 1,
    Recurring           => 1,
    RecurrenceType      => "CustomMonthly",
    RecurrenceInterval  => 2,                                        # each 2 months
    RecurrenceFrequency => [ 5, 10, 15 ],                            # Days in month
    RecurrenceCount     => 6,                                        # 3 appointments
    UserID              => $UserID,
);
$Self->True(
    $AppointmentIDRec7,
    'Recurring appointment #7 created',
);

# add recurring appointment each 2nd year on 5th january, february and december
my $AppointmentIDRec8 = $AppointmentObject->AppointmentCreate(
    CalendarID          => $Calendar1{CalendarID},
    Title               => 'Custom yearly recurring appointment',
    Description         => 'Description',
    Location            => 'Germany',
    StartTime           => '2016-01-05 16:00:00',
    EndTime             => '2016-01-05 17:00:00',
    AllDay              => 1,
    TimezoneID          => 1,
    Recurring           => 1,
    RecurrenceType      => "CustomYearly",
    RecurrenceInterval  => 2,                                       # each 2 months
    RecurrenceFrequency => [ 1, 2, 12 ],                            # months
    RecurrenceCount     => 3,                                       # 3 appointments
    UserID              => $UserID,
);
$Self->True(
    $AppointmentIDRec8,
    'Recurring appointment #8 created',
);

# add custom weekly recurring appointment (All day)
my $AppointmentIDRec9 = $AppointmentObject->AppointmentCreate(
    CalendarID          => $Calendar1{CalendarID},
    Title               => 'Custom Recurring appointment 5',
    Description         => 'Description',
    Location            => 'Germany',
    StartTime           => '2016-09-01 00:00:00',
    EndTime             => '2016-09-02 00:00:00',
    AllDay              => 1,
    TimezoneID          => 1,
    Recurring           => 1,
    RecurrenceType      => "CustomWeekly",
    RecurrenceInterval  => 2,                                  # each 2 weeks
    RecurrenceFrequency => [ 1, 3, 4, 5, 7 ],                  # Mod, Wed, Thu, Fri, Sun
    RecurrenceUntil     => '2017-10-01 00:00:00',              # october
    UserID              => $UserID,
);
$Self->True(
    $AppointmentIDRec9,
    'Recurring appointment #9 created',
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
    AppointmentID      => $AppointmentIDRec1,
    CalendarID         => $Calendar1{CalendarID},
    Title              => 'Classes',
    Description        => 'Additional description',
    Location           => 'Germany',
    StartTime          => '2016-03-02 16:00:00',
    EndTime            => '2016-03-02 17:00:00',
    AllDay             => 1,
    TimezoneID         => 1,
    Recurring          => 1,
    RecurrenceType     => "CustomDaily",
    RecurrenceInterval => 2,                          # each 2 days
    RecurrenceUntil    => '2016-03-10 17:00:00',
    UserID             => $UserID,
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

# list recurring appointments
my @AppointmentsRec5List = $AppointmentObject->AppointmentList(
    CalendarID => $Calendar1{CalendarID},
    StartTime  => '2016-09-01 00:00:00',
    EndTime    => '2016-10-01 00:00:00',
);

my @AppointmentRec5Only;
for my $Appointment ( sort { $a->{StartTime} cmp $b->{StartTime} } @AppointmentsRec5List ) {
    if ( $Appointment->{Title} eq 'Custom Recurring appointment 5' ) {
        push @AppointmentRec5Only, $Appointment;
    }
}

my @AppointmentRec5Expected = (
    {
        'StartTime' => '2016-09-01 00:00:00',
        'EndTime'   => '2016-09-02 00:00:00',
    },
    {
        'StartTime' => '2016-09-02 00:00:00',
        'EndTime'   => '2016-09-03 00:00:00'
    },
    {
        'StartTime' => '2016-09-04 00:00:00',
        'EndTime'   => '2016-09-05 00:00:00',
    },
    {
        'StartTime' => '2016-09-12 00:00:00',
        'EndTime'   => '2016-09-13 00:00:00',
    },
    {
        'StartTime' => '2016-09-14 00:00:00',
        'EndTime'   => '2016-09-15 00:00:00',
    },
    {
        'StartTime' => '2016-09-15 00:00:00',
        'EndTime'   => '2016-09-16 00:00:00',
    },
    {
        'StartTime' => '2016-09-16 00:00:00',
        'EndTime'   => '2016-09-17 00:00:00',
    },
    {
        'StartTime' => '2016-09-18 00:00:00',
        'EndTime'   => '2016-09-19 00:00:00',
    },
    {
        'StartTime' => '2016-09-26 00:00:00',
        'EndTime'   => '2016-09-27 00:00:00',
    },
    {
        'StartTime' => '2016-09-28 00:00:00',
        'EndTime'   => '2016-09-29 00:00:00',
    },
    {
        'StartTime' => '2016-09-29 00:00:00',
        'EndTime'   => '2016-09-30 00:00:00',
    },
    {
        'StartTime' => '2016-09-30 00:00:00',
        'EndTime'   => '2016-10-01 00:00:00',
    }
);

for ( my $Counter = 0; $Counter < scalar @AppointmentRec5Expected; $Counter++ ) {
    for my $Item ( sort keys %{ $AppointmentRec5Expected[$Counter] } ) {
        $Self->Is(
            $AppointmentRec5Expected[$Counter]->{$Item},
            $AppointmentRec5Only[$Counter]->{$Item},
            "AppointmentRec5 - $Item = $AppointmentRec5Expected[$Counter]->{$Item}",
        );
    }
}

my %AppointmentGet1 = $AppointmentObject->AppointmentGet(
    AppointmentID => $AppointmentID8,
);

my %AppointmentExpected1 = (
    AppointmentID      => $AppointmentID8,
    CalendarID         => $Calendar1{CalendarID},
    Title              => 'Title',
    Description        => 'Description',
    Location           => 'Germany',
    StartTime          => '2016-01-01 16:00:00',
    EndTime            => '2016-01-01 17:00:00',
    AllDay             => 1,
    TimezoneID         => 0,
    RecurrenceInterval => 1,
    CreateBy           => $UserID,
    ChangeBy           => $UserID,
);

for my $Key ( sort keys %AppointmentExpected1 ) {
    $Self->Is(
        $AppointmentGet1{$Key},
        $AppointmentExpected1{$Key},
        "AppointmentGet() - $Key ok",
    );
}

$Self->True(
    $AppointmentGet1{UniqueID},
    'AppointmentGet() - UniqueID ok',
);

$Self->True(
    $AppointmentGet1{CreateTime},
    'AppointmentGet() - CreateTime ok',
);
$Self->True(
    $AppointmentGet1{ChangeTime},
    'AppointmentGet() - ChangeTime ok',
);

my %AppointmentGet2 = $AppointmentObject->AppointmentGet();
$Self->False(
    $AppointmentGet2{AppointmentID},
    'AppointmentGet() - Missing AppointmentID and UniqueID',
);

# get by UniqueID
my %AppointmentGet3 = $AppointmentObject->AppointmentGet(
    UniqueID   => $AppointmentGet1{UniqueID},
    CalendarID => $AppointmentGet1{CalendarID},
);

$Self->Is(
    $AppointmentGet1{AppointmentID},
    $AppointmentGet3{AppointmentID},
    'AppointmentGet() - UniqueID',
);

my %Calendar2 = $CalendarObject->CalendarCreate(
    CalendarName => 'Test calendar 2',
    Color        => '#EC9073',
    GroupID      => $GroupID,
    UserID       => $UserID,
);

my $Update1 = $AppointmentObject->AppointmentUpdate(
    AppointmentID      => $AppointmentID8,
    CalendarID         => $Calendar2{CalendarID},
    Title              => 'Webinar title',
    Description        => 'Description details',
    Location           => 'England',
    StartTime          => '2016-01-02 16:00:00',
    EndTime            => '2016-01-02 17:00:00',
    AllDay             => 0,
    TimezoneID         => 1,
    Recurring          => 1,
    RecurrenceType     => 'Daily',
    RecurrenceInterval => 2,
    RecurrenceCount    => 2,
    UserID             => $UserID,
);
$Self->True(
    $Update1,
    'AppointmentUpdate() - #1',
);

my %AppointmentGet4 = $AppointmentObject->AppointmentGet(
    AppointmentID => $AppointmentID8,
);

my %AppointmentExpected4 = (
    AppointmentID      => $AppointmentID8,
    CalendarID         => $Calendar2{CalendarID},
    Title              => 'Webinar title',
    Description        => 'Description details',
    Location           => 'England',
    StartTime          => '2016-01-02 16:00:00',
    EndTime            => '2016-01-02 17:00:00',
    AllDay             => 0,
    TimezoneID         => 1,
    RecurrenceInterval => 2,
    RecurrenceCount    => 2,
    CreateBy           => $UserID,
    ChangeBy           => $UserID,
);

for my $Key ( sort keys %AppointmentExpected4 ) {
    $Self->Is(
        $AppointmentGet4{$Key},
        $AppointmentExpected4{$Key},
        "AppointmentGet() - $Key ok",
    );
}
$Self->True(
    $AppointmentGet4{UniqueID},
    'AppointmentUpdate() - UniqueID ok',
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
$Self->True(
    $AppointmentID9,
    'AppointmentCreate() - #9',
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
$Self->True(
    $AppointmentID10,
    'AppointmentCreate() - #10',
);

# Create new calendar
my %Calendar3 = $CalendarObject->CalendarCreate(
    CalendarName => 'Test calendar 3',
    Color        => '#6BAD54',
    GroupID      => $GroupID,
    UserID       => $UserID,
);
$Self->True(
    $Calendar3{CalendarID},
    "CalendarCreate( CalendarName => 'Test calendar 3', UserID => $UserID )",
);

# recurring once per month
my $AppointmentID12 = $AppointmentObject->AppointmentCreate(
    CalendarID         => $Calendar3{CalendarID},
    Title              => 'Monthly recurring',
    Description        => 'How to use Process tickets...',
    StartTime          => '2016-01-31 15:00:00',
    EndTime            => '2016-01-31 16:00:00',
    Recurring          => 1,
    RecurrenceType     => 'Monthly',
    RecurrenceInterval => 1,
    RecurrenceUntil    => '2017-01-03 16:00:00',
    TimezoneID         => 0,
    UserID             => $UserID,
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

# add recurring appointment once a day
my $AppointmentIDRec13 = $AppointmentObject->AppointmentCreate(
    CalendarID         => $Calendar1{CalendarID},
    Title              => 'Recurring appointment',
    StartTime          => '2016-06-01 00:00:00',
    EndTime            => '2016-06-01 00:00:00',
    AllDay             => 1,
    TimezoneID         => 0,
    Recurring          => 1,
    RecurrenceType     => 'Daily',
    RecurrenceInterval => 1,                         # once per day
    RecurrenceUntil    => '2016-06-05 00:00:00',     # included last day
    UserID             => $UserID,
);

$Self->True(
    $AppointmentIDRec13,
    'Recurring appointment #13 created',
);

# check number of occurences
my @Appointments13 = $AppointmentObject->AppointmentList(
    CalendarID => $Calendar1{CalendarID},
    StartTime  => '2016-06-01 00:00:00',
    EndTime    => '2016-06-05 00:00:00',
    Result     => 'ARRAY',
);

$Self->Is(
    scalar @Appointments13,
    5,
    'Occurrences for recurring appointment #13',
);

# delete middle appointment only
my $Delete13 = $AppointmentObject->AppointmentDelete(
    AppointmentID => $Appointments13[2],
    UserID        => $UserID,
);

$Self->True(
    $Delete13,
    'Single occurrence of recurring appointment #13 deleted',
);

# check number of occurences again
@Appointments13 = $AppointmentObject->AppointmentList(
    CalendarID => $Calendar1{CalendarID},
    StartTime  => '2016-06-01 00:00:00',
    EndTime    => '2016-06-05 00:00:00',
    Result     => 'ARRAY',
);

$Self->Is(
    scalar @Appointments13,
    4,
    'Occurrences for recurring appointment #13',
);

# update title and time of the second occurrence
my $Update13 = $AppointmentObject->AppointmentUpdate(
    AppointmentID => $Appointments13[1],
    CalendarID    => $Calendar1{CalendarID},
    Title         => 'Recurring appointment edit',
    StartTime     => '2016-06-07 00:00:00',
    EndTime       => '2016-06-07 00:00:00',
    TimezoneID    => 1,
    UserID        => $UserID,
);

$Self->True(
    $Update13,
    'Single occurrence of recurring appointment #13 updated',
);

# check number of occurences again
@Appointments13 = $AppointmentObject->AppointmentList(
    CalendarID => $Calendar1{CalendarID},
    StartTime  => '2016-06-01 00:00:00',
    EndTime    => '2016-06-05 00:00:00',
    Result     => 'ARRAY',
);

$Self->Is(
    scalar @Appointments13,
    3,
    'Occurrences for recurring appointment #13',
);

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
    qw(2016-02-02 2016-02-03 2016-02-04 2016-02-06 2016-02-07 2016-02-08 2016-02-09 2016-02-10 2016-02-11 2016-02-12
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
for my $Date (qw(2016-02-05 2016-02-29 2016-03-02 )) {
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
    AppointmentID  => $AppointmentID1,
    CalendarID     => $Calendar1{CalendarID},
    Title          => 'Webinar title',
    StartTime      => '2016-01-02 16:00:00',
    EndTime        => '2016-01-02 16:15:00',
    Recurring      => 1,
    RecurrenceType => 'Daily',
    UserID         => $UserID,
);
$Self->False(
    $Update10,
    "AppointmentUpdate #10",
);

# missing RecurrenceFrequency
my $AppointmentIDRecPass2 = $AppointmentObject->AppointmentUpdate(
    AppointmentID      => $AppointmentID1,
    CalendarID         => $Calendar1{CalendarID},
    Title              => 'Recurring appointment',
    Description        => 'Description',
    Location           => 'Germany',
    StartTime          => '2018-03-01 16:00:00',
    EndTime            => '2018-03-01 17:00:00',
    AllDay             => 1,
    TimezoneID         => 1,
    Recurring          => 1,
    RecurrenceType     => "CustomDaily",
    RecurrenceInterval => 1,
    RecurrenceCount    => 2,
    UserID             => $UserID,
);
$Self->True(
    $AppointmentIDRecPass2,
    'Recurring appointment(CustomDaily) - without RecurrenceFrequency',
);

# missing RecurrenceType
my $AppointmentIDRecFail6 = $AppointmentObject->AppointmentUpdate(
    AppointmentID      => $AppointmentID1,
    CalendarID         => $Calendar1{CalendarID},
    Title              => 'Recurring appointment',
    Description        => 'Description',
    Location           => 'Germany',
    StartTime          => '2016-03-01 16:00:00',
    EndTime            => '2016-03-01 17:00:00',
    AllDay             => 1,
    TimezoneID         => 1,
    Recurring          => 1,
    RecurrenceInterval => 1,
    RecurrenceUntil    => '2016-03-06 00:00:00',
    UserID             => $UserID,
);
$Self->False(
    $AppointmentIDRecFail6,
    'Recurring appointment update without RecurrenceType',
);

# wrong RecurrenceType
my $AppointmentIDRecFail7 = $AppointmentObject->AppointmentUpdate(
    AppointmentID      => $AppointmentID1,
    CalendarID         => $Calendar1{CalendarID},
    Title              => 'Recurring appointment',
    Description        => 'Description',
    Location           => 'Germany',
    StartTime          => '2016-03-01 16:00:00',
    EndTime            => '2016-03-01 17:00:00',
    AllDay             => 1,
    TimezoneID         => 1,
    Recurring          => 1,
    RecurrenceType     => "WrongDaily",              # WrongDaily is not supported
    RecurrenceInterval => 1,
    RecurrenceUntil    => '2016-03-06 00:00:00',
    UserID             => $UserID,
);
$Self->False(
    $AppointmentIDRecFail7,
    'Recurring appointment update - wrong RecurrenceType',
);

# missing RecurrenceFrequency
my $AppointmentIDRecFail8 = $AppointmentObject->AppointmentUpdate(
    AppointmentID      => $AppointmentID1,
    CalendarID         => $Calendar1{CalendarID},
    Title              => 'Recurring appointment',
    Description        => 'Description',
    Location           => 'Germany',
    StartTime          => '2016-03-01 16:00:00',
    EndTime            => '2016-03-01 17:00:00',
    AllDay             => 1,
    TimezoneID         => 1,
    Recurring          => 1,
    RecurrenceType     => "CustomWeekly",
    RecurrenceInterval => 1,
    RecurrenceUntil    => '2016-03-06 00:00:00',
    UserID             => $UserID,
);
$Self->False(
    $AppointmentIDRecFail8,
    'Recurring appointment(CustomWeekly) update - missing RecurrenceFrequency',
);

# missing RecurrenceFrequency
my $AppointmentIDRecFail9 = $AppointmentObject->AppointmentUpdate(
    AppointmentID      => $AppointmentID1,
    CalendarID         => $Calendar1{CalendarID},
    Title              => 'Recurring appointment',
    Description        => 'Description',
    Location           => 'Germany',
    StartTime          => '2016-03-01 16:00:00',
    EndTime            => '2016-03-01 17:00:00',
    AllDay             => 1,
    TimezoneID         => 1,
    Recurring          => 1,
    RecurrenceType     => "CustomMonthly",
    RecurrenceInterval => 1,
    RecurrenceUntil    => '2016-03-06 00:00:00',
    UserID             => $UserID,
);
$Self->False(
    $AppointmentIDRecFail9,
    'Recurring appointment(CustomMonthly) update - missing RecurrenceFrequency',
);

# missing RecurrenceFrequency
my $AppointmentIDRecFail10 = $AppointmentObject->AppointmentUpdate(
    AppointmentID      => $AppointmentID1,
    CalendarID         => $Calendar1{CalendarID},
    Title              => 'Recurring appointment',
    Description        => 'Description',
    Location           => 'Germany',
    StartTime          => '2016-03-01 16:00:00',
    EndTime            => '2016-03-01 17:00:00',
    AllDay             => 1,
    TimezoneID         => 1,
    Recurring          => 1,
    RecurrenceType     => "CustomYearly",
    RecurrenceInterval => 1,
    RecurrenceUntil    => '2016-03-06 00:00:00',
    UserID             => $UserID,
);
$Self->False(
    $AppointmentIDRecFail10,
    'Recurring appointment(CustomYearly) update - missing RecurrenceFrequency',
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

# get a few UniqueIDs in quick succession
my @UniqueIDs;
for ( 1 .. 10 ) {
    push @UniqueIDs, $AppointmentObject->GetUniqueID(
        CalendarID => 1,
        StartTime  => 1451606400,    # same start time '2016-01-01 00:00:00'
        UserID     => 1,
    );
}

my %Seen;
for my $UniqueID (@UniqueIDs) {
    $Self->False(
        $Seen{$UniqueID}++,
        "UniqueID $UniqueID is unique",
    );
}

# Special use-case: Repeat each month starting on 30 April - all day.
# System used to create 2 day appointment in May (30-31), which is not OK.

# Create new calendar
my %Calendar4 = $CalendarObject->CalendarCreate(
    CalendarName => 'Test calendar 4',
    Color        => '#6BAD00',
    GroupID      => $GroupID,
    UserID       => $UserID,
);
my $AppointmentID14 = $AppointmentObject->AppointmentCreate(
    CalendarID      => $Calendar4{CalendarID},
    Title           => 'Appointment #14',
    Description     => 'How to use Process tickets...',
    StartTime       => '2016-04-30 00:00:00',
    EndTime         => '2016-05-01 00:00:00',
    TimezoneID      => 0,
    AllDay          => 1,
    Recurring       => 1,
    RecurrenceType  => 'Monthly',
    RecurrenceCount => 3,
    UserID          => $UserID,
);

my @Appointments14 = $AppointmentObject->AppointmentList(
    CalendarID => $Calendar4{CalendarID},
    Result     => 'HASH',
);

$Self->Is(
    scalar @Appointments14,
    3,
    "Appointment #14 count",
);

$Self->Is(
    $Appointments14[1]->{EndTime},
    '2016-05-31 00:00:00',
    "Appointment #14 End time check",
);

1;
