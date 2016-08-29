# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::CalendarTemplateGenerator;
## nofilter(TidyAll::Plugin::OTRS::Perl::Time)

use strict;
use warnings;

use Kernel::Language;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Calendar',
    'Kernel::System::Calendar::Appointment',
    'Kernel::System::Calendar::Helper',
    'Kernel::System::HTMLUtils',
    'Kernel::System::Log',
    'Kernel::System::Time',
    'Kernel::System::User',
    'Kernel::System::Main',
);

=head1 NAME

Kernel::System::TemplateGenerator - signature lib

=head1 SYNOPSIS

All signature functions.

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object. Do not use it directly, instead use:

    use Kernel::System::ObjectManager;
    local $Kernel::OM = Kernel::System::ObjectManager->new();
    my $TemplateGeneratorObject = $Kernel::OM->Get('Kernel::System::TemplateGenerator');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    $Self->{RichText} = $Kernel::OM->Get('Kernel::Config')->Get('Frontend::RichText');

    return $Self;
}

=item NotificationEvent()

replace all OTRS smart tags in the notification body and subject

    my %NotificationEvent = $CalendarTemplateGeneratorObject->NotificationEvent(
        AppointmentID => 123,
        Recipient     => $UserDataHashRef,          # Agent data get result
        Notification  => $NotificationDataHashRef,
        UserID        => 123,
    );

=cut

sub NotificationEvent {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(AppointmentID Notification Recipient UserID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    if ( !IsHashRefWithData( $Param{Notification} ) ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Notification is invalid!",
        );
        return;
    }

    my %Notification = %{ $Param{Notification} };

    # get system default language
    my $DefaultLanguage = $Kernel::OM->Get('Kernel::Config')->Get('DefaultLanguage') || 'en';

    my $Languages = [ $Param{Recipient}->{UserLanguage}, $DefaultLanguage, 'en' ];

    my $Language;
    LANGUAGE:
    for my $Item ( @{$Languages} ) {
        next LANGUAGE if !$Item;
        next LANGUAGE if !$Notification{Message}->{$Item};

        # set language
        $Language = $Item;
        last LANGUAGE;
    }

    # if no language, then take the first one available
    if ( !$Language ) {
        my @NotificationLanguages = sort keys %{ $Notification{Message} };
        $Language = $NotificationLanguages[0];
    }

    # copy the correct language message attributes to a flat structure
    for my $Attribute (qw(Subject Body ContentType)) {
        $Notification{$Attribute} = $Notification{Message}->{$Language}->{$Attribute};
    }

    my $Start = '<';
    my $End   = '>';
    if ( $Notification{ContentType} =~ m{text\/html} ) {
        $Start = '&lt;';
        $End   = '&gt;';
    }

    # get html utils object
    my $HTMLUtilsObject = $Kernel::OM->Get('Kernel::System::HTMLUtils');

    # do text/plain to text/html convert
    if ( $Self->{RichText} && $Notification{ContentType} =~ /text\/plain/i ) {
        $Notification{ContentType} = 'text/html';
        $Notification{Body}        = $HTMLUtilsObject->ToHTML(
            String => $Notification{Body},
        );
    }

    # do text/html to text/plain convert
    if ( !$Self->{RichText} && $Notification{ContentType} =~ /text\/html/i ) {
        $Notification{ContentType} = 'text/plain';
        $Notification{Body}        = $HTMLUtilsObject->ToAscii(
            String => $Notification{Body},
        );
    }

    # get notify texts
    for my $Text (qw(Subject Body)) {
        if ( !$Notification{$Text} ) {
            $Notification{$Text} = "No Notification $Text for $Param{Type} found!";
        }
    }

    # replace place holder stuff
    $Notification{Body} = $Self->_Replace(
        RichText      => $Self->{RichText},
        Text          => $Notification{Body},
        Recipient     => $Param{Recipient},
        AppointmentID => $Param{AppointmentID},
        UserID        => $Param{UserID},
        Language      => $Language,
    );

    $Notification{Subject} = $Self->_Replace(
        RichText      => 0,
        Text          => $Notification{Subject},
        Recipient     => $Param{Recipient},
        AppointmentID => $Param{AppointmentID},
        UserID        => $Param{UserID},
        Language      => $Language,
    );

    # add URLs and verify to be full HTML document
    if ( $Self->{RichText} ) {

        $Notification{Body} = $HTMLUtilsObject->LinkQuote(
            String => $Notification{Body},
        );
    }

    return %Notification;
}

