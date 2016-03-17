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

our @ObjectDependencies = (
    'Kernel::System::DB',
    'Kernel::System::Log',
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

    return $Self;
}

=item CalendarCreate()

creates a new calendar for given user.

    my %Calendar = $CalendarObject->CalendarCreate(
        CalendarName    => 'Meetings',          # (required) Personal calendar name
        UserID          => 4,                   # (required) UserID
        ValidID         => 1,                   # (optional) Default is 1.
    );

returns Calendar hash if successful:
    %Calendar = (
        CalendarID   => 2,
        UserID       => 4,
        CalendarName => 'Meetings',
        CreateTime   => '2016-01-01 08:00:00',
        CreateBy     => 4,
        ChangeTime   => '2016-01-01 08:00:00',
        ChangeBy     => 4,
        ValidID      => 1,
    );

=cut

sub CalendarCreate {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(CalendarName UserID)) {
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
            (user_id, name, create_time, create_by, change_time, change_by, valid_id)
        VALUES (?, ?, current_timestamp, ?, current_timestamp, ?, ?)
    ';

    # create db record
    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL  => $SQL,
        Bind => [
            \$Param{UserID}, \$Param{CalendarName}, \$Param{UserID}, \$Param{CalendarName}, \$ValidID
        ],
    );

    %Calendar = $Self->CalendarGet(
        CalendarName => $Param{CalendarName},
        UserID       => $Param{UserID},
    );

    return %Calendar;
}

=item CalendarGet()

get calendar by name for given user.

    my %Calendar = $CalendarObject->CalendarGet(
        CalendarName    => 'Meetings',          # (required) Personal calendar name
        UserID          => 4,                   # (required) UserID
                                                # or
        CalendarID      => 4,                   # (required) CalendarID
    );

returns Calendar data:
    %Calendar = (
        CalendarID   => 2,
        UserID       => 3,
        CalendarName => 'Meetings',
        CreateTime   => '2016-01-01 08:00:00',
        CreateBy     => 3,
        ChangeTime   => '2016-01-01 08:00:00',
        ChangeBy     => 3,
        ValidID      => 1,
    );

=cut

sub CalendarGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{CalendarID} && ( !$Param{CalendarName} || !$Param{UserID} ) ) {

        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need CalendarID or CalendarName and UserID!"
        );
        return;
    }

    # create needed objects
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    my ( $SQL, @Bind );

    if ( $Param{CalendarID} ) {
        $SQL = '
            SELECT id, user_id, name, create_time, create_by, change_time, change_by, valid_id
            FROM calendar
            WHERE
                id=?
        ';
        push @Bind, \$Param{CalendarID};
    }
    else {
        $SQL = '
            SELECT id, user_id, name, create_time, create_by, change_time, change_by, valid_id
            FROM calendar
            WHERE
                name=? AND
                user_id=?
        ';
        push @Bind, ( \$Param{CalendarName}, \$Param{UserID} );
    }

    # db query
    return if !$DBObject->Prepare(
        SQL   => $SQL,
        Bind  => \@Bind,
        Limit => 1,
    );

    my %Calendar;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $Calendar{CalendarID}   = $Row[0];
        $Calendar{UserID}       = $Row[1];
        $Calendar{CalendarName} = $Row[2];
        $Calendar{CreateTime}   = $Row[3];
        $Calendar{CreateBy}     = $Row[4];
        $Calendar{ChangeTime}   = $Row[5];
        $Calendar{ChangeBy}     = $Row[6];
        $Calendar{ValidID}      = $Row[7];
    }

    return %Calendar;
}

=item CalendarList()

get calendar list.

    my @Result = $CalendarObject->CalendarList(
        UserID  => 4,               # (optional) Filter by User
        ValidID => 1,               # (optional) Default 1.
    );

returns:
    @Result = [
        {
            CalendarID   => 2,
            UserID       => 3,
            CalendarName => 'Meetings',
            CreateTime   => '2016-01-01 08:00:00',
            CreateBy     => 3,
            ChangeTime   => '2016-01-01 08:00:00',
            ChangeBy     => 3,
            ValidID      => 1,
        },
        {
            CalendarID   => 3,
            UserID       => 3,
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

    my $ValidID = defined $Param{ValidID} ? $Param{ValidID} : 1;

    # create needed objects
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    my $SQL = '
        SELECT id, user_id, name, create_time, create_by, change_time, change_by, valid_id
        FROM calendar
        WHERE valid_id=?
    ';
    my @Bind;
    push @Bind, \$ValidID;

    if ( $Param{UserID} ) {
        $SQL .= 'AND user_id=? ';
        push @Bind, \$Param{UserID};
    }

    # db query
    return if !$DBObject->Prepare(
        SQL  => $SQL,
        Bind => \@Bind,
    );

    my @Result;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        my %Calendar;
        $Calendar{CalendarID}   = $Row[0];
        $Calendar{UserID}       = $Row[1];
        $Calendar{CalendarName} = $Row[2];
        $Calendar{CreateTime}   = $Row[3];
        $Calendar{CreateBy}     = $Row[4];
        $Calendar{ChangeTime}   = $Row[5];
        $Calendar{ChangeBy}     = $Row[6];
        $Calendar{ValidID}      = $Row[7];
        push @Result, \%Calendar;
    }

    return @Result;
}

=item CalendarUpdate()

updates an existing calendar.

    my $Success = $CalendarObject->CalendarUpdate(
        CalendarID       => 1,                   # (required) CalendarID
        CalendarName     => 'Meetings',          # (required) Personal calendar name
        OwnerID          => 2,                   # (required) Calendar owner UserID
        UserID           => 4,                   # (required) UserID (who made update)
        ValidID          => 1,                   # (required) ValidID
    );

returns 1 if successful:

=cut

sub CalendarUpdate {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(CalendarID CalendarName UserID OwnerID ValidID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    my $SQL = '
        UPDATE calendar
        SET user_id=?, name=?, change_time=current_timestamp, change_by=?, valid_id=?
        WHERE CalendarID=?
    ';

    # create db record
    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL  => $SQL,
        Bind => [
            \$Param{OwnerID}, \$Param{CalendarName}, \$Param{UserID}, \$Param{CalendarID}, \$Param{ValidID}
        ],
    );

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
