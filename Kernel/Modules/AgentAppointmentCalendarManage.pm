# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentAppointmentCalendarManage;

use strict;
use warnings;

use Kernel::Language qw(Translatable);

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
    my $LayoutObject   = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $CalendarObject = $Kernel::OM->Get('Kernel::System::Calendar');
    my $ParamObject    = $Kernel::OM->Get('Kernel::System::Web::Request');

    my %GetParam;

    if ( $Self->{Subaction} eq 'New' ) {

        my $GroupSelection = $Self->_GroupSelectionGet();
        my $ValidSelection = $Self->_ValidSelectionGet();

        $LayoutObject->Block(
            Name => 'CalendarEdit',
            Data => {
                GroupID   => $GroupSelection,
                ValidID   => $ValidSelection,
                Subaction => 'StoreNew',
            },
        );
        $Param{Title} = $LayoutObject->{LanguageObject}->Translate("Add new Calendar");
    }
    elsif ( $Self->{Subaction} eq 'StoreNew' ) {

        # get data
        for my $Param (qw(CalendarName GroupID ValidID)) {
            $GetParam{$Param} = $ParamObject->GetParam( Param => $Param ) || '';
        }

        my %Error;

        # check name
        if ( !$GetParam{CalendarName} ) {
            $Error{'CalendarNameInvalid'} = 'ServerError';
        }
        else {

            # check if there is a calendar with same name
            my %Calendar = $CalendarObject->CalendarGet(
                CalendarName => $GetParam{CalendarName},
            );

            if (%Calendar) {
                $Error{CalendarNameInvalid} = "ServerError";
                $Error{CalendarNameExists}  = 1;
            }
        }

        if (%Error) {

            # eet title
            $Param{Title} = $LayoutObject->{LanguageObject}->Translate("Add new Calendar");

            # get selections
            my $GroupSelection = $Self->_GroupSelectionGet(%GetParam);
            my $ValidSelection = $Self->_ValidSelectionGet(%GetParam);

            $LayoutObject->Block(
                Name => 'CalendarEdit',
                Data => {
                    %Error,
                    %GetParam,
                    GroupID   => $GroupSelection,
                    ValidID   => $ValidSelection,
                    Subaction => 'StoreNew',
                },
            );
            return $Self->_Mask(%Param);
        }

        # create calendar
        my %Calendar = $CalendarObject->CalendarCreate(
            %GetParam,
            UserID => $Self->{UserID},
        );

        if ( !%Calendar ) {
            return $LayoutObject->ErrorScreen(
                Message => Translatable('System was unable to create Calendar!'),
                Comment => Translatable('Please contact the admin.'),
            );
        }

        # redirect
        return $LayoutObject->Redirect(
            OP => "Action=AgentAppointmentCalendarManage",
        );
    }
    elsif ( $Self->{Subaction} eq 'Edit' ) {

        # get data
        my %GetParam;
        $GetParam{CalendarID} = $ParamObject->GetParam( Param => 'CalendarID' ) || '';

        if ( !$GetParam{CalendarID} ) {
            return $LayoutObject->ErrorScreen(
                Message => Translatable('No CalendarID!'),
                Comment => Translatable('Please contact the admin.'),
            );
        }

        # get calendar data
        my %Calendar = $CalendarObject->CalendarGet(
            CalendarID => $GetParam{CalendarID},
            UserID     => $Self->{UserID},
        );

        if ( !%Calendar ) {

            # fake message
            return $LayoutObject->ErrorScreen(
                Message => Translatable('You have no access to this calendar!'),
                Comment => Translatable('Please contact the admin.'),
            );
        }

        # get selections
        my $GroupSelection = $Self->_GroupSelectionGet(%Calendar);
        my $ValidSelection = $Self->_ValidSelectionGet(%Calendar);

        $LayoutObject->Block(
            Name => 'CalendarEdit',
            Data => {
                %Calendar,
                GroupID   => $GroupSelection,
                ValidID   => $ValidSelection,
                Subaction => 'Update',
            },
        );

        # set title
        $Param{Title} = $LayoutObject->{LanguageObject}->Translate("Edit Calendar");
    }
    elsif ( $Self->{Subaction} eq 'Update' ) {

        # get data
        for my $Param (qw(CalendarID CalendarName GroupID ValidID)) {
            $GetParam{$Param} = $ParamObject->GetParam( Param => $Param ) || '';
        }

        my %Error;

        # check needed stuff
        for my $Needed (qw(CalendarID CalendarName GroupID)) {
            if ( !$GetParam{$Needed} ) {
                $Error{ $Needed . 'Invalid' } = 'ServerError';
                $Param{Title} = $LayoutObject->{LanguageObject}->Translate("Edit Calendar");

                return $Self->_Mask( %Param, %GetParam, %Error );
            }
        }

        # check if there is already a calendar with same name
        my %Calendar = $CalendarObject->CalendarGet(
            CalendarName => $GetParam{CalendarName},
            UserID       => $Self->{UserID},
        );

        if ( defined $Calendar{CalendarID} && $Calendar{CalendarID} != $GetParam{CalendarID} ) {
            $Error{CalendarNameInvalid} = "ServerError";
            $Error{CalendarNameExists}  = 1;
        }

        if (%Error) {

            # set title
            $Param{Title} = $LayoutObject->{LanguageObject}->Translate("Edit Calendar");

            # get selections
            my $GroupSelection = $Self->_GroupSelectionGet(%GetParam);
            my $ValidSelection = $Self->_ValidSelectionGet(%GetParam);

            $LayoutObject->Block(
                Name => 'CalendarEdit',
                Data => {
                    %Error,
                    %GetParam,
                    GroupID   => $GroupSelection,
                    ValidID   => $ValidSelection,
                    Subaction => 'Update',
                },
            );
            return $Self->_Mask(%Param);
        }

        # update calendar
        my $Success = $CalendarObject->CalendarUpdate(
            %GetParam,
            UserID => $Self->{UserID},
        );

        if ( !$Success ) {
            return $LayoutObject->ErrorScreen(
                Message => Translatable('Error updating the calendar!'),
                Comment => Translatable('Please contact the admin.'),
            );
        }

        # Redirect
        return $LayoutObject->Redirect(
            OP => "Action=AgentAppointmentCalendarManage",
        );

    }
    elsif ( $Self->{Subaction} eq 'Import' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        my $FormID      = "UploadForm";
        my %UploadStuff = $ParamObject->GetUploadAll(
            Param => 'FileUpload',
        );

        my $UploadCacheObject = $Kernel::OM->Get('Kernel::System::Web::UploadCache');

        my $UpdateExisting = $ParamObject->GetParam( Param => 'UpdateExistingCalendar' ) || '';

        my %Errors;

        # save file in upload cache
        if (%UploadStuff) {
            my $Added = $UploadCacheObject->FormIDAddFile(
                FormID => $FormID,
                %UploadStuff,
            );

            # if file got not added to storage
            # (e. g. because of 1 MB max_allowed_packet MySQL problem)
            if ( !$Added ) {
                return $LayoutObject->FatalError();
            }
        }

        # get content from upload cache
        else {
            my @AttachmentData = $UploadCacheObject->FormIDGetAllFilesData(
                FormID => $FormID,
            );
            if ( !@AttachmentData || ( $AttachmentData[0] && !%{ $AttachmentData[0] } ) ) {
                $Errors{FileUploadInvalid} = 'ServerError';
            }
            else {
                %UploadStuff = %{ $AttachmentData[0] };
            }
        }

        # check if empty
        if ( !$UploadStuff{Content} ) {
            $Errors{FileUploadInvalid} = "ServerError";
        }

        if ( !%Errors ) {
            my $CalendarName;

            # take name from .ics if available
            if ( $UploadStuff{Content} =~ /^NAME:(.*?)\s*?$/m ) {
                $CalendarName = $1;
            }

            # take name from file name
            else {
                $CalendarName = $UploadStuff{Filename};

                # remove extension
                $CalendarName = substr( $CalendarName, 0, rindex( $CalendarName, "." ) );
            }

            my %Calendar;

            %Calendar = $CalendarObject->CalendarGet(
                CalendarName => $CalendarName,
            );

            if ( !$UpdateExisting && %Calendar ) {

                # loop until Calendar name is not already used
                while (%Calendar) {
                    $CalendarName = $Self->_GenerateName(
                        Name => $CalendarName,
                    );

                    %Calendar = $CalendarObject->CalendarGet(
                        CalendarName => $CalendarName,
                    );
                }
            }

            # check if calendar exists
            if (%Calendar) {

                # Calendar with same name already exists  
                my $Permission = $CalendarObject->CalendarPermissionGet(
                    CalendarID => $Calendar{CalendarID},
                    UserID     => $Self->{UserID},
                );

                if ( $Permission ne 'create' && $Permission ne 'rw' ) {

                    # no permissions to import to the existing calendar
                    return $LayoutObject->FatalError(
                        Message =>
                            $LayoutObject->{LanguageObject}->Translate('No permissions'),
                    );
                }
            }
            else {
                my %GroupList = $Kernel::OM->Get('Kernel::System::Group')->PermissionUserGroupGet(
                    UserID => $Self->{UserID},
                    Type   => 'rw',
                );

                if ( !%GroupList ) {

                    # no permissions to create a new calendar
                    return $LayoutObject->FatalError(
                        Message =>
                            $LayoutObject->{LanguageObject}->Translate('No permissions to create a new calendar!'),
                    );
                }
                my $GroupID = ( keys %GroupList )[0];

                # create a new Calendar
                %Calendar = $CalendarObject->CalendarCreate(
                    CalendarName => $CalendarName,
                    GroupID      => $GroupID,
                    UserID       => $Self->{UserID},
                    ValidID      => 1,
                );

                if ( !%Calendar ) {
                    return $LayoutObject->FatalError(
                        Message =>
                            $LayoutObject->{LanguageObject}->Translate('System was unable to create a new calendar!'),
                    );
                }
            }

            my $Success = $Kernel::OM->Get('Kernel::System::Calendar::Import::ICal')->Import(
                CalendarID => $Calendar{CalendarID},
                ICal       => $UploadStuff{Content},
                UserID     => $Self->{UserID},
            );

            if ( !$Success ) {
                return $LayoutObject->FatalError(
                    Message =>
                        $LayoutObject->{LanguageObject}->Translate('System was unable to import file!'),
                );
            }

            # Import ok
            return $LayoutObject->Redirect(
                OP => "Action=AgentAppointmentCalendarManage;Subaction=ImportSucess;CalendarName=$CalendarName",
            );

        }
    }
    elsif ( $Self->{Subaction} eq 'ImportSucess' ) {
        $Param{Title} = $LayoutObject->{LanguageObject}->Translate("Import");

        my $CalendarName = $ParamObject->GetParam( Param => 'CalendarName' ) || '';

        $LayoutObject->Block(
            Name => 'ImportSuccess',
            Data => {
                CalendarName => $CalendarName,
                }
        );
    }
    else {

        # get all calendars user has RW access to
        my @Calendars = $CalendarObject->CalendarList(
            UserID     => $Self->{UserID},
            Permission => 'rw',
        );

        $LayoutObject->Block(
            Name => 'AddLink',
        );

        $LayoutObject->Block(
            Name => 'Import',
        );

        $LayoutObject->Block(
            Name => 'CalendarFilter',
        );

        $LayoutObject->Block(
            Name => 'Overview',
        );

        for my $Calendar (@Calendars) {

            # group name
            $Calendar->{Group} = $Kernel::OM->Get('Kernel::System::Group')->GroupLookup(
                GroupID => $Calendar->{GroupID},
            );

            # valid text
            $Calendar->{Valid} = $Kernel::OM->Get('Kernel::System::Valid')->ValidLookup(
                ValidID => $Calendar->{ValidID},
            );

            $LayoutObject->Block(
                Name => 'Calendar',
                Data => {
                    %{$Calendar},
                },
            );
        }

        $LayoutObject->Block(
            Name => 'CalendarNoDataRow',
        ) if scalar @Calendars == 0;

        $Param{Title}    = $LayoutObject->{LanguageObject}->Translate("Calendars");
        $Param{Overview} = 1;
    }

    return $Self->_Mask(%Param);
}

