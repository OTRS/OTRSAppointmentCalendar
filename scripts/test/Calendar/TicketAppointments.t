# --
# Copyright (C) 2001-2018 OTRS AG, http://otrs.com/
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

my $Helper                  = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
my $MainObject              = $Kernel::OM->Get('Kernel::System::Main');
my $GroupObject             = $Kernel::OM->Get('Kernel::System::Group');
my $UserObject              = $Kernel::OM->Get('Kernel::System::User');
my $QueueObject             = $Kernel::OM->Get('Kernel::System::Queue');
my $DynamicFieldObject      = $Kernel::OM->Get('Kernel::System::DynamicField');
my $DynamicFieldValueObject = $Kernel::OM->Get('Kernel::System::DynamicFieldValue');
my $CalendarObject          = $Kernel::OM->Get('Kernel::System::Calendar');
my $CalendarHelperObject    = $Kernel::OM->Get('Kernel::System::Calendar::Helper');
my $AppointmentObject       = $Kernel::OM->Get('Kernel::System::Calendar::Appointment');
my $TicketObject            = $Kernel::OM->Get('Kernel::System::Ticket');

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

# create test queue with escalation rules
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
    $DynamicField->{DynamicFieldID} = $DynamicFieldID;
}

# Freeze time at this point since creating tickets and checking results can take
#   several seconds to complete.
$Helper->FixedTimeSet(
    $CalendarHelperObject->CurrentSystemTime(),
);

my $TicketCount = 3;

# create a few test tickets
my @TicketIDs;
for my $Count ( 1 .. $TicketCount ) {
    my $TicketTitle = "Ticket$RandomID-$Count";
    my $TicketID    = $TicketObject->TicketCreate(
        Title    => $TicketTitle,
        QueueID  => $QueueID,
        Lock     => 'unlock',
        Priority => '3 normal',
        State    => 'open',
        OwnerID  => 1,
        UserID   => 1,
    );
    $Self->True(
        $TicketID,
        "TicketCreate() - $TicketTitle ($TicketID)",
    );

    # create article
    my $ArticleID = $TicketObject->ArticleCreate(
        TicketID       => $TicketID,
        ArticleType    => 'email-external',
        SenderType     => 'customer',
        From           => 'Some Customer A <customer-a@example.com>',
        To             => 'Some Agent <email@example.com>',
        Subject        => 'some short description',
        Body           => 'the message text',
        ContentType    => 'text/plain; charset=ISO-8859-15',
        HistoryType    => 'EmailCustomer',
        HistoryComment => 'Customer sent an email',
        UserID         => 1,
    );

    # set pending time
    my ( $Second, $Minute, $Hour, $Day, $Month, $Year, $DayOfWeek ) = $CalendarHelperObject->DateGet(
        SystemTime => $CalendarHelperObject->CurrentSystemTime() + 60 * 60 * 24,    # +24h
    );
    my $Success = $TicketObject->TicketPendingTimeSet(
        Year     => $Year,
        Month    => $Month,
        Day      => $Day,
        Hour     => $Hour,
        Minute   => $Minute,
        TicketID => $TicketID,
        UserID   => 1,
    );
    $Self->True(
        $Success,
        "TicketPendingTimeSet - Ticket $TicketID: "
            . sprintf( '%d-%02d-%02d %02d:%02d', $Year, $Month, $Day, $Hour, $Minute ),
    );

    # set dynamic field values
    $Success = $DynamicFieldValueObject->ValueSet(
        FieldID  => $DynamicFields[0]->{DynamicFieldID},
        ObjectID => $TicketID,
        Value    => [
            {
                ValueDateTime => '2016-01-01 00:00:00',
            },
        ],
        UserID => $UserID,
    );
    $Self->True(
        $Success,
        "ValueSet - $DynamicFields[0]->{DynamicFieldID} for ticket $TicketID",
    );

    $Success = $DynamicFieldValueObject->ValueSet(
        FieldID  => $DynamicFields[1]->{DynamicFieldID},
        ObjectID => $TicketID,
        Value    => [
            {
                ValueDateTime => '2016-01-01 12:00:00',
            },
        ],
        UserID => $UserID,
    );
    $Self->True(
        $Success,
        "ValueSet - $DynamicFields[1]->{DynamicFieldID} for ticket $TicketID",
    );

    push @TicketIDs, $TicketID;
}

# create test calendar
my $CalendarName = "Calendar$RandomID";
my %Calendar     = $CalendarObject->CalendarCreate(
    CalendarName => $CalendarName,
    Color        => '#3A87AD',
    GroupID      => $GroupID,
    UserID       => $UserID,
);
$Self->True(
    $Calendar{CalendarID},
    "CalendarCreate - $CalendarName ($Calendar{CalendarID})",
);

