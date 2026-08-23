function [checks, requiresSimulink] = validation_check_catalog( ...
    includeBess, includeSimulink)
%VALIDATION_CHECK_CATALOG Return the ordered repository check entry points.

if nargin < 1
    includeBess = true;
end
if nargin < 2
    includeSimulink = true;
end
validateattributes(includeBess, {'logical', 'numeric'}, ...
    {'scalar', 'real', 'finite'});
validateattributes(includeSimulink, {'logical', 'numeric'}, ...
    {'scalar', 'real', 'finite'});
if ~ismember(includeSimulink, [0, 1])
    error('ValidationCatalog:IncludeSimulink', ...
        'includeSimulink must be logical true or false.');
end
checks = [
    "battery-rc-model/check_battery_rc_model.m";
    "battery-simulink-model/check_battery_rc_simulink_model.m";
    "battery-2rc-model/check_battery_2rc_model.m";
    "battery-2rc-model/check_battery_2rc_fit.m";
    "battery-2rc-simulink-model/check_battery_2rc_simulink_model.m";
    "battery-soc-ekf/check_battery_soc_ekf.m";
    "battery-soc-ekf/check_battery_soc_ekf_current_bias.m";
    "battery-ocv-hysteresis/check_battery_ocv_hysteresis.m";
    "battery-soc-hysteresis-ekf/check_battery_soc_hysteresis_ekf.m";
    "battery-thermal-model/check_battery_thermal_model.m";
    "battery-thermal-model/check_battery_cooling_sensitivity.m";
    "battery-module-cooling-network/check_battery_module_cooling_network.m";
    "pouch-cell-thermal-gradient/check_pouch_cell_thermal_model.m";
    "battery-thermal-simulink-model/check_battery_thermal_simulink_model.m";
    "converter-average-model/check_converter_average_model.m";
    "converter-closed-loop-model/check_closed_loop_converter.m";
    "converter-closed-loop-model/check_converter_controller_comparison.m";
    "converter-switching-model/check_switching_buck_converter.m";
    "converter-switching-closed-loop-model/check_switching_closed_loop_buck.m";
    "converter-switching-closed-loop-model/check_switching_closed_loop_buck_temperature_sensitivity.m";
    "converter-switching-closed-loop-simulink-model/check_switching_closed_loop_buck_simulink_model.m";
    "converter-simulink-model/check_average_buck_simulink_model.m";
    "bess-dc-reserve-model/check_bess_dc_reserve.m";
    "bess-dc-reserve-model/check_bess_dc_reserve_envelope.m";
    "bess-dc-reserve-model/check_bess_dc_reserve_profile_sensitivity.m"
];
requiresSimulink = logical([
    0; 1; 0; 0; 1; 0; 0; 0; 0; 0; 0; 0;
    0; 1; 0; 0; 0; 0; 0; 0; 1; 1; 0; 0; 0
]);
if logical(includeBess)
    checks(end + 1) = ...
        "bess-unified-control/check_bess_unified_control.m";
    requiresSimulink(end + 1) = true;
end
if ~logical(includeSimulink)
    checks = checks(~requiresSimulink);
    requiresSimulink = requiresSimulink(~requiresSimulink);
end
end
