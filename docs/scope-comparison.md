<!-- markdownlint-disable MD013 -->

# Reduced-Order MATLAB and Simulink Models Versus Higher-Fidelity Workflows

MATLAB Simulink Energy Lab favors small, inspectable models whose assumptions,
equations, commands, outputs, and regression boundaries can be reviewed
together. Higher fidelity is appropriate when omitted physics or implementation
details control the engineering decision.

## Comparison

| Workflow | Typical inputs | Typical outputs | Required products or resources | Evidence available here | Suitable use | Move beyond this lab when |
| --- | --- | --- | --- | --- | --- | --- |
| Reduced-order Base MATLAB | Lumped parameters, synthetic/prescribed profiles, initial states | SOC, terminal voltage, temperatures, power, ripple, sensitivities | Base MATLAB | Deterministic no-plot checks; selected analytical, held-out synthetic, energy-balance, and convergence checks | Teaching, method prototyping, transparent sensitivity studies | Spatial geometry, device physics, measured calibration, or project qualification controls the answer |
| Generated Simulink references | Same reduced-order parameters plus fixed-step block implementation | Block-diagram trajectories and MATLAB/Simulink parity | MATLAB and Simulink | Generated-model construction and implementation-consistency checks | Block-level learning, integration structure, solver/sample-time review | A physical network, production controller, generated code, or real-time scheduling must be qualified |
| Simscape or detailed multi-domain model | Component data, physical-network topology, parasitics, thermal/electrical coupling | Multi-domain state and energy flows | Relevant Simscape products and validated component data | Not provided | Physical-network integration and component interaction | Use it when lumped signal-flow assumptions hide decision-critical behavior |
| CFD or multidimensional thermal model | Geometry, mesh, anisotropic properties, flow boundaries, turbulence/contact assumptions | Local temperature, pressure, velocity, and heat-transfer fields | CFD toolchain, mesh study, compute resources, measured boundary data | Not provided | Cooling-channel, hot-spot, or geometry decisions | Use it when one-dimensional/lumped gradients cannot resolve the design question |
| Pack and hardware validation | Cell/pack samples, sensors, test plans, tolerances, protection settings, calibrated instrumentation | Measured performance, uncertainty, faults, protection response | Laboratory hardware, procedures, safety controls, traceable calibration | Not provided | Design verification and project evidence | Required for claims about a named cell, pack, converter, or installation |
| HIL or real-time controller validation | Production-like controller, I/O, plant emulator, timing/fault scenarios | Timing, interface, fault, and closed-loop response | Real-time target, I/O, HIL plant, acceptance criteria | Not provided | Controller integration and real-time behavior | Required when scheduling, interfaces, code generation, or fault handling must be accepted |
| Certification or grid-code qualification | Applicable standard, accredited procedures, project plant and protection data | Formal compliance evidence | Qualified organizations, tools, facilities, and controlled records | Explicitly outside scope | Regulatory or contractual acceptance | Always use the applicable formal process; repository checks are not qualification evidence |

## Fidelity Escalation Questions

Escalate beyond this lab if any answer is yes:

1. Does the decision depend on a named cell, pack, converter, or grid connection?
2. Are geometry, parasitics, switching devices, fluid flow, contact resistance,
   degradation, protection, or real-time scheduling decision-critical?
3. Must uncertainty be supported by measured calibration and independent test
   data rather than a synthetic benchmark?
4. Will the result support safety, procurement, warranty, certification,
   grid-code, or production-release acceptance?

If all answers are no, choose the smallest route in the
[decision-based model selector](model-selection-by-decision.md), run its check,
and preserve the nearest README's assumptions and limitations in any report.

## Evidence Boundary

The repository demonstrates deterministic behavior of reduced-order reference
implementations. Simulink parity is implementation consistency, synthetic
held-out testing is method evidence, and the focused BESS suite is transition
regression evidence. None independently establishes physical accuracy or
qualification.
