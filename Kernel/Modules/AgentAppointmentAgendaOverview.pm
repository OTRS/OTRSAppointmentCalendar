# --
# Copyright (C) 2001-2019 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Kernel::Modules::AgentAppointmentAgendaOverview;

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

    # set debug
    $Self->{Debug} = 0;

    $Self->{View} = 'AgentAppointmentAgendaOverview';

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # get filters stored in the user preferences
    my %Preferences = $Kernel::OM->Get('Kernel::System::User')->GetPreferences(
        UserID => $Self->{UserID},
    );
    my $LastFilterKey = 'UserLastFilter-' . $Self->{View};
    my $LastFilter    = $Preferences{$LastFilterKey} || 'Week';

    my %Filters = (
        Month => {
            Name => Translatable('Month'),
            Prio => 100,
        },
        Week => {
            Name => Translatable('Week'),
            Prio => 200,
        },
        Day => {
            Name => Translatable('Day'),
            Prio => 300,
        },
    );

    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');

    # current filter
    $Param{Filter} = $ParamObject->GetParam( Param => 'Filter' ) || $LastFilter;

    # get layout object
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # check if filter is valid
    if ( !$Filters{ $Param{Filter} } ) {
        $LayoutObject->FatalError(
            Message => $LayoutObject->{LanguageObject}->Translate( 'Invalid Filter: %s!', $Param{Filter} ),
        );
    }

    # prepare filters
    my %NavBarFilter;
    for my $FilterColumn ( sort keys %Filters ) {
        $NavBarFilter{ $Filters{$FilterColumn}->{Prio} } = {
            Filter => $FilterColumn,
            %{ $Filters{$FilterColumn} },
        };
    }

    # Get user's permissions to associated modules which are displayed as links.
    for my $Module (qw(AgentAppointmentCalendarManage)) {
        my $ModuleGroups = $Kernel::OM->Get('Kernel::Config')->Get('Frontend::Module')
            ->{$Module}->{Group} // [];

        if ( IsArrayRefWithData($ModuleGroups) ) {
            MODULE_GROUP:
            for my $ModuleGroup ( @{$ModuleGroups} ) {
                if ( $LayoutObject->{"UserIsGroup[$ModuleGroup]"} ) {
                    $Param{ModulePermissions}->{$Module} = 1;
                    last MODULE_GROUP;
                }
            }
        }

        # Always allow links if no groups are specified.
        else {
            $Param{ModulePermissions}->{$Module} = 1;
        }
    }

    # get calendar helper object
    my $CalendarHelperObject = $Kernel::OM->Get('Kernel::System::Calendar::Helper');

    # current time in the view
    $Param{Start} = $ParamObject->GetParam( Param => 'Start' )
        || $CalendarHelperObject->CurrentTimestampGet();

    # handle jump
    $Param{Jump} = $ParamObject->GetParam( Param => 'Jump' ) || '';
    if ( $Param{Jump} ) {
        my $JumpOffset = 0;
        if ( $Param{Filter} eq 'Week' ) {
            $JumpOffset = 60 * 60 * 24 * 7;
        }
        elsif ( $Param{Filter} eq 'Day' ) {
            $JumpOffset = 60 * 60 * 24;
        }

        # calculate destination time
        my $Start = $CalendarHelperObject->SystemTimeGet(
            String => $Param{Start},
        );

        if ( $Param{Filter} eq 'Month' ) {
            my ( $Second, $Minute, $Hour, $Day, $Month, $Year, $DayOfWeek ) = $CalendarHelperObject->DateGet(
                SystemTime => $Start,
            );
            if ( $Param{Jump} eq 'Prev' ) {
                $Month -= 1;
            }
            elsif ( $Param{Jump} eq 'Next' ) {
                $Month += 1;
            }
            if ( $Month < 1 ) {
                $Month = 12;
                $Year -= 1;
            }
            elsif ( $Month > 12 ) {
                $Month = 1;
                $Year += 1;
            }
            $Start = $CalendarHelperObject->Date2SystemTime(
                Year  => $Year,
                Month => $Month,
                Day   => 1,
            );
        }
        else {
            if ( $Param{Jump} eq 'Prev' ) {
                $Start -= $JumpOffset;
            }
            elsif ( $Param{Jump} eq 'Next' ) {
                $Start += $JumpOffset;
            }
        }

        $Param{Start} = $CalendarHelperObject->TimestampGet(
            SystemTime => $Start,
        );
    }

    # calculate date boundaries
    if ( $Param{Filter} eq 'Month' ) {

        # get first day of the month
        my $StartTime = $CalendarHelperObject->SystemTimeGet(
            String => $Param{Start},
        );
        my ( $Second, $Minute, $Hour, $Day, $Month, $Year, $DayOfWeek ) = $CalendarHelperObject->DateGet(
            SystemTime => $StartTime,
        );
        $Param{StartTime} = sprintf( "%04d-%02d-%02d", $Year, $Month, 1 ) . ' 00:00:00';

        # get last day of the month
        $Month += 1;
        if ( $Month > 12 ) {
            $Month = 1;
            $Year += 1;
        }
        my $SystemTime = $CalendarHelperObject->Date2SystemTime(
            Year  => $Year,
            Month => $Month,
            Day   => 1,
        );
        $SystemTime -= 1;    # subtract one second
        ( $Second, $Minute, $Hour, $Day, $Month, $Year, $DayOfWeek ) = $CalendarHelperObject->DateGet(
            SystemTime => $SystemTime,
        );
        $Param{EndTime} = sprintf( "%04d-%02d-%02d", $Year, $Month, $Day ) . ' 23:59:59';

        # get translated name of the month
        my @MonthArray = (
            '',
            'January',
            'February',
            'March',
            'April',
            'May_long',
            'June',
            'July',
            'August',
            'September',
            'October',
            'November',
            'December',
        );
        my $TranslateMonth = $LayoutObject->{LanguageObject}->Translate( $MonthArray[$Month] );

        $Param{HeaderTitle} = "$TranslateMonth $Year";
    }
    elsif ( $Param{Filter} eq 'Week' ) {
        my $CalendarWeekDayStart = $Kernel::OM->Get('Kernel::Config')->Get('CalendarWeekDayStart') || 7;
        my $CalendarWeekDayEnd = ( $CalendarWeekDayStart - 1 ) || 7;

        # get start of the week
        my $StartTime = $CalendarHelperObject->SystemTimeGet(
            String => $Param{Start},
        );
        my ( $WeekDay, $CW ) = $CalendarHelperObject->WeekDetailsGet(
            SystemTime => $StartTime,
        );
        while ( $WeekDay != $CalendarWeekDayStart ) {
            $StartTime -= 60 * 60 * 24;
            ( $WeekDay, $CW ) = $CalendarHelperObject->WeekDetailsGet(
                SystemTime => $StartTime,
            );
        }
        $Param{StartTime} =
            substr( $CalendarHelperObject->TimestampGet( SystemTime => $StartTime ), 0, 10 )
            . ' 00:00:00';

        # get end of the week
        my $EndTime = $CalendarHelperObject->SystemTimeGet(
            String => $Param{Start},
        );
        ( $WeekDay, $CW ) = $CalendarHelperObject->WeekDetailsGet(
            SystemTime => $EndTime,
        );
        while ( $WeekDay != $CalendarWeekDayEnd ) {
            $EndTime += 60 * 60 * 24;
            ( $WeekDay, $CW ) = $CalendarHelperObject->WeekDetailsGet(
                SystemTime => $EndTime,
            );
        }
        $Param{EndTime} =
            substr( $CalendarHelperObject->TimestampGet( SystemTime => $EndTime ), 0, 10 )
            . ' 23:59:59';

        $Param{HeaderTitle} =
            $LayoutObject->{LanguageObject}->FormatTimeString( $Param{StartTime}, 'DateFormatShort' )
            . ' '
            . chr(8211)
            . ' '
            . $LayoutObject->{LanguageObject}->FormatTimeString( $Param{EndTime}, 'DateFormatShort' );
        $Param{HeaderTitleCW} = "#$CW";
    }
    elsif ( $Param{Filter} eq 'Day' ) {
        $Param{StartTime} = substr( $Param{Start}, 0, 10 ) . ' 00:00:00';
        $Param{EndTime}   = substr( $Param{Start}, 0, 10 ) . ' 23:59:59';

        # get start of the week
        my $StartTime = $CalendarHelperObject->SystemTimeGet(
            String => $Param{Start},
        );
        my ( $WeekDay, $CW ) = $CalendarHelperObject->WeekDetailsGet(
            SystemTime => $StartTime,
        );

        $Param{HeaderTitle} = $LayoutObject->{LanguageObject}->FormatTimeString( $Param{StartTime}, 'DateFormatShort' );
        $Param{HeaderTitleCW} = "#$CW";
    }

    # display filter buttons
    my @NavBarFilters;
    for my $Prio ( sort keys %NavBarFilter ) {
        push @NavBarFilters, $NavBarFilter{$Prio};
    }
    $LayoutObject->Block(
        Name => 'OverviewNavBarFilter',
        Data => {
            %Filters,
        },
    );
    my $Count = 0;
    for my $Filter (@NavBarFilters) {
        $Count++;
        if ( $Count == scalar @NavBarFilters ) {
            $Filter->{CSS} = 'Last';
        }
        $LayoutObject->Block(
            Name => 'OverviewNavBarFilterItem',
            Data => {
                %Param,
                %{$Filter},
            },
        );
        if ( $Filter->{Filter} eq $Param{Filter} ) {
            $LayoutObject->Block(
                Name => 'OverviewNavBarFilterItemSelected',
                Data => {
                    %Param,
                    %{$Filter},
                },
            );
        }
        else {
            $LayoutObject->Block(
                Name => 'OverviewNavBarFilterItemSelectedNot',
                Data => {
                    %Param,
                    %{$Filter},
                },
            );
        }
    }

    # get calendar object
    my $CalendarObject = $Kernel::OM->Get('Kernel::System::Calendar');

    # get all user's valid calendars
    my $ValidID = $Kernel::OM->Get('Kernel::System::Valid')->ValidLookup(
        Valid => 'valid',
    );
    my @Calendars = $CalendarObject->CalendarList(
        UserID  => $Self->{UserID},
        ValidID => $ValidID,
    );

    # check if we found some
    if (@Calendars) {

        for my $Calendar (@Calendars) {
            $Param{CalendarData}->{ $Calendar->{CalendarID} } = {
                CalendarName => $Calendar->{CalendarName},
                Color        => $Calendar->{Color},
            };
        }

        $LayoutObject->Block(
            Name => 'AppointmentCreateButton',
        );

        # get appointment object
        my $AppointmentObject = $Kernel::OM->Get('Kernel::System::Calendar::Appointment');

        my @ViewableAppointments;
        for my $Calendar (@Calendars) {
            my @Appointments = $AppointmentObject->AppointmentList(
                CalendarID => $Calendar->{CalendarID},
                Result     => 'HASH',
                %Param,
            );

            push @ViewableAppointments, @Appointments;
        }

        if (@ViewableAppointments) {

            # sort by start date
            @ViewableAppointments = sort { $a->{StartTime} cmp $b->{StartTime} } @ViewableAppointments;

            my $LastDay = '';
            for my $Appointment (@ViewableAppointments) {

                # save time stamps for display before calculation
                $Appointment->{StartDate} = $Appointment->{StartTime};
                $Appointment->{EndDate}   = $Appointment->{EndTime};

                # end times for all day appointments are inclusive, subtract whole day
                if ( $Appointment->{AllDay} ) {
                    my $StartTime = $CalendarHelperObject->SystemTimeGet(
                        String => $Appointment->{StartTime},
                    );
                    my $EndTime = $CalendarHelperObject->SystemTimeGet(
                        String => $Appointment->{EndTime},
                    );
                    $EndTime -= 86400;
                    if ( $EndTime < $StartTime ) {
                        $EndTime = $StartTime;
                    }
                    $Appointment->{EndDate} = $CalendarHelperObject->TimestampGet(
                        SystemTime => $EndTime,
                    );
                }

                # formatted date/time strings used in display
                $Appointment->{StartDate} = $LayoutObject->{LanguageObject}->FormatTimeString(
                    $Appointment->{StartDate},
                    'DateFormat' . ( $Appointment->{AllDay} ? 'Short' : '' )
                );
                $Appointment->{EndDate} = $LayoutObject->{LanguageObject}->FormatTimeString(
                    $Appointment->{EndDate},
                    'DateFormat' . ( $Appointment->{AllDay} ? 'Short' : '' )
                );

                # formatted notification date used in display
                $Appointment->{NotificationDate} = $LayoutObject->{LanguageObject}->FormatTimeString(
                    $Appointment->{NotificationDate},
                    'DateFormat'
                );

                # cut the time portion
                $Param{StartDay} = substr( $Appointment->{StartTime}, 0, 10 );

                if ( $LastDay ne $Param{StartDay} ) {
                    $LayoutObject->Block(
                        Name => 'AppointmentGroup',
                        Data => {
                            CurrentDay => $LayoutObject->{LanguageObject}->FormatTimeString(
                                $Appointment->{StartTime},
                                'DateFormatShort'
                            ),
                            Class => $LastDay ? '' : 'First',
                        },
                    );

                    $LastDay = $Param{StartDay};
                }

                if ( $Appointment->{AllDay} ) {
                    $Appointment->{StartTime} = $Param{StartDate};
                    $Appointment->{EndTime}   = $Param{EndDate};
                }

                $LayoutObject->Block(
                    Name => 'AppointmentActionRow',
                    Data => {
                        %Param,
                        %{$Appointment},
                    },
                );
            }
        }
        else {
            $LayoutObject->Block(
                Name => 'AppointmentNoDataRow',
            );
        }
    }
    else {
        $LayoutObject->Block(
            Name => 'CalendarsNotFound',
        );
    }

    # start output
    my $Output = $LayoutObject->Header();
    $Output .= $LayoutObject->NavigationBar();

    $Output .= $LayoutObject->Output(
        TemplateFile => 'AgentAppointmentAgendaOverview',
        Data         => \%Param,
    );

    # get page footer
    $Output .= $LayoutObject->Footer() if $Self->{Subaction} ne 'AJAXFilterUpdate';
    return $Output;
}

1;
