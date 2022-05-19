library(tidyverse)
library(ggplot2) ##ggplot is included in tidyverse. I jsut wanted you to know that this was the package I am using to plot.


ggplot(all_ozone_data, aes(x = TEMP_F, y = OZONE, color = as.character(YEAR))) +
  geom_line()
