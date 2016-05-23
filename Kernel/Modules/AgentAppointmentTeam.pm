# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentAppointmentTeam;

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

    # get local objects
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $TeamObject   = $Kernel::OM->Get('Kernel::System::Calendar::Team');

    # ------------------------------------------------------------ #
    # change screen
    # ------------------------------------------------------------ #
    if ( $Self->{Subaction} eq 'Change' ) {

        my %GetParam = ();

        $GetParam{TeamID} = $ParamObject->GetParam( Param => 'TeamID' ) || '';

        my %TeamData = $TeamObject->TeamGet(
            TeamID => $GetParam{TeamID},
            UserID => $Self->{UserID},
        );

        my $Output = $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();
        $Self->_Edit(
            Action => 'Change',
            %TeamData,
            %GetParam,
        );

        $Output .= $LayoutObject->Output(
            TemplateFile => 'AgentAppointmentTeam',
            Data         => \%Param,
        );

        $Output .= $LayoutObject->Footer();

        return $Output;
    }

    # ------------------------------------------------------------ #
    # change action
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'ChangeAction' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        my ( %GetParam, %Errors );

        # get params
        for my $Parameter (qw(TeamID Name GroupID Comment ValidID)) {
            $GetParam{$Parameter} = $ParamObject->GetParam( Param => $Parameter ) || '';
        }

        # check needed data
        for my $Needed (qw(Name GroupID ValidID)) {
            if ( !$GetParam{$Needed} ) {
                $Errors{ $Needed . 'Invalid' } = 'ServerError';
            }
        }

        # check if there is a team with same name
        my %Team = $TeamObject->TeamGet(
            Name   => $GetParam{Name},
            UserID => $Self->{UserID},
        );
        if ( %Team && $Team{ID} != $GetParam{TeamID} ) {
            $Errors{NameInvalid} = "ServerError";
            $Errors{NameExists}  = 1;
        }

        # if no errors occurred
        if ( !%Errors ) {

            # update Team
            my $Update = $TeamObject->TeamUpdate(
                %GetParam,
                UserID => $Self->{UserID}
            );

            if ($Update) {
                $Self->_Overview();
                my $Output = $LayoutObject->Header();
                $Output .= $LayoutObject->NavigationBar();
                $Output .= $LayoutObject->Notify( Info => 'Team updated!' );
                $Output .= $LayoutObject->Output(
                    TemplateFile => 'AgentAppointmentTeam',
                    Data         => \%Param,
                );
                $Output .= $LayoutObject->Footer();
                return $Output;
            }
        }

        # something has gone wrong
        my $Output = $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();
        $Output .= $LayoutObject->Notify( Team => 'Error' );
        $Self->_Edit(
            Action => 'Change',
            Errors => \%Errors,
            %GetParam,
        );
        $Output .= $LayoutObject->Output(
            TemplateFile => 'AgentAppointmentTeam',
            Data         => \%Param,
        );
        $Output .= $LayoutObject->Footer();
        return $Output;
    }

    # ------------------------------------------------------------ #
    # add screen
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'Add' ) {
        my %GetParam = ();
        $GetParam{TeamID} = $ParamObject->GetParam( Param => 'TeamID' ) || '';
        my $Output = $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();
        $Self->_Edit(
            Action => 'Add',
            %GetParam,
        );
        $Output .= $LayoutObject->Output(
            TemplateFile => 'AgentAppointmentTeam',
            Data         => \%Param,
        );
        $Output .= $LayoutObject->Footer();
        return $Output;
    }

    # ------------------------------------------------------------ #
    # add action
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'AddAction' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        my ( %GetParam, %Errors );

        # get params
        for my $Parameter (qw(TeamID Name GroupID Comment ValidID)) {
            $GetParam{$Parameter} = $ParamObject->GetParam( Param => $Parameter ) || '';
        }

        # check needed data
        for my $Needed (qw(Name GroupID ValidID)) {
            if ( !$GetParam{$Needed} ) {
                $Errors{ $Needed . 'Invalid' } = 'ServerError';
            }
        }

        # check if there is a team with same name
        my %Team = $TeamObject->TeamGet(
            Name   => $GetParam{Name},
            UserID => $Self->{UserID},
        );
        if (%Team) {
            $Errors{NameInvalid} = "ServerError";
            $Errors{NameExists}  = 1;
        }

        # if no errors occurred
        if ( !%Errors ) {

            my $NewTeam = $TeamObject->TeamAdd(
                %GetParam,
                UserID => $Self->{UserID},
            );

            if ($NewTeam) {
                $Self->_Overview();
                my $Output = $LayoutObject->Header();
                $Output .= $LayoutObject->NavigationBar();
                $Output .= $LayoutObject->Notify( Info => 'Team added!' );
                $Output .= $LayoutObject->Output(
                    TemplateFile => 'AgentAppointmentTeam',
                    Data         => \%Param,
                );
                $Output .= $LayoutObject->Footer();
                return $Output;
            }
        }

        # something has gone wrong
        my $Output = $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();
        $Output .= $LayoutObject->Notify( Team => 'Error' );
        $Self->_Edit(
            Action => 'Add',
            Errors => \%Errors,
            %GetParam,
        );
        $Output .= $LayoutObject->Output(
            TemplateFile => 'AgentAppointmentTeam',
            Data         => \%Param,
        );
        $Output .= $LayoutObject->Footer();
        return $Output;
    }

    # ------------------------------------------------------------ #
    # team import
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'TeamImport' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        # get the uploaded file content
        my $FormID = $ParamObject->GetParam( Param => 'FormID' ) || '';
        my %UploadStuff = $ParamObject->GetUploadAll(
            Param => 'FileUpload',
        );
        my $Content = $UploadStuff{Content};

        # check for overwriting option
        my $OverwriteExistingEntities = $ParamObject->GetParam( Param => 'OverwriteExistingEntities' ) || 0;

        # extract the team data from the uploaded file
        my $TeamData = $Kernel::OM->Get('Kernel::System::YAML')->Load( Data => $Content );
        if ( ref $TeamData ne 'HASH' ) {
            return (
                Message =>
                    "Couldn't read team configuration file. Please make sure you file is valid.",
            );
        }

        # import the team
        my $Success = $TeamObject->TeamImport(
            TeamData                  => $TeamData,
            OverwriteExistingEntities => $OverwriteExistingEntities,
            UserID                    => $Self->{UserID},
        );

        if ( !$Success ) {

            $Self->_Overview();
            my $Output = $LayoutObject->Header();
            $Output .= $LayoutObject->NavigationBar();
            $Output .= $LayoutObject->Notify(
                Priority => 'Error',
                Info     => 'Could not import the team!'
            );
            $Output .= $LayoutObject->Output(
                TemplateFile => 'AgentAppointmentTeam',
                Data         => \%Param,
            );
            $Output .= $LayoutObject->Footer();
            return $Output;
        }
        else {

            $Self->_Overview();
            my $Output = $LayoutObject->Header();
            $Output .= $LayoutObject->NavigationBar();
            $Output .= $LayoutObject->Notify( Info => 'Team imported!' );
            $Output .= $LayoutObject->Output(
                TemplateFile => 'AgentAppointmentTeam',
                Data         => \%Param,
            );
            $Output .= $LayoutObject->Footer();
            return $Output;
        }
    }

    # ------------------------------------------------------------ #
    # team export
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'TeamExport' ) {

        # check for TeamID
        my $TeamID = $ParamObject->GetParam( Param => 'TeamID' ) || '';
        if ( !$TeamID ) {
            return $LayoutObject->ErrorScreen(
                Message => Translatable('Need TeamID!'),
            );
        }

        # get team data
        my %TeamData = $TeamObject->TeamGet(
            TeamID => $TeamID,
            UserID => $Self->{UserID},
        );

        if ( !IsHashRefWithData( \%TeamData ) ) {
            return $LayoutObject->ErrorScreen(
                Message => Translatable('Could not retrieve data for given TeamID') . " $TeamID",
            );
        }

        # get team user list
        my %TeamUserList = $TeamObject->TeamUserList(
            TeamID => $TeamID,
            UserID => $Self->{UserID},
        );

        # get a local user object
        my $UserObject = $Kernel::OM->Get('Kernel::System::User');

        my %PreparedUsers;

        USERID:
        for my $UserID ( sort keys %TeamUserList ) {

            next USERID if !$UserID;

            # get user login by user id
            my $UserLogin = $UserObject->UserLookup(
                UserID => $UserID,
            );

            next USERID if !$UserLogin;

            # save user id and user login
            $PreparedUsers{$UserID} = $UserLogin;
        }

        $TeamData{UserList} = \%PreparedUsers;

        # convert the team data hash to string
        my $TeamDataYAML = $Kernel::OM->Get('Kernel::System::YAML')->Dump( Data => \%TeamData );

        # prepare team name to be part of the filename
        my $TeamName = $TeamData{Name};
        $TeamName =~ s/\s+/_/g;

        # send the result to the browser
        return $LayoutObject->Attachment(
            ContentType => 'text/html; charset=' . $LayoutObject->{Charset},
            Content     => $TeamDataYAML,
            Type        => 'attachment',
            Filename    => 'Export_Team_' . $TeamName . '.yml',
            NoCache     => 1,
        );
    }

    # ------------------------------------------------------------
    # overview screen
    # ------------------------------------------------------------
    else {
        $Self->_Overview();
        my $Output = $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();
        $Output .= $LayoutObject->Output(
            TemplateFile => 'AgentAppointmentTeam',
            Data         => \%Param,
        );
        $Output .= $LayoutObject->Footer();
        return $Output;
    }
}

