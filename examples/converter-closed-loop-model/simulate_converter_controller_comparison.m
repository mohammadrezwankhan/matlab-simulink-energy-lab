function comparison = simulate_converter_controller_comparison()
%SIMULATE_CONVERTER_CONTROLLER_COMPARISON Compare load-step controllers.

parameters.input_voltage_V = 800;
parameters.inductance_H = 0.002;
parameters.inductor_resistance_Ohm = 0.1;
parameters.capacitance_F = 0.001;
parameters.initial_load_resistance_Ohm = 20;
parameters.final_load_resistance_Ohm = 10;
parameters.reference_voltage_V = 400;
parameters.load_step_time_s = 0.04;
parameters.end_time_s = 0.14;
parameters.time_step_s = 1e-5;
parameters.minimum_current_reference_A = 0;
parameters.maximum_current_reference_A = 60;
parameters.minimum_duty_cycle = 0.05;
parameters.maximum_duty_cycle = 0.95;
parameters.current_proportional_gain_Ohm = 3;

time_s = (0:parameters.time_step_s:parameters.end_time_s)';
load_resistance_Ohm = parameters.initial_load_resistance_Ohm * ...
    ones(size(time_s));
load_resistance_Ohm(time_s >= parameters.load_step_time_s) = ...
    parameters.final_load_resistance_Ohm;
reference_voltage_V = parameters.reference_voltage_V * ones(size(time_s));

open_loop.kind = 'open_loop';
open_loop.display_name = 'Open loop';
open_loop.voltage_proportional_gain_A_per_V = 0;
open_loop.voltage_integral_gain_A_per_Vs = 0;
open_loop.voltage_derivative_gain_As_per_V = 0;
open_loop.derivative_filter_time_constant_s = 0;

pi_controller.kind = 'feedback';
pi_controller.display_name = 'PI';
pi_controller.voltage_proportional_gain_A_per_V = 0.25;
pi_controller.voltage_integral_gain_A_per_Vs = 80;
pi_controller.voltage_derivative_gain_As_per_V = 0;
pi_controller.derivative_filter_time_constant_s = 0;

filtered_pid.kind = 'feedback';
filtered_pid.display_name = 'Filtered PID';
filtered_pid.voltage_proportional_gain_A_per_V = 0.25;
filtered_pid.voltage_integral_gain_A_per_Vs = 80;
filtered_pid.voltage_derivative_gain_As_per_V = 0.001;
filtered_pid.derivative_filter_time_constant_s = 5e-4;

comparison.time_s = time_s;
comparison.reference_voltage_V = reference_voltage_V;
comparison.load_resistance_Ohm = load_resistance_Ohm;
comparison.parameters = parameters;
comparison.open_loop = simulate_case(time_s, load_resistance_Ohm, ...
    parameters, open_loop);
comparison.pi = simulate_case(time_s, load_resistance_Ohm, parameters, ...
    pi_controller);
comparison.filtered_pid = simulate_case(time_s, load_resistance_Ohm, ...
    parameters, filtered_pid);
end

function result = simulate_case(time_s, load_resistance_Ohm, parameters, ...
    controller)
sample_count = numel(time_s);
output_voltage_V = zeros(sample_count, 1);
inductor_current_A = zeros(sample_count, 1);
current_reference_A = zeros(sample_count, 1);
duty_cycle = zeros(sample_count, 1);

output_voltage_V(1) = parameters.reference_voltage_V;
inductor_current_A(1) = parameters.reference_voltage_V / ...
    parameters.initial_load_resistance_Ohm;
nominal_current_A = inductor_current_A(1);
initial_duty_cycle = (parameters.reference_voltage_V + ...
    parameters.inductor_resistance_Ohm * nominal_current_A) / ...
    parameters.input_voltage_V;
voltage_integral_action_A = 0;
filtered_error_derivative_V_per_s = 0;
previous_voltage_error_V = 0;

