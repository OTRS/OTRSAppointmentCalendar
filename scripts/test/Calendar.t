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
my $CalendarObject    = $Kernel::OM->Get('Kernel::System::Calendar');
my $AppointmentObject = $Kernel::OM->Get('Kernel::System::Calendar::Appointment');
my $GroupObject       = $Kernel::OM->Get('Kernel::System::Group');
my $UserObject        = $Kernel::OM->Get('Kernel::System::User');

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

my @CalendarIDs;

#
# Tests for CalendarCreate()
#
my @Tests = (
    {
        Name    => 'CalendarCreate - No params',
        Config  => {},
        Success => 0,
    },
    {
        Name   => 'CalendarCreate - Missing CalendarName',
        Config => {
            Color   => '#3A87AD',
            GroupID => $GroupID,
            UserID  => $UserID,
        },
        Success => 0,
    },
    {
        Name   => 'CalendarCreate - Missing UserID',
        Config => {
            CalendarName => "Calendar-$RandomID",
            Color        => '#3A87AD',
            GroupID      => $GroupID,
        },
        Success => 0,
    },
    {
        Name   => 'CalendarCreate - Missing GroupID',
        Config => {
            CalendarName => "Calendar-$RandomID",
            Color        => '#3A87AD',
            UserID       => $UserID,
        },
        Success => 0,
    },
    {
        Name   => 'CalendarCreate - Missing Color',
        Config => {
            CalendarName => "Calendar-$RandomID",
            GroupID      => $GroupID,
            UserID       => $UserID,
        },
        Success => 0,
    },
    {
        Name   => 'CalendarCreate - Wrong Color',
        Config => {
            CalendarName => "Calendar-$RandomID",
            Color        => 'red',
            GroupID      => $GroupID,
            UserID       => $UserID,
        },
        Success => 0,
    },
    {
        Name   => 'CalendarCreate - All parameters',
        Config => {
            CalendarName => "Calendar-$RandomID",
            Color        => '#3A87AD',
            GroupID      => $GroupID,
            UserID       => $UserID,
        },
        Success => 1,
    },
    {
        Name   => 'CalendarCreate - Same name',
        Config => {
            CalendarName => "Calendar-$RandomID",
            Color        => '#3A87AD',
            GroupID      => $GroupID,
            UserID       => $UserID,
        },
        Success => 0,
    },
    {
        Name   => 'CalendarCreate - Invalid state',
        Config => {
            CalendarName => "Calendar-$RandomID-2",
            Color        => '#EC9073',
            GroupID      => $GroupID,
            UserID       => $UserID,
            ValidID      => 2,
        },
        Success => 1,
    },
);

for my $Test (@Tests) {

    # make the call
    my %Calendar = $CalendarObject->CalendarCreate(
        %{ $Test->{Config} },
    );

    # check data
    if ( $Test->{Success} ) {
        for my $Key (qw(CalendarID GroupID CalendarName Color CreateTime CreateBy ChangeTime ChangeBy ValidID)) {
            $Self->True(
                $Calendar{$Key},
                "$Test->{Name} - $Key exists",
            );
        }

        KEY:
        for my $Key ( sort keys %{ $Test->{Config} } ) {
            next KEY if $Key eq 'UserID';

            $Self->Is(
                $Test->{Config}->{$Key},
                $Calendar{$Key},
                "$Test->{Name} - Data for $Key",
            );
        }

        push @CalendarIDs, $Calendar{CalendarID};
    }
    else {
        $Self->False(
            $Calendar{CalendarID},
            "$Test->{Name} - No success",
        );
    }
}

#
# Tests for CalendarGet()
#
@Tests = (
    {
        Name    => 'CalendarGet - No params',
        Config  => {},
        Success => 0,
    },
    {
        Name   => 'CalendarGet - Missing CalendarName and CalendarID',
        Config => {
            UserID => $UserID,
        },
        Success => 0,
    },
    {
        Name   => 'CalendarGet - First calendar',
        Config => {
            CalendarName => "Calendar-$RandomID",
            UserID       => $UserID,
        },
        Success => 1,
    },
    {
        Name   => 'CalendarGet - Second calendar',
        Config => {
            CalendarName => "Calendar-$RandomID-2",
            UserID       => $UserID,
        },
        Success => 1,
    },
);

