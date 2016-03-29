# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentAppointmentCalendarOverview;

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

        $LayoutObject->Block(
            Name => 'CalendarWidget',
        );

        my $CalendarColors = $ConfigObject->Get('AppointmentCalendar::CalendarColors') ||
            [ '#3A87AD', '#EC9073', '#6BAD54', '#78A7FC', '#DFC01B', '#43B261', '#53758D' ];

        my $CalendarColorID = 0;
        my $CurrentCalendar = 1;
        for my $Calendar (@Calendars) {

            # current calendar color (sequential)
            $Calendar->{CalendarColor} = $CalendarColors->[$CalendarColorID];

            # calendar checkbox in the widget
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
            $CalendarColorID = $CalendarColors->[ $CalendarColorID + 1 ] ? $CalendarColorID + 1 : 0;

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
        TemplateFile => 'AgentAppointmentCalendarOverview',
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
