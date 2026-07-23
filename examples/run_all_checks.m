function run_all_checks()
%RUN_ALL_CHECKS Execute every no-plot example check in isolation.
% Each check is a script that clears its local variables. A dedicated local
% function isolates that cleanup from this loop.

examplesDirectory = fileparts(mfilename('fullpath'));
checks = {
    'battery-rc-model/check_battery_rc_model.m';
    'battery-simulink-model/check_battery_rc_simulink_model.m';
    'battery-2rc-model/check_battery_2rc_model.m';
    'battery-2rc-simulink-model/check_battery_2rc_simulink_model.m';
    'battery-soc-ekf/check_battery_soc_ekf.m';
    'battery-thermal-model/check_battery_thermal_model.m';
    'battery-thermal-model/check_battery_cooling_sensitivity.m';
    'battery-module-cooling-network/check_battery_module_cooling_network.m';
    'battery-thermal-simulink-model/check_battery_thermal_simulink_model.m';
    'converter-average-model/check_converter_average_model.m';
    'converter-closed-loop-model/check_closed_loop_converter.m';
    'converter-closed-loop-model/check_converter_controller_comparison.m';
    'converter-switching-model/check_switching_buck_converter.m';
    'converter-simulink-model/check_average_buck_simulink_model.m'
};

for checkIndex = 1:numel(checks)
    checkPath = fullfile(examplesDirectory, checks{checkIndex});
    fprintf('\n[%d/%d] Running %s\n', ...
        checkIndex, numel(checks), checks{checkIndex});
    run_check_script(checkPath);
end

fprintf('\nAll %d MATLAB and Simulink checks passed.\n', numel(checks));
end

function run_check_script(checkPath)
run(checkPath);
end
