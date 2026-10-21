function report = audit_repository(phase)
%AUDIT_REPOSITORY Record reproducible release evidence and separate telemetry.
% PHASE is check, test, demos, or simulink. Run from a fresh matlab -batch
% process. A passing subset is never marked as a complete release audit.
arguments
    phase (1, 1) string {mustBeMember(phase, ...
        ["check", "test", "demos", "simulink"])} = "check"
end
root = fileparts(fileparts(mfilename('fullpath')));
originalFolder = pwd;
originalPath = path;
originalVisible = get(groot, 'DefaultFigureVisible');
cleanup = onCleanup(@() restore_context(originalFolder, originalPath, ...
    originalVisible));
cd(root);
addpath(fullfile(root, 'examples'), fullfile(root, 'tools'));
set(groot, 'DefaultFigureVisible', 'off');
files = tracked_matlab_files;
[gitStatus, gitOutput] = system('git rev-parse HEAD');
assert(gitStatus == 0, 'ReleaseAudit:Git', 'A Git checkout is required.');
[dirtyStatus, dirtyOutput] = system('git status --porcelain --untracked-files=all');
assert(dirtyStatus == 0, 'ReleaseAudit:Git', 'Cannot inspect worktree state.');
report.schema_version = "1.0.0";
report.source_commit = string(strtrim(gitOutput));
report.source_state = "clean";
if strlength(strtrim(string(dirtyOutput))) > 0
    report.source_state = "worktree";
end
report.matlab_release = "R" + string(version('-release'));
report.matlab_version = string(version);
report.phase = phase;
report.simulink_available = ~isempty(ver('Simulink')) && ...
    license('test', 'Simulink');
report.claim_boundary = ...
    "Software regression evidence; not hardware or physical validation.";
report.file_count = numel(files);
report.complete = true;
telemetry = struct;

switch phase
    case "check"
        [report.files, telemetry] = inspect_code(root, files, ...
            report.simulink_available);
        report.passed = all([report.files.analyzer_clean]) && ...
            ~any(string({report.files.dependency_status}) == "failed");
        report.complete = all(string({report.files.dependency_status}) == "passed");
    case "test"
        catalogReport = run_catalog_checks(true, true, report.simulink_available);
        manifestSource = report.source_commit;
        if report.source_state == "worktree"
            manifestSource = "worktree";
        end
        report.catalog = build_validation_manifest(catalogReport, manifestSource);
        report.complete = catalogReport.complete_suite;
        telemetry.catalog = catalogReport.telemetry;
        contract = execute_entry(root, ...
            "examples/validation-manifest/check_validation_manifest.m");
        report.manifest_contract = rmfield(contract, ...
            {'elapsed_seconds', 'stdout'});
        telemetry.manifest_contract = contract;
        results = runtests(fullfile(root, 'tests'));
        report.infrastructure_tests = struct( ...
            'names', string({results.Name}), 'passed', [results.Passed], ...
            'failed', [results.Failed], 'incomplete', [results.Incomplete]);
        telemetry.infrastructure_seconds = [results.Duration];
        report.passed = catalogReport.all_checks_passed && ...
            contract.status == "passed" && ~isempty(results) && ...
            all([results.Passed]) && ~any([results.Incomplete]);
    case "demos"
        selected = files(startsWith(last_component(files), "run_"));
        entries = repmat(empty_execution(""), numel(selected), 1);
        for index = 1:numel(selected)
            if requires_simulink(selected(index)) && ~report.simulink_available
                entries(index) = empty_execution(selected(index));
                entries(index).status = "unavailable";
                entries(index).error_message = "MATLAB + Simulink is required.";
            else
                entries(index) = execute_entry(root, selected(index));
            end
        end
        telemetry.entries = entries;
        report.entries = rmfield(entries, {'elapsed_seconds', 'stdout'});
        report.passed = ~any(string({entries.status}) == "failed");
        report.complete = all(string({entries.status}) == "passed") && ...
            report.simulink_available;
    case "simulink"
        report.models = audit_simulink_models(root);
        modelEntries = report.models.models;
        logTemplate = struct('model_name', '', 'build_log', '', ...
            'compile_log', '', 'algebraic_loop_query_log', '');
        telemetry.models = repmat(logTemplate, numel(modelEntries), 1);
        for index = 1:numel(modelEntries)
            telemetry.models(index).model_name = modelEntries(index).model_name;
            telemetry.models(index).build_log = modelEntries(index).build_log;
            telemetry.models(index).compile_log = modelEntries(index).compile_log;
            telemetry.models(index).algebraic_loop_query_log = ...
                modelEntries(index).algebraic_loops.query_log;
            modelEntries(index).algebraic_loops = ...
                rmfield(modelEntries(index).algebraic_loops, 'query_log');
        end
        report.models.models = rmfield(modelEntries, {'build_log', 'compile_log'});
        report.passed = string(report.models.status) == "passed";
        report.complete = report.passed && report.simulink_available;
