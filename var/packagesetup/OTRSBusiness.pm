# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package var::packagesetup::OTRSBusiness;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::System::Cache',
    'Kernel::System::DB',
    'Kernel::System::DynamicField',
    'Kernel::System::DynamicField::Backend',
    'Kernel::System::Log',
    'Kernel::System::Ticket',
    'Kernel::System::SysConfig',
    'Kernel::System::User',
);

=head1 NAME

OTRSBusiness.pm - code to execute during package installation

=head1 SYNOPSIS

All functions

=head1 PUBLIC INTERFACE

=over 4

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

=item CodeInstall()

run the code install part

    my $Result = $CodeObject->CodeInstall();

=cut

sub CodeInstall {
    my ( $Self, %Param ) = @_;

    $Self->_AddChatArticleTypes();
    $Self->_SetBusinessSkin();

    return 1;
}

=item CodeUninstall()

run the code uninstall part

    my $Result = $CodeObject->CodeUninstall();

=cut

sub CodeUninstall {
    my ( $Self, %Param ) = @_;

    $Self->_DeleteDynamicFields();

    return 1;
}

=item CodeUninstallPost()

run the code uninstall part (after the files are removed)

    my $Result = $CodeObject->CodeUninstallPost();

=cut

sub CodeUninstallPost {
    my ( $Self, %Param ) = @_;

    # remove any modified setting
    $Kernel::OM->Get('Kernel::System::SysConfig')->CreateConfig();

    return 1;
}

#
# Check if new chat article types need to be added.
#   Only add article types if not already present. Do not remove on uninstall as articles might use it.
#
sub _AddChatArticleTypes {
    my ( $Self, %Param ) = @_;

    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    my %ArticleTypes = reverse $TicketObject->ArticleTypeList(
        Result => 'HASH',
    );

    ARTICLE_TYPE_NAME:
    for my $ArticleTypeName (qw(chat-internal chat-external)) {

        next ARTICLE_TYPE_NAME if $ArticleTypes{$ArticleTypeName};    # article type exists, do noting

        $Kernel::OM->Get('Kernel::System::DB')->Do(
            SQL => '
                INSERT INTO article_type ( name, valid_id, create_time, create_by, change_time, change_by )
                VALUES (?, 1, current_timestamp, 1, current_timestamp, 1)',
            Bind => [ \$ArticleTypeName ],
        );
    }

    $Kernel::OM->Get('Kernel::System::Cache')->CleanUp(
        Type => 'Ticket',
    );

    return 1;

}

#
# Set the business skin as default for all users who are using
# one of the default skins (default, slim, ivory, ivory-slim)
#
sub _SetBusinessSkin {
    my ( $Self, %Param ) = @_;

    my $UserObject = $Kernel::OM->Get('Kernel::System::User');

    my @DefaultSkins    = qw(default slim ivory ivory-slim);
    my %UserPreferences = $UserObject->SearchPreferences(
        Key => 'UserSkin',
    );

    USER:
    for my $UserID ( sort keys %UserPreferences ) {
        if ( !grep { $_ eq $UserPreferences{$UserID} } @DefaultSkins ) {
            next USER;
        }

        # set business as chosen skin
        $UserObject->SetPreferences(
            Key    => 'UserSkin',
            Value  => 'business',
            UserID => $UserID,
        );
    }

    $Kernel::OM->Get('Kernel::System::Cache')->CleanUp(
        Type => 'User',
    );

    return 1;

}

#
# deletes the business specific dynamic fields
#
sub _DeleteDynamicFields {
    my ( $Self, %Param ) = @_;

    # get a list of all dynamic fields for ticket and article
    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $DynamicFieldList   = $DynamicFieldObject->DynamicFieldListGet(
        Valid      => 0,
        ObjectType => [ 'Ticket', 'Article' ],
    );

    # filter only dynamic fields added by OTRSBusiness
    my %OTRSBusinessDynamicFieldTypes = (
        ContactWithData => 1,
        Database        => 1,
    );

    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    DYNAMICFIELD:
    for my $DynamicFieldConfig ( @{$DynamicFieldList} ) {
        next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);
        next DYNAMICFIELD if !$OTRSBusinessDynamicFieldTypes{ $DynamicFieldConfig->{FieldType} };

        # remove data from the field
        my $ValuesDeleteSuccess = $DynamicFieldBackendObject->AllValuesDelete(
            DynamicFieldConfig => $DynamicFieldConfig,
            UserID             => 1,
        );

        if ( !$ValuesDeleteSuccess ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Values from dynamic field $DynamicFieldConfig->{Name} could not be deleted!",
            );
        }

        my $Success = $DynamicFieldObject->DynamicFieldDelete(
            ID      => $DynamicFieldConfig->{ID},
            UserID  => 1,
            Reorder => 1,
        );

        if ( !$Success ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Dynamic field $DynamicFieldConfig->{Name} could not be deleted!",
            );
        }
    }

    return 1;
}

#
# Set default permission level for old chats from OTRS 4. Otherwise agents cannot delete the chat any more.
#
sub CodeUpgradeFromLowerThan_5_0_4 {    ## no critic
    my ( $Self, %Param ) = @_;

    $Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL => "
            UPDATE chat_participant
            SET permission_level = 'Owner'
            WHERE permission_level IS NULL
                AND chatter_type = 'User'",
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
