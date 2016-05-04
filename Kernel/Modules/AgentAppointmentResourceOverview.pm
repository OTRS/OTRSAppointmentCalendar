# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentAppointmentResourceOverview;

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

    # get names of all parameters
    my @ParamNames = $ParamObject->GetParamNames();

    # get params
    my %GetParam;
    PARAMNAME:
    for my $Key (@ParamNames) {
        $GetParam{$Key} = $ParamObject->GetParam( Param => $Key );
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

        # get team object
        my $TeamObject = $Kernel::OM->Get('Kernel::System::Calendar::Team');

        my %TeamList = $TeamObject->TeamList(
            Valid => 1,
        );

        if ( scalar keys %TeamList > 0 ) {

            my @TeamIDs = sort keys %TeamList;
            $Param{TeamID} = $GetParam{TeamID} // $TeamIDs[0];

            $Param{TeamStrg} = $LayoutObject->BuildSelection(
                Data         => \%TeamList,
                Name         => 'TeamID',
                ID           => 'TeamID',
                Class        => 'Modernize',
                SelectedID   => $Param{TeamID},
                PossibleNone => 0,
            );

            $LayoutObject->Block(
                Name => 'TeamList',
                Data => {
                    %Param,
                },
            );

            my %TeamUserList = $TeamObject->TeamUserList(
                TeamID => $Param{TeamID},
                UserID => $Self->{UserID},
            );

            if ( scalar keys %TeamUserList > 0 ) {

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

                # resource JSON
                $LayoutObject->Block(
                    Name => 'ResourceJSON',
                    Data => {
                        TeamID => $GetParam{TeamID},
                        %Param,
                    },
                );

                # get user preferences
                my %Preferences = $Kernel::OM->Get('Kernel::System::User')->GetPreferences(
                    UserID => $Self->{UserID},
                );

                # set initial view
                $Param{DefaultView} = $Preferences{UserResourceOverviewDefaultView} // 'timelineWeek';
            }

            # show empty team message
            else {
                $LayoutObject->Block(
                    Name => 'EmptyTeam',
                );
            }
        }

        # show no team found message
        else {
            $LayoutObject->Block(
                Name => 'NoTeam',
            );
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
        TemplateFile => 'AgentAppointmentResourceOverview',
        Data         => {
            EditAction        => 'AgentAppointmentEdit',
            EditMaskSubaction => 'EditMask',
            EditSubaction     => 'EditAppointment',
            AddSubaction      => 'AddAppointment',
            ListAction        => 'AgentAppointmentList',
            DaysSubaction     => 'AppointmentDays',
            FirstDay          => $Kernel::OM->Get('Kernel::Config')->Get('CalendarWeekDayStart') || 0,
            IsRTLLanguage     => ( $TextDirection eq 'rtl' ) ? 'true' : 'false',
            %Param,
        },
    );
    $Output .= $LayoutObject->Footer();
    return $Output;
}

1;
