library(tidyverse)
library(leaflet)

##leaflet has a nice introduction page with all of its functions and ways of making maps. https://rstudio.github.io/leaflet/ 

m <- leaflet() %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  addMarkers(lng = ozone_summary$Longitude, lat = ozone_summary$Latitude)

show(m)
