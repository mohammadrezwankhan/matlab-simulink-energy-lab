%% Battery Cooling-Sensitivity Study
% Sweeps lumped cooling conductance under one shared current profile.

clear; clc; close all;

modelDirectory = fileparts(mfilename('fullpath'));
addpath(modelDirectory);

profile = battery_thermal_default_profile();
parameters = battery_thermal_default_parameters();
heatTransferValues_W_per_K = [0; 0.6; 1.2; 2.4; 4.8];
limitTemperature_C = 35;

comparison = compare_battery_cooling_sensitivity(...
    profile, parameters, heatTransferValues_W_per_K, ...
    limitTemperature_C, 1);

disp(comparison.summary);

colors = lines(height(comparison.summary));
labels = compose('hA = %.1f W/K', heatTransferValues_W_per_K);
figure('Name', 'Battery Cooling-Sensitivity Study', 'Color', 'w');
tiledlayout(2, 1, 'TileSpacing', 'compact');

nexttile;
hold on;
for caseIndex = 1:numel(comparison.results)
    result = comparison.results{caseIndex};
    plot(result.time_s / 60, result.cell_temp_C, ...
        'Color', colors(caseIndex, :), 'LineWidth', 1.3);
end
yline(limitTemperature_C, 'k--', 'Temperature limit');
grid on;
xlabel('Time (min)');
ylabel('Cell temperature (degC)');
legend(labels, 'Location', 'best');
title('Temperature response under identical electrical loading');

nexttile;
bar(heatTransferValues_W_per_K, ...
    comparison.summary.degree_hours_above_limit_C_h, 0.65, ...
    'FaceColor', [0.18, 0.45, 0.36]);
grid on;
xlabel('Lumped cooling conductance, hA (W/K)');
ylabel(sprintf('Degree-hours above %.1f degC', limitTemperature_C));
title('Thermal-limit exposure versus cooling conductance');
