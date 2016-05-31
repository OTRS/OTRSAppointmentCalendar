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

# get calendar object
my $CalendarObject = $Kernel::OM->Get('Kernel::System::Calendar');

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

for my $Key (qw(CalendarID GroupID CalendarName Color CreateTime CreateBy ChangeTime ChangeBy ValidID)) {
    $Self->True(
        $Calendar1{$Key},
        "CalendarCreate( CalendarName => 'Test calendar', Color => '#3A87AD', GroupID => $GroupID, UserID => $UserID ) - $Key",
    );
}

# try with same name
my %Calendar2 = $CalendarObject->CalendarCreate(
    CalendarName => 'Test calendar',
    Color        => '#3A87AD',
    GroupID      => $GroupID,
    UserID       => $UserID,
);

$Self->False(
    $Calendar2{CalendarID},
    "CalendarCreate( CalendarName => 'Test calendar', Color => '#3A87AD', GroupID => $GroupID, UserID => $UserID ) again same name",
);

# try without calendar name
my %Calendar3 = $CalendarObject->CalendarCreate(
    Color   => '#3A87AD',
    GroupID => $GroupID,
    UserID  => $UserID,
);

$Self->False(
    $Calendar3{CalendarID},
    "CalendarCreate( GroupID => $GroupID, Color => '#3A87AD', UserID => $UserID ) without name",
);

# try without GroupID
my %Calendar4 = $CalendarObject->CalendarCreate(
    CalendarName => 'Meetings',
    Color        => '#3A87AD',
    UserID       => $GroupID,
);

$Self->False(
    $Calendar4{CalendarID},
    "CalendarCreate( CalendarName => 'Meetings', Color => '#3A87AD', UserID => $UserID ) without GroupID",
);

# try without UserID
my %Calendar5 = $CalendarObject->CalendarCreate(
    CalendarName => 'Meetings',
    Color        => '#3A87AD',
    GroupID      => $GroupID,
);

$Self->False(
    $Calendar5{CalendarID},
    "CalendarCreate( CalendarName => 'Meetings', Color => '#3A87AD', GroupID => $GroupID ) without UserID",
);

# try without Color
my %Calendar6 = $CalendarObject->CalendarCreate(
    CalendarName => 'Meetings',
    GroupID      => $GroupID,
    UserID       => $UserID,
);

$Self->False(
    $Calendar6{CalendarID},
    "CalendarCreate( CalendarName => 'Meetings', GroupID => $GroupID, UserID => $UserID ) without Color",
);

# try with wrong color
my %Calendar7 = $CalendarObject->CalendarCreate(
    CalendarName => 'Failure is always an option',
    Color        => 'red',
    GroupID      => $GroupID,
    UserID       => $UserID,
);

$Self->False(
    $Calendar7{CalendarID},
    "CalendarCreate( CalendarName => 'Failure is always an option', Color => 'red', GroupID => $GroupID, UserID => $UserID ) wrong Color format",
);

my %Calendar8 = $CalendarObject->CalendarCreate(
    CalendarName => 'Test calendar 2',
    Color        => '#EC9073',
    GroupID      => $GroupID,
    UserID       => $UserID,
    ValidID      => 2,
);

$Self->True(
    $Calendar8{CalendarID},
    "CalendarCreate( CalendarName => 'Meetings', GroupID => $GroupID, UserID => $UserID, ValidID => 2 ) invalid state",
);

my %CalendarGet1 = $CalendarObject->CalendarGet(
    CalendarName => 'Test calendar',
    UserID       => $UserID,
);

$Self->True(
    $CalendarGet1{CalendarID},
    "CalendarGet( CalendarName => 'Test calendar', UserID => $UserID )",
);

my %CalendarGet2 = $CalendarObject->CalendarGet(
    CalendarID => $CalendarGet1{CalendarID},
    UserID     => $UserID,
);

$Self->True(
    $CalendarGet2{CalendarID},
    "CalendarGet( CalendarID => $CalendarGet1{CalendarID}, UserID => $UserID )",
);

