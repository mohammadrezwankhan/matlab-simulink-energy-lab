# A123 LFP measured-pulse example

This example uses measurements from Aloisio Kawakita de Souza, *Lithium-ion Battery OCV and Dynamic Test Data of a LiFePO4 cylindrical cell*, Mendeley Data V1, DOI `10.17632/p8kf893yv3.1`. The author describes the dataset as CC BY 4.0 at the [source repository](https://github.com/aloisiohks/A123_26650_m1b_LAB_Dataset/tree/4fc9320c85f91317ace5d1bc9c40f53aaa2b1140). The reported cell is an A123 ANR26650M1B LiFePO4 cell with nominal 2.5 Ah capacity. Attribution is required when redistributing the derivatives.

## Source records and processing

The three files below are from the same cell and source commit `4fc9320c85f91317ace5d1bc9c40f53aaa2b1140`. SHA-256 values identify the downloaded bytes; do not substitute a file merely because its name matches.

| Source file | SHA-256 | Use |
| --- | --- | --- |
| `Miscellaneous/A002_PeriodicPulseData.mat` | `866adba8064543812dc0a29ddcc2b83d034efb2cd593bc9f5af82ae8bbd88ccc` | First 400 samples of the periodic pulse segment, source time 12631.08–13030.45 s, calibration. |
| `OCVdata/A002_OCV_P25.mat` | `85767c3acaf76543db7a7cd149407161ad5878f07fba35373b7635a015e3baec` | Separate low-current discharge (`script1`) used as quasi-OCV. |
| `DYNdata/A002_DYN_20_P25.mat` | `3ef8104a0375334230626ff55e98d84f0c5bc1412faab246cce223039249875d` | First 1,500 samples of `script1`, source time 6901.08–8400.08 s, held out from fitting. |

Time is in seconds, current in amperes and voltage in volts. In the source pulse record negative current accompanies increasing discharge Ah; in the dynamic record positive current accompanies increasing discharge Ah. The preparation function negates only the pulse current, giving both output files the model's positive-discharge convention. Source pulse spacing is approximately one second; no pulse points are decimated.

The quasi-OCV curve is built from the separate approximately 0.083 A discharge: SOC is normalized using its measured 2.577564669 Ah discharge capacity, 300 points are selected, and a monotonic voltage envelope removes small reversals. The curve endpoints are extended to SOC 0 and 1. This is a low-current voltage proxy, not equilibrium OCV; it contains hysteresis and polarization. Calibration SOC starts at 0.515103918, inferred from the pulse file's cumulative discharge. The held-out dynamic run starts at assumed SOC 1 after the recorded initial rest. Its 1,500 voltage samples are not used to fit resistance or construct the quasi-OCV curve.

The pulse file's air temperature for the calibration segment is 25.89–25.97 °C and its cell surface temperature is 25.91–30.49 °C. The pulses reach approximately ±20 A. The other files are labeled P25 in the source; no temperature trace is present in their retained structures. The model omits temperature dependence, hysteresis, and uncertainty in initial SOC and OCV. The initial RC states are assumed zero; the first calibration sample is already under current. These are separate records from one cell, not independent-cell validation.

On MATLAB R2026a, `check_lfp_fit` reports 15.010 mV calibration RMSE, 12.567 mV held-out RMSE and 30.543 mV held-out maximum absolute error. The 20 mV RMSE assertions guard against regression for these exact records; they are not engineering tolerances or evidence of design, safety, field or lifetime performance. The existing synthetic and NASA examples remain separate.

## Reproduce

Download the three files at the source commit above, verify their hashes, and create a new empty output directory. From MATLAB:

```matlab
addpath('examples/battery-2rc-model');
prepare_lfp_data('path/to/pulse.mat', 'path/to/ocv.mat', ...
    'path/to/dynamic.mat', 'path/to/empty/output');
check_lfp_fit
```

The preparation function refuses to overwrite the three output filenames. Compare its three CSV outputs with the committed files to check regeneration. `check_lfp_fit` reads the committed fixture.
