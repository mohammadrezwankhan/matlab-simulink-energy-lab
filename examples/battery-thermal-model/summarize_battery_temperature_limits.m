function summary = summarize_battery_temperature_limits(result, limits_C)
%SUMMARIZE_BATTERY_TEMPERATURE_LIMITS Assess piecewise-linear limit exposure.
% The reported temperature states define the interpolation path. A sample
% exactly on a limit is not counted as an exceedance.

requiredFields = {'time_s'; 'cell_temp_C'};
if ~isstruct(result) || ~all(isfield(result, requiredFields))
    error('BatteryThermalLimits:ResultFields', ...
        'Result must contain time_s and cell_temp_C.');
end

time_s = validated_vector(result.time_s, 'time_s');
cellTemp_C = validated_vector(result.cell_temp_C, 'cell_temp_C');
if numel(time_s) < 2 || numel(cellTemp_C) ~= numel(time_s)
    error('BatteryThermalLimits:SignalShape', ...
        'Time and temperature must have equal lengths and at least two samples.');
end
if any(diff(time_s) <= 0)
    error('BatteryThermalLimits:TimeOrder', ...
        'time_s must be strictly increasing.');
end
if any(cellTemp_C <= -273.15)
    error('BatteryThermalLimits:TemperatureBounds', ...
        'cell_temp_C must remain above absolute zero.');
end

if ~isnumeric(limits_C) || ~isvector(limits_C) || isempty(limits_C) || ...
        ~isreal(limits_C) || any(~isfinite(limits_C))
    error('BatteryThermalLimits:Limits', ...
        'limits_C must be a nonempty finite real numeric vector.');
end
limits_C = limits_C(:);
if any(limits_C <= -273.15)
    error('BatteryThermalLimits:LimitBounds', ...
        'Every temperature limit must be above absolute zero.');
end
if numel(unique(limits_C)) ~= numel(limits_C)
    error('BatteryThermalLimits:UniqueLimits', ...
        'Temperature limits must be unique.');
end

limitCount = numel(limits_C);
firstExceedanceTime_s = nan(limitCount, 1);
timeAboveLimit_s = zeros(limitCount, 1);
for limitIndex = 1:limitCount
    limit_C = limits_C(limitIndex);
    if cellTemp_C(1) > limit_C
        firstExceedanceTime_s(limitIndex) = time_s(1);
    end

    for intervalIndex = 1:(numel(time_s) - 1)
        startTime_s = time_s(intervalIndex);
        endTime_s = time_s(intervalIndex + 1);
        startTemp_C = cellTemp_C(intervalIndex);
        endTemp_C = cellTemp_C(intervalIndex + 1);
        intervalDuration_s = endTime_s - startTime_s;
        startAbove = startTemp_C > limit_C;
        endAbove = endTemp_C > limit_C;

        if startAbove && endAbove
            timeAboveLimit_s(limitIndex) = ...
                timeAboveLimit_s(limitIndex) + intervalDuration_s;
            if isnan(firstExceedanceTime_s(limitIndex))
                firstExceedanceTime_s(limitIndex) = startTime_s;
            end
        elseif startAbove ~= endAbove
            crossingFraction = ...
                (limit_C - startTemp_C) / (endTemp_C - startTemp_C);
            crossingTime_s = startTime_s + ...
                crossingFraction * intervalDuration_s;
            if endAbove
                timeAboveLimit_s(limitIndex) = ...
                    timeAboveLimit_s(limitIndex) + ...
                    endTime_s - crossingTime_s;
                if isnan(firstExceedanceTime_s(limitIndex))
                    firstExceedanceTime_s(limitIndex) = crossingTime_s;
                end
            else
                timeAboveLimit_s(limitIndex) = ...
                    timeAboveLimit_s(limitIndex) + ...
                    crossingTime_s - startTime_s;
                if isnan(firstExceedanceTime_s(limitIndex))
                    firstExceedanceTime_s(limitIndex) = startTime_s;
                end
            end
        end
    end
end

duration_s = time_s(end) - time_s(1);
peakTemperature_C = max(cellTemp_C);
exceeded = ~isnan(firstExceedanceTime_s);
exposureFraction = timeAboveLimit_s / duration_s;
summary = table(...
    limits_C, exceeded, firstExceedanceTime_s, timeAboveLimit_s, ...
    exposureFraction, repmat(peakTemperature_C, limitCount, 1), ...
    limits_C - peakTemperature_C, ...
    'VariableNames', {
        'limit_temperature_C';
        'exceeded';
        'first_exceedance_time_s';
        'time_above_limit_s';
        'exposure_fraction';
        'peak_temperature_C';
        'margin_to_limit_C'
    });
end

function values = validated_vector(value, fieldName)
if ~isnumeric(value) || ~isvector(value) || ~isreal(value) || ...
        any(~isfinite(value))
    error('BatteryThermalLimits:Signals', ...
        '%s must be a finite real numeric vector.', fieldName);
end
values = value(:);
end
