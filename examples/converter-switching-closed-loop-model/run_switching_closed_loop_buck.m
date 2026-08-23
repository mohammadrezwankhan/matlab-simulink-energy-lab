clear;
close all;
clc;

modelDirectory = fileparts(mfilename('fullpath'));
originalPath = path;
pathCleanup = onCleanup(@() path(originalPath));
addpath(modelDirectory);

result = simulate_switching_closed_loop_buck();
metrics = summarize_switching_closed_loop_buck(result, 100);
periodTime_s = (0:(result.period_count - 1))'*result.switching_period_s;

figure('Name', 'Switching Closed-Loop Buck Converter', ...
    'Position', [100, 100, 1200, 820]);
tiledlayout(2, 2);

nexttile;
plot(result.time_s, result.reference_voltage_V, ':', 'LineWidth', 1.2);
hold on;
plot(result.time_s, result.output_voltage_V, 'LineWidth', 1.1);
grid on;
xlabel('Time [s]');
ylabel('Voltage [V]');
legend('Reference', 'Switched output', 'Location', 'best');
title('Reference and Load-Step Regulation');

nexttile;
plot(result.time_s, result.inductor_current_A, 'LineWidth', 1.0);
hold on;
stairs(periodTime_s, result.current_reference_A, '--', ...
    'LineWidth', 1.1);
grid on;
xlabel('Time [s]');
ylabel('Current [A]');
legend('Inductor current', 'Current reference', 'Location', 'best');
title('Bounded Inner Current Loop');

nexttile;
stairs(periodTime_s, result.duty_cycle, 'LineWidth', 1.1);
hold on;
stairs(result.time_s, result.load_resistance_Ohm/20, ':', ...
    'LineWidth', 1.0);
grid on;
xlabel('Time [s]');
ylabel('Duty / normalized load [-]');
legend('Quantized duty', 'Load resistance / 20 Ohm', ...
    'Location', 'best');
title('Period-Boundary Control and Load Step');

nexttile;
finalIntervals = (numel(result.switch_state) - ...
    5*result.parameters.steps_per_switching_period + 1): ...
    numel(result.switch_state);
yyaxis left;
stairs(result.interval_start_time_s(finalIntervals), ...
    double(result.switch_state(finalIntervals)), 'LineWidth', 1.0);
ylabel('Switch state [-]');
yyaxis right;
plot(result.time_s(finalIntervals), ...
    result.inductor_current_A(finalIntervals), 'LineWidth', 1.0);
ylabel('Inductor current [A]');
grid on;
xlabel('Time [s]');
title('Final Five PWM Periods');

fprintf('Switching closed-loop buck example complete.\n');
fprintf('Final average voltage: %.2f V\n', ...
    metrics.average_output_voltage_V);
fprintf('Reference-step overshoot: %.2f%%, settling %.1f ms\n', ...
    metrics.reference_step_overshoot_percent, ...
    1000*metrics.reference_step_settling_time_s);
fprintf('Load-step undershoot: %.2f%%, settling %.1f ms\n', ...
    metrics.load_step_undershoot_percent, ...
    1000*metrics.load_step_settling_time_s);
fprintf('Average duty cycle: %.3f\n', metrics.average_duty_cycle);
fprintf('Diode/inductor loss energy: %.3f J / %.3f J\n', ...
    metrics.diode_loss_energy_J, metrics.inductor_loss_energy_J);
