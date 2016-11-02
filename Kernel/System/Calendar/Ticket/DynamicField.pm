# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Calendar::Ticket::DynamicField;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::System::Log',
    'Kernel::System::DynamicField',
    'Kernel::System::DynamicFieldValue',
    'Kernel::System::Ticket',
);

=head1 NAME

Kernel::System::Calendar::Ticket::DynamicField - DynamicField appointment type

=head1 SYNOPSIS

DynamicField ticket appointment type.

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object. Do not use it directly, instead use:

    use Kernel::System::ObjectManager;
    local $Kernel::OM = Kernel::System::ObjectManager->new();
    my $TicketDynamicFieldObject = $Kernel::OM->Get('Kernel::System::Calendar::Ticket::DynamicField');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

=item GetTime()

returns time value for dynamic field appointment type.

    my $StartTime = $TicketDynamicFieldObject->GetTime(
        Type     => 'DynamicField_TestDate',
        TicketID => 1,
    );

=cut

sub GetTime {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(Type TicketID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    # get ticket data incl. dynamic fields
    my %Ticket = $Kernel::OM->Get('Kernel::System::Ticket')->TicketGet(
        TicketID      => $Param{TicketID},
        DynamicFields => 1,
    );
    return if !$Ticket{ $Param{Type} };

    # check if we found a valid time value and return it
    if ( $Ticket{ $Param{Type} } =~ '\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}' ) {
        return $Ticket{ $Param{Type} };
    }

    return;
}

=item SetTime()

set ticket dynamic field value to supplied time value.

    my $Success = $TicketDynamicFieldObject->SetTime(
        Type     => 'DynamicField_TestDate',
        Value    => '2016-01-01 00:00:00'
        TicketID => 1,
    );

returns 1 if successful.

=cut

sub SetTime {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(Type Value TicketID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    # get dynamic field data
    my $DynamicFieldName = $Param{Type};
    $DynamicFieldName =~ s/^DynamicField_//;
    my $DynamicField = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldGet(
        Name => $DynamicFieldName,
    );
    return if !$DynamicField;

    # set dynamic field value
    my $Success = $Kernel::OM->Get('Kernel::System::DynamicFieldValue')->ValueSet(
        FieldID  => $DynamicField->{ID},
        ObjectID => $Param{TicketID},
        Value    => [
            {
                ValueDateTime => $Param{Value},
            },
        ],
        UserID => 1,
    );

    return $Success;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut