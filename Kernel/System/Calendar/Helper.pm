# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Calendar::Helper;

use strict;
use warnings;

use Digest::MD5;

use Kernel::System::VariableCheck qw(:all);
use Kernel::System::EventHandler;

our @ObjectDependencies = (
    'Kernel::System::Log',
    'Kernel::System::User',
);

=head1 NAME

Kernel::System::Calendar.Helper - helper methods (for compatibility between OTRS 5/OTRS 6)

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
    for (qw(OriginalTime Time)) {
        if ( !defined $Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
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
    for (qw( String )) {
        if ( !defined $Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    # extract data
    $Param{String} =~ /(\d{4})-(\d{2})-(\d{2})\s(\d{2}):(\d{2}):(\d{2})$/;

    my %Data = (
        Year   => $1,
        Month  => $2,
        Day    => $3,
        Hour   => $4,
        Minute => $5,
        Second => $6,
    );

    # Create an object with a specific date and time:
    my $DateTimeObject = $Kernel::OM->Create(
        'Kernel::System::DateTime',
        ObjectParams => {
            %Data,

            # TimeZone => 'Europe/Berlin',        # optional, defaults to setting of SysConfig OTRSTimeZone
            }
    );

    # check system time
    return $DateTimeObject->ToEpoch();
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
    for (qw( SystemTime )) {
        if ( !defined $Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    my $DateTimeObject = $Kernel::OM->Create(
        'Kernel::System::DateTime',
        ObjectParams => {
            Epoch => $Param{SystemTime},
            }
    );

    # get timestamp
    return $DateTimeObject->ToString();
}

=item CurrentTimestampGet()

returns a current time stamp for a given system time in "yyyy-mm-dd 23:59:59" format.

    my $Result = $CalendarHelperObject->CurrentTimestampGet();

returns:
    $Result = '2016-01-01 00:01:00';
=cut

sub CurrentTimestampGet {
    my ( $Self, %Param ) = @_;

    # Create an object with current date and time
    # within time zone set in SysConfig OTRSTimeZone:
    my $DateTimeObject = $Kernel::OM->Create(
        'Kernel::System::DateTime'
    );

    return $DateTimeObject->ToString();
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

    # Create an object with current date and time
    # within time zone set in SysConfig OTRSTimeZone:
    my $DateTimeObject = $Kernel::OM->Create(
        'Kernel::System::DateTime',
    );

    return $DateTimeObject->ToEpoch();
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
    $DayOfWeek = '2';   #  1-monday,...7-sunday

=cut

sub DateGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw( SystemTime )) {
        if ( !defined $Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    my $DateTimeObject = $Kernel::OM->Create(
        'Kernel::System::DateTime',
        ObjectParams => {
            Epoch => $Param{SystemTime},
            }
    );

    my $Date = $DateTimeObject->Get();

    my @Result = (
        $Date->{Second}, $Date->{Minute}, $Date->{Hour},
        $Date->{Day}, $Date->{Month}, $Date->{Year}, $Date->{DayOfWeek}
    );

    return @Result;
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
    for (qw( Year Month Day )) {
        if ( !defined $Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    $Param{Hour}   //= 0;
    $Param{Minute} //= 0;

    my $DateTimeObject = $Kernel::OM->Create(
        'Kernel::System::DateTime',
        ObjectParams => {
            %Param,
            }
    );

    return $DateTimeObject->ToEpoch();
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
    for (qw(Time)) {
        if ( !defined $Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    $Param{Months} //= 0;
    $Param{Years}  //= 0;

    my $DateTimeObject = $Kernel::OM->Create(
        'Kernel::System::DateTime',
        ObjectParams => {
            Epoch => $Param{Time},
            }
    );

    # remember start day
    my $StartDay = $DateTimeObject->Get()->{Day};

    $DateTimeObject->Add(
        Months => $Param{Months},
        Years  => $Param{Years},
    );

    # get end day
    my $EndDay = $DateTimeObject->Get()->{Day};

    # check if month doesn't have enough days (for example: january 31 + 1 month = march 01)
    if ( $StartDay != $EndDay ) {
        $DateTimeObject->Subtract(
            Days => $EndDay,
        );
    }

    return $DateTimeObject->ToEpoch();
}

=item TimezoneOffsetGet()

adds time period (years and months) to the time given in Unix format.

    my $Result = $CalendarHelperObject->TimezoneOffsetGet(
        UserID      => 2,                   # (optional)
                                            # or
        TimezoneID  => 'Europe/Berlin'      # (optional) Timezone name
    );

returns:
    $Result = 2;
=cut

sub TimezoneOffsetGet {
    my ( $Self, %Param ) = @_;

    if ( !$Param{UserID} && !$Param{TimezoneID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need UserID or TimezoneID!"
        );
        return;
    }

    my $TimezoneID = $Param{TimezoneID} || '';

    if ( $Param{UserID} ) {

        # get user data
        my %User = $Kernel::OM->Get('Kernel::System::User')->GetUserData(
            UserID => $Param{UserID},
        );

        $TimezoneID = $User{UserTimeZone} || '';
    }

    return 0 if !$TimezoneID;

    my $DateTimeObject = $Kernel::OM->Create(
        'Kernel::System::DateTime',
    );
    my $TimeZoneByOffset = $DateTimeObject->TimeZoneByOffsetList();
    my $Offset           = 0;

    OFFSET:
    for my $OffsetValue ( sort keys %{$TimeZoneByOffset} ) {
        if ( grep { $_ eq $TimezoneID } @{ $TimeZoneByOffset->{$OffsetValue} } ) {
            $Offset = $OffsetValue;
            last OFFSET;
        }
    }

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

    for (qw( SystemTime )) {
        if ( !defined $Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    my $DateTimeObject = $Kernel::OM->Create(
        'Kernel::System::DateTime',
        ObjectParams => {
            Epoch => $Param{SystemTime},
            }
    );

    my $WeekDay = $DateTimeObject->Get()->{DayOfWeek};
    my $CW      = $DateTimeObject->{CPANDateTimeObject}->week_number();

    return ( $WeekDay, $CW );
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not
