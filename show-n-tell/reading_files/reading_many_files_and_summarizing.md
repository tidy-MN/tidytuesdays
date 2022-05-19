---
title: "reading_files"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

<br>

## Reading many files with a couple lines of code

Sometimes you recieve files little by little or after each season, and they are saved like "2006_water_data_fall.csv", and then you have 40 similarly named files. What do you do? The main hero in this story is list.files()

<br>

```{r read}

library(tidyverse)

movie_files <- list.files("X:/Agency_Files/Outcomes/Risk_Eval_Air_Mod/_Air_Risk_Evaluation/R/R_Camp/TidyTuesday/reading_files/movie_files")

movie_files

```

<br>

So, we have some files that we don't want to read. This happens a lot, especially if you haven't yet turned off the save history tool in R Studio.But list.files() returns a character list.So we can just remove stuff using character functions.

<br>


```{r filter}

movie_files <- movie_files[grepl(".csv", movie_files)]

movie_files

```

<br>

The OLD WAY I USED TO DO THIS was using a for loop. Before everyone starts screaming, NOOOO, I am only showing you two ways of doing this and then I will prove one point of why this isn't the best way.

<br>


```{r old way, warning = FALSE}

movies_all <- data.frame()

for(i in movie_files){
  
  setwd("X:/Agency_Files/Outcomes/Risk_Eval_Air_Mod/_Air_Risk_Evaluation/R/R_Camp/TidyTuesday/reading_files/movie_files/")
  
  movies <- read_csv(i)
  
  movies_fil <- movies %>%
    filter(`Runtime (Minutes)` <= 120)
  
  movies_all <- rbind(movies_fil, movies_all)
  
}


write_csv(movies_all, "X:/Agency_Files/Outcomes/Risk_Eval_Air_Mod/_Air_Risk_Evaluation/R/R_Camp/TidyTuesday/reading_files/our_movie_list.csv")

```

<br>

These files are small. Usually I have big giant MNRISKS files. SO, it is long overdue for me to learn some apply functions.

<br>

![](X:/Agency_Files/Outcomes/Risk_Eval_Air_Mod/_Air_Risk_Evaluation/R/R_Camp/TidyTuesday/reading_files/applyfunctions.jpg){width="500" style="margin-left:20px;"}


<br>

We will use lapply to read in these files and summarize them faster and more efficiently.

<br>

```{r lapply}
movie_files <- list.files("X:/Agency_Files/Outcomes/Risk_Eval_Air_Mod/_Air_Risk_Evaluation/R/R_Camp/TidyTuesday/reading_files/movie_files") 

movie_files <- movie_files[grepl(".csv", movie_files)] 

setwd("X:/Agency_Files/Outcomes/Risk_Eval_Air_Mod/_Air_Risk_Evaluation/R/R_Camp/TidyTuesday/reading_files/movie_files")

movie_files <- movie_files %>%
  lapply(read_csv) %>%
  bind_rows() %>%
  filter(`Runtime (Minutes)` <= 120) %>%
  write_csv("X:/Agency_Files/Outcomes/Risk_Eval_Air_Mod/_Air_Risk_Evaluation/R/R_Camp/TidyTuesday/reading_files/our_movie_list_BETTER.csv")
```

<br>

But the big question is, was Derek right? Was this faster? Let's install the package profvis to find out.

<br>

```{r profvis}

##install.packages("profvis")
library(profvis)

```

<br>

To make profvis do its magic we wrap our code into curly brackets inside the profvis function. It looks like this: profvis({what you want profvis to monitor})

<br>

```{r profvisforloop}

profvis({movie_files <- list.files("X:/Agency_Files/Outcomes/Risk_Eval_Air_Mod/_Air_Risk_Evaluation/R/R_Camp/TidyTuesday/reading_files/movie_files")

movie_files <- movie_files[grepl(".csv", movie_files)]

movies_all <- data.frame()

for(i in movie_files){
  
  setwd("X:/Agency_Files/Outcomes/Risk_Eval_Air_Mod/_Air_Risk_Evaluation/R/R_Camp/TidyTuesday/reading_files/movie_files")
  
  movies <- read_csv(i)
  
  movies_fil <- movies %>%
    filter(`Runtime (Minutes)` <= 120)
  
  movies_all <- rbind(movies_fil, movies_all)
  
}
write_csv(movies_all, "X:/Agency_Files/Outcomes/Risk_Eval_Air_Mod/_Air_Risk_Evaluation/R/R_Camp/TidyTuesday/reading_files/our_movie_list.csv")
  
})

```

<br>

So, that was 200 ms or so. Let's see how the lapply version works.

