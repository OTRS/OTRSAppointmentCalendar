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

    // Appointment days cache and ready flag
    var AppointmentDaysCache,
        AppointmentDaysCacheRefreshed = false;

    /**
     * @name Init
     * @memberof Core.Agent.AppointmentCalendar
     * @param {Object} Params - Hash with different config options.
     * @param {String} Params.AllDayText - Localized string for the word "All-day".
     * @param {Boolean} Params.IsRTL - Is current locale is right text based?
     * @param {Array} Params.MonthNames - Array containing the localized strings for each month.
     * @param {Array} Params.MonthNamesShort - Array containing the localized strings for each month on shorth format.
     * @param {Array} Params.DayNames - Array containing the localized strings for each week day.
     * @param {Array} Params.DayNamesShort - Array containing the localized strings for each week day on short format.
     * @param {Array} Params.ButtonText - Array containing the localized strings for each week day on short format.
     * @param {String} Params.ButtonText.today - Localized string for the word "Today".
     * @param {String} Params.ButtonText.month - Localized string for the word "Month".
     * @param {String} Params.ButtonText.week - Localized string for the word "Week".
     * @param {String} Params.ButtonText.day - Localized string for the word "Day".
     * @param {String} Params.ButtonText.timeline - Localized string for the word "Timeline".
     * @param {String} Params.ButtonText.jump - Localized string for the word "Jump".
     * @param {String} Params.FirstDay - First day of the week (0: Sunday).
     * @param {Array} Params.Header - Array containing view buttons in the header.
     * @param {String} Params.Header.left - String with view names for left side of the header.
     * @param {String} Params.Header.center - String with view names for header center.
     * @param {String} Params.Header.right - String with view names for right side of the header.
     * @param {Array} Params.DialogText - Array containing the localized strings for dialogs.
     * @param {String} Params.DialogText.EditTitle - Title of the add/edit dialog.
     * @param {String} Params.DialogText.OccurrenceTitle - Title of the occurrence dialog.
     * @param {String} Params.DialogText.OccurrenceText - Text of the occurrence dialog.
     * @param {String} Params.DialogText.OccurrenceAll - Text of 'all' button in occurrence dialog.
     * @param {String} Params.DialogText.OccurrenceJustThis - Text of 'just this' button in occurrence dialog.
     * @param {String} Params.DialogText.Dismiss - Text of 'Dismiss' button in dialog.
     * @param {Array} Params.Callbacks - Array containing names of the callbacks.
     * @param {Array} Params.Callbacks.EditAction - Name of the edit action.
     * @param {Array} Params.Callbacks.EditMaskSubaction - Name of the edit mask subaction.
     * @param {Array} Params.Callbacks.EditSubaction - Name of the edit subaction.
     * @param {Array} Params.Callbacks.AddSubaction - Name of the add subaction.
     * @param {Array} Params.Callbacks.ListAction - Name of the list action.
     * @param {Array} Params.Callbacks.DaysSubaction - Name of the appointment days subaction.
     * @param {Object} Params.Resources - Object with resource parameters (optional).
     * @description
     *      Initializes the appointment calendar control.
     */
    TargetNS.Init = function (Params) {
        var $CalendarObj = $('#calendar'),
            $DatepickerObj = $('<div />')
                .prop('id', 'Datepicker')
                .addClass('Hidden')
                .insertAfter($('#calendar')),
            CurrentAppointment = [];

        Params.Resources = Params.Resources || {
            ResourceColumns: null,
            ResourceJSON: null,
            ResourceText: null
        };

        // Initialize calendar
        $CalendarObj.fullCalendar({
            header: Params.Header,
            customButtons: {
                jump: {
                    text: Params.ButtonText.jump,
                    click: function() {
                        ShowDatepicker($CalendarObj, $DatepickerObj, $(this), Params);
                    }
                }
            },
            defaultView: 'timelineWeek',
            allDayText: Params.AllDayText,
            isRTL: Params.IsRTL,
            columnFormat: 'ddd, D MMM',
            timeFormat: 'HH:mm',
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
                timelineMonth: {
                    slotDuration: '24:00:00',
                    duration: {
                        months: 1
                    },
                    slotLabelFormat: [
                        'D'
                    ]
                },
                timelineWeek: {
                    slotDuration: '02:00:00',
                    duration: {
                        week: 1
                    },
                    slotLabelFormat: [
                        'ddd, D MMM',
                        'HH'
                    ]
                },
                timelineDay: {
                    slotDuration: '00:30:00',
                    duration: {
                        days: 1
                    },
                    slotLabelFormat: [
                        'ddd, D MMM',
                        'HH:mm'
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
                $CalendarObj.fullCalendar('unselect');
            },
            eventClick: function(CalEvent) {
                var Data = {
                    Start: CalEvent.start,
                    End: CalEvent.end,
                    CalEvent: CalEvent
                };
                OpenEditDialog(Params, Data);
                return false;
            },
            eventDrop: function(CalEvent, Delta, RevertFunc) {
                var Data = {
                    CalEvent: CalEvent,
                    PreviousAppointment: CurrentAppointment,
                    Delta: Delta,
                    RevertFunc: RevertFunc
                };
                UpdateAppointment(Params, Data);
            },
            eventResize: function(CalEvent, Delta, RevertFunc) {
                var Data = {
                    CalEvent: CalEvent,
                    PreviousAppointment: CurrentAppointment,
                    Delta: Delta,
                    RevertFunc: RevertFunc
                };
                UpdateAppointment(Params, Data);
            },
            eventRender: function(CalEvent, $Element) {
                if (CalEvent.allDay) {
                    $Element.addClass('AllDay');
                }
            },
            eventResizeStart: function(CalEvent) {
                CurrentAppointment.start = CalEvent.start;
                CurrentAppointment.end = CalEvent.end;
            },
            eventDragStart: function(CalEvent) {
                CurrentAppointment.start = CalEvent.start;
                CurrentAppointment.end = CalEvent.end;
            },
            resources: Params.Resources.ResourceJSON,
            resourceColumns: Params.Resources.ResourceColumns,
            resourceLabelText: Params.Resources.ResourceText
        });

        // Initialize datepicker
        $DatepickerObj.datepicker({
            showOn: 'button',
            buttonText: Params.ButtonText.jump,
            constrainInput: true,
            prevText: Params.ButtonText.prevDatepicker,
            nextText: Params.ButtonText.nextDatepicker,
            firstDay: Params.FirstDay,
            showMonthAfterYear: 0,
            monthNames: Params.MonthNames,
            monthNamesShort: Params.MonthNamesShort,
            dayNames: Params.DayNames,
            dayNamesShort: Params.DayNamesShort,
            dayNamesMin: Params.DayNamesMin,
            isRTL: Params.IsRTL,
            onSelect: function(DateText) {
                $CalendarObj.fullCalendar('gotoDate', new Date(DateText));
                $('#DatepickerOverlay').remove();
                $DatepickerObj.hide();
            },
            beforeShowDay: function(DateObject) {
                if (AppointmentDaysCacheRefreshed) {
                    return CheckDate(DateObject);
                } else {
                    return [true];
                }
            },
            onChangeMonthYear: function(Year, Month) {
                AppointmentDays($DatepickerObj, Year, Month, Params);
            }
        });

        // Check each 5 seconds
        setInterval(function () {
            TargetNS.AppointmentReached(Params)
        }, 5000);
    };

    /**
     * @private
     * @name ShowDatepicker
     * @memberof Core.Agent.AppointmentCalendar
     * @param {jQueryObject} $CalendarObj - Calendar control object.
     * @param {jQueryObject} $DatepickerObj - Datepicker control object.
     * @param {jQueryObject} $JumpButton - Datepicker button object.
     * @param {Object} Params - Hash with different config options.
     * @description
     *      Show date picker control.
     */
    function ShowDatepicker($CalendarObj, $DatepickerObj, $JumpButton, Params) {
        var CurrentDate = $CalendarObj.fullCalendar('getDate'),
            Year = CurrentDate.format('YYYY'),
            Month = CurrentDate.format('M');

        $('<div />').prop('id', 'DatepickerOverlay')
            .appendTo($('body'))
            .on('click.AppointmentCalendar', function () {
                $(this).remove();
                $DatepickerObj.hide();
            });

        AppointmentDays($DatepickerObj, Year, Month, Params);

        $DatepickerObj.datepicker('setDate', CurrentDate.toDate())
            .css({
                left: parseInt($JumpButton.offset().left - $DatepickerObj.outerWidth() + $JumpButton.outerWidth(), 10),
                top: parseInt($JumpButton.offset().top - $DatepickerObj.outerHeight() + $JumpButton.outerHeight(), 10)
            }).fadeIn(150);
    }

    /**
     * @private
     * @name CheckDate
     * @memberof Core.Agent.AppointmentCalendar
     * @function
     * @param {DateObject} DateObject - A JS date object to check.
     * @returns {Array} First element is always true, second element contains the name of a CSS
     *                  class, third element a description for the date.
     * @description
     *      Check if date has an appointment.
     */
    function CheckDate(DateObject) {
        var DateMoment = $.fullCalendar.moment(DateObject),
            DayAppointments = AppointmentDaysCache[DateMoment.format('YYYY-MM-DD')],
            DayClass = DayAppointments ? 'Highlight' : '',
            DayDescription = DayAppointments ? DayAppointments.toString() : '';

        return [true, DayClass, DayDescription];
    }

    /**
     * @private
     * @name AppointmentDays
     * @memberof Core.Agent.AppointmentCalendar
     * @param {jQueryObject} $DatepickerObj - Datepicker control object.
     * @param {Integer} Year - Selected year.
     * @param {Integer} Month - Selected month (1-12).
     * @param {Object} Params - Hash with different config options.
     * @description
     *      Caches the list of appointment days for later use.
     */
    function AppointmentDays($DatepickerObj, Year, Month, Params) {
        var StartTime = $.fullCalendar.moment(Year + '-' + Month, 'YYYY-M').startOf('month'),
            EndTime = $.fullCalendar.moment(Year + '-' + Month, 'YYYY-M').add(1, 'months').startOf('month'),
            Data = {
                Action: Params.Callbacks.ListAction,
                Subaction: Params.Callbacks.DaysSubacton,
                StartTime: StartTime.format('YYYY-MM-DD'),
                EndTime: EndTime.format('YYYY-MM-DD')
            };

        $DatepickerObj.addClass('AJAXLoading');
        AppointmentDaysCacheRefreshed = false;

        Core.AJAX.FunctionCall(
            Core.Config.Get('CGIHandle'),
            Data,
            function (Response) {
                if (Response) {
                    AppointmentDaysCache = Response;
                    AppointmentDaysCacheRefreshed = true;
                    $DatepickerObj.removeClass('AJAXLoading');

                    // Refresh the date picker because this call is asynchronous
                    $DatepickerObj.datepicker('refresh');
                }
            }
        );
    }

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
     * @param {Array} Params.DialogText - Array containing the localized strings for dialogs.
     * @param {String} Params.DialogText.EditTitle - Title of the add/edit dialog.
     * @param {String} Params.DialogText.OccurrenceTitle - Title of the occurrence dialog.
     * @param {String} Params.DialogText.OccurrenceText - Text of the occurrence dialog.
     * @param {String} Params.DialogText.OccurrenceAll - Text of 'all' button in occurrence dialog.
     * @param {String} Params.DialogText.OccurrenceJustThis - Text of 'just this' button in occurrence dialog.
     * @param {Array} Params.Callbacks - Array containing names of the callbacks.
     * @param {Array} Params.Callbacks.EditAction - Name of the edit action.
     * @param {Array} Params.Callbacks.EditMaskSubaction - Name of the edit mask subaction.
     * @param {Object} AppointmentData - Hash with appointment data.
     * @param {Moment} AppointmentData.Start - Moment object with start date/time.
     * @param {Moment} AppointmentData.End - Moment object with end date/time.
     * @param {Object} AppointmentData.CalEvent - Calendar event object (FullCalendar).
     * @param {Object} AppointmentData.Resource - Calendar resource object (FullCalendar).
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
            AllDay: !AppointmentData.CalEvent ? (AppointmentData.End.hasTime() ? '0' : '1') : null,
            ResourceID: AppointmentData.Resource ? [ AppointmentData.Resource.id ] : null
        };

        function EditDialog() {
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

        // Repeating event
        if (AppointmentData.CalEvent && AppointmentData.CalEvent.parentId) {
            Core.UI.Dialog.ShowDialog({
                Title: Params.DialogText.OccurrenceTitle,
                HTML: Params.DialogText.OccurrenceText,
                Modal: true,
                CloseOnClickOutside: true,
                CloseOnEscape: true,
                PositionTop: '20%',
                PositionLeft: 'Center',
                Buttons: [
                    {
                        Label: Params.DialogText.OccurrenceAll,
                        Class: 'Primary CallForAction',
                        Function: function() {
                            Data.AppointmentID = AppointmentData.CalEvent.parentId;
                            EditDialog();
                        }
                    },
                    {
                        Label: Params.DialogText.OccurrenceJustThis,
                        Class: 'CallForAction',
                        Function: EditDialog
                    },
                    {
                        Type: 'Close',
                        Label: Params.DialogText.Close
                    }
                ]
            });
        } else {
            EditDialog();
        }
    }

    /**
     * @private
     * @name UpdateAppointment
     * @memberof Core.Agent.AppointmentCalendar
     * @param {Object} Params - Hash with configuration.
     * @param {Array} Params.DialogText - Array containing the localized strings for dialogs.
     * @param {String} Params.DialogText.OccurrenceTitle - Title of the occurrence dialog.
     * @param {String} Params.DialogText.OccurrenceText - Text of the occurrence dialog.
     * @param {String} Params.DialogText.OccurrenceAll - Text of 'all' button in occurrence dialog.
     * @param {String} Params.DialogText.OccurrenceJustThis - Text of 'just this' button in occurrence dialog.
     * @param {Array} Params.Callbacks - Array containing names of the callbacks.
     * @param {Array} Params.Callbacks.EditAction - Name of the edit action.
     * @param {Array} Params.Callbacks.EditSubaction - Name of the edit subaction.
     * @param {Object} AppointmentData - Hash with appointment data.
     * @param {Object} AppointmentData.CalEvent - Calendar event object (FullCalendar).
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
            AllDay: AppointmentData.CalEvent.end.hasTime() ? '0' : '1',
            Recurring: AppointmentData.CalEvent.recurring ? '1' : '0',
            ResourceID: AppointmentData.CalEvent.resourceId ? AppointmentData.CalEvent.resourceId : undefined
        };

        function Update() {
            Core.UI.Dialog.CloseDialog($('.Dialog:visible'));
            Core.AJAX.FunctionCall(
                Core.Config.Get('CGIHandle'),
                Data,
                function (Response) {
                    if (Response.Success) {
                        if (Data.Recurring === '1') {
                            $('#calendar').fullCalendar('refetchEvents');
                        }
                    } else {
                        AppointmentData.RevertFunc();
                    }

                    // Close the dialog
                    Core.UI.Dialog.CloseDialog($('.Dialog:visible'));
                }
            );
        }

        // Repeating event
        if (AppointmentData.CalEvent.parentId) {
            Core.UI.Dialog.ShowDialog({
                Title: Params.DialogText.OccurrenceTitle,
                HTML: Params.DialogText.OccurrenceText,
                Modal: true,
                CloseOnClickOutside: true,
                CloseOnEscape: true,
                PositionTop: '20%',
                PositionLeft: 'Center',
                Buttons: [
                    {
                        Label: Params.DialogText.OccurrenceAll,
                        Class: 'Primary CallForAction',
                        Function: function() {
                            Data.AppointmentID = AppointmentData.CalEvent.parentId;
                            Data.Recurring = '1';
                            Data.UpdateDelta = AppointmentData.Delta.asSeconds();
                            if (
                                AppointmentData.CalEvent.start.diff(AppointmentData.PreviousAppointment.start, 'seconds')
                                === Data.UpdateDelta
                                &&
                                AppointmentData.CalEvent.end.diff(AppointmentData.PreviousAppointment.end, 'seconds')
                                === Data.UpdateDelta
                            ) {
                                Data.UpdateType = 'Both';
                            }
                            else if (
                                AppointmentData.PreviousAppointment.start.diff(AppointmentData.CalEvent.start, 'seconds')
                                === Data.UpdateDelta
                            ) {
                                Data.UpdateType = 'StartTime';
                                Data.UpdateDelta = Data.UpdateDelta * -1;
                            }
                            else if (
                                AppointmentData.CalEvent.end.diff(AppointmentData.PreviousAppointment.end, 'seconds')
                                === Data.UpdateDelta
                            ) {
                                Data.UpdateType = 'EndTime';
                            }
                            Update();
                        }
                    },
                    {
                        Label: Params.DialogText.OccurrenceJustThis,
                        Class: 'CallForAction',
                        Function: function() {
                            AppointmentData.CalEvent.parentId = null;
                            Update();
                        }
                    },
                    {
                        Type: 'Close',
                        Label: Params.DialogText.Close,
                        Function: function() {
                            Core.UI.Dialog.CloseDialog($('.Dialog:visible'));
                            AppointmentData.RevertFunc();
                        }
                    }
                ]
            });
        } else {
            Update();
        }
    }

    /**
     * @name CalendarSwitchInit
     * @memberof Core.Agent.AppointmentCalendar
     * @param {jQueryObject} $CalendarSwitch - calendar checkbox element.
     * @param {Object} EventSources - hash with calendar sources.
     * @description
     *      This method initializes calendar checkbox behavior and loads multiple calendars to the
     *      FullCalendar control.
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
     * @name RecurringInit
     * @memberof Core.Agent.AppointmentCalendar
     * @param {Object} Fields - Array with references to recurring fields.
     * @param {jQueryObject} Fields.$Recurring - field with recurring flag.
     * @param {jQueryObject} Fields.$RecurrenceType - drop down with recurrence type.
     * @param {jQueryObject} Fields.$RecurrenceLimitDiv - layer with recurrence limit fields.
     * @param {jQueryObject} Fields.$RecurrenceLimit - drop down with recurrence limit field.
     * @param {jQueryObject} Fields.$RecurrenceCountDiv - layer with reccurence count field.
     * @param {jQueryObject} Fields.$RecurrenceUntilDiv - layer with reccurence until fields.
     * @description
     *      This method initializes recurrence fields behavior.
     */
    TargetNS.RecurringInit = function (Fields) {
        Fields.$RecurrenceType.off('change.AppointmentCalendar').on('change.AppointmentCalendar', function() {
            if ($(this).val() == 0) {
                Fields.$Recurring.val(0);
                Fields.$RecurrenceLimitDiv.hide();
                Fields.$RecurrenceCountDiv.hide();
                Fields.$RecurrenceUntilDiv.hide();
            } else {
                Fields.$Recurring.val(1);
                Fields.$RecurrenceLimitDiv.show();
                Fields.$RecurrenceLimit.off('change.AppointmentCalendar').on('change.AppointmentCalendar', function() {
                    if ($(this).val() == 1) {
                        Fields.$RecurrenceCountDiv.hide();
                        Fields.$RecurrenceUntilDiv.show();
                    } else {
                        Fields.$RecurrenceUntilDiv.hide();
                        Fields.$RecurrenceCountDiv.show();
                    }
                }).trigger('change.AppointmentCalendar');
                Core.UI.InputFields.Activate(Fields.$RecurrenceLimitDiv);
            }
        }).trigger('change.AppointmentCalendar');
    }

    /**
     * @name TeamInit
     * @memberof Core.Agent.AppointmentCalendar
     * @param {jQueryObject} $TeamListObj - field with team list.
     * @description
     *      This method initializes team fields behavior.
     */
    TargetNS.TeamInit = function ($TeamListObj) {
        $TeamListObj.off('change.AppointmentCalendar').on('change.AppointmentCalendar', function() {
            var TeamID = $TeamListObj.val();

            // Hide all fields
            $('.TeamUserList,.TeamUserListLabel').hide();

            // Show selected team fields
            $('#TeamUserList' + Core.App.EscapeSelector(TeamID)).parent('.Field').show();
            $('label[for="TeamUserList' + Core.App.EscapeSelector(TeamID) + '"]').show();

            // Store resource IDs
            TargetNS.StoreResource($('#TeamUserList' + Core.App.EscapeSelector(TeamID)));

            // Activate InputFields
            Core.UI.InputFields.Activate('.TeamUserList');

        }).trigger('change.AppointmentCalendar');
    }

    /**
     * @name StoreResource
     * @memberof Core.Agent.AppointmentCalendar
     * @param {jQueryObject} $TeamUserListObj - field with team list.
     * @description
     *      This method stores selected resource IDs.
     */
    TargetNS.StoreResource = function ($TeamUserListObj) {
        $TeamUserListObj.off('change.AppointmentCalendar').on('change.AppointmentCalendar', function() {
            var $FormObj = $TeamUserListObj.closest("form"),
                $ResourceIDObj;

            // Create resource ID field if it's missing in the form
            $ResourceIDObj = $FormObj.find('input#ResourceID');
            if ($ResourceIDObj.length === 0) {
                $ResourceIDObj = $('<input />')
                    .prop('id', 'ResourceID')
                    .prop('name', 'ResourceID[]')
                    .prop('type', 'hidden')
                    .appendTo($FormObj);
            }

            // Store resource IDs
            $ResourceIDObj.val($TeamUserListObj.val());

        }).trigger('change.AppointmentCalendar');
    }

    /**
     * @name EditAppointment
     * @param {Object} Data - Hash with call and appointment data.
     * @param {Integer} Data.CalendarID - Appointment calendar ID.
     * @param {Integer} Data.AppointmentID - Appointment ID.
     * @param {Integer} Data.Action - Edit action.
     * @param {Integer} Data.Subaction - Edit subaction.
     * @param {Integer} Data.Title - Appointment title.
     * @param {Integer} Data.Description - Appointment description.
     * @param {Integer} Data.Location - Appointment location.
     * @param {Integer} Data.StartYear - Appointment start year.
     * @param {Integer} Data.StartMonth - Appointment start month.
     * @param {Integer} Data.StartDay - Appointment start day.
     * @param {Integer} Data.StartHour - Appointment start hour.
     * @param {Integer} Data.StartMinute - Appointment start minute.
     * @param {Integer} Data.EndYear - Appointment end year.
     * @param {Integer} Data.EndMonth - Appointment end month.
     * @param {Integer} Data.EndDay - Appointment end day.
     * @param {Integer} Data.EndHour - Appointment end hour.
     * @param {Integer} Data.EndMinute - Appointment end minute.
     * @param {Integer} Data.AllDay - Is appointment an all-day appointment (0|1)?
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
    };

    /**
     * @name InitCalendarFilter
     * @memberof Core.Agent.AppointmentCalendar
     * @function
     * @param {jQueryObject} $FilterInput - Filter input element.
     * @param {jQueryObject} $Container - Container of calendar switches to be filtered.
     * @description
     *      This function initializes a filter input field which can be used to dynamically filter
     *      a list of calendar switches in calendar overview.
     */
    TargetNS.InitCalendarFilter = function ($FilterInput, $Container) {
        var Timeout,
            $Rows = $Container.find('.CalendarSwitch'),
            $Elements = $Rows.find('label');

        $FilterInput.unbind('keydown.FilterInput').bind('keydown.FilterInput', function () {

            $FilterInput.addClass('Filtering');
            window.clearTimeout(Timeout);
            Timeout = window.setTimeout(function () {

                var FilterText = ($FilterInput.val() || '').toLowerCase();

                /**
                 * @private
                 * @name CheckText
                 * @memberof Core.Agent.AppointmentCalendar
                 * @function
                 * @returns {Boolean} True if text was found, false otherwise.
                 * @param {jQueryObject} $Element - Element that will be checked.
                 * @param {String} Filter - The current filter text.
                 * @description
                 *      Check if a text exist inside an element.
                 */
                function CheckText($Element, Filter) {
                    var Text;

                    Text = $Element.text();
                    if (Text && Text.toLowerCase().indexOf(Filter) > -1){
                        return true;
                    }

                    return false;
                }

                if (FilterText.length) {
                    $Rows.hide();
                    $Elements.each(function () {
                        if (CheckText($(this), FilterText)) {
                            $(this).parent().show();
                        }
                    });
                }
                else {
                    $Rows.show();
                }

                if ($Rows.filter(':visible').length) {
                    $Container.find('.FilterMessage').hide();
                }
                else {
                    $Container.find('.FilterMessage').show();
                }

                Core.App.Publish('Event.AppointmentCalendar.CalendarWidget.InitCalendarFilter.Change', [$FilterInput, $Container]);
                $FilterInput.removeClass('Filtering');

            }, 100);
        });

        // Prevent submit when the Return key was pressed
        $FilterInput.unbind('keypress.FilterInput').bind('keypress.FilterInput', function (Event) {
            if ((Event.charCode || Event.keyCode) === 13) {
                Event.preventDefault();
            }
        });
    };

    /**
     * @name AppointmentReached
     * @memberof Core.Agent.AppointmentCalendar
     * @function
     * @param {Object} Params - Hash with different config options.
     * @description
     *      This function displays dialog with currently active Appointments if needed.
     */
    TargetNS.AppointmentReached = function (Params) {
        var AppointmentIDs = [],
            Data,
            Index,
            Appointments = $('#calendar').fullCalendar('clientEvents'),
            DateCurrent = moment(); // eslint-disable-line no-undef

        if (DateCurrent.second() > 6 && this.Initialized != null) {
            // There is no need to check, since times are rounded to minutes
            return;
        }

        // Check if another dialog is already open
        if ($("div.Dialog:visible").length > 0) {
            return;
        }

        this.Initialized = true;

        // Itterate through all Appointments
        for (Index = 0; Index < Appointments.length; Index++) {
            if (Appointments[Index].start.isBefore(DateCurrent) &&
                DateCurrent.isBefore(Appointments[Index].end)
            ) {
                if (Appointments[Index].shown != null) {
                    continue;
                }

                AppointmentIDs.push(Appointments[Index].id);
            }
        }

        Data = {
            Action: "AgentAppointmentList",
            Subaction: "AppointmentsStarted",
            AppointmentIDs: AppointmentIDs
        };

        Core.AJAX.FunctionCall(
            Core.Config.Get('CGIHandle'),
            Data,
            function (Response) {

                if (Response) {
                    if (Response.Show) {

                        Core.UI.Dialog.ShowContentDialog(Response.HTML, Response.Title, '100px', 'Center', true, [
                            {
                                Label: Params.DialogText.Dismiss,
                                Type: "Close",
                                Function: function () {
                                    Core.UI.Dialog.CloseDialog($('.Dialog:visible'));
                                }
                            }
                        ], true);
                        Core.UI.InputFields.Activate($('.Dialog:visible'));
                    }
                }
            }
        );
    }

    return TargetNS;
}(Core.Agent.AppointmentCalendar || {}));
