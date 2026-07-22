%% Converter Average Model Parameter Check
% Runs no-plot assertions for the converter average model scaffold.

clearvars; clc;

input_voltage_V = 800;
duty_cycle = 0.45;
switching_frequency_Hz = 10000;
inductance_H = 0.002;
capacitance_F = 0.001;
load_resistance_Ohm = 20;

output_voltage_V = duty_cycle * input_voltage_V;
inductor_current_A = output_voltage_V / load_resistance_Ohm;
estimated_current_ripple_A = (input_voltage_V - output_voltage_V) * duty_cycle / ...
    (inductance_H * switching_frequency_Hz);
estimated_voltage_ripple_V = estimated_current_ripple_A / ...
    (8 * switching_frequency_Hz * capacitance_F);

assert(input_voltage_V > 0, 'Input voltage must be positive.');
assert(duty_cycle > 0 && duty_cycle < 1, 'Duty cycle must be between 0 and 1.');
assert(load_resistance_Ohm > 0, 'Load resistance must be positive.');
assert(output_voltage_V > 0, 'Estimated output voltage must be positive.');
assert(inductor_current_A > 0, 'Estimated load current must be positive.');
assert(estimated_current_ripple_A >= 0, 'Estimated current ripple should be nonnegative.');
assert(estimated_voltage_ripple_V >= 0, 'Estimated voltage ripple should be nonnegative.');

fprintf('Converter parameter check passed.\n');
fprintf('Output voltage: %.1f V\n', output_voltage_V);
fprintf('Load current: %.1f A\n', inductor_current_A);
