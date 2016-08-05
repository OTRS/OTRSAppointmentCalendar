# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

use strict;
use warnings;
use utf8;

use vars (qw($Self));

use Kernel::System::VariableCheck qw(:all);

# get needed objects
my $CalendarObject    = $Kernel::OM->Get('Kernel::System::Calendar');
my $AppointmentObject = $Kernel::OM->Get('Kernel::System::Calendar::Appointment');

# get helper object
$Kernel::OM->ObjectParamAdd(
    'Kernel::System::UnitTest::Helper' => {
        RestoreDatabase => 1,
    },
);
my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');

# get needed objects
my $GroupObject = $Kernel::OM->Get('Kernel::System::Group');
my $UserObject  = $Kernel::OM->Get('Kernel::System::User');

# create test user
my $UserLogin = $Helper->TestUserCreate();
my $UserID = $UserObject->UserLookup( UserLogin => $UserLogin );

$Self->True(
    $UserID,
    "Test user $UserID created",
);

my $RandomID = $Helper->GetRandomID();

# create test group
my $GroupName = 'test-calendar-group-' . $RandomID;
my $GroupID   = $GroupObject->GroupAdd(
    Name    => $GroupName,
    ValidID => 1,
    UserID  => 1,
);

$Self->True(
    $GroupID,
    "Test group $GroupID created",
);

# add test user to test group
my $Success = $GroupObject->PermissionGroupUserAdd(
    GID        => $GroupID,
    UID        => $UserID,
    Permission => {
        ro        => 1,
        move_into => 1,
        create    => 1,
        owner     => 1,
        priority  => 1,
        rw        => 1,
    },
    UserID => 1,
);

$Self->True(
    $Success,
    "Test user $UserID added to test group $GroupID",
);

# create test calendar
my %Calendar = $CalendarObject->CalendarCreate(
    CalendarName => "Calendar-$RandomID",
    Color        => '#3A87AD',
    GroupID      => $GroupID,
    UserID       => $UserID,
);

$Self->True(
    $Calendar{CalendarID},
    "CalendarCreate - $Calendar{CalendarID}",
);

#
# Tests for AppointmentCreate(), AppointmentGet() and AppointmentUpdate()
#
my @Tests = (
    {
        Name    => 'AppointmentCreate - No params',
        Config  => {},
        Success => 0,
    },
    {
        Name   => 'AppointmentCreate - No CalendarID',
        Config => {
            Title     => "Appointment-$RandomID",
            StartTime => '2016-01-01 16:00:00',
            EndTime   => '2016-01-01 17:00:00',
            UserID    => $UserID,
        },
        Success => 0,
    },
    {
        Name   => 'AppointmentCreate - No Title',
        Config => {
            CalendarID => $Calendar{CalendarID},
            StartTime  => '2016-01-01 16:00:00',
            EndTime    => '2016-01-01 17:00:00',
            UserID     => $UserID,
        },
        Success => 0,
    },
    {
        Name   => 'AppointmentCreate - No StartTime',
        Config => {
            CalendarID => $Calendar{CalendarID},
            Title      => "Appointment-$RandomID",
            EndTime    => '2016-01-01 17:00:00',
            UserID     => $UserID,
        },
        Success => 0,
    },
    {
        Name   => 'AppointmentCreate - No EndTime',
        Config => {
            CalendarID => $Calendar{CalendarID},
            Title      => "Appointment-$RandomID",
            StartTime  => '2016-01-01 16:00:00',
            UserID     => $UserID,
        },
        Success => 0,
    },
    {
        Name   => 'AppointmentCreate - No UserID',
        Config => {
            CalendarID => $Calendar{CalendarID},
            Title      => "Appointment-$RandomID",
            StartTime  => '2016-01-01 16:00:00',
            EndTime    => '2016-01-01 17:00:00',
        },
        Success => 0,
    },
    {
        Name   => 'AppointmentCreate - All required params',
        Config => {
            CalendarID => $Calendar{CalendarID},
            Title      => "Appointment-$RandomID",
            StartTime  => '2016-01-01 16:00:00',
            EndTime    => '2016-01-01 17:00:00',
            UserID     => $UserID,
        },
        Success => 1,
    },
    {
        Name   => 'AppointmentCreate - Description, Location and AllDay',
        Config => {
            CalendarID  => $Calendar{CalendarID},
            Title       => "Appointment2-$RandomID",
            Description => 'Calendar Appointment',
            Location    => 'Germany',
            StartTime   => '2016-01-02 00:00:00',
            EndTime     => '2016-01-02 00:00:00',
            AllDay      => 1,
            UserID      => $UserID,
        },
        Update => {
            CalendarID  => $Calendar{CalendarID},
            Title       => "Appointment2-$RandomID",
            Description => 'Some description',
            Location    => 'USA',
            StartTime   => '2016-01-03 16:00:00',
            EndTime     => '2016-01-03 17:00:00',
            AllDay      => 0,
            UserID      => $UserID,
        },
        Success => 1,
    },
);

for my $Test (@Tests) {

    # make the call
    my $AppointmentID = $AppointmentObject->AppointmentCreate(
        %{ $Test->{Config} },
    );

    if ( $Test->{Success} ) {
        $Self->True(
            $AppointmentID,
            "$Test->{Name} - Success",
        );

        my %Appointment = $AppointmentObject->AppointmentGet(
            AppointmentID => $AppointmentID,
        );

        KEY:
        for my $Key ( sort keys %{ $Test->{Config} } ) {
            next KEY if $Key eq 'UserID';

            $Self->Is(
                $Appointment{$Key},
                $Test->{Config}->{$Key},
                "$Test->{Name} - Returned data",
            );
        }

        if ( $Test->{Update} ) {
            my $Success = $AppointmentObject->AppointmentUpdate(
                %{ $Test->{Update} },
                AppointmentID => $AppointmentID,
            );
            $Self->True(
                $Success,
                "$Test->{Name} - Updated appointment",
            );

            %Appointment = $AppointmentObject->AppointmentGet(
                AppointmentID => $AppointmentID,
            );

            KEY:
            for my $Key ( sort keys %{ $Test->{Update} } ) {
                next KEY if $Key eq 'UserID';

                $Self->Is(
                    $Appointment{$Key},
                    $Test->{Update}->{$Key},
                    "$Test->{Name} - Updated data",
                );
            }
        }
    }
    else {
        $Self->False(
            $AppointmentID,
            "$Test->{Name} - No success",
        );
    }
}

#
# Tests for AppointmentList()
#
@Tests = (
    {
        Name    => 'AppointmentList - No params',
        Config  => {},
        Success => 0,
    },
    {
        Name   => 'AppointmentList - CalendarID',
        Config => {
            CalendarID => $Calendar{CalendarID},
        },
        Count   => 2,
        Success => 1,
    },
    {
        Name   => 'AppointmentList - StartTime and EndTime',
        Config => {
            CalendarID => $Calendar{CalendarID},
            StartTime  => '2016-01-01 00:00:00',
            EndTime    => '2016-01-04 00:00:00',
        },
        Count   => 2,
        Success => 1,
    },
    {
        Name   => 'AppointmentList - Before appointments',
        Config => {
            CalendarID => $Calendar{CalendarID},
            EndTime    => '2015-12-31 00:00:00',
        },
        Count   => 0,
        Success => 1,
    },
    {
        Name   => 'AppointmentList - After appointments',
        Config => {
            CalendarID => $Calendar{CalendarID},
            StartTime  => '2016-01-04 00:00:00',
        },
        Count   => 0,
        Success => 1,
    },
);

for my $Test (@Tests) {

    # make the call
    my @Appointments = $AppointmentObject->AppointmentList(
        %{ $Test->{Config} },
    );

    if ( $Test->{Success} ) {
        $Self->Is(
            scalar @Appointments,
            $Test->{Count},
            "$Test->{Name} - Result count",
        );

        if ( $Test->{Config}->{Result} && $Test->{Config}->{Result} eq 'ARRAY' ) {

        }
        else {
            for my $Appointment (@Appointments) {
                for my $Key (qw(AppointmentID CalendarID UniqueID Title StartTime EndTime)) {
                    $Self->True(
                        $Appointment->{$Key},
                        "$Test->{Name} - $Key exists",
                    );
                }
            }
        }
    }
    else {
        $Self->IsDeeply(
            \@Appointments,
            [],
            "$Test->{Name} - No success",
        );
    }
}

