function result = run_bess_unified_control(scenarioIdentifier)
%RUN_BESS_UNIFIED_CONTROL Build, simulate, and plot one scenario.

if nargin < 1
    scenarioIdentifier = 'C';
end
exampleDirectory = fileparts(mfilename('fullpath'));
sourceDirectory = fullfile(exampleDirectory, 'src');
originalPath = path;
pathCleanup = onCleanup(@() path(originalPath));
addpath(exampleDirectory, sourceDirectory);
parameters = bess_unified_control_parameters();
scenarios = bess_validation_scenarios(parameters);
scenarioIndex = find(strcmpi({scenarios.id}, scenarioIdentifier), 1);
if isempty(scenarioIndex)
    error('BessUnifiedControl:Scenario', ...
        'Scenario identifier must be one of A through H.');
end
scenario = scenarios(scenarioIndex);
result = simulate_bess_unified_control(scenario, parameters);

tiledlayout(4, 1);
nexttile;
plot(result.time_s, result.p_pu, result.time_s, result.q_pu, ...
    'LineWidth', 1.2);
grid on; ylabel('Power (p.u.)'); legend('P', 'Q');
title([scenario.name, ' — ', scenario.description]);
nexttile;
plot(result.time_s, result.voltage_pu, 'LineWidth', 1.2);
grid on; ylabel('PCC voltage (p.u.)');
nexttile;
plot(result.time_s, result.frequency_Hz, 'LineWidth', 1.2);
grid on; ylabel('Frequency (Hz)');
nexttile;
stairs(result.time_s, result.state_code, 'LineWidth', 1.2);
grid on; ylabel('State code'); xlabel('Time (s)');
clear pathCleanup;
end
