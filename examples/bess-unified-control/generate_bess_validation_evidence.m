function evidence = generate_bess_validation_evidence(sourceCommit)
%GENERATE_BESS_VALIDATION_EVIDENCE Regenerate metrics, JSON, and plots.

if nargin < 1 || strlength(string(sourceCommit)) == 0
    sourceCommit = "WORKTREE";
end
exampleDirectory = fileparts(mfilename('fullpath'));
sourceDirectory = fullfile(exampleDirectory, 'src');
validationDirectory = fullfile(exampleDirectory, 'validation');
originalPath = path;
pathCleanup = onCleanup(@() path(originalPath));
addpath(exampleDirectory, sourceDirectory);
parameters = bess_unified_control_parameters();
scenarios = bess_validation_scenarios(parameters);
modelDirectory = tempname;
modelCleanup = onCleanup(@() remove_directory(modelDirectory));
modelPath = build_bess_unified_control_model( ...
    modelDirectory, scenarios(1), parameters);

scenarioEvidence = repmat(struct(), 1, numel(scenarios));
results = cell(size(scenarios));
for scenarioIndex = 1:numel(scenarios)
    scenario = scenarios(scenarioIndex);
    results{scenarioIndex} = simulate_bess_unified_control_model( ...
        scenario, parameters, modelPath);
    score = bess_score_scenario(results{scenarioIndex}, parameters);
    assert(score.passed, 'BessUnifiedControl:EvidenceFailure', ...
        'Scenario %s failed while generating evidence: %s', ...
        scenario.id, strjoin(score.failures, newline));
    scenarioEvidence(scenarioIndex).id = scenario.id;
    scenarioEvidence(scenarioIndex).name = scenario.description;
    scenarioEvidence(scenarioIndex).passed = score.passed;
    scenarioEvidence(scenarioIndex).metrics = score.metrics;
end

evidence.schema_version = "1.0.0";
evidence.generated_utc = string(datetime('now', ...
    'TimeZone', 'UTC', 'Format', 'yyyy-MM-dd''T''HH:mm:ss''Z'''));
evidence.source_commit = string(sourceCommit);
evidence.matlab_release = string(version('-release'));
evidence.matlab_version = string(version);
evidence.required_products = ["MATLAB", "Simulink"];
evidence.model_builder = "build_bess_unified_control_model.m";
evidence.scenario_count = numel(scenarios);
focusedSuite = testsuite(fullfile(exampleDirectory, 'tests'));
evidence.focused_test_count = numel(focusedSuite);
evidence.all_scenarios_passed = all([scenarioEvidence.passed]);
evidence.scenarios = scenarioEvidence;
evidence.acceptance_basis = ...
    "Paper FRT statement plus documented PROJECT_ASSUMPTION gates";
evidence.code_analyzer = analyze_code(exampleDirectory);
assert(evidence.code_analyzer.message_count == 0, ...
    'BessUnifiedControl:CodeAnalyzer', ...
    'Code Analyzer reported one or more messages.');
evidence.qualification = ...
    "Educational research translation; not plant or grid-code certification";

if ~isfolder(validationDirectory)
    mkdir(validationDirectory);
end
jsonText = jsonencode(evidence, PrettyPrint=true);
write_text(fullfile(validationDirectory, 'results.json'), jsonText);
create_transition_plot(results{3}, fullfile(validationDirectory, ...
    'scenario-c-grid-loss-transition.png'));
create_reconnection_plot(results{5}, fullfile(validationDirectory, ...
    'scenario-e-reconnection.png'));
create_limit_plot(results{6}, parameters, fullfile(validationDirectory, ...
    'scenario-f-current-limit.png'));
fprintf('Generated validation evidence for %d passing scenarios.\n', ...
    numel(scenarios));
clear modelCleanup pathCleanup;
end

