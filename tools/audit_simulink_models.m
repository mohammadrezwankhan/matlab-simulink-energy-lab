function report = audit_simulink_models(repositoryRoot, outputPath, runModelAdvisor)
%AUDIT_SIMULINK_MODELS Build and inspect all six generated companion models.
%   REPORT = AUDIT_SIMULINK_MODELS(ROOT) requires MATLAB and Simulink. It
%   builds in an owned temporary directory, updates each diagram, records
%   solver/block/sample-time metadata, and queries algebraic loops.
%   REPORT = AUDIT_SIMULINK_MODELS(ROOT, JSONPATH, true) additionally requests
%   Model Advisor checks, an optional tier requiring Simulink Check.
%   This audit does not simulate scenarios or collect solver-step telemetry.
%   It does not arrange, repair, or save changes to repository source models.

if nargin < 1 || isempty(repositoryRoot)
    repositoryRoot = fileparts(fileparts(mfilename('fullpath')));
end
if nargin < 2
    outputPath = '';
end
if nargin < 3
    runModelAdvisor = false;
end
validateattributes(runModelAdvisor, {'logical', 'numeric'}, ...
    {'scalar', 'binary'}, mfilename, 'runModelAdvisor');
repositoryRoot = char(string(repositoryRoot));
outputPath = char(string(outputPath));
if ~isfolder(fullfile(repositoryRoot, 'examples'))
    error('RepositoryAudit:RepositoryRoot', ...
        'Repository root must contain the examples directory.');
end
% Resolve a relative root before entering the temporary working directory.
[resolved, attributes] = fileattrib(repositoryRoot);
if ~resolved
    error('RepositoryAudit:RepositoryRoot', 'Cannot resolve repository root.');
end
repositoryRoot = attributes.Name;
if ~isempty(outputPath) && ~is_absolute_path(outputPath)
    outputPath = fullfile(pwd, outputPath);
end

builders = {
    'converter-simulink-model', 'build_average_buck_simulink_model', ...
        'average_buck_simulink_model'; ...
    'battery-simulink-model', 'build_battery_rc_simulink_model', ...
        'battery_rc_simulink_model'; ...
    'battery-2rc-simulink-model', 'build_battery_2rc_simulink_model', ...
        'battery_2rc_simulink_model'; ...
    'battery-thermal-simulink-model', 'build_battery_thermal_simulink_model', ...
        'battery_thermal_simulink_model'; ...
    'converter-switching-closed-loop-simulink-model', ...
        'build_switching_closed_loop_buck_simulink_model', ...
        'switching_closed_loop_buck_simulink_model'; ...
    'bess-unified-control', 'build_bess_unified_control_model', ...
        'bess_unified_control'
};
report.schema_version = '1.0.0';
report.status = 'unavailable';
report.scope = 'generated-model compile, metadata, and algebraic-loop audit';
report.simulation_status = 'not_requested';
report.matlab_version = version;
report.matlab_release = version('-release');
report.required_products = {'MATLAB', 'Simulink'};
report.simulink_installed = ~isempty(ver('simulink'));
report.simulink_license_available = license('test', 'Simulink');
report.model_advisor_requested = logical(runModelAdvisor);
report.model_advisor_required_product = 'Simulink Check';
report.simulink_check_installed = ~isempty(ver('slcheck'));
report.error = struct('identifier', '', 'message', '');
report.cleanup = struct('status', 'not_needed', 'errors', {{}});
report.models = repmat(empty_model_entry(), size(builders, 1), 1);
for index = 1:size(builders, 1)
    report.models(index).builder = strrep(fullfile('examples', ...
        builders{index, 1}, [builders{index, 2}, '.m']), filesep, '/');
    report.models(index).model_name = builders{index, 3};
end
if ~report.simulink_installed || ~report.simulink_license_available
    report.error.identifier = 'RepositoryAudit:SimulinkUnavailable';
    report.error.message = 'Required Simulink product or license unavailable.';
    write_report(report, outputPath);
    return;
end

