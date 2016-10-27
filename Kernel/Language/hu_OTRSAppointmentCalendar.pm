# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::hu_OTRSAppointmentCalendar;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    # Template: AdminAppointmentNotificationEvent
    $Self->{Translation}->{'Appointment Notification Management'} = 'Értekezlet-értesítés kezelés';
    $Self->{Translation}->{'Here you can upload a configuration file to import appointment notifications to your system. The file needs to be in .yml format as exported by the appointment notification module.'} =
        'Itt tud egy beállítófájlt feltölteni az értekezlet-értesítések importálásához a rendszerre. A fájlnak .yml formátumban kell lennie, ahogy az értekezlet-értesítés modul exportálta.';
    $Self->{Translation}->{'Here you can choose which events will trigger this notification. An additional appointment filter can be applied below to only send for appointments with certain criteria.'} =
        'Itt választhatja ki, hogy mely események fogják aktiválni ezt az értesítést. Egy további értekezletszűrő alkalmazható lent a csak egy bizonyos feltétellel rendelkező értekezleteknél történő küldéshez.';
    $Self->{Translation}->{'Appointment Filter'} = 'Értekezlet szűrő';
    $Self->{Translation}->{'Team'} = 'Csapat';
    $Self->{Translation}->{'Resource'} = 'Erőforrás';
    $Self->{Translation}->{'Notify user just once per day about a single appointment using a selected transport.'} =
        'A felhasználó értesítése csak egyszer egy nap egy egyedüli értekezletről egy kiválasztott átvitel használatával.';
    $Self->{Translation}->{'Notifications are sent to an agent.'} = 'Az értesítések egy ügyintézőnek kerülnek elküldésre.';
    $Self->{Translation}->{'To get the first 20 character of the appointment title.'} = 'Az értekezlet címe első 20 karakterének lekéréséhez.';
    $Self->{Translation}->{'To get the appointment attribute'} = 'Az értekezlet jellemzőjének lekéréséhez';
    $Self->{Translation}->{'To get the calendar attribute'} = 'A naptár jellemzőjének lekéréséhez';

    # Template: AgentAppointmentAgendaOverview
    $Self->{Translation}->{'Agenda Overview'} = 'Napirend áttekintő';
    $Self->{Translation}->{'Manage Calendars'} = 'Naptárak kezelése';
    $Self->{Translation}->{'Add Appointment'} = 'Értekezlet hozzáadása';
    $Self->{Translation}->{'Color'} = 'Szín';
    $Self->{Translation}->{'End date'} = 'Befejezési dátum';
    $Self->{Translation}->{'Repeat'} = 'Ismétlés';
    $Self->{Translation}->{'No calendars found. Please add a calendar first by using Manage Calendars page.'} =
        'Nem találhatók naptárak. Először adjon hozzá egy naptárat a naptárak kezelése oldal használatával.';
    $Self->{Translation}->{'Appointment'} = 'Értekezlet';
    $Self->{Translation}->{'This is a repeating appointment'} = 'Ez egy ismétlődő értekezlet';
    $Self->{Translation}->{'Would you like to edit just this occurrence or all occurrences?'} =
        'Csak ezt az előfordulást szeretné szerkeszteni vagy az összeset?';
    $Self->{Translation}->{'All occurrences'} = 'Összes előfordulás';
    $Self->{Translation}->{'Just this occurrence'} = 'Csak ez az előfordulás';

    # Template: AgentAppointmentCalendarManage
    $Self->{Translation}->{'Calendar Management'} = 'Naptárkezelés';
    $Self->{Translation}->{'Calendar Overview'} = 'Naptár áttekintő';
    $Self->{Translation}->{'Add new Calendar'} = 'Új naptár hozzáadása';
    $Self->{Translation}->{'Add Calendar'} = 'Naptár hozzáadása';
    $Self->{Translation}->{'Import Appointments'} = 'Értekezletek importálása';
    $Self->{Translation}->{'Calendar Import'} = 'Naptár importálása';
    $Self->{Translation}->{'Here you can upload a configuration file to import a calendar to your system. The file needs to be in .yml format as exported by calendar management module.'} =
        'Itt tölthet fel egy beállítófájlt egy naptár importálásához a rendszerre. A fájlnak .yml formátumban kell lennie, ahogy a naptárkezelő modul exportálta.';
    $Self->{Translation}->{'Upload calendar configuration'} = 'Naptárbeállítás feltöltése';
    $Self->{Translation}->{'Import Calendar'} = 'Naptár importálása';
    $Self->{Translation}->{'Filter for calendars'} = 'Szűrő a naptárakhoz';
    $Self->{Translation}->{'Depending on the group field, the system will allow users the access to the calendar according to their permission level.'} =
        'A csoportmezőtől függően a rendszer a felhasználókat a jogosultsági szintjük alapján fogja engedni hozzáférni a naptárhoz.';
    $Self->{Translation}->{'Read only: users can see and export all appointments in the calendar.'} =
        'Csak olvasás: a felhasználók láthatják és exportálhatják a naptárban lévő összes értekezletet.';
    $Self->{Translation}->{'Move into: users can modify appointments in the calendar, but without changing the calendar selection.'} =
        'Átmozgatás: a felhasználók módosíthatják az értekezleteket a naptárban, de a naptárválasztás megváltoztatása nélkül.';
    $Self->{Translation}->{'Create: users can create and delete appointments in the calendar.'} =
        'Létrehozás: a felhasználók létrehozhatnak és törölhetnek értekezleteket a naptárban.';
    $Self->{Translation}->{'Read/write: users can manage the calendar itself.'} = 'Írás, olvasás: a felhasználók magát a naptárat kezelhetik.';
    $Self->{Translation}->{'URL'} = 'URL';
    $Self->{Translation}->{'Export calendar'} = 'Naptár exportálása';
    $Self->{Translation}->{'Download calendar'} = 'Naptár letöltése';
    $Self->{Translation}->{'Copy public calendar URL'} = 'Nyilvános naptár URL másolása';
    $Self->{Translation}->{'Calendar name'} = 'Naptár neve';
    $Self->{Translation}->{'Calendar with same name already exists.'} = 'Már létezik egy ilyen nevű naptár.';
    $Self->{Translation}->{'Permission group'} = 'Jogosultsági csoport';
    $Self->{Translation}->{'Ticket Appointments'} = 'Jegyértekezletek';
    $Self->{Translation}->{'Rule'} = 'Szabály';
    $Self->{Translation}->{'Use options below to narrow down for which tickets appointments will be automatically created.'} =
        'Használja a lenti lehetőségeket annak leszűkítéséhez, hogy mely jegyek értekezletei legyenek automatikusan létrehozva.';
    $Self->{Translation}->{'Please select a valid queue.'} = 'Válasszon egy érvényes várólistát.';
    $Self->{Translation}->{'Search attributes'} = 'Keresési attribútumok';
    $Self->{Translation}->{'Define rules for creating automatic appointments in this calendar based on ticket data.'} =
        'Szabályok meghatározása automatikus értekezletek létrehozásához ebben a naptárban a jegyadatok alapján.';
    $Self->{Translation}->{'Add Rule'} = 'Szabály hozzáadása';
    $Self->{Translation}->{'More'} = 'Több';
    $Self->{Translation}->{'Less'} = 'Kevesebb';

    # Template: AgentAppointmentCalendarOverview
    $Self->{Translation}->{'Add new Appointment'} = 'Új értekezlet hozzáadása';
    $Self->{Translation}->{'Calendars'} = 'Naptárak';
    $Self->{Translation}->{'This is an overview page for the Appointment Calendar.'} = 'Ez egy áttekintő oldal az értekezlet naptárhoz.';
    $Self->{Translation}->{'Too many active calendars'} = 'Túl sok aktív naptár';
    $Self->{Translation}->{'Please either turn some off first or increase the limit in configuration.'} =
        'Vagy kapcsoljon ki néhányat először, vagy növelje a korlátot a beállításokban.';
    $Self->{Translation}->{'Week'} = 'Hét';
    $Self->{Translation}->{'Timeline Month'} = 'Havi idővonal';
    $Self->{Translation}->{'Timeline Week'} = 'Heti idővonal';
    $Self->{Translation}->{'Timeline Day'} = 'Napi idővonal';
    $Self->{Translation}->{'Jump'} = 'Ugrás';
    $Self->{Translation}->{'Dismiss'} = 'Eltüntetés';
    $Self->{Translation}->{'Show'} = 'Megjelenítés';
    $Self->{Translation}->{'Basic information'} = 'Alap információk';
    $Self->{Translation}->{'Date/Time'} = 'Dátum/idő';

    # Template: AgentAppointmentEdit
    $Self->{Translation}->{'Please set this to value before End date.'} = 'Állítsa ezt egy befejezési dátum előtti értékre.';
    $Self->{Translation}->{'Please set this to value after Start date.'} = 'Állítsa ezt egy kezdési dátum utáni értékre.';
    $Self->{Translation}->{'This an occurrence of a repeating appointment.'} = 'Ez egy ismétlődő értekezlet előfordulása.';
    $Self->{Translation}->{'Click here to see the parent appointment.'} = 'Kattintson ide a szülő értekezlet megtekintéséhez.';
    $Self->{Translation}->{'Click here to edit the parent appointment.'} = 'Kattintson ide a szülő értekezlet szerkesztéséhez.';
    $Self->{Translation}->{'Frequency'} = 'Gyakoriság';
    $Self->{Translation}->{'Every'} = 'Minden';
    $Self->{Translation}->{'Relative point of time'} = 'Relatív időpont';
    $Self->{Translation}->{'Are you sure you want to delete this appointment? This operation cannot be undone.'} =
        'Biztosan törölni szeretné ezt az értekezletet? Ezt a műveletet nem lehet visszavonni.';

    # Template: AgentAppointmentImport
    $Self->{Translation}->{'Appointment Import'} = 'Értekezlet importálása';
    $Self->{Translation}->{'Uploaded file must be in valid iCal format (.ics).'} = 'A feltöltött fájlnak érvényes iCal formátumban (.ics) kell lennie.';
    $Self->{Translation}->{'If desired Calendar is not listed here, please make sure that you have at least \'create\' permissions.'} =
        'Ha a kívánt naptár nincs itt felsorolva, akkor győződjön meg arról, hogy van-e legalább „létrehozás” jogosultsága.';
    $Self->{Translation}->{'Update existing appointments?'} = 'Frissíti a meglévő értekezleteket?';
    $Self->{Translation}->{'All existing appointments in the calendar with same UniqueID will be overwritten.'} =
        'A naptárban lévő ilyen egyedi azonosítóval rendelkező összes meglévő értekezlet felül lesz írva.';
    $Self->{Translation}->{'Upload calendar'} = 'Naptár feltöltése';
    $Self->{Translation}->{'Import appointments'} = 'Értekezletek importálása';

    # Template: AgentDashboardAppointmentCalendar
    $Self->{Translation}->{'New Appointment'} = 'Új értekezlet';
    $Self->{Translation}->{'Soon'} = 'Hamarosan';
    $Self->{Translation}->{'5 days'} = '5 nap';

    # Perl Module: Kernel/Modules/AdminAppointmentNotificationEvent.pm
    $Self->{Translation}->{'Notification name already exists!'} = 'Az értesítés neve már létezik!';
    $Self->{Translation}->{'Agent (resources), who are selected within the appointment'} = 'Ügyintéző (erőforrások), aki az értekezleten belül ki lett jelölve';
    $Self->{Translation}->{'All agents with (at least) read permission for the appointment (calendar)'} =
        'Az összes ügyintéző, akiknek (legalább) olvasási jogosultságuk van az értekezlethez (naptárhoz)';
    $Self->{Translation}->{'All agents with write permission for the appointment (calendar)'} =
        'Az összes ügyintéző, akiknek írási jogosultságuk van az értekezlethez (naptárhoz)';

    # Perl Module: Kernel/Modules/AgentAppointmentCalendarManage.pm
    $Self->{Translation}->{'System was unable to create Calendar!'} = 'A rendszer nem tudta létrehozni a naptárat!';
    $Self->{Translation}->{'Please contact the administrator.'} = 'Vegye fel a kapcsolatot a rendszergazdával.';
    $Self->{Translation}->{'No CalendarID!'} = 'Nincs naptár-azonosító!';
    $Self->{Translation}->{'You have no access to this calendar!'} = 'Nincs hozzáférése ehhez a naptárhoz!';
    $Self->{Translation}->{'Edit Calendar'} = 'Naptár szerkesztése';
    $Self->{Translation}->{'Error updating the calendar!'} = 'Hiba a naptár frissítésekor!';
    $Self->{Translation}->{'Couldn\'t read calendar configuration file.'} = 'Nem sikerült beolvasni a naptárbeállító fájlt.';
    $Self->{Translation}->{'Please make sure your file is valid.'} = 'Győződjön meg arról, hogy a fájl érvényes-e.';
    $Self->{Translation}->{'Could not import the calendar!'} = 'Nem sikerült importálni a naptárat!';
    $Self->{Translation}->{'Calendar imported!'} = 'Naptár importálva!';
    $Self->{Translation}->{'Need CalendarID!'} = 'Naptár-azonosító szükséges!';
    $Self->{Translation}->{'Could not retrieve data for given CalendarID'} = 'Nem sikerült lekérni az adatokat a megadott naptár-azonosítóhoz';
    $Self->{Translation}->{'Successfully imported %s appointment(s) to calendar %s.'} = '%s értekezlet sikeresen importálva a(z) %s naptárba.';
    $Self->{Translation}->{'+5 minutes'} = '+5 perc';
    $Self->{Translation}->{'+15 minutes'} = '+15 perc';
    $Self->{Translation}->{'+30 minutes'} = '+30 perc';
    $Self->{Translation}->{'+1 hour'} = '+1 óra';

    # Perl Module: Kernel/Modules/AgentAppointmentCalendarOverview.pm
    $Self->{Translation}->{'All appointments'} = 'Minden értekezlet';
    $Self->{Translation}->{'Appointments assigned to me'} = 'Hozzám rendelt értekezletek';
    $Self->{Translation}->{'Showing only appointments assigned to you! Change settings'} = 'Csak az önhöz rendelt értekezletek vannak megjelenítve! Beállítások megváltoztatása';

    # Perl Module: Kernel/Modules/AgentAppointmentEdit.pm
    $Self->{Translation}->{'Appointment not found!'} = 'Az értekezlet nem található!';
    $Self->{Translation}->{'Never'} = 'Soha';
    $Self->{Translation}->{'Every Day'} = 'Minden nap';
    $Self->{Translation}->{'Every Week'} = 'Minden héten';
    $Self->{Translation}->{'Every Month'} = 'Minden hónapban';
    $Self->{Translation}->{'Every Year'} = 'Minden évben';
    $Self->{Translation}->{'Custom'} = 'Egyéni';
    $Self->{Translation}->{'Daily'} = 'Napi';
    $Self->{Translation}->{'Weekly'} = 'Heti';
    $Self->{Translation}->{'Monthly'} = 'Havi';
    $Self->{Translation}->{'Yearly'} = 'Éves';
    $Self->{Translation}->{'every'} = 'minden';
    $Self->{Translation}->{'for %s time(s)'} = '%s alkalommal';
    $Self->{Translation}->{'until ...'} = 'eddig: …';
    $Self->{Translation}->{'for ... time(s)'} = '… alkalommal';
    $Self->{Translation}->{'until %s'} = 'eddig: %s';
    $Self->{Translation}->{'No notification'} = 'Nincs értesítés';
    $Self->{Translation}->{'%s minute(s) before'} = '%s perccel előtte';
    $Self->{Translation}->{'%s hour(s) before'} = '%s órával előtte';
    $Self->{Translation}->{'%s day(s) before'} = '%s nappal előtte';
    $Self->{Translation}->{'%s week before'} = '%s héttel előtte';
    $Self->{Translation}->{'before the appointment starts'} = 'az értekezlet kezdete előtt';
    $Self->{Translation}->{'after the appointment has been started'} = 'miután az értekezlet elkezdődött';
    $Self->{Translation}->{'before the appointment ends'} = 'az értekezlet vége előtt';
    $Self->{Translation}->{'after the appointment has been ended'} = 'miután az értekezlet véget ért';
    $Self->{Translation}->{'No permission!'} = 'Nincs jogosultság!';
    $Self->{Translation}->{'Links could not be deleted!'} = 'A kapcsolatokat nem sikerült törölni!';
    $Self->{Translation}->{'Link could not be created!'} = 'A kapcsolatot nem sikerült létrehozni!';
    $Self->{Translation}->{'Cannot delete ticket appointment!'} = 'Nem lehet törölni a jegyértekezletet!';
    $Self->{Translation}->{'No permissions!'} = 'Nincsenek jogosultságok!';

    # Perl Module: Kernel/Modules/AgentAppointmentImport.pm
    $Self->{Translation}->{'No permissions'} = 'Nincsenek jogosultságok';
    $Self->{Translation}->{'System was unable to import file!'} = 'A rendszer nem tudta importálni a fájlt!';

    # Perl Module: Kernel/Modules/AgentAppointmentList.pm
    $Self->{Translation}->{'+%d more'} = 'további +%d';

    # Perl Module: Kernel/Modules/PublicCalendar.pm
    $Self->{Translation}->{'No %s!'} = 'Nincs %s!';
    $Self->{Translation}->{'No such user!'} = 'Nincs ilyen felhasználó!';
    $Self->{Translation}->{'Invalid calendar!'} = 'Érvénytelen naptár!';
    $Self->{Translation}->{'Invalid URL!'} = 'Érvénytelen URL!';
    $Self->{Translation}->{'There was an error exporting the calendar!'} = 'Hiba történt a naptár exportálásakor!';

    # Perl Module: Kernel/Output/HTML/Dashboard/AppointmentCalendar.pm
    $Self->{Translation}->{'Refresh (minutes)'} = 'Frissítés (perc)';

    # SysConfig
    $Self->{Translation}->{'Appointment Calendar overview page.'} = 'Értekezlet naptár áttekintő oldal.';
    $Self->{Translation}->{'Appointment Notifications'} = 'Értekezlet-értesítések';
    $Self->{Translation}->{'Appointment calendar event module that prepares notification entries for appointments.'} =
        'Értekezlet naptár esemény modul, amely előkészíti az értesítési bejegyzéseket az értekezletekhez.';
    $Self->{Translation}->{'Appointment calendar event module that updates the ticket with data from ticket appointment.'} =
        'Értekezlet naptár esemény modul, amely frissíti a jegyértekezletből származó adatokkal rendelkező jegyet.';
    $Self->{Translation}->{'Appointment edit screen.'} = 'Értekezlet-szerkesztés képernyő.';
    $Self->{Translation}->{'Appointment list'} = 'Értekezletlista';
    $Self->{Translation}->{'Appointment list.'} = 'Értekezletlista.';
    $Self->{Translation}->{'Appointment notifications'} = 'Értekezlet-értesítések';
    $Self->{Translation}->{'Appointments'} = 'Értekezletek';
    $Self->{Translation}->{'Calendar manage screen.'} = 'Naptárkezelés képernyő.';
    $Self->{Translation}->{'Choose for which kind of appointment changes you want to receive notifications.'} =
        'Válassza ki, hogy milyen típusú értekezlet-változtatásról szeretne értesítéseket kapni.';
    $Self->{Translation}->{'Create a new calendar appointment linked to this ticket'} = 'Ezzel a jeggyel összekapcsolt új naptár értekezlet létrehozása';
    $Self->{Translation}->{'Create and manage appointment notifications.'} = 'Értekezlet-értesítések létrehozása és kezelése.';
    $Self->{Translation}->{'Create new appointment.'} = 'Új értekezlet létrehozása.';
    $Self->{Translation}->{'Define which columns are shown in the linked appointment widget (LinkObject::ViewMode = "complex"). Possible settings: 0 = Disabled, 1 = Available, 2 = Enabled by default.'} =
        'Annak meghatározása, hogy mely oszlopok legyenek láthatók a kapcsolt értekezlet felületi elemen (LinkObject::ViewMode = „összetett”). Lehetséges beállítások: 0 = letiltva, 1 = elérhető, 2 = alapértelmezetten engedélyezett.';
    $Self->{Translation}->{'Defines an icon with link to the google map page of the current location in appointment edit screen.'} =
        'Meghatároz egy ikont a jelenlegi hely Google Térkép oldalára mutató hivatkozással az értekezlet-szerkesztés képernyőn.';
    $Self->{Translation}->{'Defines the event object types that will be handled via AdminAppointmentNotificationEvent.'} =
        'Meghatározza azokat az eseményobjektum típusokat, amelyek az AdminAppointmentNotificationEvent modulon keresztül lesznek kezelve.';
    $Self->{Translation}->{'Defines the list of params that can be passed to ticket search function.'} =
        'Meghatározza azoknak a paramétereknek a listáját, amelyek átadhatók a jegykeresés funkciónak.';
    $Self->{Translation}->{'Defines the ticket appointment type backend for ticket dynamic field date time.'} =
        'Meghatározza a jegyértekezlet típusának háttérprogramját a jegy dátum és idő dinamikus mezőjéhez.';
    $Self->{Translation}->{'Defines the ticket appointment type backend for ticket escalation time.'} =
        'Meghatározza a jegyértekezlet típusának háttérprogramját a jegy eszkalációs idejéhez.';
    $Self->{Translation}->{'Defines the ticket appointment type backend for ticket pending time.'} =
        'Meghatározza a jegyértekezlet típusának háttérprogramját a jegy függőben lévő idejéhez.';
    $Self->{Translation}->{'Defines the ticket plugin for calendar appointments.'} = 'Meghatározza a jegybővítményt a naptár értekezletekhez.';
    $Self->{Translation}->{'DynamicField_%s'} = 'DynamicField_%s';
    $Self->{Translation}->{'Edit appointment'} = 'Értekezlet szerkesztése';
    $Self->{Translation}->{'First response time'} = 'Első válaszidő';
    $Self->{Translation}->{'Import appointments screen.'} = 'Értekezletek importálása képernyő.';
    $Self->{Translation}->{'Links appointments and tickets with a "Normal" type link.'} = 'Összekapcsolja az értekezleteket és jegyeket egy „Normál” típusú hivatkozással.';
    $Self->{Translation}->{'List of all appointment events to be displayed in the GUI.'} = 'Az összes értekezlet esemény listája, amelyek megjelennek a grafikus felületen.';
    $Self->{Translation}->{'List of all calendar events to be displayed in the GUI.'} = 'Az összes naptáresemény listája, amelyek megjelennek a grafikus felületen.';
    $Self->{Translation}->{'List of colors in hexadecimal RGB which will be available for selection during calendar creation. Make sure the colors are dark enough so white text can be overlayed on them.'} =
        'Színek listája hexadecimális RGB formában, amelyek elérhetők lesznek a kiválasztáshoz a naptár létrehozása közben. Győződjön meg arról, hogy a színek elég sötétek-e ahhoz, hogy a világos szöveg megjeleníthető legyen rajtuk.';
    $Self->{Translation}->{'Manage different calendars.'} = 'Különböző naptárak kezelése.';
    $Self->{Translation}->{'Maximum number of active calendars in overview screens. Please note that large number of active calendars can have a performance impact on your server by making too much simultaneous calls.'} =
        'Az aktív naptárak legnagyobb száma az áttekintő képernyőkön. Ne feledje, hogy az aktív naptárak nagy száma teljesítménybeli hatással lehet a kiszolgálójára a túl sok egyidejű hívás indításával.';
    $Self->{Translation}->{'OTRS doesn\'t support recurring Appointments without end date or number of iterations. During import process, it might happen that ICS file contains such Appointments. Instead, system creates all Appointments in the past, plus Appointments for the next n months (120 months/10 years by default).'} =
        'Az OTRS nem támogatja a befejezési dátum vagy az ismétlések száma nélküli ismétlődő értekezleteket. Az importálási folyamat során előfordulhat, hogy az ICS-fájl ilyen értekezleteket tartalmaz. Ehelyett a rendszer az összes értekezletet a múltban hozza létre, valamint a következő n hónapban (120 hónap/10 év alapértelmezetten).';
    $Self->{Translation}->{'Overview of all appointments.'} = 'Az összes értekezlet áttekintője.';
    $Self->{Translation}->{'Pending time'} = 'Várakozási idő';
    $Self->{Translation}->{'Plugin search'} = 'Bővítmény keresés';
    $Self->{Translation}->{'Plugin search module for autocomplete.'} = 'Bővítmény keresési modul az automatikus kiegészítéshez.';
    $Self->{Translation}->{'Public Calendar'} = 'Nyilvános naptár';
    $Self->{Translation}->{'Public calendar.'} = 'Nyilvános naptár.';
    $Self->{Translation}->{'Resource Overview'} = 'Erőforrás áttekintő';
    $Self->{Translation}->{'Resource Overview (OTRS Business Solution™)'} = 'Erőforrás áttekintő (OTRS Business Solution™)';
    $Self->{Translation}->{'Shows a link in the menu for creating a calendar appointment linked to the ticket directly from the ticket zoom view of the agent interface. Additional access control to show or not show this link can be done by using Key "Group" and Content like "rw:group1;move_into:group2". To cluster menu items use for Key "ClusterName" and for the Content any name you want to see in the UI. Use "ClusterPriority" to configure the order of a certain cluster within the toolbar.'} =
        'Egy hivatkozást jelenít meg a menüben a jeggyel összekapcsolt naptár értekezlet létrehozásához közvetlenül az ügyintézői felület jegynagyítás nézetéből. Ezen hivatkozás megjelenítéséhez vagy meg nem jelenítéséhez további hozzáférési vezérlőt lehet készíteni a „Group” kulcs és az „rw:csoport1;move_into:csoport2” tartalomhoz hasonló használatával. A menüpontok csoportokba rendezéséhez használja a „ClusterName” kulcsot bármilyen olyan tartalommal, amelyet a felhasználói felületen látni szeretne. Használja a „ClusterPriority” kulcsot egy bizonyos fürt sorrendjének beállításához az eszköztáron belül.';
    $Self->{Translation}->{'Solution time'} = 'Megoldási idő';
    $Self->{Translation}->{'Transport selection for appointment notifications.'} = 'Átvitelkiválasztás az értekezlet-értesítésekhez.';
    $Self->{Translation}->{'Triggers add or update of automatic calendar appointments based on certain ticket times.'} =
        'Aktiválja az automatikus naptár értekezletek hozzáadását vagy frissítését bizonyos jegyidők alapján.';
    $Self->{Translation}->{'Update time'} = 'Frissítési idő';

}

1;
