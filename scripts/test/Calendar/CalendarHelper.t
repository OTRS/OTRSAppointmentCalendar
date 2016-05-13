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

my $CalendarHelperObject = $Kernel::OM->Get('Kernel::System::Calendar::Helper');

# get helper object
$Kernel::OM->ObjectParamAdd(
    'Kernel::System::UnitTest::Helper' => {
        RestoreDatabase => 1,
    },
);
my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');

# missing Time
my $TimeCheck1 = $CalendarHelperObject->TimeCheck(
    OriginalTime => '2016-01-01 00:01:00',

    # Time             => '2016-02-01 00:02:00',
);

$Self->False(
    $TimeCheck1,
    "TimeCheck - Missing Time."
);

# missing OriginalTime
my $TimeCheck2 = $CalendarHelperObject->TimeCheck(

    # OriginalTime     => '2016-01-01 00:01:00',
    Time => '2016-02-01 00:02:00',
);

$Self->False(
    $TimeCheck2,
    "TimeCheck - Missing OriginalTime."
);

# OK
my $TimeCheck3 = $CalendarHelperObject->TimeCheck(
    OriginalTime => '2016-01-01 00:01:00',
    Time         => '2016-02-01 00:02:00',
);

$Self->Is(
    $TimeCheck3,
    '2016-02-01 00:01:00',
    "TimeCheck - OK.",
);

my $SystemTimeGet1 = $CalendarHelperObject->SystemTimeGet();

$Self->False(
    $SystemTimeGet1,
    "SystemTimeGet - without String"
);

my $SystemTimeGet2 = $CalendarHelperObject->SystemTimeGet(
    String => '2016-01-01 00:01:00',
);

$Self->Is(
    $SystemTimeGet2,
    '1451606460',
    "SystemTimeGet - OK",
);

my $TimestampGet1 = $CalendarHelperObject->TimestampGet();
$Self->False(
    $TimestampGet1,
    "TimestampGet - without SystemTime"
);

my $TimestampGet2 = $CalendarHelperObject->TimestampGet(
    SystemTime => '1451606460',
);

$Self->Is(
    $TimestampGet2,
    '2016-01-01 00:01:00',
    "TimestampGet - OK",
);

my $CurrentTimestampGet = $CalendarHelperObject->CurrentTimestampGet();
$Self->True(
    $CurrentTimestampGet =~ /\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}/,
    "CurrentTimestampGet - OK",
);

my $CurrentSystemTime = $CalendarHelperObject->CurrentSystemTime();
$Self->True(
    IsInteger($CurrentSystemTime) && $CurrentSystemTime > 1463081781,
    "CurrentSystemTime - OK",
);

my ( $Second1, $Minute1, $Hour1, $Day1, $Month1, $Year1, $DayOfWeek1 ) = $CalendarHelperObject->DateGet();
$Self->False(
    $Year1,
    "DateGet without SystemTime (Year)",
);
$Self->False(
    $Month1,
    "DateGet without SystemTime (Month)",
);
$Self->False(
    $Day1,
    "DateGet without SystemTime (Day)",
);
$Self->False(
    $Hour1,
    "DateGet without SystemTime (Hour)",
);
$Self->False(
    $Minute1,
    "DateGet without SystemTime (Minute)",
);
$Self->False(
    $Second1,
    "DateGet without SystemTime (Second)",
);
$Self->False(
    $DayOfWeek1,
    "DateGet without SystemTime (DayOfWeek)",
);

my ( $Second2, $Minute2, $Hour2, $Day2, $Month2, $Year2, $DayOfWeek2 ) = $CalendarHelperObject->DateGet(
    SystemTime => '1482501910',
);
$Self->Is(
    $Year2,
    2016,
    "DateGet OK (Year)",
);
$Self->Is(
    $Month2,
    12,
    "DateGet OK (Month)",
);
$Self->Is(
    $Day2,
    23,
    "DateGet OK (Day)",
);
$Self->Is(
    $Hour2,
    14,
    "DateGet OK (Hour)",
);
$Self->Is(
    $Minute2,
    5,
    "DateGet OK (Minute)",
);
$Self->Is(
    $Second2,
    10,
    "DateGet OK (Second)",
);
$Self->Is(
    $DayOfWeek2,
    5,
    "DateGet OK (DayOfWeek)",
);

