function input = bess_unpack_input(inputVector)
%BESS_UNPACK_INPUT Convert the fixed scenario vector to named fields.

validateattributes(inputVector, {'numeric'}, ...
    {'real', 'finite', 'vector', 'numel', 16});
input.time_s = inputVector(1);
input.p_ref_pu = inputVector(2);
input.q_ref_pu = inputVector(3);
input.voltage_ref_pu = inputVector(4);
input.frequency_ref_Hz = inputVector(5);
input.load_p_pu = inputVector(6);
input.load_q_pu = inputVector(7);
input.grid_present = inputVector(8) >= 0.5;
input.grid_voltage_pu = inputVector(9);
input.grid_frequency_Hz = inputVector(10);
input.grid_phase_rad = inputVector(11);
input.request_grid_following = inputVector(12) >= 0.5;
input.grid_support_enable = inputVector(13) >= 0.5;
input.fault_code = round(inputVector(14));
input.available_power_pu = inputVector(15);
input.dc_voltage_pu = inputVector(16);
end