for my $Test (@Tests) {

    # make the call
    my %Calendar = $CalendarObject->CalendarGet(
        %{ $Test->{Config} },
    );

    # check data
    if ( $Test->{Success} ) {
        for my $Key (qw(CalendarID GroupID CalendarName Color CreateTime CreateBy ChangeTime ChangeBy ValidID)) {
            $Self->True(
                $Calendar{$Key},
                "$Test->{Name} - $Key exists",
            );
        }

        # get by id
        my %CalendarByID = $CalendarObject->CalendarGet(
            CalendarID => $Calendar{CalendarID},
        );

        # compare returned data
        $Self->IsDeeply(
            \%Calendar,
            \%CalendarByID,
            "$Test->{Name} - Get by CalendarID",
        );
    }
    else {
        $Self->False(
            $Calendar{CalendarID},
            "$Test->{Name} - No success",
        );
    }
}

#
# Tests for CalendarList()
#
@Tests = (
    {
        Name    => 'CalendarList - No params',
        Config  => {},
        Success => 1,
    },
    {
        Name   => 'CalendarList - With UserID',
        Config => {
            UserID => $UserID,
        },
        Success => 1,
        Count   => 2,
    },
    {
        Name   => 'CalendarList - With UserID and only valid',
        Config => {
            ValidID => 1,
            UserID  => $UserID,
        },
        Success => 1,
        Count   => 1,
    },
    {
        Name   => 'CalendarList - With UserID and only invalid',
        Config => {
            ValidID => 2,
            UserID  => $UserID,
        },
        Success => 1,
        Count   => 1,
    },
);

for my $Test (@Tests) {

    # make the call
    my @Result = $CalendarObject->CalendarList(
        %{ $Test->{Config} },
    );

    # check data
    if ( $Test->{Success} ) {

        # check count
        if ( $Test->{Count} ) {
            $Self->Is(
                scalar @Result,
                $Test->{Count},
                "$Test->{Name} - Result count",
            );

            # compare returned data
            for my $Calendar (@Result) {
                for my $Key (qw(CalendarID GroupID CalendarName Color CreateTime CreateBy ChangeTime ChangeBy ValidID))
                {
                    $Self->True(
                        $Calendar->{$Key},
                        "$Test->{Name} - $Key exists",
                    );
                }

                # get by id
                my %CalendarByID = $CalendarObject->CalendarGet(
                    CalendarID => $Calendar->{CalendarID},
                );

                $Self->IsDeeply(
                    $Calendar,
                    \%CalendarByID,
                    "$Test->{Name} - Compare returned data",
                );
            }
        }
        else {
            $Self->True(
                scalar @Result > 1,
                "$Test->{Name} - Has result",
            );
        }
    }
    else {
        $Self->False(
            @Result,
            "$Test->{Name} - No success",
        );
    }
}

