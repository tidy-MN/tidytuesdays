library(sf)
library(tigris)
library(ggplot2)
library(tidyverse)

states <- states(cb = TRUE)

mn <- filter(states, STUSPS == "MN")

set.seed(20210518)

#Use a bigger number for a more deranged yarn map
points <- st_sample(mn, 40)

pairs <- expand_grid(pt1 = points, pt2 = points) %>%
  rownames_to_column("id") %>%
  pivot_longer(-id) %>%
  select(-name) %>%
  unnest_wider(value)
  
pairs2 <- group_by(pairs, id) %>%
  summarize(geo = list(tibble(lon, lat) %>% as.matrix %>% st_linestring)) %>%
  mutate(color = runif(n())) %>%
  st_as_sf()

st_crs(pairs2) <- st_crs(mn)

ggplot(pairs2) + geom_sf(aes(color = color)) + geom_sf(data = mn, fill = NA, size = 2) +
  scale_color_gradientn(colors = rainbow(100)) +
  theme_classic()
