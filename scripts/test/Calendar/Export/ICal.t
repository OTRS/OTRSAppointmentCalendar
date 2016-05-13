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
my $UserObject        = $Kernel::OM->Get('Kernel::System::User');
my $GroupObject       = $Kernel::OM->Get('Kernel::System::Group');
my $CalendarObject    = $Kernel::OM->Get('Kernel::System::Calendar');
my $AppointmentObject = $Kernel::OM->Get('Kernel::System::Calendar::Appointment');
my $ExportObject      = $Kernel::OM->Get('Kernel::System::Calendar::Export::ICal');
my $ImportObject      = $Kernel::OM->Get('Kernel::System::Calendar::Import::ICal');

# get helper object
$Kernel::OM->ObjectParamAdd(
    'Kernel::System::UnitTest::Helper' => {
        RestoreDatabase => 1,
    },
);
my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');

# create test user
my $UserLogin = $Helper->TestUserCreate();
my $UserID = $UserObject->UserLookup( UserLogin => $UserLogin );

$Self->True(
    $UserID,
    "Test user $UserID created",
);

# create test group
my $GroupName = 'test-calendar-group-' . $Helper->GetRandomID();
my $GroupID   = $GroupObject->GroupAdd(
    Name    => $GroupName,
    ValidID => 1,
    UserID  => 1,
);

$Self->True(
    $GroupID,
    "Test group $UserID created",
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

# create a test calendar for export
my $ExportCalendarName = 'Export ' . $Helper->GetRandomID();
my %ExportCalendar     = $CalendarObject->CalendarCreate(
    CalendarName => $ExportCalendarName,
    GroupID      => $GroupID,
    UserID       => $UserID,
);

$Self->True(
    $ExportCalendar{CalendarID},
    "CalendarCreate( CalendarName => '$ExportCalendarName', GroupID => $GroupID, UserID => $UserID ) - CalendarID: $ExportCalendar{CalendarID}",
);

# sample appointments
my @Appointments = (

    # regular
    {
        CalendarID  => $ExportCalendar{CalendarID},
        StartTime   => '2016-03-01 10:00:00',
        EndTime     => '2016-03-01 12:00:00',
        TimezoneID  => 0,
        Title       => 'Regular Appointment',
        Description => 'Sample description',
        UserID      => $UserID,
    },

    # timezone
    {
        CalendarID  => $ExportCalendar{CalendarID},
        StartTime   => '2016-03-01 12:00:00',
        EndTime     => '2016-03-01 14:00:00',
        TimezoneID  => 2,
        Title       => 'TZ Appointment',
        Description => 'Appointment with timezone offset',
        UserID      => $UserID,
    },

    # all-day
    {
        CalendarID => $ExportCalendar{CalendarID},
        StartTime  => '2016-03-01 00:00:00',
        EndTime    => '2016-03-02 00:00:00',
        AllDay     => 1,
        TimezoneID => 0,
        Title      => 'All-day Appointment',
        Location   => 'Sample location',
        UserID     => $UserID,
    },

    # recurring
    {
        CalendarID      => $ExportCalendar{CalendarID},
        StartTime       => '2016-03-01 15:00:00',
        EndTime         => '2016-03-01 16:00:00',
        TimezoneID      => 0,
        Recurring       => 1,
        RecurrenceByDay => 1,
        RecurrenceCount => 3,
        Title           => 'Recurring Appointment',
        Description     => 'Every day, for 3 days',
        UserID          => $UserID,
    }
);

for my $Appointment (@Appointments) {
    my $AppointmentID = $AppointmentObject->AppointmentCreate(
        %{$Appointment},
    );

    $Self->True(
        $AppointmentID,
        "AppointmentCreate() - AppointmentID: $AppointmentID",
    );
}

# export appointments
my $ICalString = $ExportObject->Export(
    CalendarID => $ExportCalendar{CalendarID},
    UserID     => $UserID,
);

# get exported appointments
my @ExportedAppointments = $AppointmentObject->AppointmentList(
    CalendarID => $ExportCalendar{CalendarID},
    Result     => 'HASH',
);

$Self->True(
    $ICalString,
    'Export() - Calendar exported to iCal format',
);

$Kernel::OM->Get('Kernel::System::Log')->Dumper($ICalString);

# create a test calendar for import
my $ImportCalendarName = 'Import ' . $Helper->GetRandomID();
my %ImportCalendar     = $CalendarObject->CalendarCreate(
    CalendarName => $ImportCalendarName,
    GroupID      => $GroupID,
    UserID       => $UserID,
);

$Self->True(
    $ImportCalendar{CalendarID},
    "CalendarCreate( CalendarName => '$ImportCalendarName', GroupID => $GroupID, UserID => $UserID ) - CalendarID: $ImportCalendar{CalendarID}",
);

# import appointments
$Success = $ImportObject->Import(
    CalendarID => $ImportCalendar{CalendarID},
    ICal       => $ICalString,
    UserID     => $UserID,
);

$Self->True(
    $Success,
    'Import() - Calendar imported from iCal format',
);

# get imported appointments
my @ImportedAppointments = $AppointmentObject->AppointmentList(
    CalendarID => $ImportCalendar{CalendarID},
    Result     => 'HASH',
);

# number of imported and exported appointments match
$Self->Is(
    scalar @ImportedAppointments,
    scalar @ExportedAppointments,
    'Imported appointment count'
);

1;
