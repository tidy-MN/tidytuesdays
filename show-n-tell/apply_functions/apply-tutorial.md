Apply / Mapping tutorial
================
Derek Nagel
8/12/2020

## Why should I use apply / map functions in R?

1.  To save yourself work by avoiding code repetition
2.  To make your scripts more memory efficient (faster)
3.  To make your code more readable for others
4.  To make your scripts flexible enough to handle more complex data and
    situations

## Vectorization

Many basic functions in R are *vectorized*, which means they can take
vectors as input and perform a function on the elements of the vector
one by one and return a vector of the results.

``` r
c(1,2,3) + c(4,5,6)
```

    ## [1] 5 7 9

A lot of basic functions work the same way including `+`, `-`, `*`, `/`,
`^` as well as logical functions `==`, `<`, `>`, `&`, `|`

``` r
c(1,2,3) == c(3,2,1)
```

    ## [1] FALSE  TRUE FALSE

If the vectors have different lengths (number of values), then R will
*recycle* the smaller vector as many times as needed to produce a vector
with the same length as the larger one. This is useful for multiplying
all values in a vector by a single value.

``` r
c(1,2,3) * 2
```

    ## [1] 2 4 6

Be careful with this. If the vectors are different lengths and the
smaller vector is not a single value, then R will repeat the smaller
vector in order which may produce unexpected results.

``` r
#Produces message
c(1,2,3) + c(4, 6)
```

    ## Warning in c(1, 2, 3) + c(4, 6): longer object length is not a multiple of
    ## shorter object length

    ## [1] 5 8 7

``` r
#No message
c(1,2,3,4) + c(4, 6)
```

    ## [1]  5  8  7 10

Most simple functions that take vectors as input and return vectors as
output are vectorized for us which is convenient, but functions that
take or return more complex objects such as data frames are usually not
vectorized. This is where the `apply` family of functions comes in.

## Apply

`apply` takes a matrix or data frame and performs a function on each row
or each column of the input individually. The first argument is a data
frame or matrix, the second argument is the dimension to apply a
function to (1 for rows, 2 for columns), and the third argument is the
function to will be performed on each row or column. You can provide
additional arguments which are then passed on to the function such as
na.rm = T.

``` r
a <- data.frame(c1 = 1:3, c2 = 4:6, c3 = c(7, 8, NA))
a
```

    ##   c1 c2 c3
    ## 1  1  4  7
    ## 2  2  5  8
    ## 3  3  6 NA

``` r
#Row products
apply(a, 1, prod, na.rm = T)
```

    ## [1] 28 80 18

``` r
#Column products
apply(a, 2, prod, na.rm = T)
```

    ##  c1  c2  c3 
    ##   6 120  56

Alternatively, you can define an *anonymous function* which is basically
a one-time function to use in an apply function.

``` r
a <- data.frame(c1 = 1:3, c2 = 4:6, c3 = c(7, 8, NA))
a
```

    ##   c1 c2 c3
    ## 1  1  4  7
    ## 2  2  5  8
    ## 3  3  6 NA

``` r
#Row products
apply(a, 1, function(x) {prod(x, na.rm = T)})
```

    ## [1] 28 80 18

``` r
#x is the convention for the object in the function, but you can name it anything you want
apply(a, 1, function(derek) {prod(derek, na.rm = T)})
```

    ## [1] 28 80 18

``` r
#Subtract every value from last value in column
apply(a, 2, function(x) {dplyr::last(x) - x})
```

    ##      c1 c2 c3
    ## [1,]  2  2 NA
    ## [2,]  1  1 NA
    ## [3,]  0  0 NA

Usually there are better alternatives to `apply`. `RowSums`, `ColSums`,
`RowMeans`, and `ColMeans` are shortcuts for taking the sums or means of
all rows or columns. `mutate_all` and `summarize_all` from the dplyr /
tidyverse packages are usually better for column-wise operations on data
frames.

## lapply

`lapply` takes a vector or a list and performs a function on each item
element of that vector or list. The output is a list with each item in
the output list corresponding to the item in the input in the same
position (i.e. the second item in the output list corresponds to the
second item in the input). Lists can contain any type of object
(including other lists), so `lapply` is extremely versatile.