end

outputDirectory = fullfile(root, 'validation-artifacts');
if ~isfolder(outputDirectory)
    mkdir(outputDirectory);
end
stem = fullfile(outputDirectory, "audit-" + phase);
write_json(stem + ".json", report);
write_json(stem + "-telemetry.json", telemetry);
write_summary(stem + ".md", report);
fprintf('Release audit %s: passed=%d, complete=%d, source=%s (%s).\n', ...
    phase, report.passed, report.complete, report.source_commit, ...
    report.source_state);
clear cleanup;
end

function files = tracked_matlab_files
[status, output] = system('git ls-files --cached --others --exclude-standard -- "*.m"');
assert(status == 0, 'ReleaseAudit:Inventory', 'Cannot enumerate MATLAB files.');
files = sort(unique(string(splitlines(strtrim(output)))));
files(files == "") = [];
assert(~isempty(files), 'ReleaseAudit:Inventory', 'MATLAB inventory is empty.');
end

function [records, telemetry] = inspect_code(root, files, simulinkAvailable)
template = struct('path', "", 'analyzer_clean', false, ...
    'diagnostics', struct([]), 'complexity', struct([]), ...
    'dependency_status', "not_run", 'required_files', strings(0, 1), ...
    'required_products', struct([]), 'allowed_products', strings(0, 1), ...
    'error_identifier', "", 'error_message', "");
records = repmat(template, numel(files), 1);
seconds = zeros(numel(files), 1);
% Function-based dependencies resolve against this complete source tree.
% requiredFilesAndProducts can only report installed products; the independent
% Base-MATLAB-only CI job remains a required toolchain-isolation gate.
originalPath = path;
cleanup = onCleanup(@() path(originalPath));
addpath(genpath(fullfile(root, 'examples')), fullfile(root, 'tools'));
for index = 1:numel(files)
    started = tic;
    records(index).path = files(index);
    source = fullfile(root, files(index));
    try
        records(index).diagnostics = checkcode(source, '-id', '-struct');
        records(index).complexity = checkcode(source, '-cyc', '-id', '-struct');
        records(index).analyzer_clean = isempty(records(index).diagnostics);
        allowed = "MATLAB";
        if requires_simulink(files(index)) || is_orchestration(files(index))
            allowed = ["MATLAB", "Simulink"];
        end
        if startsWith(files(index), "tools/") || files(index) == "buildfile.m"
            % Model Advisor is optional and explicitly requested. Its
            % presence in transitive static dependencies is not a core lock.
            allowed = ["MATLAB", "Simulink", "Simulink Check"];
        end
        records(index).allowed_products = allowed;
        if requires_simulink(files(index)) && ~simulinkAvailable
            records(index).dependency_status = "unavailable";
            records(index).error_message = ...
                "Simulink dependency analysis requires an installed product.";
        else
            [requiredFiles, products] = ...
                matlab.codetools.requiredFilesAndProducts(source);
            records(index).required_files = sort(strrep( ...
                erase(string(requiredFiles), string(root) + filesep), ...
                filesep, '/'));
            if ~isempty(products)
                [~, productOrder] = sort(string({products.Name}));
                products = products(productOrder);
            end
            records(index).required_products = products;
            unexpected = setdiff(string({products.Name}), allowed);
            if ~isempty(unexpected)
                error('ReleaseAudit:ToolboxLeak', ...
                    'Undeclared products: %s', strjoin(unexpected, ', '));
            end
            records(index).dependency_status = "passed";
        end
    catch diagnosticError
        records(index).dependency_status = "failed";
        records(index).error_identifier = string(diagnosticError.identifier);
        records(index).error_message = string(diagnosticError.message);
    end
    seconds(index) = toc(started);