originalPath = path;
originalDirectory = pwd;
originalFigures = findall(groot, 'Type', 'figure');
fileGenerationConfig = [];
temporaryDirectory = tempname;
environmentCleanup = onCleanup(@restore_environment);
report.cleanup.status = 'pending';
try
    mkdir(temporaryDirectory);
    examplesDirectory = fullfile(repositoryRoot, 'examples');
    for index = 1:size(builders, 1)
        addpath(fullfile(examplesDirectory, builders{index, 1}));
    end
    addpath(fullfile(examplesDirectory, 'battery-rc-model'), ...
        fullfile(examplesDirectory, 'battery-2rc-model'), ...
        fullfile(examplesDirectory, 'battery-thermal-model'), ...
        fullfile(examplesDirectory, 'converter-switching-closed-loop-model'), ...
        fullfile(examplesDirectory, 'bess-unified-control', 'src'));
    fileGenerationConfig = Simulink.fileGenControl('getConfig');
    Simulink.fileGenControl('set', ...
        'CacheFolder', fullfile(temporaryDirectory, 'cache'), ...
        'CodeGenFolder', fullfile(temporaryDirectory, 'codegen'), ...
        'createDir', true);
    cd(temporaryDirectory);
    for index = 1:size(builders, 1)
        report.models(index) = inspect_model(report.models(index), ...
            builders{index, 2}, fullfile(temporaryDirectory, ...
            builders{index, 3}), logical(runModelAdvisor), ...
            report.simulink_check_installed);
    end
    report.status = 'passed';
    if any(~strcmp({report.models.status}, 'passed'))
        report.status = 'failed';
    elseif runModelAdvisor
        advisor = [report.models.model_advisor];
        if any(strcmp({advisor.status}, 'failed'))
            report.status = 'failed';
        elseif any(strcmp({advisor.status}, 'unavailable'))
            report.status = 'unavailable';
        end
    end
catch exception
    report.status = 'failed';
    report.error = exception_summary(exception);
end
clear environmentCleanup;
if strcmp(report.cleanup.status, 'failed')
    report.status = 'failed';
end
write_report(report, outputPath);

    function restore_environment()
        errors = {};
        try
            close_new_figures(originalFigures);
        catch exception
            errors{end + 1} = exception.message;
        end
        try
            cd(originalDirectory);
        catch exception
            errors{end + 1} = exception.message;
        end
        try
            if ~isempty(fileGenerationConfig)
                Simulink.fileGenControl('setConfig', ...
                    'config', fileGenerationConfig);
            end
        catch exception
            errors{end + 1} = exception.message;
        end
        path(originalPath);
        try
            if isfolder(temporaryDirectory)
                rmdir(temporaryDirectory, 's');
            end
        catch exception
            errors{end + 1} = exception.message;
        end
        report.cleanup.errors = errors;
        if isempty(errors)
            report.cleanup.status = 'passed';
        else
            report.cleanup.status = 'failed';
        end
    end
end

function entry = inspect_model(entry, builderName, directory, runAdvisor, hasCheck)
modelName = entry.model_name;
if bdIsLoaded(modelName)
    entry.status = 'failed';
    entry.error.identifier = 'RepositoryAudit:ModelAlreadyLoaded';
    entry.error.message = 'Caller-owned model is loaded; audit left it untouched.';
    return;
end
ownedHandle = [];
% Predeclare outputs assigned by evalc in this function's static workspace.
modelPath = '';
loops = [];
viewer = [];
figuresBefore = findall(groot, 'Type', 'figure');
modelCleanup = onCleanup(@close_owned_model);
try
    entry.build_log = evalc('modelPath = feval(builderName, directory);');
    load_system(modelPath);
    ownedHandle = get_param(modelName, 'Handle');
    entry.compile_log = evalc( ...
        'set_param(modelName, ''SimulationCommand'', ''update'');');
    parameterNames = {'SolverType', 'Solver', 'FixedStep', 'MaxStep', ...
        'RelTol', 'AbsTol', 'StartTime', 'StopTime', 'AlgebraicLoopMsg'};
    for index = 1:numel(parameterNames)
        name = parameterNames{index};
        entry.solver.(name) = get_param(modelName, name);
    end
    blockPaths = find_system(modelName, 'LookUnderMasks', 'all', ...
        'FollowLinks', 'on', 'Type', 'Block');
    entry.block_count = numel(blockPaths);
    for index = 1:numel(blockPaths)
        block = blockPaths{index};
        metadata = struct('path', block, 'type', ...
            get_param(block, 'BlockType'), 'declared_sample_time', '');
        parameters = get_param(block, 'ObjectParameters');
        if isfield(parameters, 'SampleTime')
            metadata.declared_sample_time = value_text(get_param(block, 'SampleTime'));
        end
        entry.blocks(end + 1) = metadata;
    end
    sampleTimes = Simulink.BlockDiagram.getSampleTimes(modelName);
    if isempty(sampleTimes)
        error('RepositoryAudit:MissingSampleTimes', ...
            'Compiled model did not provide sample-time metadata.');
    end
    for index = 1:numel(sampleTimes)
        sampleTime = sampleTimes(index);
        entry.sample_times(end + 1) = struct( ...
            'period_offset_text', property_text(sampleTime, 'value'), ...
            'description', property_text(sampleTime, 'Description'), ...
            'owner_block', property_text(sampleTime, 'OwnerBlock'), ...
            'annotation', property_text(sampleTime, 'Annotation'));
    end
    entry.algebraic_loops.query_log = evalc( ...
        '[loops, viewer] = Simulink.BlockDiagram.getAlgebraicLoops(modelName);');
    entry.algebraic_loops.count = numel(loops);
    for index = 1:numel(loops)
        loop = loops(index);
        entry.algebraic_loops.details(end + 1) = struct( ...
            'id', value_text(loop.Id), ...
            'artificial', logical(loop.IsArtificial), ...
            'blocks', {cellstr(getfullname(loop.BlockHandles))});
    end
    if ~isempty(viewer) && isgraphics(viewer) && ~any(viewer == figuresBefore)
        delete(viewer);
    end
    entry.algebraic_loops.status = 'passed';
    entry.status = 'passed';
    if ~isempty(loops)
        entry.algebraic_loops.status = 'failed';
        entry.status = 'failed';
    end
    if runAdvisor
        entry.model_advisor = run_model_advisor(modelName, hasCheck);
    end
