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

    # get needed objects
    my $LayoutObject   = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $CalendarObject = $Kernel::OM->Get('Kernel::System::Calendar');
    my $ParamObject    = $Kernel::OM->Get('Kernel::System::Web::Request');

    my %GetParam;

    if ( $Self->{Subaction} eq 'New' ) {

        my $GroupSelection = $Self->_GroupSelectionGet();
        my $ValidSelection = $Self->_ValidSelectionGet();

        $LayoutObject->Block(
            Name => 'CalendarEdit',
            Data => {
                GroupID   => $GroupSelection,
                ValidID   => $ValidSelection,
                Subaction => 'StoreNew',
            },
        );
        $Param{Title} = $LayoutObject->{LanguageObject}->Translate("Add new Calendar");
    }
    elsif ( $Self->{Subaction} eq 'StoreNew' ) {

        # get data
        for my $Param (qw(CalendarName GroupID ValidID)) {
            $GetParam{$Param} = $ParamObject->GetParam( Param => $Param ) || '';
        }

        my %Error;

        # check name
        if ( !$GetParam{CalendarName} ) {
            $Error{'CalendarNameInvalid'} = 'ServerError';
        }
        else {

            # check if there is a calendar with same name
            my %Calendar = $CalendarObject->CalendarGet(
                CalendarName => $GetParam{CalendarName},
            );

            if (%Calendar) {
                $Error{CalendarNameInvalid} = "ServerError";
                $Error{CalendarNameExists}  = 1;
            }
        }

        if (%Error) {

            # eet title
            $Param{Title} = $LayoutObject->{LanguageObject}->Translate("Add new Calendar");

            # get selections
            my $GroupSelection = $Self->_GroupSelectionGet(%GetParam);
            my $ValidSelection = $Self->_ValidSelectionGet(%GetParam);

            $LayoutObject->Block(
                Name => 'CalendarEdit',
                Data => {
                    %Error,
                    %GetParam,
                    GroupID   => $GroupSelection,
                    ValidID   => $ValidSelection,
                    Subaction => 'StoreNew',
                },
            );
            return $Self->_Mask(%Param);
        }

        # create calendar
        my %Calendar = $CalendarObject->CalendarCreate(
            %GetParam,
            UserID => $Self->{UserID},
        );

        if ( !%Calendar ) {
            return $LayoutObject->ErrorScreen(
                Message => Translatable('System was unable to create Calendar!'),
                Comment => Translatable('Please contact the admin.'),
            );
        }

        # redirect
        return $LayoutObject->Redirect(
            OP => "Action=AgentAppointmentCalendarManage",
        );
    }
    elsif ( $Self->{Subaction} eq 'Edit' ) {

        # get data
        my %GetParam;
        $GetParam{CalendarID} = $ParamObject->GetParam( Param => 'CalendarID' ) || '';

        if ( !$GetParam{CalendarID} ) {
            return $LayoutObject->ErrorScreen(
                Message => Translatable('No CalendarID!'),
                Comment => Translatable('Please contact the admin.'),
            );
        }

        # get calendar data
        my %Calendar = $CalendarObject->CalendarGet(
            CalendarID => $GetParam{CalendarID},
            UserID     => $Self->{UserID},
        );

        if ( !%Calendar ) {

            # fake message
            return $LayoutObject->ErrorScreen(
                Message => Translatable('You have no access to this calendar!'),
                Comment => Translatable('Please contact the admin.'),
            );
        }

        # get selections
        my $GroupSelection = $Self->_GroupSelectionGet(%Calendar);
        my $ValidSelection = $Self->_ValidSelectionGet(%Calendar);

        $LayoutObject->Block(
            Name => 'CalendarEdit',
            Data => {
                %Calendar,
                GroupID   => $GroupSelection,
                ValidID   => $ValidSelection,
                Subaction => 'Update',
            },
        );

        # set title
        $Param{Title} = $LayoutObject->{LanguageObject}->Translate("Edit Calendar");
    }
    elsif ( $Self->{Subaction} eq 'Update' ) {

        # get data
        for my $Param (qw(CalendarID CalendarName GroupID ValidID)) {
            $GetParam{$Param} = $ParamObject->GetParam( Param => $Param ) || '';
        }

        my %Error;

        # check needed stuff
        for my $Needed (qw(CalendarID CalendarName GroupID)) {
            if ( !$GetParam{$Needed} ) {
                $Error{ $Needed . 'Invalid' } = 'ServerError';
                $Param{Title} = $LayoutObject->{LanguageObject}->Translate("Edit Calendar");

                return $Self->_Mask( %Param, %GetParam, %Error );
            }
        }

        # check if there is already a calendar with same name
        my %Calendar = $CalendarObject->CalendarGet(
            CalendarName => $GetParam{CalendarName},
            UserID       => $Self->{UserID},
        );

        if ( defined $Calendar{CalendarID} && $Calendar{CalendarID} != $GetParam{CalendarID} ) {
            $Error{CalendarNameInvalid} = "ServerError";
            $Error{CalendarNameExists}  = 1;
        }

        if (%Error) {

            # set title
            $Param{Title} = $LayoutObject->{LanguageObject}->Translate("Edit Calendar");

            # get selections
            my $GroupSelection = $Self->_GroupSelectionGet(%GetParam);
            my $ValidSelection = $Self->_ValidSelectionGet(%GetParam);

            $LayoutObject->Block(
                Name => 'CalendarEdit',
                Data => {
                    %Error,
                    %GetParam,
                    GroupID   => $GroupSelection,
                    ValidID   => $ValidSelection,
                    Subaction => 'Update',
                },
            );
            return $Self->_Mask(%Param);
        }

        # update calendar
        my $Success = $CalendarObject->CalendarUpdate(
            %GetParam,
            UserID => $Self->{UserID},
        );

        if ( !$Success ) {
            return $LayoutObject->ErrorScreen(
                Message => Translatable('Error updating the calendar!'),
                Comment => Translatable('Please contact the admin.'),
            );
        }

        # Redirect
        return $LayoutObject->Redirect(
            OP => "Action=AgentAppointmentCalendarManage",
        );

    }
    else {

        # get all calendars user has RW access to
        my @Calendars = $CalendarObject->CalendarList(
            UserID     => $Self->{UserID},
            Permission => 'rw',
        );

        $LayoutObject->Block(
            Name => 'MainActions',
        );

        $LayoutObject->Block(
            Name => 'CalendarFilter',
        );

        $LayoutObject->Block(
            Name => 'Overview',
        );

        for my $Calendar (@Calendars) {

            # group name
            $Calendar->{Group} = $Kernel::OM->Get('Kernel::System::Group')->GroupLookup(
                GroupID => $Calendar->{GroupID},
            );

            # valid text
            $Calendar->{Valid} = $Kernel::OM->Get('Kernel::System::Valid')->ValidLookup(
                ValidID => $Calendar->{ValidID},
            );

            # get access tokens
            $Calendar->{AccessToken} = $CalendarObject->GetAccessToken(
                CalendarID => $Calendar->{CalendarID},
                UserLogin  => $Self->{UserLogin},
            );

            $LayoutObject->Block(
                Name => 'Calendar',
                Data => {
                    %{$Calendar},
                },
            );
        }

        $LayoutObject->Block(
            Name => 'CalendarNoDataRow',
        ) if scalar @Calendars == 0;

        $Param{Title}    = $LayoutObject->{LanguageObject}->Translate("Calendars");
        $Param{Overview} = 1;
    }

    return $Self->_Mask(%Param);
}

