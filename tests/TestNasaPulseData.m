classdef TestNasaPulseData < matlab.unittest.TestCase
    methods (Test)
        function scenarioUsesSeparateMeasuredRecords(testCase)
            root = fileparts(fileparts(mfilename('fullpath')));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                fullfile(root, 'examples', 'battery-2rc-model')));
            testCase.assertNotEmpty(which('build_nasa_rw3_fit_scenario'));
            s = build_nasa_rw3_fit_scenario();
            testCase.verifyEqual(height(s.calibration_data), 546);
            testCase.verifyEqual(height(s.validation_data), 395);
            testCase.verifyEqual(s.calibration_data.time_s(1), 0);
            testCase.verifyEqual(s.validation_data.time_s(1), 0);
            testCase.verifyEqual(s.calibration_data.current_A(1), 0);
            testCase.verifyEqual(s.validation_data.current_A(1), 0);
            testCase.verifyGreaterThan(min(diff(s.calibration_data.time_s)), 0);
            testCase.verifyGreaterThan(min(diff(s.validation_data.time_s)), 0);
            testCase.verifyEqual(s.initial_parameters.capacity_Ah, ...
                2.1191638166664273, 'AbsTol', 1e-9);
            testCase.verifyEqual(s.validation_initial_soc, ...
                0.764099627691965, 'AbsTol', 1e-9);
            testCase.verifyGreaterThan( ...
                min(diff(s.initial_parameters.ocv_soc_breakpoints)), 0);
            testCase.verifyGreaterThanOrEqual( ...
                min(diff(s.initial_parameters.ocv_lookup_V)), 0);
            parameters = s.initial_parameters;
            parameters.initial_soc = s.validation_initial_soc;
            result = evaluate_battery_2rc_fit(s.validation_data, parameters);
            testCase.verifyEqual(result.simulation.ocv_V, ...
                s.validation_data.ocv_V, 'AbsTol', 1e-8);
        end

        function preparationRejectsMissingSource(testCase)
            root = fileparts(fileparts(mfilename('fullpath')));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                fullfile(root, 'examples', 'battery-2rc-model')));
            folder = testCase.applyFixture( ...
                matlab.unittest.fixtures.TemporaryFolderFixture);
            testCase.verifyError(@() prepare_nasa_rw3_data( ...
                fullfile(folder.Folder, 'missing.mat'), folder.Folder), ...
                'NasaRW3:Path');
        end

        function preparationDoesNotOverwriteFixtures(testCase)
            root = fileparts(fileparts(mfilename('fullpath')));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                fullfile(root, 'examples', 'battery-2rc-model')));
            folder = testCase.applyFixture( ...
                matlab.unittest.fixtures.TemporaryFolderFixture);
            source = fullfile(folder.Folder, 'source.mat');
            calibration = fullfile(folder.Folder, 'calibration.csv');
            fclose(fopen(source, 'w'));
            fclose(fopen(calibration, 'w'));
            testCase.verifyError(@() prepare_nasa_rw3_data( ...
                source, folder.Folder), 'NasaRW3:Exists');
        end
    end
end
