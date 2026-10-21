classdef TestScriptIsolation < matlab.unittest.TestCase
    % Exercise actual public script entry points in a caller-owned workspace.
    methods (Test)
        function catalogRestoresFileGenerationAfterSuccess(testCase)
            verify_catalog_file_generation(testCase, false);
        end

        function catalogRestoresFileGenerationAfterFailure(testCase)
            verify_catalog_file_generation(testCase, true);
        end

        function baseChecksPreserveCallerState(testCase)
            root = fileparts(fileparts(mfilename('fullpath')));
            originalPath = path;
            pathCleanup = onCleanup(@() path(originalPath));
            addpath(fullfile(root, 'examples'));
            checks = validation_check_catalog(false, false);
            sentinelFigure = figure('Visible', 'off');
            figureCleanup = onCleanup(@() delete_if_valid(sentinelFigure));
            for index = 1:numel(checks)
                probe_script(fullfile(root, 'examples', checks(index)));
                testCase.verifyTrue(isgraphics(sentinelFigure), ...
                    'A no-plot check must not close a caller-owned figure.');
            end
            clear figureCleanup pathCleanup;
        end
    end
end

function verify_catalog_file_generation(testCase, failCheck)
testCase.assumeTrue(~isempty(ver('Simulink')) && license('test', 'Simulink'));
root = fileparts(fileparts(mfilename('fullpath')));
originalConfig = Simulink.fileGenControl('getConfig');
fixture = testCase.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture);
directory = fixture.Folder;
copyfile(fullfile(root, 'examples', 'run_catalog_checks.m'), directory);
write_source(fullfile(directory, 'validation_check_catalog.m'), ...
    ["function checks = validation_check_catalog(varargin)"; ...
    "checks = ""fixture/check_file_generation.m"";"; "end"]);
mkdir(fullfile(directory, 'fixture'));
source = ["Simulink.fileGenControl('set', ..."; ...
    "    'CacheFolder', fullfile(pwd, 'cache'), ..."; ...
    "    'CodeGenFolder', fullfile(pwd, 'codegen'), 'createDir', true);"];
if failCheck
    source(end + 1) = "error('ScriptIsolation:ForcedFailure', 'Deliberate fixture failure.');";
end
write_source(fullfile(directory, 'fixture', 'check_file_generation.m'), source);
testCase.applyFixture(matlab.unittest.fixtures.CurrentFolderFixture(directory));
testCase.applyFixture(matlab.unittest.fixtures.PathFixture(directory));
testCase.addTeardown(@() Simulink.fileGenControl('setConfig', 'config', originalConfig));
Simulink.fileGenControl('set', ...
    'CacheFolder', fullfile(directory, 'caller-cache'), ...
    'CodeGenFolder', fullfile(directory, 'caller-codegen'), 'createDir', true);
before = Simulink.fileGenControl('getConfig');
clear run_catalog_checks validation_check_catalog;
testCase.addTeardown(@clear_catalog_functions);
if failCheck
    testCase.verifyError(@() run_catalog_checks(false, false, true), ...
        'ScriptIsolation:ForcedFailure');
else
    report = run_catalog_checks(false, true, true);
    testCase.verifyTrue(report.all_checks_passed);
    testCase.verifyEqual(report.check_count, 1);
end
testCase.verifyEqual(Simulink.fileGenControl('getConfig'), before, ...
    'The catalog must restore caller file-generation settings on every exit.');
end

function clear_catalog_functions
clear run_catalog_checks validation_check_catalog;
end

function write_source(destination, lines)
fileId = fopen(destination, 'w');
assert(fileId >= 0, 'Cannot create the isolated catalog fixture.');
cleanup = onCleanup(@() fclose(fileId));
fprintf(fileId, '%s\n', lines);
end

function probe_script(scriptPath)
sentinel = uint64(314159);
beforePath = path;
beforeFolder = pwd;
beforeRng = rng;
beforeFigures = findall(groot, 'Type', 'figure');
run(scriptPath);
assert(exist('sentinel', 'var') == 1 && sentinel == uint64(314159), ...
    'ScriptIsolation:Workspace', 'The script modified its caller workspace.');
assert(strcmp(path, beforePath), 'ScriptIsolation:Path', ...
    'The script did not restore the caller path.');
assert(strcmp(pwd, beforeFolder), 'ScriptIsolation:Folder', ...
    'The script did not restore the caller folder.');
assert(isequal(rng, beforeRng), 'ScriptIsolation:Rng', ...
    'The script changed the caller random-number stream.');
afterFigures = findall(groot, 'Type', 'figure');
assert(all(isgraphics(beforeFigures)) && numel(beforeFigures) == numel(afterFigures), ...
    'ScriptIsolation:Figures', 'A no-plot check changed figure ownership.');
end

function delete_if_valid(handle)
if isgraphics(handle)
    delete(handle);
end
end