``` r
library(curl)
library(urltools)
library(pdftools)
library(rebus)
library(tidyverse)
library(lubridate)

read_cems <- function(pdf_file) {
  
  #read in pdf text
  cems_text <- pdf_text(pdf_file)
  
  #Extract dates from text
  
  #Look for "Date of Run..." until end of line
  dates <- str_extract_all(cems_text, "Date of Run" %R% any_char(1, Inf) %R% "\\r\\n") %>%
    #Extract all mm/dd dates with a preceding space
    str_extract_all(SPC %R% digit(1,2) %R% "/" %R% digit(1,2)) %>%
    unlist %>%
    str_trim %>%
    #Convert to date with year 2020
    {mdy(paste(., 2020))}
  
  #Extract emissions from text
  
  #Extract 4 lines after "LB/HR"
  emit_rates <- str_extract_all(cems_text, "LB/HR" %R% spc(1, Inf) %R% any_char(1, Inf) %R%
                                  spc(1, Inf) %R% any_char(1, Inf) %R%
                                  spc(1, Inf) %R% any_char(1, Inf) %R%
                                  spc(1, Inf) %R% any_char(1, Inf)) %>%
    #Look for line containing with "THC as Trans-1,2-"
    str_extract_all("THC as Trans-1,2-" %R% any_char(1, Inf)) %>%
    #Extract all numbers including decimal separator
    str_extract_all(digit(1, Inf) %R% DOT %R% digit(0, Inf)) %>%
    unlist %>%
    as.numeric %>%
    #Keep only values associated with a date and remove average column
    head(length(dates))
  
  #Create table of dates and values
  tibble(date = dates, emit_rate = emit_rates)
}

#Get file list from github repository; looking for shortcut. Use list.files for local directory
repository <- "https://github.com/MPCA-data/tidytuesdays/tree/master/show-n-tell/strings/water_gremlin_cems"

file_list <- curl_fetch_memory(repository)
file_list <- rawToChar(file_list[["content"]]) %>%
  str_extract_all('title=\\"' %R% any_char(1, Inf) %R% '.pdf" ') %>%
  unlist() %>%
  str_replace_all('title=\\"|\\" ', "")

url_list <- paste0("https://github.com/MPCA-data/tidytuesdays/raw/master/show-n-tell/strings/water_gremlin_cems/", url_encode(file_list))

#Test on first file
cems_data <- lapply(url_list[1], read_cems)

#Read all files using lapply
cems_data <- lapply(url_list, read_cems)

#Use bind_rows (dplyr) to merge list into one data frame
cems_data <- bind_rows(cems_data)
```

## Shortcuts for other files

If you are just reading files in a local directory you can use `lapply`
with `list.files` and \``read_csv` (or another read function for
different types of files).

``` r
library(tidyverse)

dir <- "" #Paste directory name here
data <- lapply(list.files(dir, full.names = T), read_csv) %>% bind_rows()
```

For reading in csv, txt, or excel files, you can alternatively use
`vroom` from the vroom package (they are the same name vroom::vroom) or
`import` from the rio package which automatically combine your data into
a single data frame (unless you tell them not to) without needing to
call lapply or bind\_rows.

## purrr

The purrr package is part of the tidyverse package. It contains a lot of
apply style functions beyond what is included in base R.

## map

`map` is an enhanced lapply. `map` works like `lapply` does, but it also
has some extra features. In particular, instead of providing a function
as the second argument, we can provide an expression starting with `~`
and refer to the element we are using with `.` or `.x`.

``` r
library(curl)
library(urltools)
library(pdftools)
library(rebus)
library(tidyverse)
library(lubridate)

