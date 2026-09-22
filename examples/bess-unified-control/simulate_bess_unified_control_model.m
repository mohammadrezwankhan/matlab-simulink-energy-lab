function result = simulate_bess_unified_control_model( ...
        scenario, parameters, modelPath)
%SIMULATE_BESS_UNIFIED_CONTROL_MODEL Run a scenario through Simulink.
% The optional modelPath permits one generated model to be reused across
% scenarios using temporary model-workspace profile and stop-time overrides.

if nargin < 2 || isempty(parameters)
    parameters = bess_unified_control_parameters();
end
exampleDirectory = fileparts(mfilename('fullpath'));
sourceDirectory = fullfile(exampleDirectory, 'src');
originalPath = path;
pathCleanup = onCleanup(@() path(originalPath));
addpath(exampleDirectory, sourceDirectory);
if nargin < 3
    modelPath = [];
end
% Restore the path only after Simulink/model cleanup has finished, including
% during error unwinding. Multiple cleanup objects in one scope have no
% guaranteed destruction order.
result = simulate_scenario(scenario, parameters, modelPath);
end

function result = simulate_scenario(scenario, parameters, modelPath)
if isempty(modelPath)
    modelPath = build_bess_unified_control_model( ...
        fullfile(tempdir, 'matlab-simulink-energy-lab-bess'), ...
        scenario, parameters);
end
if ~isfile(modelPath)
    error('BessUnifiedControl:ModelPath', ...
        'Generated model does not exist: %s', modelPath);
end

[modelDirectory, modelName] = fileparts(modelPath);
modelWasLoaded = bdIsLoaded(modelName);
if modelWasLoaded
    validate_loaded_model_path(modelName, modelPath);
end
fileGenerationConfig = Simulink.fileGenControl('getConfig');
fileGenerationCleanup = onCleanup(@() ...
    Simulink.fileGenControl('setConfig', ...
    'config', fileGenerationConfig));
Simulink.fileGenControl('set', ...
    'CacheFolder', fullfile(modelDirectory, 'cache'), ...
    'CodeGenFolder', fullfile(modelDirectory, 'codegen'), ...
    'createDir', true);
if ~modelWasLoaded
    load_system(modelPath);
end
modelCleanup = onCleanup(@() close_if_owned(modelName, modelWasLoaded));
validate_loaded_model_path(modelName, modelPath);
profile = bess_scenario_profile(scenario);
in = Simulink.SimulationInput(modelName);
in = in.setVariable('bess_profile', ...
    timeseries(profile, profile(:, 1)), 'Workspace', modelName);
in = in.setModelParameter('StopTime', ...
    sprintf('%.17g', scenario.time_s(end)));

clear bess_simulink_runtime;
out = sim(in);
loggedTimeseries = out.bess_output_vector;
bess_validate_output_time(loggedTimeseries.Time, scenario.time_s);
loggedData = squeeze(loggedTimeseries.Data(:, 1, :)).';
if size(loggedData, 1) ~= numel(scenario.time_s) || ...
        size(loggedData, 2) ~= 20
    error('BessUnifiedControl:ModelOutputShape', ...
        'Expected an N-by-20 output matrix from the generated model.');
end

result = bess_initialize_result(scenario);
result.p_pu = loggedData(:, 1);
result.q_pu = loggedData(:, 2);
result.voltage_pu = loggedData(:, 3);
result.frequency_Hz = loggedData(:, 4);
result.phase_rad = loggedData(:, 5);
result.current_pu = loggedData(:, 6);
result.breaker_closed = logical(loggedData(:, 7));
result.state_code = loggedData(:, 8);
result.controller_ready = logical(loggedData(:, 9));
result.sync_ready = logical(loggedData(:, 10));
result.saturated = logical(loggedData(:, 11));
result.faulted = logical(loggedData(:, 12));
result.measurement_valid = logical(loggedData(:, 13));
result.p_command_pu = loggedData(:, 14);
result.q_command_pu = loggedData(:, 15);
result.voltage_command_pu = loggedData(:, 16);
result.frequency_command_Hz = loggedData(:, 17);
result.phase_error_rad = loggedData(:, 18);
result.voltage_mismatch_pu = loggedData(:, 19);
result.frequency_mismatch_Hz = loggedData(:, 20);
clear modelCleanup fileGenerationCleanup;
end

function close_if_owned(modelName, modelWasLoaded)
if ~modelWasLoaded && bdIsLoaded(modelName)
    close_system(modelName, 0);
end
end

function validate_loaded_model_path(modelName, modelPath)
loadedPath = get_param(modelName, 'FileName');
if isempty(loadedPath)
    error('BessUnifiedControl:ModelPathCollision', ...
        ['A model named "%s" is already loaded without a file and ', ...
        'cannot be used for the requested model at "%s".'], ...
        modelName, modelPath);
end
[loadedPathExists, loadedAttributes] = fileattrib(loadedPath);
[requestedPathExists, requestedAttributes] = fileattrib(modelPath);
if ~loadedPathExists || ~requestedPathExists
    error('BessUnifiedControl:ModelPathCollision', ...
        ['A model named "%s" is already loaded from "%s" and cannot ', ...
        'be used for the requested model at "%s".'], ...
        modelName, loadedPath, modelPath);
end
if ispc
    pathsMatch = strcmpi(loadedAttributes.Name, requestedAttributes.Name);
else
    pathsMatch = strcmp(loadedAttributes.Name, requestedAttributes.Name);
end
if ~pathsMatch
    error('BessUnifiedControl:ModelPathCollision', ...
        ['A model named "%s" is already loaded from "%s" and cannot ', ...
        'be used for the requested model at "%s".'], ...
        modelName, loadedPath, modelPath);
end
end
