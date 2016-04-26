# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Calendar::Team;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::System::Log',
    'Kernel::System::DB',
    'Kernel::System::Group',
    'Kernel::System::Cache',
    'Kernel::System::Valid',
);

=head1 NAME

Kernel::System::Calendar::Team - Team lib

=head1 SYNOPSIS

All Team functions.

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object. Do not use it directly, instead use:

    use Kernel::System::ObjectManager;
    local $Kernel::OM = Kernel::System::ObjectManager->new();
    my $TeamObject = $Kernel::OM->Get('Kernel::System::Calendar::Team');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # set cache type and ttl
    $Self->{CacheType} = 'Team';
    $Self->{CacheTTL}  = 60 * 60 * 24 * 20;

    return $Self;
}

=item TeamList()

return a Team list as hash

    my %List = $TeamObject->TeamList(
        Valid  => 0,     # (optional)
        UserID => 1,     # (optional)
    );

=cut

sub TeamList {
    my ( $Self, %Param ) = @_;

    # check valid param
    if ( !defined $Param{Valid} ) {
        $Param{Valid} = 1;
    }

    # create cache key
    my $CacheKey;
    if ( $Param{Valid} ) {
        $CacheKey = 'TeamList::Valid';
    }
    else {
        $CacheKey = 'TeamList::All';
    }

    # check UserID
    return if ( $Param{UserID} && !IsInteger( $Param{UserID} ) );

    if ( $Param{UserID} ) {
        $CacheKey .= '::' . $Param{UserID};
    }

    # get local cache object
    my $CacheObject = $Kernel::OM->Get('Kernel::System::Cache');

    # check cache
    my $Cache = $CacheObject->Get(
        Key  => $CacheKey,
        Type => $Self->{CacheType},
    );
    return %{$Cache} if $Cache;

    # create sql
    my @Bind;
    my $SQL = 'SELECT id, name FROM calendar_team
        WHERE 1=1 ';
    if ( $Param{Valid} ) {
        $SQL .= "AND valid_id IN ( ${\(join ', ', $Kernel::OM->Get('Kernel::System::Valid')->ValidIDsGet())} ) ";
    }
    if ( $Param{UserID} ) {
        $SQL .= 'AND create_by = ?';
        push @Bind, \$Param{UserID};
    }

    # get local database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    return if !$DBObject->Prepare(
        SQL  => $SQL,
        Bind => \@Bind,
    );

    # fetch the result
    my %Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $Data{ $Row[0] } = $Row[1];
    }

    # set cache
    $CacheObject->Set(
        Key   => $CacheKey,
        Value => \%Data,
        Type  => $Self->{CacheType},
        TTL   => $Self->{CacheTTL},
    );

    return %Data;
}

=item TeamGet()

get a Team

    my %Team = $TeamObject->TeamGet(
        TeamID => 123,              # required
                                    # or
        Name => 'Some Team Name',   # required

        UserID => 1,                # required
    );

=cut

sub TeamGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( ( !$Param{TeamID} && !$Param{Name} ) || !$Param{UserID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need TeamID or Name and UserID!',
        );
        return;
    }

    # get local cache object
    my $CacheObject = $Kernel::OM->Get('Kernel::System::Cache');

    # check cache
    my $CacheKey = $Param{TeamID} || $Param{Name};
    my $Cache = $CacheObject->Get(
        Key  => 'TeamGet' . $CacheKey,
        Type => $Self->{CacheType},
    );
    return %{$Cache} if $Cache;

    # get local database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    my @Bind;
    my $SQL = 'SELECT id, name, group_id, comments, valid_id, create_time, create_by, change_time, change_by
        FROM calendar_team
        WHERE 1=1 ';

    if ( $Param{TeamID} ) {
        $SQL .= 'AND id = ?';
        push @Bind, \$Param{TeamID};
    }
    elsif ( $Param{Name} ) {
        $SQL .= 'AND name = ?';
        push @Bind, \$Param{Name};
    }

    # ask database
    return if !$DBObject->Prepare(
        SQL   => $SQL,
        Bind  => \@Bind,
        Limit => 1,
    );

    # fetch the result
    my %Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $Data{ID}         = $Row[0];
        $Data{Name}       = $Row[1];
        $Data{GroupID}    = $Row[2];
        $Data{Comment}    = $Row[3];
        $Data{ValidID}    = $Row[4];
        $Data{CreateTime} = $Row[5];
        $Data{CreateBy}   = $Row[6];
        $Data{ChangeTime} = $Row[7];
        $Data{ChangeBy}   = $Row[8];
    }

    # set cache
    $CacheObject->Set(
        Key   => 'TeamGet' . $CacheKey,
        Value => \%Data,
        Type  => $Self->{CacheType},
        TTL   => $Self->{CacheTTL},
    );

    return %Data;
}