#
# Tests for CalendarUpdate()
#
@Tests = (
    {
        Name    => 'CalendarUpdate - No params',
        Config  => {},
        Success => 0,
    },
    {
        Name   => 'CalendarUpdate - Missing CalendarID',
        Config => {
            GroupID      => $GroupID,
            CalendarName => "Change-$RandomID",
            Color        => '#FF9900',
            UserID       => $UserID,
            ValidID      => 2,
        },
        Success => 0,
    },
    {
        Name   => 'CalendarUpdate - Missing GroupID',
        Config => {
            CalendarID   => $CalendarIDs[0],
            CalendarName => "Change-$RandomID",
            Color        => '#FF9900',
            UserID       => $UserID,
            ValidID      => 2,
        },
        Success => 0,
    },
    {
        Name   => 'CalendarUpdate - Missing CalendarName',
        Config => {
            CalendarID => $CalendarIDs[0],
            GroupID    => $GroupID,
            Color      => '#FF9900',
            UserID     => $UserID,
            ValidID    => 2,
        },
        Success => 0,
    },
    {
        Name   => 'CalendarUpdate - Missing Color',
        Config => {
            CalendarID   => $CalendarIDs[0],
            GroupID      => $GroupID,
            CalendarName => "Change-$RandomID",
            UserID       => $UserID,
            ValidID      => 2,
        },
        Success => 0,
    },
    {
        Name   => 'CalendarUpdate - Missing UserID',
        Config => {
            CalendarID   => $CalendarIDs[0],
            GroupID      => $GroupID,
            CalendarName => "Change-$RandomID",
            Color        => '#FF9900',
            ValidID      => 2,
        },
        Success => 0,
    },
    {
        Name   => 'CalendarUpdate - Missing ValidID',
        Config => {
            CalendarID   => $CalendarIDs[0],
            GroupID      => $GroupID,
            CalendarName => "Change-$RandomID",
            Color        => '#FF9900',
            UserID       => $UserID,
        },
        Success => 0,
    },
    {
        Name   => 'CalendarUpdate - All params first',
        Config => {
            CalendarID   => $CalendarIDs[0],
            GroupID      => $GroupID,
            CalendarName => "Change-$RandomID",
            Color        => '#FF9900',
            UserID       => $UserID,
            ValidID      => 2,
        },
        Success => 1,
    },
    {
        Name   => 'CalendarUpdate - All params second',
        Config => {
            CalendarID   => $CalendarIDs[1],
            GroupID      => $GroupID,
            CalendarName => "Change-$RandomID-2",
            Color        => '#FF9900',
            UserID       => $UserID,
            ValidID      => 1,
        },
        Success => 1,
    },
);

for my $Test (@Tests) {

    # make the call
    my $Success = $CalendarObject->CalendarUpdate(
        %{ $Test->{Config} },
    );

    # check data
    if ( $Test->{Success} ) {
        $Self->True(
            $Success,
            "$Test->{Name} - Success",
        );

        # get by id
        my %Calendar = $CalendarObject->CalendarGet(
            CalendarID => $Test->{Config}->{CalendarID},
        );

        KEY:
        for my $Key ( sort keys %{ $Test->{Config} } ) {
            next KEY if $Key eq 'UserID';

            $Self->Is(
                $Test->{Config}->{$Key},
                $Calendar{$Key},
                "$Test->{Name} - Data for $Key",
            );
        }
    }
    else {
        $Self->False(
            $Success,
            "$Test->{Name} - No success",
        );
    }
}

#
# Tests for CalendarPermissionGet()
#
@Tests = (
    {
        Name    => 'CalendarPermissionGet - No params',
        Config  => {},
        Success => 0,
    },
    {
        Name   => 'CalendarPermissionGet - Missing CalendarID',
        Config => {
            UserID => $UserID,
        },
        Success => 0,
    },
    {
        Name   => 'CalendarPermissionGet - Missing UserID',
        Config => {
            CalendarID => $CalendarIDs[0],
        },
        Success => 0,
    },
    {
        Name   => 'CalendarPermissionGet - All params first',
        Config => {
            CalendarID => $CalendarIDs[0],
            UserID     => $UserID,
        },
        Success => 1,
        Result  => 'rw',
    },
    {
        Name   => 'CalendarPermissionGet - All params second',
        Config => {
            CalendarID => $CalendarIDs[1],
            UserID     => $UserID,
        },
        Success => 1,
        Result  => 'rw',
    },
);

for my $Test (@Tests) {

    # make the call
    my $Permission = $CalendarObject->CalendarPermissionGet(
        %{ $Test->{Config} },
    );

    # check permission
    if ( $Test->{Success} ) {
        $Self->Is(
            $Permission,
            $Test->{Result},
            "$Test->{Name} - Permission",
        );
    }
    else {
        $Self->False(
            $Permission,
            "$Test->{Name} - No success",
        );
    }
}

#
# Tests for GetTextColor()
#
@Tests = (
    {
        Name    => 'GetTextColor - No params',
        Config  => {},
        Success => 0,
    },
    {
        Name   => 'GetTextColor - Invalid color',
        Config => {
            Background => '#CCCCC',
        },
        Success => 0,
    },
    {
        Name   => 'GetTextColor - White',
        Config => {
            Background => '#FFF',
        },
        Success => 1,
        Result  => '#000',
    },
    {
        Name   => 'GetTextColor - Light Gray',
        Config => {
            Background => '#808080',
        },
        Success => 1,
        Result  => '#000',
    },
    {
        Name   => 'GetTextColor - Dark Gray',
        Config => {
            Background => '#797979',
        },
        Success => 1,
        Result  => '#FFFFFF',
    },
    {
        Name   => 'GetTextColor - Black',
        Config => {
            Background => '#000',
        },
        Success => 1,
        Result  => '#FFFFFF',
    },
);

