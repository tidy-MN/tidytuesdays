Use NADA and broom for non-parametric analysis of left-censored
groundwater data
================
Barbara Monaco
2/18/2020

## Groundwater impacts of unlined construction and demolition debris landfilling

[This
report](https://www.pca.state.mn.us/sites/default/files/w-sw5-54a.pdf)
explores the groundwater impacts of unlined construction and demolition
(C\&D) debris landfills by analyzing self-reported data from 43 C\&D
landfills, from 2010-2017, with special evaluations of three
contaminants of concern (COC): arsenic, boron, and manganese.

We have small data sets and unknown distributions for the COC in
groundwater thus we felt that a nonparametric approach was appropriate.
Since we have left-censored data and also a variety of reporting limits
(RLs), we used the Peto-Prentice Generalized Wilcoxon test which allows
us to use the information in the censored data and does not require a
single RL. The Peto-Prentice Generalized Wilcoxon is a special case of
the general class of weighted log-rank tests which are nonparametric
score tests used to determine whether the distribution functions differ
between groups.

## Using the NADA package for comparing upgradient vs downgradient concentrations of COC

In order to compare the upgradient vs downgradient concentrations for
each COC for each facility, we needed to figure out a smart way of
running the analysis on each combination. We also wanted to store the
results and summarize them into tables and figures for our paper. The
`NADA` package has the functions that we want but can be difficult to
get answers out of so if we combine that with the functions in `broom`
we can easily get the answers we need by turning models into tidy data.

We are going to be using the approach that Grolemund and Wickham
demonstrates in their book “R for Data Science” shown
[here](https://r4ds.had.co.nz/many-models.html). The approach starts by
creating nested data sets which are then analyzed and the results are
stored. We want to nest by facility and contaminant:

``` r
# Kaplan Meier and Peto-Prentice generalized Wilcoxon ---------------------------------------------------
# using the NADA package by Dennis Helsel, we create a nested tibble and then
# apply the cendiff and cenfit functions to each facility and contaminant

by_facility_contaminant <- data_subset %>% 
  group_by(PERMIT_NUMBER, CONTAMINANT) %>% 
  nest()
```

This creates a data frame that has one row per group (per facility and
contaminant), and a column called `data`. `data` contains all the raw
data for each group in a tibble and stores the tibbles in a list. Now
that we have the nested data frame, we want to apply the generalized
wilcoxon to each data frame in the list. We can do this by using the
`map` function from the `purrr` package.

The `map` functions transform their input by applying a function to each
element and returning a vector the same length as the input. So we need
to create a function that takes our data and applies the `cendiff`
function to it so all it needs to take is the data frame.

``` r
gen_wilcoxon <- function(df) {
  cendiff(obs = df$REPORT_VALUE_ug_L,
          censored = df$CENSORED,
          groups = df$Position)
}
```

We do something similar for fitting the Kaplan-Meier as well. Once these
functions are created and applied we need to pull out the elements from
them using functions in the `broom` package. `glance` and `tidy` will
help extract key pieces of information.

``` r
by_facility_contaminant <- by_facility_contaminant %>% 
  mutate(gen_wilcoxon = map(data, gen_wilcoxon),
         kaplan_meier = map(data, kaplan_meier),
         glance = map(gen_wilcoxon, broom::glance),
         tidy = map(gen_wilcoxon, broom::tidy))
```

In order to look at the nested output, you have to pull out an element
from the list. You can do this by calling one of the columns by name and
then grabbing the first element in the list by using `[[]]`. For more
information on accessing elements in a list, see [R Tutorial -
List](http://www.r-tutor.com/r-introduction/list)

``` r
by_facility_contaminant$gen_wilcoxon[[1]]
```

    ##                           N Observed Expected (O-E)^2/E (O-E)^2/V
    ## df$Position=Upgradient   18     11.8     6.83      3.57      7.21
    ## df$Position=Downgradient 29     12.4    17.36      1.40      7.21
    ## 
    ##  Chisq= 7.2  on 1 degrees of freedom, p= 0.007

``` r
by_facility_contaminant$glance[[1]]
```

    ## # A tibble: 1 x 3
    ##   statistic    df p.value
    ##       <dbl> <dbl>   <dbl>
    ## 1      7.21     1 0.00725

``` r
by_facility_contaminant$tidy[[1]]
```

    ## # A tibble: 2 x 4
    ##   `df$Position`     N   obs   exp
    ##   <chr>         <dbl> <dbl> <dbl>
    ## 1 Upgradient       18  11.8  6.83
    ## 2 Downgradient     29  12.4 17.4

Now that we see how the data is structured, we need to unnest the data
and pull out the necessary information. Because `tidy` and `glance` have
different numbers of rows, we need to make them match. Good news, since
we really only care about the observed and expected values for the
Upgradient samples, we can filter so we have one row when we unnest
`tidy`.

``` r
results <- by_facility_contaminant %>% 
  unnest(tidy) %>% 
  filter(`df$Position` == 'Upgradient') %>% 
  unnest(glance) %>% 
  mutate(sig_diff = ifelse(obs<exp & (p.value/2) < 0.05, TRUE, FALSE))

head(results %>% select(-data, -gen_wilcoxon,
                        -kaplan_meier, -`df$Position`))
```

    ## # A tibble: 6 x 9
    ## # Groups:   PERMIT_NUMBER, CONTAMINANT [6]
    ##   PERMIT_NUMBER CONTAMINANT statistic    df p.value     N   obs   exp sig_diff
    ##   <chr>         <chr>           <dbl> <dbl>   <dbl> <dbl> <dbl> <dbl> <lgl>   
    ## 1 SW-475        Manganese      7.21       1 0.00725    18 11.8   6.83 FALSE   
    ## 2 SW-475        Boron          7.77       1 0.00532     5  0     3.12 TRUE    
    ## 3 SW-475        Arsenic        0.226      1 0.634       7  3.03  3.64 FALSE   
    ## 4 SW-508        Boron          1.23       1 0.268       4  1.32  2.61 FALSE   
    ## 5 SW-508        Manganese      0.0150     1 0.903      16  7.06  6.83 FALSE   
    ## 6 SW-508        Arsenic        0.0456     1 0.831       6  3.21  2.93 FALSE

But what if we can’t filter so that they match? If you create two
separate dataset then you can unnest and merge them together.
`results_raw` is the results from `broom::tidy` and `results_test` are
from `broom::glance`

``` r
# Create contaminant specific datasets ------------------------------------

results_raw <- by_facility_contaminant %>% 
  mutate(tidy = map(gen_wilcoxon, broom::tidy)) %>% 
  unnest(tidy) %>% 
  select(PERMIT_NUMBER, CONTAMINANT, Position = `df$Position`, N, obs, exp)

results_test <- by_facility_contaminant %>% 
  mutate(glance = map(gen_wilcoxon, broom::glance)) %>% 
  unnest(glance)

results_df <- data.table::dcast(setDT(results_raw), PERMIT_NUMBER + CONTAMINANT ~ Position, 
      value.var = c("N", "obs", "exp"))
results_df <- inner_join(results_df, results_test, 
                       by = c("PERMIT_NUMBER", "CONTAMINANT")) %>% 
  mutate(sig_diff = ifelse(obs_Upgradient<exp_Upgradient & (p.value/2) < 0.05,
                           'Yes', "No")) %>% 
  select(-data, -gen_wilcoxon, -kaplan_meier, -tidy, -df)

head(results_df)
```

    ##   PERMIT_NUMBER CONTAMINANT N_Downgradient N_Upgradient obs_Downgradient
    ## 1        SW-143     Arsenic             15            5         0.703125
    ## 2        SW-143       Boron             18            3         8.746032
    ## 3        SW-143   Manganese             25            8        10.454545
    ## 4        SW-168     Arsenic             10           10         0.000000
    ## 5        SW-168       Boron             10           10         4.075000
    ## 6        SW-168   Manganese             10           10         5.150000
    ##   obs_Upgradient exp_Downgradient exp_Upgradient statistic       p.value
    ## 1      2.4062500         1.921875       1.187500  2.596671 0.10708844626
    ## 2      0.3809524         7.460317       1.666667  1.662696 0.19723965408
    ## 3      6.5151515        15.242424       1.727273 18.897805 0.00001379113
    ## 4      0.0000000         0.000000       0.000000  0.000000           NaN
    ## 5      1.6000000         2.800000       2.875000  1.421311 0.23318766125
    ## 6      2.6500000         3.150000       4.650000  2.697318 0.10051720779
    ##   sig_diff
    ## 1       No
    ## 2       No
    ## 3       No
    ## 4       No
    ## 5       No
    ## 6       No

Once we know which facilities and contaminants are showing a
statistically significant increase downgradient, we then evaluate the
downgradient samples for exceedances of either the intervention limit
(IL) or the health threshold (HT).

``` r
exceedance <- left_join(data_subset, results_df, 
                        by = c("PERMIT_NUMBER", "CONTAMINANT")) %>% 
  filter(sig_diff == 'Yes',
         Position == 'Downgradient') %>% 
  mutate(Exceeds = ifelse(REPORT_VALUE_ug_L > HT_ug_L & CENSORED == FALSE, "HT",
                          ifelse(REPORT_VALUE_ug_L > IL_ug_L & CENSORED == FALSE, "IL",
                                 "No Exceedance determined"))) %>% 
  group_by(PERMIT_NUMBER,CONTAMINANT, Exceeds) %>%
  dplyr::summarise(Count = n()) %>% 
  data.table() %>% 
  dcast(PERMIT_NUMBER+CONTAMINANT~Exceeds, value.var = 'Count') %>% 
  rowwise() %>% 
  mutate(total = sum(HT, IL, `No Exceedance determined`, na.rm = TRUE)) %>% 
  as.data.frame()
```

``` r
exceedance %>% 
  group_by(CONTAMINANT) %>% 
  dplyr::summarise(HT = sum(HT, na.rm = TRUE), 
            IL = sum(IL, na.rm = TRUE),
            No_Exceedance = sum(`No Exceedance determined`, na.rm = TRUE), 
            Total = sum(total, na.rm = TRUE))
```

    ## # A tibble: 3 x 5
    ##   CONTAMINANT    HT    IL No_Exceedance Total
    ##   <chr>       <int> <int>         <int> <int>
    ## 1 Arsenic        61    38           352   451
    ## 2 Boron         449   267           336  1052
    ## 3 Manganese     462    74           107   643
