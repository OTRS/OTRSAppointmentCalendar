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

    # Template: AgentAppointmentAgendaOverview
    $Self->{Translation}->{'Agenda Overview'} = 'Pregled dnevnog reda';
    $Self->{Translation}->{'Manage Calendars'} = 'Upravljanje kalendarima';
    $Self->{Translation}->{'Add Appointment'} = 'Dodaj termin';
    $Self->{Translation}->{'Color'} = 'Boja';
    $Self->{Translation}->{'End date'} = 'Datum kraja';
    $Self->{Translation}->{'Repeat'} = 'Ponavljanje';
    $Self->{Translation}->{'No calendars found. Please add a calendar first by using Manage Calendars page.'} =
        'Nije pronađen nijedan kalendar. Molimo prvo dodajte kalendar korišćenjem ekrana Upravljanje kalendarima.';
    $Self->{Translation}->{'Appointment'} = 'Termin';
    $Self->{Translation}->{'This is a repeating appointment'} = 'Ovaj termin se ponavlja';
    $Self->{Translation}->{'Would you like to edit just this occurrence or all occurrences?'} =
        'Da li želite da izmeni samo ovo ili sva ponavljanja?';
    $Self->{Translation}->{'All occurrences'} = 'Sva ponavljanja';
    $Self->{Translation}->{'Just this occurrence'} = 'Samo ovo ponavljanje';

    # Template: AgentAppointmentCalendarImport
    $Self->{Translation}->{'Calendar Import'} = 'Uvoz kalendara';
    $Self->{Translation}->{'Uploaded file must be in valid iCal format (.ics).'} = 'Poslati fajl mora biti u ispravnom iCal formatu (.ics).';
    $Self->{Translation}->{'If desired Calendar is not listed here, please make sure that you have at least \'create\' permissions.'} =
        'Ukoliko željeni kalendar nije izlistan, proverite da li imate nivo pristupa \'kreiranje\' za grupu kalendara.';
    $Self->{Translation}->{'Upload'} = 'Pošalji';
    $Self->{Translation}->{'Update existing appointments?'} = 'Osveži postojeće termine?';
    $Self->{Translation}->{'All existing appointments in the calendar with same UniqueID will be overwritten.'} =
        'Svi postojeći termini u kalendaru sa istim UniqueID poljem će biti prebrisani.';
    $Self->{Translation}->{'Upload calendar'} = 'Pošalji kalendar';
    $Self->{Translation}->{'Import calendar'} = 'Uvezi kalendar';

    # Template: AgentAppointmentCalendarManage
    $Self->{Translation}->{'Successfully imported %s appointment(s) to calendar %s.'} = 'Uspešno uvezeno %s termin(a) u kalendar %s.';
    $Self->{Translation}->{'Calendar Management'} = 'Upravljanje kalendarima';
    $Self->{Translation}->{'Calendar Overview'} = 'Pregled kalendara';
    $Self->{Translation}->{'Add new Calendar'} = 'Dodaj novi kalendar';
    $Self->{Translation}->{'Add Calendar'} = 'Dodaj kalendar';
    $Self->{Translation}->{'Import Calendar'} = 'Uvezi kalendar';
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
    $Self->{Translation}->{'URL'} = 'Adresa';
    $Self->{Translation}->{'Export calendar'} = 'Izvezi kalendar';
    $Self->{Translation}->{'Copy public calendar URL'} = 'Iskopiraj javnu adresu kalendara (URL)';
    $Self->{Translation}->{'Calendar name'} = 'Naziv kalendara';
    $Self->{Translation}->{'Calendar with same name already exists.'} = 'Kalendar sa istim nazivom već postoji.';
    $Self->{Translation}->{'Permission group'} = 'Grupa pristupa';
    $Self->{Translation}->{'More'} = 'Više';
    $Self->{Translation}->{'Less'} = 'Manje';

    # Template: AgentAppointmentCalendarOverview
    $Self->{Translation}->{'Add new Appointment'} = 'Dodaj novi termin';
    $Self->{Translation}->{'Calendars'} = 'Kalendari';
    $Self->{Translation}->{'This is an overview page for the Appointment Calendar.'} = 'Ova stranica služi za pregled kalendara.';
    $Self->{Translation}->{'Too many active calendars'} = 'Previše aktivnih kalendara';
    $Self->{Translation}->{'Please either turn some off first or increase the limit in configuration.'} =
        'Ili prvo isključite prikaz nekog kalendara ili povećajte limit u konfiguraciji.';
    $Self->{Translation}->{'Week'} = 'Sedmica';
    $Self->{Translation}->{'Timeline Month'} = 'Mesečna osa';
    $Self->{Translation}->{'Timeline Week'} = 'Sedmična osa';
    $Self->{Translation}->{'Timeline Day'} = 'Dnevna osa';
    $Self->{Translation}->{'Jump'} = 'Skoči';
    $Self->{Translation}->{'Dismiss'} = 'Poništi';
    $Self->{Translation}->{'Show'} = 'Prikaži';
    $Self->{Translation}->{'Basic information'} = 'Osnovne informacije';
    $Self->{Translation}->{'Location'} = 'Lokacija';
    $Self->{Translation}->{'Resource'} = 'Resurs';
    $Self->{Translation}->{'Team'} = 'Tim';
    $Self->{Translation}->{'Date/Time'} = 'Datum/vreme';

    # Template: AgentAppointmentCalendarOverviewSeen
    $Self->{Translation}->{'Following appointments have been started'} = 'Sledeći termini su započeti';
    $Self->{Translation}->{'Start time'} = 'Početak';
    $Self->{Translation}->{'End time'} = 'Kraj';

    # Template: AgentAppointmentEdit
    $Self->{Translation}->{'Please set this to value before End date.'} = 'Molimo postavite ovaj datum pre kraja.';
    $Self->{Translation}->{'Please set this to value after Start date.'} = 'Molimo postavite ovaj datum posle početka.';
    $Self->{Translation}->{'This an ocurrence of a repeating appointment.'} = 'Ovo je termin koji se ponavlja.';
    $Self->{Translation}->{'Click here to see the parent appointment.'} = 'Kliknite ovde za pregled matičnog termina.';
    $Self->{Translation}->{'Click here to edit the parent appointment.'} = 'Kliknite ovde za izmenu matičnog termina.';
    $Self->{Translation}->{'Frequency'} = 'Učestalost';
    $Self->{Translation}->{'Every'} = 'Svakog(e)';
    $Self->{Translation}->{'Relative point of time'} = 'Relativno vreme';
    $Self->{Translation}->{'Are you sure you want to delete this appointment? This operation cannot be undone.'} =
        'Da li ste sigurni da želite da izbrišete ovaj termin? Ovu operaciju nije moguće opozvati.';

    # Template: AgentAppointmentResourceOverview
    $Self->{Translation}->{'Resource Overview'} = 'Pregled resursa';
    $Self->{Translation}->{'Manage Teams'} = 'Upravljanje timovima';
    $Self->{Translation}->{'Manage Team Agents'} = 'Upravljanje operaterima u timovima';
    $Self->{Translation}->{'This is a resource overview page.'} = 'Ova stranica služi za pregled resursa.';
    $Self->{Translation}->{'No teams found. Please add a team first by using Manage Teams page.'} =
        'Nijedan tim nije pronađen. Molimo prvo dodajte tim korišćenjeem ekrana Upravljanje timovima';
    $Self->{Translation}->{'No team agents found. Please assign agents to a team first by using Manage Team Agents page.'} =
        'Nijedan operater nije pronađen u timu. Molimo prvo dodajte operatera u tim korišćenjem Upravljanje operaterima u timovima.';
    $Self->{Translation}->{'Restore default settings'} = 'Vratite podrazumevana podešavanja';
    $Self->{Translation}->{'Resources'} = 'Resursi';
    $Self->{Translation}->{'Shown resources'} = 'Prikazani resursi';
    $Self->{Translation}->{'Available Resources'} = 'Dostupni resursi';
    $Self->{Translation}->{'Filter available resources'} = 'Filter za dostupne resurse';
    $Self->{Translation}->{'Visible Resources (order by drag & drop)'} = 'Vidljivi resursi (redosled prema prevuci i pusti)';

    # Template: AgentAppointmentTeam
    $Self->{Translation}->{'Add Team'} = 'Dodaj tim';
    $Self->{Translation}->{'Team Import'} = 'Uvoz tima';
    $Self->{Translation}->{'Here you can upload a configuration file to import a team to your system. The file needs to be in .yml format as exported by team management module.'} =
        'Ovde možete poslati konfiguracioni fajl za uvoz tima u vaš sistem. Fajl mora biti u istom .yml formatu koji je moguće dobiti izvozom u ekranu upravljanja timovima.';
    $Self->{Translation}->{'Import team'} = 'Uvezi tim';
    $Self->{Translation}->{'Filter for teams'} = 'Filter za timove';
    $Self->{Translation}->{'Export team'} = 'Izvezi tim';
    $Self->{Translation}->{'Edit Team'} = 'Izmeni tim';
    $Self->{Translation}->{'Team with same name already exists.'} = 'Tim sa istim nazivom već postoji.';

    # Template: AgentAppointmentTeamUser
    $Self->{Translation}->{'Filter for agents'} = 'Filter za operatere';
    $Self->{Translation}->{'Teams'} = 'Timovi';
    $Self->{Translation}->{'Manage Team-Agent Relations'} = 'Upravljanje operaterima u timovima';
    $Self->{Translation}->{'Change Agent Relations for Team'} = 'Izmeni pripadnost operatera timu';
    $Self->{Translation}->{'Change Team Relations for Agent'} = 'Izmeni pripadnost timu operaterima';

    # Perl Module: Kernel/Modules/AgentAppointmentCalendarImport.pm
    $Self->{Translation}->{'No permissions'} = 'Bez dozvole';
    $Self->{Translation}->{'System was unable to import file!'} = 'Sistem nije uspeo da uveze fajl!';

    # Perl Module: Kernel/Modules/AgentAppointmentCalendarManage.pm
    $Self->{Translation}->{'System was unable to create Calendar!'} = 'Sistem nije uspeo da kreira kalendar!';
    $Self->{Translation}->{'No CalendarID!'} = 'Nema CalendarID!';
    $Self->{Translation}->{'You have no access to this calendar!'} = 'Nemate pristup ovom kalendaru!';
    $Self->{Translation}->{'Edit Calendar'} = 'Izmeni kalendar';
    $Self->{Translation}->{'Error updating the calendar!'} = 'Greška prilikom izmene kalendara';

    # Perl Module: Kernel/Modules/AgentAppointmentCalendarOverview.pm
    $Self->{Translation}->{'All appointments'} = 'Svi termini';
    $Self->{Translation}->{'Appointments assigned to me'} = 'Termini dodeljeni meni';
    $Self->{Translation}->{'Showing only appointments assigned to you! Change settings'} = 'Prikaz samo termina dodeljenih vama! Izmenite podešavanja';

    # Perl Module: Kernel/Modules/AgentAppointmentEdit.pm
    $Self->{Translation}->{'Appointment not found!'} = 'Termin nije pronađen!';
    $Self->{Translation}->{'Never'} = 'Nikada';
    $Self->{Translation}->{'Every Day'} = 'Svaki dan';
    $Self->{Translation}->{'Every Week'} = 'Svake sedmice';
    $Self->{Translation}->{'Every Month'} = 'Svakog meseca';
    $Self->{Translation}->{'Every Year'} = 'Svake godine';
    $Self->{Translation}->{'Custom'} = 'Prilagođeno';
    $Self->{Translation}->{'Daily'} = 'Dnevno';
    $Self->{Translation}->{'Weekly'} = 'Sedmično';
    $Self->{Translation}->{'Monthly'} = 'Mesečno';
    $Self->{Translation}->{'Yearly'} = 'Godišnje';
    $Self->{Translation}->{'every'} = 'Svake';
    $Self->{Translation}->{'for %s time(s)'} = 'ukupno %s put(a)';
    $Self->{Translation}->{'until ...'} = 'do ...';
    $Self->{Translation}->{'for ... time(s)'} = 'ukupno ... put(a)';
    $Self->{Translation}->{'until %s'} = 'do %s';
    $Self->{Translation}->{'No notification'} = 'Bez obaveštenja';
    $Self->{Translation}->{'%s minute(s) before'} = '%s minut(a) pre';
    $Self->{Translation}->{'%s hour(s) before'} = '%s sat(a) pre';
    $Self->{Translation}->{'%s day(s) before'} = '%s dan(a) pre';
    $Self->{Translation}->{'%s week before'} = '%s nedelja pre';
    $Self->{Translation}->{'before the appointment starts'} = 'pre nego što termin započne';
    $Self->{Translation}->{'after the appointment has been started'} = 'pošto termin započne';
    $Self->{Translation}->{'before the appointment ends'} = 'pre nego što se termin završi';
    $Self->{Translation}->{'after the appointment has been ended'} = 'pošto se termin završi';
    $Self->{Translation}->{'No permission!'} = 'Bez dozvole!';
    $Self->{Translation}->{'Links could not be deleted!'} = 'Veze ne mogu biti obrisane!';
    $Self->{Translation}->{'Link could not be created!'} = 'Veza nije mogla biti kreirana!';
    $Self->{Translation}->{'No permissions!'} = 'Bez dozvole!';

    # Perl Module: Kernel/Modules/AgentAppointmentList.pm
    $Self->{Translation}->{'+%d more'} = '+%d više';
    $Self->{Translation}->{'Ongoing appointments'} = 'Započeti termini';

    # Perl Module: Kernel/Modules/AgentAppointmentTeam.pm
    $Self->{Translation}->{'Need TeamID!'} = 'Nema TeamID!';
    $Self->{Translation}->{'Could not retrieve data for given TeamID'} = 'Za dati TeamID nema podataka';

    # Perl Module: Kernel/Modules/AgentAppointmentTeamList.pm
    $Self->{Translation}->{'Unassigned'} = 'Nedodeljeno';

    # Perl Module: Kernel/Modules/PublicCalendar.pm
    $Self->{Translation}->{'No such user!'} = 'Nepoznat korisnik!';
    $Self->{Translation}->{'Invalid calendar!'} = 'Neispravan kalendar!';
    $Self->{Translation}->{'Invalid URL!'} = 'Neispravna adresa!';
    $Self->{Translation}->{'There was an error exporting the calendar!'} = 'Greška prilikom eksportovanja kalendara!';

    # SysConfig
    $Self->{Translation}->{'Appointment Calendar overview page.'} = 'Stranica za pregled kalendara.';
    $Self->{Translation}->{'Appointment calendar event module that prepares notification entries for appointments.'} =
        'Modul događaja kalendara za pripremu obaveštenja o terminima.';
    $Self->{Translation}->{'Appointment edit screen.'} = 'Stranica za izmenu kalendara.';
    $Self->{Translation}->{'Appointment list'} = 'Lista termina';
    $Self->{Translation}->{'Appointment list.'} = 'Lista termina.';
    $Self->{Translation}->{'Calendar manage screen.'} = 'Stranica za upravljanje kalendarima.';
    $Self->{Translation}->{'Create a new calendar appointment linked to this ticket'} = 'Kreira novi termin u kalendaru povezan sa ovim tiketom';
    $Self->{Translation}->{'Create new appointment.'} = 'Kreira novi termin.';
    $Self->{Translation}->{'Defines the ticket plugin for calendar appointments.'} = 'Definiše tiket modul za kalendarske termine.';
    $Self->{Translation}->{'Defines which backend should be used for managing calendars.'} =
        'Definiše koji pozadinski modul će biti korišćen za upravljanje kalendarima.';
    $Self->{Translation}->{'Edit appointment'} = 'Izmena termina';
    $Self->{Translation}->{'Import Calendar screen.'} = 'Ekran za uvoz kalendara.';
    $Self->{Translation}->{'Links appointments and tickets with a "Normal" type link.'} = 'Povezuje termine i tikete "Normalnim" vrstama veza.';
    $Self->{Translation}->{'List of all appointment events to be displayed in the GUI.'} = 'Lista svih obaveštenja o terminima za prikaz u interfejsu.';
    $Self->{Translation}->{'List of colors in hexadecimal RGB which will be available for selection during calendar creation. Make sure the colors are dark enough so white text can be overlayed on them.'} =
        'Lista boja u heksadecimalnom RGB zapisu koje će biti dostupne za izbor prilikom pravljenja kalendara. Obratite pažnju da su boje dovoljno tamne tako da beli tekst može biti ispisan na njima.';
    $Self->{Translation}->{'Manage different calendars.'} = 'Upravljanje različitim kalendarima.';
    $Self->{Translation}->{'Manage team agents.'} = 'Upravljanje operaterima u timovima.';
    $Self->{Translation}->{'Maximum number of active calendars in overview screens. Please note that large number of active calendars can have a performance impact on your server by making too much simultaneous calls.'} =
        'Maksimalni broj aktivnih kalendara u ekranima za pregled. Obratite pažnju da veliki broj aktivnih kalendara može imati uticaj na performanse vašeg servera pravljenjem previše simultanih zahteva.';
    $Self->{Translation}->{'New Appointment'} = 'Novi termin';
    $Self->{Translation}->{'OTRS doesn\'t support recurring Appointments without end date or number of iterrations. During import process, it might happen that ICS file contains such Appointments. Instead, system creates all Appointments in the past, plus Appointments for the next n months(120 months/10 years by default).'} =
        'OTRS ne podržava termine koji se ponavljaju bez krajnjeg datuma ili broja iteracija. Prilikom uvoza kalendara, može se dogoditi da ICS fajl sadrži takve \'beskonačne\' termine. Umesto takvog ponašanja, sistem će kreirati sve termine iz prošlosti, kao i termine za sledeći n broj meseci (podrazumevano 120 meseci/10 godina).';
    $Self->{Translation}->{'Overview of all appointments.'} = 'Pregled svih termina.';
    $Self->{Translation}->{'Plugin search'} = 'Modul pretrage';
    $Self->{Translation}->{'Plugin search module for autocomplete.'} = 'Modul pretrage za automatsko dopunjavanje.';
    $Self->{Translation}->{'Resource overview page.'} = 'Stranica za pregled resursa.';
    $Self->{Translation}->{'Resource overview screen.'} = 'Ekran pregleda resursa.';
    $Self->{Translation}->{'Resources list.'} = 'Lista resursa.';
    $Self->{Translation}->{'Shows a link in the menu for creating a calendar appointment linked to the ticket directly from the ticket zoom view of the agent interface. Additional access control to show or not show this link can be done by using Key "Group" and Content like "rw:group1;move_into:group2". To cluster menu items use for Key "ClusterName" and for the Content any name you want to see in the UI. Use "ClusterPriority" to configure the order of a certain cluster within the toolbar.'} =
        'Prikazuje vezu u meniju tiketa za kreiranje termina u kalendaru povezanog sa tim tiketom. Dodatna kontrola prikaza ove veze može se postići korišćenjem ključa "Group" sa sadržajem "rw:group1;move_into:group2". Za združivanje veza u meniju podesite ključ "ClusterName" sa sadržajem koji će biti naziv koji želite da vidite u interfejsu. Koristite ključ "ClusterPriority" za izmenu redosleda grupa u meniju.';
    $Self->{Translation}->{'Team agents management screen.'} = 'Ekran upravljanja operaterima u timovima.';
    $Self->{Translation}->{'Team list'} = 'Lista timova';
    $Self->{Translation}->{'Team management screen.'} = 'Ekran upravljanja timovima.';
    $Self->{Translation}->{'Team management.'} = 'Upravljanje timovima.';


    push @{ $Self->{JavaScriptStrings} // [] }, (
    );

}

1;
