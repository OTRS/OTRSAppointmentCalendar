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

    # get all user's calendars
    my @Calendars = $CalendarObject->CalendarList(
        UserID => $Self->{UserID},
    );

    # check if we found some
    if (@Calendars) {

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
            SelectedID   => $Param{CalendarID},
            Name         => 'CalendarID',
            Multiple     => 0,
            Class        => 'Modernize',
            PossibleNone => 0,
        );

        $LayoutObject->Block(
            Name => 'CalendarDiv',
            Data => {
                %Param,
                CalendarWidth => 100,
            },
        );
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
            EditAction    => 'AgentAppointmentEdit',
            EditSubaction => 'EditMask',
            FirstDay      => $Kernel::OM->Get('Kernel::Config')->Get('CalendarWeekDayStart') || 0,
            IsRTLLanguage => ( $TextDirection eq 'rtl' ) ? 'true' : 'false',
            %Param,
        },
    );
    $Output .= $LayoutObject->Footer();
    return $Output;
}

1;
