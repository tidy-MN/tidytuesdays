library(tidyverse)
library(data.table)
library(lubridate)
library(glue)

missing_cats <- fread("https://raw.githubusercontent.com/MPCA-data/tidytuesdays/master/show-n-tell/exercises/missing_cats/missing_cat_list.csv")

missing_cats <- mutate(missing_cats, age = floor(time_length(ymd(20210413) - mdy(birthday), "years")))

found_cats <- map_dfr(1:83, ~fread(glue("https://raw.githubusercontent.com/MPCA-data/tidytuesdays/master/show-n-tell/exercises/missing_cats/meow_house_cats/cat{.}.csv")))

comparison <- function(x, y){
  case_when(
    str_detect(x, "<=") ~y <= as.numeric(str_extract(x, "\\d+")),
    str_detect(x, ">=") ~y >= as.numeric(str_extract(x, "\\d+")),
    T ~ x == y)
}

cat_matches <- found_cats %>%
  rowwise() %>%
  group_map( ~filter(missing_cats,
                     across(c(sex, color, grumpy:greedy, age),
                            function(z) comparison(.[[cur_column()]], z)
                     )
  )
  )

cat_matches_tbl <- bind_rows(cat_matches) %>% rownames_to_column() %>% select(rowname, name, country)
