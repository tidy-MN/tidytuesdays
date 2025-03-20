##install.packages("osmdata")
##install.packages("extrafont")
library(osmdata)
library(sf)
library(tidyverse)
library(extrafont)
#font_import()
#loadfonts(device = "win")
library(tigris)

# Avoid internet error
assign("has_internet_via_proxy", TRUE, environment(curl::has_internet))

# Lat/Long boundary box for city coordinates
bbx <- getbb("Duluth, MN")


## Set colors ----
water_col <-  "#EBAD1B" # mustard #rgb(0.92, 0.679, 0.105)  

land_col  <-  "#343c47" # dark greyish blue

hwy_col   <-  "#ab0f3d" # maroony pink

lil_roads <- "gray"

font_col <- "#ffffff"  #white

running_paths <- "chartreuse4"

# Road options ----
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

counties <- st_crop(counties, dul_center_buff %>% st_transform(crs = 4269),
xmin = min(bbx[1,]), xmax = max(bbx[1,]),
ymin = min(bbx[2,]), ymax = max(bbx[2,]))

water <- bbx %>%
  opq() %>%
  add_osm_feature(key = "waterway", value = c("stream", "river")) %>%
  osmdata_sf()

#get center
dul_center_df <- data.frame(a = 1, lat = "46.77474735226708", long = "-92.11478672753759", stringsAsFactors = FALSE)

dul_center <- st_as_sf(dul_center_df, coords = c("long", "lat"), crs = 4326, remove = FALSE)

dul_center_buff <- dul_center %>%
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

#map

# Add a mustard colored river
map <- map + 
  geom_sf(data = water$osm_lines, 
          inherit.aes = TRUE,
          col = water_col) 

## Center and trim
center_y <- mean(bbx[2,])

center_x <- mean(bbx[1,])

ggplot() + geom_sf(data = counties, fill = land_col, lwd  = 0)  + 
  geom_text(aes(x = 0.991*center_x, y = center_y), 
            label = "Duluth, Minnesota", 
            size = 15, family = "Palatino", color = "black")


# Trim the edges and drop legends              
map <- map + 
  theme_void() +
  #coord_sf(dul_center_buff) +
  coord_sf(xlim = c(bbx["x", "min"], bbx["x", "max"]),
           ylim = c(bbx["y", "min"], bbx["y", "max"]),
           expand = T) +
  theme(legend.position = "none") 

#map

map <- map + 
  #geom_text(aes(x = -92.0731, y = 46.788), 
  #          label = "Duluth, Minnesota", 
  #          size = 15, family = "Palatino", color = font_col) +
  annotate("text", x = -91.99, y = 46.793, 
           label = "Duluth\nMinnesota", 
           size = 15, family = "Cooper Black", color = font_col) +
  annotate("text", x = -91.99, y = 46.768, 
           label = "46.79°N — 92.073°W", 
           size = 9, family = "Cooper Black", color = "grey85", alpha = 1)

## Check it
#map

## Save it BIG
ggsave(filename = "Duluth_poster.png",
       plot = map,
       scale = 1, 
       width = 14,
       height = 12,
       units = "in",
       dpi   = 500)   # Use 50 for testing quickly
