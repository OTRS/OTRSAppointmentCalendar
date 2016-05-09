# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentAppointmentEdit;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);
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

    my $Output;

    # get param object
    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');

    # get names of all parameters
    my @ParamNames = $ParamObject->GetParamNames();

    # get params
    my %GetParam;
    PARAMNAME:
    for my $Key (@ParamNames) {

        # skip the Action parameter, it's giving BuildDateSelection problems for some reason
        next PARAMNAME if $Key eq 'Action';

        $GetParam{$Key} = $ParamObject->GetParam( Param => $Key );
    }

    # get needed objects
    my $ConfigObject      = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject      = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $CalendarObject    = $Kernel::OM->Get('Kernel::System::Calendar');
    my $AppointmentObject = $Kernel::OM->Get('Kernel::System::Calendar::Appointment');
    my $PluginObject      = $Kernel::OM->Get('Kernel::System::Calendar::Plugin');

    my $JSON = $LayoutObject->JSONEncode( Data => [] );

    my %PermissionLevel = (
        'ro'        => 1,
        'move_into' => 2,
        'create'    => 3,
        'note'      => 4,
        'owner'     => 5,
        'priority'  => 6,
        'rw'        => 7,
    );

    my $Permissions = '';

    # challenge token check
    $LayoutObject->ChallengeTokenCheck();

    # ------------------------------------------------------------ #
    # edit mask
    # ------------------------------------------------------------ #
    if ( $Self->{Subaction} eq 'EditMask' ) {

        # get all user's valid calendars
        my $ValidID = $Kernel::OM->Get('Kernel::System::Valid')->ValidLookup(
            Valid => 'valid',
        );
        my @Calendars = $CalendarObject->CalendarList(
            UserID  => $Self->{UserID},
            ValidID => $ValidID,
        );

        # transform data for select box
        my @CalendarData = map {
            {
                Key   => $_->{CalendarID},
                Value => $_->{CalendarName},
            }
        } @Calendars;

        for my $Calendar (@CalendarData) {

            # check permissions
            my $CalendarPermission = $CalendarObject->CalendarPermissionGet(
                CalendarID => $Calendar->{Key},
                UserID     => $Self->{UserID},
            );

            if ( $PermissionLevel{$CalendarPermission} < 3 ) {

                # permissions < create
                $Calendar->{Disabled} = 1;
            }
        }

        # get user timezone offset
        my $Offset = $Self->_TimezoneOffsetGet();

        my %Appointment;
        if ( $GetParam{AppointmentID} ) {
            %Appointment = $AppointmentObject->AppointmentGet(
                AppointmentID => $GetParam{AppointmentID},
            );

            # check permissions
            $Permissions = $CalendarObject->CalendarPermissionGet(
                CalendarID => $Appointment{CalendarID},
                UserID     => $Self->{UserID},
            );

            $Appointment{TimezoneID} = $Appointment{TimezoneID} ? int $Appointment{TimezoneID} : 0;

            # get start time components
            my $StartTime = $Self->_SystemTimeGet(
                String => $Appointment{StartTime},
            );
            $StartTime -= $Appointment{TimezoneID} * 3600;

            $StartTime += $Offset * 3600;
            (
                my $S, $Appointment{StartMinute},
                $Appointment{StartHour}, $Appointment{StartDay}, $Appointment{StartMonth},
                $Appointment{StartYear}
            ) = $Self->_DateGet( SystemTime => $StartTime );

            # get end time components
            my $EndTime = $Self->_SystemTimeGet(
                String => $Appointment{EndTime},
            );
            $EndTime -= $Appointment{TimezoneID} * 3600;
            $EndTime += $Offset * 3600;
            (
                $S, $Appointment{EndMinute}, $Appointment{EndHour}, $Appointment{EndDay},
                $Appointment{EndMonth}, $Appointment{EndYear}
            ) = $Self->_DateGet( SystemTime => $EndTime );

            # get recurrence until components
            if ( $Appointment{RecurrenceUntil} ) {
                my $RecurrenceUntil = $Self->_SystemTimeGet(
                    String => $Appointment{RecurrenceUntil},
                );
                $RecurrenceUntil -= $Appointment{TimezoneID} * 3600;
                $RecurrenceUntil += $Offset * 3600;
                (
                    $S, $Appointment{RecurrenceUntilMinute}, $Appointment{RecurrenceUntilHour},
                    $Appointment{RecurrenceUntilDay}, $Appointment{RecurrenceUntilMonth},
                    $Appointment{RecurrenceUntilYear}
                ) = $Self->_DateGet( SystemTime => $RecurrenceUntil );
            }
        }

        # calendar selection
        $Param{CalendarIDStrg} = $LayoutObject->BuildSelection(
            Data         => \@CalendarData,
            SelectedID   => $Appointment{CalendarID} // $GetParam{CalendarID},
            Name         => 'CalendarID',
            Multiple     => 0,
            Class        => 'Modernize Validate_Required',
            PossibleNone => 0,
            Disabled     => $Permissions
                && ( $PermissionLevel{$Permissions} < 3 ) ? 1 : 0,    # disable if permissions are below create
        );

        # start date string
        $Param{StartDateString} = $LayoutObject->BuildDateSelection(
            %GetParam,
            %Appointment,
            Prefix             => 'Start',
            StartHour          => $Appointment{StartHour} // $GetParam{StartHour},
            StartMinute        => $Appointment{StartMinute} // $GetParam{StartMinute},
            Format             => 'DateInputFormatLong',
            ValidateDateBefore => 'End',
            Validate           => 1,
            YearPeriodPast     => 5,
            YearPeriodFuture   => 5,

            # we are calculating this locally
            OverrideTimeZone => 1,
            Disabled         => $Permissions
                && ( $PermissionLevel{$Permissions} < 2 ) ? 1 : 0,    # disable if permissions are below move_into
        );

        # end date string
        $Param{EndDateString} = $LayoutObject->BuildDateSelection(
            %GetParam,
            %Appointment,
            Prefix            => 'End',
            EndHour           => $Appointment{EndHour} // $GetParam{EndHour},
            EndMinute         => $Appointment{EndMinute} // $GetParam{EndMinute},
            Format            => 'DateInputFormatLong',
            ValidateDateAfter => 'Start',
            Validate          => 1,
            YearPeriodPast    => 5,
            YearPeriodFuture  => 5,

            # we are calculating this locally
            OverrideTimeZone => 1,
            Disabled         => $Permissions
                && ( $PermissionLevel{$Permissions} < 2 ) ? 1 : 0,    # disable if permissions are below move_into
        );

        # get main object
        my $MainObject = $Kernel::OM->Get('Kernel::System::Main');

        # check if team object is registered
        if ( $MainObject->Require( 'Kernel::System::Calendar::Team', Silent => 1 ) ) {

            my $ResourceIDs = $Appointment{ResourceID};
            if ( !$ResourceIDs ) {
                my @ResourceIDs = $ParamObject->GetArray( Param => 'ResourceID[]' );
                $ResourceIDs = \@ResourceIDs;
            }

            # get needed objects
            my $TeamObject = $Kernel::OM->Get('Kernel::System::Calendar::Team');
            my $UserObject = $Kernel::OM->Get('Kernel::System::User');

            # get allowed team list for current user
            my %TeamList = $TeamObject->AllowedTeamList(
                PreventEmpty => 1,
                UserID       => $Self->{UserID},
            );

            # team list string
            $Param{TeamListStrg} = $LayoutObject->BuildSelection(
                Data         => \%TeamList,
                SelectedID   => $Appointment{TeamID} // $GetParam{TeamList},
                Name         => 'TeamList',
                Multiple     => 0,
                Class        => 'Modernize',
                PossibleNone => 1,
                Disabled     => $Permissions
                    && ( $PermissionLevel{$Permissions} < 2 ) ? 1 : 0,    # disable if permissions are below move_into
            );

            # iterate through teams
            for my $TeamID ( sort keys %TeamList ) {

                # get list of team members
                my %TeamUserList = $TeamObject->TeamUserList(
                    TeamID => $TeamID,
                    UserID => $Self->{UserID},
                );

                # get user data
                for my $UserID ( sort keys %TeamUserList ) {
                    my %User = $UserObject->GetUserData(
                        UserID => $UserID,
                    );
                    $TeamUserList{$UserID} = "$User{UserFirstname} $User{UserLastname}",
                }

                # team user list string
                $Param{TeamUserLists}->{$TeamID} = $LayoutObject->BuildSelection(
                    Data         => \%TeamUserList,
                    SelectedID   => $ResourceIDs,
                    Name         => 'TeamUserList' . $TeamID,
                    Multiple     => 1,
                    Class        => 'Modernize',
                    PossibleNone => 1,
                    Disabled     => $Permissions
                        && ( $PermissionLevel{$Permissions} < 2 ) ? 1 : 0,  # disable if permissions are below move_into
                );
            }
        }

        # all day
        if (
            $GetParam{AllDay} ||
            ( $GetParam{AppointmentID} && $Appointment{AllDay} )
            )
        {
            $Param{AllDayChecked} = 'checked="checked"';
        }
        else {
            $Param{AllDayChecked} = '';
        }

        my $SelectedRecurrenceType = 0;

        if ( $Appointment{Recurring} ) {

            # from appointment
            if ( $Appointment{RecurrenceByDay} ) {
                if ( $Appointment{RecurrenceFrequency} % 7 ) {
                    $SelectedRecurrenceType = 'Daily';
                }
                else {
                    $SelectedRecurrenceType = 'Weekly';
                }
            }
            elsif ( $Appointment{RecurrenceByMonth} ) {
                $SelectedRecurrenceType = 'Monthly';
            }
            elsif ( $Appointment{RecurrenceByYear} ) {
                $SelectedRecurrenceType = 'Yearly';
            }

            # override from %GetParam
            if ( $GetParam{RecurrenceByDay} ) {
                if ( $GetParam{RecurrenceFrequency} % 7 ) {
                    $SelectedRecurrenceType = 'Daily';
                }
                else {
                    $SelectedRecurrenceType = 'Weekly';
                }
            }
            elsif ( $GetParam{RecurrenceByMonth} ) {
                $SelectedRecurrenceType = 'Monthly';
            }
            elsif ( $GetParam{RecurrenceByYear} ) {
                $SelectedRecurrenceType = 'Yearly';
            }
        }

        # recurrence frequency selection
        $Param{RecurrenceTypeString} = $LayoutObject->BuildSelection(
            Data => [
                {
                    Key   => '0',
                    Value => Translatable('None'),
                },
                {
                    Key   => 'Daily',
                    Value => Translatable('Every Day'),
                },
                {
                    Key   => 'Weekly',
                    Value => Translatable('Every Week'),
                },
                {
                    Key   => 'Monthly',
                    Value => Translatable('Every Month'),
                },
                {
                    Key   => 'Yearly',
                    Value => Translatable('Every Year'),
                },
            ],
            SelectedID   => $SelectedRecurrenceType,
            Name         => 'RecurrenceType',
            Multiple     => 0,
            Class        => 'Modernize',
            PossibleNone => 0,
            Disabled     => $Permissions
                && ( $PermissionLevel{$Permissions} < 2 ) ? 1 : 0,    # disable if permissions are below move_into
        );

        # recurrence limit string
        my $RecurrenceLimit = 1;
        if ( $Appointment{RecurrenceCount} ) {
            $RecurrenceLimit = 2;
        }
        $Param{RecurrenceLimitString} = $LayoutObject->BuildSelection(
            Data => [
                {
                    Key   => 1,
                    Value => Translatable('until ...'),
                },
                {
                    Key   => 2,
                    Value => Translatable('for ... time(s)'),
                },
            ],
            SelectedID   => $RecurrenceLimit,
            Name         => 'RecurrenceLimit',
            Multiple     => 0,
            Class        => 'Modernize',
            PossibleNone => 0,
            Disabled     => $Permissions
                && ( $PermissionLevel{$Permissions} < 2 ) ? 1 : 0,    # disable if permissions are below move_into
        );

        # get current and start time for difference
        my $SystemTime = $Self->_CurrentSystemTime();

        my $StartTime = $Self->_Date2SystemTime(
            Year   => $Appointment{StartYear}   // $GetParam{StartYear},
            Month  => $Appointment{StartMonth}  // $GetParam{StartMonth},
            Day    => $Appointment{StartDay}    // $GetParam{StartDay},
            Hour   => $Appointment{StartHour}   // $GetParam{StartHour},
            Minute => $Appointment{StartMinute} // $GetParam{StartMinute},
            Second => 0,
        );

        # recurrence until date string
        $Param{RecurrenceUntilString} = $LayoutObject->BuildDateSelection(
            %Appointment,
            %GetParam,
            Prefix            => 'RecurrenceUntil',
            Format            => 'DateInputFormat',
            DiffTime          => $StartTime - $SystemTime + 60 * 60 * 24 * 3,    # start +3 days
            ValidateDateAfter => 'Start',
            Validate          => 1,
            YearPeriodPast    => 5,
            YearPeriodFuture  => 5,

            # we are calculating this locally
            OverrideTimeZone => 1,
            Disabled         => $Permissions
                && ( $PermissionLevel{$Permissions} < 2 ) ? 1 : 0,    # disable if permissions are below move_into
        );

        # get plugin list
        my $PluginList = $PluginObject->PluginList();

        if ( $GetParam{AppointmentID} ) {

            for my $PluginKey ( sort keys %{$PluginList} ) {
                my $LinkList = $PluginObject->PluginLinkList(
                    AppointmentID => $GetParam{AppointmentID},
                    PluginKey     => $PluginKey,
                    UserID        => $Self->{UserID},
                );

                # only one link per plugin supported
                LINK:
                for my $LinkID ( sort keys %{$LinkList} ) {
                    $Param{PluginData}->{$PluginKey}->{Name}  = $PluginList->{$PluginKey};
                    $Param{PluginData}->{$PluginKey}->{Value} = $LinkList->{$LinkID};

                    delete $PluginList->{$PluginKey};

                    last LINK;
                }
            }
        }

        # plugin list string
        $Param{PluginListStrg} = $LayoutObject->BuildSelection(
            Data  => $PluginList,
            Name  => 'PluginList',
            Class => 'Modernize',
        );

        # html mask output
        $LayoutObject->Block(
            Name => 'EditMask',
            Data => {
                PermissionLevel => $PermissionLevel{$Permissions},
                %Param,
                %GetParam,
                %Appointment,
            },
        );

        my $Output .= $LayoutObject->Output(
            TemplateFile => 'AgentAppointmentEdit',
            Data         => {
                %Param,
                %GetParam,
                %Appointment,
            },
        );
        return $LayoutObject->Attachment(
            NoCache     => 1,
            ContentType => 'text/html',
            Charset     => $LayoutObject->{UserCharset},
            Content     => $Output,
            Type        => 'inline',
        );
    }

    # ------------------------------------------------------------ #
    # add/edit appointment
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'EditAppointment' ) {
        my %Appointment;
        if ( $GetParam{AppointmentID} ) {
            %Appointment = $AppointmentObject->AppointmentGet(
                AppointmentID => $GetParam{AppointmentID},
            );

            # check permissions
            $Permissions = $CalendarObject->CalendarPermissionGet(
                CalendarID => $Appointment{CalendarID},
                UserID     => $Self->{UserID},
            );

            my $RequiredPermission = 2;
            if ( $GetParam{CalendarID} && $GetParam{CalendarID} != $Appointment{CalendarID} ) {
                $RequiredPermission
                    = 3;    # in order to move appointment to another calendar, user needs "create" permission
            }

            if ( $PermissionLevel{$Permissions} < $RequiredPermission ) {

                # no permission

                # build JSON output
                $JSON = $LayoutObject->JSONEncode(
                    Data => {
                        Success => 0,
                        Error   => Translatable('No permission!'),
                    },
                );

                # send JSON response
                return $LayoutObject->Attachment(
                    ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
                    Content     => $JSON,
                    Type        => 'inline',
                    NoCache     => 1,
                );
            }
        }

        if ( $GetParam{AllDay} ) {
            $GetParam{StartTime} = sprintf(
                "%04d-%02d-%02d 00:00:00",
                $GetParam{StartYear}, $GetParam{StartMonth}, $GetParam{StartDay}
            );
            $GetParam{EndTime} = sprintf(
                "%04d-%02d-%02d 00:00:00",
                $GetParam{EndYear}, $GetParam{EndMonth}, $GetParam{EndDay}
            );
        }
        elsif ( $GetParam{Recurring} && $GetParam{UpdateType} && $GetParam{UpdateDelta} ) {

            my $StartTime = $Self->_SystemTimeGet(
                String => $Appointment{StartTime},
            );
            my $EndTime = $Self->_SystemTimeGet(
                String => $Appointment{EndTime},
            );

            # calculate new start/end times
            if ( $GetParam{UpdateType} eq 'StartTime' ) {
                $GetParam{StartTime} = $Self->_TimestampGet(
                    SystemTime => $StartTime + $GetParam{UpdateDelta},
                );
            }
            elsif ( $GetParam{UpdateType} eq 'EndTime' ) {
                $GetParam{EndTime} = $Self->_TimestampGet(
                    SystemTime => $EndTime + $GetParam{UpdateDelta},
                );
            }
            else {
                $GetParam{StartTime} = $Self->_TimestampGet(
                    SystemTime => $StartTime + $GetParam{UpdateDelta},
                );
                $GetParam{EndTime} = $Self->_TimestampGet(
                    SystemTime => $EndTime + $GetParam{UpdateDelta},
                );
            }
        }
        else {
            $GetParam{StartTime} = sprintf(
                "%04d-%02d-%02d %02d:%02d:00",
                $GetParam{StartYear}, $GetParam{StartMonth}, $GetParam{StartDay},
                $GetParam{StartHour}, $GetParam{StartMinute}
            );
            $GetParam{EndTime} = sprintf(
                "%04d-%02d-%02d %02d:%02d:00",
                $GetParam{EndYear}, $GetParam{EndMonth}, $GetParam{EndDay},
                $GetParam{EndHour}, $GetParam{EndMinute}
            );
        }

        # recurring appointment
        if ( $GetParam{Recurring} && $GetParam{RecurrenceType} ) {

            if ( $GetParam{RecurrenceType} eq 'Daily' ) {
                $GetParam{RecurrenceByDay}     = 1;
                $GetParam{RecurrenceFrequency} = 1;
            }
            elsif ( $GetParam{RecurrenceType} eq 'Weekly' ) {
                $GetParam{RecurrenceByDay}     = 1;
                $GetParam{RecurrenceFrequency} = 7;
            }
            elsif ( $GetParam{RecurrenceType} eq 'Monthly' ) {
                $GetParam{RecurrenceByMonth}   = 1;
                $GetParam{RecurrenceFrequency} = 1;
            }
            elsif ( $GetParam{RecurrenceType} eq 'Yearly' ) {
                $GetParam{RecurrenceByYear}    = 1;
                $GetParam{RecurrenceFrequency} = 1;
            }

            # until ...
            if (
                $GetParam{RecurrenceLimit} eq '1' &&
                $GetParam{RecurrenceUntilYear} &&
                $GetParam{RecurrenceUntilMonth} &&
                $GetParam{RecurrenceUntilDay}
                )
            {
                $GetParam{RecurrenceUntil} = sprintf(
                    "%04d-%02d-%02d 00:00:00",
                    $GetParam{RecurrenceUntilYear}, $GetParam{RecurrenceUntilMonth},
                    $GetParam{RecurrenceUntilDay}
                );
                $GetParam{RecurrenceCount} = undef;
            }

            # for ... time(s)
            elsif ( $GetParam{RecurrenceLimit} eq '2' ) {
                $GetParam{RecurrenceUntil} = undef;
            }
        }

        # team
        if ( $GetParam{TeamList} ) {
            $GetParam{TeamID} = $GetParam{TeamList};
        }
        else {
            $GetParam{TeamID} = undef;
        }

        # resources
        if ( $GetParam{ResourceID} ) {
            if ( ref $GetParam{ResourceID} ne 'ARRAY' ) {
                $GetParam{ResourceID} = [ $GetParam{ResourceID} ];
            }
        }

        my $Success;

        # reset empty parameters
        for my $Param ( sort keys %GetParam ) {
            if ( !$GetParam{$Param} ) {
                $GetParam{$Param} = undef;
            }
        }

        # set required parameters
        $GetParam{TimezoneID} = $Self->_TimezoneOffsetGet();
        $GetParam{UserID}     = $Self->{UserID};

        if (%Appointment) {
            $Success = $AppointmentObject->AppointmentUpdate(
                %Appointment,
                %GetParam,
            );
        }
        else {
            $Success = $AppointmentObject->AppointmentCreate(
                %GetParam,
            );
        }

        my $AppointmentID = $GetParam{AppointmentID} ? $GetParam{AppointmentID} : $Success;

        # plugins
        if ($AppointmentID) {

            # remove all existing links
            if ( $GetParam{AppointmentID} ) {
                my $Success = $PluginObject->PluginLinkDelete(
                    AppointmentID => $AppointmentID,
                    UserID        => $Self->{UserID},
                );

                $Kernel::OM->Get('Kernel::System::Log')->Log(
                    Priority => 'error',
                    Message  => Translatable('Links could not be deleted!'),
                ) if !$Success;
            }

            # get passed plugin parameters
            my @PluginParams = grep { $_ =~ /^Plugin_/ } keys %GetParam;

            for my $PluginParam (@PluginParams) {
                my $PluginKey = $PluginParam;
                $PluginKey =~ s/^Plugin_//;

                # execute plugin link method
                if ( $GetParam{$PluginParam} ) {
                    my $Link = $PluginObject->PluginLinkAdd(
                        AppointmentID => $AppointmentID,
                        PluginKey     => $PluginKey,
                        PluginData    => $GetParam{$PluginParam},
                        UserID        => $Self->{UserID},
                    );

                    $Kernel::OM->Get('Kernel::System::Log')->Log(
                        Priority => 'error',
                        Message  => Translatable('Link could not be created!'),
                    ) if !$Link;
                }
            }
        }

        # build JSON output
        $JSON = $LayoutObject->JSONEncode(
            Data => {
                Success => $Success ? 1 : 0,
                AppointmentID => $AppointmentID,
            },
        );
    }

    # ------------------------------------------------------------ #
    # delete mask
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'DeleteAppointment' ) {

        if ( $GetParam{AppointmentID} ) {

            my $Success = $PluginObject->PluginLinkDelete(
                AppointmentID => $GetParam{AppointmentID},
                UserID        => $Self->{UserID},
            ) || 0;

            my $Error = "";
            if ($Success) {
                $Success = $AppointmentObject->AppointmentDelete(
                    %GetParam,
                    UserID => $Self->{UserID},
                );
            }

            if ( !$Success ) {
                $Error = Translatable("No permissions!");
            }

            # build JSON output
            $JSON = $LayoutObject->JSONEncode(
                Data => {
                    Success       => $Success,
                    Error         => $Error,
                    AppointmentID => $GetParam{AppointmentID},
                },
            );
        }
    }

    # ------------------------------------------------------------ #
    # update preferences
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'UpdatePreferences' ) {

        if ( $GetParam{OverviewScreen} && $GetParam{CurrentView} ) {

            # set user preferences
            my $Success = $Kernel::OM->Get('Kernel::System::User')->SetPreferences(
                Key    => 'User' . $GetParam{OverviewScreen} . 'DefaultView',
                Value  => $GetParam{CurrentView},
                UserID => $Self->{UserID},
            );

            # build JSON output
            $JSON = $LayoutObject->JSONEncode(
                Data => {
                    Success => $Success,
                },
            );
        }
    }

    # send JSON response
    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $JSON,
        Type        => 'inline',
        NoCache     => 1,
    );
}

