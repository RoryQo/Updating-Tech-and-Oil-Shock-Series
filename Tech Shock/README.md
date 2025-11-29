# Updating Coibion Gorodnichenko Technology Shocks

This directory reconstructs and updates the **technology shock series** used in  
Coibion & Gorodnichenko (2012, JPE), *“What Can Survey Forecasts Tell Us about Information Rigidities?”*  

The updated series:

- Use **FRED data** to rebuild the Galí-style VAR inputs
- Feed a **updated dataset** into the **original VAR model** from the paper's replication code
- Produce **updated technology shocks** that are consistent with the original paper but extended with more recent data

---
## Technology Shock Inputs (Gali)

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
   - the Galí VAR uses **quarterly log differences multiplied by 100**:
     - Productivity growth:

       $$\Delta y_t = 100 \left( \log Y_t^* - \log Y_{t-1}^* \right)$$

     - Hours growth:
     
       $$\Delta h_t = 100 \left( \log H_t - \log H_{t-1} \right)$$

      - Inflation:
     
       $$\pi_t = 100 \left( \log P_t - \log P_{t-1} \right)$$


   - These correspond to **percentage growth rates** for productivity and hours, and **annualized-percent inflation** (on a quarterly basis).

### Output

The transformed data are saved as a CSV file (e.g., `Tech_shock_initial_training_data_cut.csv`), containing:

- A quarterly date variable.  
- The three key variables:
  - $\( \Delta y_t \)$ (often denoted `dyn`) 
  - $\( \Delta h_t \)$ (often denoted `dh`)  
  - $\( \pi_t \)$ (often denoted `pi`)


These three variables form the VAR state vector:

$$
x_t =
\begin{bmatrix}
\Delta y_t \\
\Delta h_t \\
\pi_t
\end{bmatrix}
$$


This CSV serves as the **input dataset** for the VAR that identifies **technology shocks** using Galí’s methodology.

## 2. VAR Model and Technology Shock Identification

### 2.1 VAR Framework

The triplet $\( (\Delta y_t, \Delta h_t, \pi_t) \)$ is used in a VAR model that follows:

- The structure in **Galí (1999)**, and  
- The implementation in **Coibion & Gorodnichenko (2012)**.

A reduced-form VAR is estimated in the vector $\( x_t \)$. From the estimated VAR and long-run restriction matrix, the structural innovations corresponding to technology are extracted, producing a **time series of technology shocks**.

### 2.2 Extended Sample and Truncation

The original Coibion–Gorodnichenko MATLAB replication code uses **pre-defined matrices** with a **fixed number of observations** (e.g., fixed coefficient and residual matrices).  

When the Galidata-style inputs are rebuilt from a fresh FRED pull, the resulting sample is:

- Potentially **longer** than the original CG sample
- Incompatible with the hard-coded matrix sizes in the original VAR functions

To maintain **full compatibility** with the original VAR implementation:

- The transformed FRED data are first constructed over a long sample
- This dataset is then **explicitly truncated** so that the final input matrix has **exactly the same number of observations** as the original CG code expects
- This truncated VAR input matrix is referred to as **`gali_cut`**

Thus:

- `gali_cut` is the **actual input** to the VAR model in this project
- The VAR specification and identification scheme are **unchanged**; only the underlying data vector $\( x_t \)$ is updated and truncated to fit the fixed matrix structure

Running the original VAR on `gali_cut` yields an updated **technology shock series** that is consistent with the original paper but incorporates more recent data

---

## 3. MATLAB Implementation and File Structure

### 3.1 Replacement Shock-Creation Scripts

In the original production pipeline, the file `step001_create_shocks_all.m` constructs the technology shocks.

In this project, that step is replaced by:

- `create_tech_shocks_cut.asv`  
- **`create_tech_shocks_cut2.asv`** (updated date version)

These two files:

- Serve as **direct replacements** for `step001_create_shocks_all.asv`.  
- Take `gali_cut` as the VAR input matrix 
- Call the **original VAR and identification routines** from the authors’ replication code  
- Output the final **technology shock time series** based on the updated data

### 3.2 Auxiliary Functions and Folder Setup

The replacement `.asv` files rely on auxiliary functions from the original Coibion–Gorodnichenko replication package. Those functions are included in this repository under the **`MATLAB code`** folder.

To replicate the results:

- Move `create_tech_shocks_cut.asv` and `create_tech_shocks_cut2.asv` into the same directory as the original CG MATLAB code, **or**
- Ensure that both the replacement scripts and the `MATLAB code` folder are on your MATLAB path

This setup ensures that all called functions are available and that the VAR model is run exactly as in the original production environment, using updated input data.

---

## 4. Final Updated Technology Shock Series 1969 to 2025Q1

The figure below shows the resulting **Final updated technology shock series** generated by running the original VAR model on the updated dataset

<p align="center">
  <img src="https://github.com/RoryQo/Updating-Tech-and-Oil-Shock-Series/raw/main/Tech%20Shock/Graphs/Gali_tech_shocks.png" alt="Galí technology shocks" width="500">
</p>

