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
    'Kernel::System::Main',
    'Kernel::System::Log',
    'Kernel::System::Time',
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
    $Result = '1462871162';
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

    # check system time
    return $Kernel::OM->Get('Kernel::System::Time')->TimeStamp2SystemTime(
        String => $Param{String},
    );
}

=item TimestampGet()

returns a time stamp for a given system time in "yyyy-mm-dd 23:59:59" format.

    my $Result = $CalendarHelperObject->TimestampGet(
        SystemTime     => '1462871162',                   # (required)
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

    # get timestamp
    return $Kernel::OM->Get('Kernel::System::Time')->SystemTime2TimeStamp(
        SystemTime => $Param{SystemTime},
    );
}

=item CurrentTimestampGet()

returns a current time stamp for a given system time in "yyyy-mm-dd 23:59:59" format.

    my $Result = $CalendarHelperObject->CurrentTimestampGet(
        SystemTime     => '1462871162',                   # (required)
    );

returns:
    $Result = '2016-01-01 00:01:00';
=cut

sub CurrentTimestampGet {
    my ( $Self, %Param ) = @_;

    return $Kernel::OM->Get('Kernel::System::Time')->CurrentTimestamp();
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

    return $Kernel::OM->Get('Kernel::System::Time')->SystemTime();
}

=item DateGet()

returns date/time information in a hash for given unix time.

    my $Result = $CalendarHelperObject->DateGet(
        SystemTime => '1462871162'
    );

returns:
    $Result = (
        Year      => '2016',
        Month     => '1',
        Day       => '1',
        Hour      => '1',
        Minute    => '0',
        Second    => '0',
        DayOfWeek => '2',   # 0-sunday, 1-monday,...
    );
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

    return $Kernel::OM->Get('Kernel::System::Time')->SystemTime2Date(
        SystemTime => $Param{SystemTime},
    );
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
    $Result = '1462871162';
=cut

sub Date2SystemTime {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw( Year Month Day Hour Minute )) {
        if ( !defined $Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    return $Kernel::OM->Get('Kernel::System::Time')->Date2SystemTime(
        %Param,
    );
}

=item AddPeriod()

adds time period (years and months) to the time given in Unix format.

    my $Result = $CalendarHelperObject->AddPeriod(
        Time       => '1462871162',     # (required) time in Unix format
        Years      => '1',              # (optional) years to add
        Months     => '1',              # (optional) months to add
    );

returns:
    $Result = '1462880778';
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

    my $TimePiece = localtime( $Param{Time} );
    my $StartDay  = $TimePiece->day_of_month();

    my $NextTimePiece = $TimePiece->add_months( $Param{Months} );
    $NextTimePiece = $NextTimePiece->add_years( $Param{Years} );
    my $EndDay = $NextTimePiece->day_of_month();

    # check if month doesn't have enough days (for example: january 31 + 1 month = march 01)
    if ( $StartDay != $EndDay ) {

        # Substract needed days
        my $Days = $NextTimePiece->day_of_month();
        $NextTimePiece -= $Days * 24 * 60 * 60;
    }

    return $NextTimePiece->epoch();
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

    if ( $Param{UserID} ) {
        my %User = $Kernel::OM->Get('Kernel::System::User')->GetUserData(
            UserID => $Param{UserID},
        );

        return $User{UserTimeZone} ? int $User{UserTimeZone} : 0;
    }

    my $MainObject = $Kernel::OM->Get('Kernel::System::Main');

    # check if DateTime object exists
    return if !$MainObject->Require(
        'DateTime',
    );

    # check if DateTime::TimeZone object exists
    return if !$MainObject->Require(
        'DateTime::TimeZone',
    );

    my $DateTime = DateTime->now();

    my $Timezone = DateTime::TimeZone->new( name => $Param{TimezoneID} );
    my $Offset = $Timezone->offset_for_datetime($DateTime) / 3600.00;    # in hours

    return $Offset;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not
