# Macro Shock Controls: Oil & Technology Shocks (CG-Style)


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
  
- Estimate VAR models on productivity, hours, and inflation in order to identify **technology shocks** using Galí-style long-run restrictions. 
- Export **final shock series** on the extended sample

The end result is a set of time series that can be merged with other datasets and used directly as **macro control variables**.

---

## 1. Oil Price Shocks (Hamilton)

**Script:** `oil_shock_param_creation.R`  

### Data Sources

The oil shock construction relies on FRED series for nominal WTI crude oil prices:

- **Daily WTI prices** (e.g., `DCOILWTICO`)
- **Monthly WTI prices** (e.g., `WTISPLC`) providing a longer historical sample from the mid-1940s onward

### Key Transformations

1. **Quarterly Aggregation**  
   - Each calendar date is mapped to a quarter.  
   - Within each quarter, the average nominal oil price is calculated.  
   - This yields a quarterly series $\( p_t \)$ of oil prices.

2. **Log Transformation**  
   - Prices are converted to logs:
     $$ell_t = log(p_t)$$
   - A small positive constant is used internally to avoid numerical issues when prices are extremely low.

3. **Hamilton Net Oil Price Increase (NOPI)**  
   - For each quarter $\( t \)$, compute the maximum of log prices over the previous four quarters:
     $$M_t = \max(\ell_{t-1}, \ell_{t-2}, \ell_{t-3}, \ell_{t-4})$$
   - The Hamilton-style oil price shock is: $$\text{oilshock}_t = \max(0, \ell_t - M_t)$$
   - Intuitively, this captures **only net increases** in oil prices relative to their recent four-quarter peak, following Hamilton’s original construction.

   ***Note: Quarter Indexing for MATLAB*** 
   - Quarters are converted to a decimal-year format used in Coibion–Gorodnichenko’s MATLAB code:
     - Q1 of year \( y \): \( y + 0.00 \)  
     - Q2: \( y + 0.25 \)  
     - Q3: \( y + 0.50 \)  
     - Q4: \( y + 0.75 \)
   - This produces the first column in the MATLAB `oilshocks` matrix.

### Outputs

The script produces two MATLAB `.m` files:

- **`shocks_oil_prices.m`**  
  - Oil shocks constructed from the **daily** WTI series.  
  - Contains a two-column matrix:
    1. Decimal quarter index  
    2. Hamilton NOPI shock

- **`shocks_oil_price_historic.m`**  
  - Oil shocks constructed from the **monthly** WTI series, providing a longer historical span.  
  - Same two-column structure as above

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
   - The triplet $\((\Delta y_t, \Delta h_t, \pi_t)\)$ is used in a VAR framework that follows Galí (1999) and Coibion–Gorodnichenko’s implementation:  
     - A VAR is estimated in these variables  
     - Long-run restrictions are used to identify **technology shocks** as the structural innovations that have a permanent effect on productivity but no long-run effect on hours (or with a specified pattern of long-run responses, depending on the exact identification scheme)  
   - The resulting structural shocks are extracted as a **time series of technology shocks**

3. **Extended Sample**  
   - Because all inputs come from up-to-date FRED data, the estimated shocks naturally extend beyond the original sample of the published papers, allowing for analysis on more recent data

4. **Exported Final Series**  
   - The final products include:
     - An updated **oil shock series** (Hamilton/CG-style)  
     - An updated **technology shock series** (Galí/CG-style)  
   - These are saved in formats such as MATLAB `.m` files and/or `.csv` files, with clear labels, ready to be merged onto other datasets

---

## Use as Macro Controls in Regressions

The core purpose of these series is to provide **macro shock controls** for other empirical work. Typical use cases include:

- Adding oil shocks and technology shocks as regressors in **forecast-error regressions**, to control for macro disturbances that may drive both forecasts and realizations  
- Including shocks as exogenous controls in **VARs, panel regressions, or local projections**, especially when focusing on other structural shocks or policy variables  
- Using the series as **robustness controls** to ensure that estimated effects are not driven by unmodeled oil or technology shocks

Conceptually, you:

1. Map your dataset to a quarterly frequency and construct a quarterly date variable 
2. Merge the shock series by quarter (date or quarter index)
3. Include the shocks as additional regressors or exogenous variables in your preferred econometric specification

Because the construction closely tracks Coibion–Gorodnichenko and Galí, the resulting series are **directly interpretable** in that framework

---

## Requirements and Setup

- **R version:** 4.4.0 or later  
- Required R packages include:
  - `fredr`, `quantmod`, `zoo`, `tidyr`, `ggplot2`,  
  - `lubridate`, `dplyr`, `tidyverse`, `broom`,  
  - and any additional packages used for time-series analysis (e.g., `its.analysis` or similar)

- A **FRED API key** is required to download data programmatically  
  - The key should be set in the R environment before running the scripts  
  - For reproducibility and security, the key should be stored outside of version control (e.g., in an environment file)

---

## Workflow Summary

1. **Construct Oil Price Shocks**  
   - Run `oil_shock_param_creation.R` to obtain Hamilton-style NOPI shocks in MATLAB-ready format

2. **Construct Technology Shock Inputs**  
   - Run `create_data_Galidata_m.R` to obtain the transformed variables \((\Delta y_t, \Delta h_t, \pi_t)\) in a CSV file

3. **Estimate Models and Extract Shocks**  
   - Use MATLAB or R scripts that replicate Coibion–Gorodnichenko’s modeling approach to estimate VARs and related structures 
   - Identify the structural shocks and export them as final series

---

## References

- Coibion, O., & Gorodnichenko, Y. (2012). *What Can Survey Forecasts Tell Us about Information Rigidities?* Journal of Political Economy, 120(1), 116–159.  
- Galí, J. (1999). *Technology, Employment, and the Business Cycle: Do Technology Shocks Explain Aggregate Fluctuations?* American Economic Review, 89(1), 249–271.  
- Hamilton, J. D. (1996). *This is What Happened to the Oil Price–Macroeconomy Relationship.* Journal of Monetary Economics.