my ( $Second3, $Minute3, $Hour3, $Day3, $Month3, $Year3, $DayOfWeek3 ) = $CalendarHelperObject->DateGet(
    SystemTime => '1462672984',
);
$Self->Is(
    $Year3,
    2016,
    "DateGet OK (Year)",
);
$Self->Is(
    $Month3,
    5,
    "DateGet OK (Month)",
);
$Self->Is(
    $Day3,
    8,
    "DateGet OK (Day)",
);
$Self->Is(
    $Hour3,
    2,
    "DateGet OK (Hour)",
);
$Self->Is(
    $Minute3,
    3,
    "DateGet OK (Minute)",
);
$Self->Is(
    $Second3,
    4,
    "DateGet OK (Second)",
);
$Self->Is(
    $DayOfWeek3,
    7,
    "DateGet OK (DayOfWeek)",
);

# 1462699805

# missing year
my $Date2SystemTime1 = $CalendarHelperObject->Date2SystemTime(
    Month  => '1',
    Day    => '1',
    Hour   => '1',
    Minute => '0',
);
$Self->False(
    $Date2SystemTime1,
    "Date2SystemTime missing Year",
);

# missing month
my $Date2SystemTime2 = $CalendarHelperObject->Date2SystemTime(
    Year   => '2016',
    Day    => '1',
    Hour   => '1',
    Minute => '0',
);
$Self->False(
    $Date2SystemTime2,
    "Date2SystemTime missing Month",
);

# missing day
my $Date2SystemTime3 = $CalendarHelperObject->Date2SystemTime(
    Year   => '2016',
    Month  => '1',
    Hour   => '1',
    Minute => '0',
);
$Self->False(
    $Date2SystemTime3,
    "Date2SystemTime missing Day",
);

# missing Minute
my $Date2SystemTime4 = $CalendarHelperObject->Date2SystemTime(
    Year   => '2016',
    Month  => '1',
    Day    => '1',
    Hour   => '1',
    Minute => '0',
);
$Self->Is(
    $Date2SystemTime4,
    1451610000,
    "Date2SystemTime OK",
);

# Missing Time
my $AddPeriod1 = $CalendarHelperObject->AddPeriod(
    Years  => '1',
    Months => '1',
);
$Self->False(
    $AddPeriod1,
    "AddPeriod missing Time",
);

my $AddPeriod2 = $CalendarHelperObject->AddPeriod(
    Time   => '1462871162',
    Years  => '1',
    Months => '1',
);
$Self->Is(
    $AddPeriod2,
    1497085562,
    "AddPeriod OK",
);

# missing parameters
my $Offset1 = $CalendarHelperObject->TimezoneOffsetGet(

    # UserID      => 2,                   # (optional)
    # or
    # TimezoneID  => 'Europe/Berlin'      # (optional) Timezone name
);
$Self->False(
    $Offset1,
    "TimezoneOffsetGet missing parameters",
);

my $Offset2 = $CalendarHelperObject->TimezoneOffsetGet(
    TimezoneID => 'Europe/Berlin',
);
$Self->Is(
    $Offset2,
    2,
    "TimezoneOffsetGet - TimezoneID provided",
);

# TODO: test TimezoneOffsetGet with UserID

# missing SystemTime
my ( $WeekDay1, $CW1 ) = $CalendarHelperObject->WeekDetailsGet(

    # SystemTime => '1462880778',
);
$Self->False(
    $WeekDay1,
    "WeekDetailsGet missing SystemTime - WeekDay",
);
$Self->False(
    $CW1,
    "WeekDetailsGet missing SystemTime - CW",
);

# ok
my ( $WeekDay2, $CW2 ) = $CalendarHelperObject->WeekDetailsGet(
    SystemTime => '1494738305',
);
$Self->Is(
    $WeekDay2,
    7,
    "WeekDetailsGet missing SystemTime - WeekDay",
);
$Self->Is(
    $CW2,
    19,
    "WeekDetailsGet missing SystemTime - CW",
);

1;
