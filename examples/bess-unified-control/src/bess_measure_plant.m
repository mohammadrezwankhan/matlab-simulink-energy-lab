function measurement = bess_measure_plant(state)
%BESS_MEASURE_PLANT Produce balanced abc and scalar PCC measurements.

voltageAngles = state.phase_rad + [0, -2 * pi / 3, 2 * pi / 3];
voltage_abc_pu = sqrt(2) * state.voltage_pu .* sin(voltageAngles);
current_pu = hypot(state.current_d_pu, state.current_q_pu);
if current_pu > 1e-12
    currentAngle = state.phase_rad + atan2( ...
        state.current_q_pu, state.current_d_pu);
    currentAngles = currentAngle + [0, -2 * pi / 3, 2 * pi / 3];
    current_abc_pu = sqrt(2) * current_pu .* sin(currentAngles);
else
    current_abc_pu = [0, 0, 0];
end

measurement.voltage_abc_pu = voltage_abc_pu;
measurement.current_abc_pu = current_abc_pu;
measurement.p_pu = state.p_pu;
measurement.q_pu = state.q_pu;
measurement.voltage_pu = state.voltage_pu;
measurement.frequency_Hz = state.frequency_Hz;
measurement.phase_rad = state.phase_rad;
measurement.breaker_closed = state.breaker_closed;
measurement.current_pu = current_pu;
measurement.current_d_pu = state.current_d_pu;
measurement.current_q_pu = state.current_q_pu;
end
