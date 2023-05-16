---
title: "Non-detect method examples"
output: 
  html_document: 
    highlight: tango
    theme: readable
    toc: yes
    toc_depth: 3
---
  
<style type="text/css">
  body, td {font-size: 18px;}
  code.r{font-size: 18px;}
  pre {font-size: 18px} 
</style>
  

## Data

The example data is organized by monitoring site, region, and date. Different sites and years may have different detection limits.

```{r kable, message=F, echo=F}
library(knitr)
library(dplyr)
library(readr)

df <- read_csv(
  '"Site_ID","Region","Date","Concentration","Detect_Limit"
  270535501,"1A","2009-07-30",0.00148,0.1
  270535501,"1A","2009-09-30",0.00064,0.1
  270535501,"1A","2009-11-30",0.24256,0.1
  270535501,"1A","2009-12-30",0.00064,0.1
  270535501,"1A","2010-01-30",0.16001,0.1
  270535501,"1A","2010-03-30",0.19300,0.1
  270535502,"1A","2009-03-30",0.21219,0.01
  270535502,"1A","2009-07-30",0.01113,0.01
  270535502,"1A","2009-09-30",0.00044,0.01
  270535502,"1A","2009-11-30",0.00127,0.01
  270535502,"1A","2009-12-30",0.00613,0.01
  270535502,"1A","2010-01-30",0.02216,0.01
  270535502,"1A","2010-03-30",0.08113,0.02')



kable(df)
```

## Methods

For air monitoring data we currently use the `EnvStats` package to generate annual summary values and confidence intervals. The package provides multiple non-detect methods that will automatically calculate confidence intervals for you. The methods below will help reduce the effects of different detection limits between sites and years.

<br>
To begin, add a column indicating if the sample was detected or not. When the concentration is less than the detection limit the _Censored_ column is set to `TRUE`.

```{r}
df$Censored <-  (df$Concentration) < (df$Detect_Limit)
```

`r kable(head(df))`

</br>    
Similar to _NADA_, `EnvStats` will assume a detection limit is located at the value of the lowest detected concentration. To force the summary to show the correct detection limits you can substitute the detection limit in for the non-detected values. 

```{r}
# Save the original mean of the raw values
raw_mean <- mean(df$Concentration, na.rm=T)

# Replace non-detects with the detection limit
df$Concentration <- ifelse(df$Censored, df$Detect_Limit, df$Concentration)
```

</br>  
Next we can use `EnvStats` to estimate the mean for the entire region. Because there are multiple detection limits the potential methods we can use are more limited. For multiple detection limits with limited amounts of detections (less than 10), Helsel recommends using Kaplan-Meier. Here's an example of running Kaplan-Meier in `EnvStats` using the function `enparCensored()`.


### Kaplan-Meier
```{r message=F, warning=F}
library(EnvStats)

# Kaplan-Meier

# summary for all sites and dates


km_summary <- enparCensored(df$Concentration, 
                            df$Censored, 
                            ci=T,
                            ci.method = "bootstrap",
                            n.bootstraps = 3000)

print(km_summary)
```


<br>
To pull out the `mean` value from the results use: `$parameters[[1]]`

``` {r, message=F, warning=F}
km_mean <- enparCensored(df$Concentration, df$Censored)$parameters[[1]]

paste("The Kaplan-Meier mean is", round(km_mean, 3))

```

<br>

### NADA  

Compare with the `NADA` package  
``` {r, message=F, warning=F}
library(NADA)

Nada_KM_Mean <- cenfit(df$Concentration, df$Censored)

print(Nada_KM_Mean)

```


<br>

### ROS and MLE

When you have larger data sets there are additional methods such as ROS and MLE, which use the the observed distribution of the detected values and applies it to predict the location of non-detect values. These methods usually generate less conservative (lower estimates of the mean), but in most cases are a closer approximation to reality. Below are 2 examples of using the ROS and MLE methods in the `EnvStats` package. 

```{r warning=F, message=F}

library(EnvStats)

# ROS

# Summary across all sites and dates

ros_summary <- enormCensored(df$Concentration, 
                             df$Censored, 
                             method = "rROS", 
                             ci = F,
                             lb.impute = min(df$Detect_Limit) * 0.10,
                             ub.impute = max(df$Detect_Limit))

# The lower bound imputed limt (lb.impute) sets the minimum assigned value for non-detects. If you know the background concentration for a body of water that could be a good minimum value. The example above uses 10% of the minimum detection limit for the lower bound.

# The upper bound imputed limt (ub.impute) sets the maximum assigned value for non-detects. It's set at the highest detection limit above.

print(ros_summary)
```

<br>

```{r warning=F, message=F}

# MLE

#summary across all sites and dates

mle_summary <- enormCensored(df$Concentration, 
                             df$Censored, 
                             method = "mle", 
                             ci = F)

print(mle_summary)
```

<br>  

### 1/2 the DL
Compare to substitution of 1/2 the detection limt
``` {r, message=F, warning=F}

sub_half <- df

sub_half$Concentration <- ifelse(df$Censored, 
                                 df$Detect_Limit * 0.5, 
                                 df$Concentration)

sub_half_DL_Mean <- mean(sub_half$Concentration)

print(sub_half_DL_Mean)

```

<br> 
  
### Random substitution
Compare to random substitution between 0 and the detection limit
``` {r, message=F, warning=F}

set.seed(8*3*2016)

sub_random <- df

sub_random$Concentration <- ifelse(df$Censored, 
                                   runif(1, 0, df$Detect_Limit), 
                                   df$Concentration)

sub_random_Mean <- mean(sub_random$Concentration)

print(sub_random_Mean)

```

<br>

### Single detection limit  

When your data has a single detection limit, as for air monitoring data from a single year, annual statistics can be generated using the imputed MLE method below.

```{r message=F, warning=F, results="hide"}

# Imputed MLE

#summary across a single site with one detection limit

site1 <- filter(df, Site_ID == 270535501)

mle_summary <- enormCensored(site1$Concentration, 
                             site1$Censored, 
                             method = "impute.w.mle",
                             lb.impute = min(site1$Detect_Limit) * 0.10,
                             ci = T,
                             ci.method = "bootstrap")

#print(mle_summary)

```

<br>

## Result Summary  

Below is a summary table of the non-detect methods used for the region overall. For comparison I've also included the mean of the original values before censoring, and the mean when we replace all of the non-detects with the detection limit.

```{r}
library(dplyr)

summary <- df %>%

  summarize('Raw values' = raw_mean,
            'Kap-M'      = enparCensored(Concentration, Censored)$parameters[[1]],
            'ROS'        = enormCensored(Concentration, 
                                         Censored, 
                                         method = "rROS", 
                                         lb.impute = min(df$Detect_Limit)*0.10, 
                                         ub.impute = max(df$Detect_Limit))$parameters[[1]],
            'MLE'        = enormCensored(Concentration, 
                                         Censored, 
                                         method = "mle")$parameters[[1]],
            'Sub 1/2 DL' = sub_half_DL_Mean,
            'Sub random' = sub_random_Mean,
            'Sub DL'     = mean(df$Concentration)
           )
  
knitr::kable(summary, digits = 3)
```

<br> 

## References

DENNIS HELSEL - http://annhyg.oxfordjournals.org/content/54/3/257.full

RONALD C. ANTWEILER - http://pubs.acs.org/doi/pdf/10.1021/es071301c


