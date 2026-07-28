function profile = bess_scenario_profile(scenario)
%BESS_SCENARIO_PROFILE Pack all scenario inputs for From Workspace.

sampleCount = numel(scenario.time_s);
profile = zeros(sampleCount, 16);
for sampleIndex = 1:sampleCount
    profile(sampleIndex, :) = ...
        bess_scenario_input_vector(scenario, sampleIndex)';
end
end