=item TeamAdd()

add a team

    my $True = $TeamObject->TeamAdd(
        Name    => 'Some Team Name',
        GroupID => 5,
        Comment => 'My comment',
        ValidID => 1,
        UserID  => 1,
    );

=cut

sub TeamAdd {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(Name GroupID ValidID UserID)) {
        if ( !$Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    # check if team with same name exists
    return if $Self->TeamGet(
        Name   => $Param{Name},
        UserID => $Param{UserID},
    );

    # check group
    return if !$Kernel::OM->Get('Kernel::System::Group')->GroupLookup(
        GroupID => $Param{GroupID},
    );

    # get local database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    return if !$DBObject->Do(
        SQL => 'INSERT INTO calendar_team
                   (name, group_id, comments, valid_id, create_time, create_by, change_time, change_by)
                   VALUES
                   (?, ?, ?, ?, current_timestamp, ?, current_timestamp, ?)',
        Bind => [
            \$Param{Name}, \$Param{GroupID}, \$Param{Comment}, \$Param{ValidID}, \$Param{UserID},
            \$Param{UserID},
        ],
    );

    # get new team id
    return if !$DBObject->Prepare(
        SQL => 'SELECT id
                      FROM calendar_team
                      WHERE name = ?',
        Bind  => [ \$Param{Name} ],
        Limit => 1,
    );

    # fetch the result
    my $ID;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $ID = $Row[0];
    }

    return if !$ID;

    # delete cache
    $Kernel::OM->Get('Kernel::System::Cache')->CleanUp();

    return $ID;
}

=item TeamUpdate()

update an existing Team

    my $True = $TeamObject->TeamUpdate(
        TeamID         => 123,
        Name           => 'New Name',
        GroupID        => 4,
        Comment        => 'Some comment',
        ValidID        => 1,
        UserID         => 1,
    );

=cut

sub TeamUpdate {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(TeamID Name GroupID ValidID UserID)) {
        if ( !$Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    # check if team with same name exists
    my %Team = $Self->TeamGet(
        Name   => $Param{Name},
        UserID => $Param{UserID},
    );
    if (%Team) {
        return if $Team{ID} != $Param{TeamID};
    }

    # check group
    return if !$Kernel::OM->Get('Kernel::System::Group')->GroupLookup(
        GroupID => $Param{GroupID},
    );

    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL => 'UPDATE calendar_team
                    SET name = ?, group_id = ?, comments = ?, valid_id = ?,
                    change_time = current_timestamp, change_by = ?
                WHERE id = ?',
        Bind => [
            \$Param{Name}, \$Param{GroupID}, \$Param{Comment}, \$Param{ValidID}, \$Param{UserID},
            \$Param{TeamID},
        ],
    );

    # delete cache
    $Kernel::OM->Get('Kernel::System::Cache')->CleanUp();

    return 1;
}

=item AllowedTeamList()

return allowed, valid Teams list as hash

    my %List = $TeamObject->AllowedTeamList(
        PreventEmpty => 1,    # just get teams with assigned users; optional - default 0
        UserID       => 123,
    );

=cut

