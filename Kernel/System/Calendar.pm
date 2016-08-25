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
use MIME::Base64 ();

use Kernel::System::EventHandler;
use Kernel::Language qw(Translatable);
use Kernel::System::VariableCheck qw(:all);
use vars qw(@ISA);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Cache',
    'Kernel::System::Calendar::Appointment',
    'Kernel::System::Calendar::Helper',
    'Kernel::System::DynamicField',
    'Kernel::System::Encode',
    'Kernel::System::Group',
    'Kernel::System::DB',
    'Kernel::System::Log',
    'Kernel::System::Main',
    'Kernel::System::Storable',
    'Kernel::System::Ticket',
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

        TicketAppointments => [                 # (optional) Ticket appointments, array ref of hashes
            {
                StartDate => 'FirstResponse',
                EndDate   => 'Plus_5',
                QueueID   => [ 2 ],
                SearchParams => {
                    Title => 'This is a title',
                    Types => 'This is a type',
                },
            },
        ],

        ValidID => 1,                   # (optional) Default is 1.
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
    if ( !( $Param{Color} =~ /#[A-F0-9]{3,6}/i ) ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Color must be in hexadecimal RGB notation, eg. #FFFFFF.',
        );
        return;
    }

    # reset ticket appointments
    if ( !( scalar @{ $Param{TicketAppointments} // [] } ) ) {
        $Param{TicketAppointments} = undef;
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
    my $SaltString = $Kernel::OM->Get('Kernel::System::Main')->GenerateRandomString(
        Length => 64,
    );

    # serialize and encode ticket appointment data
    my $TicketAppointments;
    if ( $Param{TicketAppointments} ) {
        $TicketAppointments = $Kernel::OM->Get('Kernel::System::Storable')->Serialize(
            Data => $Param{TicketAppointments},
        );
        $Kernel::OM->Get('Kernel::System::Encode')->EncodeOutput($TicketAppointments);
        $TicketAppointments = MIME::Base64::encode_base64($TicketAppointments);
    }

    my $SQL = '
        INSERT INTO calendar
            (group_id, name, salt_string, color, ticket_appointments, create_time, create_by,
            change_time, change_by, valid_id)
        VALUES (?, ?, ?, ?, ?, current_timestamp, ?, current_timestamp, ?, ?)
    ';

    # create db record
    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL  => $SQL,
        Bind => [
            \$Param{GroupID}, \$Param{CalendarName}, \$SaltString, \$Param{Color},
            \$TicketAppointments, \$Param{UserID}, \$Param{UserID}, \$ValidID
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
        CalendarID         => 2,
        GroupID            => 3,
        CalendarName       => 'Meetings',
        Color              => '#FF7700',
        TicketAppointments => [
            {
                StartDate => 'FirstResponse',
                EndDate   => 'Plus_5',
                QueueID   => [ 2 ],
                SearchParams => {
                    Title => 'This is a title',
                    Types => 'This is a type',
                },
            },
        ],
        CreateTime => '2016-01-01 08:00:00',
        CreateBy   => 1,
        ChangeTime => '2016-01-01 08:00:00',
        ChangeBy   => 1,
        ValidID    => 1,
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
            SELECT id, group_id, name, color, ticket_appointments, create_time, create_by,
            change_time, change_by, valid_id
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

            # decode and deserialize ticket appointment data
            my $TicketAppointments;
            if ( $Row[4] ) {
                my $DecodedData = MIME::Base64::decode_base64( $Row[4] );
                $TicketAppointments = $Kernel::OM->Get('Kernel::System::Storable')->Deserialize(
                    Data => $DecodedData,
                );
                $TicketAppointments = undef if ref $TicketAppointments ne 'ARRAY';
            }

            $Calendar{CalendarID}         = $Row[0];
            $Calendar{GroupID}            = $Row[1];
            $Calendar{CalendarName}       = $Row[2];
            $Calendar{Color}              = $Row[3];
            $Calendar{TicketAppointments} = $TicketAppointments;
            $Calendar{CreateTime}         = $Row[5];
            $Calendar{CreateBy}           = $Row[6];
            $Calendar{ChangeTime}         = $Row[7];
            $Calendar{ChangeBy}           = $Row[8];
            $Calendar{ValidID}            = $Row[9];
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

        TicketAppointments => [                 # (optional) Ticket appointments, array ref of hashes
            {
                StartDate => 'FirstResponse',
                EndDate   => 'Plus_5',
                QueueID   => [ 2 ],
                SearchParams => {
                    Title => 'This is a title',
                    Types => 'This is a type',
                },
            },
        ],
    );

returns 1 if successful

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
    if ( !( $Param{Color} =~ /#[A-F0-9]{3,6}/i ) ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Color must be in hexadecimal RGB notation, eg. #FFFFFF.',
        );
        return;
    }

    # reset ticket appointments
    if ( !( scalar @{ $Param{TicketAppointments} // [] } ) ) {
        $Param{TicketAppointments} = undef;
    }

    # make it uppercase for the sake of consistency
    $Param{Color} = uc $Param{Color};

    # serialize and encode ticket appointment data
    my $TicketAppointments;
    if ( $Param{TicketAppointments} ) {
        $TicketAppointments = $Kernel::OM->Get('Kernel::System::Storable')->Serialize(
            Data => $Param{TicketAppointments},
        );
        $Kernel::OM->Get('Kernel::System::Encode')->EncodeOutput($TicketAppointments);
        $TicketAppointments = MIME::Base64::encode_base64($TicketAppointments);
    }

    my $SQL = '
        UPDATE calendar
        SET group_id=?, name=?, color=?, ticket_appointments=?, change_time=current_timestamp,
        change_by=?, valid_id=?
    ';

    my @Bind;
    push @Bind, \$Param{GroupID}, \$Param{CalendarName}, \$Param{Color}, \$TicketAppointments,
        \$Param{UserID}, \$Param{ValidID};

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

=item CalendarImport()

import a calendar

    my $Success = $CalendarObject->CalendarImport(
        Data => {
            CalendarData => {
                CalendarID   => 2,
                GroupID      => 3,
                CalendarName => 'Meetings',
                Color        => '#FF7700',
                ValidID      => 1,
            },
            AppointmentData => {
                {
                    AppointmentID       => 2,
                    ParentID            => 1,
                    CalendarID          => 1,
                    UniqueID            => '20160101T160000-71E386@localhost',
                    ...
                },
                ...
            },
        },
        OverwriteExistingEntities => 0,     # (optional) Overwrite existing calendar and appointments, default: 0
                                            # Calendar with same name will be overwritten
                                            # Appointments with same UniqueID in existing calendar will be overwritten
        UserID => 1,
    );

returns 1 if successful

=cut

sub CalendarImport {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(Data UserID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    return if !IsHashRefWithData( $Param{Data} );
    return if !IsHashRefWithData( $Param{Data}->{CalendarData} );

    # check for an existing calendar
    my %ExistingCalendar = $Self->CalendarGet(
        CalendarName => $Param{Data}->{CalendarData}->{CalendarName},
    );

    my $CalendarID;

    # create new calendar
    if ( !IsHashRefWithData( \%ExistingCalendar ) ) {
        my %Calendar = $Self->CalendarCreate(
            %{ $Param{Data}->{CalendarData} },
            UserID => $Param{UserID},
        );
        return if !$Calendar{CalendarID};

        $CalendarID = $Calendar{CalendarID};
    }

    # update existing calendar
    else {
        if ( $Param{OverwriteExistingEntities} ) {
            my $Success = $Self->CalendarUpdate(
                %{ $Param{Data}->{CalendarData} },
                CalendarID => $ExistingCalendar{CalendarID},
                UserID     => $Param{UserID},
            );
            return if !$Success;
        }

        $CalendarID = $ExistingCalendar{CalendarID};
    }

    # import appointments
    if ( $CalendarID && IsArrayRefWithData( $Param{Data}->{AppointmentData} ) ) {
        my $AppointmentObject = $Kernel::OM->Get('Kernel::System::Calendar::Appointment');
        my $AppointmentID;

        APPOINTMENT:
        for my $Appointment ( @{ $Param{Data}->{AppointmentData} } ) {

            # add to existing calendar
            $Appointment->{CalendarID} = $CalendarID;

            # create new appointment if NOT overwriting existing entities
            $Appointment->{UniqueID} = undef if !$Param{OverwriteExistingEntities};

            # skip adding automatic recurring occurences
            $Appointment->{RecurringRaw} = 1 if $Appointment->{Recurring};

            # set parent id to last appointment id
            $Appointment->{ParentID} = $AppointmentID if $Appointment->{ParentID};

            $AppointmentID = $AppointmentObject->AppointmentCreate(
                %{$Appointment},
                UserID => $Param{UserID},
            );
            return if !$AppointmentID;
        }
    }

    return 1;
}

=item CalendarExport()

export a calendar

    my %Data = $CalendarObject->CalendarExport(
        CalendarID => 2,
        UserID     => 1,
    }

returns calendar hash with data:

    %Data = (
        CalendarData => {
            CalendarID   => 2,
            GroupID      => 3,
            CalendarName => 'Meetings',
            Color        => '#FF7700',
            ValidID      => 1,
        },
        AppointmentData => (
            {
                AppointmentID       => 2,
                ParentID            => 1,
                CalendarID          => 1,
                UniqueID            => '20160101T160000-71E386@localhost',
                ...
            },
            ...
        ),
    );

=cut

sub CalendarExport {
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

    # get calendar data
    my %CalendarData = $Self->CalendarGet(
        CalendarID => $Param{CalendarID},
        UserID     => $Param{UserID},
    );
    return if !IsHashRefWithData( \%CalendarData );

    # get appointment object
    my $AppointmentObject = $Kernel::OM->Get('Kernel::System::Calendar::Appointment');

    # get list of appointments
    my @Appointments = $AppointmentObject->AppointmentList(
        CalendarID => $Param{CalendarID},
        Result     => 'ARRAY',
    );

    my @AppointmentData;

    APPOINTMENT:
    for my $AppointmentID (@Appointments) {
        my %Appointment = $AppointmentObject->AppointmentGet(
            AppointmentID => $AppointmentID,
        );
        next APPOINTMENT if !%Appointment;

        push @AppointmentData, \%Appointment;
    }

    my %Result = (
        CalendarData    => \%CalendarData,
        AppointmentData => \@AppointmentData,
    );

    return %Result;
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

=item TicketAppointments()

Handle the automatic ticket appointments for the ticket.

    my $Success = $CalendarObject->TicketAppointments(
        TicketID => 1,
    );

returns 1 if successful.

=cut

sub TicketAppointments {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{TicketID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need TicketID!',
        );
        return;
    }

    # get all valid calendars
    my @Calendars = $Self->CalendarList(
        ValidID => 1,
    );
    return if !@Calendars;

    # get config object
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # get ticket appointment types
    my $TicketAppointmentConfig = $ConfigObject->Get('AppointmentCalendar::TicketAppointmentType') // {};
    return if !$TicketAppointmentConfig;

    my %TicketAppointmentTypes;

    TYPE:
    for my $TypeKey ( sort keys %{$TicketAppointmentConfig} ) {
        next TYPE if !$TicketAppointmentConfig->{$TypeKey}->{Key};

        if ( $TypeKey =~ /DynamicField$/ ) {
            my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');

            # get list of all valid date and date/time dynamic fields
            my $DynamicFieldList = $DynamicFieldObject->DynamicFieldListGet(
                ObjectType => 'Ticket',
            );

            DYNAMICFIELD:
            for my $DynamicField ( @{$DynamicFieldList} ) {
                next DYNAMICFIELD if $DynamicField->{FieldType} ne 'Date' && $DynamicField->{FieldType} ne 'DateTime';

                my $Key = sprintf( $TicketAppointmentConfig->{$TypeKey}->{Key}, $DynamicField->{Name} );
                $TicketAppointmentTypes{$Key} = $TicketAppointmentConfig->{$TypeKey};
            }

            next TYPE;
        }

        $TicketAppointmentTypes{ $TicketAppointmentConfig->{$TypeKey}->{Key} } =
            $TicketAppointmentConfig->{$TypeKey};
    }

    # get ticket object
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    # go through all calendars with defined ticket appointments
    CALENDAR:
    for my $Calendar (@Calendars) {
        my %CalendarData = $Self->CalendarGet(
            CalendarID => $Calendar->{CalendarID},
        );
        next CALENDAR if !$CalendarData{TicketAppointments};

        TICKET_APPOINTMENTS:
        for my $TicketAppointments ( @{ $CalendarData{TicketAppointments} } ) {

            # check appointment types
            for my $Field (qw(StartDate EndDate)) {

                # allow special time presets for EndDate
                if ( $Field ne 'EndDate' && !( $TicketAppointments->{$Field} =~ /^Plus_/ ) ) {

                    # skip if ticket appointment type is invalid
                    if ( !$TicketAppointmentTypes{ $TicketAppointments->{$Field} } ) {
                        next TICKET_APPOINTMENTS;
                    }
                }
            }

            # check if ticket satisfies the search filter from the ticket appointment rule
            # pass all configured parameters to ticket search, including ticket id
            my $Filtered = $TicketObject->TicketSearch(
                Result   => 'COUNT',
                TicketID => $Param{TicketID},
                QueueIDs => $TicketAppointments->{QueueID},
                UserID   => 1,
                %{ $TicketAppointments->{SearchParam} // {} },
            );

            # ticket was found
            if ($Filtered) {

                # process ticket appointment rule
                $Self->TicketAppointmentProcess(
                    CalendarID => $Calendar->{CalendarID},
                    Config     => \%TicketAppointmentTypes,
                    Rule       => $TicketAppointments,
                    TicketID   => $Param{TicketID},
                );
            }

            # ticket was not found
            else {

                # remove any existing ticket appointment
                $Self->_TicketAppointmentDelete(
                    TicketID => $Param{TicketID},
                    RuleID   => $Param{RuleID},
                );
            }
        }
    }

    if ( $Kernel::OM->Get('Kernel::Config')->Get('Debug') ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'debug',
            Message  => "Processed ticket appointments for ticket: $Param{TicketID}",
        );
    }
}

=item TicketAppointmentProcess()

Process the ticket appointment rule and create, update or delete appointment if necessary.

    my $Success = $CalendarObject->TicketAppointmentProcess(
        CalendarID => 1,
        Config => {
            DynamicField_TestDate => {
                Module => 'Kernel::System::Calendar::Ticket::DynamicField',
            },
            ...
        },
        Rule => {
            StartDate => 'DynamicField_TestDate',
            EndDate   => 'Plus_5',
            QueueID   => [ 2 ],
            RuleID    => '9bb20ea035e7a9930652a9d82d00c725',
            SearchParams => {
                Title => 'Welcome*',
            },
        },
        TicketID => 1,
    );

returns 1 if successful.

=cut

sub TicketAppointmentProcess {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(CalendarID Config Rule TicketID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    return if !IsHashRefWithData( $Param{Config} );
    return if !IsHashRefWithData( $Param{Rule} );

    # get calendar helper object
    my $CalendarHelperObject = $Kernel::OM->Get('Kernel::System::Calendar::Helper');

    my $Error;
    my %AppointmentData;

    # get start and end time values
    for my $Field (qw(StartDate EndDate)) {
        my $Type = $Param{Rule}->{$Field};

        # appointment fields are named differently
        my $AppointmentField = $Field;
        $AppointmentField =~ s/Date$/Time/;

        # check if we are dealing with a registered type
        if ( $Param{Config}->{$Type} && $Param{Config}->{$Type}->{Module} ) {
            my $GenericModule = $Param{Config}->{$Type}->{Module};

            # get the time value via the module method
            if ( $Kernel::OM->Get('Kernel::System::Main')->Require($GenericModule) ) {
                $AppointmentData{$AppointmentField} = $GenericModule->new( %{$Self} )->GetTime(
                    Type     => $Type,
                    TicketID => $Param{TicketID},
                );
                $Error = 1 if !$AppointmentData{$AppointmentField};
            }
        }

        # time presets are valid only for end time and existing start time
        elsif ( $Field eq 'EndDate' && $AppointmentData{StartTime} ) {
            if ( $Type =~ /^Plus_([0-9]+)$/ ) {
                my $Preset = int $1;

                # get start time
                my $StartTime = $CalendarHelperObject->SystemTimeGet(
                    String => $AppointmentData{StartTime},
                );

                # calculate end time using preset value
                my $EndTime = $StartTime + 60 * $Preset;
                $AppointmentData{EndTime} = $CalendarHelperObject->TimestampGet(
                    SystemTime => $EndTime,
                );
            }
            else {
                $Error = 1;
                $Kernel::OM->Get('Kernel::System::Log')->Log(
                    Priority => 'error',
                    Message  => "Invalid time preset: $Type",
                );
            }
        }

        # unknown type
        else {
            $Error = 1;
        }
    }

    # prevent end time before start time
    if ( $AppointmentData{StartTime} && $AppointmentData{EndTime} ) {
        my $StartTime = $CalendarHelperObject->SystemTimeGet(
            String => $AppointmentData{StartTime},
        );
        my $EndTime = $CalendarHelperObject->SystemTimeGet(
            String => $AppointmentData{EndTime},
        );
        if ( $EndTime < $StartTime ) {
            $AppointmentData{EndTime} = $AppointmentData{StartTime};
        }
    }

    # get appointment title
    if ( !$Error ) {
        my $TicketHook        = $Kernel::OM->Get('Kernel::Config')->Get('Ticket::Hook');
        my $TicketHookDivider = $Kernel::OM->Get('Kernel::Config')->Get('Ticket::HookDivider');
        my %Ticket            = $Kernel::OM->Get('Kernel::System::Ticket')->TicketGet(
            TicketID      => $Param{TicketID},
            DynamicFields => 0,
            UserID        => 1,
        );
        $AppointmentData{Title} = "[$TicketHook$TicketHookDivider$Ticket{TicketNumber}] $Ticket{Title}";
    }

    my $Success;

    # check if ticket appointment already exists
    my $AppointmentID = $Self->_TicketAppointmentGet(
        TicketID => $Param{TicketID},
        RuleID   => $Param{Rule}->{RuleID},
    );

    # ticket appointment was found
    if ($AppointmentID) {

        # delete the ticket appointment, if error was raised
        if ($Error) {
            $Success = $Self->_TicketAppointmentDelete(
                AppointmentID => $AppointmentID,
                TicketID      => $Param{TicketID},
                RuleID        => $Param{Rule}->{RuleID},
            );
        }

        # update the ticket appointment, otherwise
        else {
            $Success = $Self->_TicketAppointmentUpdate(
                CalendarID    => $Param{CalendarID},
                AppointmentID => $AppointmentID,
                TicketID      => $Param{TicketID},
                RuleID        => $Param{Rule}->{RuleID},
                %AppointmentData,
            );
        }
    }

    # create ticket appointment if not found
    elsif ( !$Error ) {
        $Success = $Self->_TicketAppointmentCreate(
            CalendarID => $Param{CalendarID},
            TicketID   => $Param{TicketID},
            RuleID     => $Param{Rule}->{RuleID},
            %AppointmentData,
        );
    }

    return $Success;
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

=item GetTextColor()

returns best text color for supplied background, based on luminosity difference algorithm.

    my $BestTextColor = $CalendarObject->GetTextColor(
        Background => '#FFF',    # (required) must be in valid hexadecimal RGB notation
    );

returns:
    $BestTextColor = '#000';

=cut

sub GetTextColor {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(Background)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    # check color
    if ( !( $Param{Background} =~ /#[A-F0-9]{3,6}/i ) ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Background must be in hexadecimal RGB notation, eg. #FFFFFF.',
        );
        return;
    }

    # check if value is cached
    my $Data = $Kernel::OM->Get('Kernel::System::Cache')->Get(
        Type => $Self->{CacheType} . 'GetTextColor',
        Key  => $Param{Background},
    );
    return $Data if $Data;

    # get RGB values
    my @BackgroundColor;
    my $RGBHex = substr( $Param{Background}, 1 );

    # six character hexadecimal string (eg. #FFFFFF)
    if ( length $RGBHex == 6 ) {
        $BackgroundColor[0] = hex substr( $RGBHex, 0, 2 );
        $BackgroundColor[1] = hex substr( $RGBHex, 2, 2 );
        $BackgroundColor[2] = hex substr( $RGBHex, 4, 2 );
    }

    # three character hexadecimal string (eg. #FFF)
    elsif ( length $RGBHex == 3 ) {
        $BackgroundColor[0] = hex( substr( $RGBHex, 0, 1 ) . substr( $RGBHex, 0, 1 ) );
        $BackgroundColor[1] = hex( substr( $RGBHex, 1, 1 ) . substr( $RGBHex, 1, 1 ) );
        $BackgroundColor[2] = hex( substr( $RGBHex, 2, 1 ) . substr( $RGBHex, 1, 1 ) );
    }

    # invalid hexadecimal string
    else {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Background must be in valid 3 or 6 character hexadecimal RGB notation, eg. #FFF or #FFFFFF.',
        );
        return;
    }

    # predefined text colors
    my %TextColors = (
        White => [ '255', '255', '255' ],
        Gray  => [ '128', '128', '128' ],
        Black => [ '0',   '0',   '0' ],
    );

    # calculate background luminosity
    my $BackgroundLum =
        0.2126 * ( $BackgroundColor[0] / 255**2.2 ) +
        0.7152 * ( $BackgroundColor[1] / 255**2.2 ) +
        0.0722 * ( $BackgroundColor[2] / 255**2.2 );

    # calculate luminosity difference
    my %LumDiff;
    for my $TextColor ( sort keys %TextColors ) {
        my $TextLum =
            0.2126 * ( $TextColors{$TextColor}->[0] / 255**2.2 ) +
            0.7152 * ( $TextColors{$TextColor}->[1] / 255**2.2 ) +
            0.0722 * ( $TextColors{$TextColor}->[2] / 255**2.2 );

        if ( $BackgroundLum > $TextLum ) {
            $LumDiff{$TextColor} = ( $BackgroundLum + 0.05 ) / ( $TextLum + 0.05 );
        }
        else {
            $LumDiff{$TextColor} = ( $TextLum + 0.05 ) / ( $BackgroundLum + 0.05 );
        }
    }

    # get maximum luminosity difference
    my ($MaxLumDiff) = sort { $b <=> $a } values %LumDiff;
    return if !$MaxLumDiff;

    # identify best suited color
    my ($BestTextColor) = grep { $LumDiff{$_} eq $MaxLumDiff } keys %LumDiff;
    return if !$BestTextColor;

    # convert to hex string
    my $TextColor = sprintf(
        '#%X%X%X',
        $TextColors{$BestTextColor}->[0],
        $TextColors{$BestTextColor}->[1],
        $TextColors{$BestTextColor}->[2],
    );

    # cache
    $Kernel::OM->Get('Kernel::System::Cache')->Set(
        Type  => $Self->{CacheType} . 'GetTextColor',
        Key   => $Param{Background},
        Value => $TextColor,
        TTL   => $Self->{CacheTTL},
    );

    return $TextColor;
}

=begin Internal:

=item _TicketAppointmentGet()

get ticket appointment id if exists.

    my $AppointmentID = $CalendarObject->_TicketAppointmentGet(
        TicketID => 1,
        RuleID   => '9bb20ea035e7a9930652a9d82d00c725',
    );

returns appointment ID if successful.

=cut

sub _TicketAppointmentGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(TicketID RuleID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # db query
    return if !$DBObject->Prepare(
        SQL => '
            SELECT appointment_id
            FROM calendar_appointment_ticket
            WHERE ticket_id = ? AND rule_id = ?
        ',
        Bind  => [ \$Param{TicketID}, \$Param{RuleID}, ],
        Limit => 1,
    );

    my $AppointmentID;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $AppointmentID = $Row[0],
    }

    return $AppointmentID;
}

=item _TicketAppointmentCreate()

create ticket appointment.

    my $Success = $CalendarObject->_TicketAppointmentCreate(
        CalendarID => 1,
        TicketID   => 1,
        RuleID     => '9bb20ea035e7a9930652a9d82d00c725',
        Title      => '[Ticket#20160823810000010] Some Ticket Title',
        StartTime  => '2016-08-23 00:00:00',
        EndTime    => '2016-08-24 00:00:00',
    );

returns 1 if successful.

=cut

sub _TicketAppointmentCreate {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(CalendarID TicketID RuleID Title StartTime EndTime)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    # create appointment
    my $AppointmentID = $Kernel::OM->Get('Kernel::System::Calendar::Appointment')->AppointmentCreate(
        CalendarID => $Param{CalendarID},
        Title      => $Param{Title},
        StartTime  => $Param{StartTime},
        EndTime    => $Param{EndTime},
        UserID     => 1,
    );
    return if !$AppointmentID;

    # save the relation in database
    return $Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL => '
            INSERT INTO calendar_appointment_ticket
                (ticket_id, appointment_id, rule_id)
            VALUES (?, ?, ?)
        ',
        Bind => [ \$Param{TicketID}, \$AppointmentID, \$Param{RuleID}, ],
    );
}

=item _TicketAppointmentUpdate()

update ticket appointment.

    my $Success = $CalendarObject->_TicketAppointmentUpdate(
        AppointmentID => 1,
        TicketID      => 1,
        RuleID        => '9bb20ea035e7a9930652a9d82d00c725',
        Title         => '[Ticket#20160823810000010] Some Ticket Title',
        StartTime     => '2016-08-23 00:00:00',
        EndTime       => '2016-08-24 00:00:00',
    );

returns 1 if successful.

=cut

sub _TicketAppointmentUpdate {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(AppointmentID TicketID RuleID Title StartTime EndTime)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    # get appointment object
    my $AppointmentObject = $Kernel::OM->Get('Kernel::System::Calendar::Appointment');

    # get current ticket appointment data
    my %Appointment = $AppointmentObject->AppointmentGet(
        AppointmentID => $Param{AppointmentID},
    );

    # ticket appointment does not exist
    if ( !$Appointment{AppointmentID} ) {

        # remove the relation as well
        $Self->_TicketAppointmentDelete(
            %Param,
        );

        # create new ticket appointment
        return $Self->_TicketAppointmentCreate(
            %Param,
        );
    }

    # update ticket appointment
    return $AppointmentObject->AppointmentUpdate(
        %Appointment,
        Title     => $Param{Title},
        StartTime => $Param{StartTime},
        EndTime   => $Param{EndTime},
        UserID    => 1,
    );
}

=item _TicketAppointmentDelete()

delete ticket appointment(s).

    my $Success = $CalendarObject->_TicketAppointmentDelete(
        TicketID      => 1,
        RuleID        => '9bb20ea035e7a9930652a9d82d00c725',
        AppointmentID => 1,     # (optional) Appointment ID is known
    );

returns 1 if successful.

=cut

sub _TicketAppointmentDelete {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(TicketID RuleID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    # remove the relation(s) from database
    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL => '
            DELETE FROM calendar_appointment_ticket
            WHERE ticket_id = ? AND rule_id = ?
        ',
        Bind  => [ \$Param{TicketID}, \$Param{RuleID}, ],
        Limit => 1,
    );

    # appointment is known
    if ( $Param{AppointmentID} ) {

        # get appointment object
        my $AppointmentObject = $Kernel::OM->Get('Kernel::System::Calendar::Appointment');

        # check if appointment exists
        return if !$AppointmentObject->AppointmentGet(
            AppointmentID => $Param{AppointmentID},
        );

        # delete the appointment
        return $AppointmentObject->AppointmentDelete(
            AppointmentID => $Param{AppointmentID},
            UserID        => 1,
        );
    }

    return 1;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
