function states = bess_state_codes()
%BESS_STATE_CODES Stable numeric codes used by the executable supervisor.

states.GRID_FOLLOWING = 1;
states.PREPARE_ISLAND = 2;
states.GRID_FORMING = 3;
states.ISLANDED_SUPPORT = 4;
states.SYNCHRONIZING = 5;
states.PREPARE_RECONNECT = 6;
states.RECOVERY = 7;
states.FAULT_SAFE = 8;
end
