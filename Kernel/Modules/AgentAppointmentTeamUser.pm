# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentAppointmentTeamUser;

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
    # team <-> user n:1  interface to assign users to a team
    # ------------------------------------------------------------ #
    if ( $Self->{Subaction} eq 'Team' ) {

        # get Team data
        my $ID = $ParamObject->GetParam( Param => 'ID' );

        my %TeamData = $TeamObject->TeamGet(
            TeamID => $ID,
            UserID => $Self->{UserID},
        );

        # get user list, with the full name in the value
        my %UserData = $Kernel::OM->Get('Kernel::System::User')->UserList( Valid => 1 );

        for my $UserID ( sort keys %UserData ) {
            my %User = $Kernel::OM->Get('Kernel::System::User')->GetUserData( UserID => $UserID );
            $UserData{$UserID} = "$User{UserLastname} $User{UserFirstname} ($User{UserLogin})";
        }

        # get members of the the Team
        my %Member = $TeamObject->TeamUserList(
            TeamID => $ID,
            UserID => $Self->{UserID},
        );

        my $Output = $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();
        $Output .= $Self->_Change(
            Selected => \%Member,
            Data     => \%UserData,
            ID       => $TeamData{ID},
            Name     => $TeamData{Name},
            Type     => 'Team',
        );
        $Output .= $LayoutObject->Footer();

        return $Output;
    }

    # ------------------------------------------------------------ #
    # add or remove users to a Team
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'ChangeTeam' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        # to be set members of the team
        my %NewUsers = map { $_ => $_ } $ParamObject->GetArray( Param => 'Team' );

        # get the team id
        my $ID = $ParamObject->GetParam( Param => 'ID' );

        # get user list
        my %TeamUsers = $TeamObject->TeamUserList(
            TeamID => $ID,
            UserID => $Self->{UserID},
        );

        USERID:
        for my $UserID ( sort keys %NewUsers ) {

            next USERID if !$UserID;              # for select all checkbox with ID 0
            next USERID if $TeamUsers{$UserID};

            my $Value = $TeamObject->TeamUserAdd(
                TeamUserID => $UserID,
                TeamID     => $ID,
                UserID     => $Self->{UserID},
            );
        }

        USERID:
        for my $UserID ( sort keys %TeamUsers ) {

            next USERID if $NewUsers{$UserID};

            $TeamObject->TeamUserRemove(
                TeamUserID => $UserID,
                TeamID     => $ID,
                UserID     => $Self->{UserID},
            );
        }

        return $LayoutObject->Redirect( OP => "Action=$Self->{Action}" );
    }

    # ------------------------------------------------------------ #
    # user <-> team n:1  interface to assign teams to a user
    # ------------------------------------------------------------ #
    if ( $Self->{Subaction} eq 'User' ) {

        # get Team data
        my $ID = $ParamObject->GetParam( Param => 'ID' );

        my %TeamData = $TeamObject->TeamGet(
            TeamID => $ID,
            UserID => $Self->{UserID},
        );

        # get user list, with the full name in the value
        my %UserData = $Kernel::OM->Get('Kernel::System::User')->UserList( Valid => 1 );

        for my $UserID ( sort keys %UserData ) {
            my %User = $Kernel::OM->Get('Kernel::System::User')->GetUserData( UserID => $UserID );
            $UserData{$UserID} = "$User{UserLastname} $User{UserFirstname} ($User{UserLogin})";
        }

        # get members of the the Team
        my %Member = $TeamObject->TeamUserList(
            TeamID => $ID,
            UserID => $Self->{UserID},
        );

        my $Output = $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();
        $Output .= $Self->_Change(
            Selected => \%Member,
            Data     => \%UserData,
            ID       => $TeamData{ID},
            Name     => $TeamData{Name},
            Type     => 'Team',
        );
        $Output .= $LayoutObject->Footer();

        return $Output;
    }

    # ------------------------------------------------------------ #
    # add or remove users to a Team
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'ChangeUser' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        # to be set members of the team
        my %NewUsers = map { $_ => $_ } $ParamObject->GetArray( Param => 'Team' );

        # get the team id
        my $ID = $ParamObject->GetParam( Param => 'ID' );

        # get user list
        my %TeamUsers = $TeamObject->TeamUserList(
            TeamID => $ID,
            UserID => $Self->{UserID},
        );

        USERID:
        for my $UserID ( sort keys %NewUsers ) {

            next USERID if !$UserID;              # for select all checkbox with ID 0
            next USERID if $TeamUsers{$UserID};

            my $Value = $TeamObject->TeamUserAdd(
                TeamUserID => $UserID,
                TeamID     => $ID,
                UserID     => $Self->{UserID},
            );
        }

        USERID:
        for my $UserID ( sort keys %TeamUsers ) {

            next USERID if $NewUsers{$UserID};

            $TeamObject->TeamUserRemove(
                TeamUserID => $UserID,
                TeamID     => $ID,
                UserID     => $Self->{UserID},
            );
        }

        return $LayoutObject->Redirect( OP => "Action=$Self->{Action}" );
    }

    # ------------------------------------------------------------ #
    # overview
    # ------------------------------------------------------------ #
    my $Output = $LayoutObject->Header();
    $Output .= $LayoutObject->NavigationBar();
    $Output .= $Self->_Overview();
    $Output .= $LayoutObject->Footer();

    return $Output;
}

