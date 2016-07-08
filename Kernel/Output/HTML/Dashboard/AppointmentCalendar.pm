# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::Dashboard::AppointmentCalendar;

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

    # get needed parameters
    for my $Needed (qw(Config Name UserID)) {
        die "Got no $Needed!" if ( !$Self->{$Needed} );
    }

    # get param object
    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');

    # get current filter
    my $Name = $ParamObject->GetParam( Param => 'Name' ) || '';
    my $PreferencesKey = 'DashboardCalendarAppointmentFilter' . $Self->{Name};
    if ( $Self->{Name} eq $Name ) {
        $Self->{Filter} = $ParamObject->GetParam( Param => 'Filter' ) || '';
    }

    # get config object
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # remember filter
    if ( $Self->{Filter} ) {

        # update session
        $Kernel::OM->Get('Kernel::System::AuthSession')->UpdateSessionID(
            SessionID => $Self->{SessionID},
            Key       => $PreferencesKey,
            Value     => $Self->{Filter},
        );

        # update preferences
        if ( !$ConfigObject->Get('DemoSystem') ) {
            $Kernel::OM->Get('Kernel::System::User')->SetPreferences(
                UserID => $Self->{UserID},
                Key    => $PreferencesKey,
                Value  => $Self->{Filter},
            );
        }
    }

    # set default filter if not set yet
    if ( !$Self->{Filter} ) {
        $Self->{Filter} = $Self->{$PreferencesKey} || $Self->{Config}->{Filter} || 'Today';
    }

    $Self->{PrefKey} = 'AppointmentDashboardPref' . $Self->{Name} . '-Shown';

    $Self->{PageShown} = $Kernel::OM->Get('Kernel::Output::HTML::Layout')->{ $Self->{PrefKey} }
        || $Self->{Config}->{Limit} || 10;

    $Self->{StartHit} = int( $ParamObject->GetParam( Param => 'StartHit' ) || 1 );

    $Self->{CacheKey} = $Self->{Name} . '::' . $Self->{Filter};

    # get configuration for the full name order for user names
    # and append it to the cache key to make sure, that the
    # correct data will be displayed every time
    my $FirstnameLastNameOrder = $ConfigObject->Get('FirstnameLastnameOrder') || 0;
    $Self->{CacheKey} .= '::' . $FirstnameLastNameOrder;

    return $Self;
}

sub Preferences {
    my ( $Self, %Param ) = @_;

    # get a list of at least readable calendars
    my @CalendarList = $Kernel::OM->Get('Kernel::System::Calendar')->CalendarList(
        UserID  => $Self->{UserID},
        ValidID => 1,
    );

    # prepare calendars
    my %Calendars;

    CALENDAR:
    for my $Calendar (@CalendarList) {

        next CALENDAR if !$Calendar;
        next CALENDAR if !IsHashRefWithData($Calendar);
        next CALENDAR if $Calendars{ $Calendar->{CalendarID} };

        $Calendars{ $Calendar->{CalendarID} } = $Calendar->{CalendarName};
    }

    my @Params = (
        {
            Desc  => Translatable('Shown'),
            Name  => $Self->{PrefKey},
            Block => 'Option',
            Data  => {
                5  => ' 5',
                10 => '10',
                15 => '15',
                20 => '20',
                25 => '25',
            },
            SelectedID  => $Self->{PageShown},
            Translation => 0,
        },
        {
            Desc  => Translatable('Calendars'),
            Name  => $Self->{PrefKey} . 'Calendars',
            Block => 'Option',
            Data  => {
                0 => 'All calendars',
                %Calendars,
            },
            SelectedID  => 0,
            Translation => 1,
        },
    );

    return @Params;
}

sub Config {
    my ( $Self, %Param ) = @_;

    return (
        %{ $Self->{Config} },

        CanRefresh => 1,

        # remember, do not allow to use page cache
        # (it's not working because of internal filter)
        CacheKey => undef,
        CacheTTL => undef,
    );
}

