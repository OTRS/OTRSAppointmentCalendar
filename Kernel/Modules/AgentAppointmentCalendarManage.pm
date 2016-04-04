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

        my $ValidSelection = $Self->_ValidSelectionGet();

        $LayoutObject->Block(
            Name => 'CalendarEdit',
            Data => {
                ValidID   => $ValidSelection,
                Subaction => 'StoreNew',
            },
        );
        $Param{Title} = $LayoutObject->{LanguageObject}->Translate("Add new Calendar");
    }
    elsif ( $Self->{Subaction} eq 'StoreNew' ) {

        # Get data
        $GetParam{CalendarName} = $ParamObject->GetParam( Param => 'CalendarName' ) || '';
        $GetParam{ValidID}      = $ParamObject->GetParam( Param => 'ValidID' )      || '';

        my %Error;

        # Check name
        if ( !$GetParam{CalendarName} ) {
            $Error{'CalendarNameInvalid'} = 'ServerError';
        }
        else {
            # Check if user has already calendar with same name
            my %Calendar = $CalendarObject->CalendarGet(
                CalendarName => $GetParam{CalendarName},
                UserID       => $Self->{UserID},
            );

            if (%Calendar) {
                $Error{CalendarNameInvalid} = "ServerError";
                $Error{CalendarNameExists}  = 1;
            }
        }

        if (%Error) {

            # Set title
            $Param{Title} = $LayoutObject->{LanguageObject}->Translate("Add new Calendar");

            # Get valid selection
            my $ValidSelection = $Self->_ValidSelectionGet(%GetParam);

            $LayoutObject->Block(
                Name => 'CalendarEdit',
                Data => {
                    %Error,
                    %GetParam,
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

        # Redirect
        return $LayoutObject->Redirect(
            OP => "Action=AgentAppointmentCalendarManage",
        );
    }
    elsif ( $Self->{Subaction} eq 'Edit' ) {

        # Get data
        my %GetParam;
        $GetParam{CalendarID} = $ParamObject->GetParam( Param => 'CalendarID' ) || '';

        if ( !$GetParam{CalendarID} ) {
            return $LayoutObject->ErrorScreen(
                Message => Translatable('No CalendarID!'),
                Comment => Translatable('Please contact the admin.'),
            );
        }

        # TODO: Check permissions (who can edit??)

        # get calendar data
        my %Calendar = $CalendarObject->CalendarGet(
            CalendarID => $GetParam{CalendarID},
        );

        if ( !%Calendar ) {

            # fake message
            return $LayoutObject->ErrorScreen(
                Message => Translatable('You have no access to this calendar!'),
                Comment => Translatable('Please contact the admin.'),
            );
        }

        # get user data
        my %User = $Kernel::OM->Get('Kernel::System::User')->GetUserData(
            UserID => $Calendar{UserID},
        );

        # Get valid selection
        my $ValidSelection = $Self->_ValidSelectionGet(%Calendar);

        $LayoutObject->Block(
            Name => 'CalendarEdit',
            Data => {
                %Calendar,
                ValidID   => $ValidSelection,
                Subaction => 'Update',
            },
        );

        # set title
        $Param{Title} = $LayoutObject->{LanguageObject}->Translate("Edit Calendar");
    }
    elsif ( $Self->{Subaction} eq 'Update' ) {

        # Get data
        $GetParam{CalendarID}   = $ParamObject->GetParam( Param => 'CalendarID' )   || '';
        $GetParam{CalendarName} = $ParamObject->GetParam( Param => 'CalendarName' ) || '';
        $GetParam{ValidID}      = $ParamObject->GetParam( Param => 'ValidID' )      || '';

        my %Error;

        # check needed stuff
        for my $Needed (qw(CalendarID CalendarName )) {
            if ( !$GetParam{$Needed} ) {
                $Error{ $Needed . 'Invalid' } = 'ServerError';
                $Param{Title} = $LayoutObject->{LanguageObject}->Translate("Edit Calendar");

                return $Self->_Mask( %Param, %GetParam, %Error );
            }
        }

        # Check if user has already calendar with same name
        my %Calendar = $CalendarObject->CalendarGet(
            CalendarName => $GetParam{CalendarName},
            UserID       => $Self->{UserID},
        );

        if ( defined $Calendar{CalendarID} && $Calendar{CalendarID} != $GetParam{CalendarID} ) {
            $Error{CalendarNameInvalid} = "ServerError";
            $Error{CalendarNameExists}  = 1;
        }

        if (%Error) {

            # Set title
            $Param{Title} = $LayoutObject->{LanguageObject}->Translate("Edit Calendar");

            # Get valid selection
            my $ValidSelection = $Self->_ValidSelectionGet(%GetParam);

            $LayoutObject->Block(
                Name => 'CalendarEdit',
                Data => {
                    %Error,
                    %GetParam,
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
                Message => Translatable('System was unable to update Calendar!'),
                Comment => Translatable('Please contact the admin.'),
            );
        }

        # Redirect
        return $LayoutObject->Redirect(
            OP => "Action=AgentAppointmentCalendarManage",
        );

    }
    else {

        # get all user's calendars
        my @Calendars = $CalendarObject->CalendarList(
            UserID => $Self->{UserID},
        );

        $LayoutObject->Block(
            Name => 'AddLink',
        );

        $LayoutObject->Block(
            Name => 'CalendarFilter',
        );

        $LayoutObject->Block(
            Name => 'Overview',
        );

        for my $Calendar (@Calendars) {

            # valid text
            $Calendar->{Valid} = $Kernel::OM->Get('Kernel::System::Valid')->ValidLookup(
                ValidID => $Calendar->{ValidID},
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
        Class => 'Modernize',

        SelectedID => $Param{ValidID} || 1,
        Title => Translatable("Valid"),
    );

    return $ValidSelection;
}

1;
