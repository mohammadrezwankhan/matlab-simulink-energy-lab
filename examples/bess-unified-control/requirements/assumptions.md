# Project Assumptions

The identifiers in this register are stable. Numerical values live in the
central parameter function and are repeated here only after validation.

## `PROJECT_ASSUMPTION:ASM-001` — averaged plant fidelity

The publication states that its BESS is represented as an ideal power source
and does not capture converter-grid dynamic interactions. This example uses a
deterministic reduced-order, averaged three-phase converter/PCC plant with
explicit d/q current states and a current-control/filter equivalent so
controller behavior can be exercised without claiming switching or
hardware-fidelity validation.

The averaged model must preserve:

- balanced three-phase voltage and current measurements;
- active/reactive power and RMS current relationships;
- finite current-limited dynamics;
- a stiff-grid branch when the breaker is closed; and
- voltage/frequency-forming behavior with a local load when it is open.

It intentionally omits PWM, switching harmonics, semiconductor loss,
protection coordination, transformer saturation, detailed DC/DC control, and
electrochemical battery dynamics.

## `PROJECT_ASSUMPTION:ASM-002` — transition state machine

The publication's conclusion lists planned/unplanned islanding and main-grid
reconnection as future work. The eight-state supervisor is therefore a
reviewable engineering extension, not a paper reproduction. Preparation and
hold times are centralized parameters. The breaker opens immediately on grid
loss or invalid measurement and cannot reclose without the full
synchronization guard.

## `PROJECT_ASSUMPTION:ASM-003` — acceptance thresholds

Where the publication is silent, this example uses the goal-defined fallback
criteria:

- 2% rated P/Q steady-state error;
- 2% nominal grid-forming voltage error;
- 0.1% nominal grid-forming frequency error;
- 0.85 to 1.15 p.u. voltage and 98% to 102% nominal frequency during normal
  transitions;
- 1% numerical tolerance above the configured hard current limit; and
- 5% voltage, 0.1 Hz frequency, and 5 degree phase mismatch before breaker
  closure.

Changing these thresholds requires an engineering justification, an updated
before/after record, tests, and independent review.

## `PROJECT_ASSUMPTION:ASM-004` — starter ratings and tuning

The publication reports 10 MW, 8 MW, and positive/negative 4 MVar cases but
also shows 8 MW/2 Mvar figure cases and contains conflicting table labels and
units. It does not publish the complete reusable parameter set. The executable example
therefore uses replaceable educational starter ratings centered on a 10 MVA,
690 V line-to-line, 50 Hz system. Controller bandwidths, droop slopes,
restoration gains, measurement thresholds, and DC availability limits are
centralized and validated.

The values are not plant, vendor, or grid-code settings. A real project must
replace and revalidate every starter value against converter capability,
battery/DC limits, protection, transformer, network, and applicable grid-code
requirements.

## Sign convention

Positive active power means discharge/injection from the BESS converter into
the PCC. Positive reactive power means inductive reactive-power injection by
the convention documented in the executable transforms. Charging is negative
active power. The paper's qualitative charge/discharge table labels are not
used to infer a missing sign convention.

## Source replacement rule

Any later authorized source that supplies a missing equation or parameter must
replace the corresponding assumption at the central parameter or equation
definition. The source ledger, traceability matrix, affected tests, and
validation report must change in the same commit.