#Define function to parse pdf files
read_cems <- function(pdf_file) {
  
  #read in pdf text
  cems_text <- pdf_text(pdf_file)
  
  #Extract dates from text
  
  #Look for "Date of Run..." until end of line
  dates <- str_extract_all(cems_text, "Date of Run" %R% any_char(1, Inf) %R% "\\r\\n") %>%
    #Extract all mm/dd dates with a preceding space
    str_extract_all(SPC %R% digit(1,2) %R% "/" %R% digit(1,2)) %>%
    unlist %>%
    str_trim %>%
    #Convert to date with year 2020
    {mdy(paste(., 2020))}
  
  #Extract emissions from text
  
  #Extract 4 lines after "LB/HR"
  emit_rates <- str_extract_all(cems_text, "LB/HR" %R% spc(1, Inf) %R% any_char(1, Inf) %R%
                                  spc(1, Inf) %R% any_char(1, Inf) %R%
                                  spc(1, Inf) %R% any_char(1, Inf) %R%
                                  spc(1, Inf) %R% any_char(1, Inf)) %>%
    #Look for line containing with "THC as Trans-1,2-"
    str_extract_all("THC as Trans-1,2-" %R% any_char(1, Inf)) %>%
    #Extract all numbers including decimal separator
    str_extract_all(digit(1, Inf) %R% DOT %R% digit(0, Inf)) %>%
    unlist %>%
    as.numeric %>%
    #Keep only values associated with a date and remove average column
    head(length(dates))
  
  #Create table of dates and values
  tibble(date = dates, emit_rate = emit_rates)
}

#Get file list from github repository; looking for shortcut. Use list.files for local directory
repository <- "https://github.com/MPCA-data/tidytuesdays/tree/master/show-n-tell/strings/water_gremlin_cems"

file_list <- curl_fetch_memory(repository)
file_list <- rawToChar(file_list[["content"]]) %>%
  str_extract_all('title=\\"' %R% any_char(1, Inf) %R% '.pdf" ') %>%
  unlist() %>%
  str_replace_all('title=\\"|\\" ', "")

url_list <- paste0("https://github.com/MPCA-data/tidytuesdays/raw/master/show-n-tell/strings/water_gremlin_cems/", url_encode(file_list))

#Same as lapply
cems_data <- map(url_list, read_cems)

#Add the file name as a column to the data
cems_data <- map(url_list, ~ read_cems(.x) %>% mutate(url = .x)) %>%
  bind_rows()

#Same example as above, but use {} for a multi-line expression
cems_data <- map(url_list, ~{data <-read_cems(.)
data <- mutate(data, url = .)
}) %>%
  bind_rows()

#map_dfr will automatically bind the list into a data frame without calling bind_rows
cems_data <- map_dfr(url_list, read_cems)
```

There are many more map variants. `map2` allows you to create an
expression using values from two different lists or vectors. `pmap`
allows you to use any number of lists and/or vectors to map on which is
a great replacement for nested `for` loops.

## Grouped operations

The dplyr and purrr packages allow you to split up your data by group
with `group_by` and use functions on each group. `mutate` and
`summarize` automatically apply the function to each group individually
of a grouped data frame. They are useful for a lot of things, but the
limitation of these functions is that they can only produce vectors and
always return a data frame. purrr has functions `group_map`,
`group_modify` and `group walk` which are much more flexible.
`group_map` takes a grouped data frame, applies a function to each
group, and returns a list of outputs for each group.

``` r
#View data
head(iris)
```

    ##   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
    ## 1          5.1         3.5          1.4         0.2  setosa
    ## 2          4.9         3.0          1.4         0.2  setosa
    ## 3          4.7         3.2          1.3         0.2  setosa
    ## 4          4.6         3.1          1.5         0.2  setosa
    ## 5          5.0         3.6          1.4         0.2  setosa
    ## 6          5.4         3.9          1.7         0.4  setosa

``` r
iris_plots <- iris %>%
  group_by(Species) %>%
  group_map(
    ~ggplot(.x, aes(Petal.Length, Petal.Width)) +
      geom_point() +
      labs(title = paste("Petal length vs. petal width of", .y$Species)) +
      theme_classic()
  )

