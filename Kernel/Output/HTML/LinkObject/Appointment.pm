# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::LinkObject::Appointment;

use strict;
use warnings;

use Kernel::Language qw(Translatable);
use Kernel::Output::HTML::Layout;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Log',
    'Kernel::System::Web::Request',
);

=head1 NAME

Kernel::Output::HTML::LinkObject::Appointment - layout backend module

=head1 SYNOPSIS

All layout functions of link object (appointment).

=over 4

=cut

=item new()

create an object

    $BackendObject = Kernel::Output::HTML::LinkObject::Appointment->new(
        UserLanguage => 'en',
        UserID       => 1,
    );

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # check needed objects
    for my $Needed (qw(UserLanguage UserID)) {
        $Self->{$Needed} = $Param{$Needed} || die "Got no $Needed!";
    }

    # create our own LayoutObject instance to avoid block data collisions with the main page
    $Self->{LayoutObject} = Kernel::Output::HTML::Layout->new( %{$Self} );

    # define needed variables
    $Self->{ObjectData} = {
        Object   => 'Appointment',
        Realname => 'Appointment',
    };

    return $Self;
}

=item TableCreateComplex()

return an array with the block data

Return

    %BlockData = (
        {
            Object    => 'Appointment',
            Blockname => 'Appointment',
            Headline  => [
                {
                    Content => 'Title',
                },
                {
                    Content => 'Description',
                    Width   => 200,
                },
                {
                    Content => 'Start Time',
                    Width   => 150,
                },
                {
                    Content => 'End Time',
                    Width   => 150,
                },
            ],
            ItemList => [
                [
                    {
                        Type      => 'Link',
                        Key       => $AppointmentID,
                        Content   => 'Appointment title',
                        MaxLength => 70,
                    },
                    {
                        Type      => 'Text',
                        Content   => 'Appointment description',
                        MaxLength => 100,
                    },
                    {
                        Type    => 'TimeLong',
                        Content => '2016-01-01 12:00:00',
                    },
                    {
                        Type    => 'TimeLong',
                        Content => '2016-01-01 13:00:00',
                    },
                ],
            ],
        },
    );

    @BlockData = $BackendObject->TableCreateComplex(
        ObjectLinkListWithData => $ObjectLinkListRef,
    );

=cut

sub TableCreateComplex {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{ObjectLinkListWithData} || ref $Param{ObjectLinkListWithData} ne 'HASH' ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => 'Need ObjectLinkListWithData!',
        );
        return;
    }

    # convert the list
    my %LinkList;
    for my $LinkType ( sort keys %{ $Param{ObjectLinkListWithData} } ) {

        # extract link type List
        my $LinkTypeList = $Param{ObjectLinkListWithData}->{$LinkType};

        for my $Direction ( sort keys %{$LinkTypeList} ) {

            # extract direction list
            my $DirectionList = $Param{ObjectLinkListWithData}->{$LinkType}->{$Direction};

            for my $AppointmentID ( sort keys %{$DirectionList} ) {

                $LinkList{$AppointmentID}->{Data} = $DirectionList->{$AppointmentID};
            }
        }
    }

    # create the item list
    my @ItemList;
    for my $AppointmentID (
        sort { lc $LinkList{$a}{Data}->{Title} cmp lc $LinkList{$b}{Data}->{Title} }
        keys %LinkList
        )
    {

        # extract appointment data
        my $Appointment = $LinkList{$AppointmentID}{Data};

        my @ItemColumns = (
            {
                Type    => 'Link',
                Key     => $AppointmentID,
                Content => $Appointment->{Title},
                Link    => $Self->{LayoutObject}->{Baselink}
                    . 'Action=AgentAppointmentCalendarOverview;AppointmentID='
                    . $AppointmentID,
                MaxLength => 70,
            },
            {
                Type      => 'Text',
                Content   => $Appointment->{Description},
                MaxLength => 100,
            },
            {
                Type    => 'TimeLong',
                Content => $Appointment->{StartTime},
            },
            {
                Type    => 'TimeLong',
                Content => $Appointment->{EndTime},
            },
        );

        push @ItemList, \@ItemColumns;
    }

    return if !@ItemList;

    # define the block data
    my %Block = (
        Object    => $Self->{ObjectData}->{Object},
        Blockname => $Self->{ObjectData}->{Realname},
        Headline  => [
            {
                Content => Translatable('Title'),
                Width   => 200,
            },
            {
                Content => Translatable('Description'),
            },
            {
                Content => Translatable('Start Time'),
                Width   => 150,
            },
            {
                Content => Translatable('End Time'),
                Width   => 150,
            },
        ],
        ItemList => \@ItemList,
    );

    return ( \%Block );
}

=item TableCreateSimple()

return a hash with the link output data

Return

    %LinkOutputData = (
        Normal::Source => {
            Appointment => [
                {
                    Type    => 'Link',
                    Content => 'A:1',
                    Title   => 'Title of appointment',
                },
            ],
        },
    );

    %LinkOutputData = $BackendObject->TableCreateSimple(
        ObjectLinkListWithData => $ObjectLinkListRef,
    );

=cut

