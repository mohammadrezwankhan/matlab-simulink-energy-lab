%% Battery Module Liquid-Cooling Network
% Runs and plots the validated six-cell thermal-network reference.

clear; clc; close all;

modelDirectory = fileparts(mfilename('fullpath'));
originalPath = path;
pathCleanup = onCleanup(@() path(originalPath));
addpath(modelDirectory);

profile = battery_module_cooling_default_profile();
parameters = battery_module_cooling_default_parameters();
result = simulate_battery_module_cooling_network( ...
    profile, parameters, 1);

figure('Name', 'Battery Module Liquid-Cooling Network', 'Color', 'w');
tiledlayout(4, 1, 'TileSpacing', 'compact');

nexttile;
stairs(result.time_s, result.module_heat_generation_W, 'LineWidth', 1.2);
grid on;
ylabel('Heat [W]');
title('Module Heat Generation');

nexttile;
plot(result.time_s, result.cell_temp_C, 'LineWidth', 1.1);
grid on;
ylabel('Temperature [degC]');
title('Cell Temperatures Along the Coolant Path');
legend(compose('Cell %d', 1:parameters.cell_count), ...
    'Location', 'eastoutside');

nexttile;
plot(result.time_s, result.coolant_supply_temp_C, ...
    'LineWidth', 1.2);
hold on;
plot(result.time_s, result.coolant_module_outlet_temp_C, ...
    'LineWidth', 1.2);
grid on;
ylabel('Temperature [degC]');
title('Coolant Supply and Module Outlet');
legend('Supply', 'Module outlet', 'Location', 'best');

nexttile;
plot(result.time_s, result.cell_temperature_spread_C, ...
    'LineWidth', 1.2);
grid on;
xlabel('Time [s]');
ylabel('Spread [degC]');
title('Cell Temperature Nonuniformity');

fprintf('Battery module cooling-network simulation complete.\n');
fprintf('Peak cell temperature: %.2f degC (cell %d at %.0f s)\n', ...
    result.peak_cell_temp_C, result.hottest_cell_index, ...
    result.peak_time_s);
fprintf('Peak cell-temperature spread: %.2f degC\n', ...
    result.peak_temperature_spread_C);
fprintf('Peak coolant outlet temperature: %.2f degC\n', ...
    result.peak_coolant_outlet_temp_C);
fprintf('Module energy-balance error: %.3e J\n', ...
    result.energy_balance_error_J);
