clear;
close all;
clc;

modelDirectory = fileparts(mfilename('fullpath'));
originalPath = path;
pathCleanup = onCleanup(@() path(originalPath));
addpath(modelDirectory);

sensitivity = ...
    evaluate_switching_closed_loop_buck_temperature_sensitivity();
temperature_C = sensitivity.junction_temperature_C;

figure('Color', 'w');
tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

nexttile;
plot(temperature_C, 1000*sensitivity.switch_on_resistance_Ohm, ...
    'o-', 'LineWidth', 1.4);
grid on;
xlabel('Fixed junction temperature (degC)');
ylabel('Interpolated R_{DS(on)} (mOhm)');
title('Datasheet-anchor interpolation');

nexttile;
plot(temperature_C, 1e6*sensitivity.turn_on_energy_reference_J, ...
    'o-', 'LineWidth', 1.4);
hold on;
plot(temperature_C, 1e6*sensitivity.turn_off_energy_reference_J, ...
    's-', 'LineWidth', 1.4);
grid on;
xlabel('Fixed junction temperature (degC)');
ylabel('Reference event energy (uJ)');
legend('Turn-on', 'Turn-off', 'Location', 'northwest');
title('Published endpoint interpolation');

nexttile;
plot(temperature_C, ...
    sensitivity.switch_conduction_loss_energy_J, ...
    'o-', 'LineWidth', 1.4);
hold on;
plot(temperature_C, sensitivity.switching_loss_energy_J, ...
    's-', 'LineWidth', 1.4);
grid on;
xlabel('Fixed junction temperature (degC)');
ylabel('Loss energy over 0.18 s (J)');
legend('Switch conduction', 'Switching events', ...
    'Location', 'northwest');
title('Closed-loop loss sensitivity');

nexttile;
yyaxis left;
plot(temperature_C, sensitivity.energy_efficiency_percent, ...
    'o-', 'LineWidth', 1.4);
ylabel('Estimated efficiency (%)');
yyaxis right;
plot(temperature_C, sensitivity.average_output_voltage_V, ...
    's-', 'LineWidth', 1.4);
ylabel('Final average output (V)');
grid on;
xlabel('Fixed junction temperature (degC)');
title('System-level sensitivity');

fprintf('Switch fixed-temperature sensitivity complete.\n');
fprintf('25 degC total switch loss: %.3f J\n', ...
    sensitivity.total_switch_loss_energy_J(1));
fprintf('175 degC total switch loss: %.3f J\n', ...
    sensitivity.total_switch_loss_energy_J(end));
fprintf('175 degC estimated efficiency: %.3f%%\n', ...
    sensitivity.energy_efficiency_percent(end));
