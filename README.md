# Macro Shock Series: Oil & Technology


This repository builds and updates **macro shocks** according to:

- Coibion & Gorodnichenko (2012, JPE), *What Can Survey Forecasts Tell Us about Information Rigidities?*  
- Galí (1999, AER), *Technology, Employment, and the Business Cycle: Do Technology Shocks Explain Aggregate Fluctuations?*

The project:

1. **Reconstructs the data inputs** behind Coibion & Gorodnichenko’s `data_Hamilton.m` and `data_Galidata.m` using public FRED series.  
2. **Applies their original model structures** (Hamilton-style oil shocks, Galí-style VAR for technology shocks) on an updated sample.  
3. Produces **final, ready-to-use macro shock series** that can be used as controls in regression models to account for oil and technology shocks.

These series are intended for researchers who want **consistent macro controls** in their own regressions (e.g., forecast error regressions, VARs, panel models, etc.).


<p align="center">
  <a href="https://github.com/RoryQo/Updating-Tech-and-Oil-Shock-Series/raw/main/Oil%20Shock/Shock%20Series/shocks_oil_prices.m">
    <img src="https://img.shields.io/static/v1?label=Download&message=Oil%20Price%20Shock%20Series&color=blue&logo=github&logoColor=white" alt="Download shocks_oil_prices.m">
  </a>
</p>

<p align="center">
  <a href="https://github.com/RoryQo/Updating-Tech-and-Oil-Shock-Series/raw/main/Tech%20Shock/Tech%20Shock%20Series/tech_shocks_50-25.csv">
    <img src="https://img.shields.io/static/v1?label=Download&message=Tech%20Shock%20Series&color=blue&logo=github&logoColor=white" alt="Download tech_shocks_50-25.csv">
  </a>
</p>

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

---

## 2. Technology Shock Inputs (Gali)

**Script:** `create_data_Galidata_m.R`  

### Data Sources

The technology shock construction uses three FRED series for the **nonfarm business sector**:

- **Labor productivity (output per hour)** —  `OPHNFB`
- **Hours worked** — `HOANBS` 
- **GDP deflator** — `GDPDEF`

These are obtained at a quarterly frequency

### Key Transformations

1. **Base Variables**  
   - The raw levels are interpreted as:
     - $\( Y_t^* \)$: output per hour (labor productivity)
     - $\( H_t \)$: hours worked
     - $\( P_t \)$: GDP deflator

2. **Log Differences (Growth Rates and Inflation)**  
   - The core variables used in the VAR are **quarterly log differences multiplied by 100**:
     - Productivity growth:

       $$\Delta y_t = 100 \left( \log Y_t^* - \log Y_{t-1}^* \right)$$

     - Hours growth:
     
       $$\Delta h_t = 100 \left( \log H_t - \log H_{t-1} \right)$$

      - Inflation:
     
       $$\pi_t = 100 \left( \log P_t - \log P_{t-1} \right)$$


   - These correspond to **percentage growth rates** for productivity and hours, and **annualized-percent inflation** (on a quarterly basis).

3. **Sample Restriction**  
   - The resulting quarterly series $\((\Delta y_t, \Delta h_t, \pi_t)\)$ are restricted to start from a given date (e.g., 1968Q3) to match or extend the original sample used in Coibion–Gorodnichenko.

### Output

The transformed data are saved as a CSV file (e.g., `Tech_shock_initial_training_data_cut.csv`), containing:

- A quarterly date variable.  
- The three key variables:
  - $\( \Delta y_t \)$ (often denoted `dyn`) 
  - $\( \Delta h_t \)$ (often denoted `dh`)  
  - $\( \pi_t \)$ (often denoted `pi`)

This CSV serves as the **input dataset** for the VAR that identifies **technology shocks** using Galí’s methodology.

---

## 3. Final Shock Series from Coibion–Gorodnichenko Models

Beyond constructing inputs, the repository also **runs the Coibion–Gorodnichenko-style models themselves** on the extended data:

1. **Oil Shock Usage**  
   - The Hamilton NOPI series is already constructed and does not need to be run through a var model, unlike the tech shocks

2. **Technology Shock Identification**  
   1. The triplet $(\Delta y_t, \Delta h_t, \pi_t)$ is used in a VAR framework that follows Galí (1999) and Coibion–Gorodnichenko’s implementation:  
      - A VAR is estimated in these variables.  
      - Long-run restrictions are used to identify **technology shocks** as the structural innovations that have a permanent effect on productivity but no long-run effect on hours (or with a specified pattern of long-run responses, depending on the exact identification scheme).  
   2. The resulting structural shocks are extracted as a **time series of technology shocks**
   3. **Please see Tech Shock Folder for full workflow and details**


---

## Use Cases for Macro Shock Series

The core purpose of these series is to provide **macro shock controls** for other empirical work. Typical use cases include:

- Adding oil shocks and technology shocks as regressors in **forecast-error regressions**, to control for macro disturbances that may drive both forecasts and realizations  
- Including shocks as exogenous controls in **VARs, panel regressions, or local projections**, especially when focusing on other structural shocks or policy variables  
- Using the series as **robustness controls** to ensure that estimated effects are not driven by unmodeled oil or technology shocks

Because the construction closely tracks Coibion–Gorodnichenko and Galí, the resulting series are **directly interpretable** in that framework

---

## Requirements and Setup

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