function create_transition_plot(result, outputPath)
figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 1000, 760]);
cleanup = onCleanup(@() close(figureHandle));
tiledlayout(4, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
nexttile;
plot(result.time_s, result.p_pu, 'LineWidth', 1.4);
hold on;
plot(result.time_s, result.q_pu, 'LineWidth', 1.4);
grid on; ylabel('Power (p.u.)'); legend('P', 'Q', 'Location', 'best');
title('Scenario C — grid loss and islanded support');
nexttile;
plot(result.time_s, result.voltage_pu, 'LineWidth', 1.4);
grid on; ylabel('PCC V (p.u.)'); ylim([0.84, 1.16]);
nexttile;
plot(result.time_s, result.frequency_Hz, 'LineWidth', 1.4);
grid on; ylabel('f (Hz)');
nexttile;
stairs(result.time_s, result.state_code, 'LineWidth', 1.4);
grid on; ylabel('State code'); xlabel('Time (s)');
exportgraphics(figureHandle, outputPath, 'Resolution', 160);
clear cleanup;
end

function create_reconnection_plot(result, outputPath)
figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 1000, 760]);
cleanup = onCleanup(@() close(figureHandle));
tiledlayout(4, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
nexttile;
stairs(result.time_s, result.breaker_closed, 'LineWidth', 1.4);
hold on;
stairs(result.time_s, result.sync_ready, 'LineWidth', 1.2);
grid on; ylabel('Logic'); legend('Breaker', 'Sync ready', ...
    'Location', 'best');
title('Scenario E — synchronized grid reconnection');
nexttile;
plot(result.time_s, result.voltage_mismatch_pu, 'LineWidth', 1.4);
grid on; ylabel('\DeltaV (p.u.)');
nexttile;
plot(result.time_s, result.frequency_mismatch_Hz, 'LineWidth', 1.4);
grid on; ylabel('\Deltaf (Hz)');
nexttile;
plot(result.time_s, rad2deg(result.phase_error_rad), ...
    'LineWidth', 1.4);
grid on; ylabel('\Delta\theta (deg)'); xlabel('Time (s)');
exportgraphics(figureHandle, outputPath, 'Resolution', 160);
clear cleanup;
end

function create_limit_plot(result, parameters, outputPath)
figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 1000, 620]);
cleanup = onCleanup(@() close(figureHandle));
tiledlayout(3, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
nexttile;
plot(result.time_s, result.p_ref_pu, '--', 'LineWidth', 1.2);
hold on;
plot(result.time_s, result.p_pu, 'LineWidth', 1.4);
grid on; ylabel('P (p.u.)'); legend('Reference', 'Measured', ...
    'Location', 'best');
title('Scenario F — infeasible command limiting and recovery');
nexttile;
plot(result.time_s, result.q_ref_pu, '--', 'LineWidth', 1.2);
hold on;
plot(result.time_s, result.q_pu, 'LineWidth', 1.4);
grid on; ylabel('Q (p.u.)'); legend('Reference', 'Measured', ...
    'Location', 'best');
nexttile;
plot(result.time_s, result.current_pu, 'LineWidth', 1.4);
hold on;
yline(parameters.current_limit_pu, '--r', 'Hard limit');
grid on; ylabel('Current (p.u.)'); xlabel('Time (s)');
exportgraphics(figureHandle, outputPath, 'Resolution', 160);
clear cleanup;
end

function write_text(filePath, text)
fileIdentifier = fopen(filePath, 'w', 'n', 'UTF-8');
if fileIdentifier < 0
    error('BessUnifiedControl:EvidenceWrite', ...
        'Could not open evidence file: %s', filePath);
end
cleanup = onCleanup(@() fclose(fileIdentifier));
fprintf(fileIdentifier, '%s\n', text);
clear cleanup;
end

function remove_directory(directory)
if isfolder(directory)
    rmdir(directory, 's');
end
end

function analysis = analyze_code(exampleDirectory)
files = dir(fullfile(exampleDirectory, '**', '*.m'));
messages = struct('file', {}, 'line', {}, 'id', {}, 'message', {});
for fileIndex = 1:numel(files)
    filePath = fullfile(files(fileIndex).folder, files(fileIndex).name);
    fileMessages = checkcode(filePath, '-id');
    for messageIndex = 1:numel(fileMessages)
        entry.file = string(erase(filePath, ...
            [exampleDirectory, filesep]));
        entry.line = fileMessages(messageIndex).line;
        entry.id = string(fileMessages(messageIndex).id);
        entry.message = string(fileMessages(messageIndex).message);
        messages(end + 1) = entry; %#ok<AGROW>
    end
end
analysis.file_count = numel(files);
analysis.message_count = numel(messages);
analysis.messages = messages;
end
