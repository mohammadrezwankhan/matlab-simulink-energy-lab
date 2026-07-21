function parameters = switching_buck_default_parameters()
%SWITCHING_BUCK_DEFAULT_PARAMETERS Return illustrative synchronous buck data.

parameters.input_voltage_V = 800;
parameters.duty_cycle = 0.45;
parameters.switching_frequency_Hz = 10000;
parameters.inductance_H = 0.002;
parameters.inductor_resistance_Ohm = 0.1;
parameters.capacitance_F = 0.001;
parameters.load_resistance_Ohm = 20;
parameters.end_time_s = 0.3;
parameters.steps_per_switching_period = 100;
parameters.initial_inductor_current_A = 0;
parameters.initial_output_voltage_V = 0;
end
