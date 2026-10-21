%% Native Simulink Battery RC Example
% Generates the model, simulates the canonical profile, and opens the diagram.


run_example();

function run_example()
modelDirectory = fileparts(mfilename('fullpath'));
referenceDirectory = fullfile(modelDirectory, '..', 'battery-rc-model');
originalPath = path;
pathCleanup = onCleanup(@() path(originalPath));
addpath(modelDirectory, referenceDirectory);

[modelPath, referenceResult] = build_battery_rc_simulink_model();
[~, modelName] = fileparts(modelPath);
keepModelOpen = false;
ownedModelHandle = [];
plotFigure = [];
modelCleanup = onCleanup(@close_failed_model);
load_system(modelPath);
ownedModelHandle = get_param(modelName, 'Handle');
simulationOutput = sim(modelName);
current = simulationOutput.get('current_A');
soc = simulationOutput.get('soc');
terminalVoltage = simulationOutput.get('terminal_voltage_V');

plotFigure = figure('Name', 'Native Simulink Battery RC', 'Color', 'w');
tiledlayout(3, 1, 'TileSpacing', 'compact');

nexttile;
stairs(current.Time, current.Data, 'LineWidth', 1.2);
grid on;
ylabel('Current (A)');
title('Applied pulse profile');

nexttile;
plot(soc.Time, soc.Data, 'LineWidth', 1.2);
grid on;
ylabel('SOC (-)');

nexttile;
plot(terminalVoltage.Time, terminalVoltage.Data, 'LineWidth', 1.2);
grid on;
xlabel('Time (s)');
ylabel('Voltage (V)');

open_system(modelName);

fprintf('Native Simulink battery RC example\n');
fprintf('Generated model: %s\n', modelPath);
fprintf('Final SOC: %.3f\n', soc.Data(end));
fprintf('Voltage range: %.3f V to %.3f V\n', ...
    min(terminalVoltage.Data), max(terminalVoltage.Data));
fprintf('Reference final SOC: %.3f\n', referenceResult.soc(end));
keepModelOpen = true;

    function close_failed_model()
        if keepModelOpen
            return;
        end
        if isgraphics(plotFigure)
            delete(plotFigure);
        end
        if bdIsLoaded(modelName)
            if isempty(ownedModelHandle)
                loadedPath = get_param(modelName, 'FileName');
                ownsModel = isempty(loadedPath) || strcmp(loadedPath, modelPath);
            else
                ownsModel = get_param(modelName, 'Handle') == ownedModelHandle;
            end
            if ownsModel
                close_system(modelName, 0);
            end
        end
    end
end
