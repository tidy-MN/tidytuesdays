# Sulfate water data

1. What would be the most appropriate way in R to create a bootstrapped confidence interval for mean sulfate values per individual water units (chunks or streams or whole lakes)?   
2. What is the minimum number of data points that would be appropriate to use for bootstrapping this?


## Load the data
```r
library(tidyverse)

sulfate <- read_csv("https://raw.githubusercontent.com/MPCA-data/tidytuesdays/master/help/water-Sulfate/sulfate_per_wid_with_min10_obs.csv") 

# Your analysis here


```