catch exception
    entry.status = 'failed';
    entry.error = exception_summary(exception);
end
% Logs can contain the ephemeral destination path. Keep the report stable.
entry.build_log = strrep(entry.build_log, directory, '<model-audit-directory>');
entry.compile_log = strrep(entry.compile_log, directory, '<model-audit-directory>');
clear modelCleanup;

    function close_owned_model()
        try
            close_new_figures(figuresBefore);
            if bdIsLoaded(modelName)
                % The name was not loaded when this synchronous build began.
                if isempty(ownedHandle) || get_param(modelName, 'Handle') == ownedHandle
                    close_system(modelName, 0);
                else
                    error('RepositoryAudit:ModelOwnershipChanged', ...
                        'Model handle changed during the audit; left it untouched.');
                end
            end
            entry.cleanup.status = 'passed';
        catch exception
            entry.cleanup.status = 'failed';
            entry.cleanup.error = exception_summary(exception);
            entry.status = 'failed';
        end
    end
end

function result = run_model_advisor(modelName, hasCheck)
result = struct('status', 'unavailable', 'summary', struct(), ...
    'error', struct('identifier', '', 'message', ''));
if ~hasCheck
    result.error.identifier = 'RepositoryAudit:SimulinkCheckUnavailable';
    result.error.message = 'Optional Model Advisor tier requires Simulink Check.';
    return;
end
try
    % ModelAdvisor.run performs its own required-license precheck. No fix is run.
    results = ModelAdvisor.run({modelName}, ...
        {'mathworks.maab.jc_0021', 'mathworks.iec61508.UnconnectedObjects'}, ...
        'DisplayResults', 'None', 'UseParallel', 'Off');
    result.summary = results{1}.Summary;
    result.status = 'passed';
    if result.summary.Failed > 0 || result.summary.Incomplete > 0 || ...
            result.summary.NotRun > 0
        result.status = 'failed';
    elseif result.summary.Warning > 0
        result.status = 'warning';
    end
catch exception
    result.status = 'failed';
    result.error = exception_summary(exception);
end
end

function entry = empty_model_entry()
entry = struct('builder', '', 'model_name', '', 'status', 'unavailable', ...
    'build_log', '', 'compile_log', '', 'solver', struct(), 'block_count', [], ...
    'blocks', struct('path', {}, 'type', {}, 'declared_sample_time', {}), ...
    'sample_times', struct('period_offset_text', {}, 'description', {}, ...
        'owner_block', {}, 'annotation', {}), ...
    'algebraic_loops', struct('status', 'not_run', 'count', [], ...
        'query_log', '', 'details', struct('id', {}, 'artificial', {}, 'blocks', {})), ...
    'model_advisor', struct('status', 'not_requested', 'summary', struct(), ...
        'error', struct('identifier', '', 'message', '')), ...
    'cleanup', struct('status', 'not_run', ...
        'error', struct('identifier', '', 'message', '')), ...
    'error', struct('identifier', '', 'message', ''));
end

function text = property_text(object, name)
names = properties(object);
index = find(strcmpi(names, name), 1);
if isempty(index)
    text = '';
else
    text = value_text(object.(names{index}));
end
end

function text = value_text(value)
if isnumeric(value) || islogical(value)
    % Retain Inf for constant sample times instead of JSON's numeric null.
    text = mat2str(value, 17);
else
    text = char(join(string(value), ', '));
end
end

function close_new_figures(originalFigures)
currentFigures = findall(groot, 'Type', 'figure');
for index = 1:numel(currentFigures)
    if ~any(currentFigures(index) == originalFigures)
        delete(currentFigures(index));
    end
end
end

function summary = exception_summary(exception)
summary = struct('identifier', exception.identifier, 'message', exception.message);
end

function absolute = is_absolute_path(filePath)
absolute = startsWith(filePath, filesep) || ...
    ~isempty(regexp(filePath, '^[A-Za-z]:[\\/]', 'once'));
end

function write_report(report, outputPath)
if isempty(outputPath)
    return;
end
[fileId, message] = fopen(outputPath, 'w', 'n', 'UTF-8');
if fileId < 0
    error('RepositoryAudit:ReportWrite', 'Cannot write report: %s', message);
end
cleanup = onCleanup(@() fclose(fileId));
fprintf(fileId, '%s\n', jsonencode(report, 'PrettyPrint', true));
end
