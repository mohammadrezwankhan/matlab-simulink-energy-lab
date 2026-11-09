# NASA RW3 measured-pulse example

This small derivative of NASA's [Randomized Battery Usage 2 dataset](https://data.nasa.gov/dataset/randomized-battery-usage-2-room-temperature-random-walk) uses measured current and voltage from one 18650 lithium-ion cell, RW3. NASA identifies the data as government works; cite B. Bole, C. Kulkarni and M. Daigle, *Randomized Battery Usage Data Set*, NASA Ames Prognostics Data Repository. The [Zenodo mirror](https://zenodo.org/records/15277374) supplies `2. Battery_Uniform_Distribution_Discharge_Room_Temp_DataSet_2Post.zip`, with MD5 `aa53dce833e0ce7ee75376846dec4e59`. The extracted `RW3.mat` used here has SHA-256 `f396291daf142d0cf9b59c6fa1344adb4156e4259a6e1129a8486fda2cfa60a4`.

NASA's archive identifies a lithium-ion cell but does not specify its cathode chemistry or nominal capacity. Zhang and Lai, *Improving State-of-Health Estimation for Lithium-Ion Batteries* (2025, DOI `10.3390/wevj16050277`), report 2.1 Ah lithium cobalt oxide/graphite; Poh, *Advanced Data-Driven Methods for Automotive Battery Health Prognostics* (2025, DOI `10.32657/10356/199630`), reports NCA for RW3–RW6. The precise chemistry is therefore not independently resolved here. The model uses **2.11916 Ah measured from this file's low-current discharge**, not an independently verified nominal capacity.

## Source and split

The source README describes 1 A discharges for ten minutes, alternating with twenty-minute rests. Discharge current is positive. The source pulse samples are approximately one second apart; these fixtures retain every tenth sample and each step endpoint, so step transitions retain their actual short intervals. The low-current discharge is approximately 10-second sampled and is retained every sixth point plus its endpoint. Voltage is in V, current in A and time in seconds. The source describes room-temperature testing; source temperatures span 20.07–21.80 °C in calibration and 20.94–22.01 °C in the held-out portion.

| Record | Original MATLAB step indices, one-based | Samples | Source time, seconds |
| --- | --- | ---: | --- |
| Quasi-OCV reference | 1, separate 0.04 A discharge | 3,188 | 6,503.41–197,686.49 |
| Calibration | 6–11: initial rest and first three pulses | 546 | 245,015.71–250,415.70 |
| Held out | Final 300 s of rest 12, then steps 13–16 | 395 | 251,315.71–255,215.70 |

The held-out voltage samples are not used for fitting or constructing the reference curve. Its initial SOC is estimated from the measured charge removed before the held-out segment. The first held-out sample occurs after approximately 900 seconds of rest following the preceding pulse; the model nevertheless assumes zero initial polarization, which may leave residual error. The records are sequential portions of the **same cell and test**, not an independent cell or a separate experimental campaign.

## Quasi-OCV treatment and limitations

The independent 0.04 A discharge voltage is a **quasi-OCV proxy**, not an equilibrium OCV measurement: even this low current can introduce polarization and hysteresis. Charge is integrated from the low-current record to map its voltage against normalized SOC. Voltage quantization creates small reversals, so a monotonic envelope is applied; the maximum adjustment is 1 mV. The fixture's SOC trajectory uses zero-order-held sampled current. Its initial calibration SOC assumes the source's fully charged starting condition. The model does not fit capacity, temperature dependence, hysteresis, initial RC states, or uncertainty in that reference curve.

On MATLAB R2026a the no-plot check reported 3.960 mV calibration RMSE, 9.512 mV held-out RMSE and 18.199 mV held-out maximum absolute error. The check's 10 mV and 25 mV RMSE limits are regression guards for this fixture, not cell-design tolerances. These results do not establish field accuracy, safety, lifetime performance, or transfer to other cells.

## Reproduce

Download archive 2 from the source above, verify its published MD5, and extract `data/Matlab/RW3.mat`. Verify the extracted file's SHA-256 above. Create a new empty output directory, then run from the repository root:

```matlab
addpath('examples/battery-2rc-model');
prepare_nasa_rw3_data('path/to/RW3.mat', 'path/to/empty/output');
check_nasa_rw3_fit
```

The preparation function refuses to overwrite existing fixture filenames. Its regenerated numeric columns agree with the committed CSV files within `1e-8`; small text-format differences are expected. The existing deterministic synthetic benchmark remains separate.
