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

    my $CalendarID = $CalendarObject->CalendarCreate(
        Name    => 'Meetings',          # (required) Personal calendar name
        UserID  => 4,                   # (required) UserID
    );

returns CalendarID if successful:
    $CalendarID = 5;

=cut

sub CalendarCreate {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(Name UserID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    my %Calendar = $Self->CalendarGet(
        Name   => $Param{Name},
        UserID => $Param{UserID},
    );

    # If user already has Calendar with same name, return
    return '' if %Calendar;

    my $SQL = '
        INSERT INTO calendar
            (user_id, name, create_time, create_by, change_time, change_by)
        VALUES (?, ?, current_timestamp, ?, current_timestamp, ?)
    ';

    # create db record
    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL  => $SQL,
        Bind => [
            \$Param{UserID}, \$Param{Name}, \$Param{UserID}, \$Param{Name},
        ],
    );

    %Calendar = $Self->CalendarGet(
        Name   => $Param{Name},
        UserID => $Param{UserID},
    );

    return %Calendar;
}

=item CalendarGet()

get calendar by name for given user.

    my %Calendar = $CalendarObject->CalendarGet(
        Name    => 'Meetings',          # (required) Personal calendar name
        UserID  => 4,                   # (required) UserID
    );

returns Calendar data:
    %Calendar = (
        CalendarID   = 2,
        UserID       = 3,
        CalendarName = 'Meetings',
        CreateTime   = '2016-01-01 08:00:00',
        CreateBy     = 3,
        ChangeTime   = '2016-01-01 08:00:00',
        ChangeBy     = 3,
    );

=cut

sub CalendarGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(Name UserID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    # create needed objects
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    my $SQL = '
        SELECT id, user_id, name, create_time, create_by, change_time, change_by
        FROM calendar
        WHERE
            name=? AND
            user_id=?
    ';

    # db query
    return if !$DBObject->Prepare(
        SQL   => $SQL,
        Bind  => [ \$Param{Name}, \$Param{UserID} ],
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
    }

    return %Calendar;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
