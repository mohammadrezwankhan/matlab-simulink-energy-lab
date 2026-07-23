%% Averaged Buck Controller Comparison
% Compares open-loop, PI, and filtered-PID responses to one load step.

clear; clc; close all;

addpath(fileparts(mfilename('fullpath')));
comparison = simulate_converter_controller_comparison();
controllers = {comparison.open_loop, comparison.pi, ...
    comparison.filtered_pid};
summary = build_controller_comparison_table(comparison);
colors = lines(numel(controllers));

figure('Name', 'Averaged Buck Controller Comparison', 'Color', 'w');
tiledlayout(3, 1, 'TileSpacing', 'compact');

nexttile;
plot(comparison.time_s, comparison.reference_voltage_V, 'k--', ...
    'LineWidth', 1.2);
hold on;
for index = 1:numel(controllers)
    plot(comparison.time_s, controllers{index}.output_voltage_V, ...
        'Color', colors(index, :), 'LineWidth', 1.3);
end
grid on;
ylabel('Voltage (V)');
legend('Reference', 'Open loop', 'PI', 'Filtered PID', ...
    'Location', 'best');
title('Output-voltage response to a resistive load step');

nexttile;
hold on;
for index = 1:numel(controllers)
    plot(comparison.time_s, controllers{index}.inductor_current_A, ...
        'Color', colors(index, :), 'LineWidth', 1.3);
end
grid on;
ylabel('Current (A)');
legend('Open loop', 'PI', 'Filtered PID', 'Location', 'best');

nexttile;
hold on;
for index = 1:numel(controllers)
    plot(comparison.time_s, controllers{index}.duty_cycle, ...
        'Color', colors(index, :), 'LineWidth', 1.3);
end
grid on;
xlabel('Time (s)');
ylabel('Duty cycle');
ylim([0, 1]);
legend('Open loop', 'PI', 'Filtered PID', 'Location', 'best');

fprintf('Averaged buck controller load-step comparison\n');
fprintf('Load resistance: %.1f Ohm to %.1f Ohm at %.0f ms\n', ...
    comparison.parameters.initial_load_resistance_Ohm, ...
    comparison.parameters.final_load_resistance_Ohm, ...
    1000 * comparison.parameters.load_step_time_s);
disp(summary);
