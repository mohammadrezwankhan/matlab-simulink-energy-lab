function prepare_nasa_rw3_data(sourceFile, outputDirectory)
%prepare_nasa_rw3_data Reproduce the NASA RW3 pulse fixtures.
%   prepare_nasa_rw3_data(SOURCEFILE, OUTPUTDIRECTORY) reads the original
%   RW3 MAT-file and writes three CSV files without overwriting them.

names = {'calibration.csv', 'validation.csv', 'quasi-ocv.csv'};
if ~isfile(sourceFile) || ~isfolder(outputDirectory)
    error('NasaRW3:Path', 'Source file and output directory must exist.');
end
if any(cellfun(@(name) isfile(fullfile(outputDirectory, name)), names))
    error('NasaRW3:Exists', 'The output files must not already exist.');
end
loaded = load(sourceFile, 'data');
if ~isfield(loaded, 'data') || ~isstruct(loaded.data) || ...
        ~isfield(loaded.data, 'step') || numel(loaded.data.step) < 16
    error('NasaRW3:Source', 'The source is not the expected RW3 record.');
end
steps = loaded.data.step;
expected = repmat({'pulsed load (rest)', 'pulsed load (discharge)'}, 1, 5);
expected{end + 1} = 'pulsed load (rest)';
if ~strcmp(steps(1).comment, 'low current discharge at 0.04A') || ...
        ~isequal({steps(6:16).comment}, expected)
    error('NasaRW3:Source', 'The source is not the expected RW3 record.');
end

low = steps(1);
charge = cumtrapz(low.time(:), low.current(:)) / 3600;
capacity_Ah = charge(end);
indices = unique([1:6:numel(charge), numel(charge)]);
soc = flip(1 - charge(indices) / capacity_Ah);
voltage = cummax(flip(low.voltage(indices)));
soc = soc(:);
voltage = voltage(:);
writetable(table(soc, voltage, 'VariableNames', {'soc', 'voltage_V'}), ...
    fullfile(outputDirectory, names{3}));

prior_Ah = 0;
for index = 6:11
    prior_Ah = prior_Ah + trapz(steps(index).time(:), ...
        steps(index).current(:)) / 3600;
end
writeRecord(steps, 6:11, 0, 1, capacity_Ah, soc, voltage, ...
    fullfile(outputDirectory, names{1}));
writeRecord(steps, 12:16, 900, 1 - prior_Ah/capacity_Ah, ...
    capacity_Ah, soc, voltage, fullfile(outputDirectory, names{2}));
end

function writeRecord(steps, stepIndices, firstOffset, initialSoc, ...
    capacity_Ah, soc, voltage, outputFile)
rows = zeros(0, 3);
for index = stepIndices
    step = steps(index);
    first = 1;
    if index == stepIndices(1)
        first = first + firstOffset;
    end
    indices = unique([first:10:numel(step.time), numel(step.time)]);
    rows = [rows; step.time(indices(:)).', step.current(indices(:)).', ...
        step.voltage(indices(:)).']; %#ok<AGROW>
end
time_s = rows(:, 1) - rows(1, 1);
current_A = rows(:, 2);
terminal_voltage_V = rows(:, 3);
charge = [0; cumsum(current_A(1:end-1).*diff(time_s))] / 3600;
ocv_V = interp1(soc, voltage, initialSoc - charge/capacity_Ah, 'linear');
writetable(table(time_s, current_A, ocv_V, terminal_voltage_V), outputFile);
end
