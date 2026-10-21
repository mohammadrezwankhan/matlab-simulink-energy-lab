%% Native Simulink Switching Closed-Loop Buck
% Generates the model and overlays it with the Base MATLAB reference.


run_example();

function run_example()
modelDirectory = fileparts(mfilename('fullpath'));
examplesDirectory = fileparts(modelDirectory);
referenceDirectory = fullfile(examplesDirectory, ...
    'converter-switching-closed-loop-model');
originalPath = path;
pathCleanup = onCleanup(@() path(originalPath));
addpath(modelDirectory, referenceDirectory);

parameters = switching_closed_loop_buck_default_parameters();
reference = simulate_switching_closed_loop_buck(parameters);
modelPath = build_switching_closed_loop_buck_simulink_model([], parameters);
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

plotFigure = figure('Name', 'Native Simulink Switching Buck Parity', 'Color', 'white');
tiledlayout(2, 1, 'TileSpacing', 'compact');
nexttile;
plot(reference.time_s, reference.output_voltage_V, ...
    'LineWidth', 1.4, 'DisplayName', 'Base MATLAB');
hold on;
plot(outputVoltage.Time, outputVoltage.Data, '--', ...
    'LineWidth', 1.0, 'DisplayName', 'Native Simulink');
grid on;
ylabel('Output voltage [V]');
title('Exact-Affine Switched-Plant Parity');
legend('Location', 'southeast');

nexttile;
plot(reference.time_s, reference.inductor_current_A, ...
    'LineWidth', 1.4, 'DisplayName', 'Base MATLAB');
hold on;
plot(inductorCurrent.Time, inductorCurrent.Data, '--', ...
    'LineWidth', 1.0, 'DisplayName', 'Native Simulink');
grid on;
xlabel('Time [s]');
ylabel('Inductor current [A]');
legend('Location', 'southeast');

open_system(modelName);
fprintf('Native Simulink switching closed-loop buck example\n');
fprintf('Generated model: %s\n', modelPath);
fprintf('Maximum MATLAB parity error: %.3e A, %.3e V\n', ...
    max(abs(inductorCurrent.Data(:) - reference.inductor_current_A)), ...
    max(abs(outputVoltage.Data(:) - reference.output_voltage_V)));
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
