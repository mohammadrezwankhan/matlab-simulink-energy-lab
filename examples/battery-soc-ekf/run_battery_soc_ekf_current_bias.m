clear;
close all;
clc;

modelDirectory = fileparts(mfilename('fullpath'));
originalPath = path;
pathCleanup = onCleanup(@() path(originalPath));
addpath(modelDirectory);

sensitivity = evaluate_battery_soc_ekf_current_bias();
bias_A = sensitivity.current_bias_A;

figure('Color', 'w');
tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

nexttile;
plot(bias_A, 100*sensitivity.soc_rmse, 'o-', 'LineWidth', 1.4);
grid on;
xlabel('Current-sensor bias (A)');
ylabel('SOC RMSE (percentage points)');
title('Whole-profile SOC error');

nexttile;
plot(bias_A, 100*sensitivity.final_soc_error, 'o-', 'LineWidth', 1.4);
yline(0, '--k');
grid on;
xlabel('Current-sensor bias (A)');
ylabel('Final SOC error (percentage points)');
title('Signed final error');

nexttile;
plot(bias_A, sensitivity.voltage_rmse_mV, ...
    'o-', 'LineWidth', 1.4);
hold on;
plot(bias_A, sensitivity.innovation_rms_mV, ...
    's-', 'LineWidth', 1.4);
grid on;
xlabel('Current-sensor bias (A)');
ylabel('Voltage metric (mV)');
legend('Posterior voltage RMSE', 'Innovation RMS', ...
    'Location', 'northwest');
title('Voltage evidence');

nexttile;
plot(bias_A, sensitivity.mean_normalized_innovation_squared, ...
    'o-', 'LineWidth', 1.4);
grid on;
xlabel('Current-sensor bias (A)');
ylabel('Mean normalized innovation squared');
title('Filter-consistency diagnostic');

fprintf('Battery SOC EKF current-bias sensitivity complete.\n');
fprintf('Bias range: %.2f A to %.2f A\n', bias_A(1), bias_A(end));
fprintf('Final SOC error range: %+.4f to %+.4f\n', ...
    min(sensitivity.final_soc_error), ...
    max(sensitivity.final_soc_error));
