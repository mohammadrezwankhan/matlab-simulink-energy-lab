%% BESS DC Reserve Constant-Request Sensitivity
% Maps average delivered power and curtailment time by reserve floor.

clear;
close all;
clc;

modelDirectory = fileparts(mfilename('fullpath'));
originalPath = path;
pathCleanup = onCleanup(@() path(originalPath));
addpath(modelDirectory);

reserveLevels = [0.10, 0.15, 0.20];
requestedDischargePower_kW = [0, 100, 200, 250, 300, 325];
envelope = evaluate_bess_dc_reserve_envelope([], ...
    reserveLevels, 1000*requestedDischargePower_kW);
disp(envelope(:, 1:10));

reserveCount = numel(reserveLevels);
requestCount = numel(requestedDischargePower_kW);
averageDeliveredPower_kW = reshape( ...
    envelope.averageDeliveredPower_kW, requestCount, reserveCount)';
curtailmentTime_s = reshape( ...
    envelope.curtailmentTime_s, requestCount, reserveCount)';

figure('Name', 'BESS DC Reserve Constant-Request Sensitivity', ...
    'Position', [100, 100, 1200, 520], 'Color', 'white');
tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
nexttile;
plot(requestedDischargePower_kW, requestedDischargePower_kW, ...
    '--', 'LineWidth', 1.2, 'DisplayName', 'Ideal y = x');
hold on;
for reserveIndex = 1:reserveCount
    plot(requestedDischargePower_kW, ...
        averageDeliveredPower_kW(reserveIndex, :), '-o', ...
        'LineWidth', 1.4, ...
        'DisplayName', sprintf('Reserve %.2f', reserveLevels(reserveIndex)));
end
grid on;
xlabel('Constant requested discharge power [kW]');
ylabel('Average delivered discharge power [kW]');
title('Delivered Power Saturates Near the SOC Reserve');
legend('Location', 'northwest');

nexttile;
for reserveIndex = 1:reserveCount
    plot(requestedDischargePower_kW, ...
        curtailmentTime_s(reserveIndex, :), '-o', ...
        'LineWidth', 1.4, ...
        'DisplayName', sprintf('Reserve %.2f', reserveLevels(reserveIndex)));
    hold on;
end
grid on;
xlabel('Constant requested discharge power [kW]');
ylabel('Actual curtailed time [s]');
title('Time with Delivered Power Below the Request');
legend('Location', 'northwest');

fprintf('BESS DC reserve constant-request sensitivity complete.\n');
fprintf('%d cases: reserve %.2f to %.2f, request %.0f to %.0f kW\n', ...
    height(envelope), reserveLevels(1), reserveLevels(end), ...
    requestedDischargePower_kW(1), requestedDischargePower_kW(end));
fprintf('Maximum average delivered power: %.3f kW\n', ...
    max(envelope.averageDeliveredPower_kW));
fprintf('Maximum curtailed discharge energy: %.3f kWh\n', ...
    max(envelope.curtailedDischargeEnergy_kWh));
