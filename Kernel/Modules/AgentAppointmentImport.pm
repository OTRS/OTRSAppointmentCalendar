# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentAppointmentImport;

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

    if ( $Self->{Subaction} eq 'Import' ) {

        my $FormID = $ParamObject->GetParam( Param => 'FormID' ) || '';

        return $LayoutObject->FatalError() if !$FormID;

        my %UploadStuff = $ParamObject->GetUploadAll(
            Param => "FileUpload",
        );

        my $UploadCacheObject = $Kernel::OM->Get('Kernel::System::Web::UploadCache');

        my $UpdateExisting = $ParamObject->GetParam( Param => 'UpdateExistingAppointments' ) || '';
        my $CalendarID = $ParamObject->GetParam( Param => 'CalendarID' ) || '';

        my %Errors;

        if ( !$CalendarID ) {
            $Errors{CalendarIDInvalid} = 'ServerError';
        }

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

        if (%Errors) {
            return $Self->_Overview(
                %Errors,
                CalendarID => $CalendarID,
            );
        }

        my %Calendar;

        if ($CalendarID) {
            %Calendar = $CalendarObject->CalendarGet(
                CalendarID => $CalendarID,
                UserID     => $Self->{UserID},
            );
        }

        # check calendar permissions
        if ( !%Calendar ) {

            # no permissions
            return $LayoutObject->FatalError(
                Message =>
                    $LayoutObject->{LanguageObject}->Translate('No permissions'),
            );
        }

        # permissions check
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

        my $Count = $Kernel::OM->Get('Kernel::System::Calendar::Import::ICal')->Import(
            CalendarID     => $Calendar{CalendarID},
            ICal           => $UploadStuff{Content},
            UserID         => $Self->{UserID},
            UpdateExisting => $UpdateExisting,
        );

        if ( !$Count ) {
            return $LayoutObject->FatalError(
                Message =>
                    $LayoutObject->{LanguageObject}->Translate('System was unable to import file!'),
            );
        }

        # Import ok
        return $LayoutObject->Redirect(
            OP => "Action=AgentAppointmentCalendarManage;ImportAppointmentsSuccess=1;Count=${Count};Name="
                . $LayoutObject->LinkEncode( $Calendar{CalendarName} ),
        );

    }
    else {
        return $Self->_Overview();
    }

    return $Self->_Mask(%Param);
}

sub _Overview {
    my ( $Self, %Param ) = @_;

    # get needed objects
    my $LayoutObject   = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $CalendarObject = $Kernel::OM->Get('Kernel::System::Calendar');

    $Param{Title} = $LayoutObject->{LanguageObject}->Translate("Import Appointments");
    $Param{CalendarIDInvalid} //= '';

    my @CalendarList = $CalendarObject->CalendarList(
        UserID     => $Self->{UserID},
        Permission => 'create',
        ValidID    => 1,
    );

    my @CalendarData = map {
        {
            Key   => $_->{CalendarID},
            Value => $_->{CalendarName},
        }
    } sort { $a->{CalendarName} cmp $b->{CalendarName} } @CalendarList;

    $Param{Calendar} = $LayoutObject->BuildSelection(
        Data         => \@CalendarData,
        Name         => 'CalendarID',
        ID           => 'CalendarID',
        Class        => 'Modernize Validate_Required ' . $Param{CalendarIDInvalid},
        PossibleNone => 1,
        Title        => $LayoutObject->{LanguageObject}->Translate("Calendar"),
        SelectedID   => $Param{CalendarID} || '',
    );

    # get FormID from params
    $Param{FormID} = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'FormID' ) || '';

    # generate FormID if empty
    $Param{FormID} = $Kernel::OM->Get('Kernel::System::Web::UploadCache')->FormIDCreate() if !$Param{FormID};

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
        TemplateFile => 'AgentAppointmentImport',
        Data         => {
            %Param,
        },
    );
    $Output .= $LayoutObject->Footer();
    return $Output;
}

1;
