<!-- markdownlint-disable MD013 -->

# Model Selection by Engineering Decision

Choose the smallest model that can answer the decision you actually need to
make. The examples are reduced-order references with synthetic or illustrative
inputs; none is a substitute for physical-cell, hardware, safety,
certification, or grid-code qualification.

## Decision Table

| Decision | Start with | Inputs | Outputs | Required products | Evidence level | Suitable use | Unsuitable use |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Teach battery voltage and SOC dynamics | [First-order RC battery](../examples/battery-rc-model/README.md) | Current profile, ECM parameters, initial SOC | Terminal voltage, SOC, polarization voltage | Base MATLAB | Deterministic synthetic regression | Classroom exercise or first simulation | Cell identification or safety limits |
| Study two battery time constants | [Two-RC battery](../examples/battery-2rc-model/README.md) | Pulse current, OCV relation, two RC branches | Voltage response and fast/slow polarization | Base MATLAB | Synthetic calibration and held-out evaluation | Thesis method development or estimator plant | Physical-cell accuracy claim |
| Estimate SOC from noisy measurements | [SOC EKF](../examples/battery-soc-ekf/README.md) | Current, voltage, covariance assumptions | SOC estimate, residuals, consistency metrics | Base MATLAB | Synthetic estimator regression and prescribed bias sensitivity | EKF learning, algorithm comparison, sensitivity study | BMS qualification or proven sensor-bias rejection |
| Compare battery thermal-management concepts | [Thermal routes](model-selection-guide.md#i-need-a-battery-thermal-model) | Heat generation, thermal properties, cooling boundaries | Cell, module, coolant, or through-thickness temperatures | Base MATLAB; Simulink for the generated companion | Reduced-order energy-balance, analytical, and convergence checks | Early thermal reasoning, classroom work, bounded sensitivity | CFD, abuse safety, detailed pack or channel design |
| Learn converter averaging, switching, or control | [Buck-converter routes](model-selection-guide.md#i-need-a-buck-converter-model) | Source, load, switching/control parameters | Voltage, current, ripple, settling, illustrative losses | Base MATLAB; Simulink for generated companions | Deterministic numerical and parity checks | First simulation, controller comparison, teaching | Device qualification, EMI, SOA, hardware efficiency guarantee |
| Explore BESS reserve constraints | [BESS DC reserve](../examples/bess-dc-reserve-model/README.md) | SOC, reserve bounds, current capability, DC-link state | Requested, delivered, curtailed, and battery power | Base MATLAB | Synthetic DC-side operating-envelope regression | Supervisory logic and sensitivity studies | Closed-loop battery-to-grid integration |
| Study grid-forming/grid-following BESS transitions | [Unified BESS control](../examples/bess-unified-control/README.md) | Project-defined plant, limits, events, and controller parameters | Modes, P/Q, voltage, frequency, current, synchronization, recovery | MATLAB and Simulink | 31 focused regression results across eight scenarios | Controller architecture, requirements, traceability, transition learning | Grid-code certification, protection coordination, hardware control release |

## Routes by Context

### First simulation

Use the first-order RC battery or averaged buck converter. Both minimize state,
dependency, and runtime complexity while keeping equations and expected output
visible.

### Classroom

Select one model family and require students to change a bounded parameter,
predict the response, run the nearest no-plot check, and explain why the
result does not establish physical validation.

### Thesis or research-method development

Start with the two-RC identification, SOC EKF, pouch-cell thermal-gradient, or
unified-BESS workflow when the contribution concerns method, sensitivity,
traceability, or reproducibility. Replace synthetic inputs only after recording
data provenance, calibration/held-out separation, units, and limitations.

### Engineering study

Use these models for transparent early-stage reasoning only when the decision
fits their stated boundary. Move to the higher-fidelity route described in the
[scope comparison](scope-comparison.md) when geometry, switching devices,
multi-domain physics, hardware timing, safety, or qualification determines the
decision.

## Reproduce the Evidence

From the repository root:

```matlab
addpath('examples')
run_all_checks
```

See [validation results](validation-results.md) for the exact environment,
expected output, source commit, and hosted run.
