%% Validation Manifest Contract Check
% Verifies the catalog and deterministic commit-bound JSON contract.

clearvars; clc;

examplesDirectory = fileparts(fileparts(mfilename('fullpath')));
checks = validation_check_catalog(false);
allChecks = validation_check_catalog(true);
assert(numel(unique(checks)) == numel(checks), ...
    'Validation check paths must be unique.');
assert(all(arrayfun(@(item) isfile(fullfile(examplesDirectory, item)), ...
    checks)), 'Every validation check path must exist.');
assert(numel(allChecks) == numel(checks) + 1 && ...
    allChecks(end) == ...
    "bess-unified-control/check_bess_unified_control.m", ...
    'The complete catalog must add exactly the unified BESS entry point.');

checkResults = repmat(struct('path', "", 'status', "passed"), ...
    numel(checks), 1);
for checkIndex = 1:numel(checks)
    checkResults(checkIndex).path = checks(checkIndex);
end
report.suite = "run_all_checks(false)";
report.check_count = numel(checks);
report.all_checks_passed = true;
report.checks = checkResults;
sourceCommit = "0123456789abcdef0123456789abcdef01234567";
firstManifest = build_validation_manifest(report, sourceCommit);
secondManifest = build_validation_manifest(report, sourceCommit);
firstJson = jsonencode(firstManifest, PrettyPrint=true);
secondJson = jsonencode(secondManifest, PrettyPrint=true);

assert(strcmp(firstJson, secondJson), ...
    'Repeated manifest builds must be byte-identical.');
assert(firstManifest.source_commit == sourceCommit && ...
    firstManifest.check_count == numel(checks) && ...
    firstManifest.status == "passed", ...
    'Manifest provenance and status fields must match the executed report.');
assert(numel(firstManifest.claim_boundaries) >= 3 && ...
    strlength(firstManifest.related_evidence.unified_bess_schema_example) > 0, ...
    'Manifest must retain claim boundaries and separate BESS evidence.');

invalidCommitRejected = false;
try
    build_validation_manifest(report, "not-a-commit");
catch validationError
    invalidCommitRejected = strcmp(validationError.identifier, ...
        'ValidationManifest:SourceCommit');
end
assert(invalidCommitRejected, ...
    'Manifest builder must reject an invalid source commit.');

failedReport = report;
failedReport.checks(1).status = "failed";
failedStatusRejected = false;
try
    build_validation_manifest(failedReport, sourceCommit);
catch validationError
    failedStatusRejected = strcmp(validationError.identifier, ...
        'ValidationManifest:Status');
end
assert(failedStatusRejected, ...
    'Manifest builder must reject a failed check status.');

fprintf('Validation manifest contract check passed.\n');
