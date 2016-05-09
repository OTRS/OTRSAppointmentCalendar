# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentAppointmentList;

## nofilter(TidyAll::Plugin::OTRS::Migrations::OTRS6::TimeZoneOffset)

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);
use Kernel::Language qw(Translatable);

our $ObjectManagerDisabled = 1;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $Output;

    # get param object
    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');

    # get names of all parameters
    my @ParamNames = $ParamObject->GetParamNames();

    # get params
    my %GetParam;

    KEY:
    for my $Key (@ParamNames) {
        next KEY if $Key eq 'AppointmentIDs';
        $GetParam{$Key} = $ParamObject->GetParam( Param => $Key );
    }

    # get needed objects
    my $ConfigObject      = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject      = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $CalendarObject    = $Kernel::OM->Get('Kernel::System::Calendar');
    my $AppointmentObject = $Kernel::OM->Get('Kernel::System::Calendar::Appointment');

    my $JSON = $LayoutObject->JSONEncode( Data => [] );

    $LayoutObject->ChallengeTokenCheck();

    # check request
    if ( $Self->{Subaction} eq 'ListAppointments' ) {

        if ( $GetParam{CalendarID} ) {

            # append midnight to the timestamps
            for my $Timestamp (qw(StartTime EndTime)) {
                if ( $GetParam{$Timestamp} && !( $GetParam{$Timestamp} =~ /\s\d{2}:\d{2}:\d{2}$/ ) ) {
                    $GetParam{$Timestamp} = $GetParam{$Timestamp} . ' 00:00:00',
                }
            }

            # reset empty parameters
            for my $Param ( sort keys %GetParam ) {
                if ( !$GetParam{$Param} ) {
                    $GetParam{$Param} = undef;
                }
            }

            my @Appointments = $AppointmentObject->AppointmentList(
                %GetParam,
            );

            # get user timezone offset
            $Self->{UserTimeZone} = $Self->_TimezoneOffsetGet();

            # calculate local times
            for my $Appointment (@Appointments) {
                $Appointment->{TimezoneID} = $Appointment->{TimezoneID} ? int $Appointment->{TimezoneID} : 0;

                my $StartTime = $Self->_SystemTimeGet(
                    String => $Appointment->{StartTime},
                );
                $StartTime -= $Appointment->{TimezoneID} * 3600;
                $StartTime += $Self->{UserTimeZone} * 3600;
                $Appointment->{StartTime} = $Self->_TimestampGet(
                    SystemTime => $StartTime,
                );

                my $EndTime = $Self->_SystemTimeGet(
                    String => $Appointment->{EndTime},
                );
                $EndTime -= $Appointment->{TimezoneID} * 3600;
                $EndTime += $Self->{UserTimeZone} * 3600;
                $Appointment->{EndTime} = $Self->_TimestampGet(
                    SystemTime => $EndTime,
                );

                if ( $Appointment->{RecurrenceUntil} ) {
                    my $RecurrenceUntil = $Self->_SystemTimeGet(
                        String => $Appointment->{RecurrenceUntil},
                    );
                    $RecurrenceUntil -= $Appointment->{TimezoneID} * 3600;
                    $RecurrenceUntil += $Self->{UserTimeZone} * 3600;
                    $Appointment->{RecurrenceUntil} = $Self->_TimestampGet(
                        SystemTime => $RecurrenceUntil,
                    );
                }
            }

            # build JSON output
            $JSON = $LayoutObject->JSONEncode(
                Data => (
                    \@Appointments,
                ),
            );
        }
    }

    elsif ( $Self->{Subaction} eq 'AppointmentDays' ) {

        # append midnight to the timestamps
        for my $Timestamp (qw(StartTime EndTime)) {
            if ( $GetParam{$Timestamp} && !( $GetParam{$Timestamp} =~ /\s\d{2}:\d{2}:\d{2}$/ ) ) {
                $GetParam{$Timestamp} = $GetParam{$Timestamp} . ' 00:00:00',
            }
        }

        # reset empty parameters
        for my $Param ( sort keys %GetParam ) {
            if ( !$GetParam{$Param} ) {
                $GetParam{$Param} = undef;
            }
        }

        my %AppointmentDays = $AppointmentObject->AppointmentDays(
            %GetParam,
            UserID => $Self->{UserID},
        );

        # build JSON output
        $JSON = $LayoutObject->JSONEncode(
            Data => (
                \%AppointmentDays,
            ),
        );
    }
    elsif ( $Self->{Subaction} eq 'AppointmentsStarted' ) {
        my $Show = 0;

        my @AppointmentIDs = $ParamObject->GetArray( Param => 'AppointmentIDs[]' );

        # check if team object is registered
        my $ShowResources
            = $Kernel::OM->Get('Kernel::System::Main')->Require( 'Kernel::System::Calendar::Team', Silent => 1 );

        for my $AppointmentID (@AppointmentIDs) {
            my $Seen = $AppointmentObject->AppointmentSeenGet(
                AppointmentID => $AppointmentID,
                UserID        => $Self->{UserID},
            );

            if ( !$Seen ) {
                my %Appointment = $AppointmentObject->AppointmentGet(
                    AppointmentID => $AppointmentID,
                );

                my @Resources = ();
                if ($ShowResources) {
                    for my $UserID ( @{ $Appointment{ResourceID} } ) {
                        my %User = $Kernel::OM->Get('Kernel::System::User')->GetUserData(
                            UserID => $UserID,
                        );
                        push @Resources, $User{UserFullname};
                    }
                }

                $LayoutObject->Block(
                    Name => 'Appointment',
                    Data => {
                        %Appointment,
                        ShowResources => $ShowResources,
                        Resource      => join( ', ', @Resources ),
                    },
                );

                # system displays reminder this time, mark it as shown
                $AppointmentObject->AppointmentSeenSet(
                    AppointmentID => $AppointmentID,
                    UserID        => $Self->{UserID},
                );

                $Show = 1;
            }
        }

        my $HTML = $LayoutObject->Output(
            TemplateFile => 'AgentAppointmentCalendarOverviewSeen',
            Data         => {
                ShowResources => $ShowResources,
            },
        );

        $JSON = $LayoutObject->JSONEncode(
            Data => {
                HTML  => $HTML,
                Show  => $Show,
                Title => $LayoutObject->{LanguageObject}->Translate("Ongoing appointments"),
            },
        );
    }

    # send JSON response
    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $JSON,
        Type        => 'inline',
        NoCache     => 1,
    );

    return;
}

sub _SystemTimeGet {
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

sub _TimestampGet {
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

sub _TimezoneOffsetGet {
    my ( $Self, %Param ) = @_;

    # get user data
    my %User = $Kernel::OM->Get('Kernel::System::User')->GetUserData(
        UserID => $Self->{UserID},
    );

    my $DateTimeObject = $Kernel::OM->Create(
        'Kernel::System::DateTime',
    );

    my $TimeZoneByOffset = $DateTimeObject->TimeZoneByOffsetList();
    my $Offset           = 0;

    OFFSET:
    for my $OffsetValue ( sort keys %{$TimeZoneByOffset} ) {
        if ( grep { $_ eq $User{UserTimeZone} } @{ $TimeZoneByOffset->{$OffsetValue} } ) {
            $Offset = $OffsetValue;
            last OFFSET;
        }
    }

    return $Offset;
}

1;
