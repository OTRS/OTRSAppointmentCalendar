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

# override local time zone for duration of the test
local $ENV{TZ} = 'UTC';

# get helper object
$Kernel::OM->ObjectParamAdd(
    'Kernel::System::UnitTest::Helper' => {
        RestoreDatabase => 1,
    },
);
my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');

# get calendar helper object
my $CalendarHelperObject = $Kernel::OM->Get('Kernel::System::Calendar::Helper');

#
# Tests for TimeCheck()
#
my @Tests = (
    {
        Name   => 'Missing Time',
        Config => {
            OriginalTime => '2016-01-01 00:01:00',
        },
        Success => 0,
    },
    {
        Name   => 'Missing OriginalTime',
        Config => {
            Time => '2016-02-01 00:02:00',
        },
        Success => 0,
    },
    {
        Name   => 'All params',
        Config => {
            OriginalTime => '2016-01-01 00:01:00',
            Time         => '2016-02-01 00:02:00',
        },
        Result  => '2016-02-01 00:01:00',
        Success => 1,
    },
);

for my $Test (@Tests) {
    my $Result = $CalendarHelperObject->TimeCheck(
        %{ $Test->{Config} },
    );

    if ( $Test->{Success} ) {
        $Self->Is(
            $Result,
            $Test->{Result},
            "TimeCheck - $Test->{Name} - Success",
        );
    }
    else {
        $Self->False(
            $Result,
            "TimeCheck - $Test->{Name} - No success ",
        );
    }
}

#
# Tests for SystemTimeGet()
#
@Tests = (
    {
        Name    => 'No params',
        Config  => {},
        Success => 0,
    },
    {
        Name   => 'All params',
        Config => {
            String => '2016-01-01 00:01:00',
        },
        Result  => '1451606460',
        Success => 1,
    },
);

for my $Test (@Tests) {
    my $Result = $CalendarHelperObject->SystemTimeGet(
        %{ $Test->{Config} },
    );

    if ( $Test->{Success} ) {
        $Self->Is(
            $Result,
            $Test->{Result},
            "SystemTimeGet - $Test->{Name} - Success",
        );
    }
    else {
        $Self->False(
            $Result,
            "SystemTimeGet - $Test->{Name} - No success ",
        );
    }
}

#
# Tests for TimestampGet()
#
@Tests = (
    {
        Name    => 'No params',
        Config  => {},
        Success => 0,
    },
    {
        Name   => 'All params',
        Config => {
            SystemTime => '1451606460',
        },
        Result  => '2016-01-01 00:01:00',
        Success => 1,
    },
);

for my $Test (@Tests) {
    my $Result = $CalendarHelperObject->TimestampGet(
        %{ $Test->{Config} },
    );

    if ( $Test->{Success} ) {
        $Self->Is(
            $Result,
            $Test->{Result},
            "TimestampGet - $Test->{Name} - Success",
        );
    }
    else {
        $Self->False(
            $Result,
            "TimestampGet - $Test->{Name} - No success ",
        );
    }
}

#
# Tests for CurrentTimestampGet() and CurrentSystemTime()
#
@Tests = (
    {
        Name    => 'No params',
        Config  => {},
        Success => 1,
    },
);

for my $Test (@Tests) {
    my $ResultTimestamp = $CalendarHelperObject->CurrentTimestampGet(
        %{ $Test->{Config} },
    );
    my $ResultSystemTime = $CalendarHelperObject->CurrentSystemTime(
        %{ $Test->{Config} },
    );

    if ( $Test->{Success} ) {
        $Self->True(
            $ResultTimestamp,
            "CurrentTimestampGet - $Test->{Name} - Success",
        );
        $Self->True(
            $ResultSystemTime,
            "CurrentSystemTime - $Test->{Name} - Success",
        );

        $Self->True(
            $ResultTimestamp =~ /\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}/,
            "CurrentTimestampGet - Expected format",
        );

        $Self->True(
            IsInteger($ResultSystemTime) && $ResultSystemTime > 1463081781,
            "CurrentSystemTime - Expected format",
        );
    }
    else {
        $Self->False(
            $ResultTimestamp,
            "CurrentTimestampGet - $Test->{Name} - No success ",
        );
        $Self->False(
            $ResultSystemTime,
            "CurrentSystemTime - $Test->{Name} - No success ",
        );
    }
}

