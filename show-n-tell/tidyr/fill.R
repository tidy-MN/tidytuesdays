library(tidyverse)

emits <- read_csv("https://raw.githubusercontent.com/MPCA-data/tidytuesdays/master/show-n-tell/tidyr/facility_emissions_example.csv")


glimpse(emits)
# Ack!
## Stack names only listed once


# Drop blank pollutants
emits <- emits %>% filter(!is.na(Pollutant))


# fill() the stack's permit ID column
emits_full <- fill(emits, Permit)

# fill() 2 columns
emits_full <- fill(emits, Permit, AERMOD)


# Default fills downward
## Use .direction = "up" to fill upward
## (Note this is incorrect for this data)
emits_up <- fill(emits, Permit, .direction = "up")
