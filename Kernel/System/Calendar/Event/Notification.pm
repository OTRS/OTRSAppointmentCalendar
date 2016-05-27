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

    return 1;
}

sub _NotificationFilter {
    my ( $Self, %Param ) = @_;

    # check needed params
    for my $Needed (qw(Ticket Notification DynamicFieldConfigLookup)) {
        return if !$Param{$Needed};
    }

    # set local values
    my %Notification = %{ $Param{Notification} };

    # get dynamic field backend object
    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    KEY:
    for my $Key ( sort keys %{ $Notification{Data} } ) {

        # ignore not ticket related attributes
        next KEY if $Key eq 'Recipients';
        next KEY if $Key eq 'SkipRecipients';
        next KEY if $Key eq 'RecipientAgents';
        next KEY if $Key eq 'RecipientGroups';
        next KEY if $Key eq 'RecipientRoles';
        next KEY if $Key eq 'TransportEmailTemplate';
        next KEY if $Key eq 'Events';
        next KEY if $Key eq 'ArticleTypeID';
        next KEY if $Key eq 'ArticleSenderTypeID';
        next KEY if $Key eq 'ArticleSubjectMatch';
        next KEY if $Key eq 'ArticleBodyMatch';
        next KEY if $Key eq 'ArticleAttachmentInclude';
        next KEY if $Key eq 'NotificationArticleTypeID';
        next KEY if $Key eq 'Transports';
        next KEY if $Key eq 'OncePerDay';
        next KEY if $Key eq 'VisibleForAgent';
        next KEY if $Key eq 'VisibleForAgentTooltip';
        next KEY if $Key eq 'LanguageID';
        next KEY if $Key eq 'SendOnOutOfOffice';
        next KEY if $Key eq 'AgentEnabledByDefault';
        next KEY if $Key eq 'EmailSecuritySettings';
        next KEY if $Key eq 'EmailSigningCrypting';
        next KEY if $Key eq 'EmailMissingCryptingKeys';
        next KEY if $Key eq 'EmailMissingSigningKeys';
        next KEY if $Key eq 'EmailDefaultSigningKeys';

        # check recipient fields from transport methods
        if ( $Key =~ m{\A Recipient}xms ) {
            next KEY;
        }

        # check ticket attributes
        next KEY if !$Notification{Data}->{$Key};
        next KEY if !@{ $Notification{Data}->{$Key} };
        next KEY if !$Notification{Data}->{$Key}->[0];
        my $Match = 0;

        VALUE:
        for my $Value ( @{ $Notification{Data}->{$Key} } ) {

            next VALUE if !$Value;

            # check if key is a search dynamic field
            if ( $Key =~ m{\A Search_DynamicField_}xms ) {

                # remove search prefix
                my $DynamicFieldName = $Key;

                $DynamicFieldName =~ s{Search_DynamicField_}{};

                # get the dynamic field config for this field
                my $DynamicFieldConfig = $Param{DynamicFieldConfigLookup}->{$DynamicFieldName};

                next VALUE if !$DynamicFieldConfig;

                my $IsNotificationEventCondition = $DynamicFieldBackendObject->HasBehavior(
                    DynamicFieldConfig => $DynamicFieldConfig,
                    Behavior           => 'IsNotificationEventCondition',
                );

                next VALUE if !$IsNotificationEventCondition;

                $Match = $DynamicFieldBackendObject->ObjectMatch(
                    DynamicFieldConfig => $DynamicFieldConfig,
                    Value              => $Value,
                    ObjectAttributes   => $Param{Ticket},
                );

                last VALUE if $Match;
            }
            else {

                if ( $Value eq $Param{Ticket}->{$Key} ) {
                    $Match = 1;
                    last VALUE;
                }
            }
        }

        return if !$Match;
    }

    # match article types only on ArticleCreate or ArticleSend event
    if (
        ( ( $Param{Event} eq 'ArticleCreate' ) || ( $Param{Event} eq 'ArticleSend' ) )
        && $Param{Data}->{ArticleID}
        )
    {

        my %Article = $Kernel::OM->Get('Kernel::System::Ticket')->ArticleGet(
            ArticleID     => $Param{Data}->{ArticleID},
            UserID        => $Param{UserID},
            DynamicFields => 0,
        );

        # check article type
        if ( $Notification{Data}->{ArticleTypeID} ) {

            my $Match = 0;
            VALUE:
            for my $Value ( @{ $Notification{Data}->{ArticleTypeID} } ) {

                next VALUE if !$Value;

                if ( $Value == $Article{ArticleTypeID} ) {
                    $Match = 1;
                    last VALUE;
                }
            }

            return if !$Match;
        }

        # check article sender type
        if ( $Notification{Data}->{ArticleSenderTypeID} ) {

            my $Match = 0;
            VALUE:
            for my $Value ( @{ $Notification{Data}->{ArticleSenderTypeID} } ) {

                next VALUE if !$Value;

                if ( $Value == $Article{SenderTypeID} ) {
                    $Match = 1;
                    last VALUE;
                }
            }

            return if !$Match;
        }

        # check subject & body
        KEY:
        for my $Key (qw(Subject Body)) {

            next KEY if !$Notification{Data}->{ 'Article' . $Key . 'Match' };

            my $Match = 0;
            VALUE:
            for my $Value ( @{ $Notification{Data}->{ 'Article' . $Key . 'Match' } } ) {

                next VALUE if !$Value;

                if ( $Article{$Key} =~ /\Q$Value\E/i ) {
                    $Match = 1;
                    last VALUE;
                }
            }

            return if !$Match;
        }
    }

    return 1;

}

