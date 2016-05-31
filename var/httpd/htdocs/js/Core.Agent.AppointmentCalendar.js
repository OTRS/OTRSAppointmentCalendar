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
        AppointmentDaysCacheRefreshed = false,
        AJAXCounter = 0,
        CurrentView;

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
     * @param {String} Params.DefaultView - Default view to display (month|agendaWeek|agendaDay|timelineMonth|timelineWeek|timelineDay).
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
     * @param {Array} Params.OverviewScreen - Name of the screen (CalendarOverview|ResourceOverview).
     * @param {Array} Params.Callbacks - Array containing names of the callbacks.
     * @param {Array} Params.Callbacks.EditAction - Name of the edit action.
     * @param {Array} Params.Callbacks.EditMaskSubaction - Name of the edit mask subaction.
     * @param {Array} Params.Callbacks.EditSubaction - Name of the edit subaction.
     * @param {Array} Params.Callbacks.AddSubaction - Name of the add subaction.
     * @param {Array} Params.Callbacks.PrefSubaction - Name of the preferences subaction.
     * @param {Array} Params.Callbacks.ListAction - Name of the list action.
     * @param {Array} Params.Callbacks.DaysSubaction - Name of the appointment days subaction.
     * @param {Object} Params.WorkingHours - Object with working hour appointments.
     * @param {Object} Params.Resources - Object with resource parameters (optional).
     * @param {Integer} Params.AppointmentID - Auto open appointment edit screen with specified appointment.
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
            defaultView: Params.DefaultView,
            allDayText: Params.AllDayText,
            isRTL: Params.IsRTL,
            columnFormat: 'ddd, D MMM',
            timeFormat: 'HH:mm',
            slotLabelFormat: 'HH:mm',
            titleFormat: 'D MMM YYYY',
            weekNumbers: true,
            weekNumberTitle: '#',
            weekNumberCalculation: 'ISO',
            eventLimit: true,
            height: 600,
            editable: true,
            selectable: true,
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
            resourceAreaWidth: '21%',
            views: {
                month: {
                    titleFormat: 'MMMM YYYY',
                    columnFormat: 'dddd'
                },
                agendaDay: {
                    titleFormat: 'D MMM YYYY',
                    resources: false
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
            viewRender: function(View) {

                // Add calendar week number to timeline view titles
                if (View.name === 'timelineWeek' || View.name === 'timelineDay') {
                    window.setTimeout(function () {
                        $CalendarObj.find('.fc-toolbar > div > h2').append(
                            $('<span />').addClass('fc-week-number')
                                .text(View.start.format(' #W'))
                        );
                    }, 0);
                }

                // Remember view selection
                if (CurrentView !== undefined && CurrentView !== View.name) {
                    Core.AJAX.FunctionCall(
                        Core.Config.Get('CGIHandle'),
                        {
                            ChallengeToken: $("#ChallengeToken").val(),
                            Action: Params.Callbacks.EditAction ? Params.Callbacks.EditAction : 'AgentAppointmentEdit',
                            Subaction: Params.Callbacks.PrefSubaction ? Params.Callbacks.PrefSubaction : 'UpdatePreferences',
                            OverviewScreen: Params.OverviewScreen ? Params.OverviewScreen : 'CalendarOverview',
                            CurrentView: View.name
                        },
                        function (Response) {
                            if (!Response.Success) {
                                Core.Debug.Log('Error updating user preferences!');
                            }
                        }
                    );
                }
                CurrentView = View.name;
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
                if (CalEvent.recurring) {
                    $Element.addClass('RecurringParent');
                } else if (CalEvent.parentId) {
                    $Element.addClass('RecurringChild');
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
            eventMouseover: function(CalEvent, JSEvent) {
                var $TooltipObj,
                    PosX = 0,
                    PosY = 0,
                    TooltipHTML = $('#AppointmentTooltipTemplate').html() || '',
                    DocumentVisibleLeft = $(document).scrollLeft() + $(window).width(),
                    DocumentVisibleTop = $(document).scrollTop() + $(window).height(),
                    LastXPosition,
                    LastYPosition;

                if (!JSEvent) {
                    JSEvent = window.event;
                }
                if (JSEvent.pageX || JSEvent.pageY) {
                    PosX = JSEvent.pageX;
                    PosY = JSEvent.pageY;
                } else if (JSEvent.clientX || JSEvent.clientY) {
                    PosX = JSEvent.clientX + document.body.scrollLeft + document.documentElement.scrollLeft;
                    PosY = JSEvent.clientY + document.body.scrollTop + document.documentElement.scrollTop;
                }

                // Increase positions so the tooltip do not overlap with mouse pointer
                PosX += 15;
                PosY += 15;

                if (TooltipHTML.length > 0) {

                    // Replace placeholders with appointment information
                    TooltipHTML = ReplaceAppointmentInformation(TooltipHTML, CalEvent);

                    // Create tooltip object
                    $TooltipObj = $('<div/>').addClass('AppointmentTooltip Hidden')
                        .offset({
                            top: PosY,
                            left: PosX
                        })
                        .html(TooltipHTML)
                        .appendTo('body');

                    // Re-calculate top position if needed
                    LastYPosition = PosY + $TooltipObj.height();
                    if (LastYPosition > DocumentVisibleTop) {
                        PosY = PosY - (LastYPosition - DocumentVisibleTop) - 15;
                        $TooltipObj.css('top', PosY + 'px');
                    }

                    // Re-calculate left position if needed
                    LastXPosition = PosX + $TooltipObj.width();
                    if (LastXPosition > DocumentVisibleLeft) {
                        PosX = PosX - (LastXPosition - DocumentVisibleLeft) - 15;
                        $TooltipObj.css('left', PosX + 'px');
                    }

                    // Show the tooltip
                    $TooltipObj.fadeIn("fast");

                    // Collapse fieldset legend elements
                    $TooltipObj.find('fieldset').each(function (Index, Fieldset) {
                        if ($(Fieldset).find(':visible').length <= 2) {
                            $(Fieldset).hide();
                        }
                    });
                }
            },
            eventMouseout: function() {
                $('.AppointmentTooltip').fadeOut("fast").remove();
            },
            events: Params.WorkingHours,
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

        // Auto open appointment edit screen
        if (Params.AppointmentID) {
            OpenEditDialog(Params, { CalEvent: { id: Params.AppointmentID } });
        }

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
                ChallengeToken: $("#ChallengeToken").val(),
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
     * @public
     * @name ShowWaitingDialog
     * @memberof Core.Agent.AppointmentCalendar
     * @description
     *      Shows waiting dialog.
     */
    TargetNS.ShowWaitingDialog = function () {
        Core.UI.Dialog.ShowContentDialog('<div class="Spacing Center"><span class="AJAXLoader" title="' + Core.Config.Get('AppointmentCalendarTranslationsLoading') + '"></span></div>', Core.Config.Get('AppointmentCalendarTranslationsLoading'), '10px', 'Center', true);
    }

    /**
     * @private
     * @name ReplaceAppointmentInformation
     * @memberof Core.Agent.AppointmentCalendar
     * @param {String} ReplaceHTML - String containing %placeholders%.
     * @param {Object} CalEvent - Calendar appointment object.
     * @function
     * @returns {String} String with replaced placeholders.
     * @description
     *      Replaces placeholders in supplied string with calendar appointment information.
     */
    function ReplaceAppointmentInformation(ReplaceHTML, CalEvent) {
        var Placeholder,
            SearchPlaceholder,
            ReplaceValue;

        // Loop through all properties
        for (Placeholder in CalEvent) {
            SearchPlaceholder = new RegExp('%' + Placeholder + '%', 'g');
            ReplaceValue = CalEvent[Placeholder];

            // Special properties
            if (Placeholder === 'calendarId') {
                ReplaceValue = $('label[for="Calendar' + Core.App.EscapeSelector(ReplaceValue) + '"]').text();
            } else if (Placeholder === 'recurring') {
                if (CalEvent.parentId) {
                    ReplaceValue = true;
                }
            } else if (Placeholder === 'start' || Placeholder === 'end') {
                if (CalEvent.allDay) {
                    if (Placeholder === 'end') {
                        ReplaceValue = $.fullCalendar.moment(ReplaceValue).subtract(1, 'day');
                    }
                    ReplaceValue = $.fullCalendar.moment(ReplaceValue).format('YYYY-MM-DD');
                } else {
                    ReplaceValue = $.fullCalendar.moment(ReplaceValue).format('YYYY-MM-DD HH:mm');
                }
            } else if (Placeholder === 'pluginData') {
                $.each(CalEvent.pluginData, function (Key, Value) {
                    Value = Value.replace(/\\n/g, '<br>');
                    ReplaceHTML = ReplaceHTML.replace('%' + Key + '%', Value);
                });
                continue;
            }

            // Default JSON values
            if (ReplaceValue === null || ReplaceValue === false) {
                ReplaceValue = '';
            } else if (ReplaceValue === true) {
                ReplaceValue = Core.Config.Get('AppointmentCalendarTranslationsYes');
            }

            // Replace newlines
            if (ReplaceValue.replace) {
                ReplaceValue = ReplaceValue.replace(/\\n/g, '<br>');
            }

            // Replace placeholders
            ReplaceHTML = ReplaceHTML.replace(SearchPlaceholder, ReplaceValue);
        }

        return ReplaceHTML;
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
            ChallengeToken: $("#ChallengeToken").val(),
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
            TeamID: AppointmentData.Resource ? [ AppointmentData.Resource.TeamID ] : null,
            ResourceID: AppointmentData.Resource ? [ AppointmentData.Resource.id ] : null
        };

        // Make end time for all day appointments inclusive
        if (Data.AllDay && Data.AllDay === '1') {
            AppointmentData.End.subtract(1, 'day');
            Data.EndYear = AppointmentData.End.year();
            Data.EndMonth = AppointmentData.End.month() + 1;
            Data.EndDay = AppointmentData.End.date();
            Data.EndHour = AppointmentData.End.hour();
            Data.EndMinute = AppointmentData.End.minute();
        }

        function EditDialog() {
            TargetNS.ShowWaitingDialog();
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
            ChallengeToken: $("#ChallengeToken").val(),
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
            TeamID: AppointmentData.CalEvent.teamIds ? AppointmentData.CalEvent.teamIds : undefined,
            ResourceID: AppointmentData.CalEvent.resourceId ? [ AppointmentData.CalEvent.resourceId ] : undefined
        };

        function Update() {
            Core.UI.Dialog.CloseDialog($('.Dialog:visible'));
            Core.AJAX.FunctionCall(
                Core.Config.Get('CGIHandle'),
                Data,
                function (Response) {
                    if (Response.Success) {
                        if (Data.Recurring === '1' || AppointmentData.CalEvent.allDay) {
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

        // Make end time for all day appointments inclusive
        if (AppointmentData.CalEvent.allDay) {
            AppointmentData.CalEvent.end.subtract(1, 'day');
            Data.EndYear = AppointmentData.CalEvent.end.year();
            Data.EndMonth = AppointmentData.CalEvent.end.month() + 1;
            Data.EndDay = AppointmentData.CalEvent.end.date();
            Data.EndHour = AppointmentData.CalEvent.end.hour();
            Data.EndMinute = AppointmentData.CalEvent.end.minute();
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
     * @param {Integer} CalendarLimit - maximum number of active calendars.
     * @description
     *      This method initializes calendar checkbox behavior and loads multiple calendars to the
     *      FullCalendar control.
     */
    TargetNS.CalendarSwitchInit = function ($CalendarSwitch, EventSources, CalendarLimit) {

        // Show/hide the calendar appointments
        if ($CalendarSwitch.prop('checked')) {
            $('#calendar').fullCalendar('addEventSource', EventSources[$CalendarSwitch.data('id')]);
        } else {
            $('#calendar').fullCalendar('removeEventSource', EventSources[$CalendarSwitch.data('id')]);
        }

        // Register change event handler
        $CalendarSwitch.off('change.AppointmentCalendar').on('change.AppointmentCalendar', function() {
            if ($('.CalendarColorSwatch input:checked').length > CalendarLimit) {
                $CalendarSwitch.prop('checked', false);
                Core.UI.Dialog.ShowAlert(Core.Config.Get('AppointmentCalendarTranslationsTooManyCalendarsHeadline'), Core.Config.Get('AppointmentCalendarTranslationsTooManyCalendarsText'));
            } else {
                TargetNS.CalendarSwitchInit($CalendarSwitch, EventSources, CalendarLimit);
            }
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
        if ($('#StartMonth:disabled').length > 0) {
            return;
        }

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
     * @param {jQueryObject} Fields.$RecurrenceType - drop down with recurrence type
     * @param {jQueryObject} Fields.$RecurrenceCustomType - Recurrence pattern
     * @param {jQueryObject} Fields.$RecurrenceCustomTypeStringDiv - Custom type drop-down
     * @param {jQueryObject} Fields.$RecurrenceIntervalText - interval text
     * @param {jQueryObject} Fields.$RecurrenceCustomWeeklyDiv - contains week days table
     * @param {jQueryObject} Fields.$RecurrenceCustomMonthlyDiv - contains month days table
     * @param {jQueryObject} Fields.$RecurrenceCustomYearlyDiv - contains months table
     * @param {jQueryObject} Fields.$RecurrenceLimitDiv - layer with recurrence limit fields.
     * @param {jQueryObject} Fields.$RecurrenceLimit - drop down with recurrence limit field.
     * @param {jQueryObject} Fields.$RecurrenceCountDiv - layer with reccurence count field.
     * @param {jQueryObject} Fields.$RecurrenceUntilDiv - layer with reccurence until fields.
     * @param {jQueryObject} Fields.$RecurrenceUntilDay - select field for reccurence until day.
     * @description
     *      This method initializes recurrence fields behavior.
     */
    TargetNS.RecurringInit = function (Fields) {

        function RecInit(Fields) {
            var Days = $("input#Days").val().split(","),
                MonthDays = $("input#MonthDays").val().split(","),
                Months = $("input#Months").val().split(","),
                Index;

            for(Index = 0; Index < Days.length; Index++) {
                if (Days[Index] != "") {
                    $("#RecurrenceCustomWeeklyDiv button[value=" + Days[Index] + "]")
                        .addClass("fc-state-active");
                }
            }

            for(Index = 0; Index < MonthDays.length; Index++) {
                if (MonthDays[Index] != "") {
                    $("#RecurrenceCustomMonthlyDiv button[value=" + MonthDays[Index] + "]")
                        .addClass("fc-state-active");
                }
            }

            for(Index = 0; Index < Months.length; Index++) {
                if (Months[Index] != "") {
                    $("#RecurrenceCustomYearlyDiv button[value=" + Months[Index] + "]")
                        .addClass("fc-state-active");
                }
            }

            if (Fields.$RecurrenceType.val() == 0) {
                Fields.$Recurring.val(0);
                Fields.$RecurrenceCustomTypeStringDiv.hide();
                Fields.$RecurrenceCustomWeeklyDiv.hide();
                Fields.$RecurrenceCustomMonthlyDiv.hide();
                Fields.$RecurrenceCustomYearlyDiv.hide();

                Fields.$RecurrenceLimitDiv.hide();
                Fields.$RecurrenceCountDiv.hide();
                Fields.$RecurrenceUntilDiv.hide();

                // Skip validation of RecurrenceUntil fields
                Fields.$RecurrenceUntilDay.addClass('ValidationIgnore');
            }
            else if (Fields.$RecurrenceType.val() == 'Custom') {
                Fields.$Recurring.val(1);
                Fields.$RecurrenceCustomTypeStringDiv.show();

                if (Fields.$RecurrenceCustomType.val()=="CustomDaily") {
                    Fields.$RecurrenceCustomWeeklyDiv.hide();
                    Fields.$RecurrenceCustomMonthlyDiv.hide();
                    Fields.$RecurrenceCustomYearlyDiv.hide();
                    Fields.$RecurrenceIntervalText.find('span')
                        .hide()
                        .end()
                        .find('.TextDay')
                        .show();
                }
                else if (Fields.$RecurrenceCustomType.val()=="CustomWeekly") {
                    Fields.$RecurrenceCustomWeeklyDiv.show();

                    Fields.$RecurrenceCustomMonthlyDiv.hide();
                    Fields.$RecurrenceCustomYearlyDiv.hide();
                    Fields.$RecurrenceIntervalText.find('span')
                        .hide()
                        .end()
                        .find('.TextWeek')
                        .show();
                }
                else if (Fields.$RecurrenceCustomType.val()=="CustomMonthly") {
                    Fields.$RecurrenceCustomMonthlyDiv.show();

                    Fields.$RecurrenceCustomWeeklyDiv.hide();
                    Fields.$RecurrenceCustomYearlyDiv.hide();
                    Fields.$RecurrenceIntervalText.find('span')
                        .hide()
                        .end()
                        .find('.TextMonth')
                        .show();
                }
                else if (Fields.$RecurrenceCustomType.val()=="CustomYearly") {
                    Fields.$RecurrenceCustomYearlyDiv.show();

                    Fields.$RecurrenceCustomWeeklyDiv.hide();
                    Fields.$RecurrenceCustomMonthlyDiv.hide();
                    Fields.$RecurrenceIntervalText.find('span')
                        .hide()
                        .end()
                        .find('.TextYear')
                        .show();
                }

                Fields.$RecurrenceLimitDiv.show();
                Fields.$RecurrenceLimit.off('change.AppointmentCalendar').on('change.AppointmentCalendar', function() {
                    if ($(this).val() == 1) {
                        Fields.$RecurrenceCountDiv.hide();
                        Fields.$RecurrenceUntilDiv.show();

                        // Resume validation of RecurrenceUntil fields
                        Fields.$RecurrenceUntilDay.removeClass('ValidationIgnore');
                    } else {
                        Fields.$RecurrenceUntilDiv.hide();
                        Fields.$RecurrenceCountDiv.show();

                        // Skip validation of RecurrenceUntil fields
                        Fields.$RecurrenceUntilDay.addClass('ValidationIgnore');
                    }
                }).trigger('change.AppointmentCalendar');

                Core.UI.InputFields.Activate(Fields.$RecurrenceCustomTypeStringDiv);
                Core.UI.InputFields.Activate(Fields.$RecurrenceLimitDiv);
            }
            else {
                Fields.$Recurring.val(1);
                Fields.$RecurrenceLimitDiv.show();

                Fields.$RecurrenceCustomTypeStringDiv.hide();
                Fields.$RecurrenceCustomWeeklyDiv.hide();
                Fields.$RecurrenceCustomMonthlyDiv.hide();
                Fields.$RecurrenceCustomYearlyDiv.hide();

                Fields.$RecurrenceLimit.off('change.AppointmentCalendar').on('change.AppointmentCalendar', function() {
                    if ($(this).val() == 1) {
                        Fields.$RecurrenceCountDiv.hide();
                        Fields.$RecurrenceUntilDiv.show();

                        // Resume validation of RecurrenceUntil fields
                        Fields.$RecurrenceUntilDay.removeClass('ValidationIgnore');
                    } else {
                        Fields.$RecurrenceUntilDiv.hide();
                        Fields.$RecurrenceCountDiv.show();

                        // Skip validation of RecurrenceUntil fields
                        Fields.$RecurrenceUntilDay.addClass('ValidationIgnore');
                    }
                }).trigger('change.AppointmentCalendar');
                Core.UI.InputFields.Activate(Fields.$RecurrenceLimitDiv);
            }

            Fields.$RecurrenceCustomType.off('change.AppointmentCalendar').on('change.AppointmentCalendar', function() {
                TargetNS.RecurringInit(Fields);
            });
        }

        Fields.$RecurrenceType.off('change.AppointmentCalendar').on('change.AppointmentCalendar', function() {
            RecInit(Fields);
        }).trigger('change.AppointmentCalendar');
    }

    /**
     * @name TeamInit
     * @memberof Core.Agent.AppointmentCalendar
     * @param {jQueryObject} $TeamIDObj - field with list of teams.
     * @param {jQueryObject} $ResourceIDObj - field with list of resources.
     * @description
     *      This method initializes team fields behavior.
     */
    TargetNS.TeamInit = function ($TeamIDObj, $ResourceIDObj) {
        $TeamIDObj.off('change.AppointmentCalendar').on('change.AppointmentCalendar', function () {
            var Data = {
                ChallengeToken: $('#ChallengeToken').val(),
                Action: 'AgentAppointmentEdit',
                Subaction: 'TeamUserList',
                TeamID: $TeamIDObj.val()
            };

            ToggleAJAXLoader($ResourceIDObj, true);

            Core.AJAX.FunctionCall(
                Core.Config.Get('CGIHandle'),
                Data,
                function (Response) {
                    var SelectedID = $ResourceIDObj.val();
                    if (Response.TeamUserList) {
                        $ResourceIDObj.empty();
                        $.each(Response.TeamUserList, function (Index, Value) {
                            var NewOption = new Option(Value, Index);

                            // Overwrite option text, because of wrong html quoting of text content.
                            // (This is needed for IE.)
                            NewOption.innerHTML = Value;

                            // Restore selection
                            if (SelectedID && SelectedID.indexOf(Index) > -1) {
                                NewOption.selected = true;
                            }

                            $ResourceIDObj.append(NewOption);
                        });

                        // Trigger custom redraw event for InputFields
                        $ResourceIDObj.trigger('redraw.InputField');
                    }
                    ToggleAJAXLoader($ResourceIDObj, false);
                }
            );
        });
    }

    /**
     * @private
     * @name ToggleAJAXLoader
     * @memberof Core.Agent.AppointmentCalendar
     * @function
     * @param {jQueryObject} $Element - Object reference of the field which is updated
     * @param {Boolean} Show - Show or hide the AJAX loader image
     * @description
     *      Shows and hides an ajax loader for every element which is updates via ajax.
     */
    function ToggleAJAXLoader($Element, Show) {
        var $Loader = $('#AJAXLoader' + $Element.attr('id')),
            LoaderHTML = '<span id="AJAXLoader' + $Element.attr('id') + '" class="AJAXLoader"></span>';

        // Element not present
        if (!$Element.length) {
            return;
        }

        // Show or hide the loader
        if (Show) {
            if (!$Loader.length) {
                $Element.after(LoaderHTML);
            } else {
                $Loader.show();
            }
        } else {
            if ($Loader.length) {
                $Loader.hide();
            }
        }
    }

    /**
     * @name PluginInit
     * @memberof Core.Agent.AppointmentCalendar
     * @param {jQueryObject} $PluginFields - fields with different plugin searches.
     * @description
     *      This method initializes plugin fields behavior.
     */
    TargetNS.PluginInit = function ($PluginFields) {

        function InitRemoveButtons() {
            $('.RemoveButton').off('click.AppointmentCalendar').on('click.AppointmentCalendar', function () {
                var $RemoveObj = $(this),
                    PluginKey = $RemoveObj.data('pluginKey'),
                    $PluginDataObj = $('#Plugin_' + Core.App.EscapeSelector(PluginKey)),
                    PluginData = JSON.parse($PluginDataObj.val()),
                    LinkID = $RemoveObj.data('linkId').toString(),
                    $Parent = $RemoveObj.parent();

                PluginData.splice(PluginData.indexOf(LinkID), 1);
                $PluginDataObj.val(JSON.stringify(PluginData));

                $Parent.remove();

                return false;
            });
        }

        function AddLink(PluginKey, PluginURL, LinkID, LinkName) {
            var $PluginContainerObj = $('#PluginContainer_' + Core.App.EscapeSelector(PluginKey)),
                $PluginDataObj = $('#Plugin_' + Core.App.EscapeSelector(PluginKey)),
                PluginData = JSON.parse($PluginDataObj.val()),
                $ExistingLinks = $PluginContainerObj.find('.Link_' + Core.App.EscapeSelector(LinkID)),
                $LinkContainerObj = $('<div />'),
                $URLObj = $('<a />'),
                $RemoveObj = $('<a />'),
                LinkURL = PluginURL.replace('%s', LinkID);

            if ($ExistingLinks.length > 0) {
                return;
            }

            PluginData.push(LinkID);
            $PluginDataObj.val(JSON.stringify(PluginData));

            $LinkContainerObj.addClass('Link_' + Core.App.EscapeSelector(LinkID));

            $URLObj.attr('href', LinkURL)
                .attr('target', '_blank')
                .text(LinkName)
                .appendTo($LinkContainerObj);

            $RemoveObj.attr('href', '#')
                .addClass('RemoveButton')
                .data('pluginKey', PluginKey)
                .data('linkId', LinkID)
                .append(
                    $('<i />').addClass('fa fa-minus-square-o')
                )
                .appendTo($LinkContainerObj);

            $LinkContainerObj.appendTo($PluginContainerObj);
            InitRemoveButtons();
        }

        $PluginFields.each(function () {
            var $Element = $(this),
                PluginKey = $Element.data('pluginKey'),
                PluginURL = $Element.data('pluginUrl');

            // Skip already initialized fields
            if ($Element.hasClass('ui-autocomplete-input')) {
                return true;
            }

            $Element.autocomplete({
                minLength: 2,
                delay: 500,
                source: function (Request, Response) {
                    var URL = Core.Config.Get('CGIHandle'),
                        CurrentAJAXNumber = ++AJAXCounter,
                        Data = {
                            ChallengeToken: $("#ChallengeToken").val(),
                            Action: 'AgentAppointmentPluginSearch',
                            PluginKey: PluginKey,
                            Term: Request.term + '*',
                            MaxResults: 20
                        };

                    Core.AJAX.FunctionCall(URL, Data, function (Result) {
                        var Data = [];

                        // Check if the result is from the latest ajax request
                        if (AJAXCounter !== CurrentAJAXNumber) {
                            return false;
                        }

                        $.each(Result, function () {
                            Data.push({
                                label: this.Value,
                                key:  this.Key,
                                value: this.Value
                            });
                        });
                        Response(Data);
                    });
                },
                select: function (Event, UI) {
                    Event.stopPropagation();
                    $Element.val('');
                    AddLink(PluginKey, PluginURL, UI.item.key, UI.item.label);

                    return false;
                }
            });
        });

        InitRemoveButtons();
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
                else {
                    if (Response.Error) {
                        alert(Response.Error);
                    }
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
            ChallengeToken: $("#ChallengeToken").val(),
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
