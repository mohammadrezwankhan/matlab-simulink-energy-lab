function profile = battery_module_cooling_default_profile()
%BATTERY_MODULE_COOLING_DEFAULT_PROFILE Return a 30-minute heat profile.

time_s = (0:1800)';
module_heat_generation_W = zeros(size(time_s));
module_heat_generation_W(time_s >= 60 & time_s < 660) = 180;
module_heat_generation_W(time_s >= 660 & time_s < 900) = 30;
module_heat_generation_W(time_s >= 900 & time_s < 1320) = 140;
coolant_inlet_temp_C = 25 * ones(size(time_s));

profile = table(time_s, module_heat_generation_W, coolant_inlet_temp_C);
end
