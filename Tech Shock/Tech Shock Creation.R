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
fredr_set_key("api_key")




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



