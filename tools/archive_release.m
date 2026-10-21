function archivePath = archive_release
%ARCHIVE_RELEASE Archive only a clean, fully verified, exact-commit checkout.
root = fileparts(fileparts(mfilename('fullpath')));
originalFolder = pwd;
cleanup = onCleanup(@() cd(originalFolder));
cd(root);
[status, sha] = system('git rev-parse HEAD');
assert(status == 0, 'ReleaseArchive:Git', 'Cannot resolve the release commit.');
sha = string(strtrim(sha));
[status, dirty] = system('git status --porcelain --untracked-files=all');
assert(status == 0 && isempty(strtrim(dirty)), 'ReleaseArchive:Dirty', ...
    'Commit all source changes, then regenerate evidence for that commit.');
for phase = ["check", "test", "demos", "simulink"]
    reportPath = fullfile(root, 'validation-artifacts', "audit-" + phase + ".json");
    assert(isfile(reportPath), 'ReleaseArchive:MissingEvidence', ...
        'Missing release evidence: %s', reportPath);
    report = jsondecode(fileread(reportPath));
    validate_release_evidence(report, phase, sha);
end
metadata = jsondecode(fileread(fullfile(root, 'codemeta.json')));
releaseVersion = string(metadata.version);
assert(~isempty(regexp(releaseVersion, '^\d+\.\d+\.\d+$', 'once')), ...
    'ReleaseArchive:Version', 'Release version must be numeric SemVer.');
archivePath = fullfile(root, 'validation-artifacts', ...
    "matlab-simulink-energy-lab-v" + releaseVersion + ".zip");
% Archive the committed tree, never a mutable directory glob.
command = sprintf(['git archive --format=zip ' ...
    '--output="validation-artifacts/matlab-simulink-energy-lab-v%s.zip" HEAD'], ...
    releaseVersion);
[status, output] = system(command);
assert(status == 0, 'ReleaseArchive:Archive', '%s', output);
fprintf('Created %s from %s. No tag or remote release was published.\n', ...
    archivePath, sha);
clear cleanup;
end
