library(tidyverse)
library(sf)
library(raster)



library(rgdal)
library(rgeos)
library(maptools)
##blockgroups

##Blockgroups are online here: https://catalog.data.gov/dataset/tiger-line-shapefile-2016-state-minnesota-current-block-group-state-based

##and on the MPCA R drive here: R:\demographics

##or straight from R packages:
library(tigris)

#Read blockgroups shapefile for state of Minnesota
mn_blkgrps <- block_groups(state = 'MN')
mn_counties <- counties(state = 'MN')
?mn_pumas <- pumas(state = 'MN')
zipcodes_mn <- zctas(state = 'MN')

plot(mn_counties)

plot(mn_blkgrps[1])
crs(mn_blkgrps)


mn_blkgrps <- st_transform(mn_blkgrps, crs = 26915)


##Landuse for Outstate
##In about 168 instances the extraction of the nlcd raster by the census block group polygons resulted in NA for land use type in outstate. These areas were small, and the reason could not be tracked down. Therefore NAs for census block group extractions were eliminated.

##nlcd
nlcd_file <- "C:/Users/kmell/Desktop/TidyTuesday_landuse/tif_biota_landcover_nlcd_mn_2016/NLCD_2016_Land_Cover.tif"



##This raster is on the MPCA r drive R:\landuse_landcover\nlcd_2016_usgs
##and online https://www.mngeo.state.mn.us/chouse/land_use_recent.html

##Read landuse raster file.
##a great website on raster operations, but still applies to sp and not the updated sf package https://rspatial.org/raster/spatial/8-rastermanip.html

##you can do raster algebra, replacement functions
nlcd2016 <- raster(nlcd_file)
projection(nlcd2016)


plot(nlcd2016)

nlcd2016_neg <- nlcd2016 * -1
plot(nlcd2016_neg)

##this completes a dataframe later in the script.
mn_blkgrp_area <- mn_blkgrps %>%
  rowwise() %>%
  mutate(ALAND = as.numeric(ALAND), AWATER = as.numeric(AWATER), blkgrp_area = sum(ALAND, AWATER, na.rm = T)) %>%
  group_by(STATEFP, COUNTYFP) %>%
  mutate(county_area = sum(blkgrp_area, na.rm = T)) %>%
  dplyr::select(-TRACTCE, -BLKGRPCE, -NAMELSAD, -MTFCC, -FUNCSTAT, -INTPTLAT, -INTPTLON) %>%
  ungroup()

#Get list of GEOIDs in shapefile.
geoid_list <- unique(mn_blkgrp_area$GEOID)
n_geoid <- length(geoid_list)

#Get the resolution for the raster object
nlcd_res <- res(nlcd2016)[1] * res(nlcd2016)[2] # area per pixel

#get legend for nlcd values
nlcd_legend <- read_csv("C:/Users/kmell/Desktop/TidyTuesday_landuse/nlcd_legend.csv")

value_ids <- unique(nlcd_legend$VALUE)

nlcd_areas <- data.frame()

i = "270530261043"

for(i in geoid_list){
  print(paste0("Working on GEOID ", i))
  
  one_blkgrp <- mn_blkgrps %>%
    filter(GEOID == i)
  
  ##?raster::extract
  overlay <- raster::extract(nlcd2016, one_blkgrp, small = TRUE)
  
  tmp <- unlist(overlay)
  
  tmp <- data.frame(tmp, stringsAsFactors = FALSE)
  
  colnames(tmp) <- "value_id"
  
  tmp <- tmp %>%
    mutate(GEOID = i) %>%
    filter(!is.na(value_id)) %>%
    group_by(value_id, GEOID) %>%
    summarise(n_value = n(), 
              area_meters = n_value*nlcd_res, category = "Outstate") %>%
    ungroup()
  
  
  nlcd_areas <- bind_rows(tmp, nlcd_areas)
}


nlcd_areas <- left_join(nlcd_areas, nlcd_legend[,c("VALUE", "LAND_COVER_CLASS")], by = c("value_id" = "VALUE"))
                        

nlcd_areas <- nlcd_areas %>%
  rowwise() %>%
  mutate(STATEFP = substr(GEOID, 1, 2), COUNTYFP = substr(GEOID, 3, 5), value_legend = LAND_COVER_CLASS, GEOID = as.character(GEOID), value_id = as.character(value_id), value_area = area_meters) %>%
  dplyr::select(STATEFP, COUNTYFP, GEOID, value_legend, value_id, value_area, category)

##get the twin cities land use and bind_rows with outstate landuse

##Metro Area Landuse shapefile
##CRS is utm zone 15
met_lu_dir <- "C:/Users/kmell/Desktop/TidyTuesday_landuse/shp_plan_generl_lnduse2016"

met_lu_layer <- "GeneralizedLandUse2016"

#Read blockgroups shapefile
met_lu_shp <- st_read(dsn = met_lu_dir, layer = met_lu_layer, stringsAsFactors = FALSE)


unique(met_lu_shp$LUSE_DESC)









#met_lu_df <- as.data.frame(met_lu_shp, stringsAsFactors = FALSE)

##you can also strip the geometry using st_geometry and converting it to NULL
##st_geometry(met_lu_shp) <- NULL

met_lu_blkgrps <- st_join(met_lu_shp, mn_blkgrps)

fips_in_7_county_metro <- c("003", "053", "123", "019", "037", "139", "163")

##don't run this, takes forever
met_lu_blkgrps <- met_lu_blkgrps %>%
  dplyr::rename(value_id = LUSE2016, value_legend = LUSE_DESC) %>%
  dplyr::filter(COUNTYFP %in% fips_in_7_county_metro) %>%
  group_by(GEOID, value_id, value_legend, STATEFP, COUNTYFP) %>%
  dplyr::summarise(value_area = sum(Shape_Area, na.rm = T), category = "Metro") 

nlcd_areas <- nlcd_areas %>%
  filter(!COUNTYFP %in% fips_in_7_county_metro)

land_use_df <- bind_rows(nlcd_areas, met_lu_blkgrps_ids)

write_csv(land_use_df, "C:/Users/kmell/Desktop/TidyTuesday_landuse/nlcd_areas_nas.csv")

