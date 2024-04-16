

# Making WORLD maps

# Everything you needed to know about making maps of Russia and Alaska

So many folks probably know that my partner is working on his PhD in
Russian history - specifically studying environmental history of natural
disasters (earthquakes, tsunamis that follow…bears.) that occurred in
ares of Alaska (Kodiak) and an area of Russia called Kamchatka.

For those of you who don’t, go find Spencer Abbe at the PCA and ask
about his research :D.

``` r
library(sf)
```

    Linking to GEOS 3.11.2, GDAL 3.8.2, PROJ 9.3.1; sf_use_s2() is TRUE

``` r
library(tidyverse)
```

    ── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
    ✔ dplyr     1.1.4     ✔ readr     2.1.5
    ✔ forcats   1.0.0     ✔ stringr   1.5.1
    ✔ ggplot2   3.5.0     ✔ tibble    3.2.1
    ✔ lubridate 1.9.3     ✔ tidyr     1.3.1
    ✔ purrr     1.0.2     

    ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
    ✖ dplyr::filter() masks stats::filter()
    ✖ dplyr::lag()    masks stats::lag()
    ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors

``` r
library(rnaturalearth)
library(rnaturalearthdata)
```


    Attaching package: 'rnaturalearthdata'

    The following object is masked from 'package:rnaturalearth':

        countries110

``` r
library(rnaturalearthhires)
library(ggthemes)
library(janitor)
```


    Attaching package: 'janitor'

    The following objects are masked from 'package:stats':

        chisq.test, fisher.test

## Projection time!

So I needed to find a really good projection that would show just how
close Alaska, Russia, and Japan are to each other and Mercator…does not
do that. So I started looking and just did a search for “Alaska” on the
epsg.io webpage.

<https://epsg.io/?q=alaska>

