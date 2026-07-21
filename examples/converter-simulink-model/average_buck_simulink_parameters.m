function parameters = average_buck_simulink_parameters()
%AVERAGE_BUCK_SIMULINK_PARAMETERS Return illustrative averaged buck data.

parameters.input_voltage_V = 800;
parameters.duty_cycle = 0.45;
parameters.inductance_H = 0.002;
parameters.inductor_resistance_Ohm = 0.1;
parameters.capacitance_F = 0.001;
parameters.load_resistance_Ohm = 20;
parameters.end_time_s = 0.3;
parameters.initial_inductor_current_A = 0;
parameters.initial_output_voltage_V = 0;
parameters.solver_max_step_s = 1e-4;
parameters.relative_tolerance = 1e-9;
parameters.absolute_tolerance = 1e-10;
end
