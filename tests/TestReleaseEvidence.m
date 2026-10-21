classdef TestReleaseEvidence < matlab.unittest.TestCase
    % Exercise evidence validation in memory; never write fixture reports.
    methods (TestMethodSetup)
        function addAuditTools(testCase)
            root = fileparts(fileparts(mfilename('fullpath')));
            originalPath = path;
            testCase.addTeardown(@() path(originalPath));
            addpath(fullfile(root, 'tools'));
        end
    end

    methods (Test)
        function matchingEvidenceIsAccepted(testCase)
            report = evidence_fixture;
            testCase.verifyWarningFree(@() validate_release_evidence( ...
                report, "check", report.source_commit));
        end

        function missingRequiredFieldsAreRejected(testCase)
            report = evidence_fixture;
            fields = fieldnames(report);
            for index = 1:numel(fields)
                missingField = rmfield(report, fields{index});
                testCase.verifyError(@() validate_release_evidence( ...
                    missingField, "check", report.source_commit), ...
                    'ReleaseArchive:EvidenceSchema');
            end
        end

        function wrongSchemaIsRejected(testCase)
            report = evidence_fixture;
            report.schema_version = "0.0.0";
            testCase.verifyError(@() validate_release_evidence( ...
                report, "check", report.source_commit), ...
                'ReleaseArchive:EvidenceSchema');
        end

        function reportFromAnotherPhaseIsRejected(testCase)
            report = evidence_fixture;
            testCase.verifyError(@() validate_release_evidence( ...
                report, "demos", report.source_commit), ...
                'ReleaseArchive:EvidencePhase');
        end

        function unsupportedMatlabReleaseIsRejected(testCase)
            report = evidence_fixture;
            report.matlab_release = "R2025b";
            testCase.verifyError(@() validate_release_evidence( ...
                report, "check", report.source_commit), ...
                'ReleaseArchive:EvidenceRelease');
        end

        function malformedPassFlagsAreRejected(testCase)
            report = evidence_fixture;
            report.passed = [true, true];
            testCase.verifyError(@() validate_release_evidence( ...
                report, "check", report.source_commit), ...
                'ReleaseArchive:EvidenceSchema');
            report.passed = true;
            report.complete = 1;
            testCase.verifyError(@() validate_release_evidence( ...
                report, "check", report.source_commit), ...
                'ReleaseArchive:EvidenceSchema');
        end

        function malformedMetadataIsRejected(testCase)
            report = evidence_fixture;
            report.phase = ["check", "check"];
            testCase.verifyError(@() validate_release_evidence( ...
                report, "check", report.source_commit), ...
                'ReleaseArchive:EvidenceSchema');
        end

        function dirtyFailedIncompleteOrStaleEvidenceIsRejected(testCase)
            report = evidence_fixture;
            report.source_state = "worktree";
            testCase.verifyError(@() validate_release_evidence( ...
                report, "check", report.source_commit), ...
                'ReleaseArchive:Evidence');
            report = evidence_fixture;
            report.passed = false;
            testCase.verifyError(@() validate_release_evidence( ...
                report, "check", report.source_commit), ...
                'ReleaseArchive:Evidence');
            report = evidence_fixture;
            report.complete = false;
            testCase.verifyError(@() validate_release_evidence( ...
                report, "check", report.source_commit), ...
                'ReleaseArchive:Evidence');
            report = evidence_fixture;
            testCase.verifyError(@() validate_release_evidence( ...
                report, "check", string(repmat('1', 1, 40))), ...
                'ReleaseArchive:Evidence');
        end
    end
end

function report = evidence_fixture
report = struct('schema_version', "1.0.0", 'phase', "check", ...
    'matlab_release', "R2026a", ...
    'source_commit', "0123456789abcdef0123456789abcdef01234567", ...
    'source_state', "clean", 'passed', true, 'complete', true);
end
