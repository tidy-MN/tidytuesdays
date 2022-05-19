---
title: leaflet - Maps in R
author: "@TidyTuesdays"
---



# Maps are fun again

<br>

![](https://leafletjs.com/docs/images/logo.png)

https://rstudio.github.io/leaflet/



![](https://www.craftsdirect.com/cache/5a482e0b61288738ba7462d28d1dde09.jpg)





# Maps as data

```{r, eval = T}

# Create a point
data <- data.frame(lat  = 46.24, long = -93.86) 
                     
```                    

<br>




---
# Maps as charts

```{r, eval = T}
library(tidyverse)

# Create a point
data <- data.frame(lat = 46.24, long = -93.86) 

# X/Y scatterplot
ggplot(data, aes(y = lat, x = long)) + geom_point()
                     
```                    


---
# Maps w/ leaflet

```{r, eval = T}
library(leaflet)

# Create a point
data <- data.frame(lat = 46.24, long = -93.86) 

# Leaflet
leaflet(data) %>%
   addTiles() %>%
   addMarkers(lat = ~lat, lng = ~long) #<< 
    
```




---
# Maps w/ leaflet

```{r, eval = T}
# Leaflet
leaflet(data) %>%
   addTiles() %>%
   addCircleMarkers(lat = ~lat, lng = ~long) #<< 
    
```



---
# Maps in leaflet

```{r, eval = T}
# Leaflet
leaflet(data) %>%
   addTiles() %>%
   addCircleMarkers(lat = ~lat, lng = ~long,
                    color = "tomato") #<< 
    
```



---
# Maps w/ leaflet

```{r, eval = T}
# Leaflet
leaflet(data) %>%
   addTiles() %>%
   addCircleMarkers(lat = ~lat, lng = ~long,
                    color  = "tomato",
                    radius = 18) #<< 
    
```




---
# Maps w/ leaflet

```{r, eval = T}
# Leaflet
leaflet(data) %>%
   addTiles() %>%
   addCircleMarkers(lat = ~lat, lng = ~long,
                    color   = "tomato",
                    radius  = 18,
                    fillOpacity = 0.10) #<< 
```


---
# Maps w/ leaflet

```{r, eval = T}
# Leaflet
leaflet(data) %>%
   addTiles() %>%
   addCircleMarkers(lat = ~lat, lng = ~long,
                    color   = "tomato",
                    radius  = 18, 
                    fillOpacity = 0.80) #<< 
```



---
# Get in shape w/ **Polygons**

.pull-left[
![](https://raw.githubusercontent.com/MPCA-data/mpcaej/master/ej_map_pop.png)
]

.pull-right[
![](https://pbs.twimg.com/media/DIPWeZCWsAADxvv?format=jpg&name=small)
]


---
# Map polygons

```{r, eval=T, cache=T}
library(weatherAlerts) 
#remotes::install_github("ianmcook/weatherAlerts")

storms <- getAlerts(includeStates = c("FL", "LA", "GA"))
```

```{r, eval=T, echo = F}
knitr::kable(storms@data[1:5, c("severity", "event", "state")])
```




---
# Map polygons
```{r, eval=T}
# Assign alerts a color based on severity ranking
severity <- storms@data$severity

colorMap <- c(Minor    = "green",
              Moderate = "yellow",
              Severe   = "red",
              Extreme  = "magenta",
              Unknown  = "grey")

severityColors <- unname(colorMap[severity])
```



---
# Map polygons

```{r, eval=T}

leaflet(storms) %>%
  addTiles() %>%
  addPolygons(fillColor = severityColors,
              color  = "black",  # Border color
              weight = 1,        # Border width
              label  = ~summary, #<<  
              
              labelOptions = labelOptions(style = list("font-size" = "15px"))
              )
```


---
# Legends

```{r, eval=T}

leaflet(storms) %>%
  addTiles() %>%
  addPolygons(fillColor = severityColors,
              color  = "black",  # Border color
              weight = 1,        # Border width
              label  = ~summary, # Hover for alert information
              ) %>%
  addLegend(colors   = colorMap,           #<< 
            labels   = names(colorMap),
            position = "topright",
            opacity  = 0.45) 

```



Source: *https://gist.github.com/ianmcook/c75bb81011276c23441b9048656e2e76*



---

## Learn more

https://rstudio.github.io/leaflet

[Cheatsheet](https://github.com/rstudio/cheatsheets/raw/master/leaflet.pdf)




# Basemaps



---
## Default tiles: OpenStreetMap

```{r}
leaflet() %>%
  addTiles()   #<<
```


---

## Other tile providers

**ESRI Satellite** 

```{r}
leaflet() %>%
  addProviderTiles(provider = providers$Esri.WorldImagery)   #<<
```


---

## Other tile providers
 
**Simple Grayscale**

```{r}
leaflet() %>%
  addProviderTiles(provider = providers$CartoDB.Positron)   #<<
```


---

## Other tile providers

**Watercolors** 

```{r}
leaflet() %>%
  addProviderTiles(provider = providers$Stamen.Watercolor) #<<
```


---

## Other tile providers

**MN WMS tiles**

```{r}
leaflet() %>%
  setView(lat = 44.98, lng = -93.28, zoom = 11) %>%
  addWMSTiles(baseUrl = "https://imageserver.gisdata.mn.gov/cgi-bin/wmswm?", #<<
              layers = "met20")   #<<
```

Statewide layer: `"fsa2019"`

View more layers on GeoCommons: *https://www.mngeo.state.mn.us/chouse/wms/wms_image_server_layers.html*

[WMS Documentation](https://www.mngeo.state.mn.us/chouse/wms/geo_image_server.html)





# Small multiples of maps with `leafsync`

- https://github.com/r-spatial/leafsync

---

## Two leaflet maps

```{r, eval=T}
map1 <- leaflet(storms) %>%
          addProviderTiles(providers$CartoDB.Positron) %>%
          addPolygons(label = ~summary)
```


```{r, eval=T}
map2 <- leaflet(storms) %>%
          addProviderTiles(providers$Stamen.Watercolor) %>%
          addPolygons(label = ~event)
```


---
## Synchronised mapping

```{r, eval=F}
leafsync::sync(map1, map2)
```



---
class: inverse, middle, center

# There are buckets of [leaflet plugins](https://leafletjs.com/plugins)


- See `leafpop` for advanced popups 
    - https://github.com/r-spatial/leafpop


---
## Add a Mini-Map

```{r, eval=F}
leaflet(storms) %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  addPolygons() %>%
  addMiniMap()  #<<
```


---

## Measure distance

```{r}
leaflet(storms) %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  addPolygons() %>%
  addMeasure()   #<<
```



---
## Locate me?

```{r}
leaflet(storms) %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  addPolygons() %>%
  addEasyButton(easyButton(   #<<
    icon = "fa-crosshairs", title = "Locate Me",   #<<
    onClick = JS("function(btn, map){ map.locate({setView: true}); }")))  #<<
```



---

## Search places

```{r}
library("leaflet.extras")

leaflet(storms) %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  addPolygons() %>%
  addSearchOSM()   #<<
```


---

## Add reverse search

```{r}
leaflet(barrios) %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  addPolygons() %>%
  addReverseSearchOSM()  #<<
```






---
# Add a coordinate reference system

```{r, eval = T, highlight.output=c(5)}
library(sf)

st_as_sf(data, 
         coords = c("long", "lat"),
         crs    = "WGS84") #4326
```


---

# Add a coordinate reference system

```{r, eval=T, highlight.output=c(7)}
library(sf)

st_as_sf(data, 
         coords = c("long", "lat"),
         crs    = "WGS84", 
         remove = FALSE) #<< 
```



# Spatial analysis

![](https://user-images.githubusercontent.com/1325054/34829909-8544f0f0-f6e2-11e7-9161-a0ab29f6762b.png)



---
# SF spatial functions

</br>

- `st_join(data1, data2)`
- `st_nearest_feature(data1, data3)`
- `st_distance(data1, data2)` 
- `st_buffer(data1, 50)` # Default units is meters


---
## Where be yarr treasure?

```{r, eval=F}
library(tidyverse)
library(leaflet)
library(mapedit)
library(sf)
```

1. Use editMap to choose a location to hide your treasure
    - `X <- leaflet() %>% addTiles() %>% editMap()`
2. Post the coordinates into the group chat    

![](https://i.pinimg.com/originals/a2/e5/f4/a2e5f438b68fa966debcd20dc4f19845.jpg)

]


---
## The lucky pirate ship

1. Get the coordinates of a treasure from the chat
2. Create a data.frame for the treasure
    - `x <- data.frame(lat = ****, long = *****`)
3. Map the treasure with `leaflet() %>% addMarkers()`
    - Add a watercolor basemap
4. Load the pirates

```{r, eval=F}
pirates <- read_csv("https://raw.githubusercontent.com/MPCA-data/tidytuesdays/master/show-n-tell/maps/pirates.csv")
```

5. Add pirates to your map: 
    - `addCircleMarkers(data = pirates, lat = ****, lng = ****)`
    - 
6. Use `st_join()` to see if any pirates are within that buffer
7. Use `st_nearest_feature()` to find the closest pirate to the treasure
    - Update the map to add another circle for the closest pirate that is red
8. Convert treasure and pirates to **SF** objects    

```
x <- st_as_sf(x, coords = c("long", "lat"),
                      crs    = "WGS84", 
                      remove = FALSE)
                      
pirates <- st_as_sf(pirates, ....)                     
```  

9. Create a 10 km buffer around the treasure with `st_buffer()`

```
x_buffer <- data %>% 
            st_transform(crs = 26915) %>% 
            st_buffer(50000) %>% 
            st_transform(crs = 4326)
```            
    - Update the map with `addPolygons(data = x_buffer)`
10. Use `st_distance()` to find how far every pirate is from the treasure
    



