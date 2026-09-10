# Limitations, Safety, and Qualification

This implementation is a transparent research translation and educational
starter. It is not a qualified controller, protection relay, grid-code
compliance model, or safety case.

## Publication boundary

The paper supplies architectural concepts and qualitative cases but omits
material equations, gains, plant data, sample/switching settings, initial
conditions, transition rules, synchronization windows, limits, and numeric
acceptance criteria. It also says islanding and reconnection are future work.
Consequently, this project does not claim exact paper reproduction or
paper-validated transitions.

The paper's low-voltage ride-through discussion includes a 0% dip and recovery
above 50% in 150 ms. This example retains that historical source statement but
does not present it as current French or any other grid-code certification.

## Model omissions

- switching harmonics, PWM delay, dead time, semiconductor loss, and thermal
  limits;
- detailed L/LCL filter, transformer, cable, grid impedance, and resonance;
- converter inner current/voltage-loop electromagnetic states;
- DC/DC converter, DC-link capacitor, battery electrochemistry, SOC, reserve,
  ageing, and thermal dynamics;
- unbalance, zero sequence, negative sequence, harmonics, and phase faults;
- protection coordination, breaker arc/timing, grounding, and fault current;
- communications, scheduling, cybersecurity, redundant sensors, and real-time
  task jitter;
- black-start sequencing and multi-inverter power sharing;
- the paper's separate VSG swing equation, inertia, AVR, and governor branch;
- hardware, controller-code-generation, SIL/PIL/HIL, and site commissioning;
  and
- plant, protection, or grid-code qualification.

## Sample-time labeling

The current MATLAB runner and Simulink runtime both compute a controller
command, advance the plant by one configured sample interval, and then record
the result at the current input timestamp. This includes the sample labeled
zero and the terminal sample. With the default 5 ms step, the time-zero output
is therefore already a plant update, not the untouched initial state. For N
input samples, the runners perform N plant updates rather than the N - 1
intervals between those timestamps.

The relevant source is
[`simulate_bess_unified_control.m`](../simulate_bess_unified_control.m),
[`bess_simulink_runtime.m`](../src/bess_simulink_runtime.m), and
[`bess_plant_step.m`](../src/bess_plant_step.m). Agreement between the two
runners cannot detect this shared timing convention. Do not interpret their
parity checks or historical plots as independent validation of initial-state,
event-response, or total-duration timing.

Do not repair this by shifting the plotted time vector alone: the
[`controller`](../src/bess_controller_step.m) also contains a one-step grid
phase adjustment, timer updates, and sampled command limits. A behavioral
correction needs a consistent input/command/state timing contract and
independent tests for initialization, event boundaries, and final integration
duration in both execution paths. Historical validation artifacts retain
their original source provenance; this disclosure does not regenerate or
revalidate them.

## Required qualification before engineering use

A real deployment must replace every `PROJECT_ASSUMPTION`, use plant and
network models of appropriate fidelity, verify applicable interconnection
rules and protection, perform stability and fault studies over the full
operating envelope, validate generated code and hardware timing, and complete
independent safety, cybersecurity, HIL, commissioning, and operator reviews.
