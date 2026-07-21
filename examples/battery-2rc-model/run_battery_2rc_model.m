%% Battery 2RC Model Example
% Plots a pulse response with fast and slow polarization branches.

clear; clc; close all;

modelDirectory = fileparts(mfilename('fullpath'));
baseModelDirectory = fullfile(fileparts(modelDirectory), 'battery-rc-model');
originalPath = path;
pathCleanup = onCleanup(@() path(originalPath));
addpath(modelDirectory, baseModelDirectory);

profilePath = fullfile(baseModelDirectory, 'data', ...
    'pulse_current_profile.csv');
profile = readtable(profilePath);
parameters = battery_2rc_default_parameters();
result = simulate_battery_2rc_model(profile, parameters, 1);

figure('Name', 'Battery 2RC Model', 'Color', 'w');
tiledlayout(4, 1, 'TileSpacing', 'compact');

nexttile;
plot(result.time_s, result.current_A, 'LineWidth', 1.2);
grid on;
ylabel('Current [A]');
title('Applied Current Profile');

nexttile;
plot(result.time_s, result.soc, 'LineWidth', 1.2);
grid on;
ylabel('SOC [-]');
title('State of Charge');

nexttile;
plot(result.time_s, result.terminal_voltage_V, 'LineWidth', 1.2);
grid on;
ylabel('Voltage [V]');
title('Terminal Voltage');

nexttile;
plot(result.time_s, result.v_rc1_V, 'LineWidth', 1.2);
hold on;
plot(result.time_s, result.v_rc2_V, 'LineWidth', 1.2);
grid on;
xlabel('Time [s]');
ylabel('Voltage [V]');
legend('Fast R1-C1', 'Slow R2-C2', 'Location', 'best');
title('Polarization Branch States');

fprintf('Final SOC: %.3f\n', result.soc(end));
fprintf('Voltage range: %.3f V to %.3f V\n', ...
    min(result.terminal_voltage_V), max(result.terminal_voltage_V));
fprintf('Peak polarization: fast %.3f V, slow %.3f V\n', ...
    max(abs(result.v_rc1_V)), max(abs(result.v_rc2_V)));
