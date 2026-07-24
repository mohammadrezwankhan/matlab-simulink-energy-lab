function profile = battery_hysteresis_default_profile()
%BATTERY_HYSTERESIS_DEFAULT_PROFILE Return a reversal-rich current profile.
% Positive current discharges the cell and negative current charges it.

time_s = [
    0;
    300;
    900;
    1200;
    1500;
    1800;
    2100;
    2400;
    3000;
    3300
];
current_A = [
    0;
    30;
    0;
    -30;
    0;
    30;
    0;
    -30;
    0;
    0
];
profile = table(time_s, current_A);
end
