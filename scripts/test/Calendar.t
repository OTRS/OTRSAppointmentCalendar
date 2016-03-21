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

# This will be ok
my %Calendar1 = $CalendarObject->CalendarCreate(
    CalendarName => 'Test calendar',
    UserID       => 1,
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
    UserID       => 1,
);

$Self->False(
    $Calendar2{CalendarID},
    'CalendarCreate( CalendarName => "Test calendar", UserID => 1 ) again same name',
);

# Try without calendar name
my %Calendar3 = $CalendarObject->CalendarCreate(

    # CalendarName    => 'Meetings',
    UserID => 1,
);

$Self->False(
    $Calendar3{CalendarID},
    'CalendarCreate( UserID => 1 ) without name',
);

# Try without UserID
my %Calendar4 = $CalendarObject->CalendarCreate(
    CalendarName => 'Meetings',

    # UserID          => 1,
);

$Self->False(
    $Calendar4{CalendarID},
    'CalendarCreate( CalendarName => "Meetings" ) without UserID',
);

1;
