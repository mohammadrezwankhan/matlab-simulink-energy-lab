function manifest = generate_validation_manifest(sourceCommit, outputPath)
%GENERATE_VALIDATION_MANIFEST Run general checks and write commit-bound JSON.

if nargin < 1 || strlength(string(sourceCommit)) == 0
    sourceCommit = getenv('GITHUB_SHA');
end
if strlength(string(sourceCommit)) == 0
    sourceCommit = "WORKTREE";
end
examplesDirectory = fileparts(mfilename('fullpath'));
repositoryDirectory = fileparts(examplesDirectory);
if nargin < 2 || strlength(string(outputPath)) == 0
    outputPath = fullfile(repositoryDirectory, 'validation-artifacts', ...
        'validation-summary.json');
end

sourceCommit = lower(string(sourceCommit));
verify_checkout_commit(sourceCommit);
report = run_all_checks(false, true);
manifest = build_validation_manifest(report, sourceCommit);
outputDirectory = fileparts(outputPath);
if ~isfolder(outputDirectory)
    mkdir(outputDirectory);
end
write_text(outputPath, jsonencode(manifest, PrettyPrint=true));
fprintf('Wrote commit-bound validation manifest for %d passing checks.\n', ...
    nnz(string({manifest.checks.status}) == "passed"));
if ~report.all_checks_passed
    error('ValidationManifest:ChecksFailed', ...
        'One or more validation checks failed; inspect the JSON artifact.');
end
end

function verify_checkout_commit(sourceCommit)
if sourceCommit == "worktree"
    return;
end
[gitStatus, gitOutput] = system('git rev-parse HEAD');
checkoutCommit = lower(strtrim(string(gitOutput)));
if gitStatus ~= 0 || checkoutCommit ~= sourceCommit
    error('ValidationManifest:CommitMismatch', ...
        'Manifest source commit does not match the checked-out Git commit.');
end
[statusCode, statusOutput] = system( ...
    'git status --porcelain --untracked-files=all');
if statusCode ~= 0 || strlength(strtrim(string(statusOutput))) > 0
    error('ValidationManifest:DirtyWorktree', ...
        'Commit-bound CI evidence requires a clean tracked worktree.');
end
end

function write_text(filePath, value)
fileIdentifier = fopen(filePath, 'w', 'n', 'UTF-8');
if fileIdentifier < 0
    error('ValidationManifest:Write', ...
        'Could not open validation manifest: %s', filePath);
end
cleanup = onCleanup(@() fclose(fileIdentifier));
fprintf(fileIdentifier, '%s\n', value);
clear cleanup;
end
