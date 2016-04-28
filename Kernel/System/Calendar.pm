# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Calendar;

use strict;
use warnings;

use Kernel::System::EventHandler;
use Kernel::Language qw(Translatable);
use vars qw(@ISA);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Cache',
    'Kernel::System::Group',
    'Kernel::System::DB',
    'Kernel::System::Log',
    'Kernel::System::Main',
);

=head1 NAME

Kernel::System::Calendar - calendar lib

=head1 SYNOPSIS

All calendar functions.

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object. Do not use it directly, instead use:

    use Kernel::System::ObjectManager;
    local $Kernel::OM = Kernel::System::ObjectManager->new();
    my $CalendarObject = $Kernel::OM->Get('Kernel::System::Calendar');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    # load backend module
    my $Backend = $Kernel::OM->Get('Kernel::Config')->{'AppointmentCalendar::Backend'};

    if ($Backend) {
        my $GenericModule = 'Kernel::System::Calendar::Backend::' . $Backend;
        return if !$Kernel::OM->Get('Kernel::System::Main')->Require($GenericModule);
        $Self->{Backend} = $GenericModule->new( %{$Self} );
    }
    else {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'Error',
            Message  => 'Unknown database type! Set option Database::Type in '
                . 'Kernel/Config.pm to (mysql|postgresql|oracle|db2|mssql).',
        );
        return;
    }

    @ISA = qw(
        Kernel::System::EventHandler
    );

    # init of event handler
    $Self->EventHandlerInit(
        Config => 'AppointmentCalendar::EventModulePost',
    );

    $Self->{CacheType} = 'Calendar';
    $Self->{CacheTTL}  = 60 * 60 * 24 * 20;

    return $Self;
}

=item CalendarCreate()

creates a new calendar for given user.

    my %Calendar = $CalendarObject->CalendarCreate(
        CalendarName    => 'Meetings',          # (required) Personal calendar name
        GroupID         => 3,                   # (required) GroupID
        UserID          => 4,                   # (required) UserID
        ValidID         => 1,                   # (optional) Default is 1.
    );

returns Calendar hash if successful:
    %Calendar = (
        CalendarID   => 2,
        GroupID      => 3,
        CalendarName => 'Meetings',
        CreateTime   => '2016-01-01 08:00:00',
        CreateBy     => 4,
        ChangeTime   => '2016-01-01 08:00:00',
        ChangeBy     => 4,
        ValidID      => 1,
    );

Events:
    CalendarCreate

=cut

sub CalendarCreate {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(CalendarName GroupID UserID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    my $ValidID = defined $Param{ValidID} ? $Param{ValidID} : 1;

    my %Calendar = $Self->CalendarGet(
        CalendarName => $Param{CalendarName},
        UserID       => $Param{UserID},
    );

    # If user already has Calendar with same name, return
    return if %Calendar;

    my $SQL = '
        INSERT INTO calendar
            (group_id, name, create_time, create_by, change_time, change_by, valid_id)
        VALUES (?, ?, current_timestamp, ?, current_timestamp, ?, ?)
    ';

    # create db record
    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL  => $SQL,
        Bind => [
            \$Param{GroupID}, \$Param{CalendarName}, \$Param{UserID}, \$Param{UserID}, \$ValidID
        ],
    );

    %Calendar = $Self->CalendarGet(
        CalendarName => $Param{CalendarName},
        UserID       => $Param{UserID},
    );
    return if !%Calendar;

    # cache value
    $Kernel::OM->Get('Kernel::System::Cache')->Set(
        Type  => $Self->{CacheType},
        Key   => $Calendar{CalendarID},
        Value => \%Calendar,
        TTL   => $Self->{CacheTTL},
    );

    # reset CalendarList
    $Kernel::OM->Get('Kernel::System::Cache')->CleanUp(
        Type => 'CalendarList',
    );

    # fire event
    $Self->EventHandler(
        Event => 'CalendarCreate',
        Data  => {
            %Calendar,
        },
        UserID => $Param{UserID},
    );

    return %Calendar;
}

=item CalendarGet()

get calendar by name od id.

    my %Calendar = $CalendarObject->CalendarGet(
        CalendarName => 'Meetings',          # (required) Calendar name
                                             # or
        CalendarID   => 4,                   # (required) CalendarID

        UserID       => 2,                   # (required)
    );

returns Calendar data:
    %Calendar = (
        CalendarID   => 2,
        GroupID      => 3,
        CalendarName => 'Meetings',
        CreateTime   => '2016-01-01 08:00:00',
        CreateBy     => 1,
        ChangeTime   => '2016-01-01 08:00:00',
        ChangeBy     => 1,
        ValidID      => 1,
    );

=cut

