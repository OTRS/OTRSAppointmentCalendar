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

    'Kernel::Output::HTML::Layout',
    'Kernel::System::CustomerUser',
    'Kernel::System::DynamicField',
    'Kernel::System::DynamicField::Backend',
    'Kernel::System::HTMLUtils',
    'Kernel::System::JSON',
    'Kernel::System::Log',
    'Kernel::System::Queue',
    'Kernel::System::Ticket',
    'Kernel::System::User',
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

    #    # replace place holder stuff
    #    $Notification{Body} = $Self->_Replace(
    #        RichText  => $Self->{RichText},
    #        Text      => $Notification{Body},
    #        Recipient => $Param{Recipient},
    #        Data      => $Param{CustomerMessageParams},
    #        DataAgent => \%ArticleAgent,
    #        TicketID  => $Param{TicketID},
    #        UserID    => $Param{UserID},
    #        Language  => $Language,
    #    );
    #    $Notification{Subject} = $Self->_Replace(
    #        RichText  => 0,
    #        Text      => $Notification{Subject},
    #        Recipient => $Param{Recipient},
    #        Data      => $Param{CustomerMessageParams},
    #        DataAgent => \%ArticleAgent,
    #        TicketID  => $Param{TicketID},
    #        UserID    => $Param{UserID},
    #        Language  => $Language,
    #    );

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
    for (qw(Text RichText Data UserID)) {
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

    my %Ticket;
    if ( $Param{TicketID} ) {
        %Ticket = $Kernel::OM->Get('Kernel::System::Ticket')->TicketGet(
            TicketID      => $Param{TicketID},
            DynamicFields => 1,
        );
    }

    # translate ticket values if needed
    if ( $Param{Language} ) {
        my $LanguageObject = Kernel::Language->new(
            UserLanguage => $Param{Language},
        );
        for my $Field (qw(Type State StateType Lock Priority)) {
            $Ticket{$Field} = $LanguageObject->Translate( $Ticket{$Field} );
        }
    }

    my %Queue;
    if ( $Param{QueueID} ) {
        %Queue = $Kernel::OM->Get('Kernel::System::Queue')->QueueGet(
            ID => $Param{QueueID},
        );
    }

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

    # get owner data and replace it with <OTRS_OWNER_...
    $Tag = $Start . 'OTRS_OWNER_';

    # include more readable version <OTRS_TICKET_OWNER
    my $OwnerTag = $Start . 'OTRS_TICKET_OWNER_';

    if ( $Ticket{OwnerID} ) {

        my %Owner = $UserObject->GetUserData(
            UserID        => $Ticket{OwnerID},
            NoOutOfOffice => 1,
        );

        # html quoting of content
        if ( $Param{RichText} ) {

            ATTRIBUTE:
            for my $Attribute ( sort keys %Owner ) {
                next ATTRIBUTE if !$Owner{$Attribute};
                $Owner{$Attribute} = $Kernel::OM->Get('Kernel::System::HTMLUtils')->ToHTML(
                    String => $Owner{$Attribute},
                );
            }
        }

        $HashGlobalReplace->( "$Tag|$OwnerTag", %Owner );
    }

    # cleanup
    $Param{Text} =~ s/$Tag.+?$End/-/gi;
    $Param{Text} =~ s/$OwnerTag.+?$End/-/gi;

    # get owner data and replace it with <OTRS_RESPONSIBLE_...
    $Tag = $Start . 'OTRS_RESPONSIBLE_';

    # include more readable version <OTRS_TICKET_RESPONSIBLE
    my $ResponsibleTag = $Start . 'OTRS_TICKET_RESPONSIBLE_';

    if ( $Ticket{ResponsibleID} ) {
        my %Responsible = $UserObject->GetUserData(
            UserID        => $Ticket{ResponsibleID},
            NoOutOfOffice => 1,
        );

        # HTML quoting of content
        if ( $Param{RichText} ) {

            ATTRIBUTE:
            for my $Attribute ( sort keys %Responsible ) {
                next ATTRIBUTE if !$Responsible{$Attribute};
                $Responsible{$Attribute} = $Kernel::OM->Get('Kernel::System::HTMLUtils')->ToHTML(
                    String => $Responsible{$Attribute},
                );
            }
        }

        $HashGlobalReplace->( "$Tag|$ResponsibleTag", %Responsible );
    }

    # cleanup
    $Param{Text} =~ s/$Tag.+?$End/-/gi;
    $Param{Text} =~ s/$ResponsibleTag.+?$End/-/gi;

    $Tag = $Start . 'OTRS_Agent_';
    my $Tag2        = $Start . 'OTRS_CURRENT_';
    my %CurrentUser = $UserObject->GetUserData(
        UserID        => $Param{UserID},
        NoOutOfOffice => 1,
    );

    # HTML quoting of content
    if ( $Param{RichText} ) {

        ATTRIBUTE:
        for my $Attribute ( sort keys %CurrentUser ) {
            next ATTRIBUTE if !$CurrentUser{$Attribute};
            $CurrentUser{$Attribute} = $Kernel::OM->Get('Kernel::System::HTMLUtils')->ToHTML(
                String => $CurrentUser{$Attribute},
            );
        }
    }

    $HashGlobalReplace->( "$Tag|$Tag2", %CurrentUser );

    # replace other needed stuff
    $Param{Text} =~ s/$Start OTRS_FIRST_NAME $End/$CurrentUser{UserFirstname}/gxms;
    $Param{Text} =~ s/$Start OTRS_LAST_NAME $End/$CurrentUser{UserLastname}/gxms;

    # cleanup
    $Param{Text} =~ s/$Tag2.+?$End/-/gi;

    # ticket data
    $Tag = $Start . 'OTRS_TICKET_';

    # html quoting of content
    if ( $Param{RichText} ) {

        ATTRIBUTE:
        for my $Attribute ( sort keys %Ticket ) {
            next ATTRIBUTE if !$Ticket{$Attribute};
            $Ticket{$Attribute} = $Kernel::OM->Get('Kernel::System::HTMLUtils')->ToHTML(
                String => $Ticket{$Attribute},
            );
        }
    }

    # Dropdown, Checkbox and MultipleSelect DynamicFields, can store values (keys) that are
    # different from the the values to display
    # <OTRS_TICKET_DynamicField_NameX> returns the stored key
    # <OTRS_TICKET_DynamicField_NameX_Value> returns the display value

    my %DynamicFields;

    # For systems with many Dynamic fields we do not want to load them all unless needed
    # Find what Dynamic Field Values are requested
    while ( $Param{Text} =~ m/$Tag DynamicField_(\S+?)(_Value)? $End/gixms ) {
        $DynamicFields{$1} = 1;
    }

    # to store all the required DynamicField display values
    my %DynamicFieldDisplayValues;

    # get dynamic field objects
    my $DynamicFieldObject        = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    # get the dynamic fields for ticket object
    my $DynamicFieldList = $DynamicFieldObject->DynamicFieldListGet(
        Valid      => 1,
        ObjectType => ['Ticket'],
    ) || [];

    # cycle through the activated Dynamic Fields for this screen
    DYNAMICFIELD:
    for my $DynamicFieldConfig ( @{$DynamicFieldList} ) {

        next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

        # we only load the ones requested
        next DYNAMICFIELD if !$DynamicFields{ $DynamicFieldConfig->{Name} };

        my $LanguageObject;

        # translate values if needed
        if ( $Param{Language} ) {
            $LanguageObject = Kernel::Language->new(
                UserLanguage => $Param{Language},
            );
        }

        # get the display value for each dynamic field
        my $DisplayValue = $DynamicFieldBackendObject->ValueLookup(
            DynamicFieldConfig => $DynamicFieldConfig,
            Key                => $Ticket{ 'DynamicField_' . $DynamicFieldConfig->{Name} },
            LanguageObject     => $LanguageObject,
        );

        # get the readable value (value) for each dynamic field
        my $DisplayValueStrg = $DynamicFieldBackendObject->ReadableValueRender(
            DynamicFieldConfig => $DynamicFieldConfig,
            Value              => $DisplayValue,
        );

        # fill the DynamicFielsDisplayValues
        if ($DisplayValueStrg) {
            $DynamicFieldDisplayValues{ 'DynamicField_' . $DynamicFieldConfig->{Name} . '_Value' }
                = $DisplayValueStrg->{Value};
        }

        # get the readable value (key) for each dynamic field
        my $ValueStrg = $DynamicFieldBackendObject->ReadableValueRender(
            DynamicFieldConfig => $DynamicFieldConfig,
            Value              => $Ticket{ 'DynamicField_' . $DynamicFieldConfig->{Name} },
        );

        # replace ticket content with the value from ReadableValueRender (if any)
        if ( IsHashRefWithData($ValueStrg) ) {
            $Ticket{ 'DynamicField_' . $DynamicFieldConfig->{Name} } = $ValueStrg->{Value};
        }
    }

    # replace it
    $HashGlobalReplace->( $Tag, %Ticket, %DynamicFieldDisplayValues );

    # COMPAT
    $Param{Text} =~ s/$Start OTRS_TICKET_ID $End/$Ticket{TicketID}/gixms;
    $Param{Text} =~ s/$Start OTRS_TICKET_NUMBER $End/$Ticket{TicketNumber}/gixms;
    if ( $Param{TicketID} ) {
        $Param{Text} =~ s/$Start OTRS_QUEUE $End/$Ticket{Queue}/gixms;
    }
    if ( $Param{QueueID} ) {
        $Param{Text} =~ s/$Start OTRS_TICKET_QUEUE $End/$Queue{Name}/gixms;
    }

    # cleanup
    $Param{Text} =~ s/$Tag.+?$End/-/gi;

    # get customer and agent params and replace it with <OTRS_CUSTOMER_... or <OTRS_AGENT_...
    my %ArticleData = (
        'OTRS_CUSTOMER_' => $Param{Data}      || {},
        'OTRS_AGENT_'    => $Param{DataAgent} || {},
    );

    # use a list to get customer first
    for my $DataType (qw(OTRS_CUSTOMER_ OTRS_AGENT_)) {
        my %Data = %{ $ArticleData{$DataType} };

        # HTML quoting of content
        if (
            $Param{RichText}
            && ( !$Data{ContentType} || $Data{ContentType} !~ /application\/json/ )
            )
        {

            ATTRIBUTE:
            for my $Attribute ( sort keys %Data ) {
                next ATTRIBUTE if !$Data{$Attribute};

                $Data{$Attribute} = $Kernel::OM->Get('Kernel::System::HTMLUtils')->ToHTML(
                    String => $Data{$Attribute},
                );
            }
        }

        if (%Data) {

            # Check if content type is JSON
            if ( $Data{'ContentType'} && $Data{'ContentType'} =~ /application\/json/ ) {

                # if article is chat related
                if ( $Data{'ArticleType'} =~ /chat/ ) {

                    # remove spaces
                    $Data{Body} =~ s/\n/ /gms;

                    my $Body = $Kernel::OM->Get('Kernel::System::JSON')->Decode(
                        Data => $Data{Body},
                    );

                    # replace body with HTML text
                    $Data{Body} = $Kernel::OM->Get('Kernel::Output::HTML::Layout')->Output(
                        TemplateFile => "ChatDisplay",
                        Data         => {
                            ChatMessages => $Body,
                        },
                    );
                }
            }

            # check if original content isn't text/plain, don't use it
            if ( $Data{'Content-Type'} && $Data{'Content-Type'} !~ /(text\/plain|\btext\b)/i ) {
                $Data{Body} = '-> no quotable message <-';
            }

            # replace <OTRS_CUSTOMER_*> and <OTRS_AGENT_*> tags
            $Tag = $Start . $DataType;
            $HashGlobalReplace->( $Tag, %Data );

            # prepare body (insert old email) <OTRS_CUSTOMER_EMAIL[n]>, <OTRS_CUSTOMER_NOTE[n]>
            #   <OTRS_CUSTOMER_BODY[n]>, <OTRS_AGENT_EMAIL[n]>..., <OTRS_COMMENT>
            if ( $Param{Text} =~ /$Start(?:(?:$DataType(EMAIL|NOTE|BODY)\[(.+?)\])|(?:OTRS_COMMENT))$End/g ) {

                my $Line       = $2 || 2500;
                my $NewOldBody = '';
                my @Body       = split( /\n/, $Data{Body} );

                for my $Counter ( 0 .. $Line - 1 ) {

                    # 2002-06-14 patch of Pablo Ruiz Garcia
                    # http://lists.otrs.org/pipermail/dev/2002-June/000012.html
                    if ( $#Body >= $Counter ) {

                        # add no quote char, do it later by using DocumentCleanup()
                        if ( $Param{RichText} ) {
                            $NewOldBody .= $Body[$Counter];
                        }

                        # add "> " as quote char
                        else {
                            $NewOldBody .= "> $Body[$Counter]";
                        }

                        # add new line
                        if ( $Counter < ( $Line - 1 ) ) {
                            $NewOldBody .= "\n";
                        }
                    }
                    $Counter++;
                }

                chomp $NewOldBody;

                # HTML quoting of content
                if ( $Param{RichText} && $NewOldBody ) {

                    # remove trailing new lines
                    for ( 1 .. 10 ) {
                        $NewOldBody =~ s/(<br\/>)\s{0,20}$//gs;
                    }

                    # add quote
                    $NewOldBody = "<blockquote type=\"cite\">$NewOldBody</blockquote>";
                    $NewOldBody = $Kernel::OM->Get('Kernel::System::HTMLUtils')->DocumentCleanup(
                        String => $NewOldBody,
                    );
                }

                # replace tag
                $Param{Text}
                    =~ s/$Start(?:(?:$DataType(EMAIL|NOTE|BODY)\[(.+?)\])|(?:OTRS_COMMENT))$End/$NewOldBody/g;
            }

            # replace <OTRS_CUSTOMER_SUBJECT[]>  and  <OTRS_AGENT_SUBJECT[]> tags
            $Tag = "$Start$DataType" . 'SUBJECT';
            if ( $Param{Text} =~ /$Tag\[(.+?)\]$End/g ) {

                my $SubjectChar = $1;
                my $Subject     = $Kernel::OM->Get('Kernel::System::Ticket')->TicketSubjectClean(
                    TicketNumber => $Ticket{TicketNumber},
                    Subject      => $Data{Subject},
                );

                $Subject =~ s/^(.{$SubjectChar}).*$/$1 [...]/;
                $Param{Text} =~ s/$Tag\[.+?\]$End/$Subject/g;
            }

            if ( $DataType eq 'OTRS_CUSTOMER_' ) {

                # Arnold Ligtvoet - otrs@ligtvoet.org
                # get <OTRS_EMAIL_DATE[]> from body and replace with received date
                use POSIX qw(strftime);
                $Tag = $Start . 'OTRS_EMAIL_DATE';

                if ( $Param{Text} =~ /$Tag\[(.+?)\]$End/g ) {

                    my $TimeZone = $1;
                    my $EmailDate = strftime( '%A, %B %e, %Y at %T ', localtime );    ## no critic
                    $EmailDate .= "($TimeZone)";
                    $Param{Text} =~ s/$Tag\[.+?\]$End/$EmailDate/g;
                }
            }
        }

        if ( $DataType eq 'OTRS_CUSTOMER_' ) {

            # get and prepare realname
            $Tag = $Start . 'OTRS_CUSTOMER_REALNAME';
            if ( $Param{Text} =~ /$Tag$End/i ) {

                my $From;

                if ( $Ticket{CustomerUserID} ) {

                    $From = $Kernel::OM->Get('Kernel::System::CustomerUser')->CustomerName(
                        UserLogin => $Ticket{CustomerUserID}
                    );
                }

                # try to get the real name directly from the data
                $From //= $Recipient{RealName};

                # get real name based on reply-to
                if ( $Data{ReplyTo} ) {
                    $From = $Data{ReplyTo} || '';
                }

                # generate real name based on sender line
                if ( !$From ) {
                    $From = $Data{From} || '';

                    # remove email addresses
                    $From =~ s/&lt;.*&gt;|<.*>|\(.*\)|\"|&quot;|;|,//g;

                    # remove leading/trailing spaces
                    $From =~ s/^\s+//g;
                    $From =~ s/\s+$//g;
                }

                # replace <OTRS_CUSTOMER_REALNAME> with from
                $Param{Text} =~ s/$Tag$End/$From/g;
            }
        }
    }

    # get customer data and replace it with <OTRS_CUSTOMER_DATA_...
    $Tag  = $Start . 'OTRS_CUSTOMER_';
    $Tag2 = $Start . 'OTRS_CUSTOMER_DATA_';

    if ( $Ticket{CustomerUserID} || $Param{Data}->{CustomerUserID} ) {

        my $CustomerUserID = $Param{Data}->{CustomerUserID} || $Ticket{CustomerUserID};

        my %CustomerUser = $Kernel::OM->Get('Kernel::System::CustomerUser')->CustomerUserDataGet(
            User => $CustomerUserID,
        );

        # HTML quoting of content
        if ( $Param{RichText} ) {

            ATTRIBUTE:
            for my $Attribute ( sort keys %CustomerUser ) {
                next ATTRIBUTE if !$CustomerUser{$Attribute};
                $CustomerUser{$Attribute} = $Kernel::OM->Get('Kernel::System::HTMLUtils')->ToHTML(
                    String => $CustomerUser{$Attribute},
                );
            }
        }

        # replace it
        $HashGlobalReplace->( "$Tag|$Tag2", %CustomerUser );
    }

    # cleanup all not needed <OTRS_CUSTOMER_DATA_ tags
    $Param{Text} =~ s/(?:$Tag|$Tag2).+?$End/-/gi;

    # cleanup all not needed <OTRS_AGENT_ tags
    $Tag = $Start . 'OTRS_AGENT_';
    $Param{Text} =~ s/$Tag.+?$End/-/gi;

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
