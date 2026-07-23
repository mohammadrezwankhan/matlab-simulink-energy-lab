function [profile, modelParameters, filterOptions] = ...
        battery_soc_ekf_default_scenario()
%BATTERY_SOC_EKF_DEFAULT_SCENARIO Return a deterministic EKF benchmark.

time_s = (0:3600)';
current_A = zeros(size(time_s));
current_A(time_s >= 300 & time_s < 900) = 4;
current_A(time_s >= 1200 & time_s < 1800) = -2;
current_A(time_s >= 2100 & time_s < 3000) = 6;
current_A(time_s >= 3300) = -3;
profile = table(time_s, current_A);

modelParameters.capacity_Ah = 5;
modelParameters.initial_soc = 0.82;
modelParameters.ocv_soc_breakpoints = ...
    [0; 0.05; 0.10; 0.20; 0.40; 0.60; 0.80; 0.90; 0.95; 1.00];
modelParameters.ocv_lookup_V = ...
    [3.00; 3.28; 3.45; 3.58; 3.66; 3.72; 3.82; 3.94; 4.06; 4.18];
modelParameters.r0_Ohm = 0.015;
modelParameters.r1_Ohm = 0.008;
modelParameters.c1_F = 2500;

filterOptions.initial_state = [0.62; 0.04];
filterOptions.initial_covariance = diag([0.02^2, 0.02^2]);
filterOptions.process_noise_covariance_per_s = diag([1e-8, 5e-7]);
filterOptions.measurement_variance_V2 = 0.006^2;
end
