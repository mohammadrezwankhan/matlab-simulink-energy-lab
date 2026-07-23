function fitResult = fit_battery_2rc_parameters(data, baseParameters)
%FIT_BATTERY_2RC_PARAMETERS Fit positive two-RC parameters to voltage data.
% data must be a table with time_s, current_A, ocv_V, and
% terminal_voltage_V. The fit assumes rested RC states at the first sample.
% baseParameters supplies the non-fitted battery parameters and receives the
% fitted r0_Ohm, r1_Ohm, c1_F, r2_Ohm, and c2_F values.

requiredVariables = {
    'time_s';
    'current_A';
    'ocv_V';
    'terminal_voltage_V'
};
if ~istable(data) || ...
        ~all(ismember(requiredVariables, data.Properties.VariableNames))
    error('Battery2RCFit:Data', ...
        ['Data must be a table containing time_s, current_A, ocv_V, ', ...
        'and terminal_voltage_V.']);
end

time_s = validateDataColumn(data.time_s, 'time_s');
current_A = validateDataColumn(data.current_A, 'current_A');
ocv_V = validateDataColumn(data.ocv_V, 'ocv_V');
terminalVoltage_V = validateDataColumn( ...
    data.terminal_voltage_V, 'terminal_voltage_V');
sampleCount = numel(time_s);
if any([numel(current_A), numel(ocv_V), numel(terminalVoltage_V)] ~= ...
        sampleCount) || sampleCount < 20
    error('Battery2RCFit:Data', ...
        'All data columns must have the same length and at least 20 samples.');
end

interval_s = diff(time_s);
if any(interval_s <= 0)
    error('Battery2RCFit:Time', ...
        'time_s must be strictly increasing.');
end
if (max(current_A) - min(current_A)) <= 1e-6 || ...
        nnz(abs(diff(current_A)) > 1e-9) < 3
    error('Battery2RCFit:Excitation', ...
        'Current data must contain at least three informative transitions.');
end

validateBaseParameters(baseParameters);
voltageDrop_V = ocv_V - terminalVoltage_V;
duration_s = time_s(end) - time_s(1);
minimumTau_s = max(0.1*min(interval_s), 0.05);
maximumTau_s = 0.5*duration_s;
if maximumTau_s <= 4*minimumTau_s
    error('Battery2RCFit:Duration', ...
        'The record is too short to separate two RC time constants.');
end

gridSize = 36;
refinementPasses = 3;
minimumSeparationRatio = 1.5;
coarseGrid_s = logspace( ...
    log10(minimumTau_s), log10(maximumTau_s), gridSize);
bestFit = emptyBestFit();
[bestFit, candidateCount] = searchTimeConstantGrid( ...
    coarseGrid_s, coarseGrid_s, current_A, interval_s, ...
    voltageDrop_V, minimumSeparationRatio, bestFit);

if ~isfinite(bestFit.rmse_V)
    error('Battery2RCFit:Identifiability', ...
        ['No positive, numerically identifiable two-RC fit was found. ', ...
        'Use a pulse-rich record with an independently estimated OCV.']);
end

for refinementIndex = 1:refinementPasses
    fastGrid_s = localLogGrid( ...
        bestFit.tau1_s, minimumTau_s, maximumTau_s, 18);
    slowGrid_s = localLogGrid( ...
        bestFit.tau2_s, minimumTau_s, maximumTau_s, 18);
    [bestFit, refinementCount] = searchTimeConstantGrid( ...
        fastGrid_s, slowGrid_s, current_A, interval_s, ...
        voltageDrop_V, minimumSeparationRatio, bestFit);
    candidateCount = candidateCount + refinementCount;
end

estimatedParameters = baseParameters;
estimatedParameters.r0_Ohm = bestFit.resistance_Ohm(1);
estimatedParameters.r1_Ohm = bestFit.resistance_Ohm(2);
estimatedParameters.c1_F = bestFit.tau1_s / ...
    estimatedParameters.r1_Ohm;
estimatedParameters.r2_Ohm = bestFit.resistance_Ohm(3);
estimatedParameters.c2_F = bestFit.tau2_s / ...
    estimatedParameters.r2_Ohm;

predictedVoltage_V = ocv_V - ...
    bestFit.designMatrix*bestFit.resistance_Ohm;
residual_V = terminalVoltage_V - predictedVoltage_V;
residualSumSquares = sum(residual_V.^2);
totalSumSquares = sum((terminalVoltage_V - ...
    mean(terminalVoltage_V)).^2);
if totalSumSquares > eps
    rSquared = 1 - residualSumSquares/totalSumSquares;
else
    rSquared = NaN;
end
metrics = struct( ...
    'rmse_V', sqrt(mean(residual_V.^2)), ...
    'mae_V', mean(abs(residual_V)), ...
    'maximum_absolute_error_V', max(abs(residual_V)), ...
    'r_squared', rSquared, ...
    'design_condition_number', cond(bestFit.designMatrix));