sub _Mask {
    my ( $Self, %Param ) = @_;

    # get needed objects
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # output page
    my $Output = $LayoutObject->Header();
    $Output .= $LayoutObject->NavigationBar();
    $Output .= $LayoutObject->Output(
        TemplateFile => 'AgentAppointmentCalendarManage',
        Data         => {
            %Param,
        },
    );
    $Output .= $LayoutObject->Footer();
    return $Output;
}

sub _GroupSelectionGet {
    my ( $Self, %Param ) = @_;

    # get needed objects
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # get list of groups where user has RW permissions
    my %GroupList = $Kernel::OM->Get('Kernel::System::Group')->PermissionUserGet(
        UserID => $Self->{UserID},
        Type   => 'rw',
    );

    my $GroupSelection = $LayoutObject->BuildSelection(
        Data       => \%GroupList,
        Name       => 'GroupID',
        SelectedID => $Param{GroupID} || '',
        Class      => 'Modernize Validate_Required',
    );

    return $GroupSelection;
}

sub _ValidSelectionGet {
    my ( $Self, %Param ) = @_;

    # get needed objects
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ValidObject  = $Kernel::OM->Get('Kernel::System::Valid');

    my %Valid          = $ValidObject->ValidList();
    my $ValidSelection = $LayoutObject->BuildSelection(
        Data  => \%Valid,
        Name  => 'ValidID',
        ID    => 'ValidID',
        Class => 'Modernize Validate_Required',

        SelectedID => $Param{ValidID} || 1,
        Title => Translatable("Valid"),
    );

    return $ValidSelection;
}

sub _GenerateName {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(Name)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    my $Result;

    # generate new name
    if ( $Param{Name} =~ /(\d+?)$/m ) {

        # name ends with number
        my $ID = int $1 + 1;

        $Result = $Param{Name};
        $Result =~ s{\d+$}{$ID};
    }
    else {
        $Result = $Param{Name} . " 1";
    }

    return $Result;
}

1;
