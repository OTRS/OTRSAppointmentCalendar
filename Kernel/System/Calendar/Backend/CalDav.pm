# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Calendar::Backend::CalDav;

use strict;
use warnings;

use Kernel::System::WebUserAgent;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Log',
);

=head1 NAME

Kernel::System::Calendar::Backend::CalDav - CalDav lib

=head1 SYNOPSIS

All CalDav functions.

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object. Do not use it directly, instead use:

    use Kernel::System::ObjectManager;
    local $Kernel::OM = Kernel::System::ObjectManager->new();
    my $CalDavObject = $Kernel::OM->Get('Kernel::System::Calendar::Backend::CalDav');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    $Self->{CacheType} = 'CalDav';
    $Self->{CacheTTL}  = 60 * 60 * 24 * 20;

    return $Self;
}

=item AppointmentList()

get a hash of Appointments.

    my @Appointments = $AppointmentObject->AppointmentList(
        Url        => 'https://domain.example.com/dav/user@example.com/CalendarName',  # (required) subscribed url
        Username   => 'user',                                                          # (required)
        Password   => '1234',                                                          # (required)
        StartTime  => '2016-01-01 00:00:00',                                           # (optional) Filter by start date
        EndTime    => '2016-02-01 00:00:00',                                           # (optional) Filter by end date
        Result     => 'HASH',                                                          # (optional), HASH|ARRAY
    );

returns an array of hashes with select Appointment data or simple array of AppointmentIDs:

Result => 'HASH':

    @Appointments = [
        {
            ID          => 1,
            CalendarID  => 1,
            UniqueID    => '20160101T160000-71E386@localhost',
            Title       => 'Webinar',
            StartTime   => '2016-01-01 16:00:00',
            EndTime     => '2016-01-01 17:00:00',
            AllDay      => 0,
            Recurring   => 1,                                           # for recurring (parent) appointments only
        },
        {
            ID          => 2,
            ParentID    => 1,                                           # for recurred (child) appointments only
            CalendarID  => 1,
            UniqueID    => '20160101T180000-A78B57@localhost',
            Title       => 'Webinar',
            StartTime   => '2016-01-02 16:00:00',
            EndTime     => '2016-01-02 17:00:00',
            AllDay      => 0,
        },
        ...
    ];

Result => 'ARRAY':

    @Appointments = [ 1, 2, ... ]

=cut

sub AppointmentList {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(Url Username Password)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    # output array of hashes by default
    $Param{Result} = $Param{Result} || 'HASH';

    # neede objects
    my $ConfigObject       = $Kernel::OM->Get('Kernel::Config');
    my $WebUserAgentObject = Kernel::System::WebUserAgent->new(
        Timeout => $ConfigObject->Get('WebUserAgent::Timeout') || '',
        Proxy   => $ConfigObject->Get('WebUserAgent::Proxy')   || '',
    );

    my %Response = $WebUserAgentObject->Request(
        URL                 => $Param{Url},
        SkipSSLVerification => 1,             # TODO: Check if OK
        Type                => 'GET',
        Credentials         => {
            User     => $Param{Username},
            Password => $Param{Password},
            Realm    => $Param{Realm},
            Location => $Param{Location},
        },
    );

    if ( $Response{Status} ne '200 OK' ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => $Response{Status},
        );

        return;
    }

    return if !$Response{Content};

    # use Data::Dumper;
    # my $Data2 = Dumper( \%Response );
    # open(my $fh, '>>', '/opt/otrs-test/data.txt') or die 'Could not open file ';
    # print $fh "\n==========================\n" . $Data2;
    # close $fh;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not