sub _Edit {
    my ( $Self, %Param ) = @_;

    # get a local layout object
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    $LayoutObject->Block(
        Name => 'Overview',
        Data => \%Param,
    );

    $LayoutObject->Block( Name => 'ActionList' );
    $LayoutObject->Block( Name => 'ActionOverview' );

    # get valid list
    my %ValidList        = $Kernel::OM->Get('Kernel::System::Valid')->ValidList();
    my %ValidListReverse = reverse %ValidList;

    $Param{ValidOptionStrg} = $LayoutObject->BuildSelection(
        Data       => \%ValidList,
        Name       => 'ValidID',
        SelectedID => $Param{ValidID} || $ValidListReverse{valid},
        Class      => 'Modernize Validate_Required ' . ( $Param{Errors}->{'ValidIDInvalid'} || '' ),
    );

    # get group list
    my %GroupList = $Kernel::OM->Get('Kernel::System::Group')->GroupList(
        Valid => 1,
    );
    $Param{GroupOptionStrg} = $LayoutObject->BuildSelection(
        Data       => \%GroupList,
        Name       => 'GroupID',
        SelectedID => $Param{GroupID} || '',
        Class      => 'Modernize Validate_Required ' . ( $Param{Errors}->{'GroupIDInvalid'} || '' ),
    );

    $LayoutObject->Block(
        Name => 'OverviewUpdate',
        Data => {
            %Param,
            %{ $Param{Errors} },
        },
    );

    # shows header
    if ( $Param{Action} eq 'Change' ) {
        $LayoutObject->Block( Name => 'HeaderEdit' );
    }
    else {
        $LayoutObject->Block( Name => 'HeaderAdd' );
    }

    return 1;
}

