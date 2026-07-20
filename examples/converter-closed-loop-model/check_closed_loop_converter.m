%% Closed-Loop Averaged Converter Check
% Runs no-plot assertions for the cascaded voltage and current controller.

clear; clc;

addpath(fileparts(mfilename('fullpath')));
result = simulate_closed_loop_converter();

assert(all(isfinite(result.output_voltage_V)), ...
    'Output voltage must remain finite.');
assert(all(isfinite(result.inductor_current_A)), ...
    'Inductor current must remain finite.');
assert(all(result.duty_cycle >= result.minimum_duty_cycle - eps), ...
    'Duty cycle fell below its configured lower limit.');
assert(all(result.duty_cycle <= result.maximum_duty_cycle + eps), ...
    'Duty cycle exceeded its configured upper limit.');
assert(all(result.inductor_current_A >= 0), ...
    'Inductor current became negative in the unidirectional example.');

step_mask = result.time_s >= result.reference_step_time_s;
final_window_mask = result.time_s >= result.time_s(end) - 0.01;
post_step_voltage_V = result.output_voltage_V(step_mask);
final_average_voltage_V = mean(result.output_voltage_V(final_window_mask));
peak_voltage_V = max(post_step_voltage_V);

settling_band_V = 0.02 * result.final_reference_V;
outside_band = abs(post_step_voltage_V - result.final_reference_V) > ...
    settling_band_V;
last_outside_index = find(outside_band, 1, 'last');
post_step_time_s = result.time_s(step_mask);
if isempty(last_outside_index)
    settling_time_s = 0;
elseif last_outside_index < numel(post_step_time_s)
    settling_time_s = post_step_time_s(last_outside_index + 1) - ...
        result.reference_step_time_s;
else
    settling_time_s = inf;
end

assert(abs(final_average_voltage_V - result.final_reference_V) <= 1, ...
    'Final average voltage must be within 1 V of the reference.');
assert(peak_voltage_V <= 1.08 * result.final_reference_V, ...
    'Post-step voltage overshoot exceeded 8 percent.');
assert(settling_time_s <= 0.05, ...
    'Voltage did not settle inside the 2 percent band within 50 ms.');

fprintf('Closed-loop converter check passed.\n');
fprintf('Final average voltage: %.2f V\n', final_average_voltage_V);
fprintf('Peak voltage after step: %.2f V\n', peak_voltage_V);
fprintf('Two-percent settling time: %.1f ms\n', 1000 * settling_time_s);
fprintf('Duty-cycle range: %.3f to %.3f\n', ...
    min(result.duty_cycle), max(result.duty_cycle));
