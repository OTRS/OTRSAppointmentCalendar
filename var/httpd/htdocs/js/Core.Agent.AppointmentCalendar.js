// --
// Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
// --
// This software comes with ABSOLUTELY NO WARRANTY. For details, see
// the enclosed file COPYING for license information (AGPL). If you
// did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
// --

"use strict";

var Core = Core || {};
Core.Agent = Core.Agent || {};

/**
 * @namespace Core.Agent.AppointmentCalendar
 * @memberof Core.Agent
 * @author OTRS AG
 * @description
 *      This namespace contains the appointment calendar functions.
 */
Core.Agent.AppointmentCalendar = (function (TargetNS) {

    /**
     * @name Init
     * @memberof Core.Agent.AppointmentCalendar
     * @param {Object} Params - Hash with different config options.
     * @param {Array} Params.MonthNames - Array containing the localized strings for each month.
     * @param {Array} Params.MonthNamesShort - Array containing the localized strings for each month on shorth format.
     * @param {Array} Params.DayNames - Array containing the localized strings for each week day.
     * @param {Array} Params.DayNamesShort - Array containing the localized strings for each week day on short format.
     * @param {Array} Params.ButtonText - Array containing the localized strings for each week day on short format.
     * @param {String} Params.ButtonText.today - Localized string for the word "Today".
     * @param {String} Params.ButtonText.month - Localized string for the word "month".
     * @param {String} Params.ButtonText.week - Localized string for the word "week".
     * @param {String} Params.ButtonText.day - Localized string for the word "day".
     * @param {Array} Params.EventSources - Array of hashes including the data for each event.
     * @description
     *      Initializes the appointment calendar control.
     */
    TargetNS.Init = function (Params) {
        $('#calendar').fullCalendar({
            header: {
                left: 'yearly,month,agendaWeek,agendaDay timeline',
                center: 'title',
                right: 'today prev,next'
            },
            defaultView: 'timeline',
            allDayText: Params.AllDayText,
            isRTL: Params.IsRTL,
            columnFormat: 'ddd, D MMM',
            timeFormat: 'H:mm',
            slotLabelFormat: 'HH:mm',
            titleFormat: 'D MMM YYYY #W',
            businessHours: {
                start: '08:00',
                end: '18:00',
                dow: [ 1, 2, 3, 4, 5 ]
            },
            eventLimit: true,
            height: 600,
            editable: true,
            selectable: true,
            selectHelper: true,
            firstDay: Params.FirstDay,
            monthNames: Params.MonthNames,
            monthNamesShort: Params.MonthNamesShort,
            dayNames: Params.DayNames,
            dayNamesShort: Params.DayNamesShort,
            buttonText: Params.ButtonText,
            schedulerLicenseKey: 'GPL-My-Project-Is-Open-Source',
            slotDuration: '00:30:00',
            forceEventDuration: true,
            nowIndicator: true,
            views: {
                month: {
                    titleFormat: 'MMMM YYYY',
                    columnFormat: 'dddd'
                },
                agendaWeek: {
                    weekends: false
                },
                agendaDay: {
                    titleFormat: 'D MMM YYYY'
                },
                timeline: {
                    slotDuration: '02:00:00',
                    duration: {
                        days: 7
                    },
                    slotLabelFormat: [
                        'ddd, D MMM',
                        'HH'
                    ]
                }
            },
            loading: function(IsLoading) {
                if (IsLoading) {
                    $('.CalendarWidget').addClass('Loading');
                } else {
                    $('.CalendarWidget').removeClass('Loading');
                }
            },
            select: function(Start, End, JSEvent, View, Resource) {
                var Data = {
                    Start: Start,
                    End: End,
                    JSEvent: JSEvent,
                    View: View,
                    Resource: Resource
                };
                OpenEditDialog(Params, Data);
                $('#calendar').fullCalendar('unselect');
            },
            eventClick: function(CalEvent, JSEvent, View) {
                var Data = {
                    Start: CalEvent.start,
                    End: CalEvent.end,
                    CalEvent: CalEvent,
                    JSEvent: JSEvent,
                    View: View
                };
                OpenEditDialog(Params, Data);
                return false;
            },
            eventDrop: function(CalEvent, Delta, RevertFunc, JSEvent, UI, View) {
                var Data = {
                    CalEvent: CalEvent,
                    Delta: Delta,
                    RevertFunc: RevertFunc,
                    JSEvent: JSEvent,
                    UI: UI,
                    View: View
                };
                UpdateAppointment(Params, Data);
            },
            eventResize: function(CalEvent, Delta, RevertFunc, JSEvent, UI, View) {
                var Data = {
                    CalEvent: CalEvent,
                    Delta: Delta,
                    RevertFunc: RevertFunc,
                    JSEvent: JSEvent,
                    UI: UI,
                    View: View
                };
                UpdateAppointment(Params, Data);
            },
            eventRender: function(Event, $Element) {
                if (Event.allDay) {
                    $Element.addClass('AllDay');
                }
            }
        });
    };

    /**
     * @private
     * @name ShowWaitingDialog
     * @memberof Core.Agent.AppointmentCalendar
     * @function
     * @description
     *      Shows waiting dialog until dialog screen is ready.
     */
    function ShowWaitingDialog() {
        Core.UI.Dialog.ShowContentDialog('<div class="Spacing Center"><span class="AJAXLoader" title="' + Core.Config.Get('LoadingMsg') + '"></span></div>', Core.Config.Get('LoadingMsg'), '10px', 'Center', true);
    }

    /**
     * @private
     * @name OpenEditDialog
     * @memberof Core.Agent.AppointmentCalendar
     * @param {Object} Params - Hash with configuration.
     * @param {Object} AppointmentData - Hash with appointment data.
     * @description
     *      This method opens the appointment dialog after selecting a time period or an appointment.
     */
    function OpenEditDialog(Params, AppointmentData) {
        var Data = {
            Action: Params.Callbacks.EditAction ? Params.Callbacks.EditAction : 'AgentAppointmentEdit',
            Subaction: Params.Callbacks.EditMaskSubaction ? Params.Callbacks.EditMaskSubaction : 'EditMask',
            AppointmentID: AppointmentData.CalEvent ? AppointmentData.CalEvent.id : null,
            StartYear: !AppointmentData.CalEvent ? AppointmentData.Start.year() : null,
            StartMonth: !AppointmentData.CalEvent ? AppointmentData.Start.month() + 1 : null,
            StartDay: !AppointmentData.CalEvent ? AppointmentData.Start.date() : null,
            StartHour: !AppointmentData.CalEvent ? AppointmentData.Start.hour() : null,
            StartMinute: !AppointmentData.CalEvent ? AppointmentData.Start.minute() : null,
            EndYear: !AppointmentData.CalEvent ? AppointmentData.End.year() : null,
            EndMonth: !AppointmentData.CalEvent ? AppointmentData.End.month() + 1 : null,
            EndDay: !AppointmentData.CalEvent ? AppointmentData.End.date() : null,
            EndHour: !AppointmentData.CalEvent ? AppointmentData.End.hour() : null,
            EndMinute: !AppointmentData.CalEvent ? AppointmentData.End.minute() : null,
            AllDay: !AppointmentData.CalEvent ? (AppointmentData.End.hasTime() ? '0' : '1') : null
        };

        ShowWaitingDialog();

        Core.AJAX.FunctionCall(
            Core.Config.Get('CGIHandle'),
            Data,
            function (HTML) {
                Core.UI.Dialog.ShowContentDialog(HTML, Params.DialogText.EditTitle, '10px', 'Center', true, undefined, true);
                Core.UI.InputFields.Activate($('.Dialog:visible'));
            }, 'html'
        );
    }

    /**
     * @private
     * @name UpdateAppointment
     * @memberof Core.Agent.AppointmentCalendar
     * @param {Object} Params - Hash with configuration.
     * @param {Object} AppointmentData - Hash with appointment data.
     * @description
     *      This method updates the appointment with supplied data.
     */
    function UpdateAppointment(Params, AppointmentData) {
        var Data = {
            Action: Params.Callbacks.EditAction ? Params.Callbacks.EditAction : 'AgentAppointmentEdit',
            Subaction: Params.Callbacks.EditSubaction ? Params.Callbacks.EditSubaction : 'EditAppointment',
            AppointmentID: AppointmentData.CalEvent.id,
            StartYear: AppointmentData.CalEvent.start.year(),
            StartMonth: AppointmentData.CalEvent.start.month() + 1,
            StartDay: AppointmentData.CalEvent.start.date(),
            StartHour: AppointmentData.CalEvent.start.hour(),
            StartMinute: AppointmentData.CalEvent.start.minute(),
            EndYear: AppointmentData.CalEvent.end.year(),
            EndMonth: AppointmentData.CalEvent.end.month() + 1,
            EndDay: AppointmentData.CalEvent.end.date(),
            EndHour: AppointmentData.CalEvent.end.hour(),
            EndMinute: AppointmentData.CalEvent.end.minute(),
            AllDay: AppointmentData.CalEvent.end.hasTime() ? '0' : '1'
        };

        Core.AJAX.FunctionCall(
            Core.Config.Get('CGIHandle'),
            Data,
            function (Response) {
                if (!Response.Success) {
                    AppointmentData.RevertFunc();
                }
            }
        );
    }

    /**
     * @name CalendarSwitchInit
     * @memberof Core.Agent.AppointmentCalendar
     * @param {jQueryObject} $CalendarSwitch - calendar checkbox element.
     * @param {Object} EventSources - hash with calendar sources.
     * @description
     *      This method initializes calendar checkbox behavior.
     */
    TargetNS.CalendarSwitchInit = function ($CalendarSwitch, EventSources) {

        // Show/hide the calendar appointments
        if ($CalendarSwitch.prop('checked')) {
            $('#calendar').fullCalendar('addEventSource', EventSources[$CalendarSwitch.data('id')]);
        } else {
            $('#calendar').fullCalendar('removeEventSource', EventSources[$CalendarSwitch.data('id')]);
        }

        // Register change event handler
        $CalendarSwitch.off('change.AppointmentCalendar').on('change.AppointmentCalendar', function() {
            TargetNS.CalendarSwitchInit($CalendarSwitch, EventSources);
        });
    }

    /**
     * @name AllDayInit
     * @memberof Core.Agent.AppointmentCalendar
     * @param {jQueryObject} $AllDay - all day checkbox element.
     * @description
     *      This method initializes all day checkbox behavior.
     */
    TargetNS.AllDayInit = function ($AllDay) {

        // Show/hide the start hour/minute and complete end time
        if ($AllDay.prop('checked')) {
            $('#StartHour,#StartMinute,#EndHour,#EndMinute').prop('disabled', true);
        } else {
            $('#StartHour,#StartMinute,#EndHour,#EndMinute').prop('disabled', false);
        }

        // Register change event handler
        $AllDay.off('change.AppointmentCalendar').on('change.AppointmentCalendar', function() {
            TargetNS.AllDayInit($AllDay);
        });
    }

    /**
     * @private
     * @name EditAppointment
     * @memberof Core.Agent.AppointmentCalendar
     * @param {Object} Data - Hash with call and appointment data.
     * @description
     *      This method submits an edit appointment call to the backend and refreshes the view.
     */
    TargetNS.EditAppointment = function (Data) {
        Core.AJAX.FunctionCall(
            Core.Config.Get('CGIHandle'),
            Data,
            function (Response) {
                if (Response.Success) {
                    $('#calendar').fullCalendar('refetchEvents');

                    // Close the dialog
                    Core.UI.Dialog.CloseDialog($('.Dialog:visible'));
                }
            }
        );
    }

    return TargetNS;
}(Core.Agent.AppointmentCalendar || {}));
