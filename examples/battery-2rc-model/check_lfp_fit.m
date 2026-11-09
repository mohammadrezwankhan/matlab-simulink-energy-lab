%% Measured LFP pulse fit and independent dynamic-record check
run_example();

function run_example()
directory = fileparts(mfilename('fullpath'));
originalPath = path;
cleanup = onCleanup(@() path(originalPath));
addpath(directory);
scenario = build_lfp_fit_scenario();
fit = fit_battery_2rc_parameters(scenario.calibration_data, ...
    scenario.initial_parameters);
p = fit.parameters;
p.initial_soc = 1;
validation = evaluate_battery_2rc_fit(scenario.validation_data, p);
assert(fit.metrics.rmse_V < 0.020, 'LFP fit regression limit exceeded.');
assert(validation.metrics.rmse_V < 0.020, ...
    'LFP held-out regression limit exceeded.');
fprintf('LFP measured data (not design validation).\n');
fprintf('Calibration RMSE: %.3f mV; held-out RMSE: %.3f mV.\n', ...
    1000*fit.metrics.rmse_V, 1000*validation.metrics.rmse_V);
fprintf('Held-out maximum absolute error: %.3f mV.\n', ...
    1000*validation.metrics.maximum_absolute_error_V);
end
