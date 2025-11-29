# Updating Coibion Gorodnichenko Technology Shocks

This directory reconstructs and updates the **technology shock series** used in  
Coibion & Gorodnichenko (2012, JPE), *“What Can Survey Forecasts Tell Us about Information Rigidities?”*  

The updated series:

- Use **FRED data** to rebuild the Galí-style VAR inputs.
- Feed a **truncated, updated dataset** into the **original VAR model** from the CG replication code.
- Produce **ready-to-use technology shocks** that are consistent with the original paper but extended with more recent data.

---

## 1. Data Construction (Galidata-Style Inputs)

The technology shock inputs follow Galí (1999) and Coibion and Gorodnichenko (2012) and are based on three quarterly FRED series for the **nonfarm business sector**:

- Labor productivity (output per hour), denoted $\( Y_t^* \)$ (from OPHNFB).  
- Hours worked, denoted $\( H_t \)$ (from HOANBS).  
- The GDP deflator, denoted $\( P_t \)$ (from GDPDEF).

From these, the Galí-style VAR uses **quarterly log differences multiplied by 100**:

- Productivity growth:

  $$\Delta y_t = 100 \big( \log Y_t^* - \log Y_{t-1}^* \big)$$

  
- Hours growth:
  
  $$\Delta h_t = 100 \big( \log H_t - \log H_{t-1} \big)$$
  
- Inflation:

$$\pi_t = 100 \big( \log P_t - \log P_{t-1} \big)$$

These three variables form the VAR state vector:

$$
x_t =
\begin{bmatrix}
\Delta y_t \\
\Delta h_t \\
\pi_t
\end{bmatrix}
$$

An initial **start date** (e.g., a quarter in the late 1960s) is imposed to:

- Match the original empirical design, and  
- Exclude early periods with sparse or lower-quality data.

The transformed series are saved and then used to build the **VAR input matrix**.

---

## 2. VAR Model and Technology Shock Identification

### 2.1 VAR Framework

The triplet $\( (\Delta y_t, \Delta h_t, \pi_t) \)$ is used in a VAR model that follows:

- The structure in **Galí (1999)**, and  
- The implementation in **Coibion & Gorodnichenko (2012)**.

A reduced-form VAR is estimated in the vector $\( x_t \)$. Technology shocks are identified using **long-run restrictions**, typically:

- **Technology shocks** are defined as structural innovations that have a **permanent effect** on labor productivity.  
- **Non-technology shocks** are restricted so that they do **not** generate a permanent shift in the level of productivity (or follow a specified long-run pattern).

From the estimated VAR and long-run restriction matrix, the structural innovations corresponding to technology are extracted, producing a **time series of technology shocks**.

### 2.2 Extended Sample and Truncation

The original Coibion–Gorodnichenko MATLAB replication code uses **pre-defined matrices** with a **fixed number of observations** (e.g., fixed coefficient and residual matrices).  

When the Galidata-style inputs are rebuilt from a fresh FRED pull, the resulting sample is:

- Potentially **longer** than the original CG sample, and  
- Incompatible with the hard-coded matrix sizes in the original VAR functions.

To maintain **full compatibility** with the original VAR implementation:

- The transformed FRED data are first constructed over a long sample.
- This dataset is then **explicitly truncated** so that the final input matrix has **exactly the same number of observations** as the original CG code expects.
- This truncated VAR input matrix is referred to as **`gali_cut`**.

Thus:

- `gali_cut` is the **actual input** to the VAR model in this project
- The VAR specification and identification scheme are **unchanged**; only the underlying data vector $\( x_t \)$ is updated and truncated to fit the fixed matrix structure

Running the original VAR on `gali_cut` yields an updated **technology shock series** that is consistent with the original paper but incorporates more recent data (to the extent allowed by the fixed sample length and matrix design).

---

## 3. MATLAB Implementation and File Structure

### 3.1 Replacement Shock-Creation Scripts

In the original production pipeline, a file such as `step001_create_shocks_all.asv` is responsible for constructing the technology shocks.

In this project, that step is replaced by:

- `create_tech_shocks_cut.asv`  
- `create_tech_shocks_cut2.asv`

These two files:

- Serve as **direct replacements** for `step001_create_shocks_all.asv`.  
- Take `gali_cut` as the VAR input matrix.  
- Call the **original VAR and identification routines** from the authors’ replication code.  
- Output the final **technology shock time series** based on the truncated, updated data.

In other words:

- The **model** (lag structure, identification, long-run restriction) is unchanged.  
- The **data** are updated and truncated.  
- The replacement scripts simply adapt the shock creation step to work with `gali_cut`.

### 3.2 Auxiliary Functions and Folder Setup

The replacement `.asv` files rely on auxiliary functions from the original Coibion–Gorodnichenko replication package. Those functions are included in this repository under the **`MATLAB code`** folder.

To replicate the results:

- Move `create_tech_shocks_cut.asv` and `create_tech_shocks_cut2.asv` into the same directory as the original CG MATLAB code, **or**
- Ensure that both the replacement scripts and the `MATLAB code` folder are on your MATLAB path.

This setup guarantees that all called functions are available and that the VAR model is run exactly as in the original production environment, but with updated and truncated input data.

---

## 4. Visualization of Updated Technology Shocks

The figure below shows the resulting **Galí-style technology shocks** generated by running the original VAR model on the truncated, updated dataset `gali_cut`:

<p align="center">
  <img src="https://github.com/RoryQo/Updating-Tech-and-Oil-Shock-Series/raw/main/Tech%20Shock/Graphs/Gali_tech_shocks.png" alt="Galí technology shocks" width="350">
</p>


This plot provides a visual summary of the updated technology shocks, making it easy to compare their dynamics to the original series and to use them as **macro shock controls** in downstream empirical work.