sub _RecipientsGet {
    my ( $Self, %Param ) = @_;

    # check needed params
    for my $Needed (qw(Ticket Notification)) {
        return if !$Param{$Needed};
    }

    # set local values
    my %Notification = %{ $Param{Notification} };
    my %Ticket       = %{ $Param{Ticket} };

    # get needed objects
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
    my $GroupObject  = $Kernel::OM->Get('Kernel::System::Group');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    my @RecipientUserIDs;
    my @RecipientUsers;

    # add pre-calculated recipient
    if ( IsArrayRefWithData( $Param{Data}->{Recipients} ) ) {
        push @RecipientUserIDs, @{ $Param{Data}->{Recipients} };
    }

    # remember pre-calculated user recipients for later comparisons
    my %PrecalculatedUserIDs = map { $_ => 1 } @RecipientUserIDs;

    # get recipients by Recipients
    if ( $Notification{Data}->{Recipients} ) {

        # get needed objects
        my $QueueObject        = $Kernel::OM->Get('Kernel::System::Queue');
        my $CustomerUserObject = $Kernel::OM->Get('Kernel::System::CustomerUser');

        RECIPIENT:
        for my $Recipient ( @{ $Notification{Data}->{Recipients} } ) {

            if (
                $Recipient
                =~ /^Agent(Owner|Responsible|Watcher|WritePermissions|MyQueues|MyServices|MyQueuesMyServices)$/
                )
            {

                if ( $Recipient eq 'AgentOwner' ) {
                    push @{ $Notification{Data}->{RecipientAgents} }, $Ticket{OwnerID};
                }
                elsif ( $Recipient eq 'AgentResponsible' ) {

                    # add the responsible agent to the notification list
                    if ( $ConfigObject->Get('Ticket::Responsible') && $Ticket{ResponsibleID} ) {

                        push @{ $Notification{Data}->{RecipientAgents} },
                            $Ticket{ResponsibleID};
                    }
                }
                elsif ( $Recipient eq 'AgentWatcher' ) {

                    # is not needed to check Ticket::Watcher,
                    # its checked on TicketWatchGet function
                    push @{ $Notification{Data}->{RecipientAgents} }, $TicketObject->TicketWatchGet(
                        TicketID => $Param{Data}->{TicketID},
                        Result   => 'ARRAY',
                    );
                }
                elsif ( $Recipient eq 'AgentWritePermissions' ) {

                    my $GroupID = $QueueObject->GetQueueGroupID(
                        QueueID => $Ticket{QueueID},
                    );

                    my %UserList = $GroupObject->PermissionGroupUserGet(
                        GroupID => $GroupID,
                        Type    => 'rw',
                        UserID  => $Param{UserID},
                    );

                    my %RoleList = $GroupObject->PermissionGroupRoleGet(
                        GroupID => $GroupID,
                        Type    => 'rw',
                    );
                    for my $RoleID ( sort keys %RoleList ) {
                        my %RoleUserList = $GroupObject->PermissionRoleUserGet(
                            RoleID => $RoleID,
                        );
                        %UserList = ( %RoleUserList, %UserList );
                    }

                    my @UserIDs = sort keys %UserList;

                    push @{ $Notification{Data}->{RecipientAgents} }, @UserIDs;
                }
                elsif ( $Recipient eq 'AgentMyQueues' ) {

                    # get subscribed users
                    my %MyQueuesUserIDs = map { $_ => 1 } $TicketObject->GetSubscribedUserIDsByQueueID(
                        QueueID => $Ticket{QueueID}
                    );

                    my @UserIDs = sort keys %MyQueuesUserIDs;

                    push @{ $Notification{Data}->{RecipientAgents} }, @UserIDs;
                }
                elsif ( $Recipient eq 'AgentMyServices' ) {

                    # get subscribed users
                    my %MyServicesUserIDs;
                    if ( $Ticket{ServiceID} ) {
                        %MyServicesUserIDs = map { $_ => 1 } $TicketObject->GetSubscribedUserIDsByServiceID(
                            ServiceID => $Ticket{ServiceID},
                        );
                    }

                    my @UserIDs = sort keys %MyServicesUserIDs;

                    push @{ $Notification{Data}->{RecipientAgents} }, @UserIDs;
                }
                elsif ( $Recipient eq 'AgentMyQueuesMyServices' ) {

                    # get subscribed users
                    my %MyQueuesUserIDs = map { $_ => 1 } $TicketObject->GetSubscribedUserIDsByQueueID(
                        QueueID => $Ticket{QueueID}
                    );

                    # get subscribed users
                    my %MyServicesUserIDs;
                    if ( $Ticket{ServiceID} ) {
                        %MyServicesUserIDs = map { $_ => 1 } $TicketObject->GetSubscribedUserIDsByServiceID(
                            ServiceID => $Ticket{ServiceID},
                        );
                    }

                    # combine both subscribed users list (this will also remove duplicates)
                    my %SubscribedUserIDs = ( %MyQueuesUserIDs, %MyServicesUserIDs );

                    for my $UserID ( sort keys %SubscribedUserIDs ) {
                        if ( !$MyQueuesUserIDs{$UserID} || !$MyServicesUserIDs{$UserID} ) {
                            delete $SubscribedUserIDs{$UserID};
                        }
                    }

                    my @UserIDs = sort keys %SubscribedUserIDs;

                    push @{ $Notification{Data}->{RecipientAgents} }, @UserIDs;
                }
            }

            # Other OTRS packages might add other kind of recipients that are normally handled by
            #   other modules then an elsif condition here is useful.
            elsif ( $Recipient eq 'Customer' ) {

                # get old article for quoting
                my %Article = $TicketObject->ArticleLastCustomerArticle(
                    TicketID      => $Param{Data}->{TicketID},
                    DynamicFields => 0,
                );

                # If the ticket has no articles yet, get the raw ticket data
                if ( !%Article ) {
                    %Article = $TicketObject->TicketGet(
                        TicketID      => $Param{Data}->{TicketID},
                        DynamicFields => 0,
                    );
                }

                my %Recipient;

                # ArticleLastCustomerArticle() returns the latest customer article but if there
                # is no customer article, it returns the latest agent article. In this case
                # notification must not be send to the "From", but to the "To" article field.

                # Check if we actually do have an article
                if ( defined $Article{SenderType} ) {
                    if ( $Article{SenderType} eq 'customer' ) {
                        $Recipient{UserEmail} = $Article{From};
                    }
                    else {
                        $Recipient{UserEmail} = $Article{To};
                    }
                }
                $Recipient{Type} = 'Customer';

                # check if customer notifications should be send
                if (
                    $ConfigObject->Get('CustomerNotifyJustToRealCustomer')
                    && !$Article{CustomerUserID}
                    )
                {
                    $Kernel::OM->Get('Kernel::System::Log')->Log(
                        Priority => 'info',
                        Message  => 'Send no customer notification because no customer is set!',
                    );
                    next RECIPIENT;
                }

                # get language and send recipient
                $Recipient{Language} = $ConfigObject->Get('DefaultLanguage') || 'en';

                if ( $Article{CustomerUserID} ) {

                    my %CustomerUser = $CustomerUserObject->CustomerUserDataGet(
                        User => $Article{CustomerUserID},

                    );

                    # join Recipient data with CustomerUser data
                    %Recipient = ( %Recipient, %CustomerUser );

                    # get user language
                    if ( $CustomerUser{UserLanguage} ) {
                        $Recipient{Language} = $CustomerUser{UserLanguage};
                    }
                }

                # get real name
                if ( $Article{CustomerUserID} ) {
                    $Recipient{Realname} = $CustomerUserObject->CustomerName(
                        UserLogin => $Article{CustomerUserID},
                    );
                }
                if ( !$Recipient{Realname} ) {
                    $Recipient{Realname} = $Article{From} || '';
                    $Recipient{Realname} =~ s/<.*>|\(.*\)|\"|;|,//g;
                    $Recipient{Realname} =~ s/( $)|(  $)//g;
                }

                push @RecipientUsers, \%Recipient;
            }
        }
    }

    # add recipient agents
    if ( IsArrayRefWithData( $Notification{Data}->{RecipientAgents} ) ) {
        push @RecipientUserIDs, @{ $Notification{Data}->{RecipientAgents} };
    }

    # hash to keep track which agents are already receiving this notification
    my %AgentUsed = map { $_ => 1 } @RecipientUserIDs;

    # get recipients by RecipientGroups
    if ( $Notification{Data}->{RecipientGroups} ) {

        RECIPIENT:
        for my $GroupID ( @{ $Notification{Data}->{RecipientGroups} } ) {

            my %GroupMemberList = $GroupObject->PermissionGroupUserGet(
                GroupID => $GroupID,
                Type    => 'ro',
            );

            GROUPMEMBER:
            for my $UserID ( sort keys %GroupMemberList ) {

                next GROUPMEMBER if $UserID == 1;
                next GROUPMEMBER if $AgentUsed{$UserID};

                $AgentUsed{$UserID} = 1;

                push @RecipientUserIDs, $UserID;
            }
        }
    }

    # get recipients by RecipientRoles
    if ( $Notification{Data}->{RecipientRoles} ) {

        RECIPIENT:
        for my $RoleID ( @{ $Notification{Data}->{RecipientRoles} } ) {

            my %RoleMemberList = $GroupObject->PermissionRoleUserGet(
                RoleID => $RoleID,
            );

            ROLEMEMBER:
            for my $UserID ( sort keys %RoleMemberList ) {

                next ROLEMEMBER if $UserID == 1;
                next ROLEMEMBER if $AgentUsed{$UserID};

                $AgentUsed{$UserID} = 1;

                push @RecipientUserIDs, $UserID;
            }
        }
    }

    # get needed objects
    my $UserObject = $Kernel::OM->Get('Kernel::System::User');

    my %SkipRecipients;
    if ( IsArrayRefWithData( $Param{Data}->{SkipRecipients} ) ) {
        %SkipRecipients = map { $_ => 1 } @{ $Param{Data}->{SkipRecipients} };
    }

    # agent 1 should not receive notifications
    $SkipRecipients{'1'} = 1;

    # remove recipients should not receive a notification
    @RecipientUserIDs = grep { !$SkipRecipients{$_} } @RecipientUserIDs;

    # get valid users list
    my %ValidUsersList = $UserObject->UserList(
        Type          => 'Short',
        Valid         => 1,
        NoOutOfOffice => 0,
    );

    # remove invalid users
    @RecipientUserIDs = grep { $ValidUsersList{$_} } @RecipientUserIDs;

    # remove duplicated
    my %TempRecipientUserIDs = map { $_ => 1 } @RecipientUserIDs;
    @RecipientUserIDs = sort keys %TempRecipientUserIDs;

    # get time object
    my $TimeObject = $Kernel::OM->Get('Kernel::System::Time');

    # get current time-stamp
    my $Time = $TimeObject->SystemTime();

    # get all data for recipients as they should be needed by all notification transports
    RECIPIENT:
    for my $UserID (@RecipientUserIDs) {

        my %User = $UserObject->GetUserData(
            UserID => $UserID,
            Valid  => 1,
        );
        next RECIPIENT if !%User;

        # skip user that triggers the event (it should not be notified) but only if it is not
        #   a pre-calculated recipient
        if (
            !$ConfigObject->Get('AgentSelfNotifyOnAction')
            && $User{UserID} == $Param{UserID}
            && !$PrecalculatedUserIDs{ $Param{UserID} }
            )
        {
            next RECIPIENT;
        }

        # skip users out of the office if configured
        if ( !$Notification{Data}->{SendOnOutOfOffice} && $User{OutOfOffice} ) {
            my $Start = sprintf(
                "%04d-%02d-%02d 00:00:00",
                $User{OutOfOfficeStartYear}, $User{OutOfOfficeStartMonth},
                $User{OutOfOfficeStartDay}
            );
            my $TimeStart = $TimeObject->TimeStamp2SystemTime(
                String => $Start,
            );
            my $End = sprintf(
                "%04d-%02d-%02d 23:59:59",
                $User{OutOfOfficeEndYear}, $User{OutOfOfficeEndMonth},
                $User{OutOfOfficeEndDay}
            );
            my $TimeEnd = $TimeObject->TimeStamp2SystemTime(
                String => $End,
            );

            next RECIPIENT if $TimeStart < $Time && $TimeEnd > $Time;
        }

        # skip users with out ro permissions
        my $Permission = $TicketObject->TicketPermission(
            Type     => 'ro',
            TicketID => $Ticket{TicketID},
            UserID   => $User{UserID}
        );

        next RECIPIENT if !$Permission;

        # skip PostMasterUserID
        my $PostmasterUserID = $ConfigObject->Get('PostmasterUserID') || 1;
        next RECIPIENT if $User{UserID} == $PostmasterUserID;

        $User{Type} = 'Agent';

        push @RecipientUsers, \%User;
    }

    return @RecipientUsers;
}