for sample = 1:(sample_count - 1)
    voltage_error_V = parameters.reference_voltage_V - ...
        output_voltage_V(sample);

    if strcmp(controller.kind, 'open_loop')
        current_reference_A(sample) = nominal_current_A;
        duty_cycle(sample) = clamp(initial_duty_cycle, ...
            parameters.minimum_duty_cycle, parameters.maximum_duty_cycle);
    else
        raw_error_derivative_V_per_s = (voltage_error_V - ...
            previous_voltage_error_V) / parameters.time_step_s;
        if controller.derivative_filter_time_constant_s > 0
            filter_weight = controller.derivative_filter_time_constant_s / ...
                (controller.derivative_filter_time_constant_s + ...
                parameters.time_step_s);
            filtered_error_derivative_V_per_s = filter_weight * ...
                filtered_error_derivative_V_per_s + (1 - filter_weight) * ...
                raw_error_derivative_V_per_s;
        else
            filtered_error_derivative_V_per_s = 0;
        end

        unconstrained_current_reference_A = nominal_current_A + ...
            controller.voltage_proportional_gain_A_per_V * ...
            voltage_error_V + voltage_integral_action_A + ...
            controller.voltage_derivative_gain_As_per_V * ...
            filtered_error_derivative_V_per_s;
        current_reference_A(sample) = clamp(...
            unconstrained_current_reference_A, ...
            parameters.minimum_current_reference_A, ...
            parameters.maximum_current_reference_A);

        upper_limit_recovery = unconstrained_current_reference_A >= ...
            parameters.maximum_current_reference_A && voltage_error_V < 0;
        lower_limit_recovery = unconstrained_current_reference_A <= ...
            parameters.minimum_current_reference_A && voltage_error_V > 0;
        current_reference_is_free = unconstrained_current_reference_A > ...
            parameters.minimum_current_reference_A && ...
            unconstrained_current_reference_A < ...
            parameters.maximum_current_reference_A;
        if current_reference_is_free || upper_limit_recovery || ...
                lower_limit_recovery
            voltage_integral_action_A = voltage_integral_action_A + ...
                controller.voltage_integral_gain_A_per_Vs * ...
                voltage_error_V * parameters.time_step_s;
        end

        current_error_A = current_reference_A(sample) - ...
            inductor_current_A(sample);
        unconstrained_duty_cycle = (output_voltage_V(sample) + ...
            parameters.inductor_resistance_Ohm * ...
            inductor_current_A(sample) + ...
            parameters.current_proportional_gain_Ohm * current_error_A) / ...
            parameters.input_voltage_V;
        duty_cycle(sample) = clamp(unconstrained_duty_cycle, ...
            parameters.minimum_duty_cycle, parameters.maximum_duty_cycle);
    end

    current_derivative_A_per_s = (duty_cycle(sample) * ...
        parameters.input_voltage_V - output_voltage_V(sample) - ...
        parameters.inductor_resistance_Ohm * inductor_current_A(sample)) / ...
        parameters.inductance_H;
    voltage_derivative_V_per_s = (inductor_current_A(sample) - ...
        output_voltage_V(sample) / load_resistance_Ohm(sample)) / ...
        parameters.capacitance_F;

    inductor_current_A(sample + 1) = inductor_current_A(sample) + ...
        parameters.time_step_s * current_derivative_A_per_s;
    output_voltage_V(sample + 1) = output_voltage_V(sample) + ...
        parameters.time_step_s * voltage_derivative_V_per_s;
    previous_voltage_error_V = voltage_error_V;
end

current_reference_A(end) = current_reference_A(end - 1);
duty_cycle(end) = duty_cycle(end - 1);

result.display_name = controller.display_name;
result.output_voltage_V = output_voltage_V;
result.inductor_current_A = inductor_current_A;
result.current_reference_A = current_reference_A;
result.duty_cycle = duty_cycle;
result.controller = controller;
result.metrics = calculate_metrics(time_s, output_voltage_V, duty_cycle, ...
    current_reference_A, parameters);
end

function metrics = calculate_metrics(time_s, output_voltage_V, duty_cycle, ...
    current_reference_A, parameters)
step_mask = time_s >= parameters.load_step_time_s;
post_step_time_s = time_s(step_mask);
post_step_voltage_V = output_voltage_V(step_mask);
reference_voltage_V = parameters.reference_voltage_V;

metrics.overshoot_percent = 100 * max(0, ...
    max(post_step_voltage_V) - reference_voltage_V) / reference_voltage_V;
metrics.undershoot_percent = 100 * max(0, ...
    reference_voltage_V - min(post_step_voltage_V)) / reference_voltage_V;

final_window_mask = time_s >= parameters.end_time_s - 0.01;
metrics.final_average_voltage_V = mean(...
    output_voltage_V(final_window_mask));
metrics.steady_state_error_V = reference_voltage_V - ...
    metrics.final_average_voltage_V;

settling_band_V = 0.02 * reference_voltage_V;
outside_band = abs(post_step_voltage_V - reference_voltage_V) > ...
    settling_band_V;
last_outside_index = find(outside_band, 1, 'last');
if isempty(last_outside_index)
    metrics.settling_time_s = 0;
elseif last_outside_index < numel(post_step_time_s)
    metrics.settling_time_s = post_step_time_s(last_outside_index + 1) - ...
        parameters.load_step_time_s;
else
    metrics.settling_time_s = inf;
end

metrics.minimum_duty_cycle = min(duty_cycle);
metrics.maximum_duty_cycle = max(duty_cycle);
metrics.minimum_current_reference_A = min(current_reference_A);
metrics.maximum_current_reference_A = max(current_reference_A);
metrics.duty_limits_respected = all(duty_cycle >= ...
    parameters.minimum_duty_cycle - eps) && all(duty_cycle <= ...
    parameters.maximum_duty_cycle + eps);
metrics.current_limits_respected = all(current_reference_A >= ...
    parameters.minimum_current_reference_A - eps) && ...
    all(current_reference_A <= ...
    parameters.maximum_current_reference_A + eps);
end

function value = clamp(value, lower_limit, upper_limit)
value = min(max(value, lower_limit), upper_limit);
end
