# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentAppointmentCalendarManage;

use strict;
use warnings;

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

    my $Title;

    if ( $Self->{Subaction} eq 'New' ) {
        $LayoutObject->Block(
            Name => 'CalendarEdit',
            Data => {
            },
        );
        $Title = $LayoutObject->{LanguageObject}->Translate("Add new Calendar");
    }
    else {

        # get all user's calendars
        my @Calendars = $CalendarObject->CalendarList(
            UserID => $Self->{UserID},
        );

        $LayoutObject->Block(
            Name => 'AddLink',
            Data => {
            },
        );
        $LayoutObject->Block(
            Name => 'ExportLink',
            Data => {
            },
        );

        $LayoutObject->Block(
            Name => 'Overview',
            Data => {
            },
        );

        for my $Calendar (@Calendars) {
            $LayoutObject->Block(
                Name => 'Calendar',
                Data => {
                    %{$Calendar},
                },
            );
        }

        $Title = $LayoutObject->{LanguageObject}->Translate("Calendars");
    }

    # output page
    my $Output = $LayoutObject->Header();
    $Output .= $LayoutObject->NavigationBar();
    $Output .= $LayoutObject->Output(
        TemplateFile => 'AgentAppointmentCalendarManage',
        Data         => {
            Title => $Title,
        },
    );
    $Output .= $LayoutObject->Footer();
    return $Output;
}

1;