sub _SystemTimeGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw( String )) {
        if ( !defined $Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    # extract data
    $Param{String} =~ /(\d{4})-(\d{2})-(\d{2})\s(\d{2}):(\d{2}):(\d{2})$/;

    my %Data = (
        Year   => $1,
        Month  => $2,
        Day    => $3,
        Hour   => $4,
        Minute => $5,
        Second => $6,
    );

    # Create an object with a specific date and time:
    my $DateTimeObject = $Kernel::OM->Create(
        'Kernel::System::DateTime',
        ObjectParams => {
            %Data,

            # TimeZone => 'Europe/Berlin',        # optional, defaults to setting of SysConfig OTRSTimeZone
            }
    );

    # check system time
    return $DateTimeObject->ToEpoch();
}

sub _TimestampGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw( SystemTime )) {
        if ( !defined $Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    my $DateTimeObject = $Kernel::OM->Create(
        'Kernel::System::DateTime',
        ObjectParams => {
            Epoch => $Param{SystemTime},
            }
    );

    # get timestamp
    return $DateTimeObject->ToString();
}

sub _CurrentSystemTime {
    my ( $Self, %Param ) = @_;

    # Create an object with current date and time
    # within time zone set in SysConfig OTRSTimeZone:
    my $DateTimeObject = $Kernel::OM->Create(
        'Kernel::System::DateTime',
    );

    return $DateTimeObject->ToEpoch();
}

sub _DateGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw( SystemTime )) {
        if ( !defined $Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    my $DateTimeObject = $Kernel::OM->Create(
        'Kernel::System::DateTime',
        ObjectParams => {
            Epoch => $Param{SystemTime},
            }
    );

    my $Date = $DateTimeObject->Get();

    my @Result = (
        $Date->{Second}, $Date->{Minute}, $Date->{Hour},
        $Date->{Day}, $Date->{Month}, $Date->{Year}, $Date->{DayOfWeek}
    );

    return @Result;
}

sub _Date2SystemTime {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw( Year Month Day Hour Minute )) {
        if ( !defined $Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    my $DateTimeObject = $Kernel::OM->Create(
        'Kernel::System::DateTime',
        ObjectParams => {
            %Param,
            }
    );

    return $DateTimeObject->ToEpoch();
}

sub _TimezoneOffsetGet {
    my ( $Self, %Param ) = @_;

    # get user data
    my %User = $Kernel::OM->Get('Kernel::System::User')->GetUserData(
        UserID => $Self->{UserID},
    );

    my $DateTimeObject = $Kernel::OM->Create(
        'Kernel::System::DateTime',
    );
    my $TimeZoneByOffset = $DateTimeObject->TimeZoneByOffsetList();
    my $Offset           = 0;

    OFFSET:
    for my $OffsetValue ( sort keys %{$TimeZoneByOffset} ) {
        if ( grep { $_ eq $User{UserTimeZone} } @{ $TimeZoneByOffset->{$OffsetValue} } ) {
            $Offset = $OffsetValue;
            last OFFSET;
        }
    }

    return $Offset;
}

1;