# Generate few random strings for RuleIDs.
my @RuleIDs;
for ( 1 .. 5 ) {
    push @RuleIDs, $MainObject->GenerateRandomString(
        Length     => 32,
        Dictionary => [ 0 .. 9, 'a' .. 'f' ],
    );
}

#
# Tests for ticket appointments
#
my @Tests = (
    {
        Name               => 'FirstResponseTime',
        TicketAppointments => [
            {
                RuleID       => $RuleIDs[0],
                StartDate    => 'FirstResponseTime',
                EndDate      => 'Plus_5',
                QueueID      => [$QueueID],
                SearchParams => {
                    Title => "*$RandomID",
                },
            },
        ],
        Result => {
            Count             => $TicketCount,
            TicketAppointment => 'FirstResponseTime',
            StartTime         => 'FirstResponseTime',
            EndTime           => 'Plus_5',
            Cleanup           => [],
        },
    },
    {
        Name               => 'UpdateTime',
        TicketAppointments => [
            {
                RuleID       => $RuleIDs[1],
                StartDate    => 'UpdateTime',
                EndDate      => 'Plus_15',
                QueueID      => [$QueueID],
                SearchParams => {
                    Title => "*$RandomID",
                },
            },
        ],
        Result => {
            Count             => $TicketCount,
            TicketAppointment => 'UpdateTime',
            StartTime         => 'UpdateTime',
            EndTime           => 'Plus_15',
            Cleanup           => [
                {
                    RuleID  => $RuleIDs[0],
                    Success => 1,
                },
            ],
        },
    },
    {
        Name               => 'SolutionTime',
        TicketAppointments => [
            {
                RuleID       => $RuleIDs[2],
                StartDate    => 'SolutionTime',
                EndDate      => 'Plus_30',
                QueueID      => [$QueueID],
                SearchParams => {
                    Title => "*$RandomID",
                },
            },
        ],
        Result => {
            Count             => $TicketCount,
            TicketAppointment => 'SolutionTime',
            StartTime         => 'SolutionTime',
            EndTime           => 'Plus_30',
            Cleanup           => [
                {
                    RuleID  => $RuleIDs[1],
                    Success => 1,
                },
            ],
        },
    },
    {
        Name               => 'PendingTime',
        TicketAppointments => [
            {
                RuleID       => $RuleIDs[3],
                StartDate    => 'PendingTime',
                EndDate      => 'Plus_60',
                QueueID      => [$QueueID],
                SearchParams => {
                    Title => "*$RandomID",
                },
            },
        ],
        Result => {
            Count             => $TicketCount,
            TicketAppointment => 'PendingTime',
            StartTime         => 'PendingTime',
            EndTime           => 'Plus_60',
            Cleanup           => [
                {
                    RuleID  => $RuleIDs[2],
                    Success => 1,
                },
            ],
        },
        Update => {
            StartTime => '2016-01-01 00:00:00',
            EndTime   => '2016-01-01 01:00:00',
        },
        UpdateResult => {
            UntilTime => -(
                $CalendarHelperObject->CurrentSystemTime() -
                    $CalendarHelperObject->SystemTimeGet(
                    String => '2016-01-01 00:00:00',
                    )
            ),
        },
    },
    {
        Name               => 'DynamicField',
        TicketAppointments => [
            {
                RuleID       => $RuleIDs[4],
                StartDate    => 'DynamicField_' . $DynamicFields[0]->{Name},
                EndDate      => 'DynamicField_' . $DynamicFields[1]->{Name},
                QueueID      => [$QueueID],
                SearchParams => {
                    Title => "*$RandomID",
                },
            },
        ],
        Result => {
            Count             => $TicketCount,
            TicketAppointment => 'DynamicField',
            StartTime         => 'DynamicField_' . $DynamicFields[0]->{Name},
            EndTime           => 'DynamicField_' . $DynamicFields[1]->{Name},
            Cleanup           => [
                {
                    RuleID  => $RuleIDs[3],
                    Success => 1,
                },
            ],
        },
        Update => {
            StartTime => '2016-03-01 00:00:00',
            EndTime   => '2016-03-01 01:00:00',
        },
        UpdateResult => {
            'DynamicField_' . $DynamicFields[0]->{Name} => '2016-03-01 00:00:00',
            'DynamicField_' . $DynamicFields[1]->{Name} => '2016-03-01 01:00:00',
        },
    },
);

