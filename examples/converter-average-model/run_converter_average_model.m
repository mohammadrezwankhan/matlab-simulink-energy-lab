%% Converter Average Model Scaffold
% Prints starter assumptions and first-pass averaged estimates without plotting.

clear; clc;

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

fprintf('Converter average model scaffold\n');
fprintf('Input voltage: %.1f V\n', input_voltage_V);
fprintf('Duty cycle: %.2f\n', duty_cycle);
fprintf('Switching frequency: %.0f Hz\n', switching_frequency_Hz);
fprintf('Estimated output voltage: %.1f V\n', output_voltage_V);
fprintf('Estimated load current: %.1f A\n', inductor_current_A);
fprintf('Estimated current ripple: %.2f A\n', estimated_current_ripple_A);
fprintf('Estimated voltage ripple: %.3f V\n', estimated_voltage_ripple_V);
