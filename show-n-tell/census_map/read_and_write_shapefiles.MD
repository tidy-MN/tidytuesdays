
```r
library(tidyverse)
library(sf)
library(tidycensus)
library(tigris)

# Set the cache to TRUE to keep a copy of the boundaries and save future time 
options(tigris_use_cache = TRUE)

# Get county coordinates
?counties

mn_shp <- counties("MN", cb = FALSE) 
# Cartographic boundary

glimpse(mn_shp)

plot(mn_shp)

# Save a shapefile
write_sf(mn_shp, "County_shapes.shp")

henn <- tracts(state = "MN", county = "Hennepin", cb = F, year = 2020)

# Median incomes
## Find variable codes
?load_variables

deca10 <- load_variables(2010, "sf1", cache = TRUE)

acs20 <- load_variables(2020, "acs5", cache = TRUE)

income20 <- get_acs(geography = "tract", 
                    variable  = "B19013_001",
                    state  = "MN",
                    county = "Hennepin",
                    year   = 2020, 
                    survey = "acs5")

# Rename estimate column to income
income20 <- rename(income20, income = estimate)

# Join income data to shapefile
henn_inc <- henn %>% left_join(income20, by = "GEOID")

# Base plot
plot(henn_inc[,15])

# ggplot
ggplot(henn_inc) + 
  geom_sf(aes(fill = income)) + 
  scale_fill_viridis_c() +
  labs(title = "Median Household Income by Census tract")


st_crs(henn_inc)


# Centroids
tract_centers <- henn_inc %>% st_centroid()

# Quick plotlibrary
tract_centers %>% plot()


# Areas
henn_inc <- henn_inc %>% 
            mutate(area = st_area(geometry))

# Plot of BIGGEST 5 tracts
henn_inc %>% 
  filter(rank(area) > 324) %>%
  select(income) %>% 
  plot()


# Interactive Leaflet map
library(leaflet)

henn_inc <- st_transform(henn_inc, 4326)

# Create a color legend based on income
legend_colors <- colorQuantile("Blues", henn_inc$income, n = 5)

legend_colors <- colorNumeric(
  palette = "viridis",
  domain = henn_inc$income)

legend_colors(45000)


# Polygon map colored by income
web_map <- leaflet(henn_inc) %>%
  addProviderTiles(providers$OpenStreetMap) %>% 
  addPolygons(fillColor = ~legend_colors(income), 
              fillOpacity = 0.75,
              color       = "white", # Border color
              weight      = 1,       # Border width
              popup = paste("Census Tract: ", henn_inc$GEOID,
                            "<br> Median HH Income: ", henn_inc$income)) 


# Show map
web_map


# Add gray basemap and a marker for your favorite Tract
web_map <- web_map %>%
  addProviderTiles(providers$CartoDB.Positron, options = providerTileOptions(opacity = 0.75)) %>%
  addMarkers(data = st_centroid(filter(henn_inc, GEOID == 27053027002)), 
             label = "You are not here.",
             labelOptions = labelOptions(noHide = T)) 


# Add a floating legend
web_map <- web_map %>%
  addLegend("topleft",
            pal = legend_colors,
            values = ~income,
            title = "Median HH Income")

web_map


# Easy basemap
library(basemap)

leaflet(henn_inc) %>%
  addBasemap(dark = TRUE, layers = TRUE) %>%
  addPolygons(fillColor = ~legend_colors(income), 
              fillOpacity = 0.75,
              color       = "white", 
              weight      = 1,       
              popup = paste("Census Tract: ", henn_inc$GEOID,
                            "<br> Median HH Income: ", henn_inc$income)) 
```
