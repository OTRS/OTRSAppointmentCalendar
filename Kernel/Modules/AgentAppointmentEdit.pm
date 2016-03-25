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

    my $JSON = '';

    # check request
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

        # get time object
        my $TimeObject = $Kernel::OM->Get('Kernel::System::Time');

        my %Appointment;
        if ( $GetParam{AppointmentID} ) {
            %Appointment = $AppointmentObject->AppointmentGet(
                AppointmentID => $GetParam{AppointmentID},
            );

            # get start time components
            my $StartTime = $TimeObject->TimeStamp2SystemTime(
                String => $Appointment{StartTime},
            );
            (
                my $S, $Appointment{StartMinute},
                $Appointment{StartHour}, $Appointment{StartDay}, $Appointment{StartMonth},
                $Appointment{StartYear}
            ) = $TimeObject->SystemTime2Date( SystemTime => $StartTime );

            # get end time components
            my $EndTime = $TimeObject->TimeStamp2SystemTime(
                String => $Appointment{EndTime},
            );
            (
                $S, $Appointment{EndMinute}, $Appointment{EndHour}, $Appointment{EndDay},
                $Appointment{EndMonth}, $Appointment{EndYear}
            ) = $TimeObject->SystemTime2Date( SystemTime => $EndTime );

            # get recurrence until components
            if ( $Appointment{RecurrenceUntil} ) {
                my $RecurrenceUntil = $TimeObject->TimeStamp2SystemTime(
                    String => $Appointment{RecurrenceUntil},
                );
                (
                    $S, $Appointment{RecurrenceUntilMinute}, $Appointment{RecurrenceUntilHour},
                    $Appointment{RecurrenceUntilDay}, $Appointment{RecurrenceUntilMonth},
                    $Appointment{RecurrenceUntilYear}
                ) = $TimeObject->SystemTime2Date( SystemTime => $RecurrenceUntil );
            }
        }

        # calendar selection
        $Param{CalendarIDStrg} = $LayoutObject->BuildSelection(
            Data         => \@CalendarData,
            SelectedID   => $Appointment{CalendarID} // $GetParam{CalendarID},
            Name         => 'CalendarID',
            Multiple     => 0,
            Class        => 'Modernize',
            PossibleNone => 0,
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
        );

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

        # recurrence frequency selection
        $Param{RecurrenceFrequencyString} = $LayoutObject->BuildSelection(
            Data => [
                {
                    Key   => '0',
                    Value => Translatable('None'),
                },
                {
                    Key   => '1',
                    Value => Translatable('Every Day'),
                },
                {
                    Key   => '7',
                    Value => Translatable('Every Week'),
                },
                {
                    Key   => '30',
                    Value => Translatable('Every Month'),
                },
                {
                    Key   => '365',
                    Value => Translatable('Every Year'),
                },
            ],
            SelectedID => $Appointment{RecurrenceFrequency} // $GetParam{RecurrenceFrequency},
            Name       => 'RecurrenceFrequency',
            Multiple   => 0,
            Class      => 'Modernize',
            PossibleNone => 0,
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
        );

        # get current and start time for difference
        my $SystemTime = $TimeObject->SystemTime();
        my $StartTime  = $TimeObject->Date2SystemTime(
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
        );

        # html mask output
        $LayoutObject->Block(
            Name => 'EditMask',
            Data => {
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

    elsif (
        $Self->{Subaction} eq 'AddAppointment'
        || $Self->{Subaction} eq 'EditAppointment'
        )
    {
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
        if ( $GetParam{Recurring} && $GetParam{RecurrenceFrequency} ) {

            # until ...
            if (
                $GetParam{RecurrenceLimit} eq '1' &&
                $GetParam{RecurrenceUntilYear}    &&
                $GetParam{RecurrenceUntilMonth}   &&
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

        my $Success;

        # TODO: timezone support
        $GetParam{TimezoneID} = 'Europe/Belgrade';
        $GetParam{UserID}     = $Self->{UserID};

        if ( $GetParam{AppointmentID} ) {
            my %Appointment = $AppointmentObject->AppointmentGet(
                AppointmentID => $GetParam{AppointmentID},
            );

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

        # build JSON output
        $JSON = $LayoutObject->JSONEncode(
            Data => {
                Success => $Success ? 1 : 0,
                AppointmentID => $GetParam{AppointmentID} ? $GetParam{AppointmentID} : $Success,
            },
        );
    }

    elsif ( $Self->{Subaction} eq 'DeleteAppointment' ) {

        if ( $GetParam{AppointmentID} ) {

            my $Success = $AppointmentObject->AppointmentDelete(
                %GetParam,
                UserID => $Self->{UserID},
            );

            # build JSON output
            $JSON = $LayoutObject->JSONEncode(
                Data => {
                    Success       => $Success,
                    AppointmentID => $GetParam{AppointmentID},
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

1;
