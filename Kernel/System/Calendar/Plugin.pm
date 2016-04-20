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
    'Kernel::System::Log',
    'Kernel::System::Main',
    'Kernel::Config',
);

=head1 NAME

Kernel::System::Calendar::Plugin - Plugin lib

=head1 SYNOPSIS

Abstraction layer for additional fields in appointments.

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
    my $PluginConfig = $ConfigObject->Get("AppointmentCalendar::Module");

    $Self->{"PluginNames"}   = {};
    $Self->{"PluginModules"} = {};

    # load plugin modules
    PLUGIN:
    for my $PluginModule ( sort keys $PluginConfig ) {

        my $GenericModule = $PluginConfig->{$PluginModule}->{Module};
        next PLUGIN if !$GenericModule;

        if ( !$MainObject->Require($GenericModule) ) {
            $MainObject->Die("Can't load plugin module $GenericModule! $@");
        }

        $Self->{"PluginNames"}->{$PluginModule} = $PluginConfig->{$PluginModule}->{Name} // $GenericModule;
        $Self->{"PluginModules"}->{$PluginModule} = $GenericModule->new( %{$Self} );
    }

    return $Self;
}

=item PluginList()

list registered plugins

    my @Plugins = $PluginObject->PluginList();

=cut

sub PluginList {
    my ( $Self, %Param ) = @_;

    return $Self->{"PluginNames"};
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
