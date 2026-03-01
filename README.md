<h1 align="center">Macro Shock Series: Oil &amp; Technology</h1>
 

<p align="center">
  <a href="https://github.com/RoryQo/Updating-Tech-and-Oil-Shock-Series/raw/main/Oil%20Shock/Shock%20Series/shocks_oil_prices.m">
    <img src="https://img.shields.io/static/v1?label=Download&message=Oil%20Price%20Shock%20Series&color=blue&logo=github&logoColor=white" alt="Download shocks_oil_prices.m">
  </a>
  &nbsp;&nbsp;
  <a href="https://github.com/RoryQo/Updating-Tech-and-Oil-Shock-Series/raw/main/Tech%20Shock/Tech%20Shock%20Series/tech_shocks_50-25.csv">
    <img src="https://img.shields.io/static/v1?label=Download&message=Tech%20Shock%20Series&color=blue&logo=github&logoColor=white" alt="Download tech_shocks_50-25.csv">
  </a>
</p>

This repository builds and updates **macro shocks** according to:

- Coibion & Gorodnichenko (2012, JPE), *What Can Survey Forecasts Tell Us about Information Rigidities?*  
- Galí (1999, AER), *Technology, Employment, and the Business Cycle: Do Technology Shocks Explain Aggregate Fluctuations?*

The project:

1. **Reconstructs the data inputs** behind Coibion & Gorodnichenko’s `data_Hamilton.m` and `data_Galidata.m` using public FRED series.  
2. **Applies their original model structures** (Hamilton-style oil shocks, Galí-style VAR for technology shocks) on an updated sample.  
3. Produces **final, ready-to-use macro shock series** that can be used as controls in regression models to account for oil and technology shocks.

These series are intended for researchers who want **consistent macro controls** in their own regressions (e.g., forecast error regressions, VARs, panel models, etc.).



---

## Overview of Components

### R Data-Construction Scripts

- `oil_shock_param_creation.R`  
  Constructs Hamilton-style oil price shocks from West Texas Intermediate (WTI) prices - file comparable to `data_Hamilton.m`

- `create_data_Galidata_m.R`  
  Constructs the transformed macro variables used to estimate technology shocks (Gali, 1999) - file comparable to `data_Galidata.m`

### Model / Estimation Layer

Separate scripts (e.g., in MATLAB or R) take the constructed data and:
  
- Estimate VAR models on productivity, hours, and inflation in order to identify **technology shocks** using Galí-style long-run restrictions
- Export **final shock series** on the extended sample

The end result is a set of time series that can be merged with other datasets and used directly as **macro control variables**.

**(For more methodological and workflow details, please visit each shock's respective folder)**

---

## Final Series

<p align="center">
  <img src="Oil%20Shock/Graphs/hamilton_wti_shocks.png" alt="Hamilton WTI oil shocks" width="400">
  &nbsp;&nbsp;
  <img src="Tech%20Shock/Graphs/Gali_tech_shocks.png" alt="Galí technology shocks" width="400">
</p>

---

## Use Cases for Macro Shock Series

The core purpose of these series is to provide **macro shock controls** for other empirical work. Typical use cases include:

- Adding oil shocks and technology shocks as regressors in **forecast-error regressions**, to control for macro disturbances that may drive both forecasts and realizations  
- Including shocks as exogenous controls in **VARs, panel regressions, or local projections**, especially when focusing on other structural shocks or policy variables  
- Using the series as **robustness controls** to ensure that estimated effects are not driven by unmodeled oil or technology shocks

Because the construction closely tracks Coibion–Gorodnichenko and Galí, the resulting series are **directly interpretable** in that framework

---

## Requirements and Setup

(Reference `requirements.txt`)

- **R version:** 4.4.0 or later  
- Required R packages include:
  - `fredr`, `quantmod`, `zoo`, `tidyr`, `ggplot2`,  
  - `lubridate`, `dplyr`, `tidyverse`, `broom`, `R.matlab` 
  - and any additional packages used for time-series analysis (e.g., `its.analysis` or similar)

- A **FRED API key** is required to download data programmatically  
  - The key should be set in the R environment before running the scripts  
  - For reproducibility and security, the key should be stored outside of version control (e.g., in an environment file)


---

## References

- Coibion, O., & Gorodnichenko, Y. (2012). *What Can Survey Forecasts Tell Us about Information Rigidities?* Journal of Political Economy, 120(1), 116–159.  
- Galí, J. (1999). *Technology, Employment, and the Business Cycle: Do Technology Shocks Explain Aggregate Fluctuations?* American Economic Review, 89(1), 249–271.  
- Hamilton, J. D. (1996). *This is What Happened to the Oil Price–Macroeconomy Relationship.* Journal of Monetary Economics.
