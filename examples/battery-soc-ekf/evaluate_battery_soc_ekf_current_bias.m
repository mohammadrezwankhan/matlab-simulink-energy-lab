function sensitivity = evaluate_battery_soc_ekf_current_bias(bias_A)
%EVALUATE_BATTERY_SOC_EKF_CURRENT_BIAS Evaluate signed sensor-bias cases.

if nargin < 1
    bias_A = [-0.50; -0.25; 0; 0.25; 0.50];
end
validateattributes(bias_A, {'numeric'}, ...
    {'vector', 'real', 'finite', 'nonempty'});
bias_A = bias_A(:);
if any(diff(bias_A) <= 0) || ~any(bias_A == 0)
    error('BatterySOCEKF:BiasGrid', ...
        'Current-bias cases must be strictly increasing and include zero.');
end

caseCount = numel(bias_A);
caseResults = cell(caseCount, 1);
for caseIndex = 1:caseCount
    caseResults{caseIndex} = ...
        simulate_battery_soc_ekf_example(bias_A(caseIndex));
end

metrics = cellfun(@(result) result.metrics, caseResults);
sensitivity.current_bias_A = bias_A;
sensitivity.case_results = caseResults;
sensitivity.soc_rmse = reshape([metrics.soc_rmse], [], 1);
sensitivity.final_soc_error = ...
    reshape([metrics.final_soc_error], [], 1);
sensitivity.maximum_absolute_soc_error = ...
    reshape([metrics.maximum_absolute_soc_error], [], 1);
sensitivity.voltage_rmse_mV = 1000*reshape( ...
    [metrics.voltage_rmse_V], [], 1);
sensitivity.innovation_rms_mV = 1000*reshape( ...
    [metrics.innovation_rms_V], [], 1);
sensitivity.mean_normalized_innovation_squared = reshape( ...
    [metrics.mean_normalized_innovation_squared], [], 1);
sensitivity.minimum_covariance_eigenvalue = zeros(caseCount, 1);
for caseIndex = 1:caseCount
    covariance = caseResults{caseIndex}.estimate.covariance;
    minimumEigenvalue = inf;
    for sampleIndex = 1:size(covariance, 3)
        minimumEigenvalue = min(minimumEigenvalue, ...
            min(eig(covariance(:, :, sampleIndex))));
    end
    sensitivity.minimum_covariance_eigenvalue(caseIndex) = minimumEigenvalue;
end
end
