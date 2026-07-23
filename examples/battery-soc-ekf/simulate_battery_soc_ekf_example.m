function result = simulate_battery_soc_ekf_example()
%SIMULATE_BATTERY_SOC_EKF_EXAMPLE Run the deterministic SOC benchmark.

[profile, parameters, options] = battery_soc_ekf_default_scenario();

modelDirectory = fileparts(mfilename('fullpath'));
baseModelDirectory = fullfile(fileparts(modelDirectory), 'battery-rc-model');
baseSimulator = fullfile(baseModelDirectory, 'simulate_battery_rc_model.m');
if ~isfile(baseSimulator)
    error('BatterySOCEKF:Dependency', ...
        'The battery-rc-model simulator is required beside this example.');
end
originalPath = path;
pathCleanup = onCleanup(@() path(originalPath));
addpath(baseModelDirectory);

truth = simulate_battery_rc_model(profile, parameters);
time_s = truth.time_s;
measurementNoise_V = 0.004 * sin(2 * pi * time_s / 37) + ...
    0.002 * cos(2 * pi * time_s / 113);
measuredVoltage_V = truth.terminal_voltage_V + measurementNoise_V;
estimate = estimate_battery_soc_ekf( ...
    time_s, truth.current_A, measuredVoltage_V, parameters, options);

socError = estimate.soc - truth.soc;
settlingThreshold = 0.02;
settlingIndex = find_suffix_settling_index( ...
    abs(socError), settlingThreshold);

metrics.initial_prior_soc_error = ...
    options.initial_state(1) - truth.soc(1);
metrics.initial_posterior_soc_error = socError(1);
metrics.final_soc_error = socError(end);
metrics.soc_rmse = sqrt(mean(socError.^2));
metrics.maximum_absolute_soc_error = max(abs(socError));
metrics.voltage_rmse_V = sqrt(mean( ...
    (estimate.terminal_voltage_V - truth.terminal_voltage_V).^2));
metrics.innovation_rms_V = sqrt(mean(estimate.innovation_V.^2));
metrics.mean_normalized_innovation_squared = ...
    mean(estimate.normalized_innovation_squared);
metrics.settling_threshold = settlingThreshold;
if isempty(settlingIndex)
    metrics.soc_settling_time_s = NaN;
else
    metrics.soc_settling_time_s = time_s(settlingIndex);
end

result.truth = truth;
result.measurement_noise_V = measurementNoise_V;
result.measured_voltage_V = measuredVoltage_V;
result.estimate = estimate;
result.metrics = metrics;
end

function settlingIndex = find_suffix_settling_index(absoluteError, threshold)
outsideThreshold = find(absoluteError > threshold, 1, 'last');
if isempty(outsideThreshold)
    settlingIndex = 1;
elseif outsideThreshold < numel(absoluteError)
    settlingIndex = outsideThreshold + 1;
else
    settlingIndex = [];
end
end
