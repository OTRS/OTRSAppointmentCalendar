# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

## nofilter(TidyAll::Plugin::OTRS::Perl::Time)

package Kernel::System::Calendar::Helper;

use strict;
use warnings;

use Digest::MD5;
use Time::Piece;

use Kernel::System::VariableCheck qw(:all);
use Kernel::System::EventHandler;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Main',
    'Kernel::System::Log',
    'Kernel::System::Time',
    'Kernel::System::User',

);

=head1 NAME

Kernel::System::Calendar::Helper - calendar helper methods

=head1 SYNOPSIS

All helper functions.

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object. Do not use it directly, instead use:

    use Kernel::System::ObjectManager;
    local $Kernel::OM = Kernel::System::ObjectManager->new();
    my $CalendarHelperObject = $Kernel::OM->Get('Kernel::System::Calendar::Helper');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

=item TimeCheck()

check if Time and OriginalTime have same hour, minute and second value, and return timestamp with values (hour, minute and second) as in Time.

    my $Result = $CalendarHelperObject->TimeCheck(
        OriginalTime     => '2016-01-01 00:01:00',                   # (required)
        Time             => '2016-02-01 00:02:00',                   # (required)
    );

returns:
    $Result = '2016-02-01 00:01:00';
=cut

sub TimeCheck {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(OriginalTime Time)) {
        if ( !defined $Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    my $Result = '';

    $Param{OriginalTime} =~ /(.*?)\s(.*?)$/;
    my $OriginalDate = $1;
    my $OriginalTime = $2;

    $Param{Time} =~ /(.*?)\s(.*?)$/;
    my $Date = $1;

    $Result = "$Date $OriginalTime";
    return $Result;
}

=item SystemTimeGet()

returns the number of non-leap seconds since what ever time the system considers to be the epoch
(that's 00:00:00, January 1, 1904 for Mac OS, and 00:00:00 UTC, January 1, 1970 for most other systems).

    my $Result = $CalendarHelperObject->SystemTimeGet(
        String     => '2016-01-01 00:01:00',                   # (required)
    );

returns:
    $Result = '1451606460';
=cut

sub SystemTimeGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw( String )) {
        if ( !defined $Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    # get system time
    my $SystemTime = $Kernel::OM->Get('Kernel::System::Time')->TimeStamp2SystemTime(
        String => $Param{String},
    );

    return $SystemTime;
}

=item TimestampGet()

returns a time stamp for a given system time in "yyyy-mm-dd 23:59:59" format.

    my $Result = $CalendarHelperObject->TimestampGet(
        SystemTime     => '1451606460',                   # (required)
    );

returns:
    $Result = '2016-01-01 00:01:00';
=cut

sub TimestampGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw( SystemTime )) {
        if ( !defined $Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    # get timestamp
    my $Timestamp = $Kernel::OM->Get('Kernel::System::Time')->SystemTime2TimeStamp(
        SystemTime => $Param{SystemTime},
    );

    return $Timestamp;
}

=item CurrentTimestampGet()

returns a current time stamp for a given system time in "yyyy-mm-dd 23:59:59" format.

    my $Result = $CalendarHelperObject->CurrentTimestampGet();

returns:
    $Result = '2016-01-01 00:01:00';
=cut

sub CurrentTimestampGet {
    my ( $Self, %Param ) = @_;

    # get current timestamp
    my $CurrentTimestamp = $Kernel::OM->Get('Kernel::System::Time')->CurrentTimestamp();

    return $CurrentTimestamp;
}

=item CurrentSystemTime()

returns the number of non-leap seconds since what ever time the system considers to be the epoch untill now.
(that's 00:00:00, January 1, 1904 for Mac OS, and 00:00:00 UTC, January 1, 1970 for most other systems).

    my $Result = $CalendarHelperObject->CurrentSystemTime();

returns:
    $Result = '1462871162';
=cut

sub CurrentSystemTime {
    my ( $Self, %Param ) = @_;

    # get current system time
    my $CurrentSystemTime = $Kernel::OM->Get('Kernel::System::Time')->SystemTime();

    return $CurrentSystemTime;
}

=item DateGet()

returns date/time information in a hash for given unix time.

    my ($Second, $Minute, $Hour, $Day, $Month, $Year, $DayOfWeek) = $CalendarHelperObject->DateGet(
        SystemTime => '1462871162',
    );

returns:
    $Second    = '0';
    $Minute    = '0';
    $Hour      = '1';
    $Day       = '1';
    $Month     = '1';
    $Year      = '2016';
    $DayOfWeek = '2';   # 1-monday,..., 7-sunday

=cut

sub DateGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw( SystemTime )) {
        if ( !defined $Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    my ( $Second, $Minute, $Hour, $Day, $Month, $Year, $DayOfWeek ) =
        $Kernel::OM->Get('Kernel::System::Time')->SystemTime2Date(
        SystemTime => $Param{SystemTime},
        );
    $Second    = int $Second;
    $Minute    = int $Minute;
    $Hour      = int $Hour;
    $Day       = int $Day;
    $Month     = int $Month;
    $Year      = int $Year;
    $DayOfWeek = int $DayOfWeek;

    # Kernel::System::Time object returns 0 for Sunday - we need to change this to 7 (like on other places)
    if ( !$DayOfWeek ) {
        $DayOfWeek = 7;
    }

    return ( $Second, $Minute, $Hour, $Day, $Month, $Year, $DayOfWeek );
}

=item Date2SystemTime()

returns the number of non-leap seconds since what ever time the system considers to be the epoch for given parameters.
(that's 00:00:00, January 1, 1904 for Mac OS, and 00:00:00 UTC, January 1, 1970 for most other systems).

    my $Result = $CalendarHelperObject->Date2SystemTime(
        Year      => '2016',
        Month     => '1',
        Day       => '1',
        Hour      => '1',
        Minute    => '0',
    );

returns:
    $Result = '1451610000';
=cut

sub Date2SystemTime {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw( Year Month Day )) {
        if ( !defined $Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }
    $Param{Hour}   //= 0;
    $Param{Minute} //= 0;
    $Param{Second} //= 0;

    # get system time
    my $SystemTime = $Kernel::OM->Get('Kernel::System::Time')->Date2SystemTime(
        %Param,
    );

    return $SystemTime;
}

=item AddPeriod()

adds time period (years and months) to the time given in Unix format.

    my $Result = $CalendarHelperObject->AddPeriod(
        Time       => '1462871162',     # (required) time in Unix format
        Years      => '1',              # (optional) years to add
        Months     => '1',              # (optional) months to add
    );

returns:
    $Result = '1497085562';
=cut

sub AddPeriod {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(Time)) {
        if ( !defined $Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    $Param{Months} //= 0;
    $Param{Years}  //= 0;

    my $TimePiece = localtime( $Param{Time} );
    my $StartDay  = $TimePiece->day_of_month();

    my $NextTimePiece = $TimePiece->add_months( $Param{Months} );
    $NextTimePiece = $NextTimePiece->add_years( $Param{Years} );
    my $EndDay = $NextTimePiece->day_of_month();

    # check if month doesn't have enough days (for example: January 31 + 1 month = March 01)
    if ( $StartDay != $EndDay ) {

        # Subtract needed days
        my $Days = $NextTimePiece->day_of_month();
        $NextTimePiece -= $Days * 24 * 60 * 60;
    }

    return $NextTimePiece->epoch();
}

=item TimezoneOffsetGet()

returns offset of specified time zone or user's time zone.

    my $Result = $CalendarHelperObject->TimezoneOffsetGet(
        UserID      => 2,                   # (optional)
                                            # or
        TimezoneID  => 'Europe/Berlin'      # (optional) Timezone name
        Time        => '1462871162',        # (optional) Time in Unix format you want offset for
                                            #            otherwise, current time will be used
    );

returns:
    $Result = 2;

=cut

sub TimezoneOffsetGet {
    my ( $Self, %Param ) = @_;

    if ( !$Param{UserID} && !$Param{TimezoneID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need UserID or TimezoneID!",
        );
        return;
    }

    if ( $Param{UserID} ) {
        my %User = $Kernel::OM->Get('Kernel::System::User')->GetUserData(
            UserID => $Param{UserID},
        );

        return $User{UserTimeZone} ? int $User{UserTimeZone} : 0;
    }

    my $MainObject = $Kernel::OM->Get('Kernel::System::Main');

    # check if DateTime object exists
    return 0 if !$MainObject->Require(
        'DateTime',
    );

    # check if DateTime::TimeZone object exists
    return 0 if !$MainObject->Require(
        'DateTime::TimeZone',
    );

    # Offset calculation depends on specific time, because of daylight savings.
    #   If not supplied, use current time.
    my $DateTime = DateTime->now();
    if ( $Param{Time} ) {
        $DateTime = DateTime->from_epoch( epoch => $Param{Time} );
    }

    # DateTime::TimeZone might not recognize timezone by its name and die,
    #   make the call in an eval block.
    my $Timezone = eval { DateTime::TimeZone->new( name => $Param{TimezoneID} ) };

    if ($Timezone) {
        return $Timezone->offset_for_datetime($DateTime) / 3600.00;    # in hours
    }

    $Kernel::OM->Get('Kernel::System::Log')->Log(
        Priority => 'error',
        Message  => "Could not find offset for '$Param{TimezoneID}', assuming UTC!",
    );

    return 0;
}

=item LocalTimezoneOffsetGet()

returns offset of local time zone for a specified UTC system time.

    my $Result = $CalendarHelperObject->LocalTimezoneOffsetGet(
        Time => '1462871162',     # (required) time in Unix format
    );

returns:
    $Result = 2;

=cut

sub LocalTimezoneOffsetGet {
    my ( $Self, %Param ) = @_;

    if ( !$Param{Time} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need Time!',
        );
        return;
    }

    my $Time   = localtime( $Param{Time} );
    my $Offset = $Time->tzoffset() / 3600.00;    # in hours

    return $Offset;
}

=item WeekDetailsGet()

get week details for a given unix time.

    my ($WeekDay, $CW) = $CalendarHelperObject->WeekDetailsGet(
        SystemTime => '1462880778',
    );

returns:
    $WeekDay = 4; # 7-sun, 1-mon
    $CW = 19;
=cut

sub WeekDetailsGet {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw( SystemTime )) {
        if ( !defined $Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    # create Time::Piece object
    my $Time = localtime( $Param{SystemTime} );

    # Time::Piece object returns 0 for Sunday - we need to change this to 7 (like on other places)
    my $DayOfWeek = $Time->day_of_week();
    if ( !$DayOfWeek ) {
        $DayOfWeek = 7;
    }

    return ( $DayOfWeek, $Time->week() );
}

=item CWDiff()

returns how many calendar weeks has been passed between two unix times.

    my $CWDiff = $CalendarHelperObject->CWDiff(
        SystemTime   => '1462880778',
        OriginalTime => '1462980778',
    );

returns:
    $CWDiff = 5;
=cut

sub CWDiff {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw( SystemTime OriginalTime )) {
        if ( !defined $Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    my $StartTime = localtime( $Param{OriginalTime} );
    my $EndTime   = localtime( $Param{SystemTime} );

    my $StartYear = $StartTime->year();
    my $EndYear   = $EndTime->year();

    my $Result = $EndTime->week() - $StartTime->week();
    if ( $Result < 0 && $EndTime->mday() == 31 && $EndTime->mon() == 12 ) {

        # If date is end of the year and date CW starts with 1, we need to include additional year.
        $EndYear++;
    }

    for my $Year ( $StartYear .. $EndYear - 1 ) {

        my $CW  = 0;
        my $Day = 31;

        while ( $CW < 50 ) {

            # To get how many CW's are in this year, we set temporary date to 31-dec.
            my $Timestamp  = "$Year-12-$Day 23:59:00";
            my $SystemTime = $Self->SystemTimeGet(
                String => $Timestamp,
            );

            my $Time = localtime($SystemTime);

            $CW = $Time->week();
            $Day--;
        }

        $Result += $CW;

    }

    return $Result;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
