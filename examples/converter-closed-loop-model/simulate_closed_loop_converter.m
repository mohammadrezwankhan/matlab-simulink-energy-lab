function result = simulate_closed_loop_converter()
%SIMULATE_CLOSED_LOOP_CONVERTER Simulate a cascaded averaged buck controller.

input_voltage_V = 800;
inductance_H = 0.002;
inductor_resistance_Ohm = 0.1;
capacitance_F = 0.001;
load_resistance_Ohm = 20;

initial_reference_V = 300;
final_reference_V = 400;
reference_step_time_s = 0.04;
end_time_s = 0.12;
time_step_s = 1e-5;

voltage_proportional_gain_A_per_V = 0.1;
voltage_integral_gain_A_per_Vs = 10;
current_proportional_gain_Ohm = 3;
minimum_current_reference_A = 0;
maximum_current_reference_A = 40;
minimum_duty_cycle = 0.05;
maximum_duty_cycle = 0.95;

time_s = (0:time_step_s:end_time_s)';
sample_count = numel(time_s);
reference_voltage_V = initial_reference_V * ones(sample_count, 1);
reference_voltage_V(time_s >= reference_step_time_s) = final_reference_V;

output_voltage_V = zeros(sample_count, 1);
inductor_current_A = zeros(sample_count, 1);
current_reference_A = zeros(sample_count, 1);
duty_cycle = zeros(sample_count, 1);

output_voltage_V(1) = initial_reference_V;
inductor_current_A(1) = initial_reference_V / load_resistance_Ohm;
voltage_integral_action_A = 0;

for sample = 1:(sample_count - 1)
    voltage_error_V = reference_voltage_V(sample) - ...
        output_voltage_V(sample);
    unconstrained_current_reference_A = ...
        reference_voltage_V(sample) / load_resistance_Ohm + ...
        voltage_proportional_gain_A_per_V * voltage_error_V + ...
        voltage_integral_action_A;
    current_reference_A(sample) = min(max(...
        unconstrained_current_reference_A, minimum_current_reference_A), ...
        maximum_current_reference_A);

    upper_limit_recovery = unconstrained_current_reference_A >= ...
        maximum_current_reference_A && voltage_error_V < 0;
    lower_limit_recovery = unconstrained_current_reference_A <= ...
        minimum_current_reference_A && voltage_error_V > 0;
    current_reference_is_free = unconstrained_current_reference_A > ...
        minimum_current_reference_A && unconstrained_current_reference_A < ...
        maximum_current_reference_A;
    if current_reference_is_free || upper_limit_recovery || lower_limit_recovery
        voltage_integral_action_A = voltage_integral_action_A + ...
            voltage_integral_gain_A_per_Vs * voltage_error_V * time_step_s;
    end

    current_error_A = current_reference_A(sample) - ...
        inductor_current_A(sample);
    unconstrained_duty_cycle = (output_voltage_V(sample) + ...
        inductor_resistance_Ohm * inductor_current_A(sample) + ...
        current_proportional_gain_Ohm * current_error_A) / input_voltage_V;
    duty_cycle(sample) = min(max(unconstrained_duty_cycle, ...
        minimum_duty_cycle), maximum_duty_cycle);

    current_derivative_A_per_s = (duty_cycle(sample) * input_voltage_V - ...
        output_voltage_V(sample) - ...
        inductor_resistance_Ohm * inductor_current_A(sample)) / inductance_H;
    voltage_derivative_V_per_s = (inductor_current_A(sample) - ...
        output_voltage_V(sample) / load_resistance_Ohm) / capacitance_F;

    inductor_current_A(sample + 1) = inductor_current_A(sample) + ...
        time_step_s * current_derivative_A_per_s;
    output_voltage_V(sample + 1) = output_voltage_V(sample) + ...
        time_step_s * voltage_derivative_V_per_s;
end

final_voltage_error_V = reference_voltage_V(end) - output_voltage_V(end);
current_reference_A(end) = min(max(reference_voltage_V(end) / ...
    load_resistance_Ohm + voltage_proportional_gain_A_per_V * ...
    final_voltage_error_V + voltage_integral_action_A, ...
    minimum_current_reference_A), maximum_current_reference_A);
final_current_error_A = current_reference_A(end) - inductor_current_A(end);
duty_cycle(end) = min(max((output_voltage_V(end) + ...
    inductor_resistance_Ohm * inductor_current_A(end) + ...
    current_proportional_gain_Ohm * final_current_error_A) / input_voltage_V, ...
    minimum_duty_cycle), maximum_duty_cycle);

result.time_s = time_s;
result.reference_voltage_V = reference_voltage_V;
result.output_voltage_V = output_voltage_V;
result.inductor_current_A = inductor_current_A;
result.current_reference_A = current_reference_A;
result.duty_cycle = duty_cycle;
result.reference_step_time_s = reference_step_time_s;
result.final_reference_V = final_reference_V;
result.minimum_duty_cycle = minimum_duty_cycle;
result.maximum_duty_cycle = maximum_duty_cycle;
result.time_step_s = time_step_s;
end
