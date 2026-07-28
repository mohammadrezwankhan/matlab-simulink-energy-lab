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

## Required qualification before engineering use

A real deployment must replace every `PROJECT_ASSUMPTION`, use plant and
network models of appropriate fidelity, verify applicable interconnection
rules and protection, perform stability and fault studies over the full
operating envelope, validate generated code and hardware timing, and complete
independent safety, cybersecurity, HIL, commissioning, and operator reviews.
