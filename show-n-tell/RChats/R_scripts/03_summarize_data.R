library(tidyverse)

ozone_summary <- ozone_data %>%
  group_by(SITE, YEAR, Latitude, Longitude) %>%
  summarise(ozone_ppb_mean = mean(OZONE, na.rm = T))
