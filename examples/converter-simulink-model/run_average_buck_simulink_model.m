%% Native Simulink Averaged Buck Example
% Generates the model, simulates startup, and opens the block diagram.

clear; clc; close all;

modelDirectory = fileparts(mfilename('fullpath'));
addpath(modelDirectory);

parameters = average_buck_simulink_parameters();
modelPath = build_average_buck_simulink_model();
[~, modelName] = fileparts(modelPath);
load_system(modelPath);
simulationOutput = sim(modelName);
inductorCurrent = simulationOutput.get('inductor_current');
outputVoltage = simulationOutput.get('output_voltage');

figure('Name', 'Native Simulink Averaged Buck', 'Color', 'w');
tiledlayout(2, 1, 'TileSpacing', 'compact');

nexttile;
plot(outputVoltage.Time, outputVoltage.Data, 'LineWidth', 1.3);
grid on;
ylabel('Voltage (V)');
title('Averaged buck startup');

nexttile;
plot(inductorCurrent.Time, inductorCurrent.Data, 'LineWidth', 1.3);
grid on;
xlabel('Time (s)');
ylabel('Current (A)');

open_system(modelName);

fprintf('Native Simulink averaged buck example\n');
fprintf('Generated model: %s\n', modelPath);
fprintf('Final output voltage: %.3f V\n', outputVoltage.Data(end));
fprintf('Final inductor current: %.3f A\n', ...
    inductorCurrent.Data(end));
fprintf('Lossy steady-state expectation: %.3f V\n', ...
    parameters.duty_cycle * parameters.input_voltage_V / ...
    (1 + parameters.inductor_resistance_Ohm / ...
    parameters.load_resistance_Ohm));
