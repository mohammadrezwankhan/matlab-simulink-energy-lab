classdef bess_validate_output_timeTest < matlab.unittest.TestCase
    %BESS_VALIDATE_OUTPUT_TIMETEST Prevent silent relabeling of logged data.

    properties (TestParameter)
        InvalidClock = {[], [0 NaN 0.01], [0 Inf 0.01], ...
            [0 0.005 0.005], [0.01 0.005 0], [0 0.005], ...
            [0.005 0.01 0.015], [0 0.006 0.01], ...
            [0 0.005; 0.01 0.015], 'abc', [0 0.005 0.01+1i]}
    end

    methods (TestMethodSetup)
        function configurePath(testCase)
            exampleDirectory = fileparts(fileparts(mfilename('fullpath')));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                fullfile(exampleDirectory, 'src')));
        end
    end

    methods (Test)
        function matchingClockAccepted(testCase)
            testCase.verifyWarningFree(@() bess_validate_output_time( ...
                [0; 0.005; 0.01], [0 0.005 0.01]));
        end

        function singleSampleAccepted(testCase)
            testCase.verifyWarningFree(@() bess_validate_output_time(0, 0));
        end

        function roundoffAccepted(testCase)
            testCase.verifyWarningFree(@() bess_validate_output_time( ...
                [0 0.005+1e-13 0.01], [0 0.005 0.01]));
        end

        function invalidLoggedClockRejected(testCase, InvalidClock)
            testCase.verifyError(@() bess_validate_output_time( ...
                InvalidClock, [0 0.005 0.01]), ...
                'BessUnifiedControl:ModelOutputTime');
        end

        function invalidExpectedClockRejected(testCase, InvalidClock)
            testCase.verifyError(@() bess_validate_output_time( ...
                [0 0.005 0.01], InvalidClock), ...
                'BessUnifiedControl:ModelOutputTime');
        end
    end
end
