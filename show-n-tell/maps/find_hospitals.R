library(tidyverse)
library(sf)

## Conver RGB color to Hex #
rgb(108, 124, 138, maxColorValue = 255)
# "#8C370C"

## MN GeoCommons
- MN GEOCOMMONS: https://gisdata.mn.gov/
- Enviro Justice areas: https://gisdata.mn.gov/dataset/env-ej-mpca-census
- Hospitals: https://gisdata.mn.gov/dataset/health-facility-hospitals
- MPCA EJ Story map

# Download the long way

## Get Shapefile
ej_url <- "https://resources.gisdata.mn.gov/pub/gdrs/data/pub/us_mn_state_pca/env_ej_mpca_census/shp_env_ej_mpca_census.zip"

# Create a folder
dir.create("EJ_shapefiles")

zip_file <- "EJ_shapefiles/ej_shapefiles.zip"

# Download ZIP file into it
download.file(ej_url, zip_file)

# View file names
shapefiles_list <- unzip(zip_file, list = T) %>%
                   filter(str_detect(Name, "shp"), !str_detect(Name, "xml"))

shapefiles_list

# Choose the ones you want by looking for the word "trib"
ej_file <- shapefiles_list %>%
           filter(!str_detect(Name, "trib")) %>% .$Name

tribe_file <- shapefiles_list %>%
             filter(str_detect(Name, "trib")) %>% .$Name

# Unzip everything
unzip("EJ_shapefiles/ej_shapefiles.zip", exdir = "EJ_shapefiles")

# Read in the shapefiles with st_read()
ej_shapes    <- st_read(paste0("EJ_shapefiles/", ej_file))

tribe_shapes <- st_read(paste0("EJ_shapefiles/", tribe_file))

# Glimpse the columns or attributes
glimpse(ej_shapes)


# Shortcut: Download with a package
library(mpcaej) #remotes::install_github("MPCA-data/mpcaej")

ej_shapes    <- ej_shapes

tribe_shapes <- tribe_shapes

map_ej()


#-------------------#
# Super powers!
#-------------------#

# Isolate / split-off
## First item
ej_1 <- ej_shapes[1, ]

plot(ej_1)

## Second item
ej_2 <- ej_shapes[2, ]

plot(ej_2)


# Join together
friends <- rbind(ej_1, ej_2)

plot(friends[,1])

# Filter
## Higher populations
hi_pops <- filter(ej_shapes, total_pop > 12000)

plot(hi_pops[,1])

## Hennepin county
hennepin <- filter(ej_shapes, countyfp == "053")

plot(hennepin)

#-------------------#
# Map the polygons
#-------------------#
library(leaflet)

# Map center at UMN
center <- tibble(lat = 44.96, lng = -93.22)

st_crs(tribe_shapes)

st_transform(tribe_shapes, 4326) %>% st_crs()


leaflet(st_transform(tribe_shapes, 4326)) %>%
  addProviderTiles(providers$CartoDB.PositronNoLabels,
                   options = providerTileOptions(opacity = 0.95)) %>%
  addProviderTiles(providers$Stamen.Toner,
                   options = providerTileOptions(opacity = 0.45)) %>%
  addPolygons(color        = "purple",
              weight       = 1,
              smoothFactor = 1.4,
              opacity      = 0.9,
              fillOpacity  = 0.2) %>%
  addPolygons(data = ej_shapes %>%
                       st_transform(4326) %>%
                       filter(statuspoc == "YES" | status185x == "YES"),
              color        = "steelblue",
              weight       = 1,
              smoothFactor = 1.5,
              opacity      = 0.8,
              fillOpacity  = 0.2)


#-----------------------------------------#
# Alternative, read from GDB geo-database
#----------------------------------------#
if (FALSE) {

  library(rgdal)

  ej_gdb_url <- "https://resources.gisdata.mn.gov/pub/gdrs/data/pub/us_mn_state_pca/env_ej_mpca_census/fgdb_env_ej_mpca_census.zip"

  dir.create("EJ_db")

  zip_file <- "EJ_db/ej_gdb.zip"

  # Download to new folder
  download.file(ej_gdb_url, zip_file)

  # Extract
  unzip(zip_file, exdir = "EJ_db")

  # Show all layers
  ogrListLayers("EJ_db/env_ej_mpca_census.gdb")

  # Read tribal layer
  tribal_gdb <- st_read(dsn   = "EJ_db/env_ej_mpca_census.gdb",
                        layer = "census_tribal_areas")
}