#
# Tests for DateGet()
#
@Tests = (
    {
        Name    => 'No params',
        Config  => {},
        Success => 0,
    },
    {
        Name   => 'Friday, 2016-12-23 14:05:10',
        Config => {
            SystemTime => '1482501910',
        },
        Result => [
            10,
            5,
            14,
            23,
            12,
            2016,
            5,
        ],
        Success => 1,
    },
    {
        Name   => 'Sunday, 2016-05-08 02:03:04',
        Config => {
            SystemTime => '1462672984',
        },
        Result => [
            4,
            3,
            2,
            8,
            5,
            2016,
            7,
        ],
        Success => 1,
    },
);

for my $Test (@Tests) {
    my @Result = $CalendarHelperObject->DateGet(
        %{ $Test->{Config} },
    );

    if ( $Test->{Success} ) {
        $Self->IsDeeply(
            \@Result,
            $Test->{Result},
            "DateGet - $Test->{Name} - Result",
        );
    }
    else {
        $Self->False(
            scalar @Result,
            "DateGet - $Test->{Name} - No success ",
        );
    }
}

#
# Tests for Date2SystemTime()
#
@Tests = (
    {
        Name   => 'Mising Year',
        Config => {
            Month  => '1',
            Day    => '1',
            Hour   => '1',
            Minute => '0',
        },
        Success => 0,
    },
    {
        Name   => 'Mising Month',
        Config => {
            Year   => '2016',
            Day    => '1',
            Hour   => '1',
            Minute => '0',
        },
        Success => 0,
    },
    {
        Name   => 'Mising Day',
        Config => {
            Year   => '2016',
            Month  => '1',
            Hour   => '1',
            Minute => '0',
        },
        Success => 0,
    },
    {
        Name   => '2016-01-01 01:00:00',
        Config => {
            Year   => '2016',
            Month  => '1',
            Day    => '1',
            Hour   => '1',
            Minute => '0',
        },
        Result  => '1451610000',
        Success => 1,
    },
);

for my $Test (@Tests) {
    my $Result = $CalendarHelperObject->Date2SystemTime(
        %{ $Test->{Config} },
    );

    if ( $Test->{Success} ) {
        $Self->Is(
            $Result,
            $Test->{Result},
            "Date2SystemTime - $Test->{Name} - Result",
        );
    }
    else {
        $Self->False(
            $Result,
            "Date2SystemTime - $Test->{Name} - No success ",
        );
    }
}

#
# Tests for AddPeriod()
#
@Tests = (
    {
        Name   => 'Mising Time',
        Config => {
            Years  => '1',
            Months => '1',
        },
        Success => 0,
    },
    {
        Name   => 'All params',
        Config => {
            Time   => '1462871162',
            Years  => '1',
            Months => '1',
        },
        Result  => '1497085562',
        Success => 1,
    },
);

for my $Test (@Tests) {
    my $Result = $CalendarHelperObject->AddPeriod(
        %{ $Test->{Config} },
    );

    if ( $Test->{Success} ) {
        $Self->Is(
            $Result,
            $Test->{Result},
            "AddPeriod - $Test->{Name} - Result",
        );
    }
    else {
        $Self->False(
            $Result,
            "AddPeriod - $Test->{Name} - No success ",
        );
    }
}

#
# Tests for TimezoneOffsetGet()
#
@Tests = (
    {
        Name    => 'No params',
        Config  => {},
        Success => 0,
    },
    {
        Name   => 'TimezoneID',
        Config => {
            TimezoneID => 'Europe/Berlin',
        },
        Result  => 2,
        Success => 1,
    },
);

for my $Test (@Tests) {
    my $Result = $CalendarHelperObject->TimezoneOffsetGet(
        %{ $Test->{Config} },
    );

    if ( $Test->{Success} ) {
        $Self->Is(
            $Result,
            $Test->{Result},
            "TimezoneOffsetGet - $Test->{Name} - Result",
        );
    }
    else {
        $Self->False(
            $Result,
            "TimezoneOffsetGet - $Test->{Name} - No success ",
        );
    }
}

#
# Tests for WeekDetailsGet()
#
@Tests = (
    {
        Name    => 'No params',
        Config  => {},
        Success => 0,
    },
    {
        Name   => 'Sunday, 2017-05-14 05:05:05, CW19',
        Config => {
            SystemTime => '1494738305',
        },
        Result => [
            7,
            19,
        ],
        Success => 1,
    },
);

for my $Test (@Tests) {
    my @Result = $CalendarHelperObject->WeekDetailsGet(
        %{ $Test->{Config} },
    );

    if ( $Test->{Success} ) {
        $Self->IsDeeply(
            \@Result,
            $Test->{Result},
            "WeekDetailsGet - $Test->{Name} - Result",
        );
    }
    else {
        $Self->False(
            scalar @Result,
            "WeekDetailsGet - $Test->{Name} - No success ",
        );
    }
}

1;
