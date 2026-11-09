function scenario = build_nasa_rw3_fit_scenario()
%build_nasa_rw3_fit_scenario Load measured NASA pulse records.
%   SCENARIO = build_nasa_rw3_fit_scenario returns separate calibration
%   and held-out records, plus an independently measured quasi-OCV curve.

directory = fullfile(fileparts(mfilename('fullpath')), 'data', 'nasa-rw3');
curve = readtable(fullfile(directory, 'quasi-ocv.csv'));
parameters = battery_2rc_default_parameters();
parameters.capacity_Ah = 2.1191638166664273;
parameters.initial_soc = 1;
parameters.ocv_soc_breakpoints = curve.soc;
parameters.ocv_lookup_V = curve.voltage_V;
scenario = struct( ...
    'calibration_data', readtable(fullfile(directory, 'calibration.csv')), ...
    'validation_data', readtable(fullfile(directory, 'validation.csv')), ...
    'initial_parameters', parameters, ...
    'validation_initial_soc', 0.764099627691965);
end
