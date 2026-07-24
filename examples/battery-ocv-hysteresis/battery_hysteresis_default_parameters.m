function parameters = battery_hysteresis_default_parameters()
%BATTERY_HYSTERESIS_DEFAULT_PARAMETERS Return educational hysteresis parameters.

parameters.capacity_Ah = 50;
parameters.initial_soc = 0.60;
parameters.ocv_soc_breakpoints = (0:0.1:1)';
parameters.ocv_lookup_V = [
    3.10;
    3.38;
    3.52;
    3.60;
    3.66;
    3.71;
    3.76;
    3.82;
    3.91;
    4.03;
    4.18
];
parameters.r0_Ohm = 0.004;
parameters.r1_Ohm = 0.002;
parameters.c1_F = 2400;
parameters.hysteresis_max_V = 0.025;
parameters.hysteresis_rate_per_fractional_throughput = 15;
parameters.initial_hysteresis_state = 0;
end
