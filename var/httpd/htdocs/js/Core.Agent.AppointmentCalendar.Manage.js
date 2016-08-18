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
Core.Agent.AppointmentCalendar = Core.Agent.AppointmentCalendar || {};

/**
 * @namespace Core.Agent.AppointmentCalendar.Manage
 * @memberof Core.Agent.AppointmentCalendar
 * @author OTRS AG
 * @description
 *      This namespace contains the appointment calendar management functions.
 */
Core.Agent.AppointmentCalendar.Manage = (function (TargetNS) {

    var RuleCount = 0;

    /**
     * @name InitTicketAppointments
     * @memberof Core.Agent.AppointmentCalendar.Manage
     * @param {Integer} InitialRuleCount - From which rule the count should start (optional)
     * @description
     *      Initialize the ticket appointment fields behavior.
     */
    TargetNS.InitTicketAppointments = function (InitialRuleCount) {
        var $AddRuleObj = $('#AddRuleButton'),
            $TemplateObj = $('#TicketAppointmentRulesTemplate'),
            $AdvancedParamTemplateObj = $('#TicketAppointmentAdvancedParamTemplate');

        if (InitialRuleCount) {
            RuleCount = InitialRuleCount;
        }

        $AddRuleObj.off('click.AppointmentCalendar').on('click.AppointmentCalendar', function () {
            var RuleID = ++RuleCount,
                $RuleObj = $($TemplateObj.html()),
                $ContainerObj = $AddRuleObj.parents('fieldset'),
                $RemoveObj = $RuleObj.find('legend .RemoveButton'),
                $ParamObj = $RuleObj.find('#AdvancedParams'),
                $AddParamObj = $RuleObj.find('.AddButton');

            $RuleObj

                // Rule number
                .find('.RuleNumber')
                .text(RuleID)
                .end()

                // Start date field and label
                .find('#StartDate')
                .attr('id', 'StartDate_' + RuleID)
                .attr('name', 'StartDate_' + RuleID)
                .parent()
                .prev('label')
                .attr('for', 'StartDate_' + RuleID)
                .end()
                .end()
                .end()

                // End date field and label
                .find('#EndDate')
                .attr('id', 'EndDate_' + RuleID)
                .attr('name', 'EndDate_' + RuleID)
                .parent()
                .prev('label')
                .attr('for', 'EndDate_' + RuleID)
                .end()
                .end()
                .end()

                // Queues field, label and error
                .find('#QueueID')
                .attr('id', 'QueueID_' + RuleID)
                .attr('name', 'QueueID_' + RuleID)
                .end()
                .find('label[for="QueueID"]')
                .attr('for', 'QueueID_' + RuleID)
                .end()
                .find('#QueueIDError')
                .attr('id', 'QueueID_' + RuleID + 'Error')
                .end()

                .insertBefore($ContainerObj);

            Core.UI.InputFields.Activate($RuleObj);

            $RemoveObj.off('click.AppointmentCalendar').on('click.AppointmentCalendar', function () {
                $RuleObj.remove();
                return false;
            });

            $AddParamObj.off('click.AppointmentCalendar').on('click.AppointmentCalendar', function () {
                var $AdvancedParamObj = $($AdvancedParamTemplateObj.html()),
                    $AdvancedParamContainerObj = $RuleObj.find('.AdvancedParamsContainer'),
                    $RemoveParamObj = $AdvancedParamObj.find('.RemoveButton'),
                    ParamName = $ParamObj.val();

                if (!ParamName) {
                    return false;
                }

                $ParamObj.find('option[value="' + ParamName + '"]')
                    .prop('disabled', true)
                    .end()
                    .val($ParamObj.find('option:enabled').first().attr('value'))
                    .trigger('redraw.InputField');

                $AdvancedParamObj

                    // Label
                    .find('label')
                    .attr('for', 'AdvancedParam_' + RuleID + '_' + ParamName)
                    .find('span')
                    .after(' ' + ParamName + ':')
                    .end()
                    .end()

                    // Input field and error message
                    .find('input')
                    .attr('id', 'AdvancedParam_' + RuleID + '_' + ParamName)
                    .attr('name', 'AdvancedParam_' + RuleID + '_' + ParamName)
                    .end()
                    .find('#AdvancedParamError')
                    .attr('id', 'AdvancedParam_' + RuleID + '_' + ParamName + 'Error')
                    .end()

                    .appendTo($AdvancedParamContainerObj);

                    $RemoveParamObj.off('click.AppointmentCalendar').on('click.AppointmentCalendar', function () {
                        $AdvancedParamObj.remove();
                        $ParamObj.find('option[value="' + ParamName + '"]')
                            .prop('disabled', false)
                            .end()
                            .val($ParamObj.find('option:enabled').first().attr('value'))
                            .trigger('redraw.InputField');

                        return false;
                    });

                return false;
            });

            return false;
        });
    }

    return TargetNS;
}(Core.Agent.AppointmentCalendar.Manage || {}));