sub _Mask {
    my ( $Self, %Param ) = @_;

    # get needed objects
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # output page
    my $Output = $LayoutObject->Header();
    $Output .= $LayoutObject->NavigationBar();
    $Output .= $LayoutObject->Output(
        TemplateFile => 'AgentAppointmentCalendarManage',
        Data         => {
            %Param,
        },
    );
    $Output .= $LayoutObject->Footer();
    return $Output;
}

sub _GroupSelectionGet {
    my ( $Self, %Param ) = @_;

    # get needed objects
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # get list of groups where user has RW permissions
    my %GroupList = $Kernel::OM->Get('Kernel::System::Group')->PermissionUserGet(
        UserID => $Self->{UserID},
        Type   => 'rw',
    );

    my $GroupSelection = $LayoutObject->BuildSelection(
        Data       => \%GroupList,
        Name       => 'GroupID',
        SelectedID => $Param{GroupID} || '',
        Class      => 'Modernize Validate_Required',
    );

    return $GroupSelection;
}

sub _ValidSelectionGet {
    my ( $Self, %Param ) = @_;

    # get needed objects
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ValidObject  = $Kernel::OM->Get('Kernel::System::Valid');

    my %Valid          = $ValidObject->ValidList();
    my $ValidSelection = $LayoutObject->BuildSelection(
        Data  => \%Valid,
        Name  => 'ValidID',
        ID    => 'ValidID',
        Class => 'Modernize Validate_Required',

        SelectedID => $Param{ValidID} || 1,
        Title => Translatable("Valid"),
    );

    return $ValidSelection;
}

1;
