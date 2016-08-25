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

# get helper object
$Kernel::OM->ObjectParamAdd(
    'Kernel::System::UnitTest::Helper' => {
        RestoreDatabase => 1,
    },
);
my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');

# get needed objects
my $MainObject         = $Kernel::OM->Get('Kernel::System::Main');
my $GroupObject        = $Kernel::OM->Get('Kernel::System::Group');
my $UserObject         = $Kernel::OM->Get('Kernel::System::User');
my $QueueObject        = $Kernel::OM->Get('Kernel::System::Queue');
my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
my $CalendarObject     = $Kernel::OM->Get('Kernel::System::Calendar');
my $AppointmentObject  = $Kernel::OM->Get('Kernel::System::Calendar::Appointment');
my $TicketObject       = $Kernel::OM->Get('Kernel::System::Ticket');

my $RandomID = $Helper->GetRandomID();

# create test user
my $UserLogin = $Helper->TestUserCreate();
my $UserID = $UserObject->UserLookup( UserLogin => $UserLogin );
$Self->True(
    $UserID,
    "TestUserCreate - $UserID",
);

# create test group
my $GroupName = 'Group' . $RandomID;
my $GroupID   = $GroupObject->GroupAdd(
    Name    => $GroupName,
    ValidID => 1,
    UserID  => 1,
);
$Self->True(
    $GroupID,
    "GroupAdd - $GroupName ($GroupID)",
);

# add test user to test group
my $Success = $GroupObject->PermissionGroupUserAdd(
    GID        => $GroupID,
    UID        => $UserID,
    Permission => {
        rw => 1,
    },
    UserID => 1,
);
$Self->True(
    $Success,
    "PermissionGroupUserAdd - Test user $UserID added to test group $GroupID",
);

# create test queue
my $QueueName = 'Queue' . $RandomID;
my $QueueID   = $QueueObject->QueueAdd(
    Name                => $QueueName,
    ValidID             => 1,
    GroupID             => $GroupID,
    FirstResponseTime   => 30,
    FirstResponseNotify => 70,
    UpdateTime          => 240,
    UpdateNotify        => 80,
    SolutionTime        => 2440,
    SolutionNotify      => 90,
    SystemAddressID     => 1,
    SalutationID        => 1,
    SignatureID         => 1,
    UserID              => 1,
    Comment             => 'Some Comment',
);
$Self->True(
    $QueueID,
    "QueueAdd - $QueueName ($QueueID)",
);

# create test dynamic fields
my @DynamicFields = (
    {
        Name       => 'Date' . $RandomID,
        Label      => 'Date' . $RandomID,
        Config     => {},
        FieldOrder => 10000,
        FieldType  => 'Date',
        ObjectType => 'Ticket',
        ValidID    => 1,
        UserID     => 1,
    },
    {
        Name       => 'DateTime' . $RandomID,
        Label      => 'DateTime' . $RandomID,
        Config     => {},
        FieldOrder => 10000,
        FieldType  => 'DateTime',
        ObjectType => 'Ticket',
        ValidID    => 1,
        UserID     => 1,
    },
);
for my $DynamicField (@DynamicFields) {
    my $DynamicFieldID = $DynamicFieldObject->DynamicFieldAdd(
        %{$DynamicField},
    );
    $Self->True(
        $DynamicFieldID,
        "DynamicFieldAdd - $DynamicField->{Name} ($DynamicFieldID)",
    );
}

# create a few test tickets
my @TicketIDs;
for my $Count ( 1 .. 10 ) {
    my $TicketTitle = "Ticket$RandomID-$Count";
    my $TicketID    = $TicketObject->TicketCreate(
        Title    => $TicketTitle,
        QueueID  => $QueueID,
        Lock     => 'unlock',
        Priority => '3 normal',
        State    => 'open',

        # CustomerNo   => '123465',
        # CustomerUser => 'customer@example.com',
        OwnerID => 1,
        UserID  => 1,
    );
    $Self->True(
        $TicketID,
        "TicketCreate() - $TicketTitle ($TicketID)",
    );

    push @TicketIDs, $TicketID;
}

# create test calendar with ticket appointment rules
my $CalendarName = "Calendar$RandomID";
my %Calendar     = $CalendarObject->CalendarCreate(
    CalendarName       => $CalendarName,
    Color              => '#3A87AD',
    GroupID            => $GroupID,
    TicketAppointments => [
        {
            RuleID => $MainObject->GenerateRandomString(
                Length     => 32,
                Dictionary => [ 0 .. 9, 'a' .. 'f' ],
            ),
            StartDate    => 'FirstResponse',
            EndDate      => 'Plus_60',
            QueueID      => [$QueueID],
            SearchParams => {
                Title => "*$RandomID",
            },
        },
        {
            RuleID => $MainObject->GenerateRandomString(
                Length     => 32,
                Dictionary => [ 0 .. 9, 'a' .. 'f' ],
            ),
            StartDate    => 'UpdateTime',
            EndDate      => 'Plus_60',
            QueueID      => [$QueueID],
            SearchParams => {
                Title => "*$RandomID",
            },
        },
        {
            RuleID => $MainObject->GenerateRandomString(
                Length     => 32,
                Dictionary => [ 0 .. 9, 'a' .. 'f' ],
            ),
            StartDate    => 'SolutionTime',
            EndDate      => 'Plus_60',
            QueueID      => [$QueueID],
            SearchParams => {
                Title => "*$RandomID",
            },
        },
        {
            RuleID => $MainObject->GenerateRandomString(
                Length     => 32,
                Dictionary => [ 0 .. 9, 'a' .. 'f' ],
            ),
            StartDate    => 'PendingTime',
            EndDate      => 'Plus_60',
            QueueID      => [$QueueID],
            SearchParams => {
                Title => "*$RandomID",
            },
        },
        {
            RuleID => $MainObject->GenerateRandomString(
                Length     => 32,
                Dictionary => [ 0 .. 9, 'a' .. 'f' ],
            ),
            StartDate    => 'DynamicField_' . $DynamicFields[0]->{Name},
            EndDate      => 'DynamicField_' . $DynamicFields[1]->{Name},
            QueueID      => [$QueueID],
            SearchParams => {
                Title => "*$RandomID",
            },
        },
    ],
    UserID => $UserID,
);

$Self->True(
    $Calendar{CalendarID},
    "CalendarCreate - $CalendarName ($Calendar{CalendarID})",
);

# execute console command
my $CommandObject = $Kernel::OM->Get('Kernel::System::Console::Command::Maint::Calendar::TicketAppointments');
my $ExitCode = $CommandObject->Execute( $Calendar{CalendarID}, '--quiet' );

$Self->Is(
    $ExitCode,
    0,
    'Maint::Calendar::TicketAppointments exit code',
);

# check appointments
my @Appointments = $AppointmentObject->AppointmentList(
    CalendarID => $Calendar{CalendarID},
);

$Self->Is(
    scalar @Appointments,
    10,
    'Ticket Appointment count',
);

# cleanup is done by RestoreDatabase.

1;
