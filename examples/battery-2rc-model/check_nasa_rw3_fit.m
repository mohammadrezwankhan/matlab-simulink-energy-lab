%% NASA RW3 measured pulse identification check
% The regression limits guard this example; they are not design tolerances.

run_example();

function run_example()
directory = fileparts(mfilename('fullpath'));
originalPath = path;
cleanup = onCleanup(@() path(originalPath));
addpath(directory);
scenario = build_nasa_rw3_fit_scenario();
fit = fit_battery_2rc_parameters( ...
    scenario.calibration_data, scenario.initial_parameters);
calibration = evaluate_battery_2rc_fit( ...
    scenario.calibration_data, fit.parameters);
validationParameters = fit.parameters;
validationParameters.initial_soc = scenario.validation_initial_soc;
validation = evaluate_battery_2rc_fit( ...
    scenario.validation_data, validationParameters);

assert(calibration.metrics.rmse_V < 0.010, ...
    'NASA calibration RMSE exceeded its regression limit.');
assert(validation.metrics.rmse_V < 0.025, ...
    'NASA held-out RMSE exceeded its regression limit.');
assert(max(abs(validation.simulation.ocv_V - ...
    scenario.validation_data.ocv_V)) < 1e-8, ...
    'Held-out OCV must use the documented independent lookup.');
fprintf('NASA RW3 measured-pulse example (not design validation).\n');
fprintf('Calibration RMSE: %.3f mV; held-out RMSE: %.3f mV.\n', ...
    1000*calibration.metrics.rmse_V, 1000*validation.metrics.rmse_V);
fprintf('Held-out maximum absolute error: %.3f mV.\n', ...
    1000*validation.metrics.maximum_absolute_error_V);
end
