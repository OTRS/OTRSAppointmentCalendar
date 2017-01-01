# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::es_CO_OTRSAppointmentCalendar;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    # Template: AAANotification
    $Self->{Translation}->{'Appointment reminder notification'} = '';
    $Self->{Translation}->{'You will receive a notification each time a reminder time is reached for one of your appointments.'} =
        '';

    # Template: AdminAppointmentNotificationEvent
    $Self->{Translation}->{'Appointment Notification Management'} = 'Gestión de Notificaciones de Citas';
    $Self->{Translation}->{'Here you can upload a configuration file to import appointment notifications to your system. The file needs to be in .yml format as exported by the appointment notification module.'} =
        'Aquí es posible cargar un archivo de configuración para importar las notificaciones de las citas a su sistema. El archivo necesita estar en el formato .yml como los exportados por el módulo de notificaciones de citas.';
    $Self->{Translation}->{'Here you can choose which events will trigger this notification. An additional appointment filter can be applied below to only send for appointments with certain criteria.'} =
        'Aquí es posible elegir los eventos que iniciarán esta notificación. Un filtro adicional de la cita se puede aplicar a continuación para enviar sólo para citas con ciertos criterios.';
    $Self->{Translation}->{'Appointment Filter'} = 'Filtro de citas';
    $Self->{Translation}->{'Team'} = 'Equipo';
    $Self->{Translation}->{'Resource'} = 'Recurso';
    $Self->{Translation}->{'Notify user just once per day about a single appointment using a selected transport.'} =
        'Notificar al usuario solo una vez al día acerca de una sola cita usando el transporte seleccionado.';
    $Self->{Translation}->{'Notifications are sent to an agent.'} = 'Las notificaciones se envían a un agente.';
    $Self->{Translation}->{'To get the first 20 character of the appointment title.'} = 'Para obtener los primeros 20 caracteres del título de la cita';
    $Self->{Translation}->{'To get the appointment attribute'} = 'Para obtener el atributo de la cita';
    $Self->{Translation}->{'To get the calendar attribute'} = 'Para obtener el atributo del calendario';

    # Template: AgentAppointmentAgendaOverview
    $Self->{Translation}->{'Agenda Overview'} = 'Resumen de la Agenda';
    $Self->{Translation}->{'Manage Calendars'} = 'Gestionar Calendarios';
    $Self->{Translation}->{'Add Appointment'} = 'Añadir Cita';
    $Self->{Translation}->{'Color'} = 'Color';
    $Self->{Translation}->{'End date'} = 'Fecha de término';
    $Self->{Translation}->{'Repeat'} = 'Repetición';
    $Self->{Translation}->{'No calendars found. Please add a calendar first by using Manage Calendars page.'} =
        'No se encontraron calendario. Por favor primero añada un calendario utilizado la pagina de Gestionar Calendarios.';
    $Self->{Translation}->{'Appointment'} = 'Cita';
    $Self->{Translation}->{'This is a repeating appointment'} = 'Esta es una cita repetitiva';
    $Self->{Translation}->{'Would you like to edit just this occurrence or all occurrences?'} =
        'Desea editar solo esta o todas las ocurrencias';
    $Self->{Translation}->{'All occurrences'} = 'Todas las ocurrencias';
    $Self->{Translation}->{'Just this occurrence'} = 'Solo esta';

    # Template: AgentAppointmentCalendarManage
    $Self->{Translation}->{'Calendar Management'} = 'Gestión de Calendarios';
    $Self->{Translation}->{'Calendar Overview'} = 'Resumen de Calendarios';
    $Self->{Translation}->{'Add new Calendar'} = 'Añadir un Calendario nuevo';
    $Self->{Translation}->{'Add Calendar'} = 'Añadir Calendario';
    $Self->{Translation}->{'Import Appointments'} = 'Importar Citas';
    $Self->{Translation}->{'Calendar Import'} = 'Importar Calendario';
    $Self->{Translation}->{'Here you can upload a configuration file to import a calendar to your system. The file needs to be in .yml format as exported by calendar management module.'} =
        'Aquí es posible cargar un archivo de configuración para importar un calendario a su sistema. El archivo necesita estar en el formato .yml para poder ser exportado por el módulo de gestión de calendarios.';
    $Self->{Translation}->{'Upload calendar configuration'} = 'Cargar configuración de calendario';
    $Self->{Translation}->{'Import Calendar'} = 'Importar Calendario';
    $Self->{Translation}->{'Filter for calendars'} = 'Filtro para Calendarios';
    $Self->{Translation}->{'Depending on the group field, the system will allow users the access to the calendar according to their permission level.'} =
        'Dependiendo del campo de grupo, el sistema permite el acceso a usuarios al calendario de acuerdo a sus niveles de permisos.';
    $Self->{Translation}->{'Read only: users can see and export all appointments in the calendar.'} =
        'RO: usuarios que pueden ver y exportar todas las citas en el calendario.';
    $Self->{Translation}->{'Move into: users can modify appointments in the calendar, but without changing the calendar selection.'} =
        'Mover_A: usuarios que pueden modificar citas en el calendario, pero sin cambiar la selección de calendario.';
    $Self->{Translation}->{'Create: users can create and delete appointments in the calendar.'} =
        'Crear: usuarios que pueden crear y borrar citas en el calendario.';
    $Self->{Translation}->{'Read/write: users can manage the calendar itself.'} = 'RW: usuario que pueden gestionar el calendario en sí';
    $Self->{Translation}->{'URL'} = 'URL';
    $Self->{Translation}->{'Export calendar'} = 'Exportar calendario';
    $Self->{Translation}->{'Download calendar'} = 'Descargar calendario';
    $Self->{Translation}->{'Copy public calendar URL'} = 'Copiar URL pública de calendario';
    $Self->{Translation}->{'Calendar name'} = 'Nombre del calendario';
    $Self->{Translation}->{'Calendar with same name already exists.'} = 'Ya existe un calendario con el mismo nombre.';
    $Self->{Translation}->{'Permission group'} = 'Grupo de permisos';
    $Self->{Translation}->{'Ticket Appointments'} = 'Citas de Ticket';
    $Self->{Translation}->{'Rule'} = 'Regla';
    $Self->{Translation}->{'Use options below to narrow down for which tickets appointments will be automatically created.'} =
        'Use las opciones mostradas abajo para acortar las citas de tickets serán creadas automáticamente.';
    $Self->{Translation}->{'Please select a valid queue.'} = 'Poor favor seleccione una fila válida';
    $Self->{Translation}->{'Search attributes'} = 'Atributos de búsqueda';
    $Self->{Translation}->{'Define rules for creating automatic appointments in this calendar based on ticket data.'} =
        'Define reglas para creación de citas automáticas en este calendario basadas en los datos de los tickets.';
    $Self->{Translation}->{'Add Rule'} = 'Añadir regla';
    $Self->{Translation}->{'More'} = 'Más';
    $Self->{Translation}->{'Less'} = 'Menos';

    # Template: AgentAppointmentCalendarOverview
    $Self->{Translation}->{'Add new Appointment'} = 'Añadir nueva cita';
    $Self->{Translation}->{'Calendars'} = 'Calendarios';
    $Self->{Translation}->{'This is an overview page for the Appointment Calendar.'} = 'Esta es una página de resumen para el Calendario de Citas';
    $Self->{Translation}->{'Too many active calendars'} = 'Demasiados calendarios activos';
    $Self->{Translation}->{'Please either turn some off first or increase the limit in configuration.'} =
        'Por favor desactive algunos primero o incremente el límite en la configuración';
    $Self->{Translation}->{'Week'} = 'Semana';
    $Self->{Translation}->{'Timeline Month'} = 'Línea de tiempo Mensual';
    $Self->{Translation}->{'Timeline Week'} = 'Línea de tiempo Semanal';
    $Self->{Translation}->{'Timeline Day'} = 'Línea de tiempo Diaria';
    $Self->{Translation}->{'Jump'} = 'Saltar a';
    $Self->{Translation}->{'Dismiss'} = 'Descartar';
    $Self->{Translation}->{'Show'} = 'Mostrar';
    $Self->{Translation}->{'Basic information'} = 'Información básica';
    $Self->{Translation}->{'Date/Time'} = 'Fecha/Hora';

    # Template: AgentAppointmentEdit
    $Self->{Translation}->{'Please set this to value before End date.'} = 'Por favor fije este valor antes de la fecha de término.';
    $Self->{Translation}->{'Please set this to value after Start date.'} = 'Por favor fije este valor después de la fecha de inicio';
    $Self->{Translation}->{'This an occurrence of a repeating appointment.'} = 'Esta es una ocurrencia de una cita repetitiva.';
    $Self->{Translation}->{'Click here to see the parent appointment.'} = 'Precione aquí  para ver la cita padre.';
    $Self->{Translation}->{'Click here to edit the parent appointment.'} = 'Precione aquí  para editar la cita padre.';
    $Self->{Translation}->{'Frequency'} = 'Frecuencia';
    $Self->{Translation}->{'Every'} = 'Cada';
    $Self->{Translation}->{'Relative point of time'} = 'Punto de tiempo relativo.';
    $Self->{Translation}->{'Are you sure you want to delete this appointment? This operation cannot be undone.'} =
        '¿Está seguro de que desea eliminar esta cita? Esta operación no se puede deshacer.';

    # Template: AgentAppointmentImport
    $Self->{Translation}->{'Appointment Import'} = 'Importar Cita';
    $Self->{Translation}->{'Uploaded file must be in valid iCal format (.ics).'} = 'El archivo cargado tiene que estar en un formato iCal válido (.ics)';
    $Self->{Translation}->{'If desired Calendar is not listed here, please make sure that you have at least \'create\' permissions.'} =
        'Si el Calendario deseado no aparece en la lista, por favor asegúrese de que tenga al menos el permiso de "crear"';
    $Self->{Translation}->{'Update existing appointments?'} = '¿Actualizar las citas existentes?';
    $Self->{Translation}->{'All existing appointments in the calendar with same UniqueID will be overwritten.'} =
        'Todas las citas existentes en el calendario con el mismo UniqueID se sobrescribirán';
    $Self->{Translation}->{'Upload calendar'} = 'Cargar calendario';
    $Self->{Translation}->{'Import appointments'} = 'Importar citas';

    # Template: AgentDashboardAppointmentCalendar
    $Self->{Translation}->{'New Appointment'} = 'Nueva Cita';
    $Self->{Translation}->{'Soon'} = 'Pronto';
    $Self->{Translation}->{'5 days'} = '5 días';

    # Perl Module: Kernel/Modules/AdminAppointmentNotificationEvent.pm
    $Self->{Translation}->{'Notification name already exists!'} = 'El nombre de la notificación ya existe!';
    $Self->{Translation}->{'Agent (resources), who are selected within the appointment'} = 'Agentes (recursos), que pueden ser seleccionados dentro de una cita';
    $Self->{Translation}->{'All agents with (at least) read permission for the appointment (calendar)'} =
        'Agentes con (al menos) permisos de lectura para la cita (calendario)';
    $Self->{Translation}->{'All agents with write permission for the appointment (calendar)'} =
        'Todos los agentes con permisos de escritura para la cita (calendario)';

    # Perl Module: Kernel/Modules/AgentAppointmentCalendarManage.pm
    $Self->{Translation}->{'System was unable to create Calendar!'} = 'El sistema no pudo crear el Calendario!';
    $Self->{Translation}->{'No CalendarID!'} = 'No se tiene el CalendarID!';
    $Self->{Translation}->{'You have no access to this calendar!'} = 'No tiene acceso a este calendario!';
    $Self->{Translation}->{'Edit Calendar'} = 'Editar Calendario';
    $Self->{Translation}->{'Error updating the calendar!'} = 'Error al actualizer el calendario!';
    $Self->{Translation}->{'Couldn\'t read calendar configuration file.'} = 'No se puede leer el archivo de configuración del calendario.';
    $Self->{Translation}->{'Please make sure your file is valid.'} = 'Por favor asegúrese de que el archivo es válido.';
    $Self->{Translation}->{'Could not import the calendar!'} = 'No se puede importar el calendario!';
    $Self->{Translation}->{'Calendar imported!'} = 'Calendario importado!';
    $Self->{Translation}->{'Need CalendarID!'} = 'Se necesita CalendarID!';
    $Self->{Translation}->{'Could not retrieve data for given CalendarID'} = 'Not se pueden obtener los datos para el CalendarID especificado';
    $Self->{Translation}->{'Successfully imported %s appointment(s) to calendar %s.'} = 'Se han importado %s cita(s) al calendario %s.';
    $Self->{Translation}->{'+5 minutes'} = '+5 minutos';
    $Self->{Translation}->{'+15 minutes'} = '+15 minutos ';
    $Self->{Translation}->{'+30 minutes'} = '+30 minutos';
    $Self->{Translation}->{'+1 hour'} = '+1 hora';

    # Perl Module: Kernel/Modules/AgentAppointmentCalendarOverview.pm
    $Self->{Translation}->{'All appointments'} = 'Todas las citas';
    $Self->{Translation}->{'Appointments assigned to me'} = 'Citas asignadas a mí ';
    $Self->{Translation}->{'Showing only appointments assigned to you! Change settings'} = 'Mostrando solo citas asignadas a tí! Cambiar configuración';

    # Perl Module: Kernel/Modules/AgentAppointmentEdit.pm
    $Self->{Translation}->{'Appointment not found!'} = 'La cita no fue encontrada!';
    $Self->{Translation}->{'Never'} = 'Nunca';
    $Self->{Translation}->{'Every Day'} = 'Cada Día';
    $Self->{Translation}->{'Every Week'} = 'Cada Semana';
    $Self->{Translation}->{'Every Month'} = 'Cada Mes';
    $Self->{Translation}->{'Every Year'} = 'Cada Año';
    $Self->{Translation}->{'Custom'} = 'Personalizado';
    $Self->{Translation}->{'Daily'} = 'Diario';
    $Self->{Translation}->{'Weekly'} = 'Semanal';
    $Self->{Translation}->{'Monthly'} = 'Mensual';
    $Self->{Translation}->{'Yearly'} = 'Anual';
    $Self->{Translation}->{'every'} = 'cada';
    $Self->{Translation}->{'for %s time(s)'} = 'por %s vez(ces)';
    $Self->{Translation}->{'until ...'} = 'hasta ...';
    $Self->{Translation}->{'for ... time(s)'} = 'por ... vez(ces)';
    $Self->{Translation}->{'until %s'} = 'hasta %s';
    $Self->{Translation}->{'No notification'} = 'Sin notificaciones';
    $Self->{Translation}->{'%s minute(s) before'} = '%s minuto(s) antes';
    $Self->{Translation}->{'%s hour(s) before'} = '%s hora(s) antes';
    $Self->{Translation}->{'%s day(s) before'} = '%s día(s) antes';
    $Self->{Translation}->{'%s week before'} = '%s semanas antes';
    $Self->{Translation}->{'before the appointment starts'} = 'antes de que la cita inicie';
    $Self->{Translation}->{'after the appointment has been started'} = 'después de que la cita halla iniciado';
    $Self->{Translation}->{'before the appointment ends'} = 'antes de que termine la cita';
    $Self->{Translation}->{'after the appointment has been ended'} = 'después de que la cita halla finalizado';
    $Self->{Translation}->{'No permission!'} = 'No tiene permisos!';
    $Self->{Translation}->{'Links could not be deleted!'} = 'Los vínculos no pudieron ser borrados!';
    $Self->{Translation}->{'Link could not be created!'} = 'El vínculo no pudo ser borrado!';
    $Self->{Translation}->{'Cannot delete ticket appointment!'} = 'La cita no puede ser borrada!';
    $Self->{Translation}->{'No permissions!'} = 'No tiene permisos!';

    # Perl Module: Kernel/Modules/AgentAppointmentImport.pm
    $Self->{Translation}->{'No permissions'} = 'No tiene permisos';
    $Self->{Translation}->{'System was unable to import file!'} = 'El sistema no pudo importar el archivo!';
    $Self->{Translation}->{'Please check the log for more information.'} = '';

    # Perl Module: Kernel/Modules/AgentAppointmentList.pm
    $Self->{Translation}->{'+%d more'} = '+%d más';

    # Perl Module: Kernel/Modules/PublicCalendar.pm
    $Self->{Translation}->{'No %s!'} = 'No se tiene %s!';
    $Self->{Translation}->{'No such user!'} = 'No existe el usuario!';
    $Self->{Translation}->{'Invalid calendar!'} = 'Calendario inválido';
    $Self->{Translation}->{'Invalid URL!'} = 'URL inválido!';
    $Self->{Translation}->{'There was an error exporting the calendar!'} = 'Se produjo un error al exportar el calendario!';

    # Perl Module: Kernel/Output/HTML/Dashboard/AppointmentCalendar.pm
    $Self->{Translation}->{'Refresh (minutes)'} = 'Actualization (minutos)';

    # SysConfig
    $Self->{Translation}->{'Appointment Calendar overview page.'} = 'Página de resumen del Calendario de Citas';
    $Self->{Translation}->{'Appointment Notifications'} = 'Notificaciones de Citas';
    $Self->{Translation}->{'Appointment calendar event module that prepares notification entries for appointments.'} =
        'Módulo de eventos del calendario de citas que prepara entradas para citas.';
    $Self->{Translation}->{'Appointment calendar event module that updates the ticket with data from ticket appointment.'} =
        'Módulo de eventos de calendario que actualiza los datos del ticket desde una cita de ticket.';
    $Self->{Translation}->{'Appointment edit screen.'} = 'Pantalla de edición de citas.';
    $Self->{Translation}->{'Appointment list'} = 'Lista de citas';
    $Self->{Translation}->{'Appointment list.'} = 'Lista de citas.';
    $Self->{Translation}->{'Appointment notifications'} = 'Notificaciones de citas';
    $Self->{Translation}->{'Appointments'} = 'Citas';
    $Self->{Translation}->{'Calendar manage screen.'} = 'Pantalla de gestión de Calendarios';
    $Self->{Translation}->{'Choose for which kind of appointment changes you want to receive notifications.'} =
        'Elija el tipo de cambios en las citas par las cuales desea recibir notificaciones.';
    $Self->{Translation}->{'Create a new calendar appointment linked to this ticket'} = 'Crear una nueva cita de calendario vinculada a este ticket';
    $Self->{Translation}->{'Create and manage appointment notifications.'} = 'Crear y gestionar notificaciones de citas.';
    $Self->{Translation}->{'Create new appointment.'} = 'Crear nueva cita.';
    $Self->{Translation}->{'Define which columns are shown in the linked appointment widget (LinkObject::ViewMode = "complex"). Possible settings: 0 = Disabled, 1 = Available, 2 = Enabled by default.'} =
        'Define cuales columnas serán mostradas en widget de citas vinculadas (LinkObject::ViewMode = "compleja"). Posibles ajustes: 0 = Deshabitada, 1 = Habilitada, 2 = Habilitada por omisión.';
    $Self->{Translation}->{'Defines an icon with link to the google map page of the current location in appointment edit screen.'} =
        'Define un icono de vínculo a la pagina de google map de la ubicación actual en la pantalla de edición de citas.';
    $Self->{Translation}->{'Defines the event object types that will be handled via AdminAppointmentNotificationEvent.'} =
        'Define los tipos de objeto de evento que se manejan a través del AdminAppointmentNotificationEvent.';
    $Self->{Translation}->{'Defines the list of params that can be passed to ticket search function.'} =
        'Define la lista de parámetros que pueden ser enviados a la función de búsqueda de tickets';
    $Self->{Translation}->{'Defines the ticket appointment type backend for ticket dynamic field date time.'} =
        'Define el tipo de backed de cita de ticket para campos dinámicos de ticket de tipo fecha y hora';
    $Self->{Translation}->{'Defines the ticket appointment type backend for ticket escalation time.'} =
        'Define el tipo de backed de cita de ticket para el tiempo de escalamiento de ticket';
    $Self->{Translation}->{'Defines the ticket appointment type backend for ticket pending time.'} =
        'Define el tipo de backed de cita de ticket para el tiempo de espera de ticket';
    $Self->{Translation}->{'Defines the ticket plugin for calendar appointments.'} = 'Define el plugin de ticket para las citas de calendario.';
    $Self->{Translation}->{'DynamicField_%s'} = 'CampoDinámico_%s';
    $Self->{Translation}->{'Edit appointment'} = 'Editar cita';
    $Self->{Translation}->{'First response time'} = 'Tiempo de primera respuesta';
    $Self->{Translation}->{'Import appointments screen.'} = 'Pantalla de importación de citas.';
    $Self->{Translation}->{'Links appointments and tickets with a "Normal" type link.'} = 'Vincular citas y tickets con el tipo de vínculo "Normal".';
    $Self->{Translation}->{'List of all appointment events to be displayed in the GUI.'} = 'Lista de todos los eventos de citas que son desplegaos en la GUI.';
    $Self->{Translation}->{'List of all calendar events to be displayed in the GUI.'} = 'Lista de todos los eventos de calendario que son desplegados en la GUI.';
    $Self->{Translation}->{'List of colors in hexadecimal RGB which will be available for selection during calendar creation. Make sure the colors are dark enough so white text can be overlayed on them.'} =
        'Lista de colores en hexadecimal RGB que estarán disponibles para su selección durante la creación de calendarios. Asegúrese que los colores sean suficientemente obscuros para que el texto banco se vea correctamente sobre ellos.';
    $Self->{Translation}->{'Manage different calendars.'} = 'Gestionar diferentes calendarios.';
    $Self->{Translation}->{'Maximum number of active calendars in overview screens. Please note that large number of active calendars can have a performance impact on your server by making too much simultaneous calls.'} =
        'Numero máximo de calendarios activos en las pantallas de resumen. Por favor note que un numero grande de calendarios activos puede tener un impacto negativo en el desempeño del servidor debido a una gran cantidad de llamadas simultáneas.';
    $Self->{Translation}->{'OTRS doesn\'t support recurring Appointments without end date or number of iterations. During import process, it might happen that ICS file contains such Appointments. Instead, system creates all Appointments in the past, plus Appointments for the next n months (120 months/10 years by default).'} =
        'OTRS no admite citas recurrentes sin fecha de finalización o sin número de iteraciones. Durante el proceso de importación, puede ocurrir que el archivo ICS contenga dichas citas. En su lugar, el sistema crea todas las citas en el pasado, además de citas para los próximos n meses (120 meses / 10 años por defecto).';
    $Self->{Translation}->{'Overview of all appointments.'} = 'Resumen de todas las citas';
    $Self->{Translation}->{'Pending time'} = 'Tiempo de espera';
    $Self->{Translation}->{'Plugin search'} = 'Búsqueda de plug-ins';
    $Self->{Translation}->{'Plugin search module for autocomplete.'} = 'Módulo Plug-in de búsqueda para auto-completar.';
    $Self->{Translation}->{'Public Calendar'} = 'Calendario Púplico';
    $Self->{Translation}->{'Public calendar.'} = 'Calendario público.';
    $Self->{Translation}->{'Resource Overview'} = 'Resumen de Recursos';
    $Self->{Translation}->{'Resource Overview (OTRS Business Solution™)'} = 'Resumen de Recursos (OTRS Business Solution™)';
    $Self->{Translation}->{'Shows a link in the menu for creating a calendar appointment linked to the ticket directly from the ticket zoom view of the agent interface. Additional access control to show or not show this link can be done by using Key "Group" and Content like "rw:group1;move_into:group2". To cluster menu items use for Key "ClusterName" and for the Content any name you want to see in the UI. Use "ClusterPriority" to configure the order of a certain cluster within the toolbar.'} =
        'Muestra un vínculo en el menú para crear una cita de calendario vinculada al ticket directo desde  la vista de detalle de ticket de la interface del agente. Adicionalmente se puede hacer in control de acceso para mostrar o no este vínculo usando la Clave "Group" y el Contenido como "rw:group1;move_into:group2". Para agrupar elemento del menú use la Clave "ClusterName" para el Contenido cualquier nombre que desee ver en la interface del usuario. Utilize "ClusterPriority" para configurar el orden de un cierto grupo dentro de la barra de herramientas.';
    $Self->{Translation}->{'Solution time'} = 'Tiempo de Solución';
    $Self->{Translation}->{'Transport selection for appointment notifications.'} = 'Selection de transporte para notificaciones de citas.';
    $Self->{Translation}->{'Triggers add or update of automatic calendar appointments based on certain ticket times.'} =
        'Dispara la acción de añadir o actualizar citas automáticas de calendarios basadas en ciertos tiempos de tickets.';
    $Self->{Translation}->{'Update time'} = 'Tiempo de Actualización';

}

1;
