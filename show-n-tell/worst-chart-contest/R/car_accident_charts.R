library(tidytuesdayR)
library(plotly)
library(tidyverse)
library(almanac)
library(glue)
library(htmlwidgets)

# directory to save plots
output_dir <- ""

# time consuming to run, set to TRUE if you want to run
run_rainbow_plot <- FALSE

# load data
tuesdata <- tidytuesdayR::tt_load(2025, week = 16)

# function to generate 4/20 holiday
hol_420 <- function() yearly() %>%
  recur_on_month_of_year(4) %>%
  recur_on_day_of_month(20)

# data frame of holidays and theme colors
holidays <- tribble(
  ~name, ~display, ~color1, ~color2,
  'new_years_eve', 'New Years Eve', 'gray', 'white',
  'new_years_day', 'New Years Day','blue', 'white',
  'valentines_day', 'Valentines Day', 'red', 'hotpink',
  'easter', 'Easter', 'lightgreen', 'hotpink',
  '420', '4/20', 'green', 'gray',
  'us_memorial_day', 'Memorial Day', 'blue', 'red',
  'us_independence_day', 'Independence Day', 'red', 'blue',
  'halloween', 'Halloween', 'darkorange', 'black',
  'us_thanksgiving', 'Thanksgiving', 'brown', 'orange',
  'christmas_eve', 'Christmas Eve', 'red', 'green',
  'christmas', 'Christmas Day', 'green', 'red'
)

# dynamically generate list of holidays from 1992 to 2016
holiday_dates <- map(holidays$name, \(x) eval(sym(glue("hol_{x}")))() %>%
      alma_events(year = 1992:2016) %>%
      {tibble(date = .)}
      ) %>% set_names(holidays$name) %>%
  list_rbind(names_to = 'name')

# get raw accident data
accidents <- tuesdata$daily_accidents

# join holiday list and separate year from date
accidents <- accidents %>%
  left_join(holiday_dates, join_by(date)) %>%
  left_join(holidays, join_by(name)) %>%
  mutate(
    year = year(date),
    date = as.character(date) %>% str_sub(6),
    pattern = ifelse(is.na(name), "", "/")
    )

# split holiday data frame into separate lists for adding layers
accident_holidays <- accidents %>%
  drop_na(name) %>%
  group_by(name) %>%
  group_split(.keep = TRUE)

# create bad plot
bad_plot <- accidents %>%
  filter(is.na(name)) %>%
  plot_ly(x = ~date, y = ~fatalities_count,
          marker = list(
            pattern = list(
              shape = ~pattern,
              fgcolor = ~color2,
              bgcolor = ~color1
            )
          )) %>%
  add_trace(color = I('yellow'), type = 'bar',
            name = 'No holiday', frame = ~year, ids = ~date)

# add different patterns as layers for legend
for (item in accident_holidays) {
  bad_plot <- bad_plot %>%
    add_trace(data = item, type = 'bar', name = item$display[1], frame = ~year, ids = ~date)
}

bad_plot <- bad_plot %>%
  layout(
    xaxis = list(title = ""),
    yaxis = list(title = "Number of fatalities")
  )

better_plot <- accidents %>%
  plot_ly(x = ~display %>% replace_na("No holiday"), y = ~fatalities_count) %>%
  add_boxplot(line = list(color = "black", width = 4)) %>%
  layout(
    xaxis = list(title = "", tickfont = list(size=18), tickangle = 90),
    yaxis = list(
      title = "Number of fatalities",
      tickfont = list(size=18),
      titlefont = list(size=24)
    )
  )

saveWidget(bad_plot, glue("{output_dir}/accidents_bad.html"))
saveWidget(better_plot, glue("{output_dir}/accidents_better.html"))

if (run_rainbow_plot) {
  rainbow_plot <- accidents %>%
    mutate(date2 = as.factor(date)) %>%
    plot_ly(x = ~date, y = ~fatalities_count, frame = ~year) %>%
    add_bars(color=~date2)
  saveWidget(rainbow_plot, glue("{output_dir}/accidents_rainbow.html"))
}