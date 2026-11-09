classdef TestLfpPulseData < matlab.unittest.TestCase
    methods (Test)
        function recordsHaveExpectedUnitsAndSplit(testCase)
            root = fileparts(fileparts(mfilename('fullpath')));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                fullfile(root, 'examples', 'battery-2rc-model')));
            s = build_lfp_fit_scenario();
            testCase.verifyEqual(height(s.calibration_data), 400);
            testCase.verifyEqual(height(s.validation_data), 1500);
            testCase.verifyGreaterThan(min(diff(s.calibration_data.time_s)), 0);
            testCase.verifyGreaterThan(min(diff(s.validation_data.time_s)), 0);
            testCase.verifyGreaterThan(s.calibration_data.current_A(1), 19);
            testCase.verifyEqual(s.validation_data.current_A(1), 0, ...
                'AbsTol', 1e-3);
            testCase.verifyGreaterThan( ...
                min(diff(s.initial_parameters.ocv_soc_breakpoints)), 0);
            testCase.verifyGreaterThanOrEqual( ...
                min(diff(s.initial_parameters.ocv_lookup_V)), 0);
            result = evaluate_battery_2rc_fit( ...
                s.calibration_data, s.initial_parameters);
            testCase.verifyEqual(result.simulation.ocv_V, ...
                s.calibration_data.ocv_V, 'AbsTol', 1e-8);
        end

        function preparationDoesNotOverwrite(testCase)
            root = fileparts(fileparts(mfilename('fullpath')));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                fullfile(root, 'examples', 'battery-2rc-model')));
            folder = testCase.applyFixture( ...
                matlab.unittest.fixtures.TemporaryFolderFixture);
            source = fullfile(folder.Folder, 'source.mat');
            output = fullfile(folder.Folder, 'calibration.csv');
            fclose(fopen(source, 'w'));
            fclose(fopen(output, 'w'));
            testCase.verifyError(@() prepare_lfp_data( ...
                source, source, source, folder.Folder), 'LFP:Exists');
        end
    end
end
