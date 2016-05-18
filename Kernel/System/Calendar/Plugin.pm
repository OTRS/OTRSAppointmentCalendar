# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Calendar::Plugin;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Log',
    'Kernel::System::Main',
    'Kernel::System::LinkObject',
);

=head1 NAME

Kernel::System::Calendar::Plugin - Plugin lib

=head1 SYNOPSIS

Abstraction layer for appointment plugins.

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object. Do not use it directly, instead use:

    use Kernel::System::ObjectManager;
    local $Kernel::OM = Kernel::System::ObjectManager->new();
    my $TeamObject = $Kernel::OM->Get('Kernel::System::Calendar::Plugin');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # get needed objects
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $MainObject   = $Kernel::OM->Get('Kernel::System::Main');

    # get registered plugin modules
    my $PluginConfig = $ConfigObject->Get("AppointmentCalendar::Plugin");

    # load plugin modules
    PLUGIN:
    for my $PluginKey ( sort keys %{$PluginConfig} ) {

        my $GenericModule = $PluginConfig->{$PluginKey}->{Module};
        next PLUGIN if !$GenericModule;

        if ( !$MainObject->Require($GenericModule) ) {
            $MainObject->Die("Can't load plugin module $GenericModule! $@");
        }

        $Self->{Plugins}->{$PluginKey}->{PluginName} = $PluginConfig->{$PluginKey}->{Name} // $GenericModule;
        $Self->{Plugins}->{$PluginKey}->{PluginModule} = $GenericModule->new( %{$Self} );

        my $PluginURL = $PluginConfig->{$PluginKey}->{URL};
        $PluginURL =~ s{<OTRS_CONFIG_(.+?)>}{$Kernel::OM->Get('Kernel::Config')->Get($1)}egx;
        $Self->{Plugins}->{$PluginKey}->{PluginURL} = $PluginURL;
    }

    return $Self;
}

=item PluginList()

returns the hash of registered plugins

    my %PluginList = $PluginObject->PluginList();

=cut

sub PluginList {
    my ( $Self, %Param ) = @_;

    my %PluginList = map {
        $_ => {
            PluginName => $Self->{Plugins}->{$_}->{PluginName},
            PluginURL  => $Self->{Plugins}->{$_}->{PluginURL},
            },
    } keys %{ $Self->{Plugins} };

    return \%PluginList;
}

=item PluginLinkAdd()

link appointment by plugin

    my $Success = $PluginObject->PluginLinkAdd(
        AppointmentID => 1,
        PluginKey     => '0100-TicketNumber',
        PluginData    => '20160101540000014',
        UserID        => 1,
    );

=cut

sub PluginLinkAdd {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(AppointmentID PluginKey PluginData UserID)) {
        if ( !$Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }
    my $Success = $Self->{Plugins}->{ $Param{PluginKey} }->{PluginModule}->LinkAdd(
        %Param,
    );

    return $Success;
}

=item PluginLinkList()

returns list of links for supplied appointment

    my $Success = $PluginObject->PluginLinkList(
        AppointmentID => 1,
        UserID        => 1,
    );

=cut

sub PluginLinkList {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(AppointmentID PluginKey UserID)) {
        if ( !$Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    $Param{PluginURL} = $Self->{Plugins}->{ $Param{PluginKey} }->{PluginURL},

        my $LinkList = $Self->{Plugins}->{ $Param{PluginKey} }->{PluginModule}->LinkList(
        %Param,
        );

    return $LinkList;
}

=item PluginLinkDelete()

removes all links for an appointment

    my $Success = $PluginObject->PluginLinkDelete(
        AppointmentID => 1,
        UserID        => 1,
    );

=cut

sub PluginLinkDelete {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(AppointmentID UserID)) {
        if ( !$Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    my $Success = $Kernel::OM->Get('Kernel::System::LinkObject')->LinkDeleteAll(
        Object => 'Appointment',
        Key    => $Param{AppointmentID},
        UserID => $Param{UserID},
    );

    if ( !$Success ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Unable to delete plugin links!"
        );
    }

    return $Success;
}

=item PluginSearch()

search for plugin objects

    my %ResultList = $PluginObject->PluginSearch(
        Search    => $Search,
        PluginKey => $PluginKey,
        UserID    => $Self->{UserID},
    );

=cut

sub PluginSearch {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(Search PluginKey UserID)) {
        if ( !$Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    my $ResultList = $Self->{Plugins}->{ $Param{PluginKey} }->{PluginModule}->Search(
        %Param,
    );

    return $ResultList;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
