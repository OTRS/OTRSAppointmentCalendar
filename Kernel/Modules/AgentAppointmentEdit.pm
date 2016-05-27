# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentAppointmentEdit;

## nofilter(TidyAll::Plugin::OTRS::Migrations::OTRS6::TimeZoneOffset)

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

    my $Permissions = 'rw';

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
        my $Offset = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->TimezoneOffsetGet(
            UserID => $Self->{UserID},
        );

        # define year boundaries
        my ( %YearPeriodPast, %YearPeriodFuture );
        for my $Field (qw (Start End RecurrenceUntil)) {
            $YearPeriodPast{$Field} = $YearPeriodFuture{$Field} = 5;
        }

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

            $Appointment{TimezoneID} = $Appointment{TimezoneID} ? $Appointment{TimezoneID} : 0;

            # get start time components
            my $StartTime = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->SystemTimeGet(
                String => $Appointment{StartTime},
            );
            $StartTime -= $Appointment{TimezoneID} * 3600;

            $StartTime += $Offset * 3600;
            (
                my $S, $Appointment{StartMinute},
                $Appointment{StartHour}, $Appointment{StartDay}, $Appointment{StartMonth},
                $Appointment{StartYear}, $Appointment{StartWeekDay}
            ) = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->DateGet( SystemTime => $StartTime );

            # get end time components
            my $EndTime = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->SystemTimeGet(
                String => $Appointment{EndTime},
            );
            $EndTime -= $Appointment{TimezoneID} * 3600;
            $EndTime += $Offset * 3600;

            # end times for all day appointments are inclusive, subtract whole day
            if ( $Appointment{AllDay} ) {
                $EndTime -= 86400;
                if ( $EndTime < $StartTime ) {
                    $EndTime = $StartTime;
                }
            }

            (
                $S, $Appointment{EndMinute}, $Appointment{EndHour}, $Appointment{EndDay},
                $Appointment{EndMonth}, $Appointment{EndYear}
            ) = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->DateGet( SystemTime => $EndTime );

            # get recurrence until components
            if ( $Appointment{RecurrenceUntil} ) {
                my $RecurrenceUntil = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->SystemTimeGet(
                    String => $Appointment{RecurrenceUntil},
                );
                $RecurrenceUntil -= $Appointment{TimezoneID} * 3600;
                $RecurrenceUntil += $Offset * 3600;
                (
                    $S, $Appointment{RecurrenceUntilMinute}, $Appointment{RecurrenceUntilHour},
                    $Appointment{RecurrenceUntilDay}, $Appointment{RecurrenceUntilMonth},
                    $Appointment{RecurrenceUntilYear}
                ) = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->DateGet( SystemTime => $RecurrenceUntil );
            }

            # recalculate year boundaries
            my ( $Second, $Minute, $Hour, $Day, $Month, $Year, $DayOfWeek )
                = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->DateGet(
                SystemTime => $Kernel::OM->Get('Kernel::System::Calendar::Helper')->CurrentSystemTime(),
                );
            for my $Field (qw(Start End RecurrenceUntil)) {
                if ( $Appointment{"${Field}Year"} ) {
                    my $Diff = $Appointment{"${Field}Year"} - $Year;
                    if ( $Diff > 0 && abs $Diff > $YearPeriodFuture{$Field} ) {
                        $YearPeriodFuture{$Field} = abs $Diff;
                    }
                    elsif ( $Diff < 0 && abs $Diff > $YearPeriodPast{$Field} ) {
                        $YearPeriodPast{$Field} = abs $Diff;
                    }
                }
            }

            if ( $Appointment{Recurring} ) {
                my $RecurrenceType = $GetParam{RecurrenceType} || $Appointment{RecurrenceType};

                if ( $RecurrenceType eq 'CustomWeekly' ) {

                    my $DayOffset = $Self->_DayOffetGet(
                        Time     => $Appointment{StartTime},
                        Timezone => $Appointment{TimezoneID},
                    );

                    if ( defined $GetParam{Days} ) {

                        # check parameters
                        $Appointment{Days} = $GetParam{Days};
                    }
                    else {
                        my @Days = @{ $Appointment{RecurrenceFrequency} };

                        # display selected days according to user timezone
                        if ($DayOffset) {
                            for my $Day (@Days) {
                                $Day += $DayOffset;
                                $Day = 1 if $Day == 8;
                            }
                        }

                        $Appointment{Days} = join( ",", @Days );
                    }
                }
                elsif ( $RecurrenceType eq 'CustomMonthly' ) {

                    my $DayOffset = $Self->_DayOffetGet(
                        Time     => $Appointment{StartTime},
                        Timezone => $Appointment{TimezoneID},
                    );

                    if ( defined $GetParam{MonthDays} ) {

                        # check parameters
                        $Appointment{MonthDays} = $GetParam{MonthDays};
                    }
                    else {
                        my @MonthDays = @{ $Appointment{RecurrenceFrequency} };

                        # display selected days according to user timezone
                        if ($DayOffset) {
                            for my $MonthDay (@MonthDays) {
                                $MonthDay += $DayOffset;
                                $MonthDay = 1 if $Day == 32;
                            }
                        }
                        $Appointment{MonthDays} = join( ",", @MonthDays );
                    }
                }
                elsif ( $RecurrenceType eq 'CustomYearly' ) {

                    my $DayOffset = $Self->_DayOffetGet(
                        Time     => $Appointment{StartTime},
                        Timezone => $Appointment{TimezoneID},
                    );

                    if ( defined $GetParam{Months} ) {

                        # check parameters
                        $Appointment{Months} = $GetParam{Months};
                    }
                    else {
                        my @Months = @{ $Appointment{RecurrenceFrequency} };
                        $Appointment{Months} = join( ",", @Months );
                    }
                }
            }
        }

        # get selected timestamp
        my $SelectedTimestamp = sprintf(
            "%04d-%02d-%02d 00:00:00",
            $Appointment{StartYear}  // $GetParam{StartYear},
            $Appointment{StartMonth} // $GetParam{StartMonth},
            $Appointment{StartDay}   // $GetParam{StartDay}
        );

        # get current day
        my $SelectedSystemTime = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->SystemTimeGet(
            String => $SelectedTimestamp,
        );

        my @DateInfo = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->DateGet(
            SystemTime => $SelectedSystemTime,
        );

        # set week day if not set
        $Appointment{Days} = $DateInfo[6] if !$Appointment{Days};

        # set month day if not set
        $Appointment{MonthDays} = $DateInfo[3] if !$Appointment{MonthDays};

        # set month if not set
        $Appointment{Months} = $DateInfo[4] if !$Appointment{Months};

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
            Prefix                   => 'Start',
            StartHour                => $Appointment{StartHour} // $GetParam{StartHour},
            StartMinute              => $Appointment{StartMinute} // $GetParam{StartMinute},
            Format                   => 'DateInputFormatLong',
            ValidateDateBeforePrefix => 'End',
            Validate                 => 1,
            YearPeriodPast           => $YearPeriodPast{Start},
            YearPeriodFuture         => $YearPeriodFuture{Start},

            # we are calculating this locally
            OverrideTimeZone => 1,
            Disabled         => $Permissions
                && ( $PermissionLevel{$Permissions} < 2 ) ? 1 : 0,    # disable if permissions are below move_into
        );

        # end date string
        $Param{EndDateString} = $LayoutObject->BuildDateSelection(
            %GetParam,
            %Appointment,
            Prefix                  => 'End',
            EndHour                 => $Appointment{EndHour} // $GetParam{EndHour},
            EndMinute               => $Appointment{EndMinute} // $GetParam{EndMinute},
            Format                  => 'DateInputFormatLong',
            ValidateDateAfterPrefix => 'Start',
            Validate                => 1,
            YearPeriodPast          => $YearPeriodPast{End},
            YearPeriodFuture        => $YearPeriodFuture{End},

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

        my $SelectedRecurrenceType       = 0;
        my $SelectedRecurrenceCustomType = 'CustomDaily';    # default

        if ( $Appointment{Recurring} ) {

            # from appointment
            $SelectedRecurrenceType = $GetParam{RecurrenceType} || $Appointment{RecurrenceType};
            if ( $SelectedRecurrenceType =~ /Custom/ ) {
                $SelectedRecurrenceCustomType = $SelectedRecurrenceType;
                $SelectedRecurrenceType       = 'Custom';
            }
        }

        # recurrence type selection
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
                {
                    Key   => 'Custom',
                    Value => Translatable('Custom'),
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

        # recurrence custom type selection
        $Param{RecurrenceCustomTypeString} = $LayoutObject->BuildSelection(
            Data => [
                {
                    Key   => 'CustomDaily',
                    Value => Translatable('Every Day'),
                },
                {
                    Key   => 'CustomWeekly',
                    Value => Translatable('Every Week'),
                },
                {
                    Key   => 'CustomMonthly',
                    Value => Translatable('Every Month'),
                },
                {
                    Key   => 'CustomYearly',
                    Value => Translatable('Every Year'),
                },
            ],
            SelectedID => $SelectedRecurrenceCustomType,
            Name       => 'RecurrenceCustomType',
            Class      => 'Modernize',
        );

        my $SelectedInterval = $GetParam{RecurrenceInterval} || $Appointment{RecurrenceInterval} || 1;

        # add Interval selection (1-31)
        my @RecurrenceCustomInterval;
        for ( my $DayNumber = 1; $DayNumber < 32; $DayNumber++ ) {
            push @RecurrenceCustomInterval, {
                Key   => $DayNumber,
                Value => $DayNumber,
            };
        }
        $Param{RecurrenceIntervalString} = $LayoutObject->BuildSelection(
            Data       => \@RecurrenceCustomInterval,
            SelectedID => $SelectedInterval,
            Name       => 'RecurrenceInterval',
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

        my $RecurrenceUntilDiffTime = 0;
        if ( !$Appointment{RecurrenceUntil} ) {

            # get current and start time for difference
            my $SystemTime = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->CurrentSystemTime();
            my $StartTime  = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->Date2SystemTime(
                Year   => $Appointment{StartYear}   // $GetParam{StartYear},
                Month  => $Appointment{StartMonth}  // $GetParam{StartMonth},
                Day    => $Appointment{StartDay}    // $GetParam{StartDay},
                Hour   => $Appointment{StartHour}   // $GetParam{StartHour},
                Minute => $Appointment{StartMinute} // $GetParam{StartMinute},
                Second => 0,
            );
            $RecurrenceUntilDiffTime = $StartTime - $SystemTime + 60 * 60 * 24 * 3,    # start +3 days
        }

        # recurrence until date string
        $Param{RecurrenceUntilString} = $LayoutObject->BuildDateSelection(
            %Appointment,
            %GetParam,
            Prefix                  => 'RecurrenceUntil',
            Format                  => 'DateInputFormat',
            DiffTime                => $RecurrenceUntilDiffTime,
            ValidateDateAfterPrefix => 'Start',
            Validate                => 1,
            YearPeriodPast          => $YearPeriodPast{RecurrenceUntil},
            YearPeriodFuture        => $YearPeriodFuture{RecurrenceUntil},

            # we are calculating this locally
            OverrideTimeZone => 1,
            Disabled         => $Permissions
                && ( $PermissionLevel{$Permissions} < 2 ) ? 1 : 0,    # disable if permissions are below move_into
        );

        # get plugin list
        $Param{PluginList} = $PluginObject->PluginList();

        if ( $GetParam{AppointmentID} ) {

            for my $PluginKey ( sort keys %{ $Param{PluginList} } ) {
                my $LinkList = $PluginObject->PluginLinkList(
                    AppointmentID => $GetParam{AppointmentID},
                    PluginKey     => $PluginKey,
                    UserID        => $Self->{UserID},
                );
                my @LinkArray;

                $Param{PluginData}->{$PluginKey} = [];
                for my $LinkID ( sort keys %{$LinkList} ) {
                    push @{ $Param{PluginData}->{$PluginKey} }, $LinkList->{$LinkID};
                    push @LinkArray, $LinkList->{$LinkID}->{LinkID};
                }

                $Param{PluginList}->{$PluginKey}->{LinkList} = $LayoutObject->JSONEncode(
                    Data => \@LinkArray,
                );
            }
        }

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

        # datepicker initialization
        # only if user has permissions move_into and above
        if ( $Permissions && ( $PermissionLevel{$Permissions} < 2 ) ? 0 : 1 ) {

            # get text direction
            my $TextDirection = $LayoutObject->{LanguageObject}->{TextDirection} || '';

            # get vacation days
            my $VacationDaysJSON = $LayoutObject->JSONEncode(
                Data => $LayoutObject->DatepickerGetVacationDays(),
            );

            # get first day of the week
            my $WeekDayStart = $ConfigObject->Get('CalendarWeekDayStart') || 1;

            # some general datepicker code
            $LayoutObject->Block(
                Name => 'DatepickerData',
                Data => {
                    VacationDays  => $VacationDaysJSON,
                    IsRTLLanguage => ( $TextDirection eq 'rtl' ) ? 1 : 0,
                },
            );

            # initialize datepickers for different date fields
            for my $Prefix (qw(Start End RecurrenceUntil)) {
                $LayoutObject->Block(
                    Name => 'DatepickerInit',
                    Data => {
                        Prefix       => $Prefix,
                        WeekDayStart => $WeekDayStart,
                    },
                );
            }
        }

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

            # make end time inclusive, add whole day
            my $EndTime = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->SystemTimeGet(
                String => $GetParam{EndTime},
            );
            $GetParam{EndTime} = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->TimestampGet(
                SystemTime => $EndTime + 86400,
            );
        }
        elsif ( $GetParam{Recurring} && $GetParam{UpdateType} && $GetParam{UpdateDelta} ) {

            my $StartTime = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->SystemTimeGet(
                String => $Appointment{StartTime},
            );
            my $EndTime = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->SystemTimeGet(
                String => $Appointment{EndTime},
            );

            # calculate new start/end times
            if ( $GetParam{UpdateType} eq 'StartTime' ) {
                $GetParam{StartTime} = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->TimestampGet(
                    SystemTime => $StartTime + $GetParam{UpdateDelta},
                );
            }
            elsif ( $GetParam{UpdateType} eq 'EndTime' ) {
                $GetParam{EndTime} = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->TimestampGet(
                    SystemTime => $EndTime + $GetParam{UpdateDelta},
                );
            }
            else {
                $GetParam{StartTime} = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->TimestampGet(
                    SystemTime => $StartTime + $GetParam{UpdateDelta},
                );
                $GetParam{EndTime} = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->TimestampGet(
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

        # prevent recurrence until dates before start time
        if ( $Appointment{Recurring} && $Appointment{RecurrenceUntil} ) {
            my $StartTime = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->SystemTimeGet(
                String => $GetParam{StartTime},
            );
            my $RecurrenceUntil = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->SystemTimeGet(
                String => $Appointment{RecurrenceUntil},
            );
            if ( $RecurrenceUntil < $StartTime ) {
                $Appointment{RecurrenceUntil} = $GetParam{StartTime};
            }
        }

        # recurring appointment
        if ( $GetParam{Recurring} && $GetParam{RecurrenceType} ) {

            if (
                $GetParam{RecurrenceType}    eq 'Daily'
                || $GetParam{RecurrenceType} eq 'Weekly'
                || $GetParam{RecurrenceType} eq 'Monthly'
                || $GetParam{RecurrenceType} eq 'Yearly'
                )
            {
                $GetParam{RecurrenceInterval} = 1;
            }
            elsif ( $GetParam{RecurrenceType} eq 'Custom' ) {

                if ( $GetParam{RecurrenceCustomType} eq 'CustomWeekly' ) {
                    if ( $GetParam{Days} ) {
                        my @Days = split( ",", $GetParam{Days} );
                        $GetParam{RecurrenceFrequency} = \@Days;
                    }
                    else {
                        my $StartTime = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->SystemTimeGet(
                            String => $GetParam{StartTime},
                        );

                        my @DateInfo = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->DateGet(
                            SystemTime => $StartTime,
                        );

                        $GetParam{RecurrenceFrequency} = [ $DateInfo[6] ];
                    }
                }
                elsif ( $GetParam{RecurrenceCustomType} eq 'CustomMonthly' ) {
                    if ( $GetParam{MonthDays} ) {
                        my @MonthDays = split( ",", $GetParam{MonthDays} );
                        $GetParam{RecurrenceFrequency} = \@MonthDays;
                    }
                    else {
                        my $StartTime = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->SystemTimeGet(
                            String => $GetParam{StartTime},
                        );

                        my @DateInfo = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->DateGet(
                            SystemTime => $StartTime,
                        );

                        $GetParam{RecurrenceFrequency} = [ $DateInfo[3] ];
                    }
                }
                elsif ( $GetParam{RecurrenceCustomType} eq 'CustomYearly' ) {
                    if ( $GetParam{Months} ) {
                        my @Months = split( ",", $GetParam{Months} );
                        $GetParam{RecurrenceFrequency} = \@Months;
                    }
                    else {
                        my $StartTime = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->SystemTimeGet(
                            String => $GetParam{StartTime},
                        );

                        my @DateInfo = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->DateGet(
                            SystemTime => $StartTime,
                        );

                        $GetParam{RecurrenceFrequency} = [ $DateInfo[4] ];
                    }
                }

                $GetParam{RecurrenceType} = $GetParam{RecurrenceCustomType};
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
        $GetParam{TimezoneID} = $Kernel::OM->Get('Kernel::System::Calendar::Helper')->TimezoneOffsetGet(
            UserID => $Self->{UserID},
        );
        $GetParam{UserID} = $Self->{UserID};

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
                my $PluginData = $Kernel::OM->Get('Kernel::System::JSON')->Decode(
                    Data => $GetParam{$PluginParam},
                );
                my $PluginKey = $PluginParam;
                $PluginKey =~ s/^Plugin_//;

                # execute plugin link method
                if ( IsArrayRefWithData($PluginData) ) {
                    for my $LinkID ( @{$PluginData} ) {
                        my $Link = $PluginObject->PluginLinkAdd(
                            AppointmentID => $AppointmentID,
                            PluginKey     => $PluginKey,
                            PluginData    => $LinkID,
                            UserID        => $Self->{UserID},
                        );

                        $Kernel::OM->Get('Kernel::System::Log')->Log(
                            Priority => 'error',
                            Message  => Translatable('Link could not be created!'),
                        ) if !$Link;
                    }
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

sub _DayOffetGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(Time)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }
    $Param{Timezone} //= 0;

    my $CalendarHelperObject = $Kernel::OM->Get('Kernel::System::Calendar::Helper');

    # get user timezone offset
    my $UserTimezone = $CalendarHelperObject->TimezoneOffsetGet(
        UserID => $Self->{UserID},
    );

    # convert timestamp to unix time
    my $OriginalTimeSystem = $CalendarHelperObject->SystemTimeGet(
        String => $Param{Time},
    );

    # get original date info
    my @OriginalDateInfo = $CalendarHelperObject->DateGet(
        SystemTime => $OriginalTimeSystem,
    );

    # calculate destination time (according to user timezone)
    my $DestinationTimeSystem = $OriginalTimeSystem
        - $Param{Timezone} * 3600
        + $UserTimezone * 3600;

    # get destination date info
    my @DestinationDateInfo = $CalendarHelperObject->DateGet(
        SystemTime => $DestinationTimeSystem,
    );

    # compare days - arrays contains following values: Second, Minute, Hour, Day, Month, Year and DayOfWeek
    if ( $OriginalDateInfo[3] == $DestinationDateInfo[3] ) {

        # same day
        return 0;
    }
    elsif ( $OriginalTimeSystem > $DestinationTimeSystem ) {
        return -1;
    }
    else {
        return 1;
    }

}
1;
