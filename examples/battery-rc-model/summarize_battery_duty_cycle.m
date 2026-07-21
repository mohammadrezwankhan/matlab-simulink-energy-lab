function summary = summarize_battery_duty_cycle(result)
%SUMMARIZE_BATTERY_DUTY_CYCLE Integrate charge and terminal-energy duty.
% Positive current is discharge. The final timestamp has no following
% interval, so its current and voltage do not contribute to the integrals.

requiredFields = {
    'time_s';
    'current_A';
    'terminal_voltage_V';
    'soc';
    'parameters'
};
if ~isstruct(result) || ~all(isfield(result, requiredFields))
    error('BatteryDuty:ResultFields', ...
        'Result must contain time, current, voltage, SOC, and parameters.');
end

time_s = validated_vector(result.time_s, 'time_s');
current_A = validated_vector(result.current_A, 'current_A');
terminalVoltage_V = validated_vector(...
    result.terminal_voltage_V, 'terminal_voltage_V');
soc = validated_vector(result.soc, 'soc');
sampleCount = numel(time_s);
if sampleCount < 2 || numel(current_A) ~= sampleCount || ...
        numel(terminalVoltage_V) ~= sampleCount || numel(soc) ~= sampleCount
    error('BatteryDuty:SignalShape', ...
        'Duty-cycle signals must have equal lengths and at least two samples.');
end
if any(diff(time_s) <= 0)
    error('BatteryDuty:TimeOrder', ...
        'time_s must be strictly increasing.');
end
if any(terminalVoltage_V <= 0)
    error('BatteryDuty:TerminalVoltage', ...
        'terminal_voltage_V must remain positive for energy accounting.');
end
if any(soc < 0 | soc > 1)
    error('BatteryDuty:SOCBounds', 'soc must remain within [0, 1].');
end
if ~isstruct(result.parameters) || ...
        ~isfield(result.parameters, 'capacity_Ah')
    error('BatteryDuty:Capacity', ...
        'result.parameters must contain capacity_Ah.');
end
capacity_Ah = result.parameters.capacity_Ah;
if ~isnumeric(capacity_Ah) || ~isscalar(capacity_Ah) || ...
        ~isreal(capacity_Ah) || ~isfinite(capacity_Ah) || capacity_Ah <= 0
    error('BatteryDuty:Capacity', ...
        'capacity_Ah must be a finite positive real scalar.');
end

interval_s = diff(time_s);
intervalCurrent_A = current_A(1:end-1);
intervalVoltage_V = terminalVoltage_V(1:end-1);
signedCharge_Ah = intervalCurrent_A .* interval_s / 3600;
signedTerminalEnergy_Wh = ...
    intervalCurrent_A .* intervalVoltage_V .* interval_s / 3600;

discharged_Ah = sum(max(signedCharge_Ah, 0));
charged_Ah = sum(max(-signedCharge_Ah, 0));
dischargedEnergy_Wh = sum(max(signedTerminalEnergy_Wh, 0));
chargedEnergy_Wh = sum(max(-signedTerminalEnergy_Wh, 0));

summary.duration_s = time_s(end) - time_s(1);
summary.discharged_Ah = discharged_Ah;
summary.charged_Ah = charged_Ah;
summary.net_discharged_Ah = discharged_Ah - charged_Ah;
summary.charge_throughput_Ah = discharged_Ah + charged_Ah;
summary.equivalent_full_cycles = ...
    summary.charge_throughput_Ah / (2 * capacity_Ah);
summary.discharged_energy_Wh = dischargedEnergy_Wh;
summary.charged_energy_Wh = chargedEnergy_Wh;
summary.net_delivered_energy_Wh = ...
    dischargedEnergy_Wh - chargedEnergy_Wh;
summary.energy_throughput_Wh = dischargedEnergy_Wh + chargedEnergy_Wh;
summary.minimum_soc = min(soc);
summary.maximum_soc = max(soc);
summary.minimum_terminal_voltage_V = min(terminalVoltage_V);
summary.maximum_terminal_voltage_V = max(terminalVoltage_V);
summary.soc_charge_balance_error = soc(end) - ...
    (soc(1) - summary.net_discharged_Ah / capacity_Ah);
end

function values = validated_vector(value, fieldName)
if ~isnumeric(value) || ~isvector(value) || ~isreal(value) || ...
        any(~isfinite(value))
    error('BatteryDuty:Signals', ...
        '%s must be a finite real numeric vector.', fieldName);
end
values = value(:);
end