end
telemetry = struct('paths', files, 'elapsed_seconds', seconds);
clear cleanup;
end

function result = execute_entry(root, relativePath)
result = empty_execution(relativePath);
originalFolder = pwd;
originalPath = path;
originalRng = rng;
originalFigures = findall(groot, 'Type', 'figure');
hasSimulink = ~isempty(ver('Simulink')) && license('test', 'Simulink');
originalDiagrams = [];
fileGenerationConfig = [];
if hasSimulink
    originalDiagrams = Simulink.allBlockDiagrams;
    fileGenerationConfig = Simulink.fileGenControl('getConfig');
end
restorationError = [];
cleanup = onCleanup(@restore_owned_context);
% evalc assigns into this static workspace; the variable must already exist.
executionError = [];
started = tic;
try
    source = fullfile(root, relativePath);
    addpath(fileparts(source));
    text = fileread(source);
    codeLines = strip(string(splitlines(text)));
    codeLines = codeLines(strlength(codeLines) > 0 & ~startsWith(codeLines, "%"));
    firstCode = codeLines(1);
    isFunction = startsWith(strtrim(string(firstCode)), "function");
    result.stdout = string(evalc( ...
        'executionError = execute_selected(source, isFunction);'));
    if isempty(executionError)
        result.status = "passed";
    else
        result.status = "failed";
        result.error_identifier = string(executionError.identifier);
        result.error_message = string(executionError.message);
    end
catch executionError
    result.status = "failed";
    result.error_identifier = string(executionError.identifier);
    result.error_message = string(executionError.message);
end
result.elapsed_seconds = toc(started);
currentFigures = findall(groot, 'Type', 'figure');
result.new_figure_count = nnz(~ismember(currentFigures, originalFigures));
result.caller_figures_preserved = all(isgraphics(originalFigures));
if ~result.caller_figures_preserved
    result.status = "failed";
    result.error_identifier = "ReleaseAudit:CallerFigure";
    result.error_message = "The entry point closed a caller-owned figure.";
end
if hasSimulink
    currentDiagrams = Simulink.allBlockDiagrams;
    newDiagrams = currentDiagrams(~ismember(currentDiagrams, originalDiagrams));
    result.new_block_diagram_count = numel(newDiagrams);
    if ~isempty(newDiagrams)
        result.new_block_diagrams = sort(string(get_param(newDiagrams, 'Name')));
    end
    result.caller_models_preserved = all(ismember(originalDiagrams, currentDiagrams));
    if ~result.caller_models_preserved
        result.status = "failed";
        result.error_identifier = "ReleaseAudit:CallerModel";
        result.error_message = "The entry point closed a caller-owned model or library.";
    end
end
clear cleanup;
result.cleanup_status = "passed";
if ~isempty(restorationError)
    result.cleanup_status = "failed";
    result.status = "failed";
    result.error_identifier = string(restorationError.identifier);
    result.error_message = string(restorationError.message);
end

    function restore_owned_context
        try
            restore_entry(originalFolder, originalPath, originalRng, ...
                originalFigures, originalDiagrams, fileGenerationConfig);
        catch cleanupError
            restorationError = cleanupError;
        end
    end
end

function executionError = execute_selected(source, isFunction)
executionError = [];
try
    if isFunction
        [~, functionName] = fileparts(source);
        % Resolve the requested root or legacy wrapper from its own folder.
        cd(fileparts(source));
        feval(functionName);
    else
        run_in_child_workspace(source);
    end
catch caughtError
    executionError = caughtError;
end
end

function run_in_child_workspace(source)
run(source);
end

