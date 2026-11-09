function scenario = build_lfp_fit_scenario()
%build_lfp_fit_scenario - Load measured LFP identification records
%   SCENARIO = build_lfp_fit_scenario returns calibration and independent
%   dynamic records with a separately measured quasi-OCV curve.

directory = fullfile(fileparts(mfilename('fullpath')), 'data', 'a123-lfp');
curve = readtable(fullfile(directory, 'quasi-ocv.csv'));
p = battery_2rc_default_parameters();
p.capacity_Ah = 2.577564669012937;
p.initial_soc = 0.5151039184698124;
p.ocv_soc_breakpoints = curve.soc;
p.ocv_lookup_V = curve.voltage_V;
scenario = struct('calibration_data', ...
    readtable(fullfile(directory, 'calibration.csv')), ...
    'validation_data', readtable(fullfile(directory, 'validation.csv')), ...
    'initial_parameters', p);
end