sub Run {
    my ( $Self, %Param ) = @_;

    # get config settings
    my $IdleMinutes = $Self->{Config}->{IdleMinutes} || 60;
    my $SortBy      = $Self->{Config}->{SortBy}      || 'UserFullname';

    # get a local appointment object
    my $CalendarObject       = $Kernel::OM->Get('Kernel::System::Calendar');
    my $AppointmentObject    = $Kernel::OM->Get('Kernel::System::Calendar::Appointment');
    my $CalendarHelperObject = $Kernel::OM->Get('Kernel::System::Calendar::Helper');
    my $CacheObject          = $Kernel::OM->Get('Kernel::System::Cache');

    # get a list of at least readable calendars
    my @CalendarList = $CalendarObject->CalendarList(
        UserID  => $Self->{UserID},
        ValidID => 1,
    );

    # collect calendar and appointment data
    # seperate appointments to today, tomorrow
    # and the next five days (soon)
    my %Calendars;
    my %Appointments;
    my %AppointmentsCount;

    # check cache
    my $CacheKeyCalendars         = $Self->{CacheKey} . '::Calendars';
    my $CacheKeyAppointments      = $Self->{CacheKey} . '::Appointments::' . $Self->{Filter};
    my $CacheKeyAppointmentsCount = $Self->{CacheKey} . '::AppointmentsCount';

    # get cached data
    my $DataCalendars = $CacheObject->Get(
        Type => 'Dashboard',
        Key  => $CacheKeyCalendars,
    );
    my $DataAppointments = $CacheObject->Get(
        Type => 'Dashboard',
        Key  => $CacheKeyAppointments,
    );
    my $DataAppointmentsCount = $CacheObject->Get(
        Type => 'Dashboard',
        Key  => $CacheKeyAppointmentsCount,
    );

    # TESTING disable cache
    $DataCalendars             = 0;
    $DataAppointments          = 0;
    $CacheKeyAppointmentsCount = 0;

    # if cache is up-to-date, use the given data
    if (
        ref $DataCalendars eq 'HASH'
        && ref $DataAppointments eq 'HASH'
        && ref $DataAppointmentsCount eq 'HASH'
        )
    {
        %Calendars         = %{$DataCalendars};
        %Appointments      = %{$DataAppointments};
        %AppointmentsCount = %{$DataAppointmentsCount};
    }

    # collect the data again if necessary
    else {

        CALENDAR:
        for my $Calendar (@CalendarList) {

            next CALENDAR if !$Calendar;
            next CALENDAR if !IsHashRefWithData($Calendar);
            next CALENDAR if $Calendars{ $Calendar->{CalendarID} };

            $Calendars{ $Calendar->{CalendarID} } = $Calendar;
        }

        # set cache for calendars
        $CacheObject->Set(
            Type  => 'Dashboard',
            Key   => $CacheKeyCalendars,
            Value => \%Calendars,
            TTL   => $Self->{Config}->{CacheTTLLocal} * 60,
        );

        # prepare calendar appointments
        my %AppointmentsUnsorted;

        CALENDARID:
        for my $CalendarID ( sort keys %Calendars ) {

            next CALENDARID if !$CalendarID;

            my @Appointments = $AppointmentObject->AppointmentList(
                CalendarID => $CalendarID,
                StartTime  => $CalendarHelperObject->CurrentTimestampGet(),
                Result     => 'HASH',
            );

            next CALENDARID if !IsArrayRefWithData( \@Appointments );

            APPOINTMENT:
            for my $Appointment (@Appointments) {

                next APPOINTMENT if !$Appointment;
                next APPOINTMENT if !IsHashRefWithData($Appointment);

                # save appointment in new hash for later sorting
                $AppointmentsUnsorted{ $Appointment->{AppointmentID} } = $Appointment;
            }
        }

        # get datetime strings for the dates with related offsets
        # (today, tomorrow and soon - which means the next 5 days
        # except today and tomorrow counted from current timestamp)
        my %DateOffset = (
            Today     => 0,
            Tomorrow  => 86400,
            PlusTwo   => 172800,
            PlusThree => 259200,
            PlusFour  => 345600,
        );

        my %Dates;

        # get current timestamp
        my $CurrentSystemTime = $CalendarHelperObject->CurrentSystemTime();

        for my $DateOffsetKey ( sort keys %DateOffset ) {

            # get date units with current offset
            my ( $Second, $Minute, $Hour, $Day, $Month, $Year, $DayOfWeek ) = $CalendarHelperObject->DateGet(
                SystemTime => $CurrentSystemTime + $DateOffset{$DateOffsetKey},
            );

            $Dates{$DateOffsetKey}
                = sprintf( "%02d", $Year ) . '-' . sprintf( "%02d", $Month ) . '-' . sprintf( "%02d", $Day );
        }

        $AppointmentsCount{Today}    = 0;
        $AppointmentsCount{Tomorrow} = 0;
        $AppointmentsCount{Soon}     = 0;

        APPOINTMENTID:
        for my $AppointmentID ( sort keys %AppointmentsUnsorted ) {

            next APPOINTMENTID if !$AppointmentID;
            next APPOINTMENTID if !IsHashRefWithData( $AppointmentsUnsorted{$AppointmentID} );
            next APPOINTMENTID if !$AppointmentsUnsorted{$AppointmentID}->{StartTime};

            # extract current date (without time)
            my $StartDateSystemTime = $CalendarHelperObject->SystemTimeGet(
                String => $AppointmentsUnsorted{$AppointmentID}->{StartTime},
            );

            next APPOINTMENTID if !$StartDateSystemTime;

            my ( $CSecond, $CMinute, $CHour, $CDay, $CMonth, $CYear, $CDayOfWeek ) = $CalendarHelperObject->DateGet(
                SystemTime => $StartDateSystemTime,
            );

            my $StartDate
                = sprintf( "%02d", $CYear ) . '-' . sprintf( "%02d", $CMonth ) . '-' . sprintf( "%02d", $CDay );

            # today
            if ( $StartDate eq $Dates{Today} ) {

                $AppointmentsCount{Today}++;

                if ( $Self->{Filter} eq 'Today' ) {
                    $Appointments{$AppointmentID} = $AppointmentsUnsorted{$AppointmentID};
                }
            }

            # tomorrow
            elsif ( $StartDate eq $Dates{Tomorrow} ) {

                $AppointmentsCount{Tomorrow}++;

                if ( $Self->{Filter} eq 'Tomorrow' ) {
                    $Appointments{$AppointmentID} = $AppointmentsUnsorted{$AppointmentID};
                }
            }

            # soon
            elsif (
                $StartDate eq $Dates{PlusTwo}
                || $StartDate eq $Dates{PlusThree}
                || $StartDate eq $Dates{PlusFour}
                )
            {
                $AppointmentsCount{Soon}++;

                if ( $Self->{Filter} eq 'Soon' ) {
                    $Appointments{$AppointmentID} = $AppointmentsUnsorted{$AppointmentID};
                }
            }
        }

        # set cache for appointments
        $CacheObject->Set(
            Type  => 'Dashboard',
            Key   => $CacheKeyAppointments,
            Value => \%Appointments,
            TTL   => $Self->{Config}->{CacheTTLLocal} * 60,
        );

        # set cache for appointments count
        $CacheObject->Set(
            Type  => 'Dashboard',
            Key   => $CacheKeyAppointmentsCount,
            Value => \%AppointmentsCount,
            TTL   => $Self->{Config}->{CacheTTLLocal} * 60,
        );
    }

    # get layout object
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my $AppointmentTableBlock = 'ContentSmallTable';

    # prepare appointments table
    $LayoutObject->Block(
        Name => 'ContentSmallTable',
    );

    for my $AppointmentID ( sort keys %Appointments ) {

        my $StartSystemTime = $CalendarHelperObject->SystemTimeGet(
            String => $Appointments{$AppointmentID}->{StartTime},
        );

        my ( $ASecond, $AMinute, $AHour, $ADay, $AMonth, $AYear, $ADayOfWeek ) = $CalendarHelperObject->DateGet(
            SystemTime => $StartSystemTime,
        );

        my $StartTime = sprintf( "%02d", $AHour ) . ':' . sprintf( "%02d", $AMinute );

        $LayoutObject->Block(
            Name => 'ContentSmallAppointmentRow',
            Data => {
                AppointmentID => $Appointments{$AppointmentID}->{AppointmentID},
                Title         => $Appointments{$AppointmentID}->{Title},
                StartTime     => $StartTime,
                StartTimeLong => $Appointments{$AppointmentID}->{StartTime},
                Color         => $Calendars{ $Appointments{$AppointmentID}->{CalendarID} }->{Color},
                CalendarName  => $Calendars{ $Appointments{$AppointmentID}->{CalendarID} }->{CalendarName},
            },
        );
    }

    if ( !IsHashRefWithData( \%Appointments ) ) {

        # show up message for no appointments
        $LayoutObject->Block(
            Name => 'ContentSmallAppointmentNone',
        );
    }

    # get time object
    my $TimeObject = $Kernel::OM->Get('Kernel::System::Time');

    # get current time-stamp
    my $Time = $TimeObject->SystemTime();

    my $Online;

    # get session info
    my $CacheUsed = 1;
    if ( !$Online ) {

        $CacheUsed = 0;
        $Online    = {
            User => {
                Agent    => {},
                Customer => {},
            },
            UserCount => {
                Agent    => 0,
                Customer => 0,
            },
            UserData => {
                Agent    => {},
                Customer => {},
            },
        };

        # get session object
        my $SessionObject = $Kernel::OM->Get('Kernel::System::AuthSession');

        # get session ids
        my @Sessions = $SessionObject->GetAllSessionIDs();

        # get user object
        my $UserObject = $Kernel::OM->Get('Kernel::System::User');

        SESSIONID:
        for my $SessionID (@Sessions) {

            next SESSIONID if !$SessionID;

            # get session data
            my %Data = $SessionObject->GetSessionIDData( SessionID => $SessionID );

            next SESSIONID if !%Data;
            next SESSIONID if !$Data{UserID};

            # use agent instead of user
            my %AgentData;
            if ( $Data{UserType} eq 'User' ) {
                $Data{UserType} = 'Agent';

                # get user data
                %AgentData = $UserObject->GetUserData(
                    UserID        => $Data{UserID},
                    NoOutOfOffice => 1,
                );
            }
            else {
                $Data{UserFullname}
                    ||= $Kernel::OM->Get('Kernel::System::CustomerUser')->CustomerName(
                    UserLogin => $Data{UserLogin},
                    );
            }

            # only show if not already shown
            next SESSIONID if $Online->{User}->{ $Data{UserType} }->{ $Data{UserID} };

            # check last request time / idle time out
            next SESSIONID if !$Data{UserLastRequest};
            next SESSIONID if $Data{UserLastRequest} + ( $IdleMinutes * 60 ) < $Time;

            # remember user and data
            $Online->{User}->{ $Data{UserType} }->{ $Data{UserID} } = $Data{$SortBy};
            $Online->{UserCount}->{ $Data{UserType} }++;
            $Online->{UserData}->{ $Data{UserType} }->{ $Data{UserID} } = { %Data, %AgentData };
        }
    }

    # set cache
    if ( !$CacheUsed && $Self->{Config}->{CacheTTLLocal} ) {
        $CacheObject->Set(
            Type  => 'Dashboard',
            Key   => $Self->{CacheKey},
            Value => $Online,
            TTL   => $Self->{Config}->{CacheTTLLocal} * 60,
        );
    }

    # set css class
    my %Summary;
    $Summary{ $Self->{Filter} . '::Selected' } = 'Selected';

    # filter bar
    $LayoutObject->Block(
        Name => 'ContentSmallAppointmentFilter',
        Data => {
            %{ $Self->{Config} },
            %{ $Online->{UserCount} },
            %Summary,
            Name => $Self->{Name},

            TodayCount    => $AppointmentsCount{Today},
            TomorrowCount => $AppointmentsCount{Tomorrow},
            SoonCount     => $AppointmentsCount{Soon},
        },
    );

    # add page nav bar
    my $Total    = $Online->{UserCount}->{ $Self->{Filter} } || 0;
    my $LinkPage = 'Subaction=Element;Name=' . $Self->{Name} . ';Filter=' . $Self->{Filter} . ';';
    my %PageNav  = $LayoutObject->PageNavBar(
        StartHit       => $Self->{StartHit},
        PageShown      => $Self->{PageShown},
        AllHits        => $Total || 1,
        Action         => 'Action=' . $LayoutObject->{Action},
        Link           => $LinkPage,
        WindowSize     => 5,
        AJAXReplace    => 'Dashboard' . $Self->{Name},
        IDPrefix       => 'Dashboard' . $Self->{Name},
        KeepScriptTags => $Param{AJAX},
    );

    $LayoutObject->Block(
        Name => 'ContentSmallAppointmentFilterNavBar',
        Data => {
            %{ $Self->{Config} },
            Name => $Self->{Name},
            %PageNav,
        },
    );

    $Self->{Filter} = 'Agent';

    # show agent/customer
    my %OnlineUser = %{ $Online->{User}->{ $Self->{Filter} } };
    my %OnlineData = %{ $Online->{UserData}->{ $Self->{Filter} } };
    my $Count      = 0;
    my $Limit      = $LayoutObject->{ $Self->{PrefKey} } || $Self->{Config}->{Limit};

    # get config object
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # Check if agent has permission to start chats with the listed users
    my $EnableChat               = 1;
    my $ChatStartingAgentsGroup  = $ConfigObject->Get('ChatEngine::PermissionGroup::ChatStartingAgents');
    my $ChatReceivingAgentsGroup = $ConfigObject->Get('ChatEngine::PermissionGroup::ChatReceivingAgents');

    if (
        !$ConfigObject->Get('ChatEngine::Active')
        || !defined $LayoutObject->{"UserIsGroup[$ChatStartingAgentsGroup]"}
        || $LayoutObject->{"UserIsGroup[$ChatStartingAgentsGroup]"} ne 'Yes'
        )
    {
        $EnableChat = 0;
    }
    if (
        $EnableChat
        && $Self->{Filter} eq 'Agent'
        && !$ConfigObject->Get('ChatEngine::ChatDirection::AgentToAgent')
        )
    {
        $EnableChat = 0;
    }
    if (
        $EnableChat
        && $Self->{Filter} eq 'Customer'
        && !$ConfigObject->Get('ChatEngine::ChatDirection::AgentToCustomer')
        )
    {
        $EnableChat = 0;
    }

    USERID:
    for my $UserID ( sort { $OnlineUser{$a} cmp $OnlineUser{$b} } keys %OnlineUser ) {

        $Count++;

        next USERID if !$UserID;
        next USERID if $Count < $Self->{StartHit};
        last USERID if $Count >= ( $Self->{StartHit} + $Self->{PageShown} );

        # extract user data
        my $UserData        = $OnlineData{$UserID};
        my $AgentEnableChat = 0;
        my $ChatAccess      = 0;

        # Default status
        my $UserState            = "Offline";
        my $UserStateDescription = $LayoutObject->{LanguageObject}->Translate('This user is currently offline');

        # we also need to check if the receiving agent has chat permissions
        if ( $EnableChat && $Self->{Filter} eq 'Agent' ) {

            my %UserGroups = $Kernel::OM->Get('Kernel::System::Group')->PermissionUserGet(
                UserID => $UserData->{UserID},
                Type   => 'rw',
            );

            my %UserGroupsReverse = reverse %UserGroups;
            $ChatAccess = $UserGroupsReverse{$ChatReceivingAgentsGroup} ? 1 : 0;

            # Check agents availability
            if ($ChatAccess) {
                my $AgentChatAvailability = $Kernel::OM->Get('Kernel::System::Chat')->AgentAvailabilityGet(
                    UserID   => $UserID,
                    External => 0,
                );

                if ( $AgentChatAvailability == 3 ) {
                    $UserState            = "Active";
                    $AgentEnableChat      = 1;
                    $UserStateDescription = $LayoutObject->{LanguageObject}->Translate('This user is currently active');
                }
                elsif ( $AgentChatAvailability == 2 ) {
                    $UserState            = "Away";
                    $AgentEnableChat      = 1;
                    $UserStateDescription = $LayoutObject->{LanguageObject}->Translate('This user is currently away');
                }
                elsif ( $AgentChatAvailability == 1 ) {
                    $UserState = "Unavailable";
                    $UserStateDescription
                        = $LayoutObject->{LanguageObject}->Translate('This user is currently unavailable');
                }
            }
        }

        $LayoutObject->Block(
            Name => 'ContentSmallUserOnlineRow',
            Data => {
                %{$UserData},
                ChatAccess           => $ChatAccess,
                AgentEnableChat      => $AgentEnableChat,
                UserState            => $UserState,
                UserStateDescription => $UserStateDescription,
            },
        );

        if ( $Self->{Config}->{ShowEmail} ) {
            $LayoutObject->Block(
                Name => 'ContentSmallUserOnlineRowEmail',
                Data => $UserData,
            );
        }

        next USERID if !$UserData->{OutOfOffice};

        my $Start = sprintf(
            "%04d-%02d-%02d 00:00:00",
            $UserData->{OutOfOfficeStartYear}, $UserData->{OutOfOfficeStartMonth},
            $UserData->{OutOfOfficeStartDay}
        );
        my $TimeStart = $TimeObject->TimeStamp2SystemTime(
            String => $Start,
        );
        my $End = sprintf(
            "%04d-%02d-%02d 23:59:59",
            $UserData->{OutOfOfficeEndYear}, $UserData->{OutOfOfficeEndMonth},
            $UserData->{OutOfOfficeEndDay}
        );
        my $TimeEnd = $TimeObject->TimeStamp2SystemTime(
            String => $End,
        );

        next USERID if $TimeStart > $Time || $TimeEnd < $Time;

        $LayoutObject->Block(
            Name => 'ContentSmallUserOnlineRowOutOfOffice',
        );
    }

    if ( !%OnlineUser ) {
        $LayoutObject->Block(
            Name => 'ContentSmallUserOnlineNone',
        );
    }

    # check for refresh time
    my $Refresh  = 30;              # 30 seconds
    my $NameHTML = $Self->{Name};
    $NameHTML =~ s{-}{_}xmsg;

    my $Content = $LayoutObject->Output(
        TemplateFile => 'AgentDashboardAppointmentCalendar',
        Data         => {
            %{ $Self->{Config} },
            Name        => $Self->{Name},
            NameHTML    => $NameHTML,
            RefreshTime => $Refresh,
        },
        KeepScriptTags => $Param{AJAX},
    );

    return $Content;
}

1;
