# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentAppointmentCalendar;

use strict;
use warnings;

use Kernel::Language qw(Translatable);
use Kernel::System::VariableCheck qw(:all);

our $ObjectManagerDisabled = 1;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # get needed objects
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    $LayoutObject->Block(
        Name => 'CalendarDiv',
        Data => {
            CalendarWidth => 100,
        },
    );

    my $TextDirection = $LayoutObject->{LanguageObject}->{TextDirection} || '';

    my $Output = $LayoutObject->Header();
    $Output .= $LayoutObject->NavigationBar();
    $Output .= $LayoutObject->Output(
        TemplateFile => 'AgentAppointmentCalendar',
        Data         => {
            FirstDay => $Kernel::OM->Get('Kernel::Config')->Get('CalendarWeekDayStart') || 0,
            IsRTLLanguage => ( $TextDirection eq 'rtl' ) ? 'true' : 'false',
            %Param,
        },
    );
    $Output .= $LayoutObject->Footer();
    return $Output;
}

1;
