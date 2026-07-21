%% Temperature-Aware Battery Model
% Runs and plots the validated discrete electro-thermal reference.

clear; clc; close all;

modelDirectory = fileparts(mfilename('fullpath'));
originalPath = path;
pathCleanup = onCleanup(@() path(originalPath));
addpath(modelDirectory);

profile = battery_thermal_default_profile();
parameters = battery_thermal_default_parameters();
result = simulate_battery_thermal_model(profile, parameters, 1);

figure('Name', 'Temperature-Aware Battery Model', 'Color', 'w');
tiledlayout(4, 1, 'TileSpacing', 'compact');

nexttile;
stairs(result.time_s, result.current_A, 'LineWidth', 1.2);
grid on;
ylabel('Current [A]');
title('Applied Current');

nexttile;
plot(result.time_s, result.terminal_voltage_V, 'LineWidth', 1.2);
grid on;
ylabel('Voltage [V]');
title('Terminal Voltage');

nexttile;
plot(result.time_s, result.cell_temp_C, 'LineWidth', 1.2);
grid on;
ylabel('Temperature [degC]');
title('Lumped Cell Temperature');

nexttile;
plot(result.time_s, result.heat_generation_W, 'LineWidth', 1.2);
grid on;
xlabel('Time [s]');
ylabel('Heat [W]');
title('Irreversible Heat Generation');

fprintf('Peak cell temperature: %.2f degC\n', max(result.cell_temp_C));
fprintf('Final cell temperature: %.2f degC\n', result.cell_temp_C(end));
fprintf('Peak irreversible heat: %.2f W\n', ...
    max(result.heat_generation_W));
fprintf('Final SOC: %.3f\n', result.soc(end));
