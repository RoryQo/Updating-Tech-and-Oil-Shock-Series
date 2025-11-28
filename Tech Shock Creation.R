## R version 4.4.0
## Author: Rory Quinlan
## Project: Tech Shock Creation
## Date Created: 2025-10-04
## Date Updated: 2025-10-04



  # ==============================================
  # R script: create_data_Galidata_m.R
  # Purpose: Rebuild Coibion & Gorodnichenko data_Galidata.m
  # ==============================================

            # Series used:
  # OPHNFB: Output per hour (nonfarm business)
  # HOANBS: Hours (nonfarm business)
  # GDPDEF: GDP deflator



################################
####### Initial Set up #########
################################

# Load libraries
pkgs <- c("fredr","quantmod", "zoo", "tidyr", "ggplot2", "lubridate", "its.analysis", "dplyr", "tidyverse", "broom")
lapply(pkgs, library, character.only = TRUE)


# Set FRED api key
fredr_set_key("80c548aefdb3b71a0e9abd87010be626")




################################
######### Data Pull ############
################################



# List of FRED series IDs
series_ids <- c("OPHNFB", "HOANBS", "GDPDEF")


# Download and clean
df <- lapply(series_ids, function(id) {
  fredr(series_id = id) %>% 
    select(date, value) %>% 
    mutate(series = id)
}) %>% 
  bind_rows()




################################
######### Wrangling ############
################################



# Wide format (columns = series)
df <- df %>% 
  pivot_wider(names_from = series, values_from = value)

# Rename columns

df <- df %>% 
  rename(
    output_per_hour = OPHNFB,
    hours = HOANBS
  )


############################ Transformation ##############################


# Transform quarterly log differences ×100
df1 <- df %>%
  arrange(date) %>%
  mutate(
    dyn = 100 * (log(output_per_hour) - lag(log(output_per_hour))),
    dh  = 100 * (log(hours) - lag(log(hours))),
    pi  = 100 * (log(GDPDEF) - lag(log(GDPDEF)))
  ) %>%
  filter(!is.na(dyn))

# Drop first NA
df1 <- df1[-1, ]

df1$date <- as.Date(df1$date)
df1 <- df1 %>% filter(date >= "1968-07-01")
write.csv(df1, "Tech_shock_initial_training_data_cut.csv")
# df1<- read.csv("C:\\Users\\roryq\\Downloads\\Tech_shock_initial_training_data.csv")



################################
####### Matlab Format ##########
################################



# Create Matlab .m script
m_lines <- c(
  "% Automatically generated Coibion & Gorodnichenko data_Galidata.m",
  "% US quarterly data: Δlog(Output/hour), Δlog(Hours), Inflation (GDP deflator)",
  "Z = ["
)

# Add numeric data
Z_block <- apply(df1[, c("dyn", "dh", "pi")], 1, function(x)
  paste(sprintf("%0.6f", x), collapse = "\t")
)
m_lines <- c(m_lines, paste0(Z_block, ";"))
m_lines <- c(m_lines, "];", "", "dyn = Z(:,1);", "dh = Z(:,2);", "pi = Z(:,3);", "clear Z")

# --- 4. Write out to .m file ---
writeLines(m_lines, "data_Gali_cut.m")

cat("data_Galidata.m created successfully. Place it in your Coibion replication folder.\n")




################################
##### R Version Attempt ########
################################


library(vars)
library(svars)
library(dplyr)

df1 <- read.csv("C:\\Users\\roryq\\Downloads\\Tech_shock_initial_training_data.csv")

# Arrange df by date
df1 <- df1 %>% arrange(date)
# y must be your tidy quarterly data with dyn, dh, pi (already computed as log-diff*100)
y <- df1 %>% dplyr::select(dyn, dh, pi)

# VAR(4) with a constant, like Coibion’s code
varmod <- VAR(y, p = 4, type = "const")
u <- resid(varmod)      # reduced-form residuals
Sigma_u <- cov(u)  

# Long-run restrictions:
# - Variable order: [dyn, dh, pi]
# - Impose that only shock 1 (technology) has a nonzero long-run effect on dyn,
#   i.e., long-run impacts on dyn from shocks 2 and 3 are zero.





# Blanchard–Quah decomposition (long-run restriction on dyn)
bq <- BQ(varmod)

# Structural shocks
shocks <- resid(bq)       # structural shocks
tech_shock <- shocks[,1]  # column 1 = technology shocks




