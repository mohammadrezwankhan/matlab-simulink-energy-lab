function parameters = battery_rc_default_parameters()
%BATTERY_RC_DEFAULT_PARAMETERS Return educational first-order RC parameters.

parameters.capacity_Ah = 50;
parameters.initial_soc = 0.80;
parameters.ocv_soc_breakpoints = (0:0.2:1)';
parameters.ocv_lookup_V = 3.65 + 0.10 * parameters.ocv_soc_breakpoints;
parameters.r0_Ohm = 0.004;
parameters.r1_Ohm = 0.002;
parameters.c1_F = 2400;
end