$Self->IsDeeply(
    \%CalendarGet1,
    \%CalendarGet2,
    'Returned data is the same',
);

# try without params
my %CalendarGet3 = $CalendarObject->CalendarGet();

$Self->False(
    $CalendarGet3{CalendarID},
    'CalendarGet() without parameters',
);

# missing UserID
my %CalendarGet4 = $CalendarObject->CalendarGet(
    CalendarName => 'Test calendar',
);

$Self->True(
    $CalendarGet4{CalendarID},
    "CalendarGet( CalendarName => 'Test calendar') without UserID",
);

# missing CalendarName or CalendarID
my %CalendarGet5 = $CalendarObject->CalendarGet(
    UserID => $UserID,
);

$Self->False(
    $CalendarGet5{CalendarID},
    "CalendarGet(UserID => $UserID) without CalendarName or CalendarID",
);

# without params
my @CalendarList1 = $CalendarObject->CalendarList();

$Self->True(
    scalar @CalendarList1 > 1,
    'CalendarList() without parameters',
);

my %CalendarListItem1 = %{ $CalendarList1[0] };

for my $Key (
    qw(CalendarID GroupID CalendarName Color CreateTime CreateBy ChangeTime ChangeBy ValidID)
    )
{
    $Self->True(
        $CalendarListItem1{$Key},
        "CalendarList() has $Key",
    );
}

# with UserID
my @CalendarList2 = $CalendarObject->CalendarList(
    UserID => $UserID,
);

$Self->True(
    scalar @CalendarList2 == 2,
    "CalendarList( UserID => $UserID ) with UserID",
);

# only valid
my @CalendarList3 = $CalendarObject->CalendarList(
    UserID  => $UserID,
    ValidID => 1,
);

$Self->True(
    scalar @CalendarList3 == 1,
    "CalendarList(UserID => $UserID, ValidID => 1) valid state",
);

# only invalid
my @CalendarList4 = $CalendarObject->CalendarList(
    UserID  => $UserID,
    ValidID => 2,
);

$Self->True(
    scalar @CalendarList4 == 1,
    "CalendarList(UserID => $UserID, ValidID => 2) invalid state",
);

# update an already added calendar
my $Update1 = $CalendarObject->CalendarUpdate(
    CalendarID   => $Calendar1{CalendarID},
    Color        => '#6BAD54',
    GroupID      => $GroupID,
    CalendarName => 'Meetings',
    UserID       => $UserID,
    ValidID      => 2,
);

$Self->True(
    $Update1,
    "CalendarUpdate( CalendarID => $Calendar1{CalendarID}, CalendarName => 'Meetings', Color => '#6BAD54', GroupID => $GroupID, UserID => $UserID, ValidID => 2 )",
);

my %CalendarGet6 = $CalendarObject->CalendarGet(
    CalendarID => $CalendarGet1{CalendarID},
    UserID     => $UserID,
);

$Self->Is(
    $CalendarGet6{CalendarName},
    'Meetings',
    "Check CalendarName",
);

$Self->Is(
    $CalendarGet6{ValidID},
    2,
    "Check ValidID",
);

# without CalendarID
my $CalendarPermission1 = $CalendarObject->CalendarPermissionGet(
    UserID => $UserID,
);
$Self->False(
    $CalendarPermission1,
    "CalendarPermissionGet #1",
);

# without UserID
my $CalendarPermission2 = $CalendarObject->CalendarPermissionGet(
    CalendarID => $CalendarGet1{CalendarID},
);
$Self->False(
    $CalendarPermission2,
    "CalendarPermissionGet #2",
);

# Ok
my $CalendarPermission3 = $CalendarObject->CalendarPermissionGet(
    CalendarID => $CalendarGet1{CalendarID},
    UserID     => $UserID,
);
$Self->Is(
    $CalendarPermission3,
    'rw',
    "CalendarPermissionGet #3",
);

1;
