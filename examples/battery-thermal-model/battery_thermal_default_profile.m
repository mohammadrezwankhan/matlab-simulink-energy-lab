function profile = battery_thermal_default_profile()
%BATTERY_THERMAL_DEFAULT_PROFILE Return the canonical 30-minute profile.

time_s = (0:1800)';
current_A = zeros(size(time_s));
current_A(time_s >= 60 & time_s < 660) = 75;
current_A(time_s >= 900 & time_s < 1320) = -25;
profile = table(time_s, current_A);
end
