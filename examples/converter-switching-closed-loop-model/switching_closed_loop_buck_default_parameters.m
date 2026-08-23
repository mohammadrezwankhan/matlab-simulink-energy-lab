function parameters = switching_closed_loop_buck_default_parameters()
%SWITCHING_CLOSED_LOOP_BUCK_DEFAULT_PARAMETERS Return benchmark parameters.

parameters.input_voltage_V = 800;
parameters.switching_frequency_Hz = 10000;
parameters.inductance_H = 0.002;
parameters.inductor_resistance_Ohm = 0.1;
parameters.capacitance_F = 0.001;
parameters.diode_forward_voltage_V = 1.0;
% IMZC120R040M2H typical values at 25 degC and its 800 V, 18 A
% double-pulse reference point; see the example README for source and limits.
parameters.switch_on_resistance_Ohm = 0.040;
parameters.switching_loss_reference_voltage_V = 800;
parameters.switching_loss_reference_current_A = 18;
parameters.turn_on_energy_reference_J = 109e-6;
parameters.turn_off_energy_reference_J = 45e-6;
parameters.initial_load_resistance_Ohm = 20;
parameters.final_load_resistance_Ohm = 10;
parameters.load_step_time_s = 0.10;
parameters.initial_reference_voltage_V = 300;
parameters.final_reference_voltage_V = 400;
parameters.reference_step_time_s = 0.04;
parameters.end_time_s = 0.18;
parameters.steps_per_switching_period = 100;
parameters.initial_inductor_current_A = 15;
parameters.initial_output_voltage_V = 300;
parameters.voltage_proportional_gain_A_per_V = 0.24;
parameters.voltage_integral_gain_A_per_Vs = 35;
parameters.current_proportional_gain_Ohm = 3;
parameters.minimum_current_reference_A = 0;
parameters.maximum_current_reference_A = 60;
parameters.minimum_duty_cycle = 0.05;
parameters.maximum_duty_cycle = 0.95;
parameters.control_enabled = true;
parameters.enforce_continuous_conduction = true;
parameters.fixed_duty_cycle = 0.45;
end
