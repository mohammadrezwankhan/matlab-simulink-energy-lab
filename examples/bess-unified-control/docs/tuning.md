# Tuning and Parameter Replacement

All tunable values live in `bess_unified_control_parameters.m`; callers can
provide a scalar override structure. Unknown fields, nonfinite values,
nonpositive time constants, invalid ranges, and a sample time not smaller than
the plant time constants are rejected.

## Recommended replacement order

1. Replace rated MVA, line voltage, nominal frequency, P/Q capability, current
   limit, DC-voltage range, and available-power policy with project values.
2. Replace the averaged plant time constants with a validated converter,
   filter, transformer, and network model or identified equivalent.
3. Select sample time from the real control platform and revalidate every
   timer and slew limit.
4. Tune P-f and Q-V droop against network strength, reserve, load range, and
   applicable grid requirements.
5. Tune restoration gains well below the primary-forming response bandwidth.
6. Establish synchronization thresholds, hold time, and breaker timing with
   the actual protection and switching equipment.
7. Replace fault codes and validity ranges with real measurement diagnostics.
8. Re-run unit, model-build, parity, scenario, and project-specific tests.

## Starter values

| Group | Parameter | Default |
| --- | --- | ---: |
| Ratings | `rated_power_VA` | 10e6 VA |
| Ratings | `nominal_line_voltage_V` | 690 V |
| Timing | `sample_time_s` | 0.005 s |
| Limits | `current_limit_pu` | 1.00 p.u. |
| Limits | `active_power_limit_pu` | 1.00 p.u. |
| Limits | `reactive_power_limit_pu` | 0.80 p.u. |
| Plant | `filter_current_time_constant_s` | 0.040 s |
| Plant | `plant_voltage_time_constant_s` | 0.050 s |
| Plant | `plant_frequency_time_constant_s` | 0.050 s |
| Droop | `grid_frequency_droop_Hz_per_pu` | 0.50 Hz/p.u. |
| Droop | `grid_voltage_droop_pu_per_pu` | 0.050 p.u./p.u. |
| Restore | `frequency_restoration_gain_per_s` | 3.0 1/s |
| Restore | `voltage_restoration_gain_per_s` | 3.0 1/s |
| Sync | `sync_phase_gain_Hz_per_rad` | 0.80 Hz/rad |
| Sync | `sync_hold_time_s` | 0.10 s |
| Slew | `power_command_slew_pu_per_s` | 5.0 p.u./s |

These values produce a readable deterministic example. They are not vendor,
plant, stability-study, protection, or grid-code settings.

## Sensitivity and boundaries

Scenario F stresses the combined P/Q current boundary and confirms recovery.
Scenario H limits DC-side active-power availability to 0.2 p.u., exercises zero
and maximum references, adds bounded measurement bias, and confirms the
command cannot exceed available power. Parameter unit tests reject unknown or
inconsistent configurations.
