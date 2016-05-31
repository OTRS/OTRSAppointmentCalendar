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

use Digest::MD5;

use Kernel::System::EventHandler;
use Kernel::Language qw(Translatable);
use Kernel::System::VariableCheck qw(:all);
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
            Message  => 'Unknown AppointmentCalendar::Backend! Set option AppointmentCalendar::Backend in '
                . 'Kernel/Config.pm to (CalDav).',
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
        Color           => '#FF7700',           # (required) Color in hexadecimal RGB notation
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
    for my $Needed (qw(CalendarName GroupID Color UserID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    # check color
    if ( !( $Param{Color} =~ /#[A-Z0-9]{3,6}/i ) ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Color must be in hexadecimal RGB notation, eg. #FFFFFF.',
        );
        return;
    }

    # make it uppercase for the sake of consistency
    $Param{Color} = uc $Param{Color};

    my $ValidID = defined $Param{ValidID} ? $Param{ValidID} : 1;

    my %Calendar = $Self->CalendarGet(
        CalendarName => $Param{CalendarName},
    );

    # return if calendar with same name already exists
    return if %Calendar;

    # create salt string
    my $SaltString = $Self->GetRandomString( Length => 64 );

    my $SQL = '
        INSERT INTO calendar
            (group_id, name, salt_string, color, create_time, create_by, change_time, change_by,
            valid_id)
        VALUES (?, ?, ?, ?, current_timestamp, ?, current_timestamp, ?, ?)
    ';

    # create db record
    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL  => $SQL,
        Bind => [
            \$Param{GroupID}, \$Param{CalendarName}, \$SaltString, \$Param{Color}, \$Param{UserID},
            \$Param{UserID}, \$ValidID
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

        UserID       => 2,                   # (optional) UserID - System will check if user has access to calendar if provided
    );

returns Calendar data:
    %Calendar = (
        CalendarID   => 2,
        GroupID      => 3,
        CalendarName => 'Meetings',
        Color        => '#FF7700',
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

        if ( IsHashRefWithData($Data) ) {
            %Calendar = %{$Data};
        }
    }

    if ( !%Calendar ) {

        # create db object
        my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

        my $SQL = '
            SELECT id, group_id, name, color, create_time, create_by, change_time, change_by,
            valid_id
            FROM calendar
            WHERE
        ';

        my @Bind;
        if ( $Param{CalendarID} ) {
            $SQL .= '
                id=?
            ';
            push @Bind, \$Param{CalendarID};
        }
        else {
            $SQL .= '
                name=?
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
            $Calendar{Color}        = $Row[3];
            $Calendar{CreateTime}   = $Row[4];
            $Calendar{CreateBy}     = $Row[5];
            $Calendar{ChangeTime}   = $Row[6];
            $Calendar{ChangeBy}     = $Row[7];
            $Calendar{ValidID}      = $Row[8];
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

        if ( $Param{UserID} && $Calendar{GroupID} ) {

            # get user groups
            my %GroupList = $Kernel::OM->Get('Kernel::System::Group')->PermissionUserGet(
                UserID => $Param{UserID},
                Type   => 'ro',
            );

            if ( !grep { $Calendar{GroupID} == $_ } keys %GroupList ) {
                %Calendar = ();
            }
        }
    }

    return %Calendar;
}

=item CalendarList()

get calendar list.

    my @Result = $CalendarObject->CalendarList(
        UserID     => 4,            # (optional) For permission check
        Permission => 'rw',         # (optional) Required permission (default ro)
        ValidID    => 1,            # (optional) Default 0.
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
            Color        => '#FF7700',
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
            Color        => '#BB00BB',
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

    if ( !IsArrayRefWithData($Data) ) {

        # create needed objects
        my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

        my $SQL = '
            SELECT id, group_id, name, color, create_time, create_by, change_time, change_by,
            valid_id
            FROM calendar
            WHERE 1=1
        ';
        my @Bind;

        if ( $Param{ValidID} ) {
            $SQL .= ' AND valid_id=? ';
            push @Bind, \$Param{ValidID};
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
            $Calendar{Color}        = $Row[3];
            $Calendar{CreateTime}   = $Row[4];
            $Calendar{CreateBy}     = $Row[5];
            $Calendar{ChangeTime}   = $Row[6];
            $Calendar{ChangeBy}     = $Row[7];
            $Calendar{ValidID}      = $Row[8];
            push @Result, \%Calendar;
        }

        # cache data
        $Kernel::OM->Get('Kernel::System::Cache')->Set(
            Type  => $CacheType,
            Key   => "$CacheKeyUser-$CacheKeyValid",
            Value => \@Result,
            TTL   => $Self->{CacheTTL},
        );

        $Data = \@Result;
    }

    if ( $Param{UserID} ) {

        # get user groups
        my %GroupList = $Kernel::OM->Get('Kernel::System::Group')->PermissionUserGet(
            UserID => $Param{UserID},
            Type   => $Param{Permission} || 'ro',
        );

        my @Result;

        for my $Item ( @{$Data} ) {
            if ( grep { $Item->{GroupID} == $_ } keys %GroupList ) {
                push @Result, $Item;
            }
        }

        $Data = \@Result;
    }

    return @{$Data};
}

=item CalendarUpdate()

updates an existing calendar.

    my $Success = $CalendarObject->CalendarUpdate(
        CalendarID       => 1,                   # (required) CalendarID
        GroupID          => 2,                   # (required) Calendar group
        CalendarName     => 'Meetings',          # (required) Personal calendar name
        Color            => '#FF9900',           # (required) Color in hexadecimal RGB notation
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
    for my $Needed (qw(CalendarID GroupID CalendarName Color UserID ValidID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    # check color
    if ( !( $Param{Color} =~ /#[A-Z0-9]{3,6}/i ) ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Color must be in hexadecimal RGB notation, eg. #FFFFFF.',
        );
        return;
    }

    # make it uppercase for the sake of consistency
    $Param{Color} = uc $Param{Color};

    my $SQL = '
        UPDATE calendar
        SET group_id=?, name=?, color=?, change_time=current_timestamp, change_by=?, valid_id=?
    ';

    my @Bind;
    push @Bind, \$Param{GroupID}, \$Param{CalendarName}, \$Param{Color}, \$Param{UserID},
        \$Param{ValidID};

    $SQL .= '
        WHERE id=?
    ';
    push @Bind, \$Param{CalendarID};

    # create db record
    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL  => $SQL,
        Bind => \@Bind,
    );

    # get cache object
    my $CacheObject = $Kernel::OM->Get('Kernel::System::Cache');

    # clear cache
    $CacheObject->CleanUp(
        Type => 'CalendarList',
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

    my %Calendar = $Self->CalendarGet(
        CalendarID => $Param{CalendarID},
    );

    my $Result = '';

    TYPE:
    for my $Type (qw(ro move_into create rw)) {

        my %GroupData = $Kernel::OM->Get('Kernel::System::Group')->PermissionUserGet(
            UserID => $Param{UserID},
            Type   => $Type,
        );

        if ( $GroupData{ $Calendar{GroupID} } ) {
            $Result = $Type;
        }
        else {
            last TYPE;
        }
    }

    return $Result;
}

=item GetAccessToken()

get access token for the calendar.

    my $Token = $CalendarObject->GetAccessToken(
        CalendarID => 1,              # (required) CalendarID
        UserLogin  => 'agent-1',      # (required) User login
    );

returns:
    $Token = 'rw';

=cut

sub GetAccessToken {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(CalendarID UserLogin)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    # create db object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # db query
    return if !$DBObject->Prepare(
        SQL   => 'SELECT salt_string FROM calendar WHERE id = ?',
        Bind  => [ \$Param{CalendarID} ],
        Limit => 1,
    );

    # fetch the result
    my $SaltString;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $SaltString = $Row[0];
    }

    return if !$SaltString;

    # calculate md5 sum
    my $String = "$Param{UserLogin}-$SaltString";
    my $MD5    = Digest::MD5->new()->add($String)->hexdigest();

    return $MD5;
}

=item GetRandomString()

returns random string of specified length from the set of ASCII characters.

    my $RandomString = $CalendarObject->GetRandomString(
        Length => 8,    # (required)
    );

returns:
    $RandomString = ']t%C`L9q';

=cut

sub GetRandomString {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(Length)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    return if !int $Param{Length};

    my @Characters = (
        '0' .. '9', 'a' .. 'z', '`', '~', '!', '@', '$', '%', '^', '&', '*', '(', ')', '-', '_',
        '=', '+', '[', ']', ';', ':', '\'', '"', '\\', '|', '.', '<', ',', '>', '?', '/'
    );

    my $Result;
    while ( $Param{Length}-- ) {
        $Result .= $Characters[ rand @Characters ];
    }

    return $Result;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
