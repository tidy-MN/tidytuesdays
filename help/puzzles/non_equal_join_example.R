library(tidyverse)
library(lubridate)
library(data.table)
library(janitor)


# Some demo data
dates <- seq(ymd(20180901), ymd(20200831), 1)
durations <- 0:73

n <- 20

set.seed(20200808)

wildfires <- tibble(id   = 1:n,
                    start_date = sample(dates, n) %>% sort(),
                    end_date = start_date + days(sample(durations, n, T))
)

monitor_data <- tibble(date = dates,
                       pollutant = "PM2.5",
                       result = sample(1:500, length(dates), T))

#Convert data frames to data tables. Note no assignment needed here.
setDT(wildfires)
setDT(monitor_data)

#This also works
wildfires %>% setDT()
monitor_data %>% setDT()

#?`[.data.table` for more info
joined <- monitor_data[wildfires, on = .(date>=start_date, date <= end_date)]

#Create columns to join on. Need to convert result to data table since mutate only returns data frame.
monitor_data <- mutate(monitor_data, start_date = date, end_date = date) %>% setDT()

#Join again this time keeping date intact
joined <- monitor_data[wildfires, on = .(start_date >= start_date, end_date <= end_date)]

#Alternative way using foverlaps
monitor_data <- mutate(monitor_data, date_copy = date) %>%
  #Remove excess columns
  select(-start_date, -end_date) %>%
  setDT()

#Set "key" for both data tables
setkey(wildfires, start_date, end_date)
setkey(monitor_data, date, date_copy)

#no match = NULL for inner join
joined <- foverlaps(wildfires, monitor_data, nomatch = NULL)

#Calculate mean result per wildfire event
mean_concs <- joined %>%
  group_by(id, start_date, end_date, pollutant) %>%
  summarize(avg_result = mean(result) %>% round())

### Example joining with air quality index ###

#Read in air quality data
airnow <- fread("https://github.com/MPCA-data/tidytuesdays/raw/master/help/puzzles/airnow_data.csv")

#Read in AQI breakpoints
breaks <- fread("https://aqs.epa.gov/aqsweb/documents/codetables/aqi_breakpoints.csv") %>%
  clean_names()

#Check all parameter names
unique(breaks$parameter)

#Set value abbreviations for pollutants
recode_vals <- c("PM2.5", "CO", "NO2", "OZONE", "PM10", "PM2.5", "SO2") %>%
  set_names(unique(breaks$parameter))

#Use recode to abbreviate pollutants
breaks <- mutate(breaks, pollutant = recode(parameter, !!!recode_vals))

#Remove duplicate rows
breaks <- distinct(breaks, pollutant, low_breakpoint, .keep_all = T)

airnow <- mutate(airnow,
                 result = round(result),
                 result_copy = result)

setDT(airnow)
setDT(breaks)

setkey(airnow, pollutant, result, result_copy)
setkey(breaks, pollutant, low_breakpoint, high_breakpoint)

joined <- foverlaps(airnow, breaks, nomatch = NULL)

#Check that join worked correctly
summarize(joined, sum(between(result, low_breakpoint, high_breakpoint)))

#Correct ozone and rejoin
airnow <- mutate(airnow,
                 result = ifelse(pollutant == "OZONE", result / 1000, result),
                 result_copy = result) %>%
  setDT()

#Set key again
setkey(airnow, pollutant, result, result_copy)

#Join again
joined <- foverlaps(airnow, breaks, nomatch = NULL)

#calculate AQI
joined <- mutate(joined,
                 aqi = round((high_aqi - low_aqi) * (result - low_breakpoint) /
                               (high_breakpoint - low_breakpoint) + low_aqi)
                 )
