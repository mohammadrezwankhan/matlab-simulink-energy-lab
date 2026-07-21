%% Battery RC Model Example
% Simulates the canonical pulse profile and plots current, SOC, and voltage.

clear; clc; close all;

modelDirectory = fileparts(mfilename('fullpath'));
originalPath = path;
pathCleanup = onCleanup(@() path(originalPath));
addpath(modelDirectory);

profilePath = fullfile(modelDirectory, 'data', 'pulse_current_profile.csv');
profile = readtable(profilePath);
parameters = battery_rc_default_parameters();
result = simulate_battery_rc_model(profile, parameters, 1);

figure('Name', 'Battery RC Model', 'Color', 'w');
tiledlayout(3, 1, 'TileSpacing', 'compact');

nexttile;
plot(result.time_s, result.current_A, 'LineWidth', 1.2);
if any(result.current_limited)
    hold on;
    plot(result.time_s, result.requested_current_A, '--', 'LineWidth', 1.0);
    legend('Applied', 'Requested', 'Location', 'best');
end
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
xlabel('Time [s]');
ylabel('Voltage [V]');
title('Terminal Voltage');

fprintf('Final SOC: %.3f\n', result.soc(end));
fprintf('Voltage range: %.3f V to %.3f V\n', ...
    min(result.terminal_voltage_V), max(result.terminal_voltage_V));
fprintf('SOC-limited current samples: %d\n', nnz(result.current_limited));
