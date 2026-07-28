function [dAxis, qAxis] = bess_park_transform(alpha, beta, angle_rad)
%BESS_PARK_TRANSFORM Rotate alpha-beta quantities into a dq frame.

validateattributes(alpha, {'numeric'}, {'real', 'finite', ...
    'size', size(beta)});
validateattributes(angle_rad, {'numeric'}, {'real', 'finite', ...
    'size', size(beta)});
dAxis = alpha .* cos(angle_rad) + beta .* sin(angle_rad);
qAxis = -alpha .* sin(angle_rad) + beta .* cos(angle_rad);
end