iris_plots
```

    ## [[1]]

![](apply-tutorial_files/figure-gfm/group_map-1.png)<!-- -->

    ## 
    ## [[2]]

![](apply-tutorial_files/figure-gfm/group_map-2.png)<!-- -->

    ## 
    ## [[3]]

![](apply-tutorial_files/figure-gfm/group_map-3.png)<!-- -->

`group_walk` works similar to `group_map` except that it returns your
original data frame instead of the function output. This is useful when
you want to save plots or write data by group but don’t want to keep any
output from the function.

``` r
save_to <- "//pca.state.mn.us/sdrive/Public/Nagel_Derek.DN/R plots" #Change directory

iris %>%
  group_by(Species) %>%
  group_walk(
    ~{ggplot(.x, aes(Petal.Length, Petal.Width)) +
      geom_point() +
      labs(title = paste("Petal length vs. petal width of", .y$Species)) +
      theme_classic()
      
      ggsave(paste0(save_to, "/Petal length vs petal width of ", .y$Species, ".png"))
    }
  )
```

## mutate / summarize all / at / if

dplyr has several functions that quickly apply other functions to many
columns of a data frame at once.

Mutate all and summarize all take one or more functions and apply them
to all columns of a data frame.

``` r
head(mtcars)
```

    ##                    mpg cyl disp  hp drat    wt  qsec vs am gear carb
    ## Mazda RX4         21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
    ## Mazda RX4 Wag     21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
    ## Datsun 710        22.8   4  108  93 3.85 2.320 18.61  1  1    4    1
    ## Hornet 4 Drive    21.4   6  258 110 3.08 3.215 19.44  1  0    3    1
    ## Hornet Sportabout 18.7   8  360 175 3.15 3.440 17.02  0  0    3    2
    ## Valiant           18.1   6  225 105 2.76 3.460 20.22  1  0    3    1

``` r
#Round all columns
mtcars %>% mutate_all(round)
```

    ##    mpg cyl disp  hp drat wt qsec vs am gear carb
    ## 1   21   6  160 110    4  3   16  0  1    4    4
    ## 2   21   6  160 110    4  3   17  0  1    4    4
    ## 3   23   4  108  93    4  2   19  1  1    4    1
    ## 4   21   6  258 110    3  3   19  1  0    3    1
    ## 5   19   8  360 175    3  3   17  0  0    3    2
    ## 6   18   6  225 105    3  3   20  1  0    3    1
    ## 7   14   8  360 245    3  4   16  0  0    3    4
    ## 8   24   4  147  62    4  3   20  1  0    4    2
    ## 9   23   4  141  95    4  3   23  1  0    4    2
    ## 10  19   6  168 123    4  3   18  1  0    4    4
    ## 11  18   6  168 123    4  3   19  1  0    4    4
    ## 12  16   8  276 180    3  4   17  0  0    3    3
    ## 13  17   8  276 180    3  4   18  0  0    3    3
    ## 14  15   8  276 180    3  4   18  0  0    3    3
    ## 15  10   8  472 205    3  5   18  0  0    3    4
    ## 16  10   8  460 215    3  5   18  0  0    3    4
    ## 17  15   8  440 230    3  5   17  0  0    3    4
    ## 18  32   4   79  66    4  2   19  1  1    4    1
    ## 19  30   4   76  52    5  2   19  1  1    4    2
    ## 20  34   4   71  65    4  2   20  1  1    4    1
    ## 21  22   4  120  97    4  2   20  1  0    3    1
    ## 22  16   8  318 150    3  4   17  0  0    3    2
    ## 23  15   8  304 150    3  3   17  0  0    3    2
    ## 24  13   8  350 245    4  4   15  0  0    3    4
    ## 25  19   8  400 175    3  4   17  0  0    3    2
    ## 26  27   4   79  66    4  2   19  1  1    4    1
    ## 27  26   4  120  91    4  2   17  0  1    5    2
    ## 28  30   4   95 113    4  2   17  1  1    5    2
    ## 29  16   8  351 264    4  3   14  0  1    5    4
    ## 30  20   6  145 175    4  3   16  0  1    5    6
    ## 31  15   8  301 335    4  4   15  0  1    5    8
    ## 32  21   4  121 109    4  3   19  1  1    4    2

``` r
#Get mean of all columns
mtcars %>% summarize_all(mean)
```

    ##        mpg    cyl     disp       hp     drat      wt     qsec     vs      am
    ## 1 20.09062 6.1875 230.7219 146.6875 3.596563 3.21725 17.84875 0.4375 0.40625
    ##     gear   carb
    ## 1 3.6875 2.8125

``` r
#Get min and max of all columns by providing a list
mtcars %>% summarize_all(list(min = min, max = max))
```

    ##   mpg_min cyl_min disp_min hp_min drat_min wt_min qsec_min vs_min am_min
    ## 1    10.4       4     71.1     52     2.76  1.513     14.5      0      0
    ##   gear_min carb_min mpg_max cyl_max disp_max hp_max drat_max wt_max qsec_max
    ## 1        3        1    33.9       8      472    335     4.93  5.424     22.9
    ##   vs_max am_max gear_max carb_max
    ## 1      1      1        5        8

``` r
#If you use group_by first, summarize_all does not apply to grouping columns and applies by group
mtcars %>% group_by(cyl) %>% summarize_all(list(min = min, max = max))
```

    ## # A tibble: 3 x 21
    ##     cyl mpg_min disp_min hp_min drat_min wt_min qsec_min vs_min am_min gear_min
    ##   <dbl>   <dbl>    <dbl>  <dbl>    <dbl>  <dbl>    <dbl>  <dbl>  <dbl>    <dbl>
    ## 1     4    21.4     71.1     52     3.69   1.51     16.7      0      0        3
    ## 2     6    17.8    145      105     2.76   2.62     15.5      0      0        3
    ## 3     8    10.4    276.     150     2.76   3.17     14.5      0      0        3
    ## # ... with 11 more variables: carb_min <dbl>, mpg_max <dbl>, disp_max <dbl>,
    ## #   hp_max <dbl>, drat_max <dbl>, wt_max <dbl>, qsec_max <dbl>, vs_max <dbl>,
    ## #   am_max <dbl>, gear_max <dbl>, carb_max <dbl>

``` r
#Can do more complex operations using ~ and . to refer to columns
mtcars %>% group_by(cyl) %>% summarize_all(list(range = ~max(.) - min(.)))
```

    ## # A tibble: 3 x 11
    ##     cyl mpg_range disp_range hp_range drat_range wt_range qsec_range vs_range
    ##   <dbl>     <dbl>      <dbl>    <dbl>      <dbl>    <dbl>      <dbl>    <dbl>
    ## 1     4     12.5        75.6       61       1.24    1.68        6.20        1
    ## 2     6      3.60      113         70       1.16    0.840       4.72        1
    ## 3     8      8.80      196.       185       1.46    2.25        3.5         0
    ## # ... with 3 more variables: am_range <dbl>, gear_range <dbl>, carb_range <dbl>

mutate\_if and summarize\_if are similar to the \_all variants, but only
apply the function to columns that meet a *predicate* condition such as
`is.numeric`.

``` r
head(iris)
```

    ##   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
    ## 1          5.1         3.5          1.4         0.2  setosa
    ## 2          4.9         3.0          1.4         0.2  setosa
    ## 3          4.7         3.2          1.3         0.2  setosa
    ## 4          4.6         3.1          1.5         0.2  setosa
    ## 5          5.0         3.6          1.4         0.2  setosa
    ## 6          5.4         3.9          1.7         0.4  setosa

``` r
iris %>% mutate_if(is.numeric, round) %>% head() #Only show 6 rows
```

    ##   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
    ## 1            5           4            1           0  setosa
    ## 2            5           3            1           0  setosa
    ## 3            5           3            1           0  setosa
    ## 4            5           3            2           0  setosa
    ## 5            5           4            1           0  setosa
    ## 6            5           4            2           0  setosa

``` r
iris %>% summarize_if(is.numeric, list(avg = mean, med = median))
```

    ##   Sepal.Length_avg Sepal.Width_avg Petal.Length_avg Petal.Width_avg
    ## 1         5.843333        3.057333            3.758        1.199333
    ##   Sepal.Length_med Sepal.Width_med Petal.Length_med Petal.Width_med
    ## 1              5.8               3             4.35             1.3

mutate\_at and summarize\_at are similar, but let you explicitly choose
which columns to apply a function to.

``` r
head(mtcars)
```

    ##                    mpg cyl disp  hp drat    wt  qsec vs am gear carb
    ## Mazda RX4         21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
    ## Mazda RX4 Wag     21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
    ## Datsun 710        22.8   4  108  93 3.85 2.320 18.61  1  1    4    1
    ## Hornet 4 Drive    21.4   6  258 110 3.08 3.215 19.44  1  0    3    1
    ## Hornet Sportabout 18.7   8  360 175 3.15 3.440 17.02  0  0    3    2
    ## Valiant           18.1   6  225 105 2.76 3.460 20.22  1  0    3    1

``` r
#Choose columns by position
mtcars %>% summarize_at(c(1, 3:7), list(avg = mean, med = median))
```

    ##    mpg_avg disp_avg   hp_avg drat_avg  wt_avg qsec_avg mpg_med disp_med hp_med
    ## 1 20.09062 230.7219 146.6875 3.596563 3.21725 17.84875    19.2    196.3    123
    ##   drat_med wt_med qsec_med
    ## 1    3.695  3.325    17.71

``` r
#Or use vars() to select values as you would with select()
mtcars %>% summarize_at(vars(mpg, disp:qsec), list(avg = mean, med = median))
```

    ##    mpg_avg disp_avg   hp_avg drat_avg  wt_avg qsec_avg mpg_med disp_med hp_med
    ## 1 20.09062 230.7219 146.6875 3.596563 3.21725 17.84875    19.2    196.3    123
    ##   drat_med wt_med qsec_med
    ## 1    3.695  3.325    17.71

``` r
#Works by group as well
mtcars %>% group_by(cyl) %>% summarize_at(vars(mpg, disp:qsec), list(avg = mean, med = median))
```

    ## # A tibble: 3 x 13
    ##     cyl mpg_avg disp_avg hp_avg drat_avg wt_avg qsec_avg mpg_med disp_med hp_med
    ##   <dbl>   <dbl>    <dbl>  <dbl>    <dbl>  <dbl>    <dbl>   <dbl>    <dbl>  <dbl>
    ## 1     4    26.7     105.   82.6     4.07   2.29     19.1    26       108     91 
    ## 2     6    19.7     183.  122.      3.59   3.12     18.0    19.7     168.   110 
    ## 3     8    15.1     353.  209.      3.23   4.00     16.8    15.2     350.   192.
    ## # ... with 3 more variables: drat_med <dbl>, wt_med <dbl>, qsec_med <dbl>

## for loops

`for` loops are not a bad thing, but there are often better options. If
you’re trying to…

1.  read multiple files: use `lapply`, `map`, `map_dfr`, `vroom`, or
    `import`
2.  split a data frame into groups and do something to each group such
    as fit a model or create a plot: use `group_map`, `group_modify`, or
    `group_walk`
3.  apply one or more functions to multiple columns in a data frame: use
    `mutate_at`, `mutate_if`, `mutate_all`, `summarize_at`,
    `summarize_if`, `summarize_all`

`for` loops are useful when you are doing something iterative where the
input of one run depends on the output of a previous run.

``` r
#Random walk example
n <- 100
x <- 0
#Do n steps
for(i in 1:n) {
  #Randomly add -1 or 1 to previous result
  x[i+1] <- x[i] + sample(c(-1, 1), 1) #x[i+1] <- value is more memory efficient than x <- c(x, value)
}

#Create data frame with time t and position x
walk_data <- data.frame(t = 0:100, x)

#Plot data
ggplot(walk_data, aes(t, x)) +
  geom_line() +
  theme_classic()
```

![](apply-tutorial_files/figure-gfm/for-1.png)<!-- -->

``` r
#If all you care about is the final destination, sapply or map is easier
sum(sapply(1:n, function(x) sample(c(-1, 1), 1)))
```

    ## [1] 10

``` r
sum(map_dbl(1:n, ~sample(c(-1, 1), 1)))
```

    ## [1] 0
