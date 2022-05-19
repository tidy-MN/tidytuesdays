# 2020 — Trick or Treat? 

<br>

## Night theme :moon:

> The fun starts when it gets dark. Let's make our charts ready for night time.

![](https://github.com/MPCA-data/tidytuesdays/blob/master/images/starwars_dark.png?raw=true)

```{r}
remotes::install_github("hrbrmstr/hrbrthemes")

library(tidyverse)
library(hrbrthemes)

starwars <- starwars

ggplot(starwars, aes(height, log10(mass))) + 
  geom_point(aes(size = 0.02*log10(mass)), color = "#FF7518", alpha = 0.25, show.legend = F) +
  labs(title = "STARWARS", subtitle = "Alien heights and mass", y = "mass") +
  theme_modern_rc(base_size = 19) 
```

<br>

> Can you make this spookier?

- Try clown nose red: `#962e1a`
- Or toad slime green: `#B0C569`
- Or Zombie color: `???`

<br><br>

## BUT CANDY!

The trick to treating is having enough people to trade with to get what you want. But how do you ever agree on the value of different candies. How many Smarties is my box of Nerds worth? And could I get a 100 Tootsie Rolls for my 1 Reeses Peanut Butter Cup - is that not even enough?

![](https://github.com/MPCA-data/tidytuesdays/blob/master/images/candy.png?raw=true)


> Well have no fear, the answer is here. 


The 538 team provides us with candy rankings for 85 Halloween candies. Now you can use survey results to weight your candy trading appropriately.

1. Load the data

```{r load-candy, cache=TRUE}
library(tidyverse)

candy_data <- read_csv("https://raw.githubusercontent.com/MPCA-data/tidytuesdays/master/show-n-tell/exercises/candy-data.csv")

```

## Can there be too much sugar? Ever? Really?

- Is their relationship between sugar content and win percentage?

## My friends say my best quality is chocolate

- What candy quality best predicts winning?
- Why isn't there a `sour` category? *(Seriously. Did these people even like candy?)*

## Your personal ranking

- Use mutate and some algebra to create a candy index. You can weight each candy descriptor according to you or your group's preferences.
- Chart your rankings

<br><br>

# And... Action!

<br>

> **Grab the ketchup folks we're making a scary movie.**


<img src="https://i.pinimg.com/564x/fe/9c/32/fe9c3239eb69dbc16ee4e78bd386ebc5.jpg" align="left" width="70%">

## Boo!

<img src="https://i.pinimg.com/originals/5b/4d/6b/5b4d6be9dbe61d57eacf3e467fbb4ea8.png" width="25%" align="left" >


## The DATA

> Before we get too far, let's look at past films for clues about what makes a good spooky movie.

```{r, cache=T}
library(tidyverse)

all_films <- read_csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2018/2018-10-23/movie_profit.csv")

scary <- filter(all_films, genre == "Horror") 

```

<br>

## Explore

> **We need answers. Can you find them, before they find you?**

### Genre

Use `ggplot2` or `plotly`.

- Is Horror a good genre for making money?

### Lofty goals

- Which film grossed the most $$$?  
- Which film made the most profit?

### Timing

Use `lubridate`

- Which `month` is best to release our film?
- Which `day` of the month is best to release our film? *(Psst... You might be cursed if you get this wrong.)*

> *Heat map calendar example*

[![](https://pbs.twimg.com/media/EIGYfi3UEAADuWX?format=png&name=small)](https://github.com/alysonla/tidy-tuesday)


### Budget

- For most profit, should we spend: 
    - less than 1 million
    - more than 1 million
    - more than 10 million
    - or more than 100 million?

<br><br>

# Ghost stories

> Our movie needs a plot, or at least a semblance of one. Here's a data set with a short summary of recent horror movie story lines.

```{r, cache=T}
plots <- read_csv("https://github.com/MPCA-data/tidytuesdays/blob/master/show-n-tell/exercises/IMDB%20Horror%20movies.csv?raw=true")

## Data from https://www.kaggle.com/PromptCloudHQ/imdb-horror-movie-dataset
```

## Questions, I have a few...

- How many horror movies involve mutant penguins or a scary bunny?
- What movies were filmed in Finland - the scariest country in the Universe.
- Sample 2 movies randomly. Swap the villains in the 2 movie's plot lines.
    - Share your favorite version with the group.
    - :warning: WARNING: This probably doesn't need to be said, but clowns are too scary. Please drop all movies referencing clowns.

<br>

> *Movie ratings by budget example*

[![](https://pbs.twimg.com/media/EH7OJQOXUAArcJh?format=jpg&name=small)](https://github.com/jennadv/TidyTuesday/blob/master/Horror%20Movies/Horror%20Movies.R)

<br>
<br>


