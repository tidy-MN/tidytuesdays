---
title: "Tidy Tuesdays EnvStats Tutorial"
date: "2/4/2020"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

<br>

## Using the EnvStats package to calculate means and confidence limits of data with censored values

<br>

This is a short walkthrough on how to use functions from the EnvStats package. This tutorial will use MPCA air toxics monitoring results from 2017 and calculate average concentrations of upper confidence limits for each site and parameter. The data is on GitHub:
https://raw.githubusercontent.com/MPCA-air/public-data/master/Monitoring_data/2017_mn_air_toxics.txt

<br>

### Package installation

<br>

```r
install.packages(c("data.table", "tidyverse", "janitor", "lubridate", "EnvStats"))
```

<br>

### Data pre-processing

<br>

```r 
library(data.table)
library(tidyverse)
library(janitor)
library(lubridate)
library(EnvStats)

toxics <- fread("https://raw.githubusercontent.com/MPCA-air/public-data/master/Monitoring_data/2017_mn_air_toxics.txt")

toxics <- clean_names(toxics)

names(toxics)

#names(toxics)[c(13, 27)] <- c("conc", "dl")

# Or use rename() to be super safe
toxics <- rename(toxics, 
                 conc = reported_sample_value,
                 dl   = alternate_method_detection_limit)
```

<br>

### Preparing data to use in EnvStats functions

<br>

EnvStats functions which deal with censored values need two vectors to calculate a mean:

1. `x` which is a nemeric vector containing uncensored values and values of the detection limit of censored values
1. `censored` which is a logical (T/F) vector with length to that of `x` with TRUE meaning the corresponding value in `x` is censored (below detection limit) and FALSE meaning the corresponding value in `x` is detected.

Most of the functions accept NA values, but it's easier to just remove them beforehand.

<br>

```r
toxics <- filter(toxics, !is.na(conc)) %>%
  #convert date character to POXICct
  mutate(sample_date = ymd(sample_date),
         #create censored vector
         cens = conc < dl,
         #for each row set conc to either conc or detection limit, whichever is greater
         conc = pmax(conc, dl))
```

<br>

EnvStats functions also require two other conditions:

1. There must be at least 2 unique values in `x` where `censored == F`. We can use an if() statement to return NA if that condition is not met.
1. At least one value in `censored == T`. If all values are not censored -they are all detected- we must use a different function such as the plain arithmetic mean.

In the example below, we also return NA if more than 80% of the values are censored since while the function will work with > 80% censored values as long as the first condition above is met, the estimates are less reliable with so much of the data being censored.

<br>

```r 
site_means <- toxics %>%
  #we average results by site, pollutant, and year
  group_by(site_number, parameter, year = year(sample_date)) %>%
  #get number of unique noncensored values
  summarize(unique_vals = uniqueN(conc[!cens]),
            #get percent of values censored
            pct_censored = mean(cens),
            #return NA if > 80% censored
            mean = if(pct_censored > 0.8 | unique_vals < 2) NaN else
              #use elnormAltCensored if any values are censored
              if(any(cens)) elnormAltCensored(conc, cens)$parameters["mean"] else
                #just take the mean if all values are detected
                mean(conc))
```

<br>

### Confidence intervals and bootstrap sampling

<br>

We can generate upper (or lower) confidence limits for the mean estimate using bootstrap sampling.

<br>

```r 

n_bootstrap <- 10

#this is going to produce at lot of warnings
suppressWarnings(
  site_means <- toxics %>%
    group_by(site_number, parameter, year = year(sample_date)) %>%
    #calculate mean again just to keep everything in one table
    summarize(unique_vals = uniqueN(conc[!cens]),
              pct_censored = mean(cens),
              mean = if(pct_censored > 0.8 | unique_vals < 2) NaN else
                if(any(cens)) elnormAltCensored(conc, cens)$parameters["mean"] else
                  mean(conc),
              #if the mean is NA, the ucl should be as well
              ucl95 = if(is.na(mean)) NaN else
                #repeat sampling n times
                replicate(n_bootstrap,
                          #sample two distinct non-censored values as row numbers
                          sample((1:n())[!cens & !duplicated(conc * !cens)], 2, replace = F) %>%
                            #sample n-2 rows (censored or non-censored) and combine with the 2 rows from line above
                            c(sample(1:n(), n() - 2, replace = T)) %>% {
                              #use elnormAltCensored if any values in bootstrap sample are censored
                              if(any(cens[.])) elnormAltCensored(conc[.],cens[.])$parameters["mean"] else
                                #just take the mean if all values in bootstrap sample are detected
                                mean(conc[.])
                          }
                ) %>%
                #find quantile for 95% upper confidence limit
                quantile(0.95, na.rm = T)
    )
)
```
