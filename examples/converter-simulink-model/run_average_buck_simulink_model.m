%% Native Simulink Averaged Buck Example
% Generates the model, simulates startup, and opens the block diagram.


run_example();

function run_example()
modelDirectory = fileparts(mfilename('fullpath'));
originalPath = path;
pathCleanup = onCleanup(@() path(originalPath));
addpath(modelDirectory);

parameters = average_buck_simulink_parameters();
modelPath = build_average_buck_simulink_model();
[~, modelName] = fileparts(modelPath);
keepModelOpen = false;
ownedModelHandle = [];
plotFigure = [];
modelCleanup = onCleanup(@close_failed_model);
load_system(modelPath);
ownedModelHandle = get_param(modelName, 'Handle');
simulationOutput = sim(modelName);
inductorCurrent = simulationOutput.get('inductor_current');
outputVoltage = simulationOutput.get('output_voltage');

plotFigure = figure('Name', 'Native Simulink Averaged Buck', 'Color', 'w');
tiledlayout(2, 1, 'TileSpacing', 'compact');

nexttile;
plot(outputVoltage.Time, outputVoltage.Data, 'LineWidth', 1.3);
grid on;
ylabel('Voltage (V)');
title('Averaged buck startup');

nexttile;
plot(inductorCurrent.Time, inductorCurrent.Data, 'LineWidth', 1.3);
grid on;
xlabel('Time (s)');
ylabel('Current (A)');

open_system(modelName);

fprintf('Native Simulink averaged buck example\n');
fprintf('Generated model: %s\n', modelPath);
fprintf('Final output voltage: %.3f V\n', outputVoltage.Data(end));
fprintf('Final inductor current: %.3f A\n', ...
    inductorCurrent.Data(end));
fprintf('Lossy steady-state expectation: %.3f V\n', ...
    parameters.duty_cycle * parameters.input_voltage_V / ...
    (1 + parameters.inductor_resistance_Ohm / ...
    parameters.load_resistance_Ohm));
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