=begin Internal:

=cut

sub _Replace {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(Text AppointmentID RichText UserID)) {
        if ( !defined $Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    # check for mailto links
    # since the subject and body of those mailto links are
    # uri escaped we have to uri unescape them, replace
    # possible placeholders and then re-uri escape them
    $Param{Text} =~ s{
        (href="mailto:[^\?]+\?)([^"]+")
    }
    {
        my $MailToHref        = $1;
        my $MailToHrefContent = $2;

        $MailToHrefContent =~ s{
            ((?:subject|body)=)(.+?)("|&)
        }
        {
            my $SubjectOrBodyPrefix  = $1;
            my $SubjectOrBodyContent = $2;
            my $SubjectOrBodySuffix  = $3;

            my $SubjectOrBodyContentUnescaped = URI::Escape::uri_unescape $SubjectOrBodyContent;

            my $SubjectOrBodyContentReplaced = $Self->_Replace(
                %Param,
                Text     => $SubjectOrBodyContentUnescaped,
                RichText => 0,
            );

            my $SubjectOrBodyContentEscaped = URI::Escape::uri_escape_utf8 $SubjectOrBodyContentReplaced;

            $SubjectOrBodyPrefix . $SubjectOrBodyContentEscaped . $SubjectOrBodySuffix;
        }egx;

        $MailToHref . $MailToHrefContent;
    }egx;

    my $Start = '<';
    my $End   = '>';
    if ( $Param{RichText} ) {
        $Start = '&lt;';
        $End   = '&gt;';
        $Param{Text} =~ s/(\n|\r)//g;
    }

    # get needed objects
    my $AppointmentObject = $Kernel::OM->Get('Kernel::System::Calendar::Appointment');
    my $CalendarObject    = $Kernel::OM->Get('Kernel::System::Calendar');

    # get appointment data
    my %Appointment = $AppointmentObject->AppointmentGet(
        AppointmentID => $Param{AppointmentID},
    );

    # get calendar data
    my %Calendar = $CalendarObject->CalendarGet(
        CalendarID => $Appointment{CalendarID},
        UserID     => $Param{UserID},
    );

    # get config object
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # special replace from secret config options
    my @SecretConfigOptions = qw(
        DatabasePw
        SearchUserPw
        UserPw
        SendmailModule::AuthPassword
        AuthModule::Radius::Password
        PGP::Key::Password
        Customer::AuthModule::DB::CustomerPassword
        Customer::AuthModule::Radius::Password
        PublicFrontend::AuthPassword
    );

    # replace the secret config options before the normal config options
    for my $SecretConfigOption (@SecretConfigOptions) {

        my $Tag = $Start . 'OTRS_CONFIG_' . $SecretConfigOption . $End;
        $Param{Text} =~ s{$Tag}{xxx}gx;
    }

    # replace config options
    my $Tag = $Start . 'OTRS_CONFIG_';
    $Param{Text} =~ s{$Tag(.+?)$End}{$ConfigObject->Get($1) // ''}egx;

    # cleanup
    $Param{Text} =~ s/$Tag.+?$End/-/gi;

    my %Recipient = %{ $Param{Recipient} || {} };

    # get user object
    my $UserObject = $Kernel::OM->Get('Kernel::System::User');

    if ( !%Recipient && $Param{RecipientID} ) {

        %Recipient = $UserObject->GetUserData(
            UserID        => $Param{RecipientID},
            NoOutOfOffice => 1,
        );
    }

    # get a local helper object
    my $CalendarHelperObject = $Kernel::OM->Get('Kernel::System::Calendar::Helper');

    # get timezone offset for current recipient
    my $TimezoneOffsetRaw = $CalendarHelperObject->TimezoneOffsetGet(
        UserID => $Recipient{UserID},
    ) || 0;

    my $TimezoneOffset = $TimezoneOffsetRaw * 60 * 60;

    # instanciate a new language object with the given language
    my $LanguageObject = Kernel::Language->new(
        UserLanguage => $Param{Language} || 'en',
    );

    # supported appointment fields
    my %AppointmentTagsSkip = (
        RecurrenceType                        => 1,
        RecurrenceFrequency                   => 1,
        RecurrenceCount                       => 1,
        RecurrenceInterval                    => 1,
        RecurrenceUntil                       => 1,
        RecurrenceID                          => 1,
        RecurrenceExclude                     => 1,
        NotificationCustom                    => 1,
        NotificationTemplate                  => 1,
        NotificationCustomUnitCount           => 1,
        NotificationCustomUnit                => 1,
        NotificationCustomUnitPointOfTime     => 1,
        NotificationCustomRelativePointOfTime => 1,
        NotificationCustomRelativeUnit        => 1,
        NotificationCustomRelativeUnitCount   => 1,
        NotificationCustomDateTime            => 1,
    );

    # replace config options
    $Tag = $Start . 'OTRS_APPOINTMENT_';

    # get a local time object
    my $TimeObject = $Kernel::OM->Get('Kernel::System::Time');

    # replace appointment tags
    ATTRIBUTE:
    for my $Attribute ( sort keys %Appointment ) {

        next ATTRIBUTE if !$Attribute;
        next ATTRIBUTE if $AppointmentTagsSkip{$Attribute};

        # setup a new tag for the current attribute
        my $MatchTag = $Tag . uc $Attribute;

        # map NotificationTime attribute
        if ( $Attribute eq 'NotificationDate' ) {
            $MatchTag = $Tag . 'NOTIFICATIONTIME';
        }

        my $Replacement = '';

        # process datetime strings (timestamps)
        if (
            $Attribute eq 'StartTime'
            || $Attribute eq 'EndTime'
            || $Attribute eq 'NotificationDate'
            || $Attribute eq 'CreateTime'
            || $Attribute eq 'ChangeTime'
            )
        {
            # get the system time of the given timestamp
            my $TagSystemTime = $TimeObject->TimeStamp2SystemTime(
                String => $Appointment{$Attribute},
            );

            # generate new timestamp with the related timezone offset
            my $NewTimeStamp = $TimeObject->SystemTime2TimeStamp(
                SystemTime => $TagSystemTime + $TimezoneOffset,
            );

            # prepare dates and times
            $Replacement = $LanguageObject->FormatTimeString( $NewTimeStamp, 'DateFormatLong' ) || '';
        }

        # process team ids
        elsif ( $Attribute eq 'TeamID' ) {

            next ATTRIBUTE if !IsArrayRefWithData( $Appointment{$Attribute} );

            if (
                !$Kernel::OM->Get('Kernel::System::Main')->Require( 'Kernel::System::Calendar::Team', Silent => 1 )
                )
            {
                next ATTRIBUTE;
            }

            # instanciate a new team object
            my $TeamObject = Kernel::System::Calendar::Team->new();

            # get a list of available (readable) teams
            my %TeamList = $TeamObject->TeamList(
                Valid  => 0,
                UserID => $Self->{UserID},
            );

            next ATTRIBUTE if !IsHashRefWithData( \%TeamList );

            my @TeamNames;

            if ( IsHashRefWithData( \%TeamList ) ) {

                TEAMKEY:
                for my $TeamKey ( @{ $Appointment{$Attribute} } ) {

                    next TEAMKEY if !$TeamList{$TeamKey};

                    push @TeamNames, $TeamList{$TeamKey};
                }
            }

            next ATTRIBUTE if !IsArrayRefWithData( \@TeamNames );

            # replace team ids with a comma seperated list of team names
            $Replacement = join ",", @TeamNames;
        }

        # process team ids
        elsif ( $Attribute eq 'ResourceID' ) {

            next ATTRIBUTE if !IsArrayRefWithData( $Appointment{$Attribute} );

            my @UserNames;

            USERID:
            for my $UserID ( @{ $Appointment{$Attribute} } ) {

                my $UserName = $UserObject->UserName(
                    UserID => $UserID,
                );

                next USERID if !$UserName;

                push @UserNames, $UserName;
            }

            next ATTRIBUTE if !IsArrayRefWithData( \@UserNames );

            # replace team ids with a comma seperated list of team names
            $Replacement = join ",", @UserNames;
        }

        # process all day and recurring tags
        elsif (
            $Attribute eq 'AllDay'
            || $Attribute eq 'Recurring'
            )
        {
            my $TranslatedString = $LanguageObject->Translate('No');

            if ( $Appointment{$Attribute} ) {
                $TranslatedString = $LanguageObject->Translate('Yes');
            }

            $Replacement = $TranslatedString;
        }

        # process all other single values
        else {
            $Replacement = $Appointment{$Attribute};
        }

        # replace the tags
        $Param{Text} =~ s{$MatchTag$End}{$Replacement}egx;
    }

    # cleanup
    $Param{Text} =~ s/$Tag.+?$End/-/gi;

    # supported calendar fields
    my %CalendarTags = (
        'NAME' => 'CalendarName',
    );

    # replace config options
    $Tag = $Start . 'OTRS_CALENDAR_';

    # replace appointment tags
    for my $CalendarTag ( sort keys %CalendarTags ) {
        $Param{Text} =~ s{$Tag(.+?)$End}{$Calendar{$CalendarTags{$1}} // ''}egx;
    }

    # cleanup
    $Param{Text} =~ s/$Tag.+?$End/-/gi;

    my $HashGlobalReplace = sub {
        my ( $Tag, %H ) = @_;

        # Generate one single matching string for all keys to save performance.
        my $Keys = join '|', map {quotemeta} grep { defined $H{$_} } keys %H;

        # Add all keys also as lowercase to be able to match case insensitive,
        #   e. g. <OTRS_CUSTOMER_From> and <OTRS_CUSTOMER_FROM>.
        for my $Key ( sort keys %H ) {
            $H{ lc $Key } = $H{$Key};
        }

        $Param{Text} =~ s/(?:$Tag)($Keys)$End/$H{ lc $1 }/ieg;
    };

    # get recipient data and replace it with <OTRS_...
    $Tag = $Start . 'OTRS_';

    # include more readable tag <OTRS_NOTIFICATION_RECIPIENT
    my $RecipientTag = $Start . 'OTRS_NOTIFICATION_RECIPIENT_';

    if (%Recipient) {

        # HTML quoting of content
        if ( $Param{RichText} ) {
            ATTRIBUTE:
            for my $Attribute ( sort keys %Recipient ) {
                next ATTRIBUTE if !$Recipient{$Attribute};
                $Recipient{$Attribute} = $Kernel::OM->Get('Kernel::System::HTMLUtils')->ToHTML(
                    String => $Recipient{$Attribute},
                );
            }
        }

        $HashGlobalReplace->( "$Tag|$RecipientTag", %Recipient );
    }

    # cleanup
    $Param{Text} =~ s/$RecipientTag.+?$End/-/gi;

    return $Param{Text};
}

1;

=end Internal:

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
