function profile = pouch_cell_thermal_default_profile()
%POUCH_CELL_THERMAL_DEFAULT_PROFILE Return a 50-minute heat-load profile.

time_s = (0:3000)';
cell_heat_generation_W = zeros(size(time_s));
cell_heat_generation_W(time_s >= 120 & time_s < 900) = 6;
cell_heat_generation_W(time_s >= 900 & time_s < 1800) = 12;
cell_heat_generation_W(time_s >= 1800 & time_s < 2400) = 4;
left_fluid_temperature_C = 25 * ones(size(time_s));
right_fluid_temperature_C = 25 * ones(size(time_s));

profile = table( ...
    time_s, cell_heat_generation_W, ...
    left_fluid_temperature_C, right_fluid_temperature_C);
end
