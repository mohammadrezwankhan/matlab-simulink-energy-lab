%% Native Simulink Battery Thermal Example
% Generates, simulates, plots, and opens the electro-thermal diagram.

clear; clc; close all;

modelDirectory = fileparts(mfilename('fullpath'));
referenceDirectory = fullfile(modelDirectory, '..', 'battery-thermal-model');
originalPath = path;
pathCleanup = onCleanup(@() path(originalPath));
addpath(modelDirectory, referenceDirectory);

[modelPath, referenceResult] = build_battery_thermal_simulink_model();
[~, modelName] = fileparts(modelPath);
load_system(modelPath);
simulationOutput = sim(modelName);
current = simulationOutput.get('current_A');
terminalVoltage = simulationOutput.get('terminal_voltage_V');
temperature = simulationOutput.get('cell_temp_C');
heatGeneration = simulationOutput.get('heat_generation_W');

figure('Name', 'Native Simulink Battery Thermal', 'Color', 'w');
tiledlayout(4, 1, 'TileSpacing', 'compact');

nexttile;
stairs(current.Time, current.Data, 'LineWidth', 1.2);
grid on;
ylabel('Current (A)');
title('Applied current');

nexttile;
plot(terminalVoltage.Time, terminalVoltage.Data, 'LineWidth', 1.2);
grid on;
ylabel('Voltage (V)');
title('Terminal voltage');

nexttile;
plot(temperature.Time, temperature.Data, 'LineWidth', 1.2);
grid on;
ylabel('Temperature (degC)');
title('Lumped cell temperature');

nexttile;
plot(heatGeneration.Time, heatGeneration.Data, 'LineWidth', 1.2);
grid on;
xlabel('Time (s)');
ylabel('Heat (W)');
title('Irreversible heat generation');

open_system(modelName);

fprintf('Native Simulink battery thermal example\n');
fprintf('Generated model: %s\n', modelPath);
fprintf('Peak cell temperature: %.2f degC\n', max(temperature.Data));
fprintf('Final cell temperature: %.2f degC\n', temperature.Data(end));
fprintf('Reference final SOC: %.3f\n', referenceResult.soc(end));