for my $Test (@Tests) {

    # update test calendar
    my $Success = $CalendarObject->CalendarUpdate(
        %Calendar,
        TicketAppointments => $Test->{TicketAppointments},
        UserID             => $UserID,
    );
    $Self->True(
        $Success,
        "$Test->{Name} - CalendarUpdate - Update ticket appointments rule",
    );

    # Process ticket appointments of the calendar.
    my %Result = $CalendarObject->TicketAppointmentProcessCalendar(
        CalendarID => $Calendar{CalendarID},
    );

    my %ResultCompare;
    for my $TicketID ( sort @TicketIDs ) {
        push @{ $ResultCompare{Process} }, {
            TicketID => $TicketID,
            RuleID   => $Test->{TicketAppointments}->[0]->{RuleID},
            Success  => 1,
        };
    }
    $ResultCompare{Cleanup} = $Test->{Result}->{Cleanup};

    $Self->IsDeeply(
        \%Result,
        \%ResultCompare,
        "$Test->{Name} - TicketAppointmentProcessCalendar - Result",
    );

    # get appointments
    my @Appointments = $AppointmentObject->AppointmentList(
        CalendarID => $Calendar{CalendarID},
    );

    # check appointment count
    $Self->Is(
        scalar @Appointments,
        $Test->{Result}->{Count},
        "$Test->{Name} - Ticket appointment count",
    );

    for my $Appointment (@Appointments) {

        # get ticket id by ticket number
        $Appointment->{Title} =~ /#([0-9]+)\]/;
        my $TicketID = $TicketObject->TicketIDLookup(
            TicketNumber => $1,
            UserID       => 1,
        );

        # get ticket
        my %Ticket = $TicketObject->TicketGet(
            TicketID      => $TicketID,
            DynamicFields => 1,
            UserID        => 1,
        );

        # check if appointment is of ticket appointment type
        $Self->True(
            $Appointment->{TicketAppointmentRuleID},
            "$Test->{Name} - Ticket appointment type",
        );

        for my $Field (qw(StartTime EndTime)) {
            my $Key = $Test->{Result}->{$Field};

            # determine ticket value for the field
            my $TicketValue;

            # escalation times
            if (
                $Test->{Result}->{$Field} eq 'FirstResponseTime'
                || $Test->{Result}->{$Field} eq 'UpdateTime'
                || $Test->{Result}->{$Field} eq 'SolutionTime'
                )
            {
                $TicketValue = $Ticket{ $Test->{Result}->{$Field} . 'DestinationDate' };
            }

            # pending time
            elsif ( $Test->{Result}->{$Field} eq 'PendingTime' ) {
                $TicketValue = $CalendarHelperObject->TimestampGet(
                    SystemTime => $CalendarHelperObject->CurrentSystemTime() + $Ticket{UntilTime},
                );
            }

            # dynamic field
            else {
                $TicketValue = $Ticket{ $Test->{Result}->{$Field} };
            }

            # save start time value
            if ( $Field eq 'StartTime' ) {
                $Test->{Result}->{StartTimeValue} = $TicketValue;
            }

            # determine preset value
            my $Value;
            if ( $Key =~ /^Plus_([0-9]+)$/ ) {
                my $Preset = int $1;

                # get start time
                my $StartTime = $CalendarHelperObject->SystemTimeGet(
                    String => $Test->{Result}->{StartTimeValue},
                );

                # calculate end time using preset value
                my $EndTime = $StartTime + 60 * $Preset;
                $TicketValue = $CalendarHelperObject->TimestampGet(
                    SystemTime => $EndTime,
                );
            }

            # compare values
            $Self->Is(
                $Appointment->{$Field},
                $TicketValue,
                "$Test->{Name} - Appointment $Field",
            );
        }

        if ( $Test->{Update} ) {
            my $Success = $AppointmentObject->AppointmentUpdate(
                %{$Appointment},
                %{ $Test->{Update} },
                UserID => 1,
            );
            $Self->True(
                $Success,
                "$Test->{Name} - Appointment update",
            );

            # manually trigger appointment event module
            $CalendarObject->TicketAppointmentUpdateTicket(
                AppointmentID => $Appointment->{AppointmentID},
                TicketID      => $TicketID,
            );

            # make sure cache is correct
            $Kernel::OM->Get('Kernel::System::Cache')->CleanUp( Type => 'Ticket' );

            # get ticket data again
            my %Ticket = $TicketObject->TicketGet(
                TicketID      => $TicketID,
                DynamicFields => 1,
                UserID        => 1,
            );

            # compare values
            for my $Field ( sort keys %{ $Test->{UpdateResult} } ) {
                $Self->Is(
                    $Ticket{$Field},
                    $Test->{UpdateResult}->{$Field},
                    "$Test->{Name} - Ticket $Field",
                );
            }
        }
    }
}

# Cleanup is done by RestoreDatabase.

1;
