%% Pouch-Cell Through-Thickness Thermal Model
% Runs and plots the validated one-dimensional finite-volume reference.

clear; clc; close all;

modelDirectory = fileparts(mfilename("fullpath"));
originalPath = path;
pathCleanup = onCleanup(@() path(originalPath));
addpath(modelDirectory);

profile = pouch_cell_thermal_default_profile();
parameters = pouch_cell_thermal_default_parameters();
result = simulate_pouch_cell_thermal_model(profile, parameters, 0.5);

figure("Name", "Pouch-Cell Thermal Gradient", "Color", "w");
tiledlayout(2, 2, "TileSpacing", "compact");

nexttile;
stairs(result.time_s, result.cell_heat_generation_W, "LineWidth", 1.2);
grid on;
xlabel("Time [s]");
ylabel("Heat [W]");
title("Cell Heat Generation");

nexttile;
plot(result.time_s, result.left_surface_temperature_C, ...
    "LineWidth", 1.2);
hold on;
plot(result.time_s, result.center_temperature_C, "LineWidth", 1.2);
plot(result.time_s, result.right_surface_temperature_C, ...
    "LineWidth", 1.2);
plot(result.time_s, result.volume_average_temperature_C, ...
    "--", "LineWidth", 1.2);
grid on;
xlabel("Time [s]");
ylabel("Temperature [degC]");
title("Surface, Center, and Mean Temperatures");
legend("Left surface", "Center", "Right surface", ...
    "Volume average", "Location", "best");

nexttile;
peakTimeIndex = find(result.time_s == result.peak_time_s, 1);
plot(1000 * result.node_position_m, ...
    result.node_temperature_C(peakTimeIndex, :), ...
    "o-", "LineWidth", 1.2);
hold on;
plot(1000 * result.node_position_m, ...
    result.node_temperature_C(end, :), ...
    "s--", "LineWidth", 1.2);
grid on;
xlabel("Through-thickness position [mm]");
ylabel("Temperature [degC]");
title("Resolved Through-Thickness Profile");
legend("At peak temperature", "Final", "Location", "best");

nexttile;
plot(result.time_s, result.left_boundary_heat_removal_W, ...
    "LineWidth", 1.2);
hold on;
plot(result.time_s, result.right_boundary_heat_removal_W, ...
    "LineWidth", 1.2);
plot(result.time_s, result.temperature_spread_C, ...
    "--", "LineWidth", 1.2);
grid on;
xlabel("Time [s]");
ylabel("Heat [W] or spread [degC]");
title("Boundary Heat Removal and Temperature Spread");
legend("Left heat removal", "Right heat removal", ...
    "Node spread", "Location", "best");

fprintf("Pouch-cell thermal-gradient simulation complete.\n");
fprintf("Peak node temperature: %.2f degC at %.2f mm and %.0f s\n", ...
    result.peak_temperature_C, 1000 * result.peak_position_m, ...
    result.peak_time_s);
fprintf("Peak through-thickness node spread: %.2f degC\n", ...
    result.peak_temperature_spread_C);
fprintf("Thermal energy-balance error: %.3e J\n", ...
    result.energy_balance_error_J);