sub CalendarGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(UserID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }
    if ( !$Param{CalendarID} && !$Param{CalendarName} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need CalendarID or CalendarName!"
        );
        return;
    }

    my %Calendar;

    if ( $Param{CalendarID} ) {

        # check if value is cached
        my $Data = $Kernel::OM->Get('Kernel::System::Cache')->Get(
            Type => $Self->{CacheType},
            Key  => $Param{CalendarID},
        );

        if ( ref $Data eq 'HASH' ) {
            return %{$Data};
        }
    }

    # get user groups
    my %GroupList = $Kernel::OM->Get('Kernel::System::Group')->PermissionUserGet(
        UserID => $Param{UserID},
        Type   => 'ro',
    );
    my @GroupIDs = sort keys %GroupList;

    # create db object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    my $SQL = "
        SELECT id, group_id, name, create_time, create_by, change_time, change_by, valid_id
        FROM calendar
        WHERE group_id IN ( ${\(join ', ', @GroupIDs)} ) ";

    my @Bind;
    if ( $Param{CalendarID} ) {
        $SQL .= '
            AND id=?
        ';
        push @Bind, \$Param{CalendarID};
    }
    else {
        $SQL .= '
            AND name=?
        ';
        push @Bind, \$Param{CalendarName};
    }

    # db query
    return if !$DBObject->Prepare(
        SQL   => $SQL,
        Bind  => \@Bind,
        Limit => 1,
    );

    while ( my @Row = $DBObject->FetchrowArray() ) {
        $Calendar{CalendarID}   = $Row[0];
        $Calendar{GroupID}      = $Row[1];
        $Calendar{CalendarName} = $Row[2];
        $Calendar{CreateTime}   = $Row[3];
        $Calendar{CreateBy}     = $Row[4];
        $Calendar{ChangeTime}   = $Row[5];
        $Calendar{ChangeBy}     = $Row[6];
        $Calendar{ValidID}      = $Row[7];
    }

    if ( $Param{CalendarID} ) {

        # cache
        $Kernel::OM->Get('Kernel::System::Cache')->Set(
            Type  => $Self->{CacheType},
            Key   => $Param{CalendarID},
            Value => \%Calendar,
            TTL   => $Self->{CacheTTL},
        );
    }

    return %Calendar;
}

=item CalendarList()

get calendar list.

    my @Result = $CalendarObject->CalendarList(
        UserID  => 4,               # (optional) For permission check
        ValidID => 1,               # (optional) Default 0.
                                    # 0 - All states
                                    # 1 - All valid
                                    # 2 - All invalid
                                    # 3 - All temporary invalid
    );

returns:
    @Result = [
        {
            CalendarID   => 2,
            GroupID      => 3,
            CalendarName => 'Meetings',
            CreateTime   => '2016-01-01 08:00:00',
            CreateBy     => 3,
            ChangeTime   => '2016-01-01 08:00:00',
            ChangeBy     => 3,
            ValidID      => 1,
        },
        {
            CalendarID   => 3,
            GroupID      => 3,
            CalendarName => 'Customer presentations',
            CreateTime   => '2016-01-01 08:00:00',
            CreateBy     => 3,
            ChangeTime   => '2016-01-01 08:00:00',
            ChangeBy     => 3,
            ValidID      => 0,
        },
        ...
    ];

=cut

sub CalendarList {
    my ( $Self, %Param ) = @_;

    # Make different cache type for list (so we can clear cache by this value)
    my $CacheType     = 'CalendarList';
    my $CacheKeyUser  = $Param{UserID} || 'all-user-ids';
    my $CacheKeyValid = $Param{ValidID} || 'all-valid-ids';

    # get cached value if exists
    my $Data = $Kernel::OM->Get('Kernel::System::Cache')->Get(
        Type => $CacheType,
        Key  => "$CacheKeyUser-$CacheKeyValid",
    );

    if ( ref $Data eq 'ARRAY' ) {
        return @{$Data};
    }

    # create needed objects
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    my $SQL = '
        SELECT id, group_id, name, create_time, create_by, change_time, change_by, valid_id
        FROM calendar
        WHERE 1=1
    ';
    my @Bind;

    if ( $Param{ValidID} ) {
        $SQL .= ' AND valid_id=? ';
        push @Bind, \$Param{ValidID};
    }

    if ( $Param{UserID} ) {

        # get user groups
        my %GroupList = $Kernel::OM->Get('Kernel::System::Group')->PermissionUserGet(
            UserID => $Param{UserID},
            Type   => $Param{Permission} || 'ro',
        );

        my @GroupIDs = sort keys %GroupList;

        $SQL .= "AND group_id IN ( ${\(join ', ', @GroupIDs)} ) ";
    }

    $SQL .= 'ORDER BY id ASC';

    # db query
    return if !$DBObject->Prepare(
        SQL  => $SQL,
        Bind => \@Bind,
    );

    my @Result;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        my %Calendar;
        $Calendar{CalendarID}   = $Row[0];
        $Calendar{GroupID}      = $Row[1];
        $Calendar{CalendarName} = $Row[2];
        $Calendar{CreateTime}   = $Row[3];
        $Calendar{CreateBy}     = $Row[4];
        $Calendar{ChangeTime}   = $Row[5];
        $Calendar{ChangeBy}     = $Row[6];
        $Calendar{ValidID}      = $Row[7];
        push @Result, \%Calendar;
    }

    # cache data
    $Kernel::OM->Get('Kernel::System::Cache')->Set(
        Type  => $CacheType,
        Key   => "$CacheKeyUser-$CacheKeyValid",
        Value => \@Result,
        TTL   => $Self->{CacheTTL},
    );

    return @Result;
}

