
# 🐈‍ Scary functions

<br><br>

## The Cat's Meow
```r
library(tidyverse)

# Make your own function
meow <- function() { "meow" }

meow()

# Add options with an argument
meow <- function(i = 2) { rep("meow", i) }

meow(i = 3)
```

<br>

>
> **Q:** Does `i` exist() outside of the function?
>

<br><br>

## Rock-paper-scissors 

<br>

![](https://upload.wikimedia.org/wikipedia/commons/thumb/6/67/Rock-paper-scissors.svg/220px-Rock-paper-scissors.svg.png)

<br>

#### The simplest option

```r
play <- function() {"rock"}

play()
```

<br><br>

### Add some randomness

>
> `IT's ALIVE!` 
>  *-Frankenstein*

<br>

```r
# All the options 
throws <- tibble(shape = c("rock", "paper", "scissors"))


# Random numbers
runif(3)

runif(100, 0, 3) %>% ceiling

# Re-set random number generator
set.seed(100)

# Random rows
mtcars

slice_sample(mtcars, n = 3)

slice_sample(throws, n = 1)

# Get values from table
throws$shape

throws$shape[1]

throws[1]

throws$shape[runif(1, 0, 3) %>% ceiling]
```

<br>

### Your turn

```r
play <- function(i = 1) {
  
  throws <- tibble(shape = c("rock", "paper", "scissors"))
  
  # Your code here
  #...
  #...
  #...
  
}

# Run your function
play(3)
```

### Good luck! 🏆
