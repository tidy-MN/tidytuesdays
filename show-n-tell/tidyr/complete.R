library(tidyverse)

# Example County pollution data 
releases <- tibble(county = c("Benton", "Benton",
                              "Carver",
                              "StLouis", "StLouis",
                              "Dakota", "Dakota",
                              "Red Lake",
                              "Itasca", "Itasca",
                              "Rice", "Rice"),
                   pollutant = c(c("Pb", "Arsenic"),
                                 "Pb",
                                 rep(list("Pb", "Arsenic"), 2),
                                 "Arsenic",
                                 rep(list("Pb", "Arsenic"), 2)),
                   release_lbs = c(0.1,0,
                                   3,
                                   5, 2.1,
                                   22, 50,
                                   1.1,
                                   19, 0.2,
                                   66, 4))


# 7 County Metro
metro_counties <- tibble(county = c("Anoka", "Carver",
                                    "Dakota", "Hennepin",
                                    "Ramsey", "Scott",
                                    "Washington"),
                         metro = TRUE)



# Add Metro flag to counties
releases <- left_join(releases, metro_counties)

releases <- mutate(releases, metro = !is.na(metro))


# Metro / Outstate averages
in_out_avg <- releases %>%
              group_by(metro, pollutant) %>%
              summarize(avg_lbs = mean(release_lbs, na.rm = T))
            #n = n())


# COMPLETE()
rel_complete <- releases %>%
                complete(pollutant, nesting(county, metro))


rel_complete <- releases %>%
                complete(pollutant, nesting(county, metro),
                         fill = list(release_lbs = 0))

# Metro / Outstate averages
in_out_avg2 <- rel_complete %>%
               group_by(metro, pollutant) %>%
               summarize(avg_lbs = mean(release_lbs, na.rm = T))
               #n = n())



# Garbage data w/ DATES
## (for Barbara)
garbage <- tibble(site = c(rep(list("Bemidji", "Duluth", "Rochester"), 7)),
                  date = rep(c(as.Date("2021-05-10") + seq(7, 49, 7)), each = 3),
                  tons = rnorm(21, 50, 20) %>% round)

# Drop 4 days
garbage <- slice_sample(garbage, n = 17)


# Average garbage by site
## (This gives wrong answer)
garbage_avg <- garbage %>%
               group_by(site) %>%
               summarize(avg_tons = mean(tons))


# COMPLETE - the data first
garbage_complete <- garbage %>%
                    complete(date, nesting(site),
                             fill = list(tons = 0))


# Average again by site
## (A better answer)
garbage_avg2 <- garbage_complete %>%
                group_by(site) %>%
                summarize(avg_lbs = mean(tons))
