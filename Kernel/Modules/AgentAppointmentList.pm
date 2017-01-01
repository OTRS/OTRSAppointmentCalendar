# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

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

    # get time zone offset
    $Self->{TimeZone} = $Self->{UserTimeZone} || 0;
    $Self->{TimeSecDiff} = $Self->{TimeZone} * 3600;    # 60 * 60

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

    my $ConfigObject         = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject         = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $CalendarObject       = $Kernel::OM->Get('Kernel::System::Calendar');
    my $CalendarHelperObject = $Kernel::OM->Get('Kernel::System::Calendar::Helper');
    my $AppointmentObject    = $Kernel::OM->Get('Kernel::System::Calendar::Appointment');
    my $PluginObject         = $Kernel::OM->Get('Kernel::System::Calendar::Plugin');

    my $JSON = $LayoutObject->JSONEncode( Data => [] );

    $LayoutObject->ChallengeTokenCheck();

    # check request
    if ( $Self->{Subaction} eq 'ListAppointments' ) {

        if ( $GetParam{CalendarID} ) {

            # append midnight to the timestamps
            for my $Timestamp (qw(StartTime EndTime)) {
                if ( $GetParam{$Timestamp} && !( $GetParam{$Timestamp} =~ /\s\d{2}:\d{2}:\d{2}$/ ) ) {
                    $GetParam{$Timestamp} = $GetParam{$Timestamp} . ' 00:00:00';
                }
            }

            my $StartTime = $CalendarHelperObject->SystemTimeGet(
                String => $GetParam{StartTime},
            );
            my $EndTime = $CalendarHelperObject->SystemTimeGet(
                String => $GetParam{EndTime},
            );

            # convert to local time
            $StartTime -= $Self->{TimeSecDiff};
            $EndTime   -= $Self->{TimeSecDiff};

            $GetParam{StartTime} = $CalendarHelperObject->TimestampGet(
                SystemTime => $StartTime,
            );
            $GetParam{EndTime} = $CalendarHelperObject->TimestampGet(
                SystemTime => $EndTime,
            );

            # reset empty parameters
            for my $Param ( sort keys %GetParam ) {
                if ( !$GetParam{$Param} ) {
                    $GetParam{$Param} = undef;
                }
            }

            my @Appointments = $AppointmentObject->AppointmentList(
                %GetParam,
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

                # get system times
                my $StartTime = $CalendarHelperObject->SystemTimeGet(
                    String => $Appointment->{StartTime},
                );
                my $EndTime = $CalendarHelperObject->SystemTimeGet(
                    String => $Appointment->{EndTime},
                );

                # save time stamps for display before calculation
                $Appointment->{StartDate} = $Appointment->{StartTime};
                $Appointment->{EndDate}   = $Appointment->{EndTime};

                # end times for all day appointments are inclusive, subtract whole day
                if ( $Appointment->{AllDay} ) {
                    $EndTime -= 86400;
                    if ( $EndTime < $StartTime ) {
                        $EndTime = $StartTime;
                    }
                    $Appointment->{EndDate} = $CalendarHelperObject->TimestampGet(
                        SystemTime => $EndTime,
                    );
                }

                # calculate local times for control
                else {
                    $StartTime += $Self->{TimeSecDiff};
                    $Appointment->{StartTime} = $CalendarHelperObject->TimestampGet(
                        SystemTime => $StartTime,
                    );

                    $EndTime += $Self->{TimeSecDiff};
                    $Appointment->{EndTime} = $CalendarHelperObject->TimestampGet(
                        SystemTime => $EndTime,
                    );
                }

                # formatted date/time strings used in display
                $Appointment->{StartDate} = $LayoutObject->{LanguageObject}->FormatTimeString(
                    $Appointment->{StartDate},
                    'DateFormat' . ( $Appointment->{AllDay} ? 'Short' : '' )
                );
                $Appointment->{EndDate} = $LayoutObject->{LanguageObject}->FormatTimeString(
                    $Appointment->{EndDate},
                    'DateFormat' . ( $Appointment->{AllDay} ? 'Short' : '' )
                );
                if ( $Appointment->{NotificationDate} ) {
                    $Appointment->{NotificationDate} = $LayoutObject->{LanguageObject}->FormatTimeString(
                        $Appointment->{NotificationDate},
                        'DateFormat'
                    );
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
                        TEAMID:
                        for my $TeamID ( @{ $Appointment->{TeamID} } ) {
                            next TEAMID if !$TeamID;
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
                        RESOURCEID:
                        for my $ResourceID ( @{ $Appointment->{ResourceID} } ) {
                            next RESOURCEID if !$ResourceID;
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

                # check if dealing with ticket appointment
                if ( $Appointment->{TicketAppointmentRuleID} ) {
                    my $Rule = $CalendarObject->TicketAppointmentRuleGet(
                        CalendarID => $Appointment->{CalendarID},
                        RuleID     => $Appointment->{TicketAppointmentRuleID},
                    );

                    # get types from the ticket appointment rule
                    if ( IsHashRefWithData($Rule) ) {
                        $Appointment->{TicketAppointmentStartDate} = $Rule->{StartDate};
                        $Appointment->{TicketAppointmentEndDate}   = $Rule->{EndDate};
                    }
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
                $GetParam{$Timestamp} = $GetParam{$Timestamp} . ' 00:00:00';
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

    # send JSON response
    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $JSON,
        Type        => 'inline',
        NoCache     => 1,
    );
}

1;
