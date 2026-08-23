function [hysteresisOptions, baselineOptions] = ...
        battery_soc_hysteresis_ekf_default_options()
%BATTERY_SOC_HYSTERESIS_EKF_DEFAULT_OPTIONS Return benchmark EKF tuning.

hysteresisOptions.initial_state = [0.48; 0.01; 0];
hysteresisOptions.initial_covariance = diag([0.08^2, 0.02^2, 0.50^2]);
hysteresisOptions.process_noise_covariance_per_s = ...
    diag([1e-8, 2e-7, 2e-6]);
hysteresisOptions.measurement_variance_V2 = 0.006^2;

baselineOptions.initial_state = hysteresisOptions.initial_state(1:2);
baselineOptions.initial_covariance = ...
    hysteresisOptions.initial_covariance(1:2, 1:2);
baselineOptions.process_noise_covariance_per_s = ...
    hysteresisOptions.process_noise_covariance_per_s(1:2, 1:2);
baselineOptions.measurement_variance_V2 = ...
    hysteresisOptions.measurement_variance_V2;
end
