library(tidyverse)
library(mncolors)
library(hrbrthemes)
#remotes::install_github("ciannabp/inauguration")
library(inauguration)

# MN colors
ggplot(data = mpg) +
  geom_point(aes(x = displ, y = hwy, color = class), size = 6, alpha = 0.7) +
  scale_color_mn(palette = "extended")

ggplot(data = mpg) +
  geom_point(aes(x = displ, y = hwy, color = class), size = 6, alpha = 0.7) +
  scale_color_mn(palette = "green", reverse = F)


# Inauguration colors
ggplot(sample_n(diamonds, 300)) +
  geom_point(aes(y = price, x = log10(carat), color = color), alpha = 0.7, size = 7) +
  scale_color_manual(values = inauguration("inauguration_2021_bernie")) +
  scale_y_comma() +
  theme_ipsum() #theme_ft_rc()


# Mittens are nice
ggplot(sample_n(diamonds, 300)) +
  geom_point(aes(y = price, x = log10(carat), color = cut), alpha = 0.7, size = 7) +
  scale_color_manual(values = inauguration("bernie_mittens")) +
  scale_y_comma() +
  theme_ft_rc()
