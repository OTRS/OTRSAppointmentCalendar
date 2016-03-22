# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentAppointmentEdit;

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
    PARAMNAME:
    for my $Key (@ParamNames) {

        # skip the Action parameter, it's giving BuildDateSelection problems for some reason
        next PARAMNAME if $Key eq 'Action';

        $GetParam{$Key} = $ParamObject->GetParam( Param => $Key );
    }

    # get needed objects
    my $ConfigObject      = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject      = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $CalendarObject    = $Kernel::OM->Get('Kernel::System::Calendar');
    my $AppointmentObject = $Kernel::OM->Get('Kernel::System::Calendar::Appointment');

    my $JSON = '';

    # check request
    if ( $Self->{Subaction} eq 'EditMask' ) {

        # get all user's valid calendars
        my $ValidID = $Kernel::OM->Get('Kernel::System::Valid')->ValidLookup(
            Valid => 'valid',
        );
        my @Calendars = $CalendarObject->CalendarList(
            UserID  => $Self->{UserID},
            ValidID => $ValidID,
        );

        # transform data for select box
        my @CalendarData = map {
            {
                Key   => $_->{CalendarID},
                Value => $_->{CalendarName},
            }
        } @Calendars;

        # define the current ID
        $Param{CalendarID} = $ParamObject->GetParam( Param => 'CalendarID' ) || $CalendarData[0]->{Key};

        # calendar selection
        $Param{CalendarIDStrg} = $LayoutObject->BuildSelection(
            Data         => \@CalendarData,
            SelectedID   => $GetParam{CalendarID} || $CalendarData[0]->{Key},
            Name         => 'CalendarID',
            Multiple     => 0,
            Class        => 'Modernize',
            PossibleNone => 0,
        );

        # start date string
        $Param{StartDateString} = $LayoutObject->BuildDateSelection(
            %GetParam,
            Prefix      => 'Start',
            StartHour   => $GetParam{StartHour} || 0,
            StartMinute => $GetParam{StartMinute} || 0,
            Format      => 'DateInputFormatLong',
            Validate    => 1,
        );

        # end date string
        $Param{EndDateString} = $LayoutObject->BuildDateSelection(
            %GetParam,
            Prefix    => 'End',
            EndHour   => $GetParam{EndHour} || 0,
            EndMinute => $GetParam{EndMinute} || 0,
            Format    => 'DateInputFormatLong',
            Validate  => 1,
        );

        # all day
        $Param{AllDayChecked} = $GetParam{AllDay} ? 'checked="checked"' : '';

        # html mask output
        $LayoutObject->Block(
            Name => 'EditMask',
            Data => {
                %Param,
                %GetParam,
            },
        );

        my $Output .= $LayoutObject->Output(
            TemplateFile => 'AgentAppointmentEdit',
            Data         => {
                %Param,
                %GetParam,
            },
        );
        return $LayoutObject->Attachment(
            NoCache     => 1,
            ContentType => 'text/html',
            Charset     => $LayoutObject->{UserCharset},
            Content     => $Output,
            Type        => 'inline',
        );
    }

    elsif (
        $Self->{Subaction} eq 'AddAppointment'
        || $Self->{Subaction} eq 'EditAppointment'
        )
    {
        if ( $GetParam{AllDay} ) {
            $GetParam{StartTime} = sprintf(
                "%04d-%02d-%02d 00:00:00",
                $GetParam{StartYear}, $GetParam{StartMonth}, $GetParam{StartDay}
            );
            $GetParam{EndTime} = sprintf(
                "%04d-%02d-%02d 00:00:00",
                $GetParam{EndYear}, $GetParam{EndMonth}, $GetParam{EndDay}
            );
        }
        else {
            $GetParam{StartTime} = sprintf(
                "%04d-%02d-%02d %02d:%02d:00",
                $GetParam{StartYear}, $GetParam{StartMonth}, $GetParam{StartDay},
                $GetParam{StartHour}, $GetParam{StartMinute}
            );
            $GetParam{EndTime} = sprintf(
                "%04d-%02d-%02d %02d:%02d:00",
                $GetParam{EndYear}, $GetParam{EndMonth}, $GetParam{EndDay},
                $GetParam{EndHour}, $GetParam{EndMinute}
            );
        }

        my $Success;

        $GetParam{TimezoneID} = 'Europe/Belgrade';
        $GetParam{UserID}     = $Self->{UserID};

        if ( $GetParam{AppointmentID} ) {
            $Success = $AppointmentObject->AppointmentUpdate(
                %GetParam,
            );
        }
        else {
            $Success = $AppointmentObject->AppointmentCreate(
                %GetParam,
            );
        }

        # build JSON output
        $JSON = $LayoutObject->JSONEncode(
            Data => {
                Success => $Success ? 1 : 0,
                CalendarID    => $GetParam{CalendarID},
                AppointmentID => $GetParam{AppointmentID} ? $GetParam{AppointmentID} : $Success,
            },
        );
    }

    elsif ( $Self->{Subaction} eq 'DeleteAppointment' ) {

        if ( $GetParam{CalendarID} && $GetParam{AppointmentID} ) {

            my $Success = $AppointmentObject->AppointmentDelete(
                %GetParam,
                UserID => $Self->{UserID},
            );

            # build JSON output
            $JSON = $LayoutObject->JSONEncode(
                Data => {
                    Success       => $Success,
                    CalendarID    => $GetParam{CalendarID},
                    AppointmentID => $GetParam{AppointmentID},
                },
            );
        }
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
