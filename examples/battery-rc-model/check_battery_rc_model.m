%% Battery RC Model Check
% Validates the shared simulator against the canonical pulse profile.

clear; clc;

modelDirectory = fileparts(mfilename('fullpath'));
originalPath = path;
pathCleanup = onCleanup(@() path(originalPath));
addpath(modelDirectory);

profilePath = fullfile(modelDirectory, 'data', 'pulse_current_profile.csv');
profile = readtable(profilePath);
parameters = battery_rc_default_parameters();
result = simulate_battery_rc_model(profile, parameters, 1);

assert(height(profile) >= 10, 'Expected at least 10 sample profile rows.');
assert(numel(result.time_s) == 601, 'Expected a 600-second, 1 Hz result.');
assert(all(isfinite(result.terminal_voltage_V)), ...
    'Terminal voltage must remain finite.');
assert(all(result.soc >= 0 & result.soc <= 1), ...
    'SOC must remain within [0, 1].');
assert(all(result.ocv_V >= parameters.ocv_lookup_V(1) & ...
    result.ocv_V <= parameters.ocv_lookup_V(end)), ...
    'Interpolated OCV must remain inside the lookup-table range.');
assert(max(result.terminal_voltage_V) > min(result.terminal_voltage_V), ...
    'Voltage response should vary over the pulse profile.');
assert(abs(result.soc(end) - 0.7667) < 0.01, ...
    'Final SOC moved outside the expected starter-model tolerance.');
assert(abs(result.ocv_V(1) - 3.73) < 1e-12 && ...
    abs(result.terminal_voltage_V(1) - result.ocv_V(1)) < 1e-12, ...
    'Initial voltage must use the OCV lookup and initial current sample.');
reconstructedVoltage_V = result.ocv_V - ...
    result.current_A * parameters.r0_Ohm - result.v_rc_V;
assert(max(abs(result.terminal_voltage_V - reconstructedVoltage_V)) < 1e-12, ...
    'Terminal voltage must satisfy the equivalent-circuit voltage balance.');

index60 = find(result.time_s == 60, 1);
index61 = find(result.time_s == 61, 1);
assert(result.current_A(index60) == 0 && result.current_A(index61) == 50, ...
    'Canonical discharge pulse must begin after the 60-second sample.');

repeatResult = simulate_battery_rc_model(profile, parameters, 1);
assert(isequal(result.soc, repeatResult.soc) && ...
    isequal(result.ocv_V, repeatResult.ocv_V) && ...
    isequal(result.terminal_voltage_V, repeatResult.terminal_voltage_V), ...
    'Repeated simulation must be deterministic.');

curvedParameters = parameters;
curvedParameters.initial_soc = 0.70;
curvedParameters.ocv_lookup_V = [3.10; 3.48; 3.58; 3.66; 3.78; 4.15];
curvedResult = simulate_battery_rc_model(profile, curvedParameters, 1);
expectedInitialOcv_V = interp1(curvedParameters.ocv_soc_breakpoints, ...
    curvedParameters.ocv_lookup_V, curvedParameters.initial_soc, 'linear');
assert(abs(curvedResult.ocv_V(1) - expectedInitialOcv_V) < 1e-12, ...
    'A custom nonlinear OCV lookup must be interpolated at the initial SOC.');

invalidProfile = profile;
invalidProfile.time_s(2) = invalidProfile.time_s(1);
caughtTimeOrder = false;
try
    simulate_battery_rc_model(invalidProfile, parameters, 1);
catch validationError
    caughtTimeOrder = strcmp(validationError.identifier, 'BatteryRC:TimeOrder');
end
assert(caughtTimeOrder, ...
    'Simulator must reject non-increasing profile timestamps.');

unstableStepRejected = false;
try
    simulate_battery_rc_model(profile, parameters, 10);
catch validationError
    unstableStepRejected = strcmp(...
        validationError.identifier, 'BatteryRC:NumericalStability');
end
assert(unstableStepRejected, ...
    'Simulator must reject an unstable explicit-Euler time step.');

invalidCurveParameters = parameters;
invalidCurveParameters.ocv_soc_breakpoints(4) = ...
    invalidCurveParameters.ocv_soc_breakpoints(3);
invalidCurveRejected = false;
try
    simulate_battery_rc_model(profile, invalidCurveParameters, 1);
catch validationError
    invalidCurveRejected = strcmp(validationError.identifier, ...
        'BatteryRC:OCVCurve');
end
assert(invalidCurveRejected, ...
    'Simulator must reject non-increasing OCV SOC breakpoints.');

decreasingOcvParameters = parameters;
decreasingOcvParameters.ocv_lookup_V(4) = ...
    decreasingOcvParameters.ocv_lookup_V(3) - 0.01;
decreasingOcvRejected = false;
try
    simulate_battery_rc_model(profile, decreasingOcvParameters, 1);
catch validationError
    decreasingOcvRejected = strcmp(validationError.identifier, ...
        'BatteryRC:OCVCurve');
end
assert(decreasingOcvRejected, ...
    'Simulator must reject OCV values that decrease with SOC.');

fprintf('Battery RC check passed. Final SOC: %.3f\n', result.soc(end));
fprintf('Voltage range: %.3f V to %.3f V\n', ...
    min(result.terminal_voltage_V), max(result.terminal_voltage_V));
