function containsSequence = bess_state_sequence_contains(stateCodes, sequence)
%BESS_STATE_SEQUENCE_CONTAINS Check ordered occurrence without contiguity.

validateattributes(stateCodes, {'numeric'}, ...
    {'real', 'finite', 'vector'});
validateattributes(sequence, {'numeric'}, ...
    {'real', 'finite', 'vector'});
sequenceIndex = 1;
for sampleIndex = 1:numel(stateCodes)
    if stateCodes(sampleIndex) == sequence(sequenceIndex)
        sequenceIndex = sequenceIndex + 1;
        if sequenceIndex > numel(sequence)
            containsSequence = true;
            return;
        end
    end
end
containsSequence = false;
end
