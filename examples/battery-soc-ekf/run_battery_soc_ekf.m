clear;
close all;
clc;

modelDirectory = fileparts(mfilename('fullpath'));
originalPath = path;
pathCleanup = onCleanup(@() path(originalPath));
addpath(modelDirectory);

result = simulate_battery_soc_ekf_example();
truth = result.truth;
estimate = result.estimate;
metrics = result.metrics;
socStandardDeviation = squeeze(sqrt(estimate.covariance(1, 1, :)));

figure('Name', 'Battery SOC EKF');
tiledlayout(3, 1);

nexttile;
plot(truth.time_s, truth.soc, 'LineWidth', 1.4);
hold on;
plot(estimate.time_s, estimate.soc, '--', 'LineWidth', 1.2);
plot(estimate.time_s, estimate.soc + 2 * socStandardDeviation, ...
    ':', 'LineWidth', 0.9);
plot(estimate.time_s, estimate.soc - 2 * socStandardDeviation, ...
    ':', 'LineWidth', 0.9);
grid on;
ylabel('SOC [-]');
legend('Truth', 'EKF', '+2 sigma', '-2 sigma', 'Location', 'best');
title('State-of-Charge Convergence');

nexttile;
plot(truth.time_s, truth.terminal_voltage_V, 'LineWidth', 1.2);
hold on;
plot(estimate.time_s, result.measured_voltage_V, '.', ...
    'MarkerSize', 3);
plot(estimate.time_s, estimate.terminal_voltage_V, '--', ...
    'LineWidth', 1.1);
grid on;
ylabel('Voltage [V]');
legend('Truth', 'Measured', 'EKF posterior', 'Location', 'best');
title('Terminal-Voltage Correction');

nexttile;
yyaxis left;
plot(estimate.time_s, 100 * (estimate.soc - truth.soc), ...
    'LineWidth', 1.0);
yline(2, ':', 'LineWidth', 0.9);
yline(-2, ':', 'LineWidth', 0.9);
ylabel('SOC error [percentage points]');
yyaxis right;
stairs(estimate.time_s, estimate.current_A, 'LineWidth', 1.0);
ylabel('Current [A]');
grid on;
xlabel('Time [s]');
title('SOC Estimation Error and Applied Current');

fprintf('Battery SOC EKF example complete.\n');
fprintf('Initial prior SOC error: %+.3f\n', ...
    metrics.initial_prior_soc_error);
fprintf('First posterior SOC error: %+.3f\n', ...
    metrics.initial_posterior_soc_error);
fprintf('Final SOC error: %+.4f\n', metrics.final_soc_error);
fprintf('SOC RMSE: %.4f\n', metrics.soc_rmse);
fprintf('Two-percent settling time: %.0f s\n', ...
    metrics.soc_settling_time_s);
fprintf('Posterior voltage RMSE: %.3f mV\n', ...
    1000 * metrics.voltage_rmse_V);
