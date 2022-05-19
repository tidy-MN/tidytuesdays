library(sf)
library(readr)
library(dplyr)

setwd("X:/Agency_Files/Outcomes/Risk_Eval_Air_Mod/_Air_Risk_Evaluation/Staff Folders/Dorian/Data Analysis/R/useR/useR 2017")

sites <- read_csv("forecast_sites.csv")

sites <- st_as_sf(sites, coords = c("monitor_long", "monitor_lat"), crs = 4326) #"+proj=longlat +datum=WGS84 +no_defs"

sites$geometry

plot(sites[,1], col = "black")


# Transform to new UTM projection
utm_sites <- sites %>% 
             st_transform(26915) #"+proj=utm +zone=15 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0"

utm_sites$geometry

plot(utm_sites[,1], col = "black")
