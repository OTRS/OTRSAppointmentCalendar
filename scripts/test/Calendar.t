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

# get Calendar object
my $CalendarObject = $Kernel::OM->Get('Kernel::System::Calendar');

# get helper object
$Kernel::OM->ObjectParamAdd(
    'Kernel::System::UnitTest::Helper' => {
        RestoreDatabase => 1,
    },
);
my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');

my $UserID = 1;    # Use root

# This will be ok
my %Calendar1 = $CalendarObject->CalendarCreate(
    CalendarName => 'Test calendar',
    UserID       => $UserID,
);

$Self->True(
    $Calendar1{CalendarID},
    'CalendarCreate( CalendarName => "Test calendar", UserID => 1 ) - CalendarID',
);

$Self->True(
    $Calendar1{UserID},
    'CalendarCreate( CalendarName => "Test calendar", UserID => 1 ) - UserID',
);

$Self->True(
    $Calendar1{CalendarName},
    'CalendarCreate( CalendarName => "Test calendar", UserID => 1 ) - CalendarName',
);

$Self->True(
    $Calendar1{CreateTime},
    'CalendarCreate( CalendarName => "Test calendar", UserID => 1 ) - CreateTime',
);

$Self->True(
    $Calendar1{CreateBy},
    'CalendarCreate( CalendarName => "Test calendar", UserID => 1 ) - CreateBy',
);

$Self->True(
    $Calendar1{ChangeTime},
    'CalendarCreate( CalendarName => "Test calendar", UserID => 1 ) - ChangeTime',
);

$Self->True(
    $Calendar1{ChangeBy},
    'CalendarCreate( CalendarName => "Test calendar", UserID => 1 ) - ChangeBy',
);

$Self->True(
    $Calendar1{ValidID},
    'CalendarCreate( CalendarName => "Test calendar", UserID => 1 ) - ValidID',
);

# Try with same name
my %Calendar2 = $CalendarObject->CalendarCreate(
    CalendarName => 'Test calendar',
    UserID       => $UserID,
);

$Self->False(
    $Calendar2{CalendarID},
    'CalendarCreate( CalendarName => "Test calendar", UserID => 1 ) again same name',
);

# Try without calendar name
my %Calendar3 = $CalendarObject->CalendarCreate(
    UserID => $UserID,
);

$Self->False(
    $Calendar3{CalendarID},
    'CalendarCreate( UserID => 1 ) without name',
);

# Try without UserID
my %Calendar4 = $CalendarObject->CalendarCreate(
    CalendarName => 'Meetings',
);

$Self->False(
    $Calendar4{CalendarID},
    'CalendarCreate( CalendarName => "Meetings" ) without UserID',
);

my %Calendar5 = $CalendarObject->CalendarCreate(
    CalendarName => 'Test calendar 2',
    UserID       => $UserID,
    ValidID      => 2,
);

$Self->True(
    $Calendar5{CalendarID},
    'CalendarCreate( CalendarName => "Meetings", UserID => 1, ValidID => 2,) invalid state',
);

my %CalendarGet1 = $CalendarObject->CalendarGet(
    CalendarName => 'Test calendar',
    UserID       => $UserID,
);

$Self->True(
    $CalendarGet1{CalendarID},
    'CalendarGet( CalendarName => "Test calendar", UserID => 1 )',
);

my %CalendarGet2 = $CalendarObject->CalendarGet(
    CalendarID => $CalendarGet1{CalendarID},
);

my $Compare = $Self->IsDeeply(
    \%CalendarGet1,
    \%CalendarGet2,
    'Same',
);

$Self->True(
    $Compare,
    'Compare results',
);

# Try without params
my %CalendarGet3 = $CalendarObject->CalendarGet();
$Self->False(
    $CalendarGet3{CalendarID},
    'CalendarGet() without parameters',
);

# Missing UserID
my %CalendarGet4 = $CalendarObject->CalendarGet(
    CalendarName => 'Test calendar',
);
$Self->False(
    $CalendarGet4{CalendarID},
    'CalendarGet( CalendarName => "Test calendar") without UserID',
);

# Missing CalendarName
my %CalendarGet5 = $CalendarObject->CalendarGet(
    UserID => $UserID,
);
$Self->False(
    $CalendarGet5{CalendarID},
    'CalendarGet(UserID => 1) without CalendarName',
);

# Without params
my @CalendarList1 = $CalendarObject->CalendarList();
$Self->True(
    scalar @CalendarList1 > 1,
    'CalendarList() without parameters',
);

my %CalendarListItem1 = %{ $CalendarList1[0] };
$Self->True(
    $CalendarListItem1{CalendarID},
    'CalendarList() has CalendarID',
);

$Self->True(
    $CalendarListItem1{UserID},
    'CalendarList() has UserID',
);

$Self->True(
    $CalendarListItem1{CalendarName},
    'CalendarList() has CalendarName',
);

$Self->True(
    $CalendarListItem1{CreateTime},
    'CalendarList() has CreateTime',
);

$Self->True(
    $CalendarListItem1{CreateBy},
    'CalendarList() has CreateBy',
);

$Self->True(
    $CalendarListItem1{ChangeTime},
    'CalendarList() has ChangeTime',
);

$Self->True(
    $CalendarListItem1{ChangeBy},
    'CalendarList() has ChangeBy',
);

$Self->True(
    $CalendarListItem1{ValidID},
    'CalendarList() has ValidID',
);

# With UserID
my @CalendarList2 = $CalendarObject->CalendarList(
    UserID => $UserID,
);
$Self->True(
    scalar @CalendarList2 == 2,
    'CalendarList( UserID = 1) with UserID',
);

# only valid
my @CalendarList3 = $CalendarObject->CalendarList(
    UserID  => $UserID,
    ValidID => 1,
);
$Self->True(
    scalar @CalendarList3 == 1,
    'CalendarList(UserID = 1, ValidID = 1) valid state',
);

# only invalid
my @CalendarList4 = $CalendarObject->CalendarList(
    UserID  => $UserID,
    ValidID => 2,
);
$Self->True(
    scalar @CalendarList4 == 1,
    'CalendarList(UserID = 1, ValidID = 2) invalid state',
);

# Try without OwnerID
my $Update1 = $CalendarObject->CalendarUpdate(
    CalendarID   => $Calendar1{CalendarID},
    CalendarName => 'Meetings',            # (required) Personal calendar name
                                           # OwnerID          => 2,                   # (optional) Calendar owner UserID
    UserID       => $UserID,               # (required) UserID (who made update)
    ValidID      => 2,                     # (required) ValidID
);
$Self->True(
    $Update1,
    "CalendarUpdate(CalendarID => 2, CalendarName => $Calendar1{CalendarID}, UserID => $UserID, ValidID => 2)",
);

my %CalendarGet6 = $CalendarObject->CalendarGet(
    CalendarID => $CalendarGet1{CalendarID},
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

1;
