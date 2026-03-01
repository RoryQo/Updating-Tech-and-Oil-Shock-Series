## R version 4.4.0
## Author: Rory Quinlan
## Project: Oil Shock Creation
## Date Created: 2025-10-04
## Date Updated: 2025-10-08



# ==============================================
# R script: oil_shock_param_creation.R
# Purpose: Rebuild Coibion & Gorodnichenko data_Hamilton.m
# ==============================================

# Series used:
# DCOILWTICO: Crude Oil Prices: West Texas Intermediate (WTI) - Cushing, Oklahoma
# WTISPLC: Spot Crude Oil Price: West Texas Intermediate (WTI)



################################
####### Initial Set up #########
################################



# Load libraries
pkgs <- c("fredr","quantmod", "zoo", "tidyr", "ggplot2", "lubridate", "its.analysis", "dplyr", "tidyverse", "broom", "zoo")
lapply(pkgs, library, character.only = TRUE)


# Set FRED api key
fredr_set_key("api_key")



################################
######### Data Pull ############
################################




# Pull daily WTI (nominal), aggregate to quarterly mean
wti_q <- fredr(series_id = "DCOILWTICO") %>%
  filter(!is.na(value)) %>%
  mutate(qtr = as.yearqtr(date)) %>%
  group_by(qtr) %>%
  summarise(price = mean(value), .groups = "drop") %>%
  arrange(qtr)



############# Option 2 (historical) ##################

# Pull monthly oil prices (WTISPLC covers 1946–present) ----
oil_monthly <- fredr(series_id = "WTISPLC",
                     observation_start = as.Date("1946-01-01")) %>%
  select(date, value) %>%
  filter(!is.na(value)) %>%
  mutate(qtr = as.yearqtr(date))




################################
######### Wrangling ############
################################



# Take log of all prices (per footnote 7)
  # Add small constant to avoid NAs when taking log
eps <- 1e-6
wti_q <- wti_q %>% mutate(lp = log(pmax(price, eps)))



# Hamilton NOPI (compare to max of previous 4 quarters)
wti_q2 <- wti_q %>%
  mutate(max_lag4 = pmax(lag(lp,1), lag(lp,2), lag(lp,3), lag(lp,4), na.rm = TRUE),
         oilshock = pmax(0, lp - max_lag4)) %>%
  filter(!is.na(oilshock))


############# Option 2 (historical) ##################


# Aggregate to quarterly mean
wti_qh <- oil_monthly %>%
  group_by(qtr) %>%
  summarise(price = mean(value, na.rm = TRUE), .groups = "drop") %>%
  arrange(qtr) %>%
  mutate(lp = log(pmax(price, 1e-6)))  # avoid log(0)

# Compute Hamilton NOPI shocks
wti_qh <- wti_qh %>%
  mutate(
    max_lag4 = pmax(lag(lp,1), lag(lp,2), lag(lp,3), lag(lp,4), na.rm = TRUE),
    oilshock = pmax(0, lp - max_lag4)
  ) %>%
  filter(!is.na(oilshock))




####################################
######### Matlab Format ############
####################################

#  Convert yearqtr to integer
  qtr_to_thor <- function(yq) {
    y <- floor(as.numeric(yq))
    q <- round((as.numeric(yq) - y) * 4 + 1)
    y + (q - 1) * 0.25
  }

oil_mat <- cbind(qtr_to_thor(wti_q2$qtr), wti_q2$oilshock)

# Build MATLAB script lines
lines_oil <- c(
  "% load oil price shocks",
  "% column 1 = date",
  "% column 2 = Hamilton price shocks",
  "oilshocks=[",
  apply(oil_mat, 1, function(x) paste(sprintf("%.9f", x), collapse = "\t")),
  "];"
)

# Write to file
writeLines(lines_oil, "shocks_oil_prices.m")



############# Option 2 (historical) ##################



oil_math <- cbind(qtr_to_thor(wti_qh$qtr), wti_qh$oilshock)

# Build MATLAB file
lines_oilh <- c(
  "% load oil price shocks",
  "% column 1 = date",
  "% column 2 = Hamilton price shocks",
  "oilshocks=[",
  apply(oil_math, 1, function(x) paste(sprintf("%.9f", x), collapse = "\t")),
  "];"
)

# Write to file
writeLines(lines_oilh, "shocks_oil_price_historic.m")








