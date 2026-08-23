clear;
close all;
clc;

modelDirectory = fileparts(mfilename('fullpath'));
originalPath = path;
pathCleanup = onCleanup(@() path(originalPath));
addpath(modelDirectory);

result = simulate_bess_dc_reserve();
metrics = summarize_bess_dc_reserve(result);

figure('Name', 'BESS DC Reserve Model', ...
    'Position', [100, 100, 1200, 820]);
tiledlayout(2, 2);

nexttile;
stairs(result.interval_time_s, ...
    result.requested_converter_power_W/1000, ':', 'LineWidth', 1.2);
hold on;
stairs(result.interval_time_s, result.converter_power_W/1000, ...
    'LineWidth', 1.1);
stairs(result.interval_time_s, result.battery_power_W/1000, '--', ...
    'LineWidth', 1.0);
grid on;
xlabel('Time [s]');
ylabel('Power [kW]');
legend('Requested converter', 'Delivered converter', 'Battery terminal', ...
    'Location', 'best');
title('Requested, Delivered, and Battery Power');

nexttile;
plot(result.time_s, result.soc, 'LineWidth', 1.2);
hold on;
yline(result.parameters.minimum_reserve_soc, '--', 'Reserve');
grid on;
xlabel('Time [s]');
ylabel('SOC [-]');
title('Reserve-Aware State of Charge');

nexttile;
plot(result.time_s, result.dc_voltage_V, 'LineWidth', 1.2);
hold on;
yline(result.parameters.dc_voltage_reference_V, ':', 'Reference');
yline(result.parameters.minimum_dc_voltage_V, '--', 'Limits');
yline(result.parameters.maximum_dc_voltage_V, '--', ...
    'HandleVisibility', 'off');
grid on;
xlabel('Time [s]');
ylabel('DC-link voltage [V]');
title('DC-Link Energy Buffer');

nexttile;
yyaxis left;
plot(result.interval_time_s, result.battery_current_A, ...
    'LineWidth', 1.0);
ylabel('Battery current [A]');
yyaxis right;
plot(result.interval_time_s, result.discharge_availability, ...
    'LineWidth', 1.2);
hold on;
plot(result.interval_time_s, result.charge_availability, '--', ...
    'LineWidth', 1.1);
ylabel('Availability [-]');
grid on;
xlabel('Time [s]');
legend('Battery current', 'Discharge availability', ...
    'Charge availability', 'Location', 'best');
title('Current and SOC-Dependent Availability');

fprintf('BESS DC reserve example complete.\n');
fprintf('SOC: minimum %.4f, final %.4f\n', ...
    metrics.minimum_soc, metrics.final_soc);
fprintf('DC-link voltage: %.2f V to %.2f V\n', ...
    metrics.minimum_dc_voltage_V, metrics.maximum_dc_voltage_V);
fprintf('Delivered/curtailed discharge energy: %.3f / %.3f kWh\n', ...
    metrics.delivered_discharge_energy_kWh, ...
    metrics.curtailed_discharge_energy_kWh);
fprintf('Reserve-limited operation: %.1f s\n', ...
    metrics.reserve_limited_time_s);
