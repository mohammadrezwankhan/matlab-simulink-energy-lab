%% Battery OCV Hysteresis Example
% Shows how charge/discharge history separates voltage at the same SOC.

clear; clc; close all;

modelDirectory = fileparts(mfilename('fullpath'));
originalPath = path;
pathCleanup = onCleanup(@() path(originalPath));
addpath(modelDirectory);

profile = battery_hysteresis_default_profile();
parameters = battery_hysteresis_default_parameters();
result = simulate_battery_ocv_hysteresis(profile, parameters, 5);

nativeResult = simulate_battery_ocv_hysteresis(profile, parameters);
firstComparisonIndex = find(nativeResult.time_s == 1200, 1);
secondComparisonIndex = find(nativeResult.time_s == 2400, 1);
minorLoopGap_V = ...
    nativeResult.equilibrium_voltage_V(secondComparisonIndex) - ...
    nativeResult.equilibrium_voltage_V(firstComparisonIndex);

figure('Name', 'Battery OCV Hysteresis', 'Color', 'w');
tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

nexttile;
stairs(result.time_s/60, result.current_A, 'LineWidth', 1.2);
grid on;
xlabel('Time [min]');
ylabel('Current [A]');
title('Applied Current (+ discharge)');

nexttile;
plot(result.time_s/60, result.soc, 'LineWidth', 1.2);
grid on;
xlabel('Time [min]');
ylabel('SOC [-]');
title('Charge-Balanced SOC');

nexttile;
yyaxis left;
plot(result.time_s/60, result.hysteresis_state, 'LineWidth', 1.2);
ylabel('State [-]');
ylim([-1, 1]);
yyaxis right;
plot(result.time_s/60, 1000*result.hysteresis_voltage_V, ...
    'LineWidth', 1.2);
ylabel('Voltage [mV]');
grid on;
xlabel('Time [min]');
title('Dynamic Hysteresis Memory');

nexttile;
plot(result.soc, result.equilibrium_voltage_V, 'LineWidth', 1.3);
hold on;
comparisonSoc = nativeResult.soc(firstComparisonIndex);
comparisonVoltage_V = nativeResult.equilibrium_voltage_V(...
    [firstComparisonIndex, secondComparisonIndex]);
plot([comparisonSoc, comparisonSoc], comparisonVoltage_V, ':', ...
    'Color', [0.2, 0.2, 0.2], 'LineWidth', 1.2);
plot(comparisonSoc, comparisonVoltage_V(1), 'o', ...
    'MarkerFaceColor', [0.85, 0.33, 0.10]);
plot(comparisonSoc, comparisonVoltage_V(2), 's', ...
    'MarkerFaceColor', [0.47, 0.67, 0.19]);
text(comparisonSoc + 0.002, mean(comparisonVoltage_V), ...
    sprintf('%.2f mV', 1000*minorLoopGap_V));
grid on;
xlabel('SOC [-]');
ylabel('Equilibrium voltage [V]');
title('Reversal Minor Loop');

fprintf('Final SOC: %.3f\n', result.soc(end));
fprintf('Hysteresis state range: %.3f to %.3f\n', ...
    min(result.hysteresis_state), max(result.hysteresis_state));
fprintf('Same-SOC minor-loop voltage gap: %.2f mV\n', ...
    1000*minorLoopGap_V);
