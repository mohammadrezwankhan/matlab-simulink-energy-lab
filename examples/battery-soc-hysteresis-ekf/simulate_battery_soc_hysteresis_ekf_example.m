function result = simulate_battery_soc_hysteresis_ekf_example()
%SIMULATE_BATTERY_SOC_HYSTERESIS_EKF_EXAMPLE Compare two- and three-state EKFs.

modelDirectory = fileparts(mfilename('fullpath'));
examplesDirectory = fileparts(modelDirectory);
hysteresisDirectory = fullfile(examplesDirectory, 'battery-ocv-hysteresis');
baselineDirectory = fullfile(examplesDirectory, 'battery-soc-ekf');
originalPath = path;
pathCleanup = onCleanup(@() path(originalPath));
addpath(hysteresisDirectory, baselineDirectory, modelDirectory);

parameters = battery_hysteresis_default_parameters();
profile = battery_hysteresis_default_profile();
truth = simulate_battery_ocv_hysteresis(profile, parameters, 1);
[hysteresisOptions, baselineOptions] = ...
    battery_soc_hysteresis_ekf_default_options();
time_s = truth.time_s;
measurementNoise_V = 0.004*sin(2*pi*time_s/37) + ...
    0.002*cos(2*pi*time_s/113);
measuredVoltage_V = truth.terminal_voltage_V + measurementNoise_V;

hysteresisEstimate = estimate_battery_soc_hysteresis_ekf( ...
    time_s, truth.current_A, measuredVoltage_V, parameters, ...
    hysteresisOptions);
baselineEstimate = estimate_battery_soc_ekf( ...
    time_s, truth.current_A, measuredVoltage_V, parameters, baselineOptions);

hysteresisSocError = hysteresisEstimate.soc - truth.soc;
baselineSocError = baselineEstimate.soc - truth.soc;
hysteresisStateError = ...
    hysteresisEstimate.hysteresis_state - truth.hysteresis_state;
metrics.hysteresis_soc_rmse = sqrt(mean(hysteresisSocError.^2));
metrics.baseline_soc_rmse = sqrt(mean(baselineSocError.^2));
metrics.hysteresis_final_soc_error = hysteresisSocError(end);
metrics.baseline_final_soc_error = baselineSocError(end);
metrics.hysteresis_state_rmse = sqrt(mean(hysteresisStateError.^2));
metrics.hysteresis_voltage_rmse_V = sqrt(mean( ...
    (hysteresisEstimate.terminal_voltage_V - truth.terminal_voltage_V).^2));
metrics.baseline_voltage_rmse_V = sqrt(mean( ...
    (baselineEstimate.terminal_voltage_V - truth.terminal_voltage_V).^2));
metrics.soc_rmse_improvement_percent = 100*(1 - ...
    metrics.hysteresis_soc_rmse/metrics.baseline_soc_rmse);
metrics.voltage_rmse_improvement_percent = 100*(1 - ...
    metrics.hysteresis_voltage_rmse_V/metrics.baseline_voltage_rmse_V);

result.truth = truth;
result.measurement_noise_V = measurementNoise_V;
result.measured_voltage_V = measuredVoltage_V;
result.hysteresis_estimate = hysteresisEstimate;
result.baseline_estimate = baselineEstimate;
result.metrics = metrics;
end
