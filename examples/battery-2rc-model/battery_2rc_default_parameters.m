function parameters = battery_2rc_default_parameters()
%BATTERY_2RC_DEFAULT_PARAMETERS Return educational two-RC parameters.

modelDirectory = fileparts(mfilename('fullpath'));
baseModelDirectory = fullfile(fileparts(modelDirectory), 'battery-rc-model');
originalPath = path;
pathCleanup = onCleanup(@() path(originalPath));
addpath(baseModelDirectory);

parameters = battery_rc_default_parameters();
parameters.r1_Ohm = 0.0015;
parameters.c1_F = 1200;
parameters.r2_Ohm = 0.0025;
parameters.c2_F = 12000;
end
