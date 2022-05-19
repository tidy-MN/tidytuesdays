##Where is Carmen Sandiego?

library(sf)
library(tidyverse)

##we have the locations of heroes and villains around hte world.
character_locations <- read_csv("https://raw.githubusercontent.com/MPCA-data/tidytuesdays/master/show-n-tell/sf_carmensandiego/grid_characters.csv")

character_locations_sf = character_locations %>%
  mutate(geom = gsub(x,pattern="(\\))|(\\()|c",replacement = ""))%>%
  tidyr::separate(geom,into=c("lat","lon"),sep=",")%>%
  st_as_sf(.,coords=c("lat","lon"),crs=4326, remove = FALSE)

plot(character_locations_sf[1])

character_locations_sf <- character_locations_sf %>%
  filter(hair == "Red Hair",
         eye == "Hazel Eyes",
         align == "Reformed Criminals")
##Carmen Sandiego is in the data in code, based on the meanings of her first and last names.
##Eyes are hazel,
##Hair is red in color
##she aligns with reformed criminals
##look up what Carmen means, and use grepl to find this word.

##make capitol cities csv into an sf object

capitol_cities <- read_csv("https://raw.githubusercontent.com/MPCA-data/tidytuesdays/master/show-n-tell/sf_carmensandiego/concap.csv")

capitol_cities <- st_as_sf(capitol_cities, coords = c("CapitalLongitude", "CapitalLatitude"), crs = 4326, remove = FALSE)

plot(capitol_cities[2])

##this is my go to website for spatial reference system explanations, https://www.nceas.ucsb.edu/sites/default/files/2020-04/OverviewCoordinateReferenceSystems.pdf

##Carmen Sandiego is within 1 kilometer from a World Capitol. Which one?

carmen <- character_locations_sf %>%
  filter(eye == "Hazel Eyes",
         hair == "Red Hair",
         align == "Reformed Criminals")

#What is her code name??

##We know she's 1km from a World Capitol Center. 
##So, we can draw a 1km buffer around her and check if any world capitols join with that buffer, but our spatial reference system is lat/long. We need a projected reference system to draw buffers because the buffer diameter is in the units of the crs and degrees change distance as they move away from the equator.

carmen <- st_transform(carmen, crs = 32648)

carmen <- st_buffer(carmen, dist = 1000)

##Oh no!! But, no worries.

carmen <- st_transform(carmen, crs = 4326)

carmen_cities <- st_join(carmen, capitol_cities)

st_contains
st_touches