sub AllowedTeamList {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(UserID)) {
        if ( !$Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    if ( !$Param{PreventEmpty} ) {
        $Param{PreventEmpty} = 0;
    }

    my @Groups = $Kernel::OM->Get('Kernel::System::Group')->GroupMemberList(
        UserID => $Param{UserID},
        Type   => 'ro',
        Result => 'ID',
    );

    # abort if user is not a member of any group
    return if !scalar @Groups;

    # create cache key
    my $CacheKey = "AllowedTeamList::$Param{PreventEmpty}" . join( '::', sort @Groups );

    # get local cache object
    my $CacheObject = $Kernel::OM->Get('Kernel::System::Cache');

    # check cache
    my $Cache = $CacheObject->Get(
        Key  => $CacheKey,
        Type => $Self->{CacheType},
    );
    return %{$Cache} if $Cache;

    # get local database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # create sql
    my $SQL = '';

    if ( $Param{PreventEmpty} ) {
        $SQL = "SELECT DISTINCT id, name
                FROM calendar_team st
                JOIN calendar_team_user stu ON stu.team_id = st.id
                WHERE st.group_id IN ( ${\(join ', ', @Groups)} )
                AND st.valid_id = 1";
    }
    else {
        $SQL = "SELECT id, name
                FROM calendar_team
                WHERE group_id IN ( ${\(join ', ', @Groups)} )
                AND valid_id = 1";
    }

    return if !$DBObject->Prepare( SQL => $SQL );

    # fetch the result
    my %Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $Data{ $Row[0] } = $Row[1];
    }

    # set cache
    $CacheObject->Set(
        Key   => $CacheKey,
        Value => \%Data,
        Type  => $Self->{CacheType},
        TTL   => $Self->{CacheTTL},
    );

    return %Data;
}

=item TeamUserAdd()

add an agent to a team

    my $True = $TeamObject->TeamUserAdd(
        TeamID     => 4,
        TeamUserID => 5,
        UserID     => 1,
    );

=cut

sub TeamUserAdd {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(TeamID TeamUserID UserID)) {
        if ( !$Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    # TODO
    # implement TeamID, TeamUserID, permission? check (enforced by constraint on DB level)

    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL => 'INSERT INTO calendar_team_user
               (team_id, user_id, create_time, create_by, change_time, change_by)
               VALUES
               (?, ?, current_timestamp, ?, current_timestamp, ?)',
        Bind => [
            \$Param{TeamID}, \$Param{TeamUserID}, \$Param{UserID}, \$Param{UserID},
        ],
    );

    # delete cache
    $Kernel::OM->Get('Kernel::System::Cache')->CleanUp();

    return 1;
}

=item TeamUserRemove()

remove an agent from a team

    my $True = $TeamObject->TeamUserRemove(
        TeamID     => 4,
        TeamUserID => 5,
        UserID     => 1,
    );

=cut

sub TeamUserRemove {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(TeamID TeamUserID UserID)) {
        if ( !$Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    # TODO
    # implement TeamID, TeamUserID, permission? check (enforced by constraint on DB level)

    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL => 'DELETE FROM calendar_team_user
                   WHERE team_id = ?
                   AND user_id = ?',
        Bind => [
            \$Param{TeamID}, \$Param{TeamUserID},
        ],
    );

    # delete cache
    $Kernel::OM->Get('Kernel::System::Cache')->CleanUp();

    return 1;
}

=item TeamUserList()

return agents list for a team as a hash

    my %List = $TeamObject->TeamUserList(
        TeamID => 42,
        UserID => 123,
    );

=cut

sub TeamUserList {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(TeamID UserID)) {
        if ( !$Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    # create cache key
    my $CacheKey = "TeamUserList::$Param{TeamID}";

    # get local cache object
    my $CacheObject = $Kernel::OM->Get('Kernel::System::Cache');

    # check cache
    my $Cache = $CacheObject->Get(
        Key  => $CacheKey,
        Type => $Self->{CacheType},
    );
    return %{$Cache} if $Cache;

    # get local database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    return if !$DBObject->Prepare(
        SQL => 'SELECT user_id
                    FROM calendar_team_user
                    WHERE team_id = ?',
        Bind => [ \$Param{TeamID}, ],
    );

    # fetch the result
    my %Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $Data{ $Row[0] } = $Row[0];
    }

    # set cache
    $CacheObject->Set(
        Key   => $CacheKey,
        Value => \%Data,
        Type  => $Self->{CacheType},
        TTL   => $Self->{CacheTTL},
    );

    return %Data;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
