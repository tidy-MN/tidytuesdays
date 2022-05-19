##install.packages("osmdata")
##install.packages("extrafont")
library(osmdata)
library(sf)
library(tidyverse)
library(extrafont)
font_import()
loadfonts(device = "win")
library(tigris)

# Lat/Long boundary box for city coordinates
bbx <- getbb("Fargo, North Dakota")

##Get colors
water_col <-  "#EBAD1B" # mustard #rgb(0.92, 0.679, 0.105)  

land_col  <-  "#343c47" # dark greyish blue

hwy_col   <-  "#ab0f3d" # maroony pink

lil_roads <- "gray"

font_col <- "#ffffff"  #white

running_paths <- "chartreuse4"

#Get the attributes
crossings <- bbx %>%
  opq() %>%
  add_osm_feature(key   = "railway", 
                  value = c("crossing")) %>%
  osmdata_sf()


road_types <- c("motorway", "motorway_link")

hwys <- bbx %>%
  opq()%>%
  add_osm_feature(key   = "highway", 
                  value = road_types) %>%
  osmdata_sf()


paths <- bbx %>%
  opq()%>%
  add_osm_feature(key   = "highway", 
                  value = c("residential", "living_street",
                            "secondary_link",
                            "tertiary", "tertiary_link",
                            "service", "unclassified")) %>%
  osmdata_sf()

running <- bbx %>%
  opq()%>%
  add_osm_feature(key   = "highway", 
                  value = c("pedestrian", "footway",
                            "track","path")) %>%
  osmdata_sf()



##Get county geometries
counties_nd <- counties(state = "ND", cb = T, class = "sf")

counties_nd <- st_crop(counties_nd,
                    xmin = min(bbx[1,]), xmax = max(bbx[1,]),
                    ymin = min(bbx[2,]), ymax = max(bbx[2,]))

get_water_mn <- function(county_id){
  area_water("MN", county_id, class = "sf")
}

water_mn <- do.call(rbind, 
                 lapply(counties_mn$COUNTYFP, get_water_mn))

water_mn <- st_crop(water_mn,
                 xmin = min(bbx[1,]), xmax = max(bbx[1,]),
                 ymin = min(bbx[2,]), ymax = max(bbx[2,]))

st_cut <- function(x, y) {
  st_difference(x, st_union(y))
}

counties_nd <- st_cut(counties_nd, water_mn)


##Make the map
##Add the counties
map <- ggplot() + geom_sf(data = counties_nd, fill = land_col, lwd  = 0) 


# Add big roads                
map <- map + geom_sf(data  = hwys$osm_lines,
               col   = hwy_col,
               size  = 0.7,
               alpha = 0.7) 

# Add lil roads
map <- map + geom_sf(data  = paths$osm_lines,
                     col   = lil_roads,
                     size  = 0.44,
                     alpha = 0.65) 

# Add running paths
map <- map + geom_sf(data  = running$osm_lines,
                     col   = running_paths,
                     size  = 0.8,
                     alpha = 0.65) 

# Add train X             
map <- map + geom_sf(data  = crossings$osm_points,
                     col   = "plum4",
                     size  = 1,
                     alpha = 0.7) 

##Center and trim
center_x <- mean(bbx[1,])

bottom_y <- min(bbx[2,])


# Trim the edges and drop legends              
map <- map + 
  theme_void() +
  coord_sf(xlim = c(bbx["x", "min"], bbx["x", "max"]),
           ylim = c(bbx["y", "min"], bbx["y", "max"]),
           expand = F) +
  theme(legend.position = "none") 

map <- map + 
  geom_text(aes(x = center_x, y = 1.00021 *bottom_y), 
            label = "Fargo, North Dakota", 
            size = 12, family = "Palatino", color = font_col)

# Add a mustard water background
map <- map + 
  theme(panel.background = element_rect(fill = water_col))

##Check it
map

##Save it BIG
setwd("C:/Users/kmell/Desktop/present_maps")
ggsave(filename = "fargo_by_me.png",
       scale = 1, 
       width = 14,
       height = 12,
       units = "in",
       dpi   = 500)  