function result = empty_execution(relativePath)
result = struct('path', relativePath, 'status', "not_run", ...
    'error_identifier', "", 'error_message', "", ...
    'elapsed_seconds', NaN, 'stdout', "", 'new_figure_count', 0, ...
    'caller_figures_preserved', true, 'new_block_diagram_count', 0, ...
    'new_block_diagrams', strings(0, 1), 'caller_models_preserved', true, ...
    'cleanup_status', "not_run");
end

function names = last_component(paths)
names = regexprep(paths, '^.*/', '');
end

function yes = requires_simulink(relativePath)
yes = contains(relativePath, "simulink") || ...
    startsWith(relativePath, "examples/bess-unified-control/");
end

function yes = is_orchestration(relativePath)
yes = startsWith(relativePath, "tools/") || ...
    startsWith(relativePath, "tests/") || ...
    relativePath == "buildfile.m" || relativePath == "run_all_checks.m" || ...
    startsWith(relativePath, "examples/run_") || ...
    relativePath == "examples/generate_validation_manifest.m";
end

function restore_entry(folder, originalPath, originalRng, originalFigures, ...
        originalDiagrams, fileGenerationConfig)
actions = {@() close_new_figures(originalFigures), @() rng(originalRng), ...
    @() cd(folder), @() path(originalPath)};
if ~isempty(fileGenerationConfig)
    actions = [{@() close_new_diagrams(originalDiagrams), ...
        @() Simulink.fileGenControl('setConfig', 'config', fileGenerationConfig)}, ...
        actions];
end
firstError = [];
for index = 1:numel(actions)
    try
        actions{index}();
    catch cleanupError
        if isempty(firstError)
            firstError = cleanupError;
        end
    end
end
if ~isempty(firstError)
    rethrow(firstError);
end
end

function close_new_diagrams(originalDiagrams)
currentDiagrams = Simulink.allBlockDiagrams;
newDiagrams = currentDiagrams(~ismember(currentDiagrams, originalDiagrams));
firstError = [];
for index = 1:numel(newDiagrams)
    try
        if ismember(newDiagrams(index), Simulink.allBlockDiagrams)
            close_system(newDiagrams(index), 0);
        end
    catch cleanupError
        if isempty(firstError)
            firstError = cleanupError;
        end
    end
end
if ~isempty(firstError)
    rethrow(firstError);
end
end

function close_new_figures(originalFigures)
currentFigures = findall(groot, 'Type', 'figure');
newFigures = currentFigures(~ismember(currentFigures, originalFigures));
if ~isempty(newFigures)
    delete(newFigures);
end
end

function restore_context(folder, originalPath, visible)
set(groot, 'DefaultFigureVisible', visible);
cd(folder);
path(originalPath);
end

function write_json(filePath, value)
identifier = fopen(filePath, 'w', 'n', 'UTF-8');
assert(identifier >= 0, 'ReleaseAudit:Write', 'Cannot open %s.', filePath);
cleanup = onCleanup(@() fclose(identifier));
fprintf(identifier, '%s\n', jsonencode(value, PrettyPrint=true));
clear cleanup;
end

function write_summary(filePath, report)
identifier = fopen(filePath, 'w', 'n', 'UTF-8');
assert(identifier >= 0, 'ReleaseAudit:Write', 'Cannot open %s.', filePath);
cleanup = onCleanup(@() fclose(identifier));
fprintf(identifier, '# Release audit: %s\n\n', report.phase);
fprintf(identifier, '- Source commit: `%s`\n', report.source_commit);
fprintf(identifier, '- Source state: `%s`\n', report.source_state);
fprintf(identifier, '- MATLAB: `%s`\n', report.matlab_release);
fprintf(identifier, '- Passed selected checks: `%d`\n', report.passed);
fprintf(identifier, '- Complete required scope: `%d`\n\n', report.complete);
fprintf(identifier, '%s\n\n', report.claim_boundary);
fprintf(identifier, ['See the adjacent JSON for every item and the separate ' ...
    'telemetry JSON for volatile timing/stdout.\n']);
clear cleanup;
end
