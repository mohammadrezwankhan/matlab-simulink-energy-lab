# Sample timing contract

The runners record plant state at the input timestamp, before integrating
the command selected at that timestamp. Command `c_k` is held over
`[t_k, t_(k+1))`. A profile with N samples therefore advances the plant over
N - 1 intervals, with no extra update after the terminal sample.

At the first sample, controller elapsed time is zero. Dynamic initialization
is observable without initial timer, restoration, or slew credit. At later
boundaries, grid loss and measurement faults can open the breaker without a
further dynamic update. Connected phase is aligned with the current grid
phase; the preceding interval still advances phase if the grid disconnects
at its endpoint.

Synchronization hold time accumulates only when readiness is true at both
sampled boundaries. This is a sampled guard, not proof of continuous-time
readiness between samples. Identical repeated runtime calls return the same
cached sample without advancing plant or controller state.

The controller and plant helpers accept an explicit elapsed-time argument.
Four-argument direct calls retain the configured-step duration; the plant's
four-argument phase convention remains historical. The runners use explicit
elapsed times and do not use that legacy phase convention.

`TestBessSampleTiming.m` contains independent timing assertions in addition
to the existing runner-parity tests. The focused check script discovers both
test classes. Test source alone is not proof of a passing execution; use
commit-specific CI results. Historical validation artifacts describe their
original source and are not silently reinterpreted under this contract.

The Simulink wrapper's separate logged-time validation and preloaded-model
ownership limitations are not corrected by this interval-order change.
