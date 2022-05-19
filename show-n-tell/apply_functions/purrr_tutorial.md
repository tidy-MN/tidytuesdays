---
title: "Introduction to purrr"
author: "Derek Nagel"
date: "2/15/2022"
output: html_document
---

<style type="text/css">
  body{
  font-size: 12pt;
}
</style>

# Welcome to another journey in...

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

![](https://github.com/MPCA-data/tidytuesdays/raw/main/show-n-tell/apply_functions/automagical_data_science.png)

# purrr

The `purrr` package has many tools for functional programming. In short, this package is designed to reduce code repetition. A detailed purrr description along with a purrr cheat sheet can be found here: https://purrr.tidyverse.org/

This guide provides a brief overview of some of purrr's most commonly used functions and some use cases.

## Installation

purrr is part of the tidyverse so if you have installed tidyverse, you already have purrr. You can also install purrr individually.

```{r install, eval = FALSE}
install.packages("purrr")
install.packages("tidyverse")
```

## Map family of functions

purrr's map function works similarly to the base lapply function. Map does everything that lapply as well as some additional features. Map functions support the use of lambda `~` expressions with `.` or `.x` refering to the input element instead of a function (functions still work like they do in `lapply`). Map has several different variants depending on what your input or output is:  

* `map` takes a single input vector or list, applys a function to each element of that input, and returns a list or a different output depending on the suffix used.  

* `map2` is similar to `map`, but takes 2 input vectors / lists instead of 1 and iterates over both of them in parallel.  

* `imap` is also similar to `map`, but includes the ability to refer to the names of the items in the input vector / list.  

* `pmap` takes a list of vectors / lists and iterates over all of them in parallel. A data frame is a list of vectors and/or lists, so it is also a valid input to iterate over. This is typically used when applying a function over rows of a data frame. Very useful in conjunction with dplyr's `expand_grid` for replacing nested for loops.  

* Each of the above variants has suffixes for returning a specific output. They are:
  + `_lgl` which returns a logical (TRUE/FALSE) vector
  + `_chr` which returns a character string vector
  + `_int` which returns an integer (whole number) vector
  + `_dbl` which returns a decimal number vector
  + `_dfr` which takes a data frame output from each item and binds them vertically into a data frame (very useful)
  + `_dfc` which takes a data frame output from each item and binds them horizontally into a data frame (not used very often)  
  
* `_lgl`, `_chr`, `_int`, and `_dbl` only accept an atomic (single item) output item per input. If your function returns a vector and you want to combine them into a single vector, then use `map(...) %>% simplify()`  

* `walk`, `walk2`, `iwalk`, and `pwalk` are similar to their map equivalents, but do not return output. They are used for calling a function with side-effects such as saving files or printing output.

## Examples using tidycensus (need to set census API key)

```{r tidycensus, eval = F}
library(tidyverse)
library(tidycensus)
library(ggplot2)

#Set census API key if you haven't already

# census_api_key("your_census_api_key", install = T)

years <- 2015:2019

#get acs for MN 2015-2019 using map_dfr with a lambda (~) expression
pop <- map_dfr(years,  function(x) get_acs("state", variables = "B01003_001", year = x, state = "MN", cache_table = T) %>%
                 mutate(year = x))

#set variables of interest for pmap example
variables <- c("B01003_001", "B19013_001")

#tribble creates rowwise tables, good for small tables with parameters
states <- tribble(
  ~state_name, ~state_abb,
  "Minnesota", "MN",
  "Iowa", "IA",
  "Wisconsin", "WI"
)

#create table with combinations of parameters
api_calls <- expand_grid(variables, years, states)

#Likely to cause errors due to many API calls
api_results <- pmap_dfr(api_calls, function(variables, years, state_names, state_abbs, ...) {
  get_acs("state", variables = variables, year = years, state = state_abbs) %>%
    #add year
    mutate(year = years)
})
```

## purrr adverbs

For functions that don't always work consistently such as get_acs, purrr contains wrapper functions `safely` and `possibly` to deal with elements that produce errors. A function wrapped with `safely` returns a 2 item list with the first item being the result if successful and the second element being the error message if there is one. `possibly` is similar but just returns a default value such as `NULL` in place of an error.

```{r safely, eval = F}

safe_acs <- safely(get_acs)

api_vals <- pmap(api_calls, function(variables, years, state_names, state_abbs) {
  safe_acs("state", variables = variables, year = years, state = state_abbs) %>%
    #use pluck to add state name and years
    {if(pluck(., "result") %>% is.data.frame()) {
      pluck(., "result") <- mutate(pluck(., "result"),
                                   state = state_names,
                                   year = years)
      .} else .}
})

api_results <- map_dfr(api_vals, "result")
map(api_vals, "error")

#make it slower to avoid repeated API calls too quickly
safe_acs <- slowly(safe_acs, rate_delay(1))

api_vals <- pmap(api_calls, function(variables, years, state_names, state_abbs) {
  safe_acs("state", variables = variables, year = years, state = state_abbs) %>%
    #use pluck to add years
    {if(pluck(., "result") %>% is.data.frame()) {
      pluck(., "result") <- mutate(pluck(., "result"),
                                   year = years)
      .} else .}
})

api_results <- map_dfr(api_vals, "result")
map(api_vals, "error")

#set_names for easier reference
states <- c("MN", "BM", "DK", "DN", "IA", "KE", "ND", "SD", "WI") %>% set_names(.)

state_pops <- map(states, ~safe_acs("state", variables = "B01003_001", year = 2019, state = .))

state_pops_tbl <- map_dfr(state_pops, "result")
map(state_pops, "error")

#use possibly to ignore errors
safe_acs2 <- possibly(get_acs, NULL)

state_pops <- map_dfr(states, ~safe_acs2("state", variables = "B01003_001", year = 2019, state = .))
```

## group functions

purrr has functions `group_map`, `group_modify` and `group_walk` for performing a function on each group of a data frame. All of them use `.` or `.x` in a lambda expression to refer to the group data and `.y` to refer to the group keys (a single row data frame with each group key for the group). `group_map` returns a list (useful for plots and models), `group_modify` returns a data frame (can be useful in some cases, but usually `mutate` / `summarize` are better for simple operations), and `group_walk` returns the data frame invisibly (useful for saving files and other functions called for side-effects).

```{r group_map, eval = F}
#make plots by state and variable
plots <- api_results %>%
  group_by(state = NAME,
           #recode variable to human readable description
           variable = recode(variable,
                             B01003_001 = "Total population",
                             B19013_001 = "Median income"
           )
  ) %>%
  group_map(
    ~ggplot(.x, aes(year, estimate)) +
      geom_line() +
      geom_point(size = 3) +
      #add unique title to each plot
      labs(x = NULL, title = paste(pull(.y, variable), "in", pull(.y, state)))
    )

walk(plots, print)

output_dir <- ""

#use group_walk if you just want to save plots

api_results %>%
  group_by(state = NAME,
           #recode variable to human readable description
           variable = recode(variable,
                             B01003_001 = "Total population",
                             B19013_001 = "Median income"
           )
  ) %>%
  group_walk(
    ~{plot <- ggplot(.x, aes(year, estimate)) +
      geom_line() +
      geom_point(size = 3) +
      #add unique title to each plot
      labs(x = NULL, title = paste(pull(.y, variable), "in", pull(.y, state)))
    
    #save plots to output directory with unique name
      ggsave(paste0(output_dir, "/", paste(pull(.y, variable), "in", pull(.y, state)), ".png"))
    }
    )
```