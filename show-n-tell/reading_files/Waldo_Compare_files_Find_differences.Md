# Waldo
### Compare files and Find differences


![](https://compote.slate.com/images/da10c202-1283-4e22-9edf-a2a26f5880dc.jpg)


```r
library(tidyverse)

#install.packages("waldo")
library(waldo)
```


```r
old <- 4
new <- 5
compare(old, new)


apples  <- c(40, 4000)
oranges <- c(40, "4,000")
compare(apples, oranges)

fruit <- c("apple", "orange", 4) 
```

Bigger things and subtle changes.

```r
sites_2019     <- c("Westview School",             
                    "Waseca Road",                 
                    "Voyageurs",                   
                    "Virgina City Hall",            
                    "U of M - Duluth",            
                    "U of M - Cedar Creek",         
                    "Talahi School ",               
                    "Stanton Air Field",           
                    "St. Paul Park Refinery 438",   
                    "St. Paul Park Refinery 436",   
                    "St. Michael Elementary School",
                    "St. Louis Park City Hall")

sites_2020 <- sites_2019[-9]
sites_2020[7] <- "Talahi School"


compare(sites_2019, sites_2020)
```

> Let's move on to comparing Data Frames.

[Palmer Penguins!](https://allisonhorst.github.io/palmerpenguins/)

![](https://allisonhorst.github.io/palmerpenguins/articles/articles/img/lter_penguins.png)

```r
#install.packages("remotes")
remotes::install_github("allisonhorst/palmerpenguins")
library(palmerpenguins)
```

```r
my_penguins <- penguins

glimpse(my_penguins)

my_penguins %>% count(species)
```

Exciting! Let's share our preliminary data with our Antarctica research partners.

```r
shared_penguins <- my_penguins
```

Then you fix some errors in the data.

```r
## Remove a doubled measurement from a unit conversion error
my_penguins[1, ]$bill_length_mm <- my_penguins[1, ]$bill_length_mm / 2

## Two entries were entered without their data
my_penguins <- dplyr::filter(my_penguins, !is.na(body_mass_g))
```

Time flies by. A month later you notice a chart your research partner is sharing doesn't align with your results. Hmmm... Do they have the latest data?

```r
compare(my_penguins, shared_penguins)

```

Try flippering the order around.
```r
compare(my_penguins, shared_penguins)

```