#
# Tests for recurring appointments
#
@Tests = (
    {
        Name   => 'Recurring - Once per day',
        Config => {
            CalendarID         => $Calendar{CalendarID},
            Title              => 'Recurring appointment',
            StartTime          => '2016-03-01 16:00:00',
            EndTime            => '2016-03-01 17:00:00',
            AllDay             => 1,
            Recurring          => 1,
            RecurrenceType     => 'Daily',
            RecurrenceInterval => 1,                         # once per day
            RecurrenceUntil    => '2016-03-06 00:00:00',     # included last day
            UserID             => $UserID,
        },
        List => {
            CalendarID => $Calendar{CalendarID},
            StartTime  => '2016-03-01 00:00:00',
            EndTime    => '2016-03-06 00:00:00',
            Count      => 5,
        },
        Result => [
            '2016-03-01 16:00:00',
            '2016-03-02 16:00:00',
            '2016-03-03 16:00:00',
            '2016-03-04 16:00:00',
            '2016-03-05 16:00:00',
        ],
        Success => 1,
    },
    {
        Name   => 'Recurring - Once per month',
        Config => {
            CalendarID         => $Calendar{CalendarID},
            Title              => 'Recurring appointment',
            StartTime          => '2012-01-31 15:00:00',
            EndTime            => '2012-01-31 16:00:00',
            Recurring          => 1,
            RecurrenceType     => 'Monthly',
            RecurrenceInterval => 1,                         # once per month
            RecurrenceUntil    => '2013-01-03 16:00:00',     # included last day
            UserID             => $UserID,
        },
        List => {
            CalendarID => $Calendar{CalendarID},
            StartTime  => '2012-01-31 00:00:00',
            EndTime    => '2013-01-04 00:00:00',
            Count      => 12,
        },
        Result => [
            '2012-01-31 15:00:00',
            '2012-02-29 15:00:00',
            '2012-03-31 15:00:00',
            '2012-04-30 15:00:00',
            '2012-05-31 15:00:00',
            '2012-06-30 15:00:00',
            '2012-07-31 15:00:00',
            '2012-08-31 15:00:00',
            '2012-09-30 15:00:00',
            '2012-10-31 15:00:00',
            '2012-11-30 15:00:00',
            '2012-12-31 15:00:00',
        ],
        Success => 1,
    },
    {
        Name   => 'Recurring - Every month all-day per month',
        Config => {
            CalendarID      => $Calendar{CalendarID},
            Title           => 'Recurring appointment',
            StartTime       => '2008-04-30 00:00:00',
            EndTime         => '2008-05-01 00:00:00',
            AllDay          => 1,
            Recurring       => 1,
            RecurrenceType  => 'Monthly',
            RecurrenceCount => 3,
            UserID          => $UserID,
        },
        List => {
            CalendarID => $Calendar{CalendarID},
            StartTime  => '2008-04-30 00:00:00',
            EndTime    => '2008-07-01 00:00:00',
            Count      => 3,
        },
        Result => [
            '2008-04-30 00:00:00',    # on some systems with older date time library
            '2008-05-30 00:00:00',    # there will be an appointment on 2008-05-31
            '2008-06-30 00:00:00',    # but not on 2008-06-30
        ],
        Success => 1,
    },
    {
        Name   => 'Recurring - Missing RecurrenceType',
        Config => {
            CalendarID         => $Calendar{CalendarID},
            Title              => 'Recurring appointment',
            StartTime          => '2016-03-01 16:00:00',
            EndTime            => '2016-03-01 17:00:00',
            AllDay             => 1,
            Recurring          => 1,
            RecurrenceInterval => 1,
            RecurrenceUntil    => '2016-03-06 00:00:00',
            UserID             => $UserID,
        },
        Success => 0,
    },
    {
        Name   => 'Recurring - Wrong RecurrenceType',
        Config => {
            CalendarID         => $Calendar{CalendarID},
            Title              => 'Recurring appointment',
            StartTime          => '2016-03-01 16:00:00',
            EndTime            => '2016-03-01 17:00:00',
            AllDay             => 1,
            Recurring          => 1,
            RecurrenceType     => 'WrongDaily',              # WrongDaily is not supported
            RecurrenceInterval => 1,
            RecurrenceUntil    => '2016-03-06 00:00:00',
            UserID             => $UserID,
        },
        Success => 0,
    },
    {
        Name   => 'Recurring - Without RecurrenceFrequency',
        Config => {
            CalendarID         => $Calendar{CalendarID},
            Title              => 'Recurring appointment',
            StartTime          => '2018-03-01 16:00:00',
            EndTime            => '2018-03-01 17:00:00',
            AllDay             => 1,
            Recurring          => 1,
            RecurrenceType     => 'CustomDaily',
            RecurrenceInterval => 1,
            RecurrenceCount    => 2,
            UserID             => $UserID,
        },
        List => {
            CalendarID => $Calendar{CalendarID},
            StartTime  => '2018-03-01 00:00:00',
            EndTime    => '2018-03-03 00:00:00',
            Count      => 2,
        },
        Result => [
            '2018-03-01 16:00:00',
            '2018-03-02 16:00:00',
        ],
        Success => 1,
    },
    {
        Name   => 'Recurring - Missing RecurrenceFrequency (CustomWeekly)',
        Config => {
            CalendarID         => $Calendar{CalendarID},
            Title              => 'Recurring appointment',
            StartTime          => '2016-03-01 16:00:00',
            EndTime            => '2016-03-01 17:00:00',
            AllDay             => 1,
            Recurring          => 1,
            RecurrenceType     => 'CustomWeekly',
            RecurrenceInterval => 1,
            RecurrenceUntil    => '2016-03-06 00:00:00',
            UserID             => $UserID,
        },
        Success => 0,
    },
    {
        Name   => 'Recurring - Missing RecurrenceFrequency (CustomMonthly)',
        Config => {
            CalendarID         => $Calendar{CalendarID},
            Title              => 'Recurring appointment',
            StartTime          => '2016-03-01 16:00:00',
            EndTime            => '2016-03-01 17:00:00',
            AllDay             => 1,
            Recurring          => 1,
            RecurrenceType     => 'CustomMonthly',
            RecurrenceInterval => 1,
            RecurrenceUntil    => '2016-03-06 00:00:00',
            UserID             => $UserID,
        },
        Success => 0,
    },
    {
        Name   => 'Recurring - Missing RecurrenceFrequency (CustomYearly)',
        Config => {
            CalendarID         => $Calendar{CalendarID},
            Title              => 'Recurring appointment',
            StartTime          => '2016-03-01 16:00:00',
            EndTime            => '2016-03-01 17:00:00',
            AllDay             => 1,
            Recurring          => 1,
            RecurrenceType     => 'CustomYearly',
            RecurrenceInterval => 1,
            RecurrenceUntil    => '2016-03-06 00:00:00',
            UserID             => $UserID,
        },
        Success => 0,
    },
    {
        Name   => 'Recurring - Once per week',
        Config => {
            CalendarID         => $Calendar{CalendarID},
            Title              => 'Weekly recurring appointment',
            StartTime          => '2016-10-01 16:00:00',
            EndTime            => '2016-10-01 17:00:00',
            AllDay             => 1,
            Recurring          => 1,
            RecurrenceType     => 'Weekly',
            RecurrenceInterval => 1,                                # each week
            RecurrenceUntil    => '2016-10-06 00:00:00',            # included last day
            UserID             => $UserID,
        },
        List => {
            CalendarID => $Calendar{CalendarID},
            StartTime  => '2016-10-01 00:00:00',
            EndTime    => '2016-10-07 00:00:00',
            Count      => 1,
        },
        Result => [
            '2016-10-01 16:00:00',
        ],
        Success => 1,
    },
    {
        Name   => 'Recurring - Once per month',
        Config => {
            CalendarID         => $Calendar{CalendarID},
            Title              => 'Monthly recurring appointment',
            StartTime          => '2016-10-07 16:00:00',
            EndTime            => '2016-10-07 17:00:00',
            AllDay             => 1,
            Recurring          => 1,
            RecurrenceType     => 'Monthly',
            RecurrenceInterval => 1,                                 # each month
            RecurrenceCount    => 3,                                 # 3 months
            UserID             => $UserID,
        },
        List => {
            CalendarID => $Calendar{CalendarID},
            StartTime  => '2016-10-07 00:00:00',
            EndTime    => '2017-01-08 00:00:00',
            Count      => 3,
        },
        Result => [
            '2016-10-07 16:00:00',
            '2016-11-07 16:00:00',
            '2016-12-07 16:00:00',
        ],
        Success => 1,
    },
    {
        Name   => 'Recurring - Once per year',
        Config => {
            CalendarID         => $Calendar{CalendarID},
            Title              => 'Yearly recurring appointment',
            StartTime          => '2027-10-10 16:00:00',
            EndTime            => '2027-10-10 17:00:00',
            AllDay             => 1,
            Recurring          => 1,
            RecurrenceType     => 'Yearly',
            RecurrenceInterval => 1,                                # each year
            RecurrenceCount    => 3,                                # 3 years
            UserID             => $UserID,
        },
        List => {
            CalendarID => $Calendar{CalendarID},
            StartTime  => '2027-10-10 00:00:00',
            EndTime    => '2030-10-11 00:00:00',
            Count      => 3,
        },
        Result => [
            '2027-10-10 16:00:00',
            '2028-10-10 16:00:00',
            '2029-10-10 16:00:00',
        ],
        Success => 1,
    },
    {
        Name   => 'Recurring - Every two days',
        Config => {
            CalendarID         => $Calendar{CalendarID},
            Title              => 'Custom daily recurring appointment',
            Description        => 'Description',
            Location           => 'Germany',
            StartTime          => '2017-01-01 16:00:00',
            EndTime            => '2017-01-01 17:00:00',
            AllDay             => 1,
            Recurring          => 1,
            RecurrenceType     => 'CustomDaily',
            RecurrenceInterval => 2,
            RecurrenceCount    => 3,                                      # 3 appointments
            UserID             => $UserID,
        },
        List => {
            CalendarID => $Calendar{CalendarID},
            StartTime  => '2017-01-01 00:00:00',
            EndTime    => '2017-01-06 00:00:00',
            Count      => 3,
        },
        Result => [
            '2017-01-01 16:00:00',
            '2017-01-03 16:00:00',
            '2017-01-05 16:00:00',
        ],
        Success => 1,
    },
    {
        Name   => 'Recurring - On Wednesday, recurring every two weeks on Monday and Friday',
        Config => {
            CalendarID          => $Calendar{CalendarID},
            Title               => 'Custom weekly recurring appointment',
            StartTime           => '2016-05-04 16:00:00',                   # wednesday
            EndTime             => '2016-05-04 17:00:00',
            AllDay              => 1,
            Recurring           => 1,
            RecurrenceType      => 'CustomWeekly',
            RecurrenceInterval  => 2,                                       # each 2nd
            RecurrenceFrequency => [ 1, 5 ],                                # Monday and Friday
            RecurrenceCount     => 3,                                       # 3 appointments
            UserID              => $UserID,
        },
        List => {
            CalendarID => $Calendar{CalendarID},
            StartTime  => '2016-05-04 00:00:00',
            EndTime    => '2016-05-28 00:00:00',
            Count      => 3,
        },
        Result => [
            '2016-05-04 16:00:00',
            '2016-05-06 16:00:00',
            '2016-05-16 16:00:00',
        ],
        Success => 1,
    },
    {
        Name   => 'Recurring - Every 2nd month on 5th, 10th and 15th day',
        Config => {
            CalendarID          => $Calendar{CalendarID},
            Title               => 'Custom monthly recurring appointment',
            StartTime           => '2019-07-05 16:00:00',
            EndTime             => '2019-07-05 17:00:00',
            AllDay              => 1,
            Recurring           => 1,
            RecurrenceType      => "CustomMonthly",
            RecurrenceInterval  => 2,                                        # every 2 months
            RecurrenceFrequency => [ 5, 10, 15 ],                            # days in month
            RecurrenceCount     => 6,                                        # 3 appointments
            UserID              => $UserID,
        },
        List => {
            CalendarID => $Calendar{CalendarID},
            StartTime  => '2019-07-05 00:00:00',
            EndTime    => '2019-10-16 00:00:00',
            Count      => 6,
        },
        Result => [
            '2019-07-05 16:00:00',
            '2019-07-10 16:00:00',
            '2019-07-15 16:00:00',
            '2019-09-05 16:00:00',
            '2019-09-10 16:00:00',
            '2019-09-15 16:00:00',
        ],
        Success => 1,
    },
    {
        Name   => 'Recurring - Every 2nd year on January 5th, February and December',
        Config => {
            CalendarID          => $Calendar{CalendarID},
            Title               => 'Custom yearly recurring appointment',
            StartTime           => '2022-01-05 16:00:00',
            EndTime             => '2022-01-05 17:00:00',
            AllDay              => 1,
            Recurring           => 1,
            RecurrenceType      => 'CustomYearly',
            RecurrenceInterval  => 2,                                       # every 2 years
            RecurrenceFrequency => [ 1, 2, 12 ],                            # months
            RecurrenceCount     => 3,                                       # 3 appointments
            UserID              => $UserID,
        },
        List => {
            CalendarID => $Calendar{CalendarID},
            StartTime  => '2022-01-05 00:00:00',
            EndTime    => '2024-12-06 00:00:00',
            Count      => 3,
        },
        Result => [
            '2022-01-05 16:00:00',
            '2022-02-05 16:00:00',
            '2022-12-05 16:00:00',
        ],
        Success => 1,
    },
    {
        Name   => 'Recurring - Every 2 weeks, on Mon, Wed, Thu, Fri and Sun',
        Config => {
            CalendarID          => $Calendar{CalendarID},
            Title               => 'Custom recurring appointment',
            Description         => 'Description',
            StartTime           => '2025-09-01 00:00:00',
            EndTime             => '2025-09-01 00:00:00',
            AllDay              => 1,
            Recurring           => 1,
            RecurrenceType      => 'CustomWeekly',
            RecurrenceInterval  => 2,                                # each 2 weeks
            RecurrenceFrequency => [ 1, 3, 4, 5, 7 ],                # Mon, Wed, Thu, Fri, Sun
            RecurrenceUntil     => '2026-10-01 00:00:00',            # october
            UserID              => $UserID,
        },
        List => {
            CalendarID => $Calendar{CalendarID},
            StartTime  => '2025-09-01 00:00:00',
            EndTime    => '2026-10-13 00:00:00',
            Count      => 143,
        },
        Result => [
            '2025-09-01 00:00:00',
            '2025-09-03 00:00:00',
            '2025-09-04 00:00:00',
            '2025-09-05 00:00:00',
            '2025-09-07 00:00:00',
            '2025-09-15 00:00:00',
            '2025-09-17 00:00:00',
            '2025-09-18 00:00:00',
            '2025-09-19 00:00:00',
            '2025-09-21 00:00:00',
            '2025-09-29 00:00:00',
            '2025-10-01 00:00:00',
            '2025-10-02 00:00:00',
            '2025-10-03 00:00:00',
            '2025-10-05 00:00:00',
            '2025-10-13 00:00:00',
            '2025-10-15 00:00:00',
            '2025-10-16 00:00:00',
            '2025-10-17 00:00:00',
            '2025-10-19 00:00:00',
            '2025-10-27 00:00:00',
            '2025-10-29 00:00:00',
            '2025-10-30 00:00:00',
            '2025-10-31 00:00:00',
            '2025-11-02 00:00:00',
            '2025-11-10 00:00:00',
            '2025-11-12 00:00:00',
            '2025-11-13 00:00:00',
            '2025-11-14 00:00:00',
            '2025-11-16 00:00:00',
            '2025-11-24 00:00:00',
            '2025-11-26 00:00:00',
            '2025-11-27 00:00:00',
            '2025-11-28 00:00:00',
            '2025-11-30 00:00:00',
            '2025-12-08 00:00:00',
            '2025-12-10 00:00:00',
            '2025-12-11 00:00:00',
            '2025-12-12 00:00:00',
            '2025-12-14 00:00:00',
            '2025-12-22 00:00:00',
            '2025-12-24 00:00:00',
            '2025-12-25 00:00:00',
            '2025-12-26 00:00:00',
            '2025-12-28 00:00:00',
            '2026-01-05 00:00:00',
            '2026-01-07 00:00:00',
            '2026-01-08 00:00:00',
            '2026-01-09 00:00:00',
            '2026-01-11 00:00:00',
            '2026-01-19 00:00:00',
            '2026-01-21 00:00:00',
            '2026-01-22 00:00:00',
            '2026-01-23 00:00:00',
            '2026-01-25 00:00:00',
            '2026-02-02 00:00:00',
            '2026-02-04 00:00:00',
            '2026-02-05 00:00:00',
            '2026-02-06 00:00:00',
            '2026-02-08 00:00:00',
            '2026-02-16 00:00:00',
            '2026-02-18 00:00:00',
            '2026-02-19 00:00:00',
            '2026-02-20 00:00:00',
            '2026-02-22 00:00:00',
            '2026-03-02 00:00:00',
            '2026-03-04 00:00:00',
            '2026-03-05 00:00:00',
            '2026-03-06 00:00:00',
            '2026-03-08 00:00:00',
            '2026-03-16 00:00:00',
            '2026-03-18 00:00:00',
            '2026-03-19 00:00:00',
            '2026-03-20 00:00:00',
            '2026-03-22 00:00:00',
            '2026-03-30 00:00:00',
            '2026-04-01 00:00:00',
            '2026-04-02 00:00:00',
            '2026-04-03 00:00:00',
            '2026-04-05 00:00:00',
            '2026-04-13 00:00:00',
            '2026-04-15 00:00:00',
            '2026-04-16 00:00:00',
            '2026-04-17 00:00:00',
            '2026-04-19 00:00:00',
            '2026-04-27 00:00:00',
            '2026-04-29 00:00:00',
            '2026-04-30 00:00:00',
            '2026-05-01 00:00:00',
            '2026-05-03 00:00:00',
            '2026-05-11 00:00:00',
            '2026-05-13 00:00:00',
            '2026-05-14 00:00:00',
            '2026-05-15 00:00:00',
            '2026-05-17 00:00:00',
            '2026-05-25 00:00:00',
            '2026-05-27 00:00:00',
            '2026-05-28 00:00:00',
            '2026-05-29 00:00:00',
            '2026-05-31 00:00:00',
            '2026-06-08 00:00:00',
            '2026-06-10 00:00:00',
            '2026-06-11 00:00:00',
            '2026-06-12 00:00:00',
            '2026-06-14 00:00:00',
            '2026-06-22 00:00:00',
            '2026-06-24 00:00:00',
            '2026-06-25 00:00:00',
            '2026-06-26 00:00:00',
            '2026-06-28 00:00:00',
            '2026-07-06 00:00:00',
            '2026-07-08 00:00:00',
            '2026-07-09 00:00:00',
            '2026-07-10 00:00:00',
            '2026-07-12 00:00:00',
            '2026-07-20 00:00:00',
            '2026-07-22 00:00:00',
            '2026-07-23 00:00:00',
            '2026-07-24 00:00:00',
            '2026-07-26 00:00:00',
            '2026-08-03 00:00:00',
            '2026-08-05 00:00:00',
            '2026-08-06 00:00:00',
            '2026-08-07 00:00:00',
            '2026-08-09 00:00:00',
            '2026-08-17 00:00:00',
            '2026-08-19 00:00:00',
            '2026-08-20 00:00:00',
            '2026-08-21 00:00:00',
            '2026-08-23 00:00:00',
            '2026-08-31 00:00:00',
            '2026-09-02 00:00:00',
            '2026-09-03 00:00:00',
            '2026-09-04 00:00:00',
            '2026-09-06 00:00:00',
            '2026-09-14 00:00:00',
            '2026-09-16 00:00:00',
            '2026-09-17 00:00:00',
            '2026-09-18 00:00:00',
            '2026-09-20 00:00:00',
            '2026-09-28 00:00:00',
            '2026-09-30 00:00:00',
            '2026-10-01 00:00:00',
        ],
        Success => 1,
    },
);

