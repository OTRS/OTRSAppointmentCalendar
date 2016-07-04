# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

## nofilter(TidyAll::Plugin::OTRS::Migrations::OTRS6::TimeZoneOffset)

package Kernel::Modules::AgentAppointmentList;

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
    my $PluginObject      = $Kernel::OM->Get('Kernel::System::Calendar::Plugin');

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
            $Self->{UserTimeZone} = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->TimezoneOffsetGet(
                UserID => $Self->{UserID},
            );

            # go through all appointments
            for my $Appointment (@Appointments) {

                # check for notification date
                if (
                    !$Appointment->{NotificationDate}
                    || $Appointment->{NotificationDate} eq '0000-00-00 00:00:00'
                    )
                {
                    $Appointment->{NotificationDate} = '';
                }

                # calculate local times
                if ( !$Appointment->{AllDay} ) {
                    $Appointment->{TimezoneID} = $Appointment->{TimezoneID} ? $Appointment->{TimezoneID} : 0;

                    my $StartTime = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->SystemTimeGet(
                        String => $Appointment->{StartTime},
                    );
                    $StartTime -= $Appointment->{TimezoneID} * 3600;
                    $StartTime += $Self->{UserTimeZone} * 3600;
                    $Appointment->{StartTime} = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->TimestampGet(
                        SystemTime => $StartTime,
                    );

                    my $EndTime = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->SystemTimeGet(
                        String => $Appointment->{EndTime},
                    );
                    $EndTime -= $Appointment->{TimezoneID} * 3600;
                    $EndTime += $Self->{UserTimeZone} * 3600;
                    $Appointment->{EndTime} = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->TimestampGet(
                        SystemTime => $EndTime,
                    );

                    if ( $Appointment->{RecurrenceUntil} ) {
                        my $RecurrenceUntil = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->SystemTimeGet(
                            String => $Appointment->{RecurrenceUntil},
                        );
                        $RecurrenceUntil -= $Appointment->{TimezoneID} * 3600;
                        $RecurrenceUntil += $Self->{UserTimeZone} * 3600;
                        $Appointment->{RecurrenceUntil}
                            = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->TimestampGet(
                            SystemTime => $RecurrenceUntil,
                            );
                    }
                }

                # include resource data
                $Appointment->{TeamName}      = '';
                $Appointment->{ResourceNames} = '';

                if (
                    $Kernel::OM->Get('Kernel::System::Main')->Require(
                        'Kernel::System::Calendar::Team',
                        Silent => 1,
                    )
                    )
                {
                    if ( $Appointment->{TeamID} ) {
                        my $TeamObject = $Kernel::OM->Get('Kernel::System::Calendar::Team');
                        my @TeamNames;
                        TEAM:
                        for my $TeamID ( @{ $Appointment->{TeamID} } ) {
                            next TEAM if !$TeamID;
                            my %Team = $TeamObject->TeamGet(
                                TeamID => $TeamID,
                                UserID => $Self->{UserID},
                            );
                            push @TeamNames, $Team{Name} if %Team;
                        }

                        # truncate more than three elements
                        my $TeamCount = scalar @TeamNames;
                        if ( $TeamCount > 4 ) {
                            splice @TeamNames, 3;
                            push @TeamNames, sprintf( Translatable('+%d more'), $TeamCount - 3 );
                        }

                        $Appointment->{TeamNames} = join( '\n', @TeamNames );
                    }
                    if ( $Appointment->{ResourceID} ) {
                        my $UserObject = $Kernel::OM->Get('Kernel::System::User');
                        my @ResourceNames;
                        RESOURCE:
                        for my $ResourceID ( @{ $Appointment->{ResourceID} } ) {
                            next RESOURCE if !$ResourceID;
                            my %User = $UserObject->GetUserData(
                                UserID => $ResourceID,
                            );
                            push @ResourceNames, $User{UserFullname};
                        }

                        # truncate more than three elements
                        my $ResourceCount = scalar @ResourceNames;
                        if ( $ResourceCount > 4 ) {
                            splice @ResourceNames, 3;
                            push @ResourceNames, sprintf( Translatable('+%d more'), $ResourceCount - 3 );
                        }

                        $Appointment->{ResourceNames} = join( '\n', @ResourceNames );
                    }
                }

                # include plugin (link) data
                my $PluginList = $PluginObject->PluginList();
                for my $PluginKey ( sort keys %{$PluginList} ) {
                    my $LinkList = $PluginObject->PluginLinkList(
                        AppointmentID => $Appointment->{AppointmentID},
                        PluginKey     => $PluginKey,
                        UserID        => $Self->{UserID},
                    );
                    my @LinkArray;
                    for my $LinkID ( sort keys %{$LinkList} ) {
                        push @LinkArray, $LinkList->{$LinkID}->{LinkName};
                    }

                    # truncate more than three elements
                    my $LinkCount = scalar @LinkArray;
                    if ( $LinkCount > 4 ) {
                        splice @LinkArray, 3;
                        push @LinkArray, sprintf( Translatable('+%d more'), $LinkCount - 3 );
                    }

                    $Appointment->{PluginData}->{$PluginKey} = join( '\n', @LinkArray );
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
                        if ($UserID) {
                            my %User = $Kernel::OM->Get('Kernel::System::User')->GetUserData(
                                UserID => $UserID,
                            );
                            push @Resources, $User{UserFullname};
                        }
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

1;
