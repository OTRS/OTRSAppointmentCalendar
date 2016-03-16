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
my $Calendar1 = $CalendarObject->CalendarCreate(
    Name   => 'Test calendar',
    UserID => 1,
);

$Self->True(
    \$Calendar1,
    'CalendarCreate("Test calendar", 1)',
);

# Try with same name
my $Calendar2 = $CalendarObject->CalendarCreate(
    Name   => 'Test calendar',
    UserID => 1,
);

$Self->Is(
    $Calendar2,
    undef,
    'CalendarCreate("Test calendar", 1) again same name',
);

1;