sub _Change {
    my ( $Self, %Param ) = @_;

    my %Data   = %{ $Param{Data} };
    my $Type   = $Param{Type} || 'User';
    my $NeType = $Type eq 'Team' ? 'User' : 'Team';

    my %VisibleType = (
        Team => 'Team',
        User => 'Agent'
    );

    # get a local layout object
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    $LayoutObject->Block(
        Name => 'Change',
        Data => {
            %Param,
            ActionHome    => 'Admin' . $Type,
            NeType        => $NeType,
            VisibleType   => $VisibleType{$Type},
            VisibleNeType => $VisibleType{$NeType},
        },
    );

    $LayoutObject->Block(
        Name => 'ChangeHeader',
        Data => {
            %Param,
            Type   => $Type,
            NeType => $NeType,
        },
    );

    for my $ID ( sort { uc( $Data{$a} ) cmp uc( $Data{$b} ) } keys %Data ) {

        # set output class
        my $Selected = $Param{Selected}->{$ID} ? ' checked="checked"' : '';

        $LayoutObject->Block(
            Name => 'ChangeRow',
            Data => {
                %Param,
                Name     => $Param{Data}->{$ID},
                NeType   => $NeType,
                Type     => $Type,
                ID       => $ID,
                Selected => $Selected,
            },
        );
    }

    return $LayoutObject->Output(
        TemplateFile => 'AgentAppointmentTeamUser',
        Data         => \%Param,
    );
}

sub _Overview {
    my ( $Self, %Param ) = @_;

    # get a local layout object
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    $LayoutObject->Block(
        Name => 'Overview',
        Data => {},
    );

    $LayoutObject->Block(
        Name => 'OverviewResult',
    );

    # get a local team object
    my $TeamObject = $Kernel::OM->Get('Kernel::System::Calendar::Team');

    # get team data
    my %TeamData = $TeamObject->AllowedTeamList(
        UserID => $Self->{UserID}
    );
    if (%TeamData) {

        TEAMID:
        for my $TeamID ( sort { uc( $TeamData{$a} ) cmp uc( $TeamData{$b} ) } keys %TeamData ) {

            my %Team = $TeamObject->TeamGet(
                TeamID => $TeamID,
                UserID => $Self->{UserID},
            );

            next TEAMID if !IsHashRefWithData( \%Team );

            $LayoutObject->Block(
                Name => 'ListTeams',
                Data => {
                    Subaction => 'Team',
                    %Team,
                },
            );
        }
    }
    else {
        $LayoutObject->Block(
            Name => 'NoDataFoundMsg',
            Data => {},
        );
    }

    # get a local user object
    my $UserObject = $Kernel::OM->Get('Kernel::System::User');

    # get a list of all users
    my %UserData = $UserObject->UserList(
        Valid => 0,
    );

    # get user name
    USERID:
    for my $UserID ( sort keys %UserData ) {

        my $UserName = $UserObject->UserName( UserID => $UserID );

        next USERID if !$UserName;

        $UserData{$UserID} .= " ($UserName)";
    }

    USERID:
    for my $UserID ( sort { uc( $UserData{$a} ) cmp uc( $UserData{$b} ) } keys %UserData ) {

        next USERID if !$UserID;

        # set output class
        $LayoutObject->Block(
            Name => 'ListUsers',
            Data => {
                Name      => $UserData{$UserID},
                Subaction => 'User',
                ID        => $UserID,
            },
        );
    }

    # return output
    return $LayoutObject->Output(
        TemplateFile => 'AgentAppointmentTeamUser',
        Data         => \%Param,
    );
}

1;
