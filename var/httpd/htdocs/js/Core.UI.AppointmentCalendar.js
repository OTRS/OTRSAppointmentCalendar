// --
// Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
// --
// This software comes with ABSOLUTELY NO WARRANTY. For details, see
// the enclosed file COPYING for license information (AGPL). If you
// did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
// --

"use strict";

var Core = Core || {};
Core.UI = Core.UI || {};

/**
 * @namespace Core.UI.AppointmentCalendar
 * @memberof Core.UI
 * @author OTRS AG
 * @description
 *      This namespace contains the appointment calendar functions.
 */
Core.UI.AppointmentCalendar = (function (TargetNS) {

    /**
     * @name Init
     * @memberof Core.UI.AppointmentCalendar
     * @function
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
     * @param {Array} Params.Events - Array of hashes including the data for each event.
     * @description
     *      Initializes the appointment calendar control.
     */
    TargetNS.Init = function (Params) {
        $('#calendar').fullCalendar({
            header: {
                left: 'month,agendaWeek,agendaDay timeline',
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
            aspectRatio: 2.5,
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
                    duration: { days: 5 },
                    slotLabelFormat: [
                        'ddd, D MMM',
                        'HH'
                    ]
                }
            },
            // eventMouseover: function(calEvent, jsEvent) {
                // var Layer, PosX, PosY, DocumentVisible, ContainerHeight,
                //     LastYPosition, VisibleScrollPosition, WindowHeight;
                //
                // // define PosX and PosY
                // // should contain the mouse position relative to the document
                // PosX = 0;
                // PosY = 0;
                //
                // if (!jsEvent) {
                //     jsEvent = window.event;
                // }
                // if (jsEvent.pageX || jsEvent.pageY) {
                //
                //     PosX = jsEvent.pageX;
                //     PosY = jsEvent.pageY;
                // }
                // else if (jsEvent.clientX || jsEvent.clientY) {
                //
                //     PosX = jsEvent.clientX + document.body.scrollLeft + document.documentElement.scrollLeft;
                //     PosY = jsEvent.clientY + document.body.scrollTop + document.documentElement.scrollTop;
                // }
                //
                // // increase X position to don't be overlapped by mouse pointer
                // PosX = PosX + 15;
                //
                // Layer =
                // '<div id="events-layer" class="Hidden" style="position:absolute; top: ' + PosY + 'px; left:' + PosX + 'px; z-index: 999;"> ' +
                // '    <div class="EventDetails">' +
                //          $('#event-content-' + calEvent.id).html() +
                // '    </div> ' +
                // '</div> ';
                //
                // $(Layer).appendTo('body');
                //
                // // re-calculate Top position if needed
                // VisibleScrollPosition = $(document).scrollTop();
                // WindowHeight = $(window).height();
                // DocumentVisible = VisibleScrollPosition + WindowHeight;
                //
                // ContainerHeight = $('#events-layer').height();
                // LastYPosition = PosY + ContainerHeight;
                // if (LastYPosition > DocumentVisible) {
                //     PosY = PosY - (LastYPosition - DocumentVisible) - 10;
                //     $('#events-layer').css('top', PosY + 'px');
                // }
                //
                // $('#events-layer').fadeIn("fast");
            //},
            // eventMouseout: function() {
            //     $('#events-layer').fadeOut("fast");
            //     $('#events-layer').remove();
            // },
            events: Params.Events
        });
    };

    return TargetNS;
}(Core.UI.AppointmentCalendar || {}));
