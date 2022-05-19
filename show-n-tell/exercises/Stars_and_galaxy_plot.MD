Birth of a galaxy
================

![Image of Milky Way Galaxy spiral arms of
stars](https://i0.wp.com/shawenyao.github.io/R/output/milky_way/plot_0_demo.jpg?zoom=1.100000023841858&w=578&ssl=1)

### 

*Reference: <https://www.r-bloggers.com/2020/11/the-birth-of-a-galaxy>*

## Setup

### Required packages

``` r
library(tidyverse)

install.packages("patchwork")
library(patchwork)
```

## Space is dark

We start with a blank plot.

``` r
ggplot()
```

<br>

And make it dark.

``` r
ggplot() + 
  theme(panel.background = element_rect(fill = "black"))  

space <- ggplot() + 
         theme_void()
         theme(panel.background = element_rect(fill = "black"))  
```

## A star

``` r
sun <- tibble(x = 0, y = 0)

ggplot(sun, aes(x = x, y = y)) + 
  geom_point(size = 17)  
```

## Turn off the lights

``` r
ggplot(sun, aes(x = x, y = y)) + 
  geom_point(color = "white", size = 17) +
  theme(panel.background = element_rect(fill = "black"))

# Drop the grid
ggplot(sun, aes(x = x, y = y)) + 
  geom_point(color = "white", size = 17) +
  theme_void() +
  theme(panel.background = element_rect(fill = "black"))
```

## Save theme options

``` r
star_theme <- theme_void() +
              theme(panel.background = element_rect(fill = "black"))
```

## Twinkle-twinkle

**Point shape options**

![](http://www.sthda.com/sthda/RDoc/figure/graphs/r-plot-pch-symbols-points-in-r.png)

``` r
ggplot(sun, aes(x = x, y = y)) + 
  geom_point(color = "white", shape = 8, size = 17) +
  star_theme  
```

### Add layers

Change transparency with `alpha = 0.5`.

``` r
ggplot(sun, aes(x = x, y = y)) + 
  geom_point(color = "white", shape = 8, size = 17, alpha = 0.2) +
  star_theme

# Stack smaller points for a brighter center
ggplot(sun, aes(x = x, y = y)) + 
  geom_point(color = "white", shape = 8, size = 17, alpha = 0.2) +
  
  geom_point(color = "white", shape = 8, size = 10, alpha = 0.3) +
  geom_point(color = "steelblue", shape = 8, size = 4, alpha = 0.7) +  # tomato star?
  star_theme  
```

## Spirals of suns

``` r
theta_center <- 0.001

theta_end <- 9

n_stars <- 700

thetas <- seq(from = theta_center, 
              to   = theta_end, 
              length.out = n_stars)

# Spiral curvieness
k <- 1.3

# Calculate star locations
spirals <- tibble(theta = thetas) %>%
                mutate(
                  r = theta**k,
                  x = r * cos(theta),
                  y = r * sin(theta)
                )

# View the spiral
ggplot(spirals, aes(x = x, y = y)) + 
      geom_point(color = "white", shape = 8, size = 4, alpha = 0.4) +
      star_theme 
```

## Multiple spirals

``` r
n_arms <- 2

spirals <- tibble()

for(n in 1:n_arms) {
  
  print(n)
  
  spirals <-
      tibble(id = n,
             theta = thetas) %>% 
      mutate(r = theta ^ k,
             x = r * cos(theta + 2 * pi * id / n_arms),
             y = r * sin(theta + 2 * pi * id / n_arms)) %>% 
      bind_rows(spirals)
  
}

ggplot(spirals, aes(x = x, y = y)) + 
    geom_point(color = "white", shape = 8, size = 4, alpha = 0.3) +
    star_theme 
```

## Jitter more stars

``` r
star_spacing <- 0.55

extra_stars <- 7

star_sizes  <- c(0.03, 0.1, 0.12, 0.45, 0.9, 1.3, 1.6)
 
star_alphas <- c(0.04, 0.05, 0.06, 0.07, 0.08, 0.1, 0.15, 0.2, 0.3, 0.4, 0.55)

star_colors <- c("#ef3038", "#c4e2d8", "steelblue", "#f3fed3", "lightgray", "white", "#66c5e5", "#73503a", "#010304")

stars <- spirals %>% 
  slice(rep(row_number(), extra_stars)) %>% 
  rowwise() %>%
  mutate(
    x = x + rnorm(1, sd = star_spacing + theta/13),
    y = y + rnorm(1, sd = star_spacing + theta/13),
    size  = sample(star_sizes, 1),
    alpha = sample(star_alphas, 1),
    color = sample(star_colors, 1),
    star_halo_size1 = ifelse(runif(1) > 0.7, size * 1.5, 0),
    star_halo_size2 = star_halo_size1 / 1.2
    )


# Stars with layered sparkles
ggplot(spirals, aes(x = x, y = y)) +
  geom_point(data = stars, size = stars$star_halo_size1, color = "white", shape = 8, alpha = 0.015) +
  geom_point(data = stars, size = stars$star_halo_size2, color = "white", shape = 8, alpha = 0.03) +
  geom_point(data = stars, size = stars$size, color = stars$color, shape = 8,  alpha = stars$alpha) +
  star_theme 
```

## Fuzzy artifacts

``` r
# Fuzzy stars
fuzzy_stars <- spirals %>% 
  slice(rep(row_number(), 4)) %>% 
  mutate(
    x = x + rnorm(n(), sd = star_spacing + theta/16),
    y = y + rnorm(n(), sd = star_spacing + theta/16),
    fuzzy_area = ifelse(theta > 1.1, 6 + theta/1.2, 0))


# Double stars
dbl_stars <- stars[sample(1:nrow(stars), nrow(stars)/10), ]

dbl_stars <- dbl_stars %>% 
              rowwise() %>%
              mutate(x = x + rnorm(1, sd = 0.02+size/8),
                     y = y + rnorm(1, sd = 0.02+size/8),
                     alpha = alpha*1.05,
                     size  = size*1.05)
```

### All together

``` r
ggplot(spirals, aes(x = x, y = y)) +
  geom_point(data = fuzzy_stars, 
             size = fuzzy_stars$fuzzy_area, color = "white", alpha = 0.002) +
  geom_point(data = stars, 
            size = stars$star_halo_size1, color = "white", shape = 8, alpha = 0.015) +
  geom_point(data = stars, 
             size = stars$star_halo_size2, color = "white", shape = 8, alpha = 0.03) +
  geom_point(data = stars, 
             size = stars$size, color = stars$color, shape = 8, alpha = stars$alpha) +
  geom_point(data = dbl_stars, 
             size = dbl_stars$size, alpha = dbl_stars$alpha, color = dbl_stars$color, shape = 8) +
  star_theme 
```

# The center yoke

``` r
eye_stars <- 5000

eye_rho   <- 0.25

eye_sd_y  <- 0.9

eye_sd_x  <- eye_sd_y*1.8

eye <- tibble(x = rnorm(eye_stars, sd = eye_sd_x)) %>%
       mutate(y  = eye_rho * x + sqrt(1 - eye_rho ** 2) * rnorm(n(), sd = eye_sd_y))


# Plot the Center
ggplot(data = spirals, aes(x = x, y = y)) +
  geom_point(data = eye, size = 1.7, color = "gold", shape = 8, alpha = 0.05) +
  star_theme

# Add some yellow variety 
ggplot(data = spirals, aes(x = x, y = y)) +
  geom_point(data = eye, size = 2.2, alpha = 0.008, color = "gold", shape = 8) +
  geom_point(data = eye, size = 1.2, alpha = 0.015, color = "gold", shape = 8) +
  geom_point(data = sample_n(eye, 5500, replace = T), size = 0.7, alpha = 0.09, color = "#fcfce2", shape = 8) +
  geom_point(data = sample_n(eye, 800), size = 0.7, alpha = 0.08, color = "#f2dd1a", shape = 8) +
  geom_point(data = sample_n(eye, 700), size = 0.7, alpha = 0.08, color = "#ebeb94", shape = 8) +
  geom_point(data = sample_n(eye, 500), size = 0.7, alpha = 0.1, color = "#fdfcd6", shape = 8) +
  star_theme


# Add to galaxy
g1 <- ggplot(spirals, aes(x = x, y = y)) +
  geom_point(data = fuzzy_stars, 
             size = fuzzy_stars$fuzzy_area, color = "white", alpha = 0.002) +
  geom_point(data = stars, 
            size = stars$star_halo_size1, color = "white", shape = 8, alpha = 0.01) +
  geom_point(data = stars, 
             size = stars$star_halo_size2, color = "white", shape = 8, alpha = 0.015) +
  geom_point(data = stars, 
             size = stars$size, color = stars$color, shape = 8, alpha = stars$alpha) +
  geom_point(data = dbl_stars, 
             size = dbl_stars$size, color = dbl_stars$color, shape = 8, alpha = dbl_stars$alpha) +
  geom_point(data = eye, size = 2.2, alpha = 0.008, color = "gold", shape = 8) +
  geom_point(data = eye, size = 1.2, alpha = 0.015, color = "gold", shape = 8) +
  geom_point(data = sample_n(eye, 5500, replace = T), size = 0.7, alpha = 0.09, color = "#fcfce2", shape = 8) +
  geom_point(data = sample_n(eye, 800), size = 0.7, alpha = 0.08, color = "#f2dd1a", shape = 8) +
  geom_point(data = sample_n(eye, 700), size = 0.7, alpha = 0.08, color = "#ebeb94", shape = 8) +
  geom_point(data = sample_n(eye, 500), size = 0.7, alpha = 0.1, color = "#fdfcd6", shape = 8) +
  star_theme
```

## A map home

``` r
# Add the sun
home <- g1 + geom_point(x = 0, y = -7, color = "gold", alpha = 0.01)
  
home

# Add the label
home <- home + 
        geom_text(x = 4, y = -11.3, label = "the Sun", color = "gold", size = 5, alpha = 0.6)

home

# Add a line
home <- home + 
        annotate("segment", 
                 x = 0.1,  xend = 3.7, 
                 y = -7.1, yend = -10.85,
                 color = "lightgray") 
   
home  
```

## The Universe expands

![](https://www.universetoday.com/wp-content/uploads/2011/05/WISE.jpg)
<br>

Use `patchwork` to combine multiple plots. In our case we can add
multiple galaxies to our universe.

``` r
library(patchwork)
```

## Galaxy clusters

``` r
g1 | home

# Remove white background lines
g1 | home + plot_annotation(theme = theme(plot.background = element_rect(fill = 'black')))
```

## Empty space

``` r
space

space / 
(space| home |space) / 
space + 
plot_annotation(theme = theme(plot.background = element_rect(fill = 'black')))
```

## A multi-verse

``` r
space / (space|space| g1  |space|space) /
space / (space|space|space| g1  |space) / 
space / (  g1 |space|space|space|space) /
        (space| g1  |space|space|space) / space + 
  plot_annotation(theme = theme(plot.background = element_rect(fill = 'black')))
```

## Name your universe

``` r
space / (space|space| g1  |space|space) /
space / (space|space|space| g1  |space) / 
space / (  g1 |space|space|space|space) /
        (space| g1  |space|space|space) / space + 
plot_annotation(title = "My Universe",
                theme = theme(plot.title = element_text(color = "white", size = 20)) &
                        theme(plot.background = element_rect(fill = 'black')) & 
                        theme(text = element_text('mono')))
```
