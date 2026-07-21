function parameters = battery_thermal_default_parameters()
%BATTERY_THERMAL_DEFAULT_PARAMETERS Return educational thermal parameters.

parameters.capacity_Ah = 50;
parameters.initial_soc = 0.80;
parameters.ocv_nominal_V = 3.70;
parameters.ocv_soc_slope_V = 0.10;
parameters.r0_reference_Ohm = 0.004;
parameters.r1_Ohm = 0.002;
parameters.c1_F = 2400;
parameters.resistance_temp_coefficient_per_C = 0.025;
parameters.reference_temp_C = 25;
parameters.entropic_soc_breakpoints = [0, 0.20, 0.40, 0.60, 0.80, 1.00];
parameters.entropic_coefficient_V_per_K = 1e-3 * ...
    [-0.10, 0.05, -0.08, 0.10, -0.05, 0.02];

parameters.ambient_temp_C = 25;
parameters.initial_cell_temp_C = 25;
parameters.cell_mass_kg = 1.05;
parameters.specific_heat_J_per_kgK = 1000;
parameters.heat_transfer_W_per_K = 1.2;
end
