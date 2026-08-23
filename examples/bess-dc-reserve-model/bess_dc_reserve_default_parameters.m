function parameters = bess_dc_reserve_default_parameters()
%BESS_DC_RESERVE_DEFAULT_PARAMETERS Return the canonical DC-side benchmark.

parameters.sample_time_s = 0.1;
parameters.end_time_s = 420;
parameters.capacity_Ah = 200;
parameters.initial_soc = 0.25;
parameters.minimum_reserve_soc = 0.20;
parameters.maximum_soc = 0.90;
parameters.reserve_taper_width_soc = 0.04;
parameters.charge_taper_width_soc = 0.05;
parameters.ocv_intercept_V = 700;
parameters.ocv_slope_V_per_soc = 100;
parameters.internal_resistance_Ohm = 0.08;
parameters.maximum_discharge_current_A = 500;
parameters.maximum_charge_current_A = 300;
parameters.dc_link_capacitance_F = 0.8;
parameters.dc_voltage_reference_V = 750;
parameters.initial_dc_voltage_V = 750;
parameters.minimum_dc_voltage_V = 700;
parameters.maximum_dc_voltage_V = 800;
parameters.dc_energy_feedback_gain_per_s = 4;
parameters.request_breakpoints_s = [0; 120; 240; 360];
parameters.requested_converter_power_W = [250e3; -120e3; 300e3; 0];
end
