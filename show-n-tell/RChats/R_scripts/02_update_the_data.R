library(tidyverse)

setwd("C:/Users/kmell/Desktop/RChats with Angie and Melinda/data/")

all_ozone_files <- list.files()


##lapply(): lapply function is applied for operations on list objects and returns a list object of same length of original set. 

all_ozone_data <- all_ozone_files %>%
  lapply(read_csv) %>%
  bind_rows()

unique(all_ozone_data$YEAR)

unique(all_ozone_data$SITE)
