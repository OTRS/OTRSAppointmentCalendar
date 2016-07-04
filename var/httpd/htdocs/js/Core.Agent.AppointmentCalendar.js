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
     * @param {String} Params.ChallengeToken - User challenge token.
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
     * @param {String} Params.CalendarSettingsButton - ID of the settings button.
     * @param {String} Params.CalendarSettingsDialogContainer - ID of the settings dialog container.
     * @param {String} Params.CalendarSettingsShow - Show the settings dialog immediately.
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
     * @param {Object} Params.Appointment - Object with appointment screen related data (optional).
     * @param {Object} Params.Appointment.AppointmentCreate - Auto open appointment create screen parameters (optional).
     * @param {String} Params.Appointment.AppointmentCreate.Start - Start date of new appointment (moment ready).
     * @param {String} Params.Appointment.AppointmentCreate.End - End date of new appointment (moment ready).
     * @param {String} Params.Appointment.AppointmentCreate.PluginKey - Name of the plugin module to use.
     * @param {String} Params.Appointment.AppointmentCreate.Search - Search string for the plugin module search.
     * @param {String} Params.Appointment.AppointmentCreate.ObjectID - Object ID for the plugin module search.
     * @param {Integer} Params.Appointment.AppointmentID - Auto open appointment edit screen with specified appointment (optional).
     * @param {Object} Params.Calendars - Object with calendar parameters.
     * @param {Array} Params.Calendars.Sources - Array of calendar sources.
     * @param {jQueryObjects} Params.Calendars.Switches - Array of calendar switch elements.
     * @param {jQueryObjects} Params.Calendars.Limit - Maximum number of active calendar switches.
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

        if (!Params.ChallengeToken) {
            return;
        }

        Params.Resources = Params.Resources || {
            ResourceColumns: null,
            ResourceText: null,
            ResourceSettingsButton: null,
            ResourceSettingsDialogContainer: null,
            RestoreDefaultSettings: false,
            ResourceJSON: null
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
            timezone: 'local',
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
                            ChallengeToken: Params.ChallengeToken,
                            Action: Params.Callbacks.EditAction ? Params.Callbacks.EditAction : 'AgentAppointmentEdit',
                            Subaction: Params.Callbacks.PrefSubaction ? Params.Callbacks.PrefSubaction : 'UpdatePreferences',
                            OverviewScreen: Params.OverviewScreen ? Params.OverviewScreen : 'CalendarOverview',
                            DefaultView: View.name
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
                }
                else if (CalEvent.parentId) {
                    $Element.addClass('RecurringChild');
                }

                if (CalEvent.notification) {

                    // check for already existing font-awesome
                    // classes to prevent overwriting css-contents
                    // on pseudo elements like .Class:before
                    if ($Element.hasClass('AllDay')) {
                        $Element.addClass('NotificationAllDay');
                    }
                    else if ($Element.hasClass('RecurringParent')) {
                        $Element.addClass('NotificationRecurringParent');
                    }
                    else if ($Element.hasClass('RecurringChild')) {
                        $Element.addClass('NotificationRecurringChild');
                    }
                    else {
                        $Element.addClass('Notification');
                    }
                }
            },
            eventResizeStart: function(CalEvent) {
                CurrentAppointment.start = CalEvent.start;
                CurrentAppointment.end = CalEvent.end;
            },
            eventDragStart: function(CalEvent) {
                CurrentAppointment.start = CalEvent.start;
                CurrentAppointment.end = CalEvent.end;
                CurrentAppointment.resourceIds = CalEvent.resourceIds;
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
                PosX += 10;
                PosY += 10;

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
                        PosY = PosY - $TooltipObj.height();
                        $TooltipObj.css('top', PosY + 'px');
                    }

                    // Re-calculate left position if needed
                    LastXPosition = PosX + $TooltipObj.width();
                    if (LastXPosition > DocumentVisibleLeft) {
                        PosX = PosX - $TooltipObj.width() - 30;
                        $TooltipObj.css('left', PosX + 'px');
                    }

                    // Show the tooltip
                    $TooltipObj.fadeIn('fast');

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

        Params.Calendars.Switches.each(function () {
            CalendarSwitchInit($(this), Params);
        });

        if (Params.Appointment) {

            // Auto open appointment create screen
            if (Params.Appointment.AppointmentCreate) {
                OpenEditDialog(Params, {
                    Start: Params.Appointment.AppointmentCreate.Start ? $.fullCalendar.moment(Params.Appointment.AppointmentCreate.Start) : $.fullCalendar.moment().add(1, 'hours').startOf('hour'),
                    End: Params.Appointment.AppointmentCreate.End ? $.fullCalendar.moment(Params.Appointment.AppointmentCreate.End) : $.fullCalendar.moment().add(2, 'hours').startOf('hour'),
                    PluginKey: Params.Appointment.AppointmentCreate.PluginKey ? Params.Appointment.AppointmentCreate.PluginKey : null,
                    Search: Params.Appointment.AppointmentCreate.Search ? Params.Appointment.AppointmentCreate.Search : null,
                    ObjectID: Params.Appointment.AppointmentCreate.ObjectID ? Params.Appointment.AppointmentCreate.ObjectID : null
                });
            }

            // Auto open appointment edit screen
            else if (Params.Appointment.AppointmentID) {
                OpenEditDialog(Params, { CalEvent: { id: Params.Appointment.AppointmentID } });
            }
        }

        if (Params.CalendarSettingsButton) {
            CalendarSettingsInit(Params);
        }

        if (Params.Resources.ResourceSettingsButton) {
            ResourceSettingsInit(Params);
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
            }).fadeIn('fast');
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
                ChallengeToken: Params.ChallengeToken,
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
            ChallengeToken: Params.ChallengeToken,
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
            ResourceID: AppointmentData.Resource ? [ AppointmentData.Resource.id ] : null,
            PluginKey: AppointmentData.PluginKey ? AppointmentData.PluginKey : null,
            Search: AppointmentData.Search ? AppointmentData.Search : null,
            ObjectID: AppointmentData.ObjectID ? AppointmentData.ObjectID : null
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
            ChallengeToken: Params.ChallengeToken,
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
            ResourceID: AppointmentData.CalEvent.resourceIds ? AppointmentData.CalEvent.resourceIds :
                AppointmentData.CalEvent.resourceId ? [ AppointmentData.CalEvent.resourceId ] : undefined
        };

        // Assigned resource didn't change
        if (
            AppointmentData.CalEvent.resourceId
            && AppointmentData.PreviousAppointment.resourceIds
            && $.inArray(
                AppointmentData.CalEvent.resourceId,
                AppointmentData.PreviousAppointment.resourceIds
            ) !== -1
        ) {
            Data.ResourceID = AppointmentData.PreviousAppointment.resourceIds;
        }

        function Update() {
            Core.UI.Dialog.CloseDialog($('.Dialog:visible'));
            Core.AJAX.FunctionCall(
                Core.Config.Get('CGIHandle'),
                Data,
                function (Response) {
                    if (Response.Success) {
                        $('#calendar').fullCalendar('refetchEvents');
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

        // Setup notification data if available
        if (AppointmentData.CalEvent.notificationDate.length) {

            // Setup data for related custom notification type
            if (AppointmentData.CalEvent.notificationCustom === 'relative') {
                Data.NotificationCustomRelativeInput = 1;
                Data.NotificationCustomDateTimeInput = 0;
            }
            else if (AppointmentData.CalEvent.notificationCustom === 'datetime') {
                Data.NotificationCustomDateTimeInput = 1;
                Data.NotificationCustomRelativeInput = 0;
            }
            else {
                Data.NotificationCustomDateTimeInput = 0;
                Data.NotificationCustomRelativeInput = 0;
            }

            Data.NotificationDate = AppointmentData.CalEvent.notificationDate;
            Data.NotificationTemplate = AppointmentData.CalEvent.notificationTemplate;
            Data.NotificationCustom = AppointmentData.CalEvent.notificationCustom;
            Data.NotificationCustomRelativeUnitCount = AppointmentData.CalEvent.notificationCustomRelativeUnitCount;
            Data.NotificationCustomRelativeUnit = AppointmentData.CalEvent.notificationCustomRelativeUnit;
            Data.NotificationCustomRelativePointOfTime = AppointmentData.CalEvent.notificationCustomRelativePointOfTime;
            Data.NotificationCustomDateTime = AppointmentData.CalEvent.notificationCustomDateTime;
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
     * @private
     * @name CalendarSwitchInit
     * @memberof Core.Agent.AppointmentCalendar
     * @param {jQueryObject} $CalendarSwitch - calendar checkbox element.
     * @param {Object} Params - Hash with different config options.
     * @param {Array} Params.Callbacks.EditAction - Name of the edit action.
     * @param {Array} Params.Callbacks.PrefSubaction - Name of the preferences subaction.
     * @param {Array} Params.OverviewScreen - Name of the screen (CalendarOverview|ResourceOverview).
     * @param {Object} Params.Calendars - Object with calendar parameters.
     * @param {Array} Params.Calendars.Sources - Array of calendar sources.
     * @param {jQueryObjects} Params.Calendars.Switches - Array of calendar switch elements.
     * @param {jQueryObjects} Params.Calendars.Limit - Maximum number of active calendar switches.
     * @description
     *      This method initializes calendar checkbox behavior and loads multiple calendars to the
     *      FullCalendar control.
     */
    function CalendarSwitchInit($CalendarSwitch, Params) {

        // Initialize enabled sources
        if ($CalendarSwitch.prop('checked')) {
            $('#calendar').fullCalendar('addEventSource', Params.Calendars.Sources[$CalendarSwitch.data('id')]);
        }

        // Register change event handler
        $CalendarSwitch.off('change.AppointmentCalendar').on('change.AppointmentCalendar', function() {
            if ($('.CalendarSwitch input:checked').length > Params.Calendars.Limit) {
                $CalendarSwitch.prop('checked', false);
                Core.UI.Dialog.ShowAlert(Core.Config.Get('AppointmentCalendarTranslationsTooManyCalendarsHeadline'), Core.Config.Get('AppointmentCalendarTranslationsTooManyCalendarsText'));
            } else {
                CalendarSwitchSource($CalendarSwitch, Params);
            }
        });
    }

    /**
     * @private
     * @name CalendarSwitchSource
     * @memberof Core.Agent.AppointmentCalendar
     * @param {jQueryObject} $CalendarSwitch - calendar checkbox element.
     * @param {Object} Params - Hash with different config options.
     * @param {Array} Params.Callbacks.EditAction - Name of the edit action.
     * @param {Array} Params.Callbacks.PrefSubaction - Name of the preferences subaction.
     * @param {Array} Params.OverviewScreen - Name of the screen (CalendarOverview|ResourceOverview).
     * @param {Object} Params.Calendars - Object with calendar parameters.
     * @param {Array} Params.Calendars.Sources - Array of calendar sources.
     * @description
     *      This method enables/disables calendar source in FullCalendar control and stores
     *      selection to user preferences.
     */
    function CalendarSwitchSource($CalendarSwitch, Params) {
        var CalendarSelection = [];

        // Show/hide the calendar appointments
        if ($CalendarSwitch.prop('checked')) {
            $('#calendar').fullCalendar('addEventSource', Params.Calendars.Sources[$CalendarSwitch.data('id')]);
        } else {
            $('#calendar').fullCalendar('removeEventSource', Params.Calendars.Sources[$CalendarSwitch.data('id')]);
        }

        // Get all checked calendars
        $.each($('.CalendarSwitch input:checked'), function (Index, Element) {
            CalendarSelection.push($(Element).data('id'));
        });

        // Store selection in user preferences
        Core.AJAX.FunctionCall(
            Core.Config.Get('CGIHandle'),
            {
                ChallengeToken: Params.ChallengeToken,
                Action: Params.Callbacks.EditAction ? Params.Callbacks.EditAction : 'AgentAppointmentEdit',
                Subaction: Params.Callbacks.PrefSubaction ? Params.Callbacks.PrefSubaction : 'UpdatePreferences',
                OverviewScreen: Params.OverviewScreen ? Params.OverviewScreen : 'CalendarOverview',
                CalendarSelection: JSON.stringify(CalendarSelection)
            },
            function (Response) {
                if (!Response.Success) {
                    Core.Debug.Log('Error updating user preferences!');
                }
            }
        );
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
            $('#StartHour,#StartMinute,#EndHour,#EndMinute').prop('disabled', true)
                .prop('readonly', true);
        } else {
            $('#StartHour,#StartMinute,#EndHour,#EndMinute').prop('disabled', false)
                .prop('readonly', false);
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
            var Days = [],
                MonthDays = [],
                Months = [],
                Index;

            if ($('input#Days').length) {
                Days = $('input#Days').val().split(',');
            }
            if ($('input#MonthDays').length) {
                MonthDays = $('input#MonthDays').val().split(',');
            }
            if ($('input#MonthDays').length) {
                Months = $('input#Months').val().split(',');
            }

            for (Index = 0; Index < Days.length; Index++) {
                if (Days[Index] != "") {
                    $("#RecurrenceCustomWeeklyDiv button[value=" + Days[Index] + "]")
                        .addClass("fc-state-active");
                }
            }

            for (Index = 0; Index < MonthDays.length; Index++) {
                if (MonthDays[Index] != "") {
                    $("#RecurrenceCustomMonthlyDiv button[value=" + MonthDays[Index] + "]")
                        .addClass("fc-state-active");
                }
            }

            for (Index = 0; Index < Months.length; Index++) {
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
     * @name NotificationInit
     * @memberof Core.Agent.AppointmentCalendar
     * @param {Object} Fields - Array with references to reminder fields.
     * @param {jQueryObject} Fields.$Notification - drop down with system notification selection.
     * @param {jQueryObject} Fields.$NotificationCustomStringDiv - custom selection of system notification date
     * @description
     *      This method initializes the reminder section behavior.
     */
    TargetNS.NotificationInit = function (Fields) {

        if (Fields.$NotificationTemplate.val() !== 'Custom') {

            // hide the custom fields
            Fields.$NotificationCustomStringDiv.hide();
        }
        else {

            // custom field is needed
            Fields.$NotificationCustomStringDiv.show();

            // initialize modern fields on custom selection
            Core.UI.InputFields.InitSelect($('select.Modernize'));
        }

        // disable enable the different custom fields
        if (Fields.$NotificationCustomRelativeInput.prop('checked')) {

            // enable relative date fields
            Fields.$NotificationCustomRelativeInput.val(1);
            Fields.$NotificationCustomRelativeUnitCount.prop('disabled', false);
            Fields.$NotificationCustomRelativeUnit.prop('disabled', false).trigger('redraw.InputField');
            Fields.$NotificationCustomRelativePointOfTime.prop('disabled', false).trigger('redraw.InputField');

            // disable the custom date time fields
            Fields.$NotificationCustomDateTimeInput.val('');
            Fields.$NotificationCustomDateTimeDay.prop('disabled', true);
            Fields.$NotificationCustomDateTimeMonth.prop('disabled', true);
            Fields.$NotificationCustomDateTimeYear.prop('disabled', true);
            Fields.$NotificationCustomDateTimeHour.prop('disabled', true);
            Fields.$NotificationCustomDateTimeMinute.prop('disabled', true);
        }
        else {

            // enable the custom date time input
            Fields.$NotificationCustomDateTimeInput.val(1);
            Fields.$NotificationCustomDateTimeInput.prop('checked', true);
            Fields.$NotificationCustomDateTimeDay.prop('disabled', false);
            Fields.$NotificationCustomDateTimeMonth.prop('disabled', false);
            Fields.$NotificationCustomDateTimeYear.prop('disabled', false);
            Fields.$NotificationCustomDateTimeHour.prop('disabled', false);
            Fields.$NotificationCustomDateTimeMinute.prop('disabled', false);

            // disable relative date fields
            Fields.$NotificationCustomRelativeInput.val('');
            Fields.$NotificationCustomRelativeInput.prop('checked', false);
            Fields.$NotificationCustomRelativeUnitCount.prop('disabled', true);
            Fields.$NotificationCustomRelativeUnit.prop('disabled', true).trigger('redraw.InputField');
            Fields.$NotificationCustomRelativePointOfTime.prop('disabled', true).trigger('redraw.InputField');
        }

        // Register change event handler
        Fields.$NotificationTemplate.off('change.AppointmentCalendar').on('change.AppointmentCalendar', function() {
            TargetNS.NotificationInit(Fields);
        });

        Fields.$NotificationCustomRelativeInput.off('change.AppointmentCalendar').on('change.AppointmentCalendar', function() {

            // handle radio buttons
            Fields.$NotificationCustomRelativeInput.prop('checked', true);
            Fields.$NotificationCustomDateTimeInput.prop('checked', false);

            // process changes
            TargetNS.NotificationInit(Fields);
        });

        Fields.$NotificationCustomDateTimeInput.off('change.AppointmentCalendar').on('change.AppointmentCalendar', function() {

            // handle radio buttons
            Fields.$NotificationCustomDateTimeInput.prop('checked', true);
            Fields.$NotificationCustomRelativeInput.prop('checked', false);

            // process changes
            TargetNS.NotificationInit(Fields);
        });
    }

    /**
     * @name TeamInit
     * @memberof Core.Agent.AppointmentCalendar
     * @param {jQueryObject} $TeamIDObj - field with list of teams.
     * @param {jQueryObject} $ResourceIDObj - field with list of resources.
     * @param {String} ChallengeToken - User challenge token.
     * @param {jQueryObject} $TeamValueObj - field with read only values for team.
     * @param {jQueryObject} $ResourceValueObj - field with read only values for resources.
     * @description
     *      This method initializes team fields behavior.
     */
    TargetNS.TeamInit = function ($TeamIDObj, $ResourceIDObj, ChallengeToken, $TeamValueObj, $ResourceValueObj) {
        $TeamIDObj.off('change.AppointmentCalendar').on('change.AppointmentCalendar', function () {
            var Data = {
                ChallengeToken: ChallengeToken,
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

        function CollapseValues($ValueObj, Values) {
            $ValueObj.html('');
            $.each(Values, function (Index, Value) {
                var Count = Values.length;

                if (Index < 2) {
                    $ValueObj.html($ValueObj.html() + Value + '<br>');
                } else {
                    Values.splice(-Count, 2);
                    $('<a />').attr('href', '#')
                        .addClass('DialogTooltipLink')
                        .text('+' + (Count-2) + ' more')
                        .off('click.AppointmentCalendar')
                        .on('click.AppointmentCalendar', function (Event) {
                            var $TooltipObj,
                                PosX = 0,
                                PosY = 0,
                                TooltipHTML = '<p>' + Values.join('<br>') + '</p>',
                                DocumentVisibleLeft = $(document).scrollLeft() + $(window).width(),
                                DocumentVisibleTop = $(document).scrollTop() + $(window).height(),
                                LastXPosition,
                                LastYPosition;

                            // Close existing tooltips
                            $('.DialogTooltip').remove();

                            if (Event.pageX || Event.pageY) {
                                PosX = Event.pageX;
                                PosY = Event.pageY;
                            } else if (Event.clientX || Event.clientY) {
                                PosX = Event.clientX + document.body.scrollLeft + document.documentElement.scrollLeft;
                                PosY = Event.clientY + document.body.scrollTop + document.documentElement.scrollTop;
                            }

                            // Increase positions so the tooltip do not overlap with mouse pointer
                            PosX += 10;
                            PosY += 5;

                            // Create tooltip object
                            $TooltipObj = $('<div/>').addClass('AppointmentTooltip DialogTooltip Hidden')
                                .offset({
                                    top: PosY,
                                    left: PosX
                                })
                                .html(TooltipHTML)
                                .css('z-index', 4000)
                                .css('width', 'auto')
                                .off('click.AppointmentCalendar')
                                .on('click.AppointmentCalendar', function (Event) {
                                    Event.stopPropagation();
                                })
                                .appendTo('body');

                            // Re-calculate top position if needed
                            LastYPosition = PosY + $TooltipObj.height();
                            if (LastYPosition > DocumentVisibleTop) {
                                PosY = PosY - $TooltipObj.height();
                                $TooltipObj.css('top', PosY + 'px');
                            }

                            // Re-calculate left position if needed
                            LastXPosition = PosX + $TooltipObj.width();
                            if (LastXPosition > DocumentVisibleLeft) {
                                PosX = PosX - $TooltipObj.width() - 30;
                                $TooltipObj.css('left', PosX + 'px');
                            }

                            // Show the tooltip
                            $TooltipObj.fadeIn('fast');

                            // Close tooltip on any outside click
                            $(document).off('click.AppointmentCalendar')
                                .on('click.AppointmentCalendar', function (Event) {
                                    if (!$(Event.target).closest('.DialogTooltipLink').length) {
                                        $('.DialogTooltip').remove();
                                        $(document).off('click.AppointmentCalendar');
                                    }
                                });
                        })
                        .appendTo($ValueObj);
                    return false;
                }
            });
        }

        // Collapse read only values
        if ($TeamValueObj.length) {
            CollapseValues($TeamValueObj, $TeamValueObj.html().split('<br>'));
        }
        if ($ResourceValueObj.length) {
            CollapseValues($ResourceValueObj, $ResourceValueObj.html().split('<br>'));
        }
    }

    /**
     * @private
     * @name CalendarSettingsInit
     * @memberof Core.Agent.AppointmentCalendar
     * @param {Object} Params - Hash with different config options.
     * @param {Array} Params.Callbacks - Array containing names of the callbacks.
     * @param {Array} Params.Callbacks.EditAction - Name of the edit action.
     * @param {Array} Params.Callbacks.PrefSubaction - Name of the preferences subaction.
     * @param {Array} Params.OverviewScreen - Name of the screen (ResourceOverview).
     * @param {String} Params.CalendarSettingsButton - ID of the settings button.
     * @param {String} Params.CalendarSettingsDialogContainer - ID of the settings dialog container.
     * @param {String} Params.CalendarSettingsShow - Show the settings dialog immediately.
     * @description
     *      This method initializes calendar settings behavior.
     */
    function CalendarSettingsInit(Params) {
        var $CalendarSettingsObj = $('#' + Core.App.EscapeSelector(Params.CalendarSettingsButton)),
            $CalendarSettingsDialog = $('#' + Core.App.EscapeSelector(Params.CalendarSettingsDialogContainer));

        // Calendar settings button
        $CalendarSettingsObj.off('click.AppointmentCalendar').on('click.AppointmentCalendar', function (Event) {
            Core.UI.Dialog.ShowContentDialog($CalendarSettingsDialog, Core.Config.Get('AppointmentCalendarTranslationsSettings'), '10px', 'Center', true,
                [
                    {
                        Label: Core.Config.Get('AppointmentCalendarTranslationsSave'),
                        Class: 'Primary',
                        Function: function () {
                            var $ShownAppointments = $('#ShownAppointments'),
                                Data = {
                                    ChallengeToken: Params.ChallengeToken,
                                    Action: Params.Callbacks.EditAction ? Params.Callbacks.EditAction : 'AgentAppointmentEdit',
                                    Subaction: Params.Callbacks.PrefSubaction ? Params.Callbacks.PrefSubaction : 'UpdatePreferences',
                                    OverviewScreen: Params.OverviewScreen ? Params.OverviewScreen : 'CalendarOverview',
                                    ShownAppointments: $ShownAppointments.val()
                                };

                            Core.Agent.AppointmentCalendar.ShowWaitingDialog();

                            Core.AJAX.FunctionCall(
                                Core.Config.Get('CGIHandle'),
                                Data,
                                function (Response) {
                                    if (!Response.Success) {
                                        Core.Debug.Log('Error updating user preferences!');
                                    }
                                    window.location.href = Core.Config.Get('Baselink') + 'Action=AgentAppointment' + (Params.OverviewScreen ? Params.OverviewScreen : 'CalendarOverview');
                                }
                            );
                        }
                    }
                ], true);

            Event.preventDefault();
            Event.stopPropagation();

            return false;
        });

        // Show settings dialog immediately
        if (Params.CalendarSettingsShow) {
            $CalendarSettingsObj.trigger('click.AppointmentCalendar');
        }
    }

    /**
     * @private
     * @name ResourceSettingsInit
     * @memberof Core.Agent.AppointmentCalendar
     * @param {Object} Params - Hash with different config options.
     * @param {Array} Params.Callbacks - Array containing names of the callbacks.
     * @param {Array} Params.Callbacks.EditAction - Name of the edit action.
     * @param {Array} Params.Callbacks.PrefSubaction - Name of the preferences subaction.
     * @param {Array} Params.OverviewScreen - Name of the screen (ResourceOverview).
     * @param {Object} Params.Resources - Object with resources parameters.
     * @param {String} Params.Resources.ResourceSettingsButton - ID of the element for settings button.
     * @param {String} Params.Resources.ResourceSettingsDialogContainer - ID of the element with dialog content.
     * @param {Boolean} Params.Resources.RestoreDefaultSettings - whether to display restore settings button.
     * @description
     *      This method initializes resource settings behavior.
     */
    function ResourceSettingsInit(Params) {
        var $ResourceSettingsObj = $('#' + Core.App.EscapeSelector(Params.Resources.ResourceSettingsButton)),
            $ResourceSettingsDialog = $('#' + Core.App.EscapeSelector(Params.Resources.ResourceSettingsDialogContainer)),
            $RestoreSettingsObj;

        // Resource settings button
        $ResourceSettingsObj.off('click.AppointmentCalendar').on('click.AppointmentCalendar', function (Event) {
            Core.UI.Dialog.ShowContentDialog($ResourceSettingsDialog, Core.Config.Get('AppointmentCalendarTranslationsSettings'), '10px', 'Center', true,
                [
                    {
                        Label: Core.Config.Get('AppointmentCalendarTranslationsSave'),
                        Class: 'Primary',
                        Function: function () {
                            var $ListContainer = $('.AllocationListContainer').find('.AssignedFields'),
                                ShownResources = [],
                                Data = {
                                    ChallengeToken: Params.ChallengeToken,
                                    Action: Params.Callbacks.EditAction ? Params.Callbacks.EditAction : 'AgentAppointmentEdit',
                                    Subaction: Params.Callbacks.PrefSubaction ? Params.Callbacks.PrefSubaction : 'UpdatePreferences',
                                    OverviewScreen: Params.OverviewScreen ? Params.OverviewScreen : 'ResourceOverview',
                                    TeamID: $('#Team').val()
                                };

                            if (isJQueryObject($ListContainer) && $ListContainer.length) {
                                $.each($ListContainer.find('li'), function() {
                                    ShownResources.push($(this).attr('data-fieldname'));
                                });
                            }
                            Data.ShownResources = JSON.stringify(ShownResources);

                            Core.Agent.AppointmentCalendar.ShowWaitingDialog();

                            Core.AJAX.FunctionCall(
                                Core.Config.Get('CGIHandle'),
                                Data,
                                function (Response) {
                                    if (!Response.Success) {
                                        Core.Debug.Log('Error updating user preferences!');
                                    }
                                    location.reload();
                                }
                            );
                        }
                    }
                ], true);

            Event.preventDefault();
            Event.stopPropagation();

            Core.Agent.TableFilters.SetAllocationList();

            return false;
        });

        // Restore settings button
        if (Params.Resources.RestoreDefaultSettings) {
            $RestoreSettingsObj = $('<a />').attr('id', 'RestoreDefaultSettings')
                .attr('href', '#')
                .attr('title', Core.Config.Get('AppointmentCalendarTranslationsRestore'))
                .append($('<i />').addClass('fa fa-trash'));

            // Add it to the column header
            $('tr.fc-super + tr .fc-cell-content').append($RestoreSettingsObj);

            $RestoreSettingsObj.off('click.AppointmentCalendar').on('click.AppointmentCalendar', function (Event) {
                Core.AJAX.FunctionCall(
                    Core.Config.Get('CGIHandle'),
                    {
                        ChallengeToken: Params.ChallengeToken,
                        Action: Params.Callbacks.EditAction ? Params.Callbacks.EditAction : 'AgentAppointmentEdit',
                        Subaction: Params.Callbacks.PrefSubaction ? Params.Callbacks.PrefSubaction : 'UpdatePreferences',
                        OverviewScreen: Params.OverviewScreen ? Params.OverviewScreen : 'ResourceOverview',
                        RestoreDefaultSettings: 'ShownResources',
                        TeamID: $('#Team').val()
                    },
                    function (Response) {
                        if (!Response.Success) {
                            Core.Debug.Log('Error updating user preferences!');
                        }
                        location.reload();
                    }
                );

                Event.preventDefault();
                Event.stopPropagation();

                return false;
            });
        }
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
     * @param {String} ChallengeToken - User challenge token.
     * @description
     *      This method initializes plugin fields behavior.
     */
    TargetNS.PluginInit = function ($PluginFields, ChallengeToken) {

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
                            ChallengeToken: ChallengeToken,
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
            DateCurrent = $.fullCalendar.moment();

        // There is no need to check, since times are rounded to minutes
        if (DateCurrent.second() > 6 && this.Initialized != null) {
            return;
        }

        // Check if another dialog is already open
        if ($("div.Dialog:visible").length > 0) {
            return;
        }

        this.Initialized = true;

        // Iterate through all appointments
        for (Index = 0; Index < Appointments.length; Index++) {
            if (Appointments[Index].start.isBefore(DateCurrent) &&
                DateCurrent.isBefore(Appointments[Index].end)
            ) {
                if (
                    Appointments[Index].shown != null
                    || Appointments[Index].id === 'workingHours'
                    )
                {
                    continue;
                }

                AppointmentIDs.push(Appointments[Index].id);
            }
        }

        // Give up if no appointments found
        if (AppointmentIDs.length === 0) {
            return;
        }

        Data = {
            ChallengeToken: Params.ChallengeToken,
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
