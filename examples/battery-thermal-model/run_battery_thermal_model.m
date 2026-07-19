%% Temperature-Aware Battery Model
% Couples a first-order electrical equivalent circuit to a lumped thermal
% balance. Parameters are educational placeholders, not calibrated cell data.

clear; clc;

%% Electrical Parameters
capacity_Ah = 50;                   % Cell capacity [Ah]
initial_soc = 0.80;                 % Initial state of charge [-]
ocv_nominal_V = 3.70;               % Nominal open-circuit voltage [V]
r0_reference_Ohm = 0.004;           % Ohmic resistance at 25 degC [Ohm]
r1_Ohm = 0.002;                     % Polarization resistance [Ohm]
c1_F = 2400;                        % Polarization capacitance [F]
resistance_temp_coefficient_per_C = 0.025; % Resistance sensitivity [1/degC]
reference_temp_C = 25;              % Resistance reference temperature [degC]

%% Thermal Parameters
ambient_temp_C = 25;                % Fixed ambient temperature [degC]
cell_mass_kg = 1.05;                % Lumped cell mass [kg]
specific_heat_J_per_kgK = 1000;     % Effective specific heat [J/(kg K)]
heat_transfer_W_per_K = 1.2;        % Lumped conductance to ambient [W/K]
thermal_capacity_J_per_K = cell_mass_kg * specific_heat_J_per_kgK;

%% Simulation Settings and Current Profile
% Sign convention: positive current means discharge.
dt_s = 1;                           % Simulation time step [s]
t_end_s = 1800;                     % Simulation duration [s]
time_s = (0:dt_s:t_end_s)';
current_A = zeros(size(time_s));
current_A(time_s >= 60 & time_s < 660) = 75;    % 1.5C discharge [A]
current_A(time_s >= 900 & time_s < 1320) = -25; % 0.5C charge [A]

%% State Initialization
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

%% Coupled Electro-Thermal Simulation
for k = 2:numel(time_s)
    soc(k) = soc(k-1) - (current_A(k-1) * dt_s) / (capacity_Ah * 3600);
    soc(k) = min(max(soc(k), 0), 1);

    dv_rc_V = (-(v_rc_V(k-1) / (r1_Ohm * c1_F)) ...
        + current_A(k-1) / c1_F) * dt_s;
    v_rc_V(k) = v_rc_V(k-1) + dv_rc_V;

    % Irreversible heat from the equivalent-circuit voltage loss.
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

%% Results
figure('Name', 'Temperature-Aware Battery Model');
tiledlayout(4, 1);

nexttile;
plot(time_s, current_A, 'LineWidth', 1.2);
grid on;
ylabel('Current [A]');
title('Applied Current');

nexttile;
plot(time_s, terminal_voltage_V, 'LineWidth', 1.2);
grid on;
ylabel('Voltage [V]');
title('Terminal Voltage');

nexttile;
plot(time_s, cell_temp_C, 'LineWidth', 1.2);
grid on;
ylabel('Temperature [degC]');
title('Lumped Cell Temperature');

nexttile;
plot(time_s, heat_generation_W, 'LineWidth', 1.2);
grid on;
xlabel('Time [s]');
ylabel('Heat [W]');
title('Irreversible Heat Generation');

fprintf('Peak cell temperature: %.2f degC\n', max(cell_temp_C));
fprintf('Final cell temperature: %.2f degC\n', cell_temp_C(end));
fprintf('Peak irreversible heat: %.2f W\n', max(heat_generation_W));
fprintf('Final SOC: %.3f\n', soc(end));
