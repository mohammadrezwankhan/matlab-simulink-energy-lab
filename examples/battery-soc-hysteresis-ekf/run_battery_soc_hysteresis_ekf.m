clear;
close all;
clc;

modelDirectory = fileparts(mfilename('fullpath'));
originalPath = path;
pathCleanup = onCleanup(@() path(originalPath));
addpath(modelDirectory);

result = simulate_battery_soc_hysteresis_ekf_example();
truth = result.truth;
hysteresisEstimate = result.hysteresis_estimate;
baselineEstimate = result.baseline_estimate;
metrics = result.metrics;

figure('Name', 'Battery SOC Hysteresis EKF', ...
    'Position', [100, 100, 1200, 820]);
tiledlayout(2, 2);

nexttile;
plot(truth.time_s, truth.soc, 'LineWidth', 1.4);
hold on;
plot(hysteresisEstimate.time_s, hysteresisEstimate.soc, '--', ...
    'LineWidth', 1.2);
plot(baselineEstimate.time_s, baselineEstimate.soc, ':', ...
    'LineWidth', 1.2);
grid on;
ylabel('SOC [-]');
legend('Truth', 'Hysteresis EKF', 'Two-state baseline', ...
    'Location', 'best');
title('SOC Estimation Under Current Reversals');

nexttile;
plot(truth.time_s, truth.hysteresis_state, 'LineWidth', 1.4);
hold on;
plot(hysteresisEstimate.time_s, ...
    hysteresisEstimate.hysteresis_state, '--', 'LineWidth', 1.2);
grid on;
ylabel('Hysteresis state [-]');
legend('Truth', 'Estimate', 'Location', 'best');
title('Dynamic Hysteresis-State Tracking');

nexttile;
plot(truth.time_s, ...
    100*(hysteresisEstimate.soc - truth.soc), 'LineWidth', 1.1);
hold on;
plot(truth.time_s, ...
    100*(baselineEstimate.soc - truth.soc), ':', 'LineWidth', 1.2);
grid on;
xlabel('Time [s]');
ylabel('SOC error [percentage points]');
legend('Hysteresis EKF', 'Two-state baseline', 'Location', 'best');
title('Error Caused by an Omitted Hysteresis State');

nexttile;
yyaxis left;
plot(truth.time_s, 1000*hysteresisEstimate.innovation_V, ...
    'LineWidth', 1.0);
hold on;
plot(truth.time_s, 1000*baselineEstimate.innovation_V, ':', ...
    'LineWidth', 1.0);
ylabel('Innovation [mV]');
yyaxis right;
stairs(truth.time_s, truth.current_A, 'LineWidth', 1.0);
ylabel('Current [A]');
grid on;
xlabel('Time [s]');
title('Voltage Innovation and Applied Current');
legend('Hysteresis EKF', 'Two-state baseline', 'Current', ...
    'Location', 'best');

fprintf('Battery SOC hysteresis EKF example complete.\n');
fprintf('SOC RMSE: hysteresis %.4f, baseline %.4f\n', ...
    metrics.hysteresis_soc_rmse, metrics.baseline_soc_rmse);
fprintf('Final SOC error: hysteresis %+.4f, baseline %+.4f\n', ...
    metrics.hysteresis_final_soc_error, metrics.baseline_final_soc_error);
fprintf('Hysteresis-state RMSE: %.4f\n', metrics.hysteresis_state_rmse);
fprintf('Voltage RMSE: hysteresis %.3f mV, baseline %.3f mV\n', ...
    1000*metrics.hysteresis_voltage_rmse_V, ...
    1000*metrics.baseline_voltage_rmse_V);
