%% Battery RC Model Starter Script
% This script is a small, inspectable first-order equivalent-circuit model.
% It is intended as a starting point for documentation and validation notes,
% not as a calibrated battery model.

clear; clc;

%% Parameters
capacity_Ah = 50;      % Cell capacity [Ah]
initial_soc = 0.80;    % Initial state of charge [-]
ocv_nominal_V = 3.70;  % Nominal open-circuit voltage [V]
r0_Ohm = 0.004;        % Ohmic resistance [Ohm]
r1_Ohm = 0.002;        % Polarization resistance [Ohm]
c1_F = 2400;           % Polarization capacitance [F]
dt_s = 1;              % Simulation time step [s]
t_end_s = 600;         % Simulation duration [s]

%% Current Profile
% Sign convention: positive current means discharge.
time_s = (0:dt_s:t_end_s)';
current_A = zeros(size(time_s));
current_A(time_s >= 60 & time_s < 240) = 50;    % 1C discharge pulse [A]
current_A(time_s >= 360 & time_s < 480) = -25;  % 0.5C charge pulse [A]

%% State Initialization
soc = zeros(size(time_s));
v_rc = zeros(size(time_s));
terminal_voltage_V = zeros(size(time_s));

soc(1) = initial_soc;
terminal_voltage_V(1) = ocv_nominal_V;

%% Simulation Loop
for k = 2:numel(time_s)
    soc(k) = soc(k-1) - (current_A(k-1) * dt_s) / (capacity_Ah * 3600);
    soc(k) = min(max(soc(k), 0), 1);

    dv_rc = (-(v_rc(k-1) / (r1_Ohm * c1_F)) + current_A(k-1) / c1_F) * dt_s;
    v_rc(k) = v_rc(k-1) + dv_rc;

    ocv_V = ocv_nominal_V + 0.1 * (soc(k) - 0.5); % Placeholder OCV-SOC relation [V]
    terminal_voltage_V(k) = ocv_V - current_A(k) * r0_Ohm - v_rc(k);
end

%% Results
figure('Name', 'Battery RC Model Starter');
tiledlayout(3, 1);

nexttile;
plot(time_s, current_A, 'LineWidth', 1.2);
grid on;
ylabel('Current [A]');
title('Input Current Profile');

nexttile;
plot(time_s, soc, 'LineWidth', 1.2);
grid on;
ylabel('SOC [-]');
title('State of Charge');

nexttile;
plot(time_s, terminal_voltage_V, 'LineWidth', 1.2);
grid on;
xlabel('Time [s]');
ylabel('Voltage [V]');
title('Terminal Voltage');

fprintf('Final SOC: %.3f\n', soc(end));
fprintf('Voltage range: %.3f V to %.3f V\n', min(terminal_voltage_V), max(terminal_voltage_V));
