function prepare_lfp_data(pulseFile, ocvFile, dynamicFile, outputDirectory)
%prepare_lfp_data - Reproduce the measured LFP example files
%   prepare_lfp_data(PULSEFILE,OCVFILE,DYNAMICFILE,OUTPUTDIRECTORY)
%   derives the example CSV files from the cited source MAT-files. The
%   output directory must exist and must not contain those filenames.

names = {'calibration.csv', 'validation.csv', 'quasi-ocv.csv'};
if ~all(cellfun(@isfile, {pulseFile, ocvFile, dynamicFile})) || ...
        ~isfolder(outputDirectory)
    error('LFP:Path', 'Input files and output directory must exist.');
end
if any(cellfun(@(n) isfile(fullfile(outputDirectory, n)), names))
    error('LFP:Exists', 'Output files must not already exist.');
end
p = load(pulseFile, 'Data');
o = load(ocvFile, 'OCVData');
q = load(dynamicFile, 'DYNData');
s = o.OCVData.script1;
capacity = max(s.disAh);
use = s.current < -0.08;
rawSoc = 1 - s.disAh(use)/capacity;
rawVoltage = s.voltage(use);
[soc, indices] = unique(flip(rawSoc));
voltage = flip(rawVoltage);
voltage = voltage(indices);
selected = unique(round(linspace(1, numel(soc), 300)));
soc = soc(selected);
voltage = cummax(voltage(selected));
soc([1 end]) = [0 1];
writetable(table(soc, voltage, 'VariableNames', {'soc', 'voltage_V'}), ...
    fullfile(outputDirectory, names{3}));

d = p.Data;
indices = find(d.step == 5 | d.step == 6);
indices = indices(1:400);
time_s = d.time(indices) - d.time(indices(1));
current_A = -d.current(indices);
terminal_voltage_V = d.voltage(indices);
initialSoc = 1 - d.disAh(indices(1))/capacity;
socTrace = initialSoc - [0; cumsum(current_A(1:end-1).*diff(time_s))] ...
    / (3600*capacity);
ocv_V = interp1(soc, voltage, socTrace, 'linear');
writetable(table(time_s, current_A, ocv_V, terminal_voltage_V), ...
    fullfile(outputDirectory, names{1}));

v = q.DYNData.script1;
indices = (1:1500)';
time_s = v.time(indices)' - v.time(1);
current_A = v.current(indices)';
terminal_voltage_V = v.voltage(indices)';
writetable(table(time_s, current_A, terminal_voltage_V), ...
    fullfile(outputDirectory, names{2}));
end
