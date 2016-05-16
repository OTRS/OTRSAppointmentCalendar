# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::sr_Latn_OTRSAppointmentCalendar;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    # Template: AgentAppointmentCalendarManage
    $Self->{Translation}->{'Calendar Management'} = 'Upravljanje kalendarima';
    $Self->{Translation}->{'Calendar Overview'} = 'Pregled kalendara';
    $Self->{Translation}->{'Add new Calendar'} = 'Dodaj novi kalendar';
    $Self->{Translation}->{'Calendar Import'} = 'Uvoz kalendara';
    $Self->{Translation}->{'Here you can upload a file to import calendar to your system. The file needs to be in .ics format.'} =
        'Ovde možete poslati fajl za uvoz kalendara u sistem. Fajl mora biti u .ics formatu.';
    $Self->{Translation}->{'Upload calendar'} = 'Pošalji kalendar';
    $Self->{Translation}->{'Import calendar'} = 'Uvezi kalendar';
    $Self->{Translation}->{'Filter for calendars'} = 'Filter za kalendare';
    $Self->{Translation}->{'Depending on the group field, the system will allow users the access to the calendar according to their permission level.'} =
        'U zavisnosti od polja grupe, sistem će dozvoliti pristup kalendaru operaterima prema njihovom nivou pristupa.';
    $Self->{Translation}->{'Read only: users can see and export all appointments in the calendar.'} =
        'RO: operateri mogu pregledati i eksportovati sve termine u kalendaru.';
    $Self->{Translation}->{'Move into: users can modify appointments in the calendar, but without changing the calendar selection.'} =
        'Premesti u: operateri mogu modifikovati termine u kalendaru, ali bez promene kom kalendaru pripadaju.';
    $Self->{Translation}->{'Create: users can create and delete appointments in the calendar.'} =
        'Kreiranje: operateri mogu kreirati i brisati termine u kalendaru.';
    $Self->{Translation}->{'Read/write: users can manage the calendar itself.'} = 'RW: operateri mogu administrirati i sam kalendar.';
    $Self->{Translation}->{'Calendar imported successfully.'} = 'Kalendar uspešno uvezen.';
    $Self->{Translation}->{'Calendar name'} = 'Naziv kalendara';
    $Self->{Translation}->{'Calendar with same name already exists.'} = 'Kalendar sa istim nazivom već postoji.';
    $Self->{Translation}->{'Permission group'} = 'Grupa pristupa';

    # Template: AgentAppointmentCalendarOverview
    $Self->{Translation}->{'Manage Calendars'} = 'Upravljanje kalendarima';
    $Self->{Translation}->{'Calendars'} = 'Kalendari';
    $Self->{Translation}->{'This is an overview page for the Appointment Calendar.'} = 'Ova stranica služi za pregled kalendara.';
    $Self->{Translation}->{'No calendars found. Please add a calendar first by using Manage Calendars page.'} =
        'Nije pronađen nijedan kalendar. Molimo prvo dodajte kalendar korišćenjem ekrana Upravljanje kalendarima.';
    $Self->{Translation}->{'Week'} = 'Sedmica';
    $Self->{Translation}->{'Timeline'} = 'Vremenska osa';
    $Self->{Translation}->{'Jump'} = 'Skoči';
    $Self->{Translation}->{'Appointment'} = 'Termin';
    $Self->{Translation}->{'This is a repeating appointment'} = 'Ovaj termin se ponavlja';
    $Self->{Translation}->{'Would you like to edit just this occurrence or all occurrences?'} =
        'Da li želite da izmeni samo ovo ili sva ponavljanja?';
    $Self->{Translation}->{'All occurrences'} = 'Sva ponavljanja';
    $Self->{Translation}->{'Just this occurrence'} = 'Samo ovo ponavljanje';
    $Self->{Translation}->{'Dismiss'} = 'Poništi';
    $Self->{Translation}->{'Basic information'} = 'Osnovne informacije';
    $Self->{Translation}->{'Date/Time'} = 'Datum/vreme';
    $Self->{Translation}->{'End date'} = 'Datum kraja';
    $Self->{Translation}->{'Repeat'} = 'Ponavljanje';

    # Template: AgentAppointmentCalendarOverviewSeen
    $Self->{Translation}->{'Following appointments have been started'} = 'Sledeći termini su započeti';
    $Self->{Translation}->{'Start time'} = 'Početak';
    $Self->{Translation}->{'End time'} = 'Kraj';
    $Self->{Translation}->{'Resource'} = 'Resurs';

    # Template: AgentAppointmentEdit
    $Self->{Translation}->{'Team'} = 'Tim';

    # Template: AgentAppointmentResourceOverview
    $Self->{Translation}->{'Resource Overview'} = 'Pregled resursa';
    $Self->{Translation}->{'Manage Teams'} = 'Upravljanje timovima';
    $Self->{Translation}->{'Manage Team Agents'} = 'Upravljanje operaterima u timovima';
    $Self->{Translation}->{'This is a resource overview page.'} = 'Ova stranica služi za pregled resursa.';
    $Self->{Translation}->{'No teams found. Please add a team first by using Manage Teams page.'} =
        'Nijedan tim nije pronađen. Molimo prvo dodajte tim korišćenjeem ekrana Upravljanje timovima';
    $Self->{Translation}->{'No team agents found. Please assign agents to a team first by using Manage Team Agents page.'} =
        'Nijedan operater nije pronađen u timu. Molimo prvo dodajte operatera u tim korišćenjem Upravljanje operaterima u timovima.';
    $Self->{Translation}->{'Timeline Month'} = 'Mesečna vremenska osa';
    $Self->{Translation}->{'Timeline Week'} = 'Sedmična vremenska osa';
    $Self->{Translation}->{'Timeline Day'} = 'Dnevna vremenska osa';
    $Self->{Translation}->{'Resources'} = 'Resursi';

    # Template: AgentAppointmentTeam
    $Self->{Translation}->{'Add Team'} = 'Dodaj tim';
    $Self->{Translation}->{'Filter for teams'} = 'Filter za timove';
    $Self->{Translation}->{'Edit Team'} = 'Izmeni tim';
    $Self->{Translation}->{'Team with same name already exists.'} = 'Tim sa istim nazivom već postoji.';

    # Template: AgentAppointmentTeamUser
    $Self->{Translation}->{'Manage Team-Agent Relations'} = 'Upravljanje operaterima u timovima';
    $Self->{Translation}->{'Change Agent Relations for Team'} = 'Izmeni pripadnost operatera timu';

    # Perl Module: Kernel/Modules/AgentAppointmentCalendarManage.pm
    $Self->{Translation}->{'System was unable to create Calendar!'} = 'Sistem nije uspeo da kreira kalendar!';
    $Self->{Translation}->{'No CalendarID!'} = 'Nema CalendarID!';
    $Self->{Translation}->{'You have no access to this calendar!'} = 'Nemate pristup ovom kalendaru!';
    $Self->{Translation}->{'Edit Calendar'} = 'Izmeni kalendar';
    $Self->{Translation}->{'Error updating the calendar!'} = 'Greška prilikom izmene kalendara';
    $Self->{Translation}->{'No permissions'} = 'Bez dozvole';
    $Self->{Translation}->{'No permissions to create a new calendar!'} = 'Nemate dozvolu da kreirate novi kalendar!';
    $Self->{Translation}->{'System was unable to create a new calendar!'} = 'Sistem nije uspeo da kreira novi kalendar!';
    $Self->{Translation}->{'System was unable to import file!'} = 'Sistem nije uspeo da uveze fajl!';

    # Perl Module: Kernel/Modules/AgentAppointmentEdit.pm
    $Self->{Translation}->{'Every Day'} = 'Svaki dan';
    $Self->{Translation}->{'Every Week'} = 'Svake sedmice';
    $Self->{Translation}->{'Every Month'} = 'Svakog meseca';
    $Self->{Translation}->{'Every Year'} = 'Svake godine';
    $Self->{Translation}->{'until ...'} = 'do ...';
    $Self->{Translation}->{'for ... time(s)'} = 'ukupno ... put(a)';
    $Self->{Translation}->{'No permission!'} = 'Bez dozvole!';
    $Self->{Translation}->{'Links could not be deleted!'} = 'Veze ne mogu biti obrisane!';
    $Self->{Translation}->{'Link could not be created!'} = 'Veza nije mogla biti kreirana!';
    $Self->{Translation}->{'No permissions!'} = 'Bez dozvole!';

    # Perl Module: Kernel/Modules/AgentAppointmentList.pm
    $Self->{Translation}->{'Ongoing appointments'} = 'Započeti termini';

    # Perl Module: Kernel/Modules/AgentAppointmentTeamList.pm
    $Self->{Translation}->{'Unassigned'} = 'Nedodeljeno';

    # Perl Module: Kernel/Modules/PublicCalendar.pm
    $Self->{Translation}->{'There was an error exporting the calendar!'} = 'Greška prilikom eksportovanja kalendara!';

    # SysConfig
    $Self->{Translation}->{'Appointment Calendar overview page.'} = 'Stranica za pregled kalendara.';
    $Self->{Translation}->{'Appointment edit screen.'} = 'Stranica za izmenu kalendara.';
    $Self->{Translation}->{'Appointment list'} = 'Lista termina';
    $Self->{Translation}->{'Appointment list.'} = 'Lista termina.';
    $Self->{Translation}->{'Calendar manage screen.'} = 'Stranica za upravljanje kalendarima.';
    $Self->{Translation}->{'Defines the ticket number plugin for calendar appointments.'} = 'Definiše plugin za broj tiketa u kalendar terminima.';
    $Self->{Translation}->{'Defines which backend should be used for managing calendars.'} =
        'Definiše koji pozadinskog modul će biti korišćen za upravljanje kalendarima.';
    $Self->{Translation}->{'Edit appointment'} = 'Izmena termina';
    $Self->{Translation}->{'Links appointments and tickets with a "Normal" type link.'} = 'Povezuje termine i tikete "Normalnim" vrstama veza.';
    $Self->{Translation}->{'List of colors in hexadecimal RGB which will be allocated to different user calendars. Make sure the colors are dark enough so white text can be overlayed on them. If the number of calendars exceeds the number of colors, the list will be reused from the start.'} =
        'Lista boja u heksadecimalnom RGB zapisu koje će biti korišćene za prikaz kalendara. Obratite pažnju da boje budu dovoljno tamne tako da se može prikazati beli tekst na njima. Ukoliko broj kalendara pređe preko broja boja, lista će biti ponovo iskorišćena iz početka.';
    $Self->{Translation}->{'Manage different calendars.'} = 'Upravljanje različitim kalendarima.';
    $Self->{Translation}->{'Manage team agents.'} = 'Upravljanje operaterima u timovima.';
    $Self->{Translation}->{'Resource overview page.'} = 'Stranica za pregled resursa.';
    $Self->{Translation}->{'Resource overview screen.'} = 'Ekran pregleda resursa.';
    $Self->{Translation}->{'Resources list.'} = 'Lista resursa.';
    $Self->{Translation}->{'Team agents management screen.'} = 'Ekran upravljanja operaterima u timovima.';
    $Self->{Translation}->{'Team list'} = 'Lista timova';
    $Self->{Translation}->{'Team management screen.'} = 'Ekran upravljanja timovima.';
    $Self->{Translation}->{'Team management.'} = 'Upravljanje timovima.';

}

1;
