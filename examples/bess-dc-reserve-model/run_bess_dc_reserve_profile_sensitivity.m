%% BESS DC Reserve Prescribed Dynamic-Profile Sensitivity
% Visualizes within-profile reserve responses for three fixed requests.

clear;
close all;
clc;

modelDirectory = fileparts(mfilename('fullpath'));
originalPath = path;
pathCleanup = onCleanup(@() path(originalPath));
addpath(modelDirectory);

profiles = bess_dc_reserve_dynamic_profiles();
reserveLevels = [0.10, 0.15, 0.20];
sensitivity = evaluate_bess_dc_reserve_profile_sensitivity( ...
    [], profiles, reserveLevels);
disp(sensitivity(:, 1:18));

profileLabels = replace(string({profiles.id}), "_", " ");
reserveCount = numel(reserveLevels);
profileCount = numel(profiles);
deliveredEnergy_kWh = reshape( ...
    sensitivity.deliveredDischargeEnergy_kWh, reserveCount, profileCount)';
curtailedEnergy_kWh = reshape( ...
    sensitivity.curtailedDischargeEnergy_kWh, reserveCount, profileCount)';
minimumSoc = reshape(sensitivity.minimumSoc, reserveCount, profileCount)';
curtailmentTime_s = reshape( ...
    sensitivity.curtailmentTime_s, reserveCount, profileCount)';

figure('Name', 'BESS Prescribed Dynamic-Profile Sensitivity', ...
    'Position', [100, 100, 1220, 760], 'Color', 'white');
tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
nexttile;
bar(deliveredEnergy_kWh);
grid on;
set(gca, 'XTickLabel', profileLabels);
ylabel('Delivered discharge energy [kWh]');
title('Delivered Energy Within Each Fixed Profile');
legend(compose('Reserve %.2f', reserveLevels), 'Location', 'southwest');

nexttile;
bar(curtailedEnergy_kWh);
grid on;
set(gca, 'XTickLabel', profileLabels);
ylabel('Curtailed discharge energy [kWh]');
title('Request Energy Not Delivered');
legend(compose('Reserve %.2f', reserveLevels), 'Location', 'northwest');

nexttile;
bar(minimumSoc);
grid on;
set(gca, 'XTickLabel', profileLabels);
ylabel('Minimum SOC [-]');
title('Minimum SOC Retained');
legend(compose('Reserve %.2f', reserveLevels), 'Location', 'northwest');

nexttile;
bar(curtailmentTime_s);
grid on;
set(gca, 'XTickLabel', profileLabels);
ylabel('Actual curtailed time [s]');
title('Time Delivered Power Fell Below Request');
legend(compose('Reserve %.2f', reserveLevels), 'Location', 'northwest');

fprintf('BESS prescribed dynamic-profile sensitivity complete.\n');
fprintf('%d cases: %d fixed profiles by %d reserve floors.\n', ...
    height(sensitivity), profileCount, reserveCount);
fprintf('Delivered discharge energy: %.3f to %.3f kWh.\n', ...
    min(sensitivity.deliveredDischargeEnergy_kWh), ...
    max(sensitivity.deliveredDischargeEnergy_kWh));
fprintf(['Profile-to-profile values are descriptive only; profiles are not ', ...
    'energy-normalized.\n']);
