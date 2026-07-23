function estimate = estimate_battery_soc_ekf( ...
        time_s, current_A, measuredVoltage_V, parameters, options)
%ESTIMATE_BATTERY_SOC_EKF Estimate SOC and RC polarization from voltage.
% Positive current denotes discharge. The state is [SOC; Vrc].

[time_s, current_A, measuredVoltage_V, parameters, options] = ...
    validate_inputs(time_s, current_A, measuredVoltage_V, ...
    parameters, options);

sampleCount = numel(time_s);
state = zeros(2, sampleCount);
priorState = zeros(2, sampleCount);
covariance = zeros(2, 2, sampleCount);
priorCovariance = zeros(2, 2, sampleCount);
estimatedOcv_V = zeros(sampleCount, 1);
estimatedTerminalVoltage_V = zeros(sampleCount, 1);
innovation_V = zeros(sampleCount, 1);
innovationVariance_V2 = zeros(sampleCount, 1);
normalizedInnovationSquared = zeros(sampleCount, 1);
kalmanGain = zeros(2, sampleCount);

xPrior = options.initial_state;
pPrior = options.initial_covariance;
identityMatrix = eye(2);

for sampleIndex = 1:sampleCount
    priorState(:, sampleIndex) = xPrior;
    priorCovariance(:, :, sampleIndex) = pPrior;

    [priorOcv_V, ocvSlope_V] = ocv_with_slope( ...
        xPrior(1), parameters.ocv_soc_breakpoints, ...
        parameters.ocv_lookup_V);
    measurementJacobian = [ocvSlope_V, -1];
    priorTerminalVoltage_V = priorOcv_V - ...
        parameters.r0_Ohm * current_A(sampleIndex) - xPrior(2);
    innovation = measuredVoltage_V(sampleIndex) - ...
        priorTerminalVoltage_V;
    innovationVariance = measurementJacobian * pPrior * ...
        measurementJacobian' + options.measurement_variance_V2;
    gain = pPrior * measurementJacobian' / innovationVariance;

    xPosterior = xPrior + gain * innovation;
    xPosterior(1) = min(max(xPosterior(1), 0), 1);
    josephFactor = identityMatrix - gain * measurementJacobian;
    pPosterior = josephFactor * pPrior * josephFactor' + ...
        gain * options.measurement_variance_V2 * gain';
    pPosterior = (pPosterior + pPosterior') / 2;

    state(:, sampleIndex) = xPosterior;
    covariance(:, :, sampleIndex) = pPosterior;
    innovation_V(sampleIndex) = innovation;
    innovationVariance_V2(sampleIndex) = innovationVariance;
    normalizedInnovationSquared(sampleIndex) = ...
        innovation^2 / innovationVariance;
    kalmanGain(:, sampleIndex) = gain;
    [estimatedOcv_V(sampleIndex), ~] = ocv_with_slope( ...
        xPosterior(1), parameters.ocv_soc_breakpoints, ...
        parameters.ocv_lookup_V);
    estimatedTerminalVoltage_V(sampleIndex) = ...
        estimatedOcv_V(sampleIndex) - ...
        parameters.r0_Ohm * current_A(sampleIndex) - xPosterior(2);

    if sampleIndex < sampleCount
        interval_s = time_s(sampleIndex + 1) - time_s(sampleIndex);
        decayFactor = exp(-interval_s / ...
            (parameters.r1_Ohm * parameters.c1_F));
        stateTransition = [1, 0; 0, decayFactor];
        xPrior = [
            xPosterior(1) - current_A(sampleIndex) * interval_s / ...
                (3600 * parameters.capacity_Ah);
            decayFactor * xPosterior(2) + ...
                parameters.r1_Ohm * (1 - decayFactor) * ...
                current_A(sampleIndex)
        ];
        xPrior(1) = min(max(xPrior(1), 0), 1);
        processCovariance = ...
            options.process_noise_covariance_per_s * interval_s;
        pPrior = stateTransition * pPosterior * stateTransition' + ...
            processCovariance;
        pPrior = (pPrior + pPrior') / 2;
    end
end

estimate.time_s = time_s;
estimate.current_A = current_A;
estimate.measured_voltage_V = measuredVoltage_V;
estimate.soc = state(1, :)';
estimate.v_rc_V = state(2, :)';
estimate.prior_soc = priorState(1, :)';
estimate.prior_v_rc_V = priorState(2, :)';
estimate.ocv_V = estimatedOcv_V;
estimate.terminal_voltage_V = estimatedTerminalVoltage_V;
estimate.innovation_V = innovation_V;
estimate.innovation_variance_V2 = innovationVariance_V2;
estimate.normalized_innovation_squared = normalizedInnovationSquared;
estimate.kalman_gain = kalmanGain;
estimate.covariance = covariance;
estimate.prior_covariance = priorCovariance;
estimate.parameters = parameters;
estimate.options = options;
end

function [time_s, current_A, measuredVoltage_V, parameters, options] = ...
        validate_inputs(time_s, current_A, measuredVoltage_V, ...
        parameters, options)
vectors = {time_s, current_A, measuredVoltage_V};
for vectorIndex = 1:numel(vectors)
    value = vectors{vectorIndex};
    if ~isnumeric(value) || ~isvector(value) || ~isreal(value) || ...
            any(~isfinite(value))
        error('BatterySOCEKF:Signals', ...
            'Time, current, and voltage must be finite real numeric vectors.');
    end
end
time_s = time_s(:);
current_A = current_A(:);
measuredVoltage_V = measuredVoltage_V(:);
if numel(time_s) < 2 || numel(current_A) ~= numel(time_s) || ...
        numel(measuredVoltage_V) ~= numel(time_s)
    error('BatterySOCEKF:SignalShape', ...
        'Time, current, and voltage must have equal length of at least two.');
end
if any(diff(time_s) <= 0)
    error('BatterySOCEKF:TimeOrder', ...
        'Time samples must increase strictly.');
end

requiredScalarParameters = {
    'capacity_Ah';
    'r0_Ohm';
    'r1_Ohm';
    'c1_F'
};
requiredParameters = [requiredScalarParameters; {
    'ocv_soc_breakpoints';
    'ocv_lookup_V'
}];
if ~isstruct(parameters) || ...
        ~all(isfield(parameters, requiredParameters))
    error('BatterySOCEKF:Parameters', ...
        'The parameter structure is missing a required field.');
end
for parameterIndex = 1:numel(requiredScalarParameters)
    value = parameters.(requiredScalarParameters{parameterIndex});
    if ~isnumeric(value) || ~isscalar(value) || ~isreal(value) || ...
            ~isfinite(value)
        error('BatterySOCEKF:Parameters', ...
            'Every scalar model parameter must be finite and real.');
    end
end
if parameters.capacity_Ah <= 0 || parameters.r0_Ohm < 0 || ...
        parameters.r1_Ohm <= 0 || parameters.c1_F <= 0
    error('BatterySOCEKF:Parameters', ...
        'Capacity, R1, and C1 must be positive; R0 must be nonnegative.');
end

breakpoints = parameters.ocv_soc_breakpoints(:);
lookup = parameters.ocv_lookup_V(:);
if ~isnumeric(parameters.ocv_soc_breakpoints) || ...
        ~isvector(parameters.ocv_soc_breakpoints) || ...
        ~isreal(parameters.ocv_soc_breakpoints) || ...
        ~isnumeric(parameters.ocv_lookup_V) || ...
        ~isvector(parameters.ocv_lookup_V) || ...
        ~isreal(parameters.ocv_lookup_V) || ...
        numel(breakpoints) < 2 || numel(breakpoints) ~= numel(lookup) || ...
        any(~isfinite(breakpoints)) || any(~isfinite(lookup)) || ...
        abs(breakpoints(1)) > 1e-12 || ...
        abs(breakpoints(end) - 1) > 1e-12 || ...
        any(diff(breakpoints) <= 0) || any(lookup <= 0) || ...
        any(diff(lookup) < 0)
    error('BatterySOCEKF:OCVCurve', ...
        ['OCV data must be finite, positive, nondecreasing, and use ', ...
        'strictly increasing SOC breakpoints from zero to one.']);
end
parameters.ocv_soc_breakpoints = breakpoints;
parameters.ocv_lookup_V = lookup;

requiredOptions = {
    'initial_state';
    'initial_covariance';
    'process_noise_covariance_per_s';
    'measurement_variance_V2'
};
if ~isstruct(options) || ~all(isfield(options, requiredOptions))
    error('BatterySOCEKF:Options', ...
        'The filter options structure is missing a required field.');
end
if ~isnumeric(options.initial_state) || ...
        ~isequal(size(options.initial_state), [2, 1]) || ...
        ~isreal(options.initial_state) || ...
        any(~isfinite(options.initial_state)) || ...
        options.initial_state(1) < 0 || options.initial_state(1) > 1
    error('BatterySOCEKF:InitialState', ...
        'initial_state must be a finite [SOC; Vrc] column with bounded SOC.');
end
options.initial_covariance = validated_covariance( ...
    options.initial_covariance, 'initial_covariance');
options.process_noise_covariance_per_s = validated_covariance( ...
    options.process_noise_covariance_per_s, ...
    'process_noise_covariance_per_s');
if ~isnumeric(options.measurement_variance_V2) || ...
        ~isscalar(options.measurement_variance_V2) || ...
        ~isreal(options.measurement_variance_V2) || ...
        ~isfinite(options.measurement_variance_V2) || ...
        options.measurement_variance_V2 <= 0
    error('BatterySOCEKF:MeasurementVariance', ...
        'measurement_variance_V2 must be a finite positive scalar.');
end
end

function covariance = validated_covariance(covariance, fieldName)
if ~isnumeric(covariance) || ~isequal(size(covariance), [2, 2]) || ...
        ~isreal(covariance) || any(~isfinite(covariance), 'all') || ...
        max(abs(covariance - covariance'), [], 'all') > 1e-12 || ...
        min(eig(covariance)) < -1e-12
    error('BatterySOCEKF:Covariance', ...
        '%s must be a finite symmetric positive-semidefinite 2-by-2 matrix.', ...
        fieldName);
end
end

function [ocv_V, slope_V] = ocv_with_slope(soc, breakpoints, lookup)
boundedSoc = min(max(soc, 0), 1);
segmentIndex = find(boundedSoc <= breakpoints(2:end), 1, 'first');
if isempty(segmentIndex)
    segmentIndex = numel(breakpoints) - 1;
end
slope_V = (lookup(segmentIndex + 1) - lookup(segmentIndex)) / ...
    (breakpoints(segmentIndex + 1) - breakpoints(segmentIndex));
ocv_V = lookup(segmentIndex) + ...
    slope_V * (boundedSoc - breakpoints(segmentIndex));
end
