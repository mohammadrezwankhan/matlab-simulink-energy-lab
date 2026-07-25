<!-- markdownlint-disable MD013 -->

# ⚡ MATLAB Simulink Energy Lab

[![Markdown maintenance](https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab/actions/workflows/markdown-maintenance.yml/badge.svg)](https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab/actions/workflows/markdown-maintenance.yml)
![MATLAB R2026a](https://img.shields.io/badge/verified-MATLAB%20R2026a-e86e25.svg)
[![License: MIT](https://img.shields.io/badge/license-MIT-2f6f5e.svg)](LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/mohammadrezwankhan/matlab-simulink-energy-lab?style=social)](https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab)

> **Inspect every parameter, trace every equation into waveforms, and build robust energy-system models with confidence.**

**MATLAB Simulink Energy Lab** is an open-source, highly inspectable engineering library of runnable models for **battery systems**, **Battery Energy Storage Systems (BESS)**, and **power electronics converters**. Designed for students, researchers, and power electronics engineers, every model in this lab emphasizes physical clarity, unit consistency, and automated headless verification.

---

> [!TIP]
> **If this laboratory saves you setup time or helps your research, please leave a ⭐ star on GitHub!**
> Starred feedback directly guides which open-source energy models (e.g., closed-loop BESS controllers, thermal battery models) are developed next.

---

![First-order battery RC model response showing discharge and charge current pulses, state-of-charge change, and terminal-voltage transients](assets/battery-rc-response.png)

---

## 🔋 Summary of Included Models

| Model Module | Category | Focus & Engineering Challenge | Verification Check | Toolbox Dependencies |
| --- | --- | --- | --- | --- |
| **[Battery RC Equivalent Model](examples/battery-rc-model/README.md)** | Battery Systems / BESS | First-order RC transient response, State-of-Charge (SOC) tracking, Open-Circuit Voltage (OCV) dynamics under pulse loading. | `check_battery_rc_model.m` | Base MATLAB |
| **[Averaged Converter Model](examples/converter-average-model/README.md)** | Power Electronics | Duty-cycle math, DC-DC converter state equations, voltage ripple estimation, and load current dynamics. | `check_converter_average_model.m` | Base MATLAB |

*Upcoming roadmap additions include native Simulink (`.slx`) switching blocks, closed-loop PID power converters, and multi-cell BESS balancing models.*

---

## 🛠️ System Requirements & Dependencies

- **MATLAB Release**: Verified on **MATLAB R2026a** (Compatible with MATLAB R2020b and newer).
- **Core Requirements**: Base MATLAB is sufficient for standard parameter initialization and headless execution scripts.
- **Optional Toolboxes** (for extended `.slx` and Simscape modules):
  - **Simulink**
  - **Simscape** & **Simscape Electrical** (Power Systems)
  - **Control System Toolbox** (for closed-loop transfer functions)

---

## 🚀 Quick Start & Usage Guide

### 1. Clone the Repository
```bash
git clone https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab.git
cd matlab-simulink-energy-lab
```

### 2. Initialize Workspace Parameters & Run Verification (Headless / Command-Line)
Run the headless validation scripts from your command line without opening graphical plots:

```bash
matlab -batch "run('examples/battery-rc-model/check_battery_rc_model.m'); run('examples/converter-average-model/check_converter_average_model.m')"
```

**Expected Console Output**:
```text
Battery RC check passed. Final SOC: 0.767
Voltage range: 3.425 V to 3.877 V
Converter parameter check passed.
Output voltage: 360.0 V
Load current: 18.0 A
```

### 3. Interactive Execution & Waveform Plotting
To initialize workspace parameter files (`.m`) and plot transient waveforms in MATLAB:

```matlab
% Run Battery RC Simulation & Generate Waveform Plots
run('examples/battery-rc-model/run_battery_rc_model.m');

% Run Converter Average Calculation & Parametric Check
run('examples/converter-average-model/run_converter_average_model.m');
```

### 4. Running Simulink Models (`.slx`)
When working with Simulink models:
1. Open MATLAB and navigate to the desired example folder (e.g., `examples/battery-rc-model/`).
2. Run the corresponding workspace parameter initialization script (e.g., `run_battery_rc_model.m`) to load model parameters into the MATLAB base workspace.
3. Open the Simulink model file (`.slx`) and click **Run**.

---

## 🔬 Why Inspectable Engineering Models Matter

Foundational energy models are often either too abstracted to trust or too complex to learn from. This lab provides:

- 🔍 **Transparent Parameters**: All physical parameters, units (V, A, $\Omega$, F, Ah), and sign conventions are declared in plain text.
- ✅ **Automated Verification**: Headless `check_*.m` scripts assert numerical bounds and physical constraints before running larger simulations.
- 📐 **Modular Foundations**: Simple baseline models make extending into higher-order dynamics, thermal coupling, or hardware-in-the-loop (HIL) testing straightforward.

---

## 🎯 Target Audience

- **Electrical & Energy Engineering Students**: Understand physical parameter interactions and converter control math.
- **Researchers & Postdocs**: Transparent baseline models to build upon for BESS research and grid-connected converters.
- **Practicing Engineers**: Quick, inspectable verification scripts for initial parameter sizing and trade-off analysis.

---

## 📁 Repository Structure

```text
matlab-simulink-energy-lab/
├── assets/                         # Visual assets, output plots, and architecture diagrams
│   └── battery-rc-response.png
├── examples/                       # Executable model examples & documentation
│   ├── battery-rc-model/           # RC equivalent circuit, pulse profiles, & verification check
│   ├── converter-average-model/    # Power converter average model scaffold & verification check
│   └── guides/                     # Reproducibility, parameter review, & modeling guidelines
├── notes/                          # Project-wide modeling standards & unit conventions
├── .gitignore                      # MATLAB/Simulink specific gitignore
├── CONTRIBUTING.md                 # Contribution guidelines & submission checklist
├── LICENSE                         # MIT License
└── README.md                       # Main lab documentation
```

---

## 🤝 Contributing

Contributions are welcomed! Whether you want to submit a new battery aging model, add a closed-loop converter simulation, or improve documentation, please read [CONTRIBUTING.md](CONTRIBUTING.md) before submitting a Pull Request.

---

## 📄 License

This repository is distributed under the [MIT License](LICENSE).