#--------------------------#
# Get Hospitals locations
#--------------------------#
## Data source
## Hospitals: https://gisdata.mn.gov/dataset/health-facility-hospitals
hosp <- st_read("X:/Agency_Files/Outcomes/Risk_Eval_Air_Mod/_Air_Risk_Evaluation/R/Packages/mpca_ej/Hospitals/hospitals.shp")

plot(hosp[ , 1])


#---------------------------------#
# Get traffic locations and volume
#---------------------------------#
# Traffic layer
traff <- st_read("X:/Agency_Files/Outcomes/Risk_Eval_Air_Mod/_Air_Risk_Evaluation/R/Packages/mpca_ej/Traffic/2014_traffic_segments.shp") %>%
         clean_names() %>%
         st_zm()

summary(traff$curr_vol)


##  High Traffic segments
high_volume   <- 10000 #10,000 daily vehicles

buffer_meters <- 300


# High traffic roads (busy roads)
hi_traffic <- filter(traff, curr_vol >= high_volume)

plot(hi_traffic[1,1])

#--------------------------#
# Buffers !!!
#--------------------------#

# Add 300 meter buffer around roads
hi_traffic <- st_buffer(hi_traffic, dist = as_units(300, "m"))

plot(hi_traffic[1, 1])


# Spatial analysis

#Blank table to store results
results <- data.frame()
results[1, ] <- NA

# Find hospitals that overlap the high traffic buffers
high_hosp <- st_join(hosp, hi_traffic) %>%
              filter(!is.na(curr_vol)) %>%
              group_by(NAME) %>%
              slice(1)

plot(high_hosp[,1])

nrow(high_hosp) / nrow(hosp)
#28%

# How many hospitals near High Traffic?
results$"Statewide count"   <- nrow(hosp)

results$"Near high traffic" <- nrow(high_hosp)


#-------------------#
# Nearest neighbor
#-------------------#

# Find nearest hospital for each Census Tract group
non_ej        <- filter(ej_shapes, statuspoc != "YES", status185x != "YES")

ej_poc        <- filter(ej_shapes, statuspoc == "YES")

ej_low_income <- filter(ej_shapes, status185x == "YES")


# Count near high traffic for Non-EJ
near_nonej <- st_nearest_feature(non_ej, hosp)

# This spits out a list of row numbers that correspond to the hospital table
## Here's the nearest hospital for the 1st non_ej Census Tract
hosp[122, ]

# Using the entire list of nearest hospitals
# We can attach their ID's as a new column to the Census Tract shapes
non_ej$nearest_hosp <-  hosp[near_nonej, ]$HFID

# And count how many of those hospitals are near high traffic
non_ej_count <- non_ej$nearest_hosp %in% high_hosp$HFID %>% sum()

results$"% Non-EJ Areas w/ Nearest Hospital in High Traffic" <- paste0(round(100 * near_nonej_count / nrow(non_ej)), "%")
#57%


#-----------------------------#
# Repeat for the other groups
#-----------------------------#

## Count near high traffic for low income
near_low <- st_nearest_feature(ej_low_income, hosp)

ej_low_income$nearest_hosp <- hosp[near_low, ]$HFID

near_low_count <- ej_low_income$nearest_hosp %in% high_hosp$HFID %>% sum()

results$"% EJ: Low Income Areas w/ Nearest Hospital in High Traffic" <- paste0(round(100 * near_low_count / nrow(ej_low_income)), "%")
#65%

# Count near high traffic for POC
near_poc <- st_nearest_feature(ej_poc, hosp)

ej_poc$nearest_hosp <-  hosp[near_poc, ]$HFID

near_poc_count <- ej_poc$nearest_hosp %in% high_hosp$HFID %>% sum()

results$"% EJ: POC Areas w/ Nearest Hospital in High Traffic" <- paste0(round(100 * near_poc_count / nrow(ej_poc)), "%")

#90% !!!

# View all results
View(results)


# Drop the geometry column when you want save the data to CSV
# Or don't need the spatial information
hosp_data <- st_set_geometry(hosp, NULL)

write_csv(hosp_data, "Hospitals_in_MN.csv")

#


