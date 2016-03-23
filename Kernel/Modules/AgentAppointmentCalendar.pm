# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentAppointmentCalendar;

use strict;
use warnings;

use Kernel::Language qw(Translatable);
use Kernel::System::VariableCheck qw(:all);

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

    # get needed objects
    my $ConfigObject   = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject   = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $CalendarObject = $Kernel::OM->Get('Kernel::System::Calendar');
    my $JSONObject     = $Kernel::OM->Get('Kernel::System::JSON');
    my $ParamObject    = $Kernel::OM->Get('Kernel::System::Web::Request');

    if ( $Self->{Subaction} eq 'CalendarAdd' ) {
        my $CalendarName = $ParamObject->GetParam( Param => 'CalendarName' ) || '';

        my %Error;
        my %Calendar = ();

        if ( !$CalendarName ) {
            $Error{ServerError} = "MissingCalendarName";
        }
        else {
            %Calendar = $CalendarObject->CalendarCreate(
                Name   => $CalendarName,
                UserID => $Self->{UserID},
            );
        }

        if ( !%Calendar ) {
            $Error{ServerError} = "AlreadyExists";
        }

        my $JSONResponse = $JSONObject->Encode(
            Data => {
                CalendarID => $Calendar{CalendarID},
                Error      => \%Error,
            },
        );

        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
            Content     => $JSONResponse,
            Type        => 'inline',
            NoCache     => 1,
        );
    }

    # get all user's valid calendars
    my $ValidID = $Kernel::OM->Get('Kernel::System::Valid')->ValidLookup(
        Valid => 'valid',
    );
    my @Calendars = $CalendarObject->CalendarList(
        UserID  => $Self->{UserID},
        ValidID => $ValidID,
    );

    # check if we found some
    if (@Calendars) {

        $LayoutObject->Block(
            Name => 'CalendarDiv',
            Data => {
                %Param,
                CalendarWidth => 100,
            },
        );

        my @CalendarColors = (
            '#3A87AD', '#EC9073', '#6BAD54', '#78A7FC', '#DFC01B', '#43B261', '#53758D', '#C1AE45',
            '#3EBB34', '#956669', '#34A0FB', '#AB766A', '#A68477', '#B54667', '#3B62C0', '#876CDC',
            '#1A5F2D', '#ED603F', '#3BB3AA', '#B6716A', '#E5845B', '#497FC2', '#222047', '#388B85',
            '#811A26', '#206057', '#557FDB', '#792DA8', '#954958', '#74575C', '#AC5CAF', '#4B693B',
            '#5D7BA1', '#BF1B1C', '#C87D39', '#AEAB86', '#DA9998', '#AAB717', '#8496E6', '#1A3B4C',
            '#3F7E68', '#5564DE', '#0C847C', '#85DE9B', '#D0AD74', '#0E3C7E', '#A8AE41', '#C3AA40',
            '#A5782F', '#E33C5B', '#59BF4F', '#B553D8', '#2CB590', '#01045E', '#CA78AC', '#8AA596',
            '#54BB79', '#3A5E0E', '#234D8D', '#3D2F8A', '#9B4F95', '#E96E9C', '#11231A', '#DA529F',
            '#789D72', '#AB9906', '#205F33', '#444685', '#05067A', '#6E2FC9', '#AA5F55', '#558BCA',
            '#56034C', '#A896DD', '#9C7CD0', '#B8B170', '#7D6F92', '#9E8A2D', '#7D6134', '#74625E',
            '#C64507', '#274987', '#C53379', '#1A6E42', '#308859', '#AD60CB', '#30BB80', '#5886C9',
        );

        my $CalendarColorID = 0;
        my $CurrentCalendar = 1;
        for my $Calendar (@Calendars) {

            # current calendar color (sequential)
            $Calendar->{CalendarColor} = $CalendarColors[$CalendarColorID];

            # calendar checkbox switch on top
            $LayoutObject->Block(
                Name => 'CalendarSwitch',
                Data => {
                    %{$Calendar},
                    %Param,
                },
            );

            # calendar source (JSON)
            $LayoutObject->Block(
                Name => 'CalendarSource',
                Data => {
                    %{$Calendar},
                    %Param,
                },
            );
            $LayoutObject->Block(
                Name => 'CalendarSourceComma',
            ) if $CurrentCalendar < scalar @Calendars;

            # restart using the color array if needed
            $CalendarColorID = $CalendarColors[ $CalendarColorID + 1 ] ? $CalendarColorID + 1 : 0;

            $CurrentCalendar++;
        }
    }

    # show no calendar found message
    else {
        $LayoutObject->Block(
            Name => 'NoCalendar',
        );
    }

    # get text direction from language object
    my $TextDirection = $LayoutObject->{LanguageObject}->{TextDirection} || '';

    # output page
    my $Output = $LayoutObject->Header();
    $Output .= $LayoutObject->NavigationBar();
    $Output .= $LayoutObject->Output(
        TemplateFile => 'AgentAppointmentCalendar',
        Data         => {
            EditAction        => 'AgentAppointmentEdit',
            EditMaskSubaction => 'EditMask',
            EditSubaction     => 'EditAppointment',
            AddSubaction      => 'AddAppointment',
            FirstDay          => $Kernel::OM->Get('Kernel::Config')->Get('CalendarWeekDayStart') || 0,
            IsRTLLanguage     => ( $TextDirection eq 'rtl' ) ? 'true' : 'false',
            %Param,
        },
    );
    $Output .= $LayoutObject->Footer();
    return $Output;
}

1;