```{r profvislapply}

profvis({movie_files <- list.files("X:/Agency_Files/Outcomes/Risk_Eval_Air_Mod/_Air_Risk_Evaluation/R/R_Camp/TidyTuesday/reading_files/movie_files") 

movie_files <- movie_files[grepl(".csv", movie_files)] 

setwd("X:/Agency_Files/Outcomes/Risk_Eval_Air_Mod/_Air_Risk_Evaluation/R/R_Camp/TidyTuesday/reading_files/movie_files")

movie_files <- movie_files %>%
  lapply(read_csv) %>%
  bind_rows() %>%
  filter(`Runtime (Minutes)` <= 120) %>%
  write_csv("X:/Agency_Files/Outcomes/Risk_Eval_Air_Mod/_Air_Risk_Evaluation/R/R_Camp/TidyTuesday/reading_files/our_movie_list_BETTER.csv")
})


```

<br>

The lapply version is faster (180 ms). Derek is right! Derek is always right. Listen to Derek.

<br>

But, in all honesty the movie data didn't come to me in year based files. I lied. I had to write a for loop to save these files, because I hadn't yet forced myself to learn lapply as of 2pm yesterday afternoon. So, let's see how I did this in reverse. I will read in a file, and save it in pieces based on a category in the data. Then, I will pose a question.

<br>

```{r readindata}
##make the data

movies <- read_csv("X:/Agency_Files/Outcomes/Risk_Eval_Air_Mod/_Air_Risk_Evaluation/R/R_Camp/TidyTuesday/reading_files/movie_files")

years <- 2006:2016


setwd("X:/Agency_Files/Outcomes/Risk_Eval_Air_Mod/_Air_Risk_Evaluation/R/R_Camp/TidyTuesday/reading_files/movie_files")

for(i in years){
  movies_year <- filter(movies, Year == i)
  write_csv(movies_year, paste0("X:/Agency_Files/Outcomes/Risk_Eval_Air_Mod/_Air_Risk_Evaluation/R/R_Camp/TidyTuesday/reading_files/movie_files", i, ".csv"))
}
```

<br>

But again, I am trying to stop using for loops because I want to be faster and more efficient and not have my computer churning away day after day opening, summarizing and saving MNRISKS files.

<br>

```{r lapplyreadfiles}

movies <- read_csv("X:/Agency_Files/Outcomes/Risk_Eval_Air_Mod/_Air_Risk_Evaluation/R/R_Camp/TidyTuesday/reading_files/movie_data.csv") 

movies <- split(movies, movies$Year)

write <- function(i){write_csv(i, paste0("X:/Agency_Files/Outcomes/Risk_Eval_Air_Mod/_Air_Risk_Evaluation/R/R_Camp/TidyTuesday/reading_files/new_movie_data", i$Year[1], ".csv"))}

lapply(movies, write)

```

<br>

But let's test which one was faster!

<br>

```{r forloopprofvisread}

profvis({movies <- read_csv("X:/Agency_Files/Outcomes/Risk_Eval_Air_Mod/_Air_Risk_Evaluation/R/R_Camp/TidyTuesday/reading_files/movie_data.csv")

years <- 2006:2016


for(i in years){
  movies_year <- filter(movies, Year == i)
  write_csv(movies_year, paste0("X:/Agency_Files/Outcomes/Risk_Eval_Air_Mod/_Air_Risk_Evaluation/R/R_Camp/TidyTuesday/reading_files/movie_files", i, ".csv"))
}})
```

<br>

That took about 150ms. Let's see how long hte lapply version takes.

<br>

```{r lapplyprofvisread}
         


##Then using lapply()

profvis({movies <- read_csv("X:/Agency_Files/Outcomes/Risk_Eval_Air_Mod/_Air_Risk_Evaluation/R/R_Camp/TidyTuesday/reading_files/movie_data.csv") 

movies <- split(movies, movies$Year)

write <- function(i){write_csv(i, paste0("X:/Agency_Files/Outcomes/Risk_Eval_Air_Mod/_Air_Risk_Evaluation/R/R_Camp/TidyTuesday/reading_files/new_movie_data", i$Year[1], ".csv"))}

lapply(movies, write)
})

```

<br>

Whoa. That took 150ms. That is likely because I am brand new at using apply functions. Does anyone have a suggestion for me? I really wanted to save these files with the year. How do I change the lapply() based script so that each file is named by its year.

<br>

For a final tip, sometimes your data is stored in many folders. You you may want to search folders and only pull summarize and save files that include a folder path name with the word "air_ambient" in it. You can use list.dirs()

<br>

```{r listdirs}

directories <- list.dirs("X:/Agency_Files/Outcomes/Risk_Eval_Air_Mod/_Air_Risk_Evaluation/R/R_Camp/TidyTuesday/reading_files/")

```


### Stay well R users!!



