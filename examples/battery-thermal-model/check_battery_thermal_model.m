%% Temperature-Aware Battery Model Check
% Runs the coupled electro-thermal example without plotting and validates
% physical bounds plus the discrete thermal energy balance.

clear; clc;

capacity_Ah = 50;
initial_soc = 0.80;
ocv_nominal_V = 3.70;
r0_reference_Ohm = 0.004;
r1_Ohm = 0.002;
c1_F = 2400;
resistance_temp_coefficient_per_C = 0.025;
reference_temp_C = 25;

ambient_temp_C = 25;
cell_mass_kg = 1.05;
specific_heat_J_per_kgK = 1000;
heat_transfer_W_per_K = 1.2;
thermal_capacity_J_per_K = cell_mass_kg * specific_heat_J_per_kgK;

dt_s = 1;
t_end_s = 1800;
time_s = (0:dt_s:t_end_s)';
current_A = zeros(size(time_s));
current_A(time_s >= 60 & time_s < 660) = 75;
current_A(time_s >= 900 & time_s < 1320) = -25;

soc = zeros(size(time_s));
v_rc_V = zeros(size(time_s));
terminal_voltage_V = zeros(size(time_s));
cell_temp_C = zeros(size(time_s));
r0_Ohm = zeros(size(time_s));
heat_generation_W = zeros(size(time_s));
cooling_power_W = zeros(size(time_s));

soc(1) = initial_soc;
cell_temp_C(1) = ambient_temp_C;
r0_Ohm(1) = r0_reference_Ohm;
terminal_voltage_V(1) = ocv_nominal_V;

for k = 2:numel(time_s)
    soc(k) = soc(k-1) - (current_A(k-1) * dt_s) / (capacity_Ah * 3600);
    soc(k) = min(max(soc(k), 0), 1);

    dv_rc_V = (-(v_rc_V(k-1) / (r1_Ohm * c1_F)) ...
        + current_A(k-1) / c1_F) * dt_s;
    v_rc_V(k) = v_rc_V(k-1) + dv_rc_V;

    heat_generation_W(k-1) = current_A(k-1) ...
        * (current_A(k-1) * r0_Ohm(k-1) + v_rc_V(k-1));
    cooling_power_W(k-1) = heat_transfer_W_per_K ...
        * (cell_temp_C(k-1) - ambient_temp_C);

    net_heat_W = heat_generation_W(k-1) - cooling_power_W(k-1);
    cell_temp_C(k) = cell_temp_C(k-1) ...
        + (net_heat_W / thermal_capacity_J_per_K) * dt_s;

    r0_Ohm(k) = r0_reference_Ohm * exp(...
        resistance_temp_coefficient_per_C ...
        * (reference_temp_C - cell_temp_C(k)));

    ocv_V = ocv_nominal_V + 0.1 * (soc(k) - 0.5);
    terminal_voltage_V(k) = ocv_V - current_A(k) * r0_Ohm(k) - v_rc_V(k);
end

heat_generation_W(end) = current_A(end) ...
    * (current_A(end) * r0_Ohm(end) + v_rc_V(end));
cooling_power_W(end) = heat_transfer_W_per_K ...
    * (cell_temp_C(end) - ambient_temp_C);

thermal_energy_change_J = thermal_capacity_J_per_K ...
    * (cell_temp_C(end) - cell_temp_C(1));
integrated_net_heat_J = sum(heat_generation_W(1:end-1) ...
    - cooling_power_W(1:end-1)) * dt_s;
energy_balance_error_J = abs(thermal_energy_change_J - integrated_net_heat_J);

assert(all(soc >= 0 & soc <= 1), 'SOC must remain within [0, 1].');
assert(all(cell_temp_C >= ambient_temp_C - 1e-9), ...
    'This pulse case should not cool below the fixed ambient temperature.');
assert(max(cell_temp_C) > ambient_temp_C + 5, ...
    'The discharge pulse should produce a visible temperature rise.');
assert(max(cell_temp_C) < 45, ...
    'The educational pulse case should remain below 45 degC.');
assert(min(r0_Ohm) < r0_reference_Ohm, ...
    'Ohmic resistance should decrease as cell temperature rises.');
assert(all(heat_generation_W >= -1e-9), ...
    'Irreversible heat should remain nonnegative for this pulse case.');
assert(max(terminal_voltage_V) > min(terminal_voltage_V), ...
    'Terminal voltage should vary over the current profile.');
assert(energy_balance_error_J < 1e-6, ...
    'Discrete thermal energy balance is inconsistent.');

fprintf('Battery thermal check passed.\n');
fprintf('Peak cell temperature: %.2f degC\n', max(cell_temp_C));
fprintf('Final cell temperature: %.2f degC\n', cell_temp_C(end));
fprintf('Peak irreversible heat: %.2f W\n', max(heat_generation_W));
fprintf('Final SOC: %.3f\n', soc(end));
