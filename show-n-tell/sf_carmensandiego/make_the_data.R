library(sf)
library(tidyverse)

world_coords <- st_read("data/TM_WORLD_BORDERS-0.3.shp")
st_crs(world_coords)

##global_buf <- st_union(world_coords)

st_write(global_buf, "data/global_buffer.shp")

st_read("data/global_buffer.shp")

global_grid <- st_make_grid(
  global_buf, cellsize = 0.5, what = "centers")

global_grid <- st_as_sf(global_grid)
global_grid <- mutate(global_grid, count = 1:n())

global_capitols <- read_csv("data/concap.csv")


characters <- read_csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2018/2018-05-29/week9_comic_characters.csv")

characters <- characters %>%
  select(name, id, align, eye, hair, sex, alive)

carm_san <- data.frame(name = "Garden the Teacher", id = "Public Identity", align = "Reformed Criminals", eye = "Hazel Eyes", hair = "Red Hair", alive = "Living Characters", sex = "Female Characters", stringsAsFactors = FALSE)

characters <- bind_rows(characters, carm_san)

characters <- characters %>%
  mutate(count = sample(1:85698, 23273))

grid_characters <- left_join(global_grid, characters)
grid_characters <- dplyr::select(grid_characters, -count) %>% unique()


grid_characters <- grid_characters %>%
  mutate(x = as.character(x))

grid_characters <- grid_characters %>%
  mutate(x = ifelse(name == "Garden the Teacher", "c(104.91671, 11.551)", x)) %>%
  filter(!is.na(x))


check <- filter(grid_characters, name == "Garden the Teacher")



st_write(grid_characters, "data/grid_characters.shp", delete_layer = TRUE)

write_csv(grid_characters, "data/grid_characters.csv")
