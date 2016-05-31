# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Calendar::Event::Notification;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Log',
    'Kernel::System::Daemon::SchedulerDB',
    'Kernel::System::Calendar::Appointment',
    'Kernel::System::Calendar::Helper',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(Event Data Config UserID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    if ( !$Param{Data}->{AppointmentID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need AppointmentID in Data!',
        );
        return;
    }

    # get a local appointment object
    my $AppointmentObject = $Kernel::OM->Get('Kernel::System::Calendar::Appointment');

    # get the next upcoming appointment
    my %UpcomingAppointment = $AppointmentObject->AppointmentUpcomingGet();

    return if !IsHashRefWithData( \%UpcomingAppointment );
    return if !$UpcomingAppointment{StartTime};

    # get a local scheduler db object
    my $SchedulerDBObject = $Kernel::OM->Get('Kernel::System::Daemon::SchedulerDB');

    # get a list of already stored future tasks
    my @FutureTaskList = $SchedulerDBObject->FutureTaskList(
        Type => 'CalendarAppointment',
    );

    # check if it is needed to update the future task list
    if ( scalar @FutureTaskList == 1 ) {

        # get the stored future task
        my %StoredFutureTask = $SchedulerDBObject->FutureTaskGet(
            TaskID => $FutureTaskList[0]->{TaskID},
        );

        if ( IsHashRefWithData( \%StoredFutureTask ) ) {

            # get a local calendar helper object
            my $CalendarHelperObject = $Kernel::OM->Get('Kernel::System::Calendar::Helper');

            # get unix timestamps of stored, modified and upcoming starttime to compare
            my $StoredAppointmentStartTime = $CalendarHelperObject->SystemTimeGet(
                String => $StoredFutureTask{Data}->{StartTime},
            );
            my $UpcomingAppointmentStartTime = $CalendarHelperObject->SystemTimeGet(
                String => $UpcomingAppointment{StartTime},
            );

            # do nothing if the upcoming start time and id equals the stored values
            if (
                $UpcomingAppointmentStartTime == $StoredAppointmentStartTime
                && $UpcomingAppointment{AppointmentID} == $StoredFutureTask{Data}->{AppointmentID}
                )
            {
                return 1;
            }
        }
    }

    # flush obsolete future tasks
    if ( IsArrayRefWithData( \@FutureTaskList ) ) {

        FUTURETASK:
        for my $FutureTask (@FutureTaskList) {

            next FUTURETASK if !$FutureTask;
            next FUTURETASK if !IsHashRefWithData($FutureTask);

            my $Success = $SchedulerDBObject->FutureTaskDelete(
                TaskID => $FutureTask->{TaskID},
            );

            if ( !$Success ) {
                $Kernel::OM->Get('Kernel::System::Log')->Log(
                    Priority => 'error',
                    Message  => "Could not delete future task with id $FutureTask->{TaskID}!",
                );
                return;
            }
        }
    }

    # schedule new future task for notification actions
    my $TaskID = $Kernel::OM->Get('Kernel::System::Daemon::SchedulerDB')->FutureTaskAdd(
        ExecutionTime => $UpcomingAppointment{StartTime},
        Type          => 'CalendarAppointment',
        Data          => {
            AppointmentID => $UpcomingAppointment{AppointmentID},
            ParentID      => $UpcomingAppointment{ParentID},
            CalendarID    => $UpcomingAppointment{CalendarID},
            StartTime     => $UpcomingAppointment{StartTime},
            EndTime       => $UpcomingAppointment{EndTime},
        },
    );

    if ( !$TaskID ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Could not schedule future task for AppointmentID $UpcomingAppointment{AppointmentID}!",
        );
        return;
    }

    return 1;
}

1;
