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

# get Appointment object
my $CalendarObject    = $Kernel::OM->Get('Kernel::System::Calendar');
my $AppointmentObject = $Kernel::OM->Get('Kernel::System::Calendar::Appointment');

# get helper object
$Kernel::OM->ObjectParamAdd(
    'Kernel::System::UnitTest::Helper' => {
        RestoreDatabase => 1,
    },
);
my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');

my $UserID = 1;    # Use root

# This will be ok
my %Calendar1 = $CalendarObject->CalendarCreate(
    CalendarName => 'Test calendar',
    UserID       => $UserID,
);

$Self->True(
    $Calendar1{CalendarID},
    'CalendarCreate( CalendarName => "Test calendar", UserID => 1 ) - CalendarID',
);

# only required fields
my $AppointmentID1 = $AppointmentObject->AppointmentCreate(
    CalendarID          => $Calendar1{CalendarID},
    Title               => 'Webinar',
#    Description         => 'How to use Process tickets...', # opt
#    Location            => 'Straubing', # opt
    StartTime           => '2016-01-01 16:00:00',
#    EndTime             => '2016-01-01 17:00:00',   # op
    TimezoneID          => 'Timezone',
    # RecurrenceFrequency => '1',                                     # (optional)
    # RecurrenceCount     => '1',                                     # (optional)
    # RecurrenceInterval  => '',                                      # (optional)
    # RecurrenceUntil     => '',                                      # (optional)
    # RecurrenceByMonth   => '',                                      # (optional)
    # RecurrenceByDay     => '',                                      # (optional)
    UserID              => $UserID,                                       # (required) UserID
);

$Self->True(
    $AppointmentID1,
    'AppointmentCreate #1',
);

# No CalendarID
my $AppointmentID2 = $AppointmentObject->AppointmentCreate(
    Title               => 'Webinar',
    StartTime           => '2016-01-01 16:00:00',
    TimezoneID          => 'Timezone',
    UserID              => $UserID,
);

$Self->False(
    $AppointmentID2,
    'AppointmentCreate #2',
);

# No Title
my $AppointmentID3 = $AppointmentObject->AppointmentCreate(
    CalendarID          => $Calendar1{CalendarID},
    StartTime           => '2016-01-01 16:00:00',
    TimezoneID          => 'Timezone',
    UserID              => $UserID,
);

$Self->False(
    $AppointmentID3,
    'AppointmentCreate #3',
);

# No StartTime
my $AppointmentID4 = $AppointmentObject->AppointmentCreate(
    CalendarID          => $Calendar1{CalendarID},
    Title               => 'Webinar',
    TimezoneID          => 'Timezone',
    UserID              => $UserID,
);

$Self->False(
    $AppointmentID4,
    'AppointmentCreate #4',
);

# No TimezoneID
my $AppointmentID5 = $AppointmentObject->AppointmentCreate(
    CalendarID          => $Calendar1{CalendarID},
    Title               => 'Webinar',
    StartTime           => '2016-01-01 16:00:00',    
    UserID              => $UserID,
);

$Self->False(
    $AppointmentID5,
    'AppointmentCreate #5',
);

# No UserID
my $AppointmentID6 = $AppointmentObject->AppointmentCreate(
    CalendarID          => $Calendar1{CalendarID},
    Title               => 'Webinar',
    StartTime           => '2016-01-01 16:00:00',
    TimezoneID          => 'Timezone',    
);

$Self->False(
    $AppointmentID6,
    'AppointmentCreate #6',
);


1;
