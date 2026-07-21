%% Native Simulink Battery 2RC Example
% Generates, simulates, plots, and opens the two-RC block diagram.

clear; clc; close all;

modelDirectory = fileparts(mfilename('fullpath'));
referenceDirectory = fullfile(modelDirectory, '..', 'battery-2rc-model');
baseReferenceDirectory = fullfile(modelDirectory, '..', 'battery-rc-model');
originalPath = path;
pathCleanup = onCleanup(@() path(originalPath));
addpath(modelDirectory, referenceDirectory, baseReferenceDirectory);

[modelPath, referenceResult] = build_battery_2rc_simulink_model();
[~, modelName] = fileparts(modelPath);
load_system(modelPath);
simulationOutput = sim(modelName);
current = simulationOutput.get('current_A');
soc = simulationOutput.get('soc');
fastPolarization = simulationOutput.get('v_rc1_V');
slowPolarization = simulationOutput.get('v_rc2_V');
terminalVoltage = simulationOutput.get('terminal_voltage_V');

figure('Name', 'Native Simulink Battery 2RC', 'Color', 'w');
tiledlayout(4, 1, 'TileSpacing', 'compact');

nexttile;
stairs(current.Time, current.Data, 'LineWidth', 1.2);
grid on;
ylabel('Current (A)');
title('Applied pulse profile');

nexttile;
plot(soc.Time, soc.Data, 'LineWidth', 1.2);
grid on;
ylabel('SOC (-)');

nexttile;
plot(terminalVoltage.Time, terminalVoltage.Data, 'LineWidth', 1.2);
grid on;
ylabel('Voltage (V)');
title('Terminal voltage');

nexttile;
plot(fastPolarization.Time, fastPolarization.Data, 'LineWidth', 1.2);
hold on;
plot(slowPolarization.Time, slowPolarization.Data, 'LineWidth', 1.2);
grid on;
xlabel('Time (s)');
ylabel('Voltage (V)');
legend('Fast R1-C1', 'Slow R2-C2', 'Location', 'best');
title('Polarization branch states');

open_system(modelName);

fprintf('Native Simulink battery 2RC example\n');
fprintf('Generated model: %s\n', modelPath);
fprintf('Final SOC: %.3f\n', soc.Data(end));
fprintf('Voltage range: %.3f V to %.3f V\n', ...
    min(terminalVoltage.Data), max(terminalVoltage.Data));
fprintf('Reference final SOC: %.3f\n', referenceResult.soc(end));
