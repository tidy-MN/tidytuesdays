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
bbx <- getbb("Northfield, MN")


##Get colors
water_col <-  "#EBAD1B" # mustard #rgb(0.92, 0.679, 0.105)  

land_col  <-  "#343c47" # dark greyish blue

hwy_col   <-  "#ab0f3d" # maroony pink

lil_roads <- "gray"

font_col <- "#ffffff"  #white

running_paths <- "chartreuse4"

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
counties <- counties(state = "MN", cb = T, class = "sf")

counties <- st_crop(counties, nf_center_buff %>% st_transform(crs = 4269))
                       xmin = min(bbx[1,]), xmax = max(bbx[1,]),
                       ymin = min(bbx[2,]), ymax = max(bbx[2,]))

water <- getbb("Northfield, MN") %>%
  opq() %>%
  add_osm_feature(key = "waterway", value = c("stream", "river")) %>%
  osmdata_sf()

#get center
nf_center_df <- data.frame(a = 1, lat = "44.4546344", long = "-93.2005066", stringsAsFactors = FALSE)

nf_center <- st_as_sf(nf_center_df, coords = c("long", "lat"), crs = 4326, remove = FALSE)

nf_center_buff <- nf_center %>%
  st_transform(crs = 26915) %>%
  st_buffer(dist = 10000)

##Make the map
##Add the counties
map <- ggplot() + geom_sf(data = counties, fill = land_col, lwd  = 0) 
map

# Add buildings
buildings <-  bbx %>%
  opq()%>%
  add_osm_feature(key   = "building") %>% #, 
                 # value = c("residential", "living_street",
                #            "secondary_link",
                #            "tertiary", "tertiary_link",
               # %            "service", "unclassified")) %>%
  osmdata_sf()
# count the needed levels of a factor
number <- nlevels(buildings$osm_points)

# repeat the given colors enough times
palette <- rep(c("#543005","#8c510a","#bf812d","#dfc27d","#f6e8c3","#f5f5f5","#c7eae5","#80cdc1","#35978f","#01665e","#003c30"), length.out = number)

#palette <- sample(palette, number)

map <- map + geom_sf(data = buildings$osm_points, 
                     alpha = 0.8) +
  scale_fill_manual(values = palette) + 
  theme(legend.position = "none")
map

#map
# Add lil roads
map <- map + geom_sf(data  = paths$osm_lines,
                     col   = lil_roads,
                     size  = 0.44,
                     alpha = 0.65) 

# Add big roads                
map <- map + geom_sf(data  = hwys$osm_lines,
                     col   = hwy_col,
                     size  = 0.7,
                     alpha = 0.7) 

# Add running paths
map <- map + geom_sf(data  = running$osm_lines,
                     col   = running_paths,
                     size  = 0.8,
                     alpha = 0.65) 

map

# Add a mustard colored river
map <- map + 
    geom_sf(data = water$osm_lines, 
          inherit.aes = TRUE,
          col = water_col) 

##Center and trim
center_x <- mean(bbx[1,])

bottom_y <- min(bbx[2,])


# Trim the edges and drop legends              
map <- map + 
  theme_void() +
  #coord_sf(nf_center_buff) +
  coord_sf(xlim = c(bbx["x", "min"], bbx["x", "max"]),
           ylim = c(bbx["y", "min"], bbx["y", "max"]),
           expand = T) +
  theme(legend.position = "none") 

map

map <- map + 
  geom_text(aes(x = center_x, y = 1.00004*bottom_y), 
            label = "Northfield, Minnesota", 
            size = 15, family = "Palatino", color = font_col)

##Check it
map

##Save it BIG
setwd("C:/Users/kmell/Desktop/present_maps")
ggsave(filename = "coldspring_by_me.png",
       scale = 1, 
       width = 14,
       height = 12,
       units = "in",
       dpi   = 500)  
