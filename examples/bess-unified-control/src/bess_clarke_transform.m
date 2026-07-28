function [alpha, beta, zero] = bess_clarke_transform(a, b, c)
%BESS_CLARKE_TRANSFORM Amplitude-invariant abc-to-alpha-beta-zero transform.

validateattributes(a, {'numeric'}, {'real', 'finite', 'size', size(b)});
validateattributes(c, {'numeric'}, {'real', 'finite', 'size', size(b)});
alpha = (2 / 3) .* (a - 0.5 .* b - 0.5 .* c);
beta = (2 / 3) .* (sqrt(3) / 2) .* (b - c);
zero = (a + b + c) ./ 3;
end
