# Non-detects

Examples of summarizing and visualizing **non-detect** or **censored** data.


## Air toxics monitoring data

```r
library(readr)

air <- read_delim("https://raw.githubusercontent.com/MPCA-air/public-data/master/Monitoring_data/2017_mn_air_toxics.txt", 
                  delim = "|")

View(air)
```


