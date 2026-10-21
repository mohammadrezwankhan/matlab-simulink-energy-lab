classdef TestBessPlotOwnership < matlab.unittest.TestCase
    %TESTBESSPLOTOWNERSHIP A demo must preserve the caller's current figure.

    methods (Test)
        function demoPreservesExistingAxesAndLine(testCase)
            exampleDirectory = fileparts(fileparts(mfilename('fullpath')));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                {exampleDirectory, fullfile(exampleDirectory, 'src')}));
            originalFigures = findall(groot, 'Type', 'figure');
            originalVisibility = get(groot, 'DefaultFigureVisible');
            cleanup = onCleanup(@() restore_figures( ...
                originalFigures, originalVisibility));
            set(groot, 'DefaultFigureVisible', 'off');
            callerFigure = figure('Visible', 'off');
            callerAxes = axes('Parent', callerFigure);
            callerLine = plot(callerAxes, [1, 2, 3], [7, 11, 13]);

            run_bess_unified_control('A');

            testCase.verifyTrue(isgraphics(callerFigure));
            testCase.verifyTrue(isgraphics(callerAxes));
            testCase.assertTrue(isgraphics(callerLine));
            testCase.verifyEqual(callerLine.YData, [7, 11, 13]);
            testCase.verifyNotEqual(get(groot, 'CurrentFigure'), callerFigure);
        end
    end
end

function restore_figures(originalFigures, originalVisibility)
set(groot, 'DefaultFigureVisible', originalVisibility);
currentFigures = findall(groot, 'Type', 'figure');
for index = 1:numel(currentFigures)
    if ~any(currentFigures(index) == originalFigures)
        delete(currentFigures(index));
    end
end
end