sub _SendRecipientNotification {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(TicketID UserID Notification Recipient Event Transport TransportObject)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
        }
    }

    # get ticket object
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    # check if the notification needs to be sent just one time per day
    if ( $Param{Notification}->{Data}->{OncePerDay} && $Param{Recipient}->{UserLogin} ) {

        # get ticket history
        my @HistoryLines = $TicketObject->HistoryGet(
            TicketID => $Param{TicketID},
            UserID   => $Param{UserID},
        );

        # get last notification sent ticket history entry for this transport and this user
        my $LastNotificationHistory = first {
            $_->{HistoryType} eq 'SendAgentNotification'
                && $_->{Name} eq
                "\%\%$Param{Notification}->{Name}\%\%$Param{Recipient}->{UserLogin}\%\%$Param{Transport}"
        }
        reverse @HistoryLines;

        if ( $LastNotificationHistory && $LastNotificationHistory->{CreateTime} ) {

            # get time object
            my $TimeObject = $Kernel::OM->Get('Kernel::System::Time');

            # get last notification date
            my ( $Sec, $Min, $Hour, $Day, $Month, $Year, $WeekDay ) = $TimeObject->SystemTime2Date(
                SystemTime => $TimeObject->TimeStamp2SystemTime(
                    String => $LastNotificationHistory->{CreateTime},
                    )
            );

            # get current date
            my ( $CurrSec, $CurrMin, $CurrHour, $CurrDay, $CurrMonth, $CurrYear, $CurrWeekDay )
                = $TimeObject->SystemTime2Date(
                SystemTime => $TimeObject->SystemTime(),
                );

            # do not send the notification if it has been sent already today
            if (
                $CurrYear == $Year
                && $CurrMonth == $Month
                && $CurrDay == $Day
                )
            {
                return;
            }
        }
    }

    my $TransportObject = $Param{TransportObject};

    # send notification to each recipient
    my $Success = $TransportObject->SendNotification(
        TicketID              => $Param{TicketID},
        UserID                => $Param{UserID},
        Notification          => $Param{Notification},
        CustomerMessageParams => $Param{CustomerMessageParams},
        Recipient             => $Param{Recipient},
        Event                 => $Param{Event},
        Attachments           => $Param{Attachments},
    );

    return if !$Success;

    if (
        $Param{Recipient}->{Type} eq 'Agent'
        && $Param{Recipient}->{UserLogin}
        )
    {

        # write history
        $TicketObject->HistoryAdd(
            TicketID     => $Param{TicketID},
            HistoryType  => 'SendAgentNotification',
            Name         => "\%\%$Param{Notification}->{Name}\%\%$Param{Recipient}->{UserLogin}\%\%$Param{Transport}",
            CreateUserID => $Param{UserID},
        );
    }

    my %EventData = %{ $TransportObject->GetTransportEventData() };

    return 1 if !%EventData;

    if ( !$EventData{Event} || !$EventData{Data} || !$EventData{UserID} ) {

        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Could not trigger notification post send event",
        );

        return;
    }

    # ticket event
    $TicketObject->EventHandler(
        %EventData,
    );

    return 1;
}

sub _ArticleToUpdate {
    my ( $Self, %Param ) = @_;

    # check needed params
    for my $Needed (qw(ArticleID ArticleType UserIDs UserID)) {
        return if !$Param{$Needed};
    }

    # not update for User 1
    return 1 if $Param{UserID} eq 1;

    # get needed objects
    my $DBObject   = $Kernel::OM->Get('Kernel::System::DB');
    my $UserObject = $Kernel::OM->Get('Kernel::System::User');

    # not update if its not a note article
    return 1 if $Param{ArticleType} !~ /^note\-/;

    my $NewTo = $Param{To} || '';
    for my $UserID ( sort keys %{ $Param{UserIDs} } ) {
        my %UserData = $UserObject->GetUserData(
            UserID => $UserID,
            Valid  => 1,
        );
        if ($NewTo) {
            $NewTo .= ', ';
        }
        $NewTo .= "$UserData{UserFirstname} $UserData{UserLastname} <$UserData{UserEmail}>";
    }

    # not update if To is the same
    return 1 if !$NewTo;

    return if !$DBObject->Do(
        SQL  => 'UPDATE article SET a_to = ? WHERE id = ?',
        Bind => [ \$NewTo, \$Param{ArticleID} ],
    );

    return 1;
}

1;
