function parameters = battery_module_cooling_default_parameters()
%BATTERY_MODULE_COOLING_DEFAULT_PARAMETERS Return illustrative module data.

parameters.cell_count = 6;
parameters.cell_mass_kg = 1.05 * ones(1, parameters.cell_count);
parameters.cell_specific_heat_J_per_kgK = ...
    1000 * ones(1, parameters.cell_count);
parameters.initial_cell_temp_C = 25 * ones(1, parameters.cell_count);

parameters.cell_heat_fraction = [0.14, 0.16, 0.19, 0.20, 0.17, 0.14];
parameters.cell_to_coolant_conductance_W_per_K = ...
    [1.7, 1.8, 1.9, 1.9, 1.8, 1.7];
parameters.cell_to_cell_conductance_W_per_K = ...
    0.25 * ones(1, parameters.cell_count - 1);

parameters.coolant_mass_flow_kg_per_s = 0.004;
parameters.coolant_specific_heat_J_per_kgK = 4180;
end
