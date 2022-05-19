###Hi everyone!
###Let's make a census map in 10 minutes

### I always load this R package, just because it has most of what I need to process my data.
library(tidyverse)

###First I want the shapes of the census block groups. I use the tigris package for that. The tigris package is awesome because of its hex sticker (see it in your chat). We all need wall hangings with that image on it, am I right?

library(tigris)
block_groups <- block_groups(state = 'MN', cb = TRUE) %>% select(GEOID, geometry)
options(tigris_use_cache = TRUE)

plot(block_groups)


##Just in case the tiger shapefile website is down, I have saved the shapefile.
##block_groups <- read_sf("C:/Users/kmell/Desktop/air_assessment_section_meeting/block_groups.shp")

##A census block group is a geography where between 600 - 3000 people live.
##Now we want to pull populations of kids within the block groups.
##https://www.rdocumentation.org/packages/tidycensus/versions/0.9.9.5/topics/get_acs You can get your key here.

library(tidycensus)

census_api_key("f152f8211beb7be9b03ef7f9f0a01cb63283cb4e", overwrite = TRUE)

acs_variables <- load_variables(2018, "acs5", cache = TRUE)

kiddos <- get_acs(geography = "block group", 
                      state = "MN", 
                      cache_table = TRUE,
                      variables = c("B01001_003", "B01001_027"),
                      survey = "acs5", 
                      year = 2018,
                     geometry = TRUE) %>%
  rename(kiddo_population     = estimate,
         population_moe = moe) %>%
  select(-NAME) %>%
  group_by(GEOID) %>%
  summarise(kiddo_population = sum(kiddo_population))

##Just in case the census site goes down, I have saved the census data here.
##kiddos <- read_csv("C:/Users/kmell/Desktop/air_assessment_section_meeting/census_data.csv")

##Pull in some MNRISKS air pollution risk scores. 
risks <- read_csv("C:/Users/kmell/Desktop/air_assessment_section_meeting/2014_BG_totals_nolows.csv") %>%
  select(county, geoid, combined_air_score) %>% mutate(geoid = as.character(geoid))

##Join all the data

risks_kiddos <- left_join(risks, kiddos, by = c("geoid" = "GEOID"))

risks_kiddos <- risks_kiddos %>%
  rowwise() %>%
  mutate(cool_label = paste("air score = ", combined_air_score, ", population of kids = ", kiddo_population))

##Let R know that there is geographic information in the table
library(sf)
risks_kiddos <- st_as_sf(risks_kiddos, crs = 4269, sf_column_name = "geometry")

##Put the data in a map
library(leaflet)

leaflet(risks_kiddos) %>%
  addPolygons(
    weight = 1,
    color = "grey",
    fillColor = ~colorQuantile("YlOrRd", combined_air_score)(combined_air_score), 
    label = ~cool_label)

##Save the data as a shapefile
write_sf(risks_kiddos, "C:/Users/kmell/Desktop/air_assessment_section_meeting/risks_kiddos.shp")

##This script is stored here: https://github.com/MPCA-data/tidytuesdays/tree/master/show-n-tell/census_map

##Thanks for listening!!
