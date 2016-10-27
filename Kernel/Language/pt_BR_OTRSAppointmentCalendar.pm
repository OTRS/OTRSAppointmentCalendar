# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::pt_BR_OTRSAppointmentCalendar;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    # Template: AdminAppointmentNotificationEvent
    $Self->{Translation}->{'Appointment Notification Management'} = 'Gerenciamento de notificação do compromisso';
    $Self->{Translation}->{'Here you can upload a configuration file to import appointment notifications to your system. The file needs to be in .yml format as exported by the appointment notification module.'} =
        'Aqui você pode fazer upload de um arquivo de configuração para importar notificações de compromisso para o seu sistema. O arquivo deve estar no formato .yml como exportado pelo módulo de notificação de compromisso.';
    $Self->{Translation}->{'Here you can choose which events will trigger this notification. An additional appointment filter can be applied below to only send for appointments with certain criteria.'} =
        'Aqui você pode escolher quais eventos irão acionar essa notificação. Um filtro de compromisso adicional pode ser aplicado abaixo para enviar apenas compromissos com determinados critérios.';
    $Self->{Translation}->{'Appointment Filter'} = 'Filtrar Compromisso';
    $Self->{Translation}->{'Team'} = 'Time';
    $Self->{Translation}->{'Resource'} = 'Recurso';
    $Self->{Translation}->{'Notify user just once per day about a single appointment using a selected transport.'} =
        'Notificar o usuário apenas uma vez por dia sobre um único compromisso usando um transporte selecionado.';
    $Self->{Translation}->{'Notifications are sent to an agent.'} = 'As notificações são enviadas a um agente.';
    $Self->{Translation}->{'To get the first 20 character of the appointment title.'} = 'Para obter os 20 primeiros caracteres do título do compromisso.';
    $Self->{Translation}->{'To get the appointment attribute'} = 'Para obter o atributo compromisso';
    $Self->{Translation}->{'To get the calendar attribute'} = 'Para obter o atributo calendário';

    # Template: AgentAppointmentAgendaOverview
    $Self->{Translation}->{'Agenda Overview'} = 'Visão geral da Agenda';
    $Self->{Translation}->{'Manage Calendars'} = 'Gerenciar Calendários';
    $Self->{Translation}->{'Add Appointment'} = 'Adicionar Compromisso';
    $Self->{Translation}->{'Color'} = 'Cor';
    $Self->{Translation}->{'End date'} = 'Data final';
    $Self->{Translation}->{'Repeat'} = 'Repetir';
    $Self->{Translation}->{'No calendars found. Please add a calendar first by using Manage Calendars page.'} =
        'Nenhum calendário encontrado. Por favor, primeiro adicione um calendário usando a página de Gerenciamento de Calendários.';
    $Self->{Translation}->{'Appointment'} = 'Compromisso';
    $Self->{Translation}->{'This is a repeating appointment'} = 'Este é um compromisso repetido';
    $Self->{Translation}->{'Would you like to edit just this occurrence or all occurrences?'} =
        'Você deseja editar apenas essa ocorrência ou todas as ocorrências?';
    $Self->{Translation}->{'All occurrences'} = 'Todas as ocorrências ';
    $Self->{Translation}->{'Just this occurrence'} = 'Apenas essa ocorrência';

    # Template: AgentAppointmentCalendarManage
    $Self->{Translation}->{'Calendar Management'} = 'Gerenciamento de Calendário';
    $Self->{Translation}->{'Calendar Overview'} = 'Visão geral de Calendário';
    $Self->{Translation}->{'Add new Calendar'} = 'Adicionar novo Calendário';
    $Self->{Translation}->{'Add Calendar'} = 'Adicionar Calendário';
    $Self->{Translation}->{'Import Appointments'} = 'Importar Compromissos';
    $Self->{Translation}->{'Calendar Import'} = 'Importar Calendário';
    $Self->{Translation}->{'Here you can upload a configuration file to import a calendar to your system. The file needs to be in .yml format as exported by calendar management module.'} =
        'Aqui você pode carregar um arquivo de configuração para importar um calendário para seu sistema. O arquivo precisa ser em .yml  como o exportado pelo módulo de gerenciamento de calendário.';
    $Self->{Translation}->{'Upload calendar configuration'} = 'Carregar configuração do calendário';
    $Self->{Translation}->{'Import Calendar'} = 'Importar Calendário';
    $Self->{Translation}->{'Filter for calendars'} = 'Filtro para calendários';
    $Self->{Translation}->{'Depending on the group field, the system will allow users the access to the calendar according to their permission level.'} =
        'Dependendo do campo grupo, o sistema liberará usuário para acessar o calendário de acordo com o nível de permissão deles.';
    $Self->{Translation}->{'Read only: users can see and export all appointments in the calendar.'} =
        'Apenas leitura: Usuários podem ver e exportar todas os compromissos nesse calendário.';
    $Self->{Translation}->{'Move into: users can modify appointments in the calendar, but without changing the calendar selection.'} =
        'Mover para: Usuário poderão modificar compromissos no calendário, mas sem alterar a seleção do calendário.';
    $Self->{Translation}->{'Create: users can create and delete appointments in the calendar.'} =
        'Criar: usuários podem criar e excluir compromissos no calendário.';
    $Self->{Translation}->{'Read/write: users can manage the calendar itself.'} = 'Leitura/escrita: os usuários podem gerenciar o próprio calendário.';
    $Self->{Translation}->{'URL'} = 'URL';
    $Self->{Translation}->{'Export calendar'} = 'Exportar calendário';
    $Self->{Translation}->{'Download calendar'} = 'Baixar calendário';
    $Self->{Translation}->{'Copy public calendar URL'} = 'Copiar URL publica do calendário';
    $Self->{Translation}->{'Calendar name'} = 'Nome do calendário';
    $Self->{Translation}->{'Calendar with same name already exists.'} = 'Calendário com mesmo nome já existe.';
    $Self->{Translation}->{'Permission group'} = 'Grupo de permissão';
    $Self->{Translation}->{'Ticket Appointments'} = 'Compromissos de chamado';
    $Self->{Translation}->{'Rule'} = 'Regra';
    $Self->{Translation}->{'Use options below to narrow down for which tickets appointments will be automatically created.'} =
        'Use as opções abaixo para diminuir quais compromissos de chamado serão criados automaticamente.';
    $Self->{Translation}->{'Please select a valid queue.'} = 'Por favor, selecione uma fila válida.';
    $Self->{Translation}->{'Search attributes'} = 'Atributos da pesquisa';
    $Self->{Translation}->{'Define rules for creating automatic appointments in this calendar based on ticket data.'} =
        'Definir regras para criação automática de compromissos neste calendário baseado em dados de chamado. ';
    $Self->{Translation}->{'Add Rule'} = 'Adicionar regra';
    $Self->{Translation}->{'More'} = 'Mais';
    $Self->{Translation}->{'Less'} = 'Menos';

    # Template: AgentAppointmentCalendarOverview
    $Self->{Translation}->{'Add new Appointment'} = 'Adicionar novo Compromisso';
    $Self->{Translation}->{'Calendars'} = 'Calendários';
    $Self->{Translation}->{'This is an overview page for the Appointment Calendar.'} = 'Esta página é uma de visão geral para o calendário de compromissos.';
    $Self->{Translation}->{'Too many active calendars'} = 'Muitos calendários ativos';
    $Self->{Translation}->{'Please either turn some off first or increase the limit in configuration.'} =
        'Por favor, desligue alguns primeiro ou aumente o limite na configuração.';
    $Self->{Translation}->{'Week'} = 'Semana';
    $Self->{Translation}->{'Timeline Month'} = 'Linha de tempo do mês';
    $Self->{Translation}->{'Timeline Week'} = 'Linha de tempo da semana';
    $Self->{Translation}->{'Timeline Day'} = 'Linha de tempo do dia';
    $Self->{Translation}->{'Jump'} = 'Pular';
    $Self->{Translation}->{'Dismiss'} = 'Recusar';
    $Self->{Translation}->{'Show'} = 'Mostrar';
    $Self->{Translation}->{'Basic information'} = 'Informação básica';
    $Self->{Translation}->{'Date/Time'} = 'Data/Hora';

    # Template: AgentAppointmentEdit
    $Self->{Translation}->{'Please set this to value before End date.'} = 'Por favor, configure o valor antes da data final.';
    $Self->{Translation}->{'Please set this to value after Start date.'} = 'Por favor, configure o valor antes da data inicial.';
    $Self->{Translation}->{'This an occurrence of a repeating appointment.'} = 'Esta uma ocorrência de um compromisso de repetição.';
    $Self->{Translation}->{'Click here to see the parent appointment.'} = 'Clique aqui para ver o compromisso pai.';
    $Self->{Translation}->{'Click here to edit the parent appointment.'} = 'Clique aqui para editar o compromisso pai.';
    $Self->{Translation}->{'Frequency'} = 'Frequência ';
    $Self->{Translation}->{'Every'} = 'Todos';
    $Self->{Translation}->{'Relative point of time'} = 'Ponto de tempo relativo';
    $Self->{Translation}->{'Are you sure you want to delete this appointment? This operation cannot be undone.'} =
        'Tem certeza que deseja remover esse compromisso? Essa operação não pode ser desfeita.';

    # Template: AgentAppointmentImport
    $Self->{Translation}->{'Appointment Import'} = 'Importação de compromissos';
    $Self->{Translation}->{'Uploaded file must be in valid iCal format (.ics).'} = 'O arquivo enviado deve estar no formato válido iCal (.ics).';
    $Self->{Translation}->{'If desired Calendar is not listed here, please make sure that you have at least \'create\' permissions.'} =
        'Se o Calendário desejado não estiver listado aqui, por favor certifique-se que você tenha, pelo menos permissões "Criar".';
    $Self->{Translation}->{'Update existing appointments?'} = 'Atualizar compromissos existentes?';
    $Self->{Translation}->{'All existing appointments in the calendar with same UniqueID will be overwritten.'} =
        'Todos os compromissos no calendário com o mesmo UniqueID serão sobrescrito.  ';
    $Self->{Translation}->{'Upload calendar'} = 'Carregar calendário';
    $Self->{Translation}->{'Import appointments'} = 'Importar compromissos';

    # Template: AgentDashboardAppointmentCalendar
    $Self->{Translation}->{'New Appointment'} = 'Novo Compromisso';
    $Self->{Translation}->{'Soon'} = 'Em breve';
    $Self->{Translation}->{'5 days'} = '5 dias';

    # Perl Module: Kernel/Modules/AdminAppointmentNotificationEvent.pm
    $Self->{Translation}->{'Notification name already exists!'} = 'Nome da notificação já existe!';
    $Self->{Translation}->{'Agent (resources), who are selected within the appointment'} = 'Atendente (recursos), que são selecionados dentro do compromisso';
    $Self->{Translation}->{'All agents with (at least) read permission for the appointment (calendar)'} =
        'Todos os agentes com (no mínimo) permissão de leitura do compromisso (calendário)';
    $Self->{Translation}->{'All agents with write permission for the appointment (calendar)'} =
        'Todos os atendentes com permissão de escrita no compromisso (calendário)';

    # Perl Module: Kernel/Modules/AgentAppointmentCalendarManage.pm
    $Self->{Translation}->{'System was unable to create Calendar!'} = 'Sistema não foi capaz de criar o Calendário!';
    $Self->{Translation}->{'Please contact the administrator.'} = 'Por favor, entre em contato com o administrador.';
    $Self->{Translation}->{'No CalendarID!'} = 'Nenhum CalendarID!';
    $Self->{Translation}->{'You have no access to this calendar!'} = 'Você não tem acesso a este calendário!';
    $Self->{Translation}->{'Edit Calendar'} = 'Editar Calendário';
    $Self->{Translation}->{'Error updating the calendar!'} = 'Erro ao atualizar o calendário!';
    $Self->{Translation}->{'Couldn\'t read calendar configuration file.'} = 'Não foi possível ler arquivo de configuração do calendário.';
    $Self->{Translation}->{'Please make sure your file is valid.'} = 'Por favor, verifique se o seu arquivo é válido.';
    $Self->{Translation}->{'Could not import the calendar!'} = 'Não foi possível importar o calendário!';
    $Self->{Translation}->{'Calendar imported!'} = 'Calendário importado!';
    $Self->{Translation}->{'Need CalendarID!'} = 'Necessário CalendarID!';
    $Self->{Translation}->{'Could not retrieve data for given CalendarID'} = 'Não foi possível obter dados para determinado CalendarID';
    $Self->{Translation}->{'Successfully imported %s appointment(s) to calendar %s.'} = 'Importado com sucesso %s compromisso(s) para o calendário %s.';
    $Self->{Translation}->{'+5 minutes'} = '+5 minutos';
    $Self->{Translation}->{'+15 minutes'} = '+15 minutos';
    $Self->{Translation}->{'+30 minutes'} = '+30 minutos';
    $Self->{Translation}->{'+1 hour'} = '+1 hora';

    # Perl Module: Kernel/Modules/AgentAppointmentCalendarOverview.pm
    $Self->{Translation}->{'All appointments'} = 'Todos os compromissos';
    $Self->{Translation}->{'Appointments assigned to me'} = 'Compromissos atribuídos a mim';
    $Self->{Translation}->{'Showing only appointments assigned to you! Change settings'} = 'Mostrar apenas compromissos assinados a você! Alterar configurações';

    # Perl Module: Kernel/Modules/AgentAppointmentEdit.pm
    $Self->{Translation}->{'Appointment not found!'} = 'Compromisso não encontrado!';
    $Self->{Translation}->{'Never'} = 'Nunca';
    $Self->{Translation}->{'Every Day'} = 'Todo dia';
    $Self->{Translation}->{'Every Week'} = 'Todo semana';
    $Self->{Translation}->{'Every Month'} = 'Todo Mês';
    $Self->{Translation}->{'Every Year'} = 'Todo Ano';
    $Self->{Translation}->{'Custom'} = 'Customizado';
    $Self->{Translation}->{'Daily'} = 'Diário';
    $Self->{Translation}->{'Weekly'} = 'Semanal';
    $Self->{Translation}->{'Monthly'} = 'Mensal';
    $Self->{Translation}->{'Yearly'} = 'Anual';
    $Self->{Translation}->{'every'} = 'todos';
    $Self->{Translation}->{'for %s time(s)'} = 'de %s tempo(s)';
    $Self->{Translation}->{'until ...'} = 'até ...';
    $Self->{Translation}->{'for ... time(s)'} = 'de ... tempo(s)';
    $Self->{Translation}->{'until %s'} = 'até %s';
    $Self->{Translation}->{'No notification'} = 'Nenhuma notificação';
    $Self->{Translation}->{'%s minute(s) before'} = '%s minuto(s) antes';
    $Self->{Translation}->{'%s hour(s) before'} = '%s hora(s) antes';
    $Self->{Translation}->{'%s day(s) before'} = '%s dia(s) antes';
    $Self->{Translation}->{'%s week before'} = '%s semana antes';
    $Self->{Translation}->{'before the appointment starts'} = 'antes do compromisso iniciar';
    $Self->{Translation}->{'after the appointment has been started'} = 'depois que o compromisso foi iniciado';
    $Self->{Translation}->{'before the appointment ends'} = 'antes do compromisso encerrar';
    $Self->{Translation}->{'after the appointment has been ended'} = 'depois que o compromisso foi encerrado';
    $Self->{Translation}->{'No permission!'} = 'Sem permissão!';
    $Self->{Translation}->{'Links could not be deleted!'} = 'Os links não pode ser apagado!';
    $Self->{Translation}->{'Link could not be created!'} = 'O Link não pode ser criado!';
    $Self->{Translation}->{'Cannot delete ticket appointment!'} = 'Não é possível excluir o compromisso do chamado.';
    $Self->{Translation}->{'No permissions!'} = 'Sem permissões!';

    # Perl Module: Kernel/Modules/AgentAppointmentImport.pm
    $Self->{Translation}->{'No permissions'} = 'Sem permissão';
    $Self->{Translation}->{'System was unable to import file!'} = 'Sistema não foi capaz de importar arquivo!';

    # Perl Module: Kernel/Modules/AgentAppointmentList.pm
    $Self->{Translation}->{'+%d more'} = '+%d mais';

    # Perl Module: Kernel/Modules/PublicCalendar.pm
    $Self->{Translation}->{'No %s!'} = 'Nenhum %s!';
    $Self->{Translation}->{'No such user!'} = 'Usuário não encontrado';
    $Self->{Translation}->{'Invalid calendar!'} = 'Calendário invalido!';
    $Self->{Translation}->{'Invalid URL!'} = 'URL inválida!';
    $Self->{Translation}->{'There was an error exporting the calendar!'} = 'Houve um erro ao exportar o calendário!';

    # Perl Module: Kernel/Output/HTML/Dashboard/AppointmentCalendar.pm
    $Self->{Translation}->{'Refresh (minutes)'} = 'Atualização (minutos)';

    # SysConfig
    $Self->{Translation}->{'Appointment Calendar overview page.'} = 'Página de visão geral de calendário de compromissos.';
    $Self->{Translation}->{'Appointment Notifications'} = 'Notificações de compromisso';
    $Self->{Translation}->{'Appointment calendar event module that prepares notification entries for appointments.'} =
        'Módulo de evento do calendário de compromissos que prepara a entrada de notificação para apontamentos.';
    $Self->{Translation}->{'Appointment calendar event module that updates the ticket with data from ticket appointment.'} =
        'Módulo de evento do calendário de compromissos que atualiza o chamado com dados do compromisso de chamado.';
    $Self->{Translation}->{'Appointment edit screen.'} = 'Tela de edição de compromisso.';
    $Self->{Translation}->{'Appointment list'} = 'Lista de compromissos';
    $Self->{Translation}->{'Appointment list.'} = 'Lista de compromissos.';
    $Self->{Translation}->{'Appointment notifications'} = 'Notificações de compromisso';
    $Self->{Translation}->{'Appointments'} = 'Compromissos';
    $Self->{Translation}->{'Calendar manage screen.'} = 'Tela de gerenciamento de calendário.';
    $Self->{Translation}->{'Choose for which kind of appointment changes you want to receive notifications.'} =
        'Escolha para a qual tipo de alterações no compromisso você deseja receber notificações.';
    $Self->{Translation}->{'Create a new calendar appointment linked to this ticket'} = 'Criar um novo compromisso de calendário associado a esse chamado';
    $Self->{Translation}->{'Create and manage appointment notifications.'} = 'Criar e gerenciar notificações de compromisso.';
    $Self->{Translation}->{'Create new appointment.'} = 'Criar novo compromisso.';
    $Self->{Translation}->{'Define which columns are shown in the linked appointment widget (LinkObject::ViewMode = "complex"). Possible settings: 0 = Disabled, 1 = Available, 2 = Enabled by default.'} =
        'Define quais colunas serão exibidas no widget de compromissos associados (LinkObject::ViewMode = "complex"). Configurações possíveis: 0 = Desabilitado , 1 = Disponível, 2 = Ativado por padrão.';
    $Self->{Translation}->{'Defines an icon with link to the google map page of the current location in appointment edit screen.'} =
        'Define um ícone com link para a página com mapa do google da localização atual na tela de edição de compromisso.';
    $Self->{Translation}->{'Defines the event object types that will be handled via AdminAppointmentNotificationEvent.'} =
        'Define os tipos de eventos de objetos que serão tratadas através de AdminAppointmentNotificationEvent.';
    $Self->{Translation}->{'Defines the list of params that can be passed to ticket search function.'} =
        'Define a lista de parâmetros que podem ser passados para a função de busca do ticket.';
    $Self->{Translation}->{'Defines the ticket appointment type backend for ticket dynamic field date time.'} =
        'Define o ticket appointment type backend para o ticket dynamic field date time.';
    $Self->{Translation}->{'Defines the ticket appointment type backend for ticket escalation time.'} =
        'Define o ticket appointment type backend para o ticket escalation time.';
    $Self->{Translation}->{'Defines the ticket appointment type backend for ticket pending time.'} =
        'Define o ticket appointment type backend para o ticket pending time.';
    $Self->{Translation}->{'Defines the ticket plugin for calendar appointments.'} = 'Define o plugin do ticket para compromissos do calendário.';
    $Self->{Translation}->{'DynamicField_%s'} = 'DynamicField_%s';
    $Self->{Translation}->{'Edit appointment'} = 'Editar compromisso';
    $Self->{Translation}->{'First response time'} = 'Tempo de primeira resposta';
    $Self->{Translation}->{'Import appointments screen.'} = 'Tela de importação de compromissos';
    $Self->{Translation}->{'Links appointments and tickets with a "Normal" type link.'} = 'Associar compromissos e chamados como uma tipo "Normal".';
    $Self->{Translation}->{'List of all appointment events to be displayed in the GUI.'} = 'Lista de todos os eventos de compromisso que serão exibido na GUI.';
    $Self->{Translation}->{'List of all calendar events to be displayed in the GUI.'} = 'Lista de todos os eventos do calendário a ser exibido na GUI.';
    $Self->{Translation}->{'List of colors in hexadecimal RGB which will be available for selection during calendar creation. Make sure the colors are dark enough so white text can be overlayed on them.'} =
        'Lista de cores em RGB hexadecimal que estarão disponíveis para seleção durante a criação do calendário. Certifique-se de as cores são escuras o suficiente, texto brancas podem ser sobrepostos. ';
    $Self->{Translation}->{'Manage different calendars.'} = 'Gerenciar calendário diferentes.';
    $Self->{Translation}->{'Maximum number of active calendars in overview screens. Please note that large number of active calendars can have a performance impact on your server by making too much simultaneous calls.'} =
        'Número máximo de calendário ativos nas visões gerais. Por favor, note que um numero grande de calendário ativos você poderá ter impactos na performance do servidor devido a muitas chamadas simultâneas.';
    $Self->{Translation}->{'OTRS doesn\'t support recurring Appointments without end date or number of iterations. During import process, it might happen that ICS file contains such Appointments. Instead, system creates all Appointments in the past, plus Appointments for the next n months (120 months/10 years by default).'} =
        'O OTRS não suporta compromissos recorrentes, sem data de término ou o número de iterações. Durante o processo de importação, pode acontecer do arquivo ICS, conter esses compromissos. Em vez disso, o sistema cria todos os compromissos no passado, além de compromissos para os próximos n meses (120 meses/10 anos por padrão).';
    $Self->{Translation}->{'Overview of all appointments.'} = 'Visão geral de todos os compromissos.';
    $Self->{Translation}->{'Pending time'} = 'Data de pendência';
    $Self->{Translation}->{'Plugin search'} = 'Pesquisar Plugin';
    $Self->{Translation}->{'Plugin search module for autocomplete.'} = 'Módulo de pesquisa de autocompletar.';
    $Self->{Translation}->{'Public Calendar'} = 'Calendário público';
    $Self->{Translation}->{'Public calendar.'} = 'Calendário público';
    $Self->{Translation}->{'Resource Overview'} = 'Visão geral de recursos';
    $Self->{Translation}->{'Resource Overview (OTRS Business Solution™)'} = 'Visão geral de recurso (OTRS Business Solution™)';
    $Self->{Translation}->{'Shows a link in the menu for creating a calendar appointment linked to the ticket directly from the ticket zoom view of the agent interface. Additional access control to show or not show this link can be done by using Key "Group" and Content like "rw:group1;move_into:group2". To cluster menu items use for Key "ClusterName" and for the Content any name you want to see in the UI. Use "ClusterPriority" to configure the order of a certain cluster within the toolbar.'} =
        'Mostra um link no menu para criar um compromisso de calendário vinculado ao chamado na visão ticket zoom na interface do atendente. Controle de acesso adicional para mostrar ou não o vínculo pode ser feito usando a chave "Group" e o conteúdo como "rw:group1;move_into:group2". Para agrupar itens de menu use a chave "ClusterName" e para o conteúdo qualquer nome que deseje ver na interface do usuário. Use "ClusterPriority" para configurar a ordem de um determinado conjunto dentro do toolbar.';
    $Self->{Translation}->{'Solution time'} = 'Tempo de solução';
    $Self->{Translation}->{'Transport selection for appointment notifications.'} = 'Seleção de transporte para notificações de compromisso.';
    $Self->{Translation}->{'Triggers add or update of automatic calendar appointments based on certain ticket times.'} =
        'Dispara adição ou atualização de compromissos do calendário automático com base em determinados tempos do ticket.';
    $Self->{Translation}->{'Update time'} = 'Tempo de atualização';

}

1;
