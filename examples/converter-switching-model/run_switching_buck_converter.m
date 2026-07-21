%% Switching Buck Converter Example
% Plots startup and settled PWM, current, and voltage waveforms.

clear; clc; close all;

modelDirectory = fileparts(mfilename('fullpath'));
addpath(modelDirectory);

result = simulate_switching_buck_converter();
metrics = summarize_switching_buck_converter(result, 50);
parameters = result.parameters;

plotPeriods = 3;
plotIntervalCount = plotPeriods * parameters.steps_per_switching_period;
firstPlotInterval = numel(result.switch_state) - plotIntervalCount + 1;
plotIntervalIndices = firstPlotInterval:numel(result.switch_state);
plotStateIndices = firstPlotInterval:(firstPlotInterval + plotIntervalCount);

figure('Name', 'Switching Buck Converter', 'Color', 'w');
tiledlayout(4, 1, 'TileSpacing', 'compact');

nexttile;
plot(result.time_s, result.output_voltage_V, 'LineWidth', 1.3);
hold on;
yline(metrics.expected_average_voltage_V, '--', 'LineWidth', 1.1);
grid on;
ylabel('Voltage (V)');
legend('Switched output', 'Averaged expectation', 'Location', 'southeast');
title('Ideal synchronous buck startup');

nexttile;
stairs(result.interval_start_time_s(plotIntervalIndices), ...
    result.switch_node_voltage_V(plotIntervalIndices), 'LineWidth', 1.1);
grid on;
ylabel('Node (V)');
title('Final three PWM periods');

nexttile;
plot(result.time_s(plotStateIndices), ...
    result.inductor_current_A(plotStateIndices), 'LineWidth', 1.3);
grid on;
ylabel('Current (A)');

nexttile;
plot(result.time_s(plotStateIndices), ...
    result.output_voltage_V(plotStateIndices), 'LineWidth', 1.3);
grid on;
xlabel('Time (s)');
ylabel('Voltage (V)');

fprintf('Switching buck converter example\n');
fprintf('Average output voltage: %.3f V\n', ...
    metrics.average_output_voltage_V);
fprintf('Average inductor current: %.3f A\n', ...
    metrics.average_inductor_current_A);
fprintf('Current ripple: %.3f A peak-to-peak\n', ...
    metrics.inductor_current_ripple_A);
fprintf('Voltage ripple: %.3f V peak-to-peak\n', ...
    metrics.output_voltage_ripple_V);
fprintf('Measured duty cycle: %.3f\n', metrics.measured_duty_cycle);
