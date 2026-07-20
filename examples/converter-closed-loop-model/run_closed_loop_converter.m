%% Closed-Loop Averaged Converter Example
% Plots a voltage-reference step, inductor current, and bounded duty command.

clear; clc; close all;

addpath(fileparts(mfilename('fullpath')));
result = simulate_closed_loop_converter();

figure('Name', 'Closed-Loop Averaged Converter', 'Color', 'w');
tiledlayout(3, 1, 'TileSpacing', 'compact');

nexttile;
plot(result.time_s, result.reference_voltage_V, '--', 'LineWidth', 1.2);
hold on;
plot(result.time_s, result.output_voltage_V, 'LineWidth', 1.5);
grid on;
ylabel('Voltage (V)');
legend('Reference', 'Output', 'Location', 'southeast');
title('Averaged buck-converter voltage response');

nexttile;
plot(result.time_s, result.current_reference_A, '--', 'LineWidth', 1.2);
hold on;
plot(result.time_s, result.inductor_current_A, 'LineWidth', 1.5);
grid on;
ylabel('Current (A)');
legend('Reference', 'Inductor', 'Location', 'southeast');

nexttile;
plot(result.time_s, result.duty_cycle, 'LineWidth', 1.5);
grid on;
xlabel('Time (s)');
ylabel('Duty cycle');
ylim([0, 1]);

final_window_mask = result.time_s >= result.time_s(end) - 0.01;
fprintf('Closed-loop averaged converter example\n');
fprintf('Reference step: 300 V to %.0f V at %.0f ms\n', ...
    result.final_reference_V, 1000 * result.reference_step_time_s);
fprintf('Final average voltage: %.2f V\n', ...
    mean(result.output_voltage_V(final_window_mask)));
fprintf('Peak voltage after step: %.2f V\n', ...
    max(result.output_voltage_V(result.time_s >= ...
    result.reference_step_time_s)));
