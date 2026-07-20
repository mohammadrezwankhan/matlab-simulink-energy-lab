function parameters = battery_rc_default_parameters()
%BATTERY_RC_DEFAULT_PARAMETERS Return educational first-order RC parameters.

parameters.capacity_Ah = 50;
parameters.initial_soc = 0.80;
parameters.ocv_nominal_V = 3.70;
parameters.r0_Ohm = 0.004;
parameters.r1_Ohm = 0.002;
parameters.c1_F = 2400;
end
