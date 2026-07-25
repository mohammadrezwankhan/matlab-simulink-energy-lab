# Contributing to MATLAB Simulink Energy Lab

Thank you for your interest in contributing! This project aims to maintain a transparent, highly inspectable, and reproducible collection of foundational energy-system modeling examples in MATLAB and Simulink.

---

## 🌟 How You Can Contribute

We welcome contributions across several areas:

- **New Reference Models**: First-order battery models, BESS charge/discharge controllers, averaged converter models, PWM switching simulations, or renewable grid interface blocks.
- **Measured Data Validation**: Real-world experimental data or benchmark parameters for battery cell RC parameters, converter duty cycles, or thermal dynamics.
- **Scripted Verification**: Automated checks (no-plot `.m` scripts) asserting model stability, numerical bounds, or energy conservation.
- **Documentation & Notes**: Improving parameter definitions, adding unit labels, or enhancing step-by-step educational explanations.

---

## 📋 Contribution Standards

To keep the repository clean and inspectable, all pull requests should adhere to these principles:

1. **Explicit Assumptions & Units**: State all physical constants, state variables, and units (e.g., Volts, Amperes, Seconds, Ohms, Farads) clearly at the top of parameter files.
2. **No-Plot Verification Scripts**: Provide a lightweight `check_<example_name>.m` script that validates model behavior headlessly using standard MATLAB `assert` statements.
3. **Product Requirements**: Clearly specify if an example requires standard MATLAB, Simscape, Simscape Electrical, or Control System Toolbox.
4. **Reproducibility**: Provide step-by-step instructions so any engineer or student can reproduce your simulation results in under 60 seconds.

---

## 🚀 Pull Request Checklist

Before submitting a PR, please verify:

- [ ] Model parameters and physical units are explicitly declared.
- [ ] The model includes a standalone `check_*.m` headless validation script.
- [ ] MATLAB version requirements and required toolboxes are documented.
- [ ] All code formatting follows standard MATLAB conventions.
- [ ] The `README.md` within the example directory includes expected output waveforms or summary tables.

---

## 💬 Opening an Issue

If you encounter a bug, have a feature request, or want to suggest a new modeling module, feel free to open a [GitHub Issue](https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab/issues).