=item CalendarUpdate()

updates an existing calendar.

    my $Success = $CalendarObject->CalendarUpdate(
        CalendarID       => 1,                   # (required) CalendarID
        GroupID          => 2,                   # (required) Calendar group
        CalendarName     => 'Meetings',          # (required) Personal calendar name
        UserID           => 4,                   # (required) UserID (who made update)
        ValidID          => 1,                   # (required) ValidID
    );

returns 1 if successful:

Events:
    CalendarUpdate

=cut

sub CalendarUpdate {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(CalendarID GroupID CalendarName UserID ValidID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    # needed objects
    my $CacheObject = $Kernel::OM->Get('Kernel::System::Cache');

    my $SQL = '
        UPDATE calendar
        SET group_id=?, name=?, change_time=current_timestamp, change_by=?, valid_id=?
    ';

    my @Bind;
    push @Bind, ( \$Param{GroupID}, \$Param{CalendarName}, \$Param{UserID}, \$Param{ValidID} );

    $SQL .= '
            WHERE id=?
    ';
    push @Bind, \$Param{CalendarID};

    # create db record
    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL  => $SQL,
        Bind => \@Bind,
    );

    # clear cache
    $CacheObject->CleanUp(
        Type => 'CalendarList',
    );

    $CacheObject->CleanUp(
        Type => 'CalendarPermissionGet',
    );

    $CacheObject->Delete(
        Type => $Self->{CacheType},
        Key  => $Param{CalendarID},
    );

    # fire event
    $Self->EventHandler(
        Event => 'CalendarUpdate',
        Data  => {
            Calendar => $Param{CalendarID},
        },
        UserID => $Param{UserID},
    );

    return 1;
}

=item CalendarPermissionGet()

get permission level for given CalendarID and UserID.

    my $Permission = $CalendarObject->CalendarPermissionGet(
        CalendarID  => 1,                   # (required) CalendarID
        UserID      => 4,                   # (required) UserID
    );

returns:
    $Permission = 'rw';    # 'ro', 'rw',...

=cut

sub CalendarPermissionGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(CalendarID UserID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    # needed object
    my $CacheObject = $Kernel::OM->Get('Kernel::System::Cache');
    my $DBObject    = $Kernel::OM->Get('Kernel::System::DB');

    # cache params
    my $CacheType = 'CalendarPermissionGet';
    my $CacheKey  = "$Param{CalendarID}-$Param{UserID}";

    # get cached value if exists
    my $Data = $CacheObject->Get(
        Type => $CacheType,
        Key  => $CacheKey,
    );

    # return cached result if exists
    return $Data if $Data;

    my $GroupID;

    my $SQL = '
        SELECT group_id
        FROM calendar
        WHERE id=?
    ';

    # db query
    return if !$DBObject->Prepare(
        SQL  => $SQL,
        Bind => [
            \$Param{CalendarID},
        ],
    );

    while ( my @Row = $DBObject->FetchrowArray() ) {
        $GroupID = $Row[0];
    }
    return if !$GroupID;

    TYPE:
    for my $Type (qw(ro move_into create rw)) {

        my %GroupData = $Kernel::OM->Get('Kernel::System::Group')->PermissionUserGet(
            UserID => $Param{UserID},
            Type   => $Type,
        );

        if ( $GroupData{$GroupID} ) {
            $Data = $Type;
        }
        else {
            last TYPE;
        }
    }

    return if !$Data;

    # TODO: Check how to delete this cache in the framework!
    # cache data
    # $CacheObject->Set(
    #     Type  => $CacheType,
    #     Key   => $CacheKey,
    #     Value => $Data,
    #     TTL   => $Self->{CacheTTL},
    # );

    return $Data;
}
1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