sub _Overview {
    my ( $Self, %Param ) = @_;

    my $Output = '';

    # get a local layout object
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    $LayoutObject->Block(
        Name => 'Overview',
        Data => \%Param,
    );

    $LayoutObject->Block( Name => 'ActionList' );
    $LayoutObject->Block( Name => 'ActionAdd' );

    $LayoutObject->Block(
        Name => 'OverviewResult',
        Data => \%Param,
    );

    # get a local team object
    my $TeamObject = $Kernel::OM->Get('Kernel::System::Calendar::Team');

    # get Team list
    my %TeamList = $TeamObject->TeamList(
        Valid => 0,
    );

    # if there are any teams defined, they are shown
    if (%TeamList) {

        # get valid list
        my %ValidList = $Kernel::OM->Get('Kernel::System::Valid')->ValidList();

        for my $TeamID ( sort { $a <=> $b } keys %TeamList ) {

            # get Team data
            my %TeamData = $TeamObject->TeamGet(
                TeamID => $TeamID,
                UserID => $Self->{UserID},
            );

            # group lookup
            $TeamData{GroupName} = $Kernel::OM->Get('Kernel::System::Group')->GroupLookup(
                GroupID => $TeamData{GroupID},
            );

            $LayoutObject->Block(
                Name => 'OverviewResultRow',
                Data => {
                    %TeamData,
                    TeamID => $TeamID,
                    Valid  => $ValidList{ $TeamData{ValidID} },
                },
            );
        }
    }

    # otherwise a no data found message is displayed
    else {
        $LayoutObject->Block(
            Name => 'NoDataFoundMsg',
            Data => {},
        );
    }
    return 1;
}

1;
