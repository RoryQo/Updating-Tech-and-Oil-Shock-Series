





################################
####### Initial Set up #########
################################




setwd("C:\\Users\\roryq\\Downloads")

# Load libraries
pkgs <- c("tidyr", "ggplot2", "lubridate","zoo", "dplyr", "tidyverse", "broom", "readxl", "R.matlab")
lapply(pkgs, library, character.only = TRUE)





##################### Daily WTI 1986 to present #############################




# Read the .m file as plain text
lines <- readLines("shocks_oil_prices.m")

# Keep only lines that start with a number (your data rows)
data_lines <- grep("^\\s*[0-9]", lines, value = TRUE)

# Parse those lines into a data.frame
WTI <- read.table(text = data_lines)

# Add column names
names(WTI) <- c("date", "hamilton_shock")




##################### Monthly WTI 1946 to present #############################




# Read the .m file as plain text
lines <- readLines("shocks_oil_price_historic.m")

# Keep only lines that start with a number (your data rows)
data_lines <- grep("^\\s*[0-9]", lines, value = TRUE)

# Parse those lines into a data.frame
DCOIL <- read.table(text = data_lines)

# Add column names
names(DCOIL) <- c("date", "hamilton_shock")




################################
########### Plotting ###########
################################

library(dplyr)
library(zoo)
library(ggplot2)
library(scales)

WTI <- WTI %>% 
  mutate(
    year   = floor(date),
    q      = round((date - year) * 4) + 1L,
    yearqtr = as.yearqtr(paste(year, q), format = "%Y %q"),
    # pick one of these as your plotting date:
    date_qtr = as.Date(yearqtr, frac = 1)   # quarter end
    # or: date_qtr = as.Date(yearqtr)       # quarter start
  )


ggplot(WTI, aes(x = date_qtr, y = hamilton_shock)) +
  # light fill under the line
  geom_area(alpha = 0.15, color = "cornflowerblue") +
  # main line
  geom_line(linewidth = 1, color = "blue4") +
  # points on top
  geom_point(size = 2, alpha = 0.7, color = "blue4") +
  # nicer axes
  scale_x_date(
    date_breaks = "5 years",
    date_labels = "%Y",
    expand = expansion(mult = c(0.01, 0.01))
  ) +
  scale_y_continuous(labels = scales::label_number(accuracy = 0.01)) +
  # labels
  labs(
    title    = "Hamilton Oil Price Shocks – WTI Daily Series",
    subtitle = "Aggregated quarterly shocks, 1986 to present",
    x        = NULL,
    y        = "Hamilton oil shock"
  ) +
  # clean theme
  theme_minimal(base_size = 13) +
  theme(
    plot.title        = element_text(face = "bold", size = 16, hjust = 0.5),
    plot.subtitle     = element_text(size = 11, hjust = 0.5),
    axis.title.y      = element_text(margin = margin(r = 10)),
    panel.grid.minor  = element_blank(),
    panel.grid.major.x = element_blank(),
    # >>> force white background <<<
    panel.background  = element_rect(fill = "white", color = NA),
    plot.background   = element_rect(fill = "white", color = NA)
  )

ggsave(
  filename = "hamilton_wti_shocks.png",
  width    = 12,
  height   = 8)











DCOIL <- DCOIL %>% 
  mutate(
    year   = floor(date),
    q      = round((date - year) * 4) + 1L,
    yearqtr = as.yearqtr(paste(year, q), format = "%Y %q"),
    # pick one of these as your plotting date:
    date_qtr = as.Date(yearqtr, frac = 1)   # quarter end
    # or: date_qtr = as.Date(yearqtr)       # quarter start
  )


ggplot(DCOIL, aes(x = date_qtr, y = hamilton_shock)) +
  # light fill under the line
  geom_area(alpha = 0.15, color = "cornflowerblue") +
  # main line
  geom_line(linewidth = 1, color = "blue4") +
  # points on top
  geom_point(size = 2, alpha = 0.7, color = "blue4") +
  # nicer axes
  scale_x_date(
    date_breaks = "5 years",
    date_labels = "%Y",
    expand = expansion(mult = c(0.01, 0.01))
  ) +
  scale_y_continuous(labels = scales::label_number(accuracy = 0.01)) +
  # labels
  labs(
    title    = "Hamilton Oil Price Shocks – WTI Monthly Series",
    subtitle = "Aggregated quarterly shocks, 1946 to present",
    x        = NULL,
    y        = "Hamilton oil shock"
  ) +
  # clean theme
  theme_minimal(base_size = 13) +
  theme(
    plot.title        = element_text(face = "bold", size = 16, hjust = 0.5),
    plot.subtitle     = element_text(size = 11, hjust = 0.5),
    axis.title.y      = element_text(margin = margin(r = 10)),
    panel.grid.minor  = element_blank(),
    panel.grid.major.x = element_blank(),
    # >>> force white background <<<
    panel.background  = element_rect(fill = "white", color = NA),
    plot.background   = element_rect(fill = "white", color = NA)
  )

ggsave(
  filename = "hamilton_DCOIL_shocks.png",
  width    = 12,
  height   = 8)


  











