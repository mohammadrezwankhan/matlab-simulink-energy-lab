%% Battery 2RC Parameter Identification Example
% Fits a deterministic calibration record and evaluates a held-out profile.

clear; clc; close all;

modelDirectory = fileparts(mfilename('fullpath'));
originalPath = path;
pathCleanup = onCleanup(@() path(originalPath));
addpath(modelDirectory);

scenario = build_battery_2rc_fit_scenario();
fitResult = fit_battery_2rc_parameters( ...
    scenario.calibration_data, scenario.initial_parameters);
calibrationEvaluation = evaluate_battery_2rc_fit( ...
    scenario.calibration_data, fitResult.parameters);
validationEvaluation = evaluate_battery_2rc_fit( ...
    scenario.validation_data, fitResult.parameters);

split = ["Calibration"; "Held-out validation"];
rmse_mV = 1000*[
    calibrationEvaluation.metrics.rmse_V;
    validationEvaluation.metrics.rmse_V
];
mae_mV = 1000*[
    calibrationEvaluation.metrics.mae_V;
    validationEvaluation.metrics.mae_V
];
maximumError_mV = 1000*[
    calibrationEvaluation.metrics.maximum_absolute_error_V;
    validationEvaluation.metrics.maximum_absolute_error_V
];
fitMetrics = table(split, rmse_mV, mae_mV, maximumError_mV);
disp(fitMetrics);

fprintf('Estimated R0: %.4f Ohm\n', fitResult.parameters.r0_Ohm);
fprintf('Estimated fast branch: R1 %.4f Ohm, tau1 %.2f s\n', ...
    fitResult.parameters.r1_Ohm, ...
    fitResult.parameters.r1_Ohm*fitResult.parameters.c1_F);
fprintf('Estimated slow branch: R2 %.4f Ohm, tau2 %.2f s\n', ...
    fitResult.parameters.r2_Ohm, ...
    fitResult.parameters.r2_Ohm*fitResult.parameters.c2_F);

fitFigure = figure( ...
    'Name', 'Battery 2RC Identification', ...
    'Color', 'w', ...
    'Position', [100, 100, 1000, 700]);
tiledlayout(2, 2, 'TileSpacing', 'compact');

nexttile;
plot(scenario.calibration_data.time_s, ...
    scenario.calibration_data.terminal_voltage_V, ...
    'LineWidth', 1.1);
hold on;
plot(scenario.calibration_data.time_s, ...
    calibrationEvaluation.predicted_terminal_voltage_V, ...
    '--', 'LineWidth', 1.1);
grid on;
xlabel('Time [s]');
ylabel('Voltage [V]');
title('Calibration Record');
legend('Synthetic measurement', 'Fitted model', 'Location', 'best');

nexttile;
plot(scenario.calibration_data.time_s, ...
    1000*calibrationEvaluation.residual_V, ...
    'LineWidth', 1.0);
grid on;
xlabel('Time [s]');
ylabel('Residual [mV]');
title('Calibration Residual');

nexttile;
plot(scenario.validation_data.time_s, ...
    scenario.validation_data.terminal_voltage_V, ...
    'LineWidth', 1.1);
hold on;
plot(scenario.validation_data.time_s, ...
    validationEvaluation.predicted_terminal_voltage_V, ...
    '--', 'LineWidth', 1.1);
grid on;
xlabel('Time [s]');
ylabel('Voltage [V]');
title('Held-Out Profile');
legend('Synthetic measurement', 'Fitted model', 'Location', 'best');

nexttile;
plot(scenario.validation_data.time_s, ...
    1000*validationEvaluation.residual_V, ...
    'LineWidth', 1.0);
grid on;
xlabel('Time [s]');
ylabel('Residual [mV]');
title('Held-Out Residual');
