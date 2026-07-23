function summary = build_controller_comparison_table(comparison)
%BUILD_CONTROLLER_COMPARISON_TABLE Collect controller metrics in one table.
% The rows are always Open loop, PI, and Filtered PID. Variable names and
% table metadata state the engineering units used by each metric.

requiredControllerFields = {'open_loop'; 'pi'; 'filtered_pid'};
if ~isstruct(comparison) || ~isscalar(comparison) || ...
        ~all(isfield(comparison, requiredControllerFields))
    error('ControllerComparisonTable:Comparison', ...
        ['Comparison must be a scalar structure containing open_loop, ' ...
        'pi, and filtered_pid results.']);
end

controllerCount = numel(requiredControllerFields);
controller_name = strings(controllerCount, 1);
steady_state_error_V = zeros(controllerCount, 1);
overshoot_percent = zeros(controllerCount, 1);
undershoot_percent = zeros(controllerCount, 1);
settling_time_s = zeros(controllerCount, 1);
minimum_duty_cycle = zeros(controllerCount, 1);
maximum_duty_cycle = zeros(controllerCount, 1);
minimum_current_reference_A = zeros(controllerCount, 1);
maximum_current_reference_A = zeros(controllerCount, 1);
duty_limits_respected = false(controllerCount, 1);
current_limits_respected = false(controllerCount, 1);

for controllerIndex = 1:controllerCount
    result = comparison.(requiredControllerFields{controllerIndex});
    if ~isstruct(result) || ~isscalar(result) || ...
            ~isfield(result, 'display_name') || ~isfield(result, 'metrics')
        error('ControllerComparisonTable:ControllerResult', ...
            'Every controller result must contain display_name and metrics.');
    end

    metrics = result.metrics;
    controller_name(controllerIndex) = string(result.display_name);
    steady_state_error_V(controllerIndex) = validated_numeric_metric(...
        metrics, 'steady_state_error_V', false);
    overshoot_percent(controllerIndex) = validated_numeric_metric(...
        metrics, 'overshoot_percent', false);
    undershoot_percent(controllerIndex) = validated_numeric_metric(...
        metrics, 'undershoot_percent', false);
    settling_time_s(controllerIndex) = validated_numeric_metric(...
        metrics, 'settling_time_s', true);
    minimum_duty_cycle(controllerIndex) = validated_numeric_metric(...
        metrics, 'minimum_duty_cycle', false);
    maximum_duty_cycle(controllerIndex) = validated_numeric_metric(...
        metrics, 'maximum_duty_cycle', false);
    minimum_current_reference_A(controllerIndex) = ...
        validated_numeric_metric(metrics, ...
        'minimum_current_reference_A', false);
    maximum_current_reference_A(controllerIndex) = ...
        validated_numeric_metric(metrics, ...
        'maximum_current_reference_A', false);
    duty_limits_respected(controllerIndex) = validated_logical_metric(...
        metrics, 'duty_limits_respected');
    current_limits_respected(controllerIndex) = validated_logical_metric(...
        metrics, 'current_limits_respected');
end

summary = table(...
    controller_name, steady_state_error_V, overshoot_percent, ...
    undershoot_percent, settling_time_s, minimum_duty_cycle, ...
    maximum_duty_cycle, minimum_current_reference_A, ...
    maximum_current_reference_A, duty_limits_respected, ...
    current_limits_respected);
summary.Properties.VariableUnits = {
    '';
    'V';
    '%';
    '%';
    's';
    '';
    '';
    'A';
    'A';
    '';
    ''
};
summary.Properties.VariableDescriptions = {
    'Controller strategy in deterministic comparison order.';
    'Reference voltage minus the final-window average output voltage.';
    'Maximum positive post-step voltage deviation relative to reference.';
    'Maximum negative post-step voltage deviation relative to reference.';
    'Elapsed time after the load step before entering the two-percent band.';
    'Minimum commanded duty cycle over the simulation.';
    'Maximum commanded duty cycle over the simulation.';
    'Minimum bounded current reference over the simulation.';
    'Maximum bounded current reference over the simulation.';
    'True when every duty-cycle sample remains within its configured limits.';
    'True when every current-reference sample remains within its configured limits.'
};
end

function value = validated_numeric_metric(metrics, fieldName, allowInfinite)
if ~isstruct(metrics) || ~isscalar(metrics) || ~isfield(metrics, fieldName)
    error('ControllerComparisonTable:MetricField', ...
        'Controller metrics must contain scalar field %s.', fieldName);
end

value = metrics.(fieldName);
isValid = isnumeric(value) && isscalar(value) && isreal(value) && ...
    ~isnan(value);
if ~allowInfinite
    isValid = isValid && isfinite(value);
end
if ~isValid
    error('ControllerComparisonTable:NumericMetric', ...
        '%s must be a real numeric scalar.', fieldName);
end
value = double(value);
end

function value = validated_logical_metric(metrics, fieldName)
if ~isstruct(metrics) || ~isscalar(metrics) || ~isfield(metrics, fieldName)
    error('ControllerComparisonTable:MetricField', ...
        'Controller metrics must contain scalar field %s.', fieldName);
end

value = metrics.(fieldName);
if ~islogical(value) || ~isscalar(value)
    error('ControllerComparisonTable:LogicalMetric', ...
        '%s must be a logical scalar.', fieldName);
end
end
