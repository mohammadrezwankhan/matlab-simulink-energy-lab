<!-- markdownlint-disable MD013 MD060 -->

# Battery 2RC Model Example

This runnable example extends the validated battery state pipeline with two
exact polarization branches: one fast and one slow.

## Engineering Question

How does a second RC branch separate short and long terminal-voltage recovery
after battery current pulses?

## Model Scope

| Element | Meaning |
|---|---|
| `OCV(SOC)` | Open-circuit voltage from the shared replaceable SOC/voltage lookup table |
| `R0` | Instantaneous ohmic resistance |
| `R1-C1` | Fast polarization branch with a default 1.8-second time constant |
| `R2-C2` | Slow polarization branch with a default 30-second time constant |
| `I_applied` | Requested current after the shared SOC-boundary limit |
| `Vt` | `OCV - I*R0 - Vrc1 - Vrc2` |

For each zero-order-held current interval and branch `k`, the simulator uses
the exact update:

```text
Vrc_k,next = exp(-dt / (Rk*Ck)) * Vrc_k
             + Rk * (1 - exp(-dt / (Rk*Ck))) * I_applied
```

The implementation calls the established one-RC simulator first, preserving
its profile validation, optional uniform resampling, OCV interpolation, SOC
charge balance, and boundary-current logic. It then propagates the second
branch from the same applied current and recomputes terminal voltage.

## Included MATLAB Files

```text
examples/battery-2rc-model/
  README.md
  battery_2rc_default_parameters.m
  simulate_battery_2rc_model.m
  run_battery_2rc_model.m
  check_battery_2rc_model.m
```

The example intentionally reuses
`../battery-rc-model/data/pulse_current_profile.csv` rather than duplicating
the canonical input.

The [native Simulink counterpart](../battery-2rc-simulink-model/README.md)
generates an inspectable block diagram and compares both numerical RC states
with this exact interval-update reference.

## How To Run

Open MATLAB, navigate to this folder, and run:

```matlab
run_battery_2rc_model
```

The plotting script shows current, SOC, terminal voltage, and both polarization
states. Run the no-plot validation with:

```matlab
check_battery_2rc_model
```

Expected output:

```text
Battery 2RC check passed. Final SOC: 0.767
Voltage range: 3.325 V to 3.925 V
Peak polarization: fast 0.075 V, slow 0.125 V
```

## Result Fields

The result preserves the shared one-RC fields except for the single
`v_rc_V` name, which becomes explicit two-branch output:

| Result Field | Meaning |
|---|---|
| `v_rc1_V` | Fast branch polarization voltage |
| `v_rc2_V` | Slow branch polarization voltage |
| `v_polarization_V` | Sum of both branch voltages |
| `branch_time_constants_s` | `[R1*C1, R2*C2]` for the configured branches |
| `terminal_voltage_V` | Recomputed voltage after both polarization drops |

The inherited `requested_current_A`, `current_A`, `current_limited`,
`interval_s`, `cumulative_net_discharge_Ah`, and
`soc_charge_balance_error` fields retain their one-RC meanings.

## Validation Coverage

The no-plot check verifies:

- finite voltage and bounded SOC over the canonical pulse profile;
- terminal-voltage and polarization-state balances;
- exact constant-current and irregular-interval updates for both branches;
- faster relaxation of the configured R1-C1 branch;
- equality of shared current, SOC, OCV, and first-branch states with the
  established one-RC simulator;
- inherited SOC-boundary current limiting; and
- malformed second-branch parameter rejection and deterministic reruns.

## Explicit Limitations

- Both branches begin from a rested zero-polarization state.
- Default parameters are illustrative and are not fitted to measured data.
- OCV hysteresis, ageing, self-discharge, temperature feedback, and
  cell-to-cell variation are excluded.
- The model is an equivalent-circuit teaching reference, not an
  electrochemical or pack-level design model.
- A second branch can improve transient shape but does not prove parameter
  identifiability; fit and cross-validate parameters against held-out pulse
  data before using the model for a specific cell.