I choose the following because I was also trying to determine bounding
boxes and going slowly insane. There’s a [handy
website](http://bboxfinder.com/) that lets you draw a bounding box but I
don’t think I got it work right…and it didn’t have all the projections
so that’s why I choose this one…it did have it.

**NAD83(NSRS2007) / Alaska Albers**

EPSG:3467 with transformation: 15931

Area of use: Puerto Rico (accuracy: 2.0)

``` r
crs <- 'EPSG:3467'
```

## Reading in the data…or making the data

Most of the data is coming from [Natural
Earth](https://www.naturalearthdata.com/) and I’m using the packages
from
[rOpenSci](https://docs.ropensci.org/rnaturalearth/articles/rnaturalearth.html)
to read them

- `rnaturalearth`

- `rnaturalearthdata`

- `rnaturalearthhires`

For any data that’s not available in those packages but is available
from Natural Earth, I’m downloading them and using the `sf` package to
read them in.

We’re also making our own data using the lat/longs from Google Maps in
some instances because it can be just too much of a pain to do anything
else.

I’m reading in countries (`countries` and `countries_labels`) twice
because I need the area of the United States but I don’t want the label
because it gets very weird looking very quickly.

``` r
important_areas <- data.frame(name = c("Kodiak", 'Anchorage',"Neftegorsk", 
                                       'Severo-Kurilsk','Petropavlovsk-Kamchatskiy',
                                       'Kuril Islands'),
                              latitude = c(57.790464,61.1088644, 52.9966664, 
                                           50.6768574, 53.0188809,47.0404291),
                              longitude = c(-152.403974,-149.4403109, 142.946389,
                                            156.1228553,158.6635664, 145.6909406)) %>% 
  st_as_sf(coords = c("longitude", "latitude")) %>% 
  st_set_crs(4269)

marine_polys <- st_read(dsn = "Data", "ne_10m_geography_marine_polys")
```

    Reading layer `ne_10m_geography_marine_polys' from data source 
      `C:\Users\monac\OneDrive\Documents\Abbe Dissertation Maps\Data' 
      using driver `ESRI Shapefile'
    Simple feature collection with 306 features and 37 fields
    Geometry type: MULTIPOLYGON
    Dimension:     XY
    Bounding box:  xmin: -180 ymin: -85.19206 xmax: 179.9999 ymax: 90
    Geodetic CRS:  WGS 84

``` r
sea_okhotsk <- marine_polys %>% 
  filter(name == 'Sea of Okhotsk')

ocean_names <- data.frame(name = c('Arctic Ocean', 'Pacific Ocean'),
                          latitude = c(74.3345286,46.6682647),
                          longitude = c(-171.4776189, 159.1572211)) %>% 
  st_as_sf(coords = c("longitude", "latitude")) %>% 
  st_set_crs(4269)

countries <- ne_countries(country = c("Russia", "Japan", 'China', 'Canada', 
                                             'Mongolia', 'North Korea', 'South Korea',
                                             'Taiwan', 'United States of America'), 
                                 scale = 10,
                                 type = "countries",
                                 returnclass = "sf") %>% 
  st_transform(crs = crs)

countries_labels <- countries %>% 
  filter(adm0_a3 != 'USA')

alaska <- ne_states(country = 'United States of America') %>% 
  filter(name == 'Alaska') %>% 
  st_transform(crs = crs)

kamchatka <- ne_states(country = 'Russia') %>% 
  filter(iso_3166_2 == 'RU-KAM')

sakhalin <- ne_states(country = 'Russia') %>% 
  filter(iso_3166_2 == 'RU-SAK')
```

Creating the boundary box was an exercise in frustration…It’s honestly
mostly trial and error so I hope better things for you than that. Also
because of our funky projection, I had to make sure that the `hjust` and
`vjust` are inside the `aes` function to work! You can pass them one
value or a vector for each item to be labeled.

``` r
bounding_box <- c(xmin = -6827218.5131, ymin = 4672230.8695, 
                  xmax = 3004574, ymax = 108426.3238)


ggplot(countries %>% 
         st_crop(bounding_box))+
  geom_sf(fill = 'grey')+
  geom_sf_text(data = countries_labels %>% 
                 st_crop(bounding_box),
               aes(label = geounit), size = 4, fontface = 'italic') +
  geom_sf(data = alaska, fill = 'grey')+
  geom_sf_text(data = alaska, aes(label = name),
               size = 4, fontface = 'italic')+
  geom_sf_text(data = kamchatka, aes(label = paste(name, "\nPennisula"),
                                     hjust = .1, vjust = 2),
               size = 4, fontface = 'italic') +
  geom_sf_text(data = sakhalin, aes(label = name, hjust = -.1, vjust = 1.5),
               size = 4, fontface = 'italic') +
  geom_sf_text(data = important_areas %>% 
                 filter(name %in% c('Kodiak', 'Kuril Islands')), 
               aes(label = name, hjust = -.1, vjust = 1.5),
               fontface = 'italic') +
  geom_sf_text(data = ocean_names, aes(label = name),
               size = 4, fontface = 'bold.italic')+
  geom_sf_text(data = sea_okhotsk, aes(label = name, vjust = -1.25),
               size = 4, fontface = 'bold.italic')+
  theme_map()
```

![Region containing Kamchatka Pennisula and Kodiak
Island](Tidy-Tuesday-Presentation_files/figure-commonmark/unnamed-chunk-4-1.png)

Ta-da!!! This is our first map! Now we are going to do some detail work!

### Alaska!

``` r
populated_places <- st_read(dsn = "Data", "ne_10m_populated_places") %>% 
  clean_names()

alaska_cities <- populated_places %>% 
  filter(adm1name == "Alaska",
         name %in% c('Anchorage', "Juneau", "Kodiak", "Seward", "Valdez",
                     "Fairbanks", "Nome", "Kenai", "Sitka"))

alaska_water <- marine_polys %>% 
  filter(name %in% c('Bering Sea', 'Gulf of Alaska'))

bounding_box_ak <- c(xmin = -2827218.5131, ymin = 3672230.8695, 
                     xmax = 2004574, ymax = 108426.3238)

hjust = c(0, 1.25, 1.25, -.25, 0, 0, 0, 0, 1)
vjust = c(1.75, 0, 0, -.5, -1, -1, -1, -1, -1)
```

``` r
ggplot(countries %>% 
         st_crop(bounding_box_ak))+
  geom_sf()+
  geom_sf_text(data = countries_labels %>% 
                 st_crop(bounding_box_ak), aes(label = name),
               size = 4, fontface = 'italic')+
  geom_sf(data = alaska, fill = 'grey')+
  geom_sf_text(data = alaska, aes(label = name, vjust = -1.75),
               size = 4, fontface = 'italic') +
  geom_sf(data = alaska_cities, size = 2)+
  geom_sf_text(data = alaska_cities, aes(label = name, hjust = hjust, 
                                         vjust = vjust), size = 3) +
  geom_sf_text(data = ocean_names %>% 
                 filter(name == 'Arctic Ocean'), aes(label = name),
               size = 4, fontface = 'bold.italic')+
  geom_sf_text(data = alaska_water, aes(label = name, hjust = c(-.25, 1.25),
                                        vjust = 1.5),
               size = 4, fontface = 'bold.italic')+
  theme_map()
```

![](Tidy-Tuesday-Presentation_files/figure-commonmark/unnamed-chunk-6-1.png)

### Kodiak Island

This dataset came from the [Kodiak Island Borough GIS Data
Portal](https://data-kiborough.opendata.arcgis.com/)!

``` r
kib <- st_read(dsn = "Data", 
               "41878b02-5a07-46d1-bdf4-e18cfa3ecb7a202049-1-3ncuwz.m011q") %>% 
  clean_names()
```

    Reading layer `41878b02-5a07-46d1-bdf4-e18cfa3ecb7a202049-1-3ncuwz.m011q' from data source `C:\Users\monac\OneDrive\Documents\Abbe Dissertation Maps\Data' 
      using driver `ESRI Shapefile'
    replacing null geometries with empty geometries
    Simple feature collection with 1910 features and 6 fields (with 1 geometry empty)
    Geometry type: POLYGON
    Dimension:     XY
    Bounding box:  xmin: -156.8153 ymin: 55.7564 xmax: -151.7897 ymax: 58.97606
    Geodetic CRS:  WGS 84

``` r
kib_poi <- st_read(dsn = 'Data', "KIB_GeographicNames") %>% 
  clean_names()
```

    Reading layer `KIB_GeographicNames' from data source 
      `C:\Users\monac\OneDrive\Documents\Abbe Dissertation Maps\Data' 
      using driver `ESRI Shapefile'
    Simple feature collection with 1208 features and 9 fields
    Geometry type: POINT
    Dimension:     XY
    Bounding box:  xmin: -156.7878 ymin: 55.76333 xmax: -151.7914 ymax: 59.00833
    Geodetic CRS:  WGS 84

``` r
kib_populated_places <- kib_poi %>% 
  filter(name %in% c("Port Lions", "Old Harbor", "Kodiak", 'Karluk'))

kib_bays_islands <- kib_poi %>% 
  filter(name %in% c('Woody Island', 'Afognak Island', 'Kalsin Bay', 'Three Saints Bay',
                     'Spruce Island'),
         type %in% c('Island', 'Bay'))
```

``` r
ggplot(kib %>% 
         filter(region == 'Kodiak Archipelago'))+
  geom_sf()+
  geom_sf(data= kib_populated_places, size = 3) +
  geom_sf_text(data = kib_populated_places, aes(label = name,
                                                hjust = c(0.75, -.25, 0, 0.5),
                                                vjust = c(-1.25, -1, -1, -1.25)),
               size = 3)+
  geom_sf_text(data = kib_bays_islands, aes(label = name, 
                                            hjust = c(0.5, -.1, -.1, 0, -.1),
                                            vjust = c(.5, -1.25, -1.25, 1, 0)),
               size = 4, fontface = 'italic') +
  coord_sf(xlim = c(-157, -150), ylim = c(55.7564, 58.97606), expand = F)+
  theme_map()
```

    Warning in st_point_on_surface.sfc(sf::st_zm(x)): st_point_on_surface may not
    give correct results for longitude/latitude data
    Warning in st_point_on_surface.sfc(sf::st_zm(x)): st_point_on_surface may not
    give correct results for longitude/latitude data

![](Tidy-Tuesday-Presentation_files/figure-commonmark/unnamed-chunk-8-1.png)

### Kamchatka!

``` r
kamchatka <- ne_states(country = 'Russia') %>% 
  filter(name == 'Kamchatka')

kamchatka_cities <- populated_places %>% 
  filter(adm1name == "Kamchatka")

kamchatka_water <- marine_polys %>% 
  filter(name %in% c('Bering Sea','Sea of Okhotsk'))
```

``` r
ggplot(kamchatka)+
  geom_sf()+
  geom_sf_text(aes(label = name, vjust = 1.5), size = 4, fontface = 'italic')+
  geom_sf(data = kamchatka_cities, size = 2)+
  geom_sf_text(data = kamchatka_cities, 
               aes(label = name, vjust = -1), size = 3)+
  geom_sf_text(data = kamchatka_water %>% 
                 st_crop(xmin = 145.5512, ymin = 50.86392, xmax = 174.5124, ymax = 64.93425),
               aes(label = name, hjust = c(0,.5), vjust = c(-10, 0)), size = 4, fontface = 'bold.italic')+
  theme_map()
```

    Warning: attribute variables are assumed to be spatially constant throughout
    all geometries

    Warning in st_point_on_surface.sfc(sf::st_zm(x)): st_point_on_surface may not
    give correct results for longitude/latitude data
    Warning in st_point_on_surface.sfc(sf::st_zm(x)): st_point_on_surface may not
    give correct results for longitude/latitude data
    Warning in st_point_on_surface.sfc(sf::st_zm(x)): st_point_on_surface may not
    give correct results for longitude/latitude data

![](Tidy-Tuesday-Presentation_files/figure-commonmark/unnamed-chunk-10-1.png)

