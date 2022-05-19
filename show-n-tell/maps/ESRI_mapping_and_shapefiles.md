---
title: "simple mapping"
author: "Kristie Ellickson"
date: "3/3/2020"
output: html_document
---

## Tidy Tuesday Data - Simple Mapping and Spatial Analysis

<br>
<br>

Where are the trees? This is what I asked when I looked at the Tidy Tuesday San Francisco tree data. 

```r
library(readr)
library(sf)
library(tidyverse)
tree_data <- read_csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-01-28/sf_trees.csv")
```

<br>

```r
glimpse(tree_data)
```
<br>

Attempt to make a geographic object:
```r
##tell R where the geometry is
tree_data <- st_as_sf(tree_data, coords = c("longitude", "latitude"), crs = 4326)
```

<br>

Woop! We've got some missing coordinates. Fail!

```r
##tell R where the geometry is
tree_data <- tree_data %>%
  filter(!is.na(longitude))
```

<br>

Make a geographic object:

```r
##tell R where the geometry columns are
tree_data <- st_as_sf(tree_data, coords = c("longitude", "latitude"), crs = 4326)
```

<br>
Plot the data
```{r pressure}
plot(tree_data[1])
```

<br>
```r
tree_data <- read_csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-01-28/sf_trees.csv") %>%
             filter(!is.na(latitude))
```

<br>
Hey! That doesn't look like San Francisco
<br>

```r
tree_data <- tree_data %>% filter(latitude < 40)
```

<br>

```r
## Tell R where the geometry columns are

tree_data <- st_as_sf(tree_data, coords = c("longitude", "latitude"), crs = 4326)
```

<br>

Plot the data again

<br>

```r
plot(tree_data[1])
```

<br>
<br>
<br>

## Fun Friday Project

I decided to use the sf package in R to talk to MPCA's water and watershed program about how we might be able to collaborate.

<br>

First I pulled in the metals risks from MNRISKS

<br>

```r
data <- read_csv("X:/Agency_Files/Outcomes/Risk_Eval_Air_Mod/_Air_Risk_Evaluation/MNRISKS/2014 MNRISKS/Results/Pollutant_totals/checking_cobalt/interim_tables/metal_risks.csv")
```

<br>

Then, I pulled in a surface water layer. I used the st_read() function from the sf package. The st_read function will guess that the driver = "ESRI Shapefile", but if your data aren't an ESRI SHapefile, you can include the "driver = " argument.

<br>

```r
lakes <- st_read(dsn = "R:/surface_water", layer = "dowlakes_comprehensive_dnr")
```

<br>

By reading in with st_read(), I conserve the geographic features. To prove it,

<br>

```r
plot(lakes[1])
```

<br>

So, my simple question on a Friday afternoon was, where do high density of metal air emissions overlap with surface waters that might be of interest to MPCA Water and Watershed teams?

<br>

```r 
lakes <- lakes %>%
  filter(grepl("Lake", wb_class),
         outside_mn == "N",
         pw_basin_n != "Unnamed") %>%
  filter(!grepl("Pond", pw_basin_n)) %>%
  filter(!is.na(pw_basin_n))
```

<br>

Similar to the trees, I converted the mnrisks data into an sf object

<br>

```r
data <- st_as_sf(data, coords = c("long", "lat"), crs = 4326)
```

<br>

Then I checked to see if that worked

<br>

```r
plot(data[2])
```

<br>

I had to assume that the lakes and the MNRISKS data wouldn't have the same spatial reference system. But what are they?

<br>

```r
st_crs(lakes)
st_crs(data)
```

<br>

So, I transformed both to be certain that the spatial reference systems would align.

<br>

```r
data <- st_transform(data, crs = 26915, proj4string = "+proj=utm +zone=15 +datum=NAD83 +units=m +no_defs")

lakes <- st_transform(lakes, crs = 26915, proj4string = "+proj=utm +zone=15 +datum=NAD83 +units=m +no_defs")
```

<br>

Then I used the st_join() function to spatially join the two data sets: one points the other polygons. The default type of join in st_join() is an intersect. There are other functions for a variety of spatial joins in the sf package.

<br>

```r
data_lakes <- st_join(lakes, data)
```

<br>

Let's check what that looks like. Not much different than the original lake polygon, and I do not think anyone wants to work on ALL of the lakes near metal air emissions. So, I filter the data to higher metal emissions.

<br>


```r
plot(data[2])
```

```r

data_lakes <- data_lakes %>%
  group_by(dowlknum, pw_basin_n) %>%
  summarise(resident_cancer = max(resident_cancer),
            resident_hazard = max(resident_hazard),
            inhalation_cancer = max(inhalation_cancer),
            inhalation_hazard = max(inhalation_hazard)) %>%
  ungroup() %>%
  filter(resident_cancer > 1.5E-6)
```

<br>

Then I check the map.

<br>

```r
plot(data_lakes[3])
```

<br>

Then I save the shapefile with the joined risks and lakes.

<br>

```r
st_write(data_lakes, dsn = "X:/Agency_Files/Outcomes/Risk_Eval_Air_Mod/_Air_Risk_Evaluation/Presentations/Ellickson_WaterMeeting_2020", layer = "high_metals", driver = "ESRI Shapefile")
```

<br>

st_write will fail if there is already a shapefile saved in the destination folder. You can add the argument delete_layer = TRUE to your st_write() function to over write that layer.

<br>

Geometry is "sticky" in the sf package. Sometimes you may want to save a dataframe of your data without the geometry.

<br>

```r
st_geometry(lakes_risks_nogeo) <- NULL

write_csv(lakes_risks, "your destination folder.csv")
```

<br>

## But those maps were so ugly Kristie. How do I make better maps?

<br>

You can use the ggplot2 package

<br>

```r
library(ggplot2)

minnesota <- st_read(dsn = "R:/administrative_boundaries", layer = "state_mndot")

ggplot(data = data_lakes) +
geom_sf(data = minnesota) +
geom_sf(aes(fill = pw_basin_n)) +
theme(legend.position = "none") +
ylab("Latitude") +
xlab("Longitude") +
ggtitle("Intersection of high metal air emissions and surface water bodies")
  
```

<br>

Want to add a north arrow to the map? Install the ggsn package!

<br>

```r
#install.packages("ggsn")

library(ggsn)

ggplot(data = data_lakes) +
geom_sf(data = minnesota) +
geom_sf(aes(fill = pw_basin_n)) +
theme(legend.position = "none") +
ylab("Latitude") +
xlab("Longitude") +
ggtitle("Intersection of high metal air emissions and surface water bodies") +
north(data_lakes, location = "topleft")
```

<br>

You could also use the leaflet or plotly packages, but we will save that for another Tuesday!
