# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::PublicCalendar;

use strict;
use warnings;

use MIME::Base64 qw();
use Kernel::Language qw(Translatable);

our $ObjectManagerDisabled = 1;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    # set UserID to root because in public interface there is no user
    $Self->{UserID} = 1;

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # needed objects
    # my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject   = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $CalendarObject = $Kernel::OM->Get('Kernel::System::Calendar');
    my $ParamObject    = $Kernel::OM->Get('Kernel::System::Web::Request');

    my %GetParam;

    # check needed parameters
    for my $Needed (qw(CalendarID UserID)) {
        $GetParam{$Needed} = $ParamObject->GetParam( Param => $Needed );
        if ( !$GetParam{$Needed} ) {
            return $LayoutObject->ErrorScreen(
                Message => Translatable("No $Needed !"),
                Comment => Translatable('Please contact the admin.'),
            );
        }
    }

    # get calendar
    my %Calendar = $CalendarObject->CalendarGet(
        CalendarID => $GetParam{CalendarID},
    );

    if ( !%Calendar ) {
        return $LayoutObject->ErrorScreen(
            Message => Translatable("No permission!"),
            Comment => Translatable('Please contact the admin.'),
        );
    }

    # get iCalendar string
    my $ICalString = $Kernel::OM->Get('Kernel::System::Calendar::Export::ICal')->Export(
        CalendarID   => $Calendar{CalendarID},
        UserID       => $Self->{UserID},
        UserTimeZone => $Self->{UserTimeZone} ? $Self->{UserTimeZone} : undef,
    );

    if ( !$ICalString ) {
        return $LayoutObject->ErrorScreen(
            Message => Translatable('There was an error exporting the calendar!'),
            Comment => Translatable('Please contact the admin.'),
        );
    }

    # prepare the file name
    my $Filename = $Kernel::OM->Get('Kernel::System::Main')->FilenameCleanUp(
        Filename => "$Calendar{CalendarName}.ics",
        Type     => 'Attachment',
    );

    # send iCal response
    return $LayoutObject->Attachment(
        ContentType => 'text/calendar',
        Charset     => $LayoutObject->{Charset},
        Content     => $ICalString || 'Test',
        Filename    => $Filename,
        NoCache     => 1,
    );

    # # start template output
    # $Output .= $LayoutObject->Output(
    #     TemplateFile => 'PublicCalendar',
    #     Data         => {

    #     },
    # );

    # # add footer
    # $Output .= $LayoutObject->CustomerFooter();

    # return $Output;
}

1;