for my $Test (@Tests) {

    # make the call
    my $AppointmentID = $AppointmentObject->AppointmentCreate(
        %{ $Test->{Config} },
    );

    if ( $Test->{Success} ) {
        $Self->True(
            $AppointmentID,
            "$Test->{Name} - Success",
        );

        # check count
        my @Appointments = $AppointmentObject->AppointmentList(
            %{ $Test->{List} // {} },
        );
        $Self->Is(
            scalar @Appointments,
            $Test->{List}->{Count},
            "$Test->{Name} - List count",
        );

        # check start times
        my @StartTimes;
        for my $Appointment (@Appointments) {
            push @StartTimes, $Appointment->{StartTime};
        }
        $Self->IsDeeply(
            \@StartTimes,
            $Test->{Result},
            "$Test->{Name} - Result",
        );
    }
    else {
        $Self->False(
            $AppointmentID,
            "$Test->{Name} - No success",
        );
    }
}

#
# Tests for AppointmentDays()
#
@Tests = (
    {
        Name   => 'AppointmentDays - Missing UserID',
        Config => {
            StartTime => '2016-01-25 00:00:00',
            EndTime   => '2016-02-01 00:00:00',
        },
        Success => 0,
    },
    {
        Name   => 'AppointmentDays - January',
        Config => {
            StartTime => '2016-01-01 00:00:00',
            EndTime   => '2016-02-01 00:00:00',
            UserID    => $UserID,
        },
        Result => {
            '2016-01-01' => 1,
            '2016-01-03' => 1,
        },
        Success => 1,
    },
    {
        Name   => 'AppointmentDays - March',
        Config => {
            StartTime => '2016-03-01 00:00:00',
            EndTime   => '2016-04-01 00:00:00',
            UserID    => $UserID,
        },
        Result => {
            '2016-03-01' => 1,
            '2016-03-02' => 1,
            '2016-03-03' => 1,
            '2016-03-04' => 1,
            '2016-03-05' => 1,
            '2016-03-06' => 1,
        },
        Success => 1,
    },
    {
        Name   => 'AppointmentDays - May',
        Config => {
            StartTime => '2016-05-01 00:00:00',
            EndTime   => '2016-06-01 00:00:00',
            UserID    => $UserID,
        },
        Result => {
            '2016-05-04' => 1,
            '2016-05-06' => 1,
            '2016-05-16' => 1,
        },
        Success => 1,
    },
);

for my $Test (@Tests) {

    # make the call
    my %AppointmentDays = $AppointmentObject->AppointmentDays(
        %{ $Test->{Config} },
    );

    if ( $Test->{Success} ) {

        # check dates
        $Self->IsDeeply(
            \%AppointmentDays,
            $Test->{Result},
            "$Test->{Name} - Result",
        );
    }
    else {
        $Self->IsDeeply(
            \%AppointmentDays,
            {},
            "$Test->{Name} - No success",
        );
    }
}

# get a few UniqueIDs in quick succession
my @UniqueIDs;
for ( 1 .. 10 ) {
    push @UniqueIDs, $AppointmentObject->GetUniqueID(
        CalendarID => 1,
        StartTime  => 1451606400,    # same start time '2016-01-01 00:00:00'
        UserID     => 1,
    );
}

my %Seen;
for my $UniqueID (@UniqueIDs) {
    $Self->False(
        $Seen{$UniqueID}++,
        "UniqueID $UniqueID is unique",
    );
}

# create another test group
my $GroupName2 = 'test-calendar-group-' . $RandomID . '-2';
my $GroupID2   = $GroupObject->GroupAdd(
    Name    => $GroupName2,
    ValidID => 1,
    UserID  => 1,
);

$Self->True(
    $GroupID2,
    "Test group $GroupID2 created",
);

# add test user to test group with ro permissions
$Success = $GroupObject->PermissionGroupUserAdd(
    GID        => $GroupID2,
    UID        => $UserID,
    Permission => {
        ro        => 1,
        move_into => 0,
        create    => 0,
        owner     => 0,
        priority  => 0,
        rw        => 0,
    },
    UserID => 1,
);

$Self->True(
    $Success,
    "Test user $UserID added to test group $GroupID2 with 'ro'",
);

# create another test calendar
my %Calendar2 = $CalendarObject->CalendarCreate(
    CalendarName => "Calendar2-$RandomID",
    Color        => '#3A87AD',
    GroupID      => $GroupID2,
    UserID       => $UserID,
);

$Self->True(
    $Calendar2{CalendarID},
    "CalendarCreate - $Calendar2{CalendarID}",
);

#
# Tests for AppointmentDelete()
#
@Tests = (
    {
        Name    => 'AppointmentDelete - No params',
        Config  => {},
        Success => 0,
    },
    {
        Name   => 'AppointmentDelete - No AppointmentID',
        Config => {
            UserID => $UserID,
        },
        Success => 0,
    },
    {
        Name   => 'AppointmentDelete - No UserID',
        Config => {
            AppointmentID => 1,
        },
        Success => 0,
    },
    {
        Name   => 'AppointmentDelete - All params',
        Create => {
            CalendarID => $Calendar{CalendarID},
            Title      => "Appointment-$RandomID",
            StartTime  => '2016-02-29 00:00:00',
            EndTime    => '2016-02-29 00:00:00',
            AllDay     => 1,
            UserID     => $UserID,
        },
        Config => {
            UserID => $UserID,
        },
        List => {
            CalendarID => $Calendar{CalendarID},
            StartTime  => '2016-02-29 00:00:00',
            EndTime    => '2016-02-29 00:00:00',
        },
        Success => 1,
    },
    {
        Name   => 'AppointmentDelete - No permissions',
        Create => {
            CalendarID => $Calendar2{CalendarID},
            Title      => "Appointment-RO-$RandomID",
            StartTime  => '2016-07-04 19:45:00',
            EndTime    => '2016-07-04 19:45:00',
            UserID     => $UserID,
        },
        Config => {
            UserID => $UserID,
        },
        List => {
            CalendarID => $Calendar2{CalendarID},
            StartTime  => '2016-07-04 00:00:00',
            EndTime    => '2016-07-05 00:00:00',
        },
        Success => 0,
    },

);

for my $Test (@Tests) {

    # create appointment
    if ( $Test->{Create} ) {
        my $AppointmentID = $AppointmentObject->AppointmentCreate(
            %{ $Test->{Create} },
        );
        $Self->True(
            $AppointmentID,
            "$Test->{Name} - Appointment created",
        );

        # save appointment id
        $Test->{Config}->{AppointmentID} = $AppointmentID;

        # check list
        my @AppointmentList = $AppointmentObject->AppointmentList(
            %{ $Test->{List} },
        );
        $Self->Is(
            scalar @AppointmentList,
            1,
            "$Test->{Name} - Appointment list start",
        );
    }

    # make the call
    my $Success = $AppointmentObject->AppointmentDelete(
        %{ $Test->{Config} },
    );

    if ( $Test->{Success} ) {
        $Self->True(
            $Success,
            "$Test->{Name} - Success",
        );
    }
    else {
        $Self->False(
            $Success,
            "$Test->{Name} - No success",
        );
    }

    # check list again
    if ( $Test->{Create} ) {
        my @AppointmentList = $AppointmentObject->AppointmentList(
            %{ $Test->{List} },
        );
        $Self->Is(
            scalar @AppointmentList,
            $Test->{Success} ? 0 : 1,
            "$Test->{Name} - Appointment list end",
        );
    }
}

#
# Notifications
#

# notification creation test definition
my @NotificationCreateTests = (

    # add appointment with notifications disabled explicitly
    {
        Data => {
            CalendarID           => $Calendar{CalendarID},
            Title                => 'Notification appointment 1',
            Description          => 'no notification',
            Location             => 'Germany',
            StartTime            => '2016-09-01 00:00:00',
            EndTime              => '2016-09-02 00:00:00',
            AllDay               => 1,
            TimezoneID           => 1,
            NotificationTemplate => 0,
            UserID               => $UserID,
        },
        Result => {
            NotificationDate                      => '',
            NotificationTemplate                  => '',
            NotificationCustom                    => '',
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => '',
            NotificationCustomRelativePointOfTime => '',
            NotificationCustomDateTime            => '',
        },
    },

    # add appointment with wrong notification template
    {
        Data => {
            CalendarID           => $Calendar{CalendarID},
            Title                => 'Notification appointment 2',
            Description          => 'wrong notification template',
            Location             => 'Germany',
            StartTime            => '2016-09-01 00:00:00',
            EndTime              => '2016-09-02 00:00:00',
            AllDay               => 1,
            TimezoneID           => 1,
            NotificationTemplate => 'WrongNotificationTemplate',
            UserID               => $UserID,
        },
        Result => {
            NotificationDate                      => '',
            NotificationTemplate                  => 'WrongNotificationTemplate',
            NotificationCustom                    => '',
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => '',
            NotificationCustomRelativePointOfTime => '',
            NotificationCustomDateTime            => '',
        },
    },

    # add appointment with notification 0 minute template (AppointmentStart)
    {
        Data => {
            CalendarID           => $Calendar{CalendarID},
            Title                => 'Notification appointment 3',
            Description          => 'notification template start',
            Location             => 'Germany',
            StartTime            => '2016-09-01 00:00:00',
            EndTime              => '2016-09-02 00:00:00',
            AllDay               => 1,
            TimezoneID           => 1,
            NotificationTemplate => 'Start',
            UserID               => $UserID,
        },
        Result => {
            NotificationDate                      => '2016-09-01 00:00:00',
            NotificationTemplate                  => 'Start',
            NotificationCustom                    => '',
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => '',
            NotificationCustomRelativePointOfTime => '',
            NotificationCustomDateTime            => '',
        },
    },

    # add appointment with notification 30 minutes template
    {
        Data => {
            CalendarID           => $Calendar{CalendarID},
            Title                => 'Notification appointment 4',
            Description          => 'notification template 30 minutes before start',
            Location             => 'Germany',
            StartTime            => '2016-09-01 00:00:00',
            EndTime              => '2016-09-02 00:00:00',
            AllDay               => 1,
            TimezoneID           => 1,
            NotificationTemplate => 1800,
            UserID               => $UserID,
        },
        Result => {
            NotificationDate                      => '2016-08-31 23:30:00',
            NotificationTemplate                  => 1800,
            NotificationCustom                    => '',
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => '',
            NotificationCustomRelativePointOfTime => '',
            NotificationCustomDateTime            => '',
        },
    },

    # add appointment with notification 12 hours template
    {
        Data => {
            CalendarID           => $Calendar{CalendarID},
            Title                => 'Notification appointment 5',
            Description          => 'notification template 12 hours before start',
            Location             => 'Germany',
            StartTime            => '2016-09-01 00:00:00',
            EndTime              => '2016-09-02 00:00:00',
            AllDay               => 1,
            TimezoneID           => 1,
            NotificationTemplate => 43200,
            UserID               => $UserID,
        },
        Result => {
            NotificationDate                      => '2016-08-31 12:00:00',
            NotificationTemplate                  => 43200,
            NotificationCustom                    => '',
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => '',
            NotificationCustomRelativePointOfTime => '',
            NotificationCustomDateTime            => '',
        },
    },

    # add appointment with notification 2 days template
    {
        Data => {
            CalendarID           => $Calendar{CalendarID},
            Title                => 'Notification appointment 6',
            Description          => 'notification template 2 days before start',
            Location             => 'Germany',
            StartTime            => '2016-09-01 00:00:00',
            EndTime              => '2016-09-02 00:00:00',
            AllDay               => 1,
            TimezoneID           => 1,
            NotificationTemplate => 172800,
            UserID               => $UserID,
        },
        Result => {
            NotificationDate                      => '2016-08-30 00:00:00',
            NotificationTemplate                  => 172800,
            NotificationCustom                    => '',
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => '',
            NotificationCustomRelativePointOfTime => '',
            NotificationCustomDateTime            => '',
        },
    },

    # add appointment with notification 1 week template
    {
        Data => {
            CalendarID           => $Calendar{CalendarID},
            Title                => 'Notification appointment 7',
            Description          => 'notification template 1 week before start',
            Location             => 'Germany',
            StartTime            => '2016-09-01 00:00:00',
            EndTime              => '2016-09-02 00:00:00',
            AllDay               => 1,
            TimezoneID           => 1,
            NotificationTemplate => 604800,
            UserID               => $UserID,
        },
        Result => {
            NotificationDate                      => '2016-08-25 00:00:00',
            NotificationTemplate                  => 604800,
            NotificationCustom                    => '',
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => '',
            NotificationCustomRelativePointOfTime => '',
            NotificationCustomDateTime            => '',
        },
    },

    # add appointment with custom relative notification 2 minutes before start
    {
        Data => {
            CalendarID                            => $Calendar{CalendarID},
            Title                                 => 'Notification appointment 8',
            Description                           => 'notification custom 2 minutes before start',
            Location                              => 'Germany',
            StartTime                             => '2016-09-01 00:00:00',
            EndTime                               => '2016-09-02 00:00:00',
            AllDay                                => 1,
            TimezoneID                            => 1,
            NotificationTemplate                  => 'Custom',
            NotificationCustomRelativeInput       => 1,
            NotificationCustomDateTimeInput       => 0,
            NotificationCustomRelativeUnitCount   => 2,
            NotificationCustomRelativeUnit        => 'minutes',
            NotificationCustomRelativePointOfTime => 'beforestart',
            UserID                                => $UserID,
        },
        Result => {
            NotificationDate                      => '2016-08-31 23:58:00',
            NotificationTemplate                  => 'Custom',
            NotificationCustom                    => 'relative',
            NotificationCustomRelativeUnitCount   => 2,
            NotificationCustomRelativeUnit        => 'minutes',
            NotificationCustomRelativePointOfTime => 'beforestart',
            NotificationCustomDateTime            => '',
        },
    },

    # add appointment with custom relative notification 2 hours before start
    {
        Data => {
            CalendarID                            => $Calendar{CalendarID},
            Title                                 => 'Notification appointment 9',
            Description                           => 'notification custom 2 hours before start',
            Location                              => 'Germany',
            StartTime                             => '2016-09-01 00:00:00',
            EndTime                               => '2016-09-02 00:00:00',
            AllDay                                => 1,
            TimezoneID                            => 1,
            NotificationTemplate                  => 'Custom',
            NotificationCustomRelativeInput       => 1,
            NotificationCustomDateTimeInput       => 0,
            NotificationCustomRelativeUnitCount   => 2,
            NotificationCustomRelativeUnit        => 'hours',
            NotificationCustomRelativePointOfTime => 'beforestart',
            UserID                                => $UserID,
        },
        Result => {
            NotificationDate                      => '2016-08-31 22:00:00',
            NotificationTemplate                  => 'Custom',
            NotificationCustom                    => 'relative',
            NotificationCustomRelativeUnitCount   => 2,
            NotificationCustomRelativeUnit        => 'hours',
            NotificationCustomRelativePointOfTime => 'beforestart',
            NotificationCustomDateTime            => '',
        },
    },

    # add appointment with custom relative notification 2 days before start
    {
        Data => {
            CalendarID                            => $Calendar{CalendarID},
            Title                                 => 'Notification appointment 10',
            Description                           => 'notification custom 2 days before start',
            Location                              => 'Germany',
            StartTime                             => '2016-09-01 00:00:00',
            EndTime                               => '2016-09-02 00:00:00',
            AllDay                                => 1,
            TimezoneID                            => 1,
            NotificationTemplate                  => 'Custom',
            NotificationCustomRelativeInput       => 1,
            NotificationCustomDateTimeInput       => 0,
            NotificationCustomRelativeUnitCount   => 2,
            NotificationCustomRelativeUnit        => 'days',
            NotificationCustomRelativePointOfTime => 'beforestart',
            UserID                                => $UserID,
        },
        Result => {
            NotificationDate                      => '2016-08-30 00:00:00',
            NotificationTemplate                  => 'Custom',
            NotificationCustom                    => 'relative',
            NotificationCustomRelativeUnitCount   => 2,
            NotificationCustomRelativeUnit        => 'days',
            NotificationCustomRelativePointOfTime => 'beforestart',
            NotificationCustomDateTime            => '',
        },
    },

    # add appointment with custom relative notification 2 minutes after start
    {
        Data => {
            CalendarID                            => $Calendar{CalendarID},
            Title                                 => 'Notification appointment 11',
            Description                           => 'notification date 2 minutes after start',
            Location                              => 'Germany',
            StartTime                             => '2016-09-01 00:00:00',
            EndTime                               => '2016-09-02 00:00:00',
            AllDay                                => 1,
            TimezoneID                            => 1,
            NotificationTemplate                  => 'Custom',
            NotificationCustomRelativeInput       => 1,
            NotificationCustomDateTimeInput       => 0,
            NotificationCustomRelativeUnitCount   => 2,
            NotificationCustomRelativeUnit        => 'minutes',
            NotificationCustomRelativePointOfTime => 'afterstart',
            UserID                                => $UserID,
        },
        Result => {
            NotificationDate                      => '2016-09-01 00:02:00',
            NotificationTemplate                  => 'Custom',
            NotificationCustom                    => 'relative',
            NotificationCustomRelativeUnitCount   => 2,
            NotificationCustomRelativeUnit        => 'minutes',
            NotificationCustomRelativePointOfTime => 'afterstart',
            NotificationCustomDateTime            => '',
        },
    },

    # add appointment with custom relative notification 2 hours after start
    {
        Data => {
            CalendarID                            => $Calendar{CalendarID},
            Title                                 => 'Notification appointment 12',
            Description                           => 'notification date 2 hours after start',
            Location                              => 'Germany',
            StartTime                             => '2016-09-01 00:00:00',
            EndTime                               => '2016-09-02 00:00:00',
            AllDay                                => 1,
            TimezoneID                            => 1,
            NotificationTemplate                  => 'Custom',
            NotificationCustomRelativeInput       => 1,
            NotificationCustomDateTimeInput       => 0,
            NotificationCustomRelativeUnitCount   => 2,
            NotificationCustomRelativeUnit        => 'hours',
            NotificationCustomRelativePointOfTime => 'afterstart',
            UserID                                => $UserID,
        },
        Result => {
            NotificationDate                      => '2016-09-01 02:00:00',
            NotificationTemplate                  => 'Custom',
            NotificationCustom                    => 'relative',
            NotificationCustomRelativeUnitCount   => 2,
            NotificationCustomRelativeUnit        => 'hours',
            NotificationCustomRelativePointOfTime => 'afterstart',
            NotificationCustomDateTime            => '',
        },
    },

    # add appointment with custom relative notification 2 days after start
    {
        Data => {
            CalendarID                            => $Calendar{CalendarID},
            Title                                 => 'Notification appointment 13',
            Description                           => 'notification date 2 days after start',
            Location                              => 'Germany',
            StartTime                             => '2016-09-01 00:00:00',
            EndTime                               => '2016-09-02 00:00:00',
            AllDay                                => 1,
            TimezoneID                            => 1,
            NotificationTemplate                  => 'Custom',
            NotificationCustomRelativeInput       => 1,
            NotificationCustomDateTimeInput       => 0,
            NotificationCustomRelativeUnitCount   => 2,
            NotificationCustomRelativeUnit        => 'days',
            NotificationCustomRelativePointOfTime => 'afterstart',
            UserID                                => $UserID,
        },
        Result => {
            NotificationDate                      => '2016-09-03 00:00:00',
            NotificationTemplate                  => 'Custom',
            NotificationCustom                    => 'relative',
            NotificationCustomRelativeUnitCount   => 2,
            NotificationCustomRelativeUnit        => 'days',
            NotificationCustomRelativePointOfTime => 'afterstart',
            NotificationCustomDateTime            => '',
        },
    },

    # add appointment with custom relative notification 2 minutes before end
    {
        Data => {
            CalendarID                            => $Calendar{CalendarID},
            Title                                 => 'Notification appointment 14',
            Description                           => 'notification date 2 minutes before end',
            Location                              => 'Germany',
            StartTime                             => '2016-09-01 00:00:00',
            EndTime                               => '2016-09-02 00:00:00',
            AllDay                                => 1,
            TimezoneID                            => 1,
            NotificationTemplate                  => 'Custom',
            NotificationCustomRelativeInput       => 1,
            NotificationCustomDateTimeInput       => 0,
            NotificationCustomRelativeUnitCount   => 2,
            NotificationCustomRelativeUnit        => 'minutes',
            NotificationCustomRelativePointOfTime => 'beforeend',
            UserID                                => $UserID,
        },
        Result => {
            NotificationDate                      => '2016-09-01 23:58:00',
            NotificationTemplate                  => 'Custom',
            NotificationCustom                    => 'relative',
            NotificationCustomRelativeUnitCount   => 2,
            NotificationCustomRelativeUnit        => 'minutes',
            NotificationCustomRelativePointOfTime => 'beforeend',
            NotificationCustomDateTime            => '',
        },
    },

    # add appointment with custom relative notification 2 hours before end
    {
        Data => {
            CalendarID                            => $Calendar{CalendarID},
            Title                                 => 'Notification appointment 15',
            Description                           => 'notification date 2 hours before end',
            Location                              => 'Germany',
            StartTime                             => '2016-09-01 00:00:00',
            EndTime                               => '2016-09-02 00:00:00',
            AllDay                                => 1,
            TimezoneID                            => 1,
            NotificationTemplate                  => 'Custom',
            NotificationCustomRelativeInput       => 1,
            NotificationCustomDateTimeInput       => 0,
            NotificationCustomRelativeUnitCount   => 2,
            NotificationCustomRelativeUnit        => 'hours',
            NotificationCustomRelativePointOfTime => 'beforeend',
            UserID                                => $UserID,
        },
        Result => {
            NotificationDate                      => '2016-09-01 22:00:00',
            NotificationTemplate                  => 'Custom',
            NotificationCustom                    => 'relative',
            NotificationCustomRelativeUnitCount   => 2,
            NotificationCustomRelativeUnit        => 'hours',
            NotificationCustomRelativePointOfTime => 'beforeend',
            NotificationCustomDateTime            => '',
        },
    },

    # add appointment with custom relative notification 2 days before end
    {
        Data => {
            CalendarID                            => $Calendar{CalendarID},
            Title                                 => 'Notification appointment 16',
            Description                           => 'notification date 2 days before end',
            Location                              => 'Germany',
            StartTime                             => '2016-09-01 00:00:00',
            EndTime                               => '2016-09-02 00:00:00',
            AllDay                                => 1,
            TimezoneID                            => 1,
            NotificationTemplate                  => 'Custom',
            NotificationCustomRelativeInput       => 1,
            NotificationCustomDateTimeInput       => 0,
            NotificationCustomRelativeUnitCount   => 2,
            NotificationCustomRelativeUnit        => 'days',
            NotificationCustomRelativePointOfTime => 'beforeend',
            UserID                                => $UserID,
        },
        Result => {
            NotificationDate                      => '2016-08-31 00:00:00',
            NotificationTemplate                  => 'Custom',
            NotificationCustom                    => 'relative',
            NotificationCustomRelativeUnitCount   => 2,
            NotificationCustomRelativeUnit        => 'days',
            NotificationCustomRelativePointOfTime => 'beforeend',
            NotificationCustomDateTime            => '',
        },
    },

    # add appointment with custom relative notification 2 minutes after end
    {
        Data => {
            CalendarID                            => $Calendar{CalendarID},
            Title                                 => 'Notification appointment 17',
            Description                           => 'notification date 2 minutes after end',
            Location                              => 'Germany',
            StartTime                             => '2016-09-01 00:00:00',
            EndTime                               => '2016-09-02 00:00:00',
            AllDay                                => 1,
            TimezoneID                            => 1,
            NotificationTemplate                  => 'Custom',
            NotificationCustomRelativeInput       => 1,
            NotificationCustomDateTimeInput       => 0,
            NotificationCustomRelativeUnitCount   => 2,
            NotificationCustomRelativeUnit        => 'minutes',
            NotificationCustomRelativePointOfTime => 'afterend',
            UserID                                => $UserID,
        },
        Result => {
            NotificationDate                      => '2016-09-02 00:02:00',
            NotificationTemplate                  => 'Custom',
            NotificationCustom                    => 'relative',
            NotificationCustomRelativeUnitCount   => 2,
            NotificationCustomRelativeUnit        => 'minutes',
            NotificationCustomRelativePointOfTime => 'afterend',
            NotificationCustomDateTime            => '',
        },
    },

    # add appointment with custom relative notification 2 hours after end
    {
        Data => {
            CalendarID                            => $Calendar{CalendarID},
            Title                                 => 'Notification appointment 18',
            Description                           => 'notification date 2 hours after end',
            Location                              => 'Germany',
            StartTime                             => '2016-09-01 00:00:00',
            EndTime                               => '2016-09-02 00:00:00',
            AllDay                                => 1,
            TimezoneID                            => 1,
            NotificationTemplate                  => 'Custom',
            NotificationCustomRelativeInput       => 1,
            NotificationCustomDateTimeInput       => 0,
            NotificationCustomRelativeUnitCount   => 2,
            NotificationCustomRelativeUnit        => 'hours',
            NotificationCustomRelativePointOfTime => 'afterend',
            UserID                                => $UserID,
        },
        Result => {
            NotificationDate                      => '2016-09-02 02:00:00',
            NotificationTemplate                  => 'Custom',
            NotificationCustom                    => 'relative',
            NotificationCustomRelativeUnitCount   => 2,
            NotificationCustomRelativeUnit        => 'hours',
            NotificationCustomRelativePointOfTime => 'afterend',
            NotificationCustomDateTime            => '',
        },
    },

    # add appointment with custom relative notification 2 days after end
    {
        Data => {
            CalendarID                            => $Calendar{CalendarID},
            Title                                 => 'Notification appointment 19',
            Description                           => 'notification date 2 days after end',
            Location                              => 'Germany',
            StartTime                             => '2016-09-01 00:00:00',
            EndTime                               => '2016-09-02 00:00:00',
            AllDay                                => 1,
            TimezoneID                            => 1,
            NotificationTemplate                  => 'Custom',
            NotificationCustomRelativeInput       => 1,
            NotificationCustomDateTimeInput       => 0,
            NotificationCustomRelativeUnitCount   => 2,
            NotificationCustomRelativeUnit        => 'days',
            NotificationCustomRelativePointOfTime => 'afterend',
            UserID                                => $UserID,
        },
        Result => {
            NotificationDate                      => '2016-09-04 00:00:00',
            NotificationTemplate                  => 'Custom',
            NotificationCustom                    => 'relative',
            NotificationCustomRelativeUnitCount   => 2,
            NotificationCustomRelativeUnit        => 'days',
            NotificationCustomRelativePointOfTime => 'afterend',
            NotificationCustomDateTime            => '',
        },
    },

    # add appointment with custom relative notification 0 minutes before start
    {
        Data => {
            CalendarID                            => $Calendar{CalendarID},
            Title                                 => 'Notification appointment 20',
            Description                           => 'notification custom 0 minutes before start',
            Location                              => 'Germany',
            StartTime                             => '2016-09-01 00:00:00',
            EndTime                               => '2016-09-02 00:00:00',
            AllDay                                => 1,
            TimezoneID                            => 1,
            NotificationTemplate                  => 'Custom',
            NotificationCustomRelativeInput       => 1,
            NotificationCustomDateTimeInput       => 0,
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => 'minutes',
            NotificationCustomRelativePointOfTime => 'beforestart',
            UserID                                => $UserID,
        },
        Result => {
            NotificationDate                      => '2016-09-01 00:00:00',
            NotificationTemplate                  => 'Custom',
            NotificationCustom                    => 'relative',
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => 'minutes',
            NotificationCustomRelativePointOfTime => 'beforestart',
            NotificationCustomDateTime            => '',
        },
    },

    # add appointment with custom relative notification 0 hours before start
    {
        Data => {
            CalendarID                            => $Calendar{CalendarID},
            Title                                 => 'Notification appointment 21',
            Description                           => 'notification custom 0 hours before start',
            Location                              => 'Germany',
            StartTime                             => '2016-09-01 00:00:00',
            EndTime                               => '2016-09-02 00:00:00',
            AllDay                                => 1,
            TimezoneID                            => 1,
            NotificationTemplate                  => 'Custom',
            NotificationCustomRelativeInput       => 1,
            NotificationCustomDateTimeInput       => 0,
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => 'hours',
            NotificationCustomRelativePointOfTime => 'beforestart',
            UserID                                => $UserID,
        },
        Result => {
            NotificationDate                      => '2016-09-01 00:00:00',
            NotificationTemplate                  => 'Custom',
            NotificationCustom                    => 'relative',
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => 'hours',
            NotificationCustomRelativePointOfTime => 'beforestart',
            NotificationCustomDateTime            => '',
        },
    },

    # add appointment with custom relative notification 0 days before start
    {
        Data => {
            CalendarID                            => $Calendar{CalendarID},
            Title                                 => 'Notification appointment 22',
            Description                           => 'notification custom 0 days before start',
            Location                              => 'Germany',
            StartTime                             => '2016-09-01 00:00:00',
            EndTime                               => '2016-09-02 00:00:00',
            AllDay                                => 1,
            TimezoneID                            => 1,
            NotificationTemplate                  => 'Custom',
            NotificationCustomRelativeInput       => 1,
            NotificationCustomDateTimeInput       => 0,
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => 'days',
            NotificationCustomRelativePointOfTime => 'beforestart',
            UserID                                => $UserID,
        },
        Result => {
            NotificationDate                      => '2016-09-01 00:00:00',
            NotificationTemplate                  => 'Custom',
            NotificationCustom                    => 'relative',
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => 'days',
            NotificationCustomRelativePointOfTime => 'beforestart',
            NotificationCustomDateTime            => '',
        },
    },

    # add appointment with custom relative notification 0 minutes after start
    {
        Data => {
            CalendarID                            => $Calendar{CalendarID},
            Title                                 => 'Notification appointment 23',
            Description                           => 'notification date 0 minutes after start',
            Location                              => 'Germany',
            StartTime                             => '2016-09-01 00:00:00',
            EndTime                               => '2016-09-02 00:00:00',
            AllDay                                => 1,
            TimezoneID                            => 1,
            NotificationTemplate                  => 'Custom',
            NotificationCustomRelativeInput       => 1,
            NotificationCustomDateTimeInput       => 0,
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => 'minutes',
            NotificationCustomRelativePointOfTime => 'afterstart',
            UserID                                => $UserID,
        },
        Result => {
            NotificationDate                      => '2016-09-01 00:00:00',
            NotificationTemplate                  => 'Custom',
            NotificationCustom                    => 'relative',
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => 'minutes',
            NotificationCustomRelativePointOfTime => 'afterstart',
            NotificationCustomDateTime            => '',
        },
    },

    # add appointment with custom relative notification 0 hours after start
    {
        Data => {
            CalendarID                            => $Calendar{CalendarID},
            Title                                 => 'Notification appointment 24',
            Description                           => 'notification date 0 hours after start',
            Location                              => 'Germany',
            StartTime                             => '2016-09-01 00:00:00',
            EndTime                               => '2016-09-02 00:00:00',
            AllDay                                => 1,
            TimezoneID                            => 1,
            NotificationTemplate                  => 'Custom',
            NotificationCustomRelativeInput       => 1,
            NotificationCustomDateTimeInput       => 0,
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => 'hours',
            NotificationCustomRelativePointOfTime => 'afterstart',
            UserID                                => $UserID,
        },
        Result => {
            NotificationDate                      => '2016-09-01 00:00:00',
            NotificationTemplate                  => 'Custom',
            NotificationCustom                    => 'relative',
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => 'hours',
            NotificationCustomRelativePointOfTime => 'afterstart',
            NotificationCustomDateTime            => '',
        },
    },

    # add appointment with custom relative notification 0 days after start
    {
        Data => {
            CalendarID                            => $Calendar{CalendarID},
            Title                                 => 'Notification appointment 25',
            Description                           => 'notification date 0 days after start',
            Location                              => 'Germany',
            StartTime                             => '2016-09-01 00:00:00',
            EndTime                               => '2016-09-02 00:00:00',
            AllDay                                => 1,
            TimezoneID                            => 1,
            NotificationTemplate                  => 'Custom',
            NotificationCustomRelativeInput       => 1,
            NotificationCustomDateTimeInput       => 0,
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => 'days',
            NotificationCustomRelativePointOfTime => 'afterstart',
            UserID                                => $UserID,
        },
        Result => {
            NotificationDate                      => '2016-09-01 00:00:00',
            NotificationTemplate                  => 'Custom',
            NotificationCustom                    => 'relative',
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => 'days',
            NotificationCustomRelativePointOfTime => 'afterstart',
            NotificationCustomDateTime            => '',
        },
    },

    # add appointment with custom relative notification 0 minutes before end
    {
        Data => {
            CalendarID                            => $Calendar{CalendarID},
            Title                                 => 'Notification appointment 26',
            Description                           => 'notification date 0 minutes before end',
            Location                              => 'Germany',
            StartTime                             => '2016-09-01 00:00:00',
            EndTime                               => '2016-09-02 00:00:00',
            AllDay                                => 1,
            TimezoneID                            => 1,
            NotificationTemplate                  => 'Custom',
            NotificationCustomRelativeInput       => 1,
            NotificationCustomDateTimeInput       => 0,
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => 'minutes',
            NotificationCustomRelativePointOfTime => 'beforeend',
            UserID                                => $UserID,
        },
        Result => {
            NotificationDate                      => '2016-09-02 00:00:00',
            NotificationTemplate                  => 'Custom',
            NotificationCustom                    => 'relative',
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => 'minutes',
            NotificationCustomRelativePointOfTime => 'beforeend',
            NotificationCustomDateTime            => '',
        },
    },

    # add appointment with custom relative notification 0 hours before end
    {
        Data => {
            CalendarID                            => $Calendar{CalendarID},
            Title                                 => 'Notification appointment 27',
            Description                           => 'notification date 0 hours before end',
            Location                              => 'Germany',
            StartTime                             => '2016-09-01 00:00:00',
            EndTime                               => '2016-09-02 00:00:00',
            AllDay                                => 1,
            TimezoneID                            => 1,
            NotificationTemplate                  => 'Custom',
            NotificationCustomRelativeInput       => 1,
            NotificationCustomDateTimeInput       => 0,
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => 'hours',
            NotificationCustomRelativePointOfTime => 'beforeend',
            UserID                                => $UserID,
        },
        Result => {
            NotificationDate                      => '2016-09-02 00:00:00',
            NotificationTemplate                  => 'Custom',
            NotificationCustom                    => 'relative',
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => 'hours',
            NotificationCustomRelativePointOfTime => 'beforeend',
            NotificationCustomDateTime            => '',
        },
    },

    # add appointment with custom relative notification 0 days before end
    {
        Data => {
            CalendarID                            => $Calendar{CalendarID},
            Title                                 => 'Notification appointment 28',
            Description                           => 'notification date 0 days before end',
            Location                              => 'Germany',
            StartTime                             => '2016-09-01 00:00:00',
            EndTime                               => '2016-09-02 00:00:00',
            AllDay                                => 1,
            TimezoneID                            => 1,
            NotificationTemplate                  => 'Custom',
            NotificationCustomRelativeInput       => 1,
            NotificationCustomDateTimeInput       => 0,
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => 'days',
            NotificationCustomRelativePointOfTime => 'beforeend',
            UserID                                => $UserID,
        },
        Result => {
            NotificationDate                      => '2016-09-02 00:00:00',
            NotificationTemplate                  => 'Custom',
            NotificationCustom                    => 'relative',
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => 'days',
            NotificationCustomRelativePointOfTime => 'beforeend',
            NotificationCustomDateTime            => '',
        },
    },

    # add appointment with custom relative notification 0 minutes after end
    {
        Data => {
            CalendarID                            => $Calendar{CalendarID},
            Title                                 => 'Notification appointment 29',
            Description                           => 'notification date 0 minutes after end',
            Location                              => 'Germany',
            StartTime                             => '2016-09-01 00:00:00',
            EndTime                               => '2016-09-02 00:00:00',
            AllDay                                => 1,
            TimezoneID                            => 1,
            NotificationTemplate                  => 'Custom',
            NotificationCustomRelativeInput       => 1,
            NotificationCustomDateTimeInput       => 0,
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => 'minutes',
            NotificationCustomRelativePointOfTime => 'afterend',
            UserID                                => $UserID,
        },
        Result => {
            NotificationDate                      => '2016-09-02 00:00:00',
            NotificationTemplate                  => 'Custom',
            NotificationCustom                    => 'relative',
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => 'minutes',
            NotificationCustomRelativePointOfTime => 'afterend',
            NotificationCustomDateTime            => '',
        },
    },

    # add appointment with custom relative notification 0 hours after end
    {
        Data => {
            CalendarID                            => $Calendar{CalendarID},
            Title                                 => 'Notification appointment 30',
            Description                           => 'notification date 0 hours after end',
            Location                              => 'Germany',
            StartTime                             => '2016-09-01 00:00:00',
            EndTime                               => '2016-09-02 00:00:00',
            AllDay                                => 1,
            TimezoneID                            => 1,
            NotificationTemplate                  => 'Custom',
            NotificationCustomRelativeInput       => 1,
            NotificationCustomDateTimeInput       => 0,
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => 'hours',
            NotificationCustomRelativePointOfTime => 'afterend',
            UserID                                => $UserID,
        },
        Result => {
            NotificationDate                      => '2016-09-02 00:00:00',
            NotificationTemplate                  => 'Custom',
            NotificationCustom                    => 'relative',
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => 'hours',
            NotificationCustomRelativePointOfTime => 'afterend',
            NotificationCustomDateTime            => '',
        },
    },

    # add appointment with custom relative notification 0 days after end
    {
        Data => {
            CalendarID                            => $Calendar{CalendarID},
            Title                                 => 'Notification appointment 31',
            Description                           => 'notification date 0 days after end',
            Location                              => 'Germany',
            StartTime                             => '2016-09-01 00:00:00',
            EndTime                               => '2016-09-02 00:00:00',
            AllDay                                => 1,
            TimezoneID                            => 1,
            NotificationTemplate                  => 'Custom',
            NotificationCustomRelativeInput       => 1,
            NotificationCustomDateTimeInput       => 0,
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => 'days',
            NotificationCustomRelativePointOfTime => 'afterend',
            UserID                                => $UserID,
        },
        Result => {
            NotificationDate                      => '2016-09-02 00:00:00',
            NotificationTemplate                  => 'Custom',
            NotificationCustom                    => 'relative',
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => 'days',
            NotificationCustomRelativePointOfTime => 'afterend',
            NotificationCustomDateTime            => '',
        },
    },

    # add appointment with custom relative notification -2345 days after end
    {
        Data => {
            CalendarID                            => $Calendar{CalendarID},
            Title                                 => 'Notification appointment 32',
            Description                           => 'notification date -2345 days after end',
            Location                              => 'Germany',
            StartTime                             => '2016-09-01 00:00:00',
            EndTime                               => '2016-09-02 00:00:00',
            AllDay                                => 1,
            TimezoneID                            => 1,
            NotificationTemplate                  => 'Custom',
            NotificationCustomRelativeInput       => 1,
            NotificationCustomDateTimeInput       => 0,
            NotificationCustomRelativeUnitCount   => -2345,
            NotificationCustomRelativeUnit        => 'days',
            NotificationCustomRelativePointOfTime => 'afterend',
            UserID                                => $UserID,
        },
        Result => {
            NotificationDate                      => '2016-09-02 00:00:00',
            NotificationTemplate                  => 'Custom',
            NotificationCustom                    => 'relative',
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => 'days',
            NotificationCustomRelativePointOfTime => 'afterend',
            NotificationCustomDateTime            => '',
        },
    },

    # add appointment with custom datetime notification 2 minutes before start
    {
        Data => {
            CalendarID                            => $Calendar{CalendarID},
            Title                                 => 'Notification appointment 33',
            Description                           => 'notification date 2 minutes before start',
            Location                              => 'Germany',
            StartTime                             => '2016-09-01 00:00:00',
            EndTime                               => '2016-09-02 00:00:00',
            AllDay                                => 1,
            TimezoneID                            => 1,
            NotificationTemplate                  => 'Custom',
            NotificationCustomRelativeInput       => 0,
            NotificationCustomDateTimeInput       => 1,
            NotificationCustomRelativeUnitCount   => undef,
            NotificationCustomRelativeUnit        => undef,
            NotificationCustomRelativePointOfTime => undef,
            NotificationCustomDateTime            => '2016-08-31 23:58:00',
            UserID                                => $UserID,
        },
        Result => {
            NotificationDate                      => '2016-08-31 23:58:00',
            NotificationTemplate                  => 'Custom',
            NotificationCustom                    => 'datetime',
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => '',
            NotificationCustomRelativePointOfTime => '',
            NotificationCustomDateTime            => '2016-08-31 23:58:00',
        },
    },

    # add appointment with custom datetime notification 2 hours before start
    {
        Data => {
            CalendarID                            => $Calendar{CalendarID},
            Title                                 => 'Notification appointment 34',
            Description                           => 'notification date 2 hours before start',
            Location                              => 'Germany',
            StartTime                             => '2016-09-01 00:00:00',
            EndTime                               => '2016-09-02 00:00:00',
            AllDay                                => 1,
            TimezoneID                            => 1,
            NotificationTemplate                  => 'Custom',
            NotificationCustomRelativeInput       => 0,
            NotificationCustomDateTimeInput       => 1,
            NotificationCustomRelativeUnitCount   => undef,
            NotificationCustomRelativeUnit        => undef,
            NotificationCustomRelativePointOfTime => undef,
            NotificationCustomDateTime            => '2016-08-31 22:00:00',
            UserID                                => $UserID,
        },
        Result => {
            NotificationDate                      => '2016-08-31 22:00:00',
            NotificationTemplate                  => 'Custom',
            NotificationCustom                    => 'datetime',
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => '',
            NotificationCustomRelativePointOfTime => '',
            NotificationCustomDateTime            => '2016-08-31 22:00:00',
        },
    },

    # add appointment with custom datetime notification 2 days before start
    {
        Data => {
            CalendarID                            => $Calendar{CalendarID},
            Title                                 => 'Notification appointment 35',
            Description                           => 'notification date 2 days before start',
            Location                              => 'Germany',
            StartTime                             => '2016-09-01 00:00:00',
            EndTime                               => '2016-09-02 00:00:00',
            AllDay                                => 1,
            TimezoneID                            => 1,
            NotificationTemplate                  => 'Custom',
            NotificationCustomRelativeInput       => 0,
            NotificationCustomDateTimeInput       => 1,
            NotificationCustomRelativeUnitCount   => undef,
            NotificationCustomRelativeUnit        => undef,
            NotificationCustomRelativePointOfTime => undef,
            NotificationCustomDateTime            => '2016-08-30 00:00:00',
            UserID                                => $UserID,
        },
        Result => {
            NotificationDate                      => '2016-08-30 00:00:00',
            NotificationTemplate                  => 'Custom',
            NotificationCustom                    => 'datetime',
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => '',
            NotificationCustomRelativePointOfTime => '',
            NotificationCustomDateTime            => '2016-08-30 00:00:00',
        },
    },

    # add appointment with custom datetime notification 2 minutes after end
    {
        Data => {
            CalendarID                            => $Calendar{CalendarID},
            Title                                 => 'Notification appointment 36',
            Description                           => 'notification date 2 minutes after end',
            Location                              => 'Germany',
            StartTime                             => '2016-09-01 00:00:00',
            EndTime                               => '2016-09-02 00:00:00',
            AllDay                                => 1,
            TimezoneID                            => 1,
            NotificationTemplate                  => 'Custom',
            NotificationCustomRelativeInput       => 0,
            NotificationCustomDateTimeInput       => 1,
            NotificationCustomRelativeUnitCount   => undef,
            NotificationCustomRelativeUnit        => undef,
            NotificationCustomRelativePointOfTime => undef,
            NotificationCustomDateTime            => '2016-09-02 00:02:00',
            UserID                                => $UserID,
        },
        Result => {
            NotificationDate                      => '2016-09-02 00:02:00',
            NotificationTemplate                  => 'Custom',
            NotificationCustom                    => 'datetime',
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => '',
            NotificationCustomRelativePointOfTime => '',
            NotificationCustomDateTime            => '2016-09-02 00:02:00',
        },
    },

    # add appointment with custom datetime notification 2 hours after end
    {
        Data => {
            CalendarID                            => $Calendar{CalendarID},
            Title                                 => 'Notification appointment 37',
            Description                           => 'notification date 2 hours after end',
            Location                              => 'Germany',
            StartTime                             => '2016-09-01 00:00:00',
            EndTime                               => '2016-09-02 00:00:00',
            AllDay                                => 1,
            TimezoneID                            => 1,
            NotificationTemplate                  => 'Custom',
            NotificationCustomRelativeInput       => 0,
            NotificationCustomDateTimeInput       => 1,
            NotificationCustomRelativeUnitCount   => undef,
            NotificationCustomRelativeUnit        => undef,
            NotificationCustomRelativePointOfTime => undef,
            NotificationCustomDateTime            => '2016-09-02 02:00:00',
            UserID                                => $UserID,
        },
        Result => {
            NotificationDate                      => '2016-09-02 02:00:00',
            NotificationTemplate                  => 'Custom',
            NotificationCustom                    => 'datetime',
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => '',
            NotificationCustomRelativePointOfTime => '',
            NotificationCustomDateTime            => '2016-09-02 02:00:00',
        },
    },

    # add appointment with custom datetime notification 2 days after end
    {
        Data => {
            CalendarID                            => $Calendar{CalendarID},
            Title                                 => 'Notification appointment 38',
            Description                           => 'notification date 2 days after end',
            Location                              => 'Germany',
            StartTime                             => '2016-09-01 00:00:00',
            EndTime                               => '2016-09-02 00:00:00',
            AllDay                                => 1,
            TimezoneID                            => 1,
            NotificationTemplate                  => 'Custom',
            NotificationCustomRelativeInput       => 0,
            NotificationCustomDateTimeInput       => 1,
            NotificationCustomRelativeUnitCount   => undef,
            NotificationCustomRelativeUnit        => undef,
            NotificationCustomRelativePointOfTime => undef,
            NotificationCustomDateTime            => '2016-09-04 00:00:00',
            UserID                                => $UserID,
        },
        Result => {
            NotificationDate                      => '2016-09-04 00:00:00',
            NotificationTemplate                  => 'Custom',
            NotificationCustom                    => 'datetime',
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => '',
            NotificationCustomRelativePointOfTime => '',
            NotificationCustomDateTime            => '2016-09-04 00:00:00',
        },
    },
);

# notification create test execution
for my $Test (@NotificationCreateTests) {

    # create appointment
    my $AppointmentID = $AppointmentObject->AppointmentCreate(
        %{ $Test->{Data} },
        UserID => $UserID,
    );

    # verify appointment creation
    $Self->True(
        $AppointmentID,
        'Notification appointment created - ' . $Test->{Data}->{Description},
    );

    # retrieve stored appointment information
    my %AppointmentData = $AppointmentObject->AppointmentGet(
        AppointmentID => $AppointmentID,
    );

    # verify appointment data get
    my $Created = IsHashRefWithData( \%AppointmentData );
    $Self->True(
        $Created,
        'Notification appointment data retrieved - ' . $Test->{Data}->{Description},
    );

    # verify results
    for my $ResultKey ( sort keys %{ $Test->{Result} } ) {

        $Self->Is(
            $AppointmentData{$ResultKey},
            $Test->{Result}->{$ResultKey},
            'Notification appointment result: ' . $ResultKey . ' - ' . $Test->{Data}->{Description},
        );
    }
}

# notification update test definition
my @NotificationUpdateTests = (

    # update appointment from no template to wrong template
    {
        DataBefore => {
            CalendarID           => $Calendar{CalendarID},
            Title                => 'Update notification appointment 1',
            Description          => 'Before update no notification',
            Location             => 'Germany',
            StartTime            => '2016-09-01 00:00:00',
            EndTime              => '2016-09-02 00:00:00',
            AllDay               => 1,
            TimezoneID           => 1,
            NotificationTemplate => 0,
            UserID               => $UserID,
        },
        DataAfter => {
            CalendarID           => $Calendar{CalendarID},
            Title                => 'Update notification appointment 1',
            Description          => 'Update to wrong notification template',
            Location             => 'Germany',
            StartTime            => '2016-09-01 00:00:00',
            EndTime              => '2016-09-02 00:00:00',
            AllDay               => 1,
            TimezoneID           => 1,
            NotificationTemplate => 'WrongNotificationTemplate',
            UserID               => $UserID,
        },
        Result => {
            NotificationDate                      => '',
            NotificationTemplate                  => 'WrongNotificationTemplate',
            NotificationCustom                    => '',
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => '',
            NotificationCustomRelativePointOfTime => '',
            NotificationCustomDateTime            => '',
        },
    },

    # update appointment from no template to starttime template
    {
        DataBefore => {
            CalendarID           => $Calendar{CalendarID},
            Title                => 'Update notification appointment 2',
            Description          => 'Before update no notification',
            Location             => 'Germany',
            StartTime            => '2016-09-01 00:00:00',
            EndTime              => '2016-09-02 00:00:00',
            AllDay               => 1,
            TimezoneID           => 1,
            NotificationTemplate => 0,
            UserID               => $UserID,
        },
        DataAfter => {
            CalendarID           => $Calendar{CalendarID},
            Title                => 'Update notification appointment 2',
            Description          => 'Update to notification template start',
            Location             => 'Germany',
            StartTime            => '2016-09-01 00:00:00',
            EndTime              => '2016-09-02 00:00:00',
            AllDay               => 1,
            TimezoneID           => 1,
            NotificationTemplate => 'Start',
            UserID               => $UserID,
        },
        Result => {
            NotificationDate                      => '2016-09-01 00:00:00',
            NotificationTemplate                  => 'Start',
            NotificationCustom                    => '',
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => '',
            NotificationCustomRelativePointOfTime => '',
            NotificationCustomDateTime            => '',
        },
    },

    # update appointment from starttime template to 30 minutes before start template
    {
        DataBefore => {

            CalendarID           => $Calendar{CalendarID},
            Title                => 'Update notification appointment 3',
            Description          => 'Update to notification template 30 minutes before start',
            Location             => 'Germany',
            StartTime            => '2016-09-01 00:00:00',
            EndTime              => '2016-09-02 00:00:00',
            AllDay               => 1,
            TimezoneID           => 1,
            NotificationTemplate => 'Start',
            UserID               => $UserID,
        },
        DataAfter => {
            CalendarID           => $Calendar{CalendarID},
            Title                => 'Update notification appointment 3',
            Description          => 'Update to notification template 30 minutes before start',
            Location             => 'Germany',
            StartTime            => '2016-09-01 00:00:00',
            EndTime              => '2016-09-02 00:00:00',
            AllDay               => 1,
            TimezoneID           => 1,
            NotificationTemplate => 1800,
            UserID               => $UserID,
        },
        Result => {
            NotificationDate                      => '2016-08-31 23:30:00',
            NotificationTemplate                  => 1800,
            NotificationCustom                    => '',
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => '',
            NotificationCustomRelativePointOfTime => '',
            NotificationCustomDateTime            => '',
        },
    },

    # update appointment from 30 minutes before start template to 12 hours before start template
    {
        DataBefore => {
            CalendarID           => $Calendar{CalendarID},
            Title                => 'Update notification appointment 4',
            Description          => 'Update to notification template 12 hours before start template',
            Location             => 'Germany',
            StartTime            => '2016-09-01 00:00:00',
            EndTime              => '2016-09-02 00:00:00',
            AllDay               => 1,
            TimezoneID           => 1,
            NotificationTemplate => 1800,
            UserID               => $UserID,
        },
        DataAfter => {
            CalendarID           => $Calendar{CalendarID},
            Title                => 'Update notification appointment 4',
            Description          => 'Update to notification template 12 hours before start',
            Location             => 'Germany',
            StartTime            => '2016-09-01 00:00:00',
            EndTime              => '2016-09-02 00:00:00',
            AllDay               => 1,
            TimezoneID           => 1,
            NotificationTemplate => 43200,
            UserID               => $UserID,
        },
        Result => {
            NotificationDate                      => '2016-08-31 12:00:00',
            NotificationTemplate                  => 43200,
            NotificationCustom                    => '',
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => '',
            NotificationCustomRelativePointOfTime => '',
            NotificationCustomDateTime            => '',
        },
    },

    # update appointment from 12 hours before start template to 2 days before start template
    {
        DataBefore => {
            CalendarID           => $Calendar{CalendarID},
            Title                => 'Update notification appointment 5',
            Description          => 'Update to notification template 2 days before start template',
            Location             => 'Germany',
            StartTime            => '2016-09-01 00:00:00',
            EndTime              => '2016-09-02 00:00:00',
            AllDay               => 1,
            TimezoneID           => 1,
            NotificationTemplate => 43200,
            UserID               => $UserID,
        },
        DataAfter => {
            CalendarID           => $Calendar{CalendarID},
            Title                => 'Update notification appointment 5',
            Description          => 'Update to notification template 2 days before start',
            Location             => 'Germany',
            StartTime            => '2016-09-01 00:00:00',
            EndTime              => '2016-09-02 00:00:00',
            AllDay               => 1,
            TimezoneID           => 1,
            NotificationTemplate => 172800,
            UserID               => $UserID,
        },
        Result => {
            NotificationDate                      => '2016-08-30 00:00:00',
            NotificationTemplate                  => 172800,
            NotificationCustom                    => '',
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => '',
            NotificationCustomRelativePointOfTime => '',
            NotificationCustomDateTime            => '',
        },
    },

    # update appointment from 2 days before start template to no notification template
    {
        DataBefore => {
            CalendarID           => $Calendar{CalendarID},
            Title                => 'Update notification appointment 6',
            Description          => 'Update to no notification template',
            Location             => 'Germany',
            StartTime            => '2016-09-01 00:00:00',
            EndTime              => '2016-09-02 00:00:00',
            AllDay               => 1,
            TimezoneID           => 1,
            NotificationTemplate => 172800,
            UserID               => $UserID,
        },
        DataAfter => {
            CalendarID           => $Calendar{CalendarID},
            Title                => 'Update notification appointment 6',
            Description          => 'Before update to no notification',
            Location             => 'Germany',
            StartTime            => '2016-09-01 00:00:00',
            EndTime              => '2016-09-02 00:00:00',
            AllDay               => 1,
            TimezoneID           => 1,
            NotificationTemplate => 0,
            UserID               => $UserID,
        },
        Result => {
            NotificationDate                      => '',
            NotificationTemplate                  => '',
            NotificationCustom                    => '',
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => '',
            NotificationCustomRelativePointOfTime => '',
            NotificationCustomDateTime            => '',
        },
    },

    # update appointment from 12 hours before start template to custom 2 minutes before start template
    {
        DataBefore => {
            CalendarID           => $Calendar{CalendarID},
            Title                => 'Update notification appointment 7',
            Description          => 'Update to notification template custom 2 minutes before start',
            Location             => 'Germany',
            StartTime            => '2016-09-01 00:00:00',
            EndTime              => '2016-09-02 00:00:00',
            AllDay               => 1,
            TimezoneID           => 1,
            NotificationTemplate => 43200,
            UserID               => $UserID,
        },
        DataAfter => {
            CalendarID                            => $Calendar{CalendarID},
            Title                                 => 'Update notification appointment 7',
            Description                           => 'Update to notification custom 2 minutes before start',
            Location                              => 'Germany',
            StartTime                             => '2016-09-01 00:00:00',
            EndTime                               => '2016-09-02 00:00:00',
            AllDay                                => 1,
            TimezoneID                            => 1,
            NotificationTemplate                  => 'Custom',
            NotificationCustomRelativeInput       => 1,
            NotificationCustomDateTimeInput       => 0,
            NotificationCustomRelativeUnitCount   => 2,
            NotificationCustomRelativeUnit        => 'minutes',
            NotificationCustomRelativePointOfTime => 'beforestart',
            UserID                                => $UserID,
        },
        Result => {
            NotificationDate                      => '2016-08-31 23:58:00',
            NotificationTemplate                  => 'Custom',
            NotificationCustom                    => 'relative',
            NotificationCustomRelativeUnitCount   => 2,
            NotificationCustomRelativeUnit        => 'minutes',
            NotificationCustomRelativePointOfTime => 'beforestart',
            NotificationCustomDateTime            => '',
        },
    },

# update appointment from custom 2 minutes before start template to custom relative notification 2 hours before start template
    {
        DataBefore => {
            CalendarID           => $Calendar{CalendarID},
            Title                => 'Update notification appointment 8',
            Description          => 'Update to notification custom relative notification 2 hours before start',
            Location             => 'Germany',
            StartTime            => '2016-09-01 00:00:00',
            EndTime              => '2016-09-02 00:00:00',
            AllDay               => 1,
            TimezoneID           => 1,
            NotificationTemplate => 'Custom',
            NotificationCustomRelativeInput       => 1,
            NotificationCustomDateTimeInput       => 0,
            NotificationCustomRelativeUnitCount   => 2,
            NotificationCustomRelativeUnit        => 'minutes',
            NotificationCustomRelativePointOfTime => 'beforestart',
            UserID                                => $UserID,
        },
        DataAfter => {
            CalendarID           => $Calendar{CalendarID},
            Title                => 'Update notification appointment 8',
            Description          => 'Update to notification custom relative notification 2 hours before start',
            Location             => 'Germany',
            StartTime            => '2016-09-01 00:00:00',
            EndTime              => '2016-09-02 00:00:00',
            AllDay               => 1,
            TimezoneID           => 1,
            NotificationTemplate => 'Custom',
            NotificationCustomRelativeInput       => 1,
            NotificationCustomDateTimeInput       => 0,
            NotificationCustomRelativeUnitCount   => 2,
            NotificationCustomRelativeUnit        => 'hours',
            NotificationCustomRelativePointOfTime => 'beforestart',
            UserID                                => $UserID,
        },
        Result => {
            NotificationDate                      => '2016-08-31 22:00:00',
            NotificationTemplate                  => 'Custom',
            NotificationCustom                    => 'relative',
            NotificationCustomRelativeUnitCount   => 2,
            NotificationCustomRelativeUnit        => 'hours',
            NotificationCustomRelativePointOfTime => 'beforestart',
            NotificationCustomDateTime            => '',
        },
    },

# update appointment from custom relative notification 2 hours before start template to custom relative notification 2 days before start template
    {
        DataBefore => {
            CalendarID           => $Calendar{CalendarID},
            Title                => 'Update notification appointment 9',
            Description          => 'Update to notification custom relative notification 2 days before start',
            Location             => 'Germany',
            StartTime            => '2016-09-01 00:00:00',
            EndTime              => '2016-09-02 00:00:00',
            AllDay               => 1,
            TimezoneID           => 1,
            NotificationTemplate => 'Custom',
            NotificationCustomRelativeInput       => 1,
            NotificationCustomDateTimeInput       => 0,
            NotificationCustomRelativeUnitCount   => 2,
            NotificationCustomRelativeUnit        => 'hours',
            NotificationCustomRelativePointOfTime => 'beforestart',
            UserID                                => $UserID,
        },
        DataAfter => {
            CalendarID           => $Calendar{CalendarID},
            Title                => 'Update notification appointment 9',
            Description          => 'Update to notification custom relative notification 2 days before start',
            Location             => 'Germany',
            StartTime            => '2016-09-01 00:00:00',
            EndTime              => '2016-09-02 00:00:00',
            AllDay               => 1,
            TimezoneID           => 1,
            NotificationTemplate => 'Custom',
            NotificationCustomRelativeInput       => 1,
            NotificationCustomDateTimeInput       => 0,
            NotificationCustomRelativeUnitCount   => 2,
            NotificationCustomRelativeUnit        => 'days',
            NotificationCustomRelativePointOfTime => 'beforestart',
            UserID                                => $UserID,
        },
        Result => {
            NotificationDate                      => '2016-08-30 00:00:00',
            NotificationTemplate                  => 'Custom',
            NotificationCustom                    => 'relative',
            NotificationCustomRelativeUnitCount   => 2,
            NotificationCustomRelativeUnit        => 'days',
            NotificationCustomRelativePointOfTime => 'beforestart',
            NotificationCustomDateTime            => '',
        },
    },

# update appointment from custom relative notification 2 days before start template to notification date 2 minutes before start template
    {
        DataBefore => {
            CalendarID                            => $Calendar{CalendarID},
            Title                                 => 'Update notification appointment 10',
            Description                           => 'Update to notification date 2 minutes before start',
            Location                              => 'Germany',
            StartTime                             => '2016-09-01 00:00:00',
            EndTime                               => '2016-09-02 00:00:00',
            AllDay                                => 1,
            TimezoneID                            => 1,
            NotificationTemplate                  => 'Custom',
            NotificationCustomRelativeInput       => 1,
            NotificationCustomDateTimeInput       => 0,
            NotificationCustomRelativeUnitCount   => 2,
            NotificationCustomRelativeUnit        => 'days',
            NotificationCustomRelativePointOfTime => 'beforestart',
            UserID                                => $UserID,
        },
        DataAfter => {
            CalendarID                            => $Calendar{CalendarID},
            Title                                 => 'Update notification appointment 10',
            Description                           => 'Update to notification date 2 minutes before start',
            Location                              => 'Germany',
            StartTime                             => '2016-09-01 00:00:00',
            EndTime                               => '2016-09-02 00:00:00',
            AllDay                                => 1,
            TimezoneID                            => 1,
            NotificationTemplate                  => 'Custom',
            NotificationCustomRelativeInput       => 0,
            NotificationCustomDateTimeInput       => 1,
            NotificationCustomRelativeUnitCount   => undef,
            NotificationCustomRelativeUnit        => undef,
            NotificationCustomRelativePointOfTime => undef,
            NotificationCustomDateTime            => '2016-08-31 23:58:00',
            UserID                                => $UserID,
        },
        Result => {
            NotificationDate                      => '2016-08-31 23:58:00',
            NotificationTemplate                  => 'Custom',
            NotificationCustom                    => 'datetime',
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => '',
            NotificationCustomRelativePointOfTime => '',
            NotificationCustomDateTime            => '2016-08-31 23:58:00',
        },
    },

    # update appointment from custom relative notification 2 hours before start template to no notification template
    {
        DataBefore => {
            CalendarID           => $Calendar{CalendarID},
            Title                => 'Update notification appointment 11',
            Description          => 'Update to notification custom relative notification 2 days before start',
            Location             => 'Germany',
            StartTime            => '2016-09-01 00:00:00',
            EndTime              => '2016-09-02 00:00:00',
            AllDay               => 1,
            TimezoneID           => 1,
            NotificationTemplate => 'Custom',
            NotificationCustomRelativeInput       => 1,
            NotificationCustomDateTimeInput       => 0,
            NotificationCustomRelativeUnitCount   => 2,
            NotificationCustomRelativeUnit        => 'days',
            NotificationCustomRelativePointOfTime => 'beforestart',
            UserID                                => $UserID,
        },
        DataAfter => {
            CalendarID           => $Calendar{CalendarID},
            Title                => 'Update notification appointment 11',
            Description          => 'Update to no notification template',
            Location             => 'Germany',
            StartTime            => '2016-09-01 00:00:00',
            EndTime              => '2016-09-02 00:00:00',
            AllDay               => 1,
            TimezoneID           => 1,
            NotificationTemplate => 0,
            UserID               => $UserID,
        },
        Result => {
            NotificationDate                      => '',
            NotificationTemplate                  => '',
            NotificationCustom                    => '',
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => '',
            NotificationCustomRelativePointOfTime => '',
            NotificationCustomDateTime            => '',
        },
    },

    # update appointment from custom relative notification 2 hours before start template to no notification template
    # verify that not needed values are flushed afterwards
    {
        DataBefore => {
            CalendarID           => $Calendar{CalendarID},
            Title                => 'Update notification appointment 11',
            Description          => 'Update to notification custom relative notification 2 days before start',
            Location             => 'Germany',
            StartTime            => '2016-09-01 00:00:00',
            EndTime              => '2016-09-02 00:00:00',
            AllDay               => 1,
            TimezoneID           => 1,
            NotificationTemplate => 'Custom',
            NotificationCustomRelativeInput       => 1,
            NotificationCustomDateTimeInput       => 0,
            NotificationCustomRelativeUnitCount   => 2,
            NotificationCustomRelativeUnit        => 'days',
            NotificationCustomRelativePointOfTime => 'beforestart',
            UserID                                => $UserID,
        },
        DataAfter => {
            CalendarID                            => $Calendar{CalendarID},
            Title                                 => 'Update notification appointment 11',
            Description                           => 'Update to no notification template',
            Location                              => 'Germany',
            StartTime                             => '2016-09-01 00:00:00',
            EndTime                               => '2016-09-02 00:00:00',
            AllDay                                => 1,
            TimezoneID                            => 1,
            NotificationTemplate                  => 0,
            NotificationCustomRelativeInput       => 1,
            NotificationCustomDateTimeInput       => 0,
            NotificationCustomRelativeUnitCount   => 30,
            NotificationCustomRelativeUnit        => 'days',
            NotificationCustomRelativePointOfTime => 'beforestart',
            UserID                                => $UserID,
        },
        Result => {
            NotificationDate                      => '',
            NotificationTemplate                  => '',
            NotificationCustom                    => '',
            NotificationCustomRelativeUnitCount   => 0,
            NotificationCustomRelativeUnit        => '',
            NotificationCustomRelativePointOfTime => '',
            NotificationCustomDateTime            => '',
        },
    },
);

# notification update test execution
for my $Test (@NotificationUpdateTests) {

    # create appointment
    my $AppointmentID = $AppointmentObject->AppointmentCreate(
        %{ $Test->{DataBefore} },
        UserID => $UserID,
    );

    # verify appointment creation
    $Self->True(
        $AppointmentID,
        'Notification appointment created - ' . $Test->{DataBefore}->{Description},
    );

    # retrieve stored appointment information
    my %AppointmentData = $AppointmentObject->AppointmentGet(
        AppointmentID => $AppointmentID,
    );

    # verify appointment data get
    my $Created = IsHashRefWithData( \%AppointmentData );
    $Self->True(
        $Created,
        'Notification appointment data retrieved - ' . $Test->{DataBefore}->{Description},
    );

    # update appointment
    my $Success = $AppointmentObject->AppointmentUpdate(
        %{ $Test->{DataAfter} },
        AppointmentID => $AppointmentID,
        UserID        => $UserID,
    );

    # verify appointment update
    $Self->True(
        $Success,
        'Notification appointment updated - ' . $Test->{DataAfter}->{Description},
    );

    # retrieve stored appointment information
    %AppointmentData = $AppointmentObject->AppointmentGet(
        AppointmentID => $AppointmentID,
    );

    # verify appointment data get
    $Created = IsHashRefWithData( \%AppointmentData );
    $Self->True(
        $Created,
        'Notification appointment data retrieved - ' . $Test->{DataBefore}->{Description},
    );

    # verify results
    for my $ResultKey ( sort keys %{ $Test->{Result} } ) {

        $Self->Is(
            $AppointmentData{$ResultKey},
            $Test->{Result}->{$ResultKey},
            'Notification appointment result: ' . $ResultKey . ' - ' . $Test->{DataAfter}->{Description},
        );
    }
}

1;
