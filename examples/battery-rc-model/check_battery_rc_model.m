%% Battery RC Model Lightweight Check
% Runs the starter RC model with sample pulse-current data and no plotting.

clear; clc;

dataPath = fullfile(fileparts(mfilename('fullpath')), 'data', 'pulse_current_profile.csv');
profile = readtable(dataPath);

capacity_Ah = 50;
initial_soc = 0.80;
ocv_nominal_V = 3.70;
r0_Ohm = 0.004;
r1_Ohm = 0.002;
c1_F = 2400;
dt_s = 1;

time_s = (profile.time_s(1):dt_s:profile.time_s(end))';
current_A = interp1(profile.time_s, profile.current_A, time_s, 'previous', 'extrap');

soc = zeros(size(time_s));
v_rc = zeros(size(time_s));
terminal_voltage_V = zeros(size(time_s));

soc(1) = initial_soc;
terminal_voltage_V(1) = ocv_nominal_V;

for k = 2:numel(time_s)
    soc(k) = soc(k-1) - (current_A(k-1) * dt_s) / (capacity_Ah * 3600);
    soc(k) = min(max(soc(k), 0), 1);

    dv_rc = (-(v_rc(k-1) / (r1_Ohm * c1_F)) + current_A(k-1) / c1_F) * dt_s;
    v_rc(k) = v_rc(k-1) + dv_rc;

    ocv_V = ocv_nominal_V + 0.1 * (soc(k) - 0.5);
    terminal_voltage_V(k) = ocv_V - current_A(k) * r0_Ohm - v_rc(k);
end

assert(height(profile) >= 10, 'Expected at least 10 sample profile rows.');
assert(all(soc >= 0 & soc <= 1), 'SOC must remain within [0, 1].');
assert(max(terminal_voltage_V) > min(terminal_voltage_V), 'Voltage response should vary over the pulse profile.');
assert(abs(soc(end) - 0.7667) < 0.01, 'Final SOC moved outside the expected starter-model tolerance.');

fprintf('Battery RC check passed. Final SOC: %.3f\n', soc(end));
fprintf('Voltage range: %.3f V to %.3f V\n', min(terminal_voltage_V), max(terminal_voltage_V));
