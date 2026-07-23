function parameters = pouch_cell_thermal_default_parameters()
%POUCH_CELL_THERMAL_DEFAULT_PARAMETERS Return illustrative pouch-cell data.

parameters.node_count = 15;
parameters.thickness_m = 0.008;
parameters.width_m = 0.15;
parameters.height_m = 0.10;
parameters.density_kg_per_m3 = 2200;
parameters.specific_heat_J_per_kgK = 900;
parameters.through_plane_conductivity_W_per_mK = 0.45;
parameters.left_heat_transfer_coefficient_W_per_m2K = 35;
parameters.right_heat_transfer_coefficient_W_per_m2K = 12;
parameters.initial_temperature_C = 25;
end
