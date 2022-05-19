library(tidyverse)
library(sf)
library(tidycensus)
library(tigris)


##Tidy Census population: https://walker-data.com/tidycensus/

##Pull in populations

census_api_key("2406e6fa13ae3981943a5c0fa5798cf8b6a9602a", overwrite = TRUE) ##this is mine.
##Go here to get your census api key: http://api.census.gov/data/key_signup.html

#census_api_key("your_key_here", overwrite = TRUE) ##this is mine.

variables_decennial <- load_variables(2020, "pl", cache = TRUE) ##check to 2010 to check if the code works

tot_pop <- get_decennial(geography = "block group",
                       variables = "P1_001N", ##P001001
                       state = "MN",
                       year = 2020,
                       geometry = TRUE) ##change to 2010 to check if the code works

acs_variables <- load_variables(2019, "acs5", cache = TRUE)

pop_blkgrp <- get_acs(geography = "block group",
                      state = "MN",
                      variables = "B01001_001",
                      survey = "acs5",
                      year = 2019) %>%
  rename(population     = estimate,
         population_moe = moe) %>%
  select(-variable, -NAME)

young_males  <- get_acs(geography = "block group",
                        state = "MN",
                        variables = "B01001_003",
                        survey = "acs5",
                        year = 2019) %>%
  rename(under_five_males     = estimate,
         under_five_males_moe = moe) %>%
  select(-variable, -NAME)

young_females  <- get_acs(geography = "block group",
                          state = "MN",
                          variables = "B01001_027",
                          survey = "acs5",
                          year = 2019) %>%
  rename(under_five_females     = estimate,
         under_five_females_moe = moe) %>%
  select(-variable, -NAME)

elderly_males  <- get_acs(geography = "block group",
                          state = "MN",
                          variables = "B01001_025",
                          survey = "acs5",
                          year = 2019) %>%
  rename(over_85_males     = estimate,
         over_85_males_moe = moe) %>%
  select(-variable, -NAME)

elderly_females  <- get_acs(geography = "block group",
                            state = "MN",
                            variables = "B01001_049",
                            survey = "acs5",
                            year = 2019) %>%
  rename(over_85_females     = estimate,
         over_85_females_moe = moe) %>%
  select(-variable, -NAME)

pop_blkgrp <- left_join(pop_blkgrp, young_males)
pop_blkgrp <- left_join(pop_blkgrp, young_females)
pop_blkgrp <- left_join(pop_blkgrp, elderly_males)
pop_blkgrp <- left_join(pop_blkgrp, elderly_females)

pop_blkgrp <- pop_blkgrp %>%
  rowwise() %>%
  mutate(pop_children = sum(under_five_males, under_five_females, na.rm = T),
         pop_elderly = sum(over_85_females, over_85_males, na.rm = T)) %>%
  select(-c(under_five_males:over_85_females_moe))

blkgrps <- block_groups(state = 'MN')

pop_blkgrp <- left_join(pop_blkgrp, blkgrps)
pop_blkgrp <- st_as_sf(pop_blkgrp, sf_column_name = "geometry", crs = 4326)
plot(pop_blkgrp[2])
##4 children
##5 elderly

##This won't work because I didn't specify that geometry=TRUE, the default is FALSE. So, let's go back and do this again and chat a bit while it runs and THEN plot it simply.

##Now, we will all do this tutorial together
##We will simply copy and paste and talk through the scripts. Then we will convert to Minnesota: https://juliasilge.com/blog/using-tidycensus/
