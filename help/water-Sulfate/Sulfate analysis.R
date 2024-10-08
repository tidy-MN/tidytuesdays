#install.packages(c("tidyverse", "skimr", "janitor", "lubridate", "plotly", "glue", "magrittr", "EnvStats", "data.table"))

library(tidyverse)
library(skimr)
library(janitor)
library(lubridate)
library(plotly)
library(glue)
library(magrittr)
library(EnvStats)
library(data.table)

#read in data
sulfate <- read_csv("https://raw.githubusercontent.com/MPCA-data/tidytuesdays/master/help/water-Sulfate/sulfate_per_wid_with_min10_obs.csv")

#use skim for overview of data
skim(sulfate)

#clean column names
sulfate <- clean_names(sulfate)

#check names
names(sulfate)

sulfate <- mutate(sulfate,
                  #convert integer date to r date object
                  sample_date = as_date(sample_date, ymd(19000101)),
                  #convert detect_flag to logical
                  detect_flag = detect_flag == "Y",
                  cens = !detect_flag,
                  #set censoring level to mdl or rdl, whichever is higher
                  cens_level = pmax(method_detection_limit, reporting_detection_limit, na.rm = T))

#check for any non detects without a censoring level
filter(sulfate, !detect_flag, is.na(cens_level))

#get sample counts for each stream code
sample_counts <- sulfate %>% group_by(stream_code) %>% summarise(n())

#create plotly widget to view data
plot_ly(sulfate, x = ~sample_date, y = ~report_result_value) %>%
  add_markers(hoverinfo = "text",
              color = ~detect_flag,
              colors = c("orange", "blue"),
              text = ~glue("Stream Code: {stream_code}
                           Sample date: {sample_date}
                           Result: {report_result_value} {result_unit}"))

#set number of bootstrap samples
n_bootstrap <- 100

#set seed for reproducability
set.seed(20200317)

stream_summary <- sulfate %>% group_by(stream_code) %>%
  #Use group_modify instead of summarize since we want to extract 2 values out of bootstrap samples (ci_lower and ci_upper)
  group_modify(~tibble(unique_vals = .x %$% uniqueN(report_result_value[!cens]),
                    pct_censored = .x %$% mean(cens),
                    mean = .x %$% if(unique_vals < 2) NA else
                      if (all(detect_flag)) mean(report_result_value) else
                        enparCensored(report_result_value, !detect_flag)$parameters["mean"],
                    #if the mean is NA, the ucl should be as well
                    ci95 = .x %$% if(is.na(mean)) NA else {
                      #repeat sampling n times
                    n = length(cens)
                    replicate(n_bootstrap,
                              #sample two distinct non-censored values as row numbers
                              sample((1:n)[!cens & !duplicated(report_result_value * !cens)], 2, replace = F) %>%
                                #sample n-2 rows (censored or non-censored) and combine with the 2 rows from line above
                                c(sample(1:n, n - 2, replace = T)) %>% {
                                  #use elnormAltCensored if any values in bootstrap sample are censored
                                  if(any(cens[.])) enparCensored(report_result_value[.],cens[.])$parameters["mean"] else
                                    #just take the mean if all values in bootstrap sample are detected
                                    mean(report_result_value[.])
                                }
                    )} %>%
                    #create list column to get both lower and upper ci bounds
                    {tibble(ci_lower = quantile(., 0.025), ci_upper = quantile(., 0.975)) %>% list()},
                    #find min and max value for each stream
                    min = .x %$% min(report_result_value),
                    max = .x %$% max(report_result_value),
                    #get total number of samples for each stream
                    n = nrow(.x)
  ),
  keep = T
  )

#Split ci95 list column into separate columns
stream_summary <- unnest_wider(stream_summary, ci95)