for my $Test (@Tests) {

    # make the call
    my $TextColor = $CalendarObject->GetTextColor(
        %{ $Test->{Config} },
    );

    # check text color
    if ( $Test->{Success} ) {
        $Self->Is(
            $TextColor,
            $Test->{Result},
            "$Test->{Name} - Text color",
        );
    }
    else {
        $Self->False(
            $TextColor,
            "$Test->{Name} - No success",
        );
    }
}

#
# Tests for CalendarExport() and CalendarImport()
#
@Tests = (
    {
        Name    => 'CalendarExport/Import - No params',
        Config  => {},
        Success => 0,
    },
    {
        Name   => 'CalendarExport/Import - No CalendarData',
        Config => {
            UserID => $UserID,
        },
        Success => 0,
    },
    {
        Name   => 'CalendarExport/Import - All params with overwrite',
        Export => {
            CalendarID => $CalendarIDs[0],
            UserID     => $UserID,
        },
        Config => {
            UserID                    => $UserID,
            OverwriteExistingEntities => 1,
        },
        Appointments => [
            {
                CalendarID => $CalendarIDs[0],
                Title      => "Appointment1-$RandomID",
                StartTime  => '2016-01-01 16:00:00',
                EndTime    => '2016-01-01 17:00:00',
                UserID     => $UserID,
            },
            {
                CalendarID => $CalendarIDs[0],
                Title      => "Appointment2-$RandomID",
                StartTime  => '2016-01-01 16:00:00',
                EndTime    => '2016-01-01 17:00:00',
                UserID     => $UserID,
            },
        ],
        Success => 1,
    },
);

for my $Test (@Tests) {

    # create appointments
    if ( $Test->{Appointments} ) {
        for my $Appointment ( @{ $Test->{Appointments} } ) {
            my $AppointmentID = $AppointmentObject->AppointmentCreate(
                %{$Appointment},
            );
            $Self->True(
                $AppointmentID,
                "$Test->{Name} - Created appointment ($AppointmentID)",
            );
        }
    }

    # export calendar
    if ( $Test->{Export} ) {
        my %Data = $CalendarObject->CalendarExport(
            %{ $Test->{Export} },
        );

        $Test->{Config}->{Data} = \%Data;
    }

    # make the call
    my $Success = $CalendarObject->CalendarImport(
        %{ $Test->{Config} },
    );

    # check result
    if ( $Test->{Success} ) {
        $Self->True(
            $Success,
            "$Test->{Name} - Success",
        );

        my %Calendar = $CalendarObject->CalendarGet(
            %{ $Test->{Export} },
        );

        # reset ChangeTime since it might differ by one second
        $Calendar{ChangeTime} = undef;
        $Test->{Config}->{Data}->{CalendarData}->{ChangeTime} = undef;

        $Self->IsDeeply(
            \%Calendar,
            $Test->{Config}->{Data}->{CalendarData},
            "$Test->{Name} - Calendar data",
        );

        my @Appointments = $AppointmentObject->AppointmentList(
            %{ $Test->{Export} },
            Result => 'ARRAY',
        );

        my @AppointmentData;
        for my $AppointmentID (@Appointments) {
            my %Appointment = $AppointmentObject->AppointmentGet(
                AppointmentID => $AppointmentID,
            );
            $Appointment{AppointmentID} = undef;

            push @AppointmentData, \%Appointment;
        }

        for my $Appointment ( @{ $Test->{Config}->{Data}->{AppointmentData} } ) {
            $Appointment->{AppointmentID} = undef;
        }

        $Self->IsDeeply(
            \@AppointmentData,
            $Test->{Config}->{Data}->{AppointmentData},
            "$Test->{Name} - Appointment data",
        );
    }
    else {
        $Self->False(
            $Success,
            "$Test->{Name} - No success",
        );
    }
}

1;