searchSummary = struct( ...
    'candidate_count', candidateCount, ...
    'initial_time_constant_bounds_s', ...
        [minimumTau_s, maximumTau_s], ...
    'grid_size', gridSize, ...
    'refinement_passes', refinementPasses, ...
    'minimum_separation_ratio', minimumSeparationRatio);
fitResult = struct( ...
    'parameters', estimatedParameters, ...
    'time_s', time_s, ...
    'measured_terminal_voltage_V', terminalVoltage_V, ...
    'predicted_terminal_voltage_V', predictedVoltage_V, ...
    'residual_V', residual_V, ...
    'estimated_time_constants_s', ...
        [bestFit.tau1_s, bestFit.tau2_s], ...
    'metrics', metrics, ...
    'search', searchSummary);
end

function values = validateDataColumn(values, variableName)
if ~isnumeric(values) || ~isvector(values)
    error('Battery2RCFit:Data', ...
        '%s must be a numeric vector.', variableName);
end
values = values(:);
if any(~isfinite(values))
    error('Battery2RCFit:Data', ...
        '%s must contain only finite values.', variableName);
end
end

function validateBaseParameters(parameters)
requiredParameters = {
    'r0_Ohm';
    'r1_Ohm';
    'c1_F';
    'r2_Ohm';
    'c2_F'
};
if ~isstruct(parameters) || ...
        ~all(isfield(parameters, requiredParameters))
    error('Battery2RCFit:Parameters', ...
        ['baseParameters must contain r0_Ohm, r1_Ohm, c1_F, ', ...
        'r2_Ohm, and c2_F.']);
end
for parameterIndex = 1:numel(requiredParameters)
    parameterValue = parameters.(requiredParameters{parameterIndex});
    if ~isnumeric(parameterValue) || ~isscalar(parameterValue) || ...
            ~isfinite(parameterValue) || parameterValue <= 0
        error('Battery2RCFit:Parameters', ...
            'All fitted base parameters must be finite positive scalars.');
    end
end
end

function bestFit = emptyBestFit()
bestFit = struct( ...
    'rmse_V', Inf, ...
    'tau1_s', NaN, ...
    'tau2_s', NaN, ...
    'resistance_Ohm', NaN(3, 1), ...
    'designMatrix', NaN(1, 3));
end

function grid_s = localLogGrid(center_s, lowerBound_s, upperBound_s, count)
localLower_s = max(lowerBound_s, center_s/2);
localUpper_s = min(upperBound_s, center_s*2);
grid_s = logspace(log10(localLower_s), log10(localUpper_s), count);
end

function [bestFit, candidateCount] = searchTimeConstantGrid( ...
        fastGrid_s, slowGrid_s, current_A, interval_s, voltageDrop_V, ...
        minimumSeparationRatio, bestFit)
candidateCount = 0;
minimumResistance_Ohm = 1e-7;
maximumResistance_Ohm = 0.5;
minimumReciprocalCondition = 1e-12;

fastBases = cell(numel(fastGrid_s), 1);
for fastIndex = 1:numel(fastGrid_s)
    fastBases{fastIndex} = buildPolarizationBasis( ...
        current_A, interval_s, fastGrid_s(fastIndex));
end
slowBases = cell(numel(slowGrid_s), 1);
for slowIndex = 1:numel(slowGrid_s)
    slowBases{slowIndex} = buildPolarizationBasis( ...
        current_A, interval_s, slowGrid_s(slowIndex));
end

for fastIndex = 1:numel(fastGrid_s)
    tau1_s = fastGrid_s(fastIndex);
    for slowIndex = 1:numel(slowGrid_s)
        tau2_s = slowGrid_s(slowIndex);
        if tau2_s < minimumSeparationRatio*tau1_s
            continue;
        end
        candidateCount = candidateCount + 1;
        designMatrix = [
            current_A, ...
            fastBases{fastIndex}, ...
            slowBases{slowIndex}
        ];
        if rcond(designMatrix.'*designMatrix) < ...
                minimumReciprocalCondition
            continue;
        end
        resistance_Ohm = designMatrix\voltageDrop_V;
        if any(~isfinite(resistance_Ohm)) || ...
                any(resistance_Ohm <= minimumResistance_Ohm) || ...
                any(resistance_Ohm >= maximumResistance_Ohm)
            continue;
        end
        residual_V = voltageDrop_V - designMatrix*resistance_Ohm;
        rmse_V = sqrt(mean(residual_V.^2));
        if rmse_V < bestFit.rmse_V
            bestFit = struct( ...
                'rmse_V', rmse_V, ...
                'tau1_s', tau1_s, ...
                'tau2_s', tau2_s, ...
                'resistance_Ohm', resistance_Ohm, ...
                'designMatrix', designMatrix);
        end
    end
end
end

function basis_A = buildPolarizationBasis(current_A, interval_s, tau_s)
basis_A = zeros(size(current_A));
for intervalIndex = 1:numel(interval_s)
    decayFactor = exp(-interval_s(intervalIndex)/tau_s);
    basis_A(intervalIndex + 1) = ...
        decayFactor*basis_A(intervalIndex) + ...
        (1 - decayFactor)*current_A(intervalIndex);
end
end
