%CHECK_BESS_UNIFIED_CONTROL Run the complete focused BESS verification suite.

exampleDirectory = fileparts(mfilename('fullpath'));
testDirectory = fullfile(exampleDirectory, 'tests');
results = runtests(testDirectory, 'IncludeSubfolders', false);
assert(all([results.Passed]), ...
    'BessUnifiedControl:VerificationFailure', ...
    'One or more focused BESS verification tests failed.');
fprintf('All %d focused BESS controller tests passed.\n', numel(results));