sub TableCreateSimple {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{ObjectLinkListWithData} || ref $Param{ObjectLinkListWithData} ne 'HASH' ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need ObjectLinkListWithData!',
        );
        return;
    }

    my %LinkOutputData;
    for my $LinkType ( sort keys %{ $Param{ObjectLinkListWithData} } ) {

        # extract link type List
        my $LinkTypeList = $Param{ObjectLinkListWithData}->{$LinkType};

        for my $Direction ( sort keys %{$LinkTypeList} ) {

            # extract direction list
            my $DirectionList = $Param{ObjectLinkListWithData}->{$LinkType}->{$Direction};

            my @ItemList;
            for my $AppointmentID (
                sort {
                    lc $DirectionList->{$a}->{NameShort} cmp lc $DirectionList->{$b}->{NameShort}
                } keys %{$DirectionList}
                )
            {

                # extract appointment data
                my $Appointment = $DirectionList->{$AppointmentID};

                # define item data
                my %Item = (
                    Type    => 'Link',
                    Content => "A:$AppointmentID",
                    Title   => Translatable('Appointment'),
                    Link    => $Self->{LayoutObject}->{Baselink}
                        . 'Action=AgentAppointmentCalendarOverview;AppointmentID='
                        . $AppointmentID,
                    MaxLength => 20,
                );

                push @ItemList, \%Item;
            }

            # add item list to link output data
            $LinkOutputData{ $LinkType . '::' . $Direction }->{Appointment} = \@ItemList;
        }
    }

    return %LinkOutputData;
}

=item ContentStringCreate()

return a output string

    my $String = $LayoutObject->ContentStringCreate(
        ContentData => $HashRef,
    );

=cut

sub ContentStringCreate {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{ContentData} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need ContentData!'
        );
        return;
    }

    return;
}

=item SelectableObjectList()

return an array hash with selectable objects

Return

    @SelectableObjectList = (
        {
            Key   => 'Appointment',
            Value => 'Appointment',
        },
    );

    @SelectableObjectList = $BackendObject->SelectableObjectList(
        Selected => $Identifier,  # (optional)
    );

=cut

sub SelectableObjectList {
    my ( $Self, %Param ) = @_;

    my $Selected;
    if ( $Param{Selected} && $Param{Selected} eq $Self->{ObjectData}->{Object} ) {
        $Selected = 1;
    }

    # object select list
    my @ObjectSelectList = (
        {
            Key      => $Self->{ObjectData}->{Object},
            Value    => $Self->{ObjectData}->{Realname},
            Selected => $Selected,
        },
    );

    return @ObjectSelectList;
}

=item SearchOptionList()

return an array hash with search options

Return

    @SearchOptionList = (
        {
            Key       => 'CalendarName',
            Name      => 'Calendar Name',
            InputStrg => $FormString,
            FormData  => '1234',
        },
        {
            Key       => 'StartTime',
            Name      => 'Appointment Start Time',
            InputStrg => $FormString,
            FormData  => 'BlaBla',
        },
    );

    @SearchOptionList = $BackendObject->SearchOptionList(
        SubObject => 'Bla',  # (optional)
    );

=cut

sub SearchOptionList {
    my ( $Self, %Param ) = @_;

    my $ParamHook = $Kernel::OM->Get('Kernel::Config')->Get('Ticket::Hook') || 'Ticket#';

    # search option list
    my @SearchOptionList = (
        {
            Key  => 'CalendarName',
            Name => 'Calendar Name',
            Type => 'Text',
        },
        {
            Prefix => 'Start',
            Key    => 'StartTime',
            Name   => 'Start Time',
            Type   => 'TimeLong',
        },
        {
            Prefix => 'End',
            Key    => 'EndTime',
            Name   => 'End Time',
            Type   => 'TimeLong',
        },
    );

    # add formkey
    for my $Row (@SearchOptionList) {
        $Row->{FormKey} = 'SEARCH::' . $Row->{Key};
    }

    # add form data and input string
    ROW:
    for my $Row (@SearchOptionList) {

        next ROW if $Row->{Type} eq 'Hidden';

        # prepare text input fields
        if ( $Row->{Type} eq 'Text' ) {

            # get form data
            $Row->{FormData} = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => $Row->{FormKey} );

            # parse the input text block
            $Self->{LayoutObject}->Block(
                Name => 'InputText',
                Data => {
                    Key   => $Row->{FormKey},
                    Value => $Row->{FormData} || '',
                },
            );

            # add the input string
            $Row->{InputStrg} = $Self->{LayoutObject}->Output(
                TemplateFile => 'LinkObject',
            );

            next ROW;
        }

        # prepare date input fields
        if ( $Row->{Type} eq 'TimeLong' ) {

            # get form data
            my %FormData;
            for my $Param (qw(Year Month Day Hour Minute Optional)) {
                $FormData{ $Row->{Prefix} . $Param } = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam(
                    Param => $Row->{Prefix} . $Param
                );
            }

            my $DateStrg = $Self->{LayoutObject}->BuildDateSelection(
                %FormData,
                Prefix           => $Row->{Prefix},
                Format           => 'DateInputFormatLong',
                YearPeriodPast   => 5,
                YearPeriodFuture => 5,

                # add checkbox
                "$Row->{Prefix}Optional" => 1,

                # we are calculating this locally
                OverrideTimeZone => 1,
            );

            # parse the date block
            $Self->{LayoutObject}->Block(
                Name => 'TimeLong',
                Data => {
                    Content => $DateStrg,
                },
            );

            # add the input string
            $Row->{InputStrg} = $Self->{LayoutObject}->Output(
                TemplateFile => 'LinkObject',
            );

            next ROW;
        }
    }

    return @SearchOptionList;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (http://otrs.org/).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
