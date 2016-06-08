# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentAppointmentTeamList;

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

    KEY:
    for my $Key (@ParamNames) {
        $GetParam{$Key} = $ParamObject->GetParam( Param => $Key );
    }

    # get needed objects
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my $JSON = $LayoutObject->JSONEncode( Data => [] );

    $LayoutObject->ChallengeTokenCheck();

    # check request
    if ( $Self->{Subaction} eq 'ListResources' ) {

        if ( $GetParam{TeamID} ) {

            # get team object
            my $TeamObject = $Kernel::OM->Get('Kernel::System::Calendar::Team');

            # get list of agents for the team
            my %TeamUserIDs = $TeamObject->TeamUserList(
                TeamID => $GetParam{TeamID},
                UserID => $Self->{UserID},
            );

            if ( scalar keys %TeamUserIDs > 0 ) {

                # get user object
                my $UserObject = $Kernel::OM->Get('Kernel::System::User');

                # get user preferences
                my %Preferences = $Kernel::OM->Get('Kernel::System::User')->GetPreferences(
                    UserID => $Self->{UserID},
                );

                # get resource names
                my @TeamUserList;
                for my $UserID ( sort keys %TeamUserIDs ) {
                    my %User = $UserObject->GetUserData(
                        UserID => $UserID,
                    );
                    push @TeamUserList, {
                        id           => $User{UserID},
                        title        => $User{UserFullname},
                        TeamID       => $GetParam{TeamID},
                        UserLastname => $User{UserLastname},
                    };
                }

                # sort the list by last name
                @TeamUserList = sort { $a->{UserLastname} cmp $b->{UserLastname} } @TeamUserList;
                my @TeamUserIDs = map { $_->{id} } @TeamUserList;

                # resource name lookup table
                my %TeamUserList = map { $_->{id} => $_->{title} } @TeamUserList;

                # user preference key
                my $ShownResourcesPrefKey = 'UserResourceOverviewShownResources-' . $GetParam{TeamID};

                # read preference if it exists
                my @ShownResources;
                if ( $Preferences{$ShownResourcesPrefKey} ) {
                    my $ShownResourcesPrefVal = $Kernel::OM->Get('Kernel::System::JSON')->Decode(
                        Data => $Preferences{$ShownResourcesPrefKey},
                    );

                    # add only valid and unique users
                    for my $UserID ( @{ $ShownResourcesPrefVal || [] } ) {
                        if ( grep { $_ eq $UserID } @TeamUserIDs ) {
                            push @ShownResources, {
                                id     => $UserID,
                                title  => $TeamUserList{$UserID},
                                TeamID => $GetParam{TeamID},
                            } if !grep { $_->{id} eq $UserID } @ShownResources;
                        }
                    }
                }

                # set default if empty
                @ShownResources = @TeamUserList if !scalar @ShownResources;

                push @ShownResources, {
                    id     => 0,
                    title  => Translatable('Unassigned'),
                    TeamID => $GetParam{TeamID},
                };

                # build JSON output
                $JSON = $LayoutObject->JSONEncode(
                    Data => (
                        \@ShownResources,
                    ),
                );
            }
        }
    }

    # send JSON response
    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $JSON,
        Type        => 'inline',
        NoCache     => 1,
    );

    return;
}

1;
