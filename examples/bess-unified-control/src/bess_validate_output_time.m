function bess_validate_output_time(loggedTime, expectedTime)
%BESS_VALIDATE_OUTPUT_TIME Reject logged clocks that cannot label scenario rows.
% Both clocks must be nonempty, finite, real double vectors in strictly
% increasing order, with equal lengths and corresponding times within
% 1e-12 seconds. Row and column orientation is immaterial. The tolerance
% matches the runners' fixed-grid clock-roundoff allowance, not a resampling
% allowance. This function neither interpolates nor repairs logged output.
% Single and integer clocks are unsupported: silent conversion can obscure
% precision differences. The generated scenario/profile clock uses doubles.

if ~valid_clock(loggedTime) || ~valid_clock(expectedTime)
    error('BessUnifiedControl:ModelOutputTime', ...
        'Logged and expected times must be finite, strictly increasing double vectors.');
end
if numel(loggedTime) ~= numel(expectedTime) || ...
        any(abs(loggedTime(:) - expectedTime(:)) > 1e-12)
    error('BessUnifiedControl:ModelOutputTime', ...
        'Logged output timestamps do not match the scenario timestamps.');
end
end

function valid = valid_clock(value)
valid = isa(value, 'double') && isreal(value) && isvector(value) && ...
    ~isempty(value) && all(isfinite(value(:))) && ...
    all(diff(value(:)) > 0);
end
