classdef TestScriptIsolation < matlab.unittest.TestCase
    % Exercise actual public script entry points in a caller-owned workspace.
    methods (Test)
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
