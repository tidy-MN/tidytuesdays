This code formats the data in insurance_dates so that each person just has a max and min date 
for their continuing insurance (or uninsurance, or missing) status

```r
library(readxl)
library(tidyverse)
library(lubridate)
```

Skip first row, only read first 4 columns
```r
insur <- read_xlsx("G:/Data/Secure Data/Team Folders/Jennifer/IHVE_analysis/insurance_dates.xlsx", 
                   sheet = 1, 
                   range = cell_limits(c(2, 1), c(NA, 4)))
```

```r
insur2 <- insur %>%
          group_by(client_id) %>%
          arrange(start_date, .by_group = T) %>%
          mutate(prev_insure = lag(insure)) %>%
          #Replace first NA in prev_value with first insure status for client_id
          fill(prev_insure, .direction = "up") %>%
          #Create index for each insure status change
          mutate(ins_ind = cumsum(insure != prev_insure)) %>%
          group_by(client_id, ins_ind, insure) %>%
          #Get start and end dates for each insure status period
          summarize(start_date = min(start_date),
                    end_date = max(end_date)) %>%
          ungroup() %>%
          select(-ins_ind)
```


