classdef TestReleaseInfrastructure < matlab.unittest.TestCase
    % Contract tests for release evidence; no physical model is mocked.
    methods (Test)
        function baseManifestRetainsItsProductBoundary(testCase)
            root = fileparts(fileparts(mfilename('fullpath')));
            originalPath = path;
            cleanup = onCleanup(@() path(originalPath));
            addpath(fullfile(root, 'examples'));
            report = struct('suite', "base-fixture", 'profile', "base_matlab", ...
                'required_products', "MATLAB", 'check_count', 1, ...
                'all_checks_passed', true, 'checks', struct( ...
                'path', "fixture.m", 'status', "passed", ...
                'error_identifier', "", 'error_message', ""));
            actual = build_validation_manifest(report, "worktree");
            testCase.verifyEqual(actual.required_products, "MATLAB");
            testCase.verifyEqual(actual.profile, "base_matlab");
            testCase.verifyEqual(jsonencode(actual), ...
                jsonencode(build_validation_manifest(report, "worktree")));
            clear cleanup;
        end

        function allBooleanFlagsRejectNonBooleanNumbers(testCase)
            root = fileparts(fileparts(mfilename('fullpath')));
            originalPath = path;
            cleanup = onCleanup(@() path(originalPath));
            addpath(fullfile(root, 'examples'));
            testCase.verifyError(@() validation_check_catalog(2, false), ...
                'ValidationCatalog:IncludeBess');
            testCase.verifyError(@() run_all_checks(false, 2, false), ...
                'ValidationChecks:ContinueOnFailure');
            testCase.verifyError(@() run_all_checks(2, true, false), ...
                'ValidationChecks:IncludeBess');
            clear cleanup;
        end

        function rootAndLegacyRunnersDelegateWithoutRecursion(testCase)
            root = fileparts(fileparts(mfilename('fullpath')));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(root));
            testCase.verifyTrue(isfile(fullfile(root, 'run_all_checks.m')));
            testCase.verifyTrue(isfile(fullfile(root, 'examples', ...
                'run_catalog_checks.m')));
            plan = buildfile;
            for name = ["base", "check", "test", "demos", "simulink", "archive"]
                testCase.verifyNotEmpty(plan(name));
            end
        end
    end
end
