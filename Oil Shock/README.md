## Hamilton Oil Price Shocks

This folder contains Hamilton-style oil price shock series constructed from crude oil prices and aggregated to the quarterly frequency

### WTI-based shocks

<p align="left">
  <img src="Graphs/hamilton_wti_shocks.png" alt="Hamilton Oil Price Shocks – WTI" width="420">
</p>

The **WTI Hamilton shock series** is constructed from your benchmark WTI price series. At a high level:

- Start from the underlying `WTI`FRED price series
- This creates more similar series to C and G, from 1986 to present

### DCOILWTICO-based shocks

<p align="left">
  <img src="Graphs/hamilton_DCOIL_shocks.png" alt="Hamilton Oil Price Shocks – DCOILWTICO" width="420">
</p>

The **DCOILWTICO Hamilton shock series** is built from the FRED spot price of WTI crude oil (`DCOILWTICO`). The procedure mirrors the WTI series:

- Use `DCOILWTICO` prices
- This creates a longer history dating back to 1946

---

For more details on the exact data sources, transformations, and how these shock series fit into the broader replication/extension of Coibion–Gorodnichenko and related work, see the main project README in the root of this repository.

