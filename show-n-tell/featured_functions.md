# :hatching_chick: Featured functions

<br>

- [`tidylog()`](#library(tidylog))
- [`beep()`](#beep-beepnotes)
- [`add_count()`](#counting-is-easy-with-add_count)

<br>

## `library(tidylog)`

R keeps getting friendlier. This is technically a package, but it makes all of your _tidyverse_ functions share a nice informative messages after running them. Here's a few.

#### Load `tidylog` last
``` r
library(dplyr)
library(tidyr)
library(tidylog, warn.conflicts = FALSE)
```

Tidylog gives you feedback when filtering a data frame or adding a new variable:

``` r
df <- filter(mtcars, cyl == 4)
#> filter: removed 21 rows (66%), 11 rows remaining

df <- mutate(mtcars, wt_sqrd = wt ** 2)
#> mutate: new variable 'wt_sqrd' with 29 unique values and 0% NA
```

Tidylog reports detailed information for joins:

``` r
df <- left_join(nycflights13::flights, nycflights13::weather)
#> left_join: added 9 columns (temp, dewp, humid, wind_dir, wind_speed, …)
#>            > rows only in x     1,556
#>            > rows only in y  (  6,737)
#>            > matched rows     335,220
#>            >                 =========
#>            > rows total       336,776
```


What did this big pipey chunk do again?

``` r
summary <- mtcars %>%
              select(mpg, cyl, hp, am) %>%
              filter(mpg > 15) %>%
              mutate(mpg_round = round(mpg)) %>%
              group_by(cyl, mpg_round, am) %>%
              tally() %>%
              filter(n >= 1)
#> select: dropped 7 variables (disp, drat, wt, qsec, vs, …)
#> filter: removed 6 rows (19%), 26 rows remaining
#> mutate: new variable 'mpg_round' with 15 unique values and 0% NA
#> group_by: 3 grouping variables (cyl, mpg_round, am)
#> tally: now 20 rows and 4 columns, 2 group variables remaining (cyl, mpg_round)
#> filter (grouped): no rows removed
```
<br>


## `beep()` `beep()`:notes: 

Add a little music to your scripts! The `beep()` function from the `beepr` package plays various sounds on command. 
Use it to play a sound to alert you when a long running command completes. 
Here's an example that plays the happy __Mario__ coin sound after the script runs succesfully. 

``` r
devtools::install_github("beepr")
```

<img src="images/mario.ico" width="13%" />

  
``` r
library(beepr)

df <- data.frame(x = 0:30, y = 200:230)

# Print every row and then CELEBRATE with Mario
for(i in 1:nrow(df)) {
  print(df[i, ])
}

# Success!!
beepr::beep("mario")

```
<br>

# Counting is easy with `add_count()`

``` r
library(dplyr)
library(readr)
```

```r
tree_url <- "https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-01-28/sf_trees.csv"

trees <- read_csv(tree_url)

glimpse(trees)


# Count the number of each species
# As new table
trees %>% count(species)

# Count and then arrange 
trees %>% count(species, sort = T)

# Give the count column a special name
tree_counts <- trees %>% count(species, sort = T, name = "total_trees")


# Count the number of each species
## As new column
trees <- trees %>% add_count(species, sort = T)

```

##  
