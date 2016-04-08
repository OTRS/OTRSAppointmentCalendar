# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
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

            # get time object
            my $TimeObject = $Kernel::OM->Get('Kernel::System::Time');

            # get user timezone offset
            $Self->{UserTimeZone} = $Self->{UserTimeZone} ? int $Self->{UserTimeZone} : 0;

            # calculate local times
            for my $Appointment (@Appointments) {
                $Appointment->{TimezoneID} = $Appointment->{TimezoneID} ? int $Appointment->{TimezoneID} : 0;

                my $StartTime = $TimeObject->TimeStamp2SystemTime(
                    String => $Appointment->{StartTime},
                );
                $StartTime -= $Appointment->{TimezoneID} * 3600;
                $StartTime += $Self->{UserTimeZone} * 3600;
                $Appointment->{StartTime} = $TimeObject->SystemTime2TimeStamp(
                    SystemTime => $StartTime,
                );

                my $EndTime = $TimeObject->TimeStamp2SystemTime(
                    String => $Appointment->{EndTime},
                );
                $EndTime -= $Appointment->{TimezoneID} * 3600;
                $EndTime += $Self->{UserTimeZone} * 3600;
                $Appointment->{EndTime} = $TimeObject->SystemTime2TimeStamp(
                    SystemTime => $EndTime,
                );

                if ( $Appointment->{RecurrenceUntil} ) {
                    my $RecurrenceUntil = $TimeObject->TimeStamp2SystemTime(
                        String => $Appointment->{RecurrenceUntil},
                    );
                    $RecurrenceUntil -= $Appointment->{TimezoneID} * 3600;
                    $RecurrenceUntil += $Self->{UserTimeZone} * 3600;
                    $Appointment->{RecurrenceUntil} = $TimeObject->SystemTime2TimeStamp(
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

        for my $AppointmentID (@AppointmentIDs) {
            my $Seen = $AppointmentObject->AppointmentSeenGet(
                AppointmentID => $AppointmentID,
                UserID        => $Self->{UserID},
            );

            if ( !$Seen ) {
                my %Appointment = $AppointmentObject->AppointmentGet(
                    AppointmentID => $AppointmentID,
                );

                $LayoutObject->Block(
                    Name => 'Appointment',
                    Data => {
                        %Appointment,
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
