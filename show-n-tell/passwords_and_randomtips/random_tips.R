library(tidyverse)


passwords <- read_csv(unz("C:/Users/kmell/Desktop/TidyTuesdayRandomTips/passwords.zip", "passwords.csv"))

##Here is a webpage that explains how to do this if you have multiple zip files and you don't want to extract them first
##https://stackoverflow.com/questions/40536666/r-read-multiple-files-from-zip-without-extracting
#########################################

glimpse(passwords)



library(wordcloud2)

min(passwords$offline_crack_sec)

##It won't work!
##Why?
##There are NAs in the dataset

passwords <- passwords %>%
  filter(!is.na(offline_crack_sec))


##one way to visualize a bunch of a text is to make a word cloud. This one is pretty funny, because we have a huge variation in the amount of time it takes to crack passwords offline. 

#install.packages("wordcloud2")

library(wordcloud2)

wordcloud2(passwords %>% select(password, offline_crack_sec), size = 1)
           
summary(passwords$offline_crack_sec)


##Let's make a chart where we can actually look at the seonds it took to crack the passwords offline
## Let's make a diverging bar chart and look at cracking times over and under the mean
## First, we need to normalize the offline password cracking times (seconds)

passwords <- passwords %>%
  group_by() %>%
  mutate(mean_offline_crack_sec = mean(offline_crack_sec),
         sd_offline_crack_sec = sd(offline_crack_sec)) %>%
  rowwise() %>%
  mutate(z_offline_crack_sec = (offline_crack_sec - mean_offline_crack_sec)/sd_offline_crack_sec,
         above_below = ifelse(z_offline_crack_sec > 0, "above", "below"))

ggplot(passwords, aes(x = reorder(password, offline_crack_sec), y = z_offline_crack_sec, label = z_offline_crack_sec)) + 
  geom_bar(stat='identity', aes(fill = above_below), width=.5)  +
  scale_fill_manual(name="Guess the Password", 
                    labels = c("Above one second", "Below one second"), 
                    values = c("above"="#00ba38", "below"="#f8766d")) + 
  labs(subtitle="Time in seconds for a computer to guess a password", 
       title= "Diverging Bars") + 
  coord_flip()

##we are just going to pick one password per each offline_crack_sec 
##We want to see what kind of passwords align with each category of cracking time

##why use slice?
##sometimes you want the highest values
##What are the ten most used passwords?
passwords_highest_rank <- passwords %>%
  arrange(rank) %>%
  slice(1:10)

##sometimes it is way faster that unique
##so, if you think there are duplicates in your data and you've got ALOT of data, you can use slice
passwords_unique <- passwords %>%
  group_by_all() %>%
  slice(1)

##We group by the offline_crack_sec values (since these are repeating) and we just chose the first one. You'd rarely ever want to do this type of thing.
passwords_fil <- passwords %>%
  group_by(offline_crack_sec) %>%
  slice(1)

ggplot(passwords_fil, aes(x = reorder(password, offline_crack_sec), y = z_offline_crack_sec, label = z_offline_crack_sec)) + 
  geom_bar(stat='identity', aes(fill = above_below), width=.5)  +
  scale_fill_manual(name="Guess the Password", 
                    labels = c("above", "below"), 
                    values = c("above"="#00ba38", "below"="#f8766d")) + 
  labs(subtitle="Time in seconds for a computer to guess a password", 
       title= "Diverging Bars") + 
  coord_flip()


##lets look at the data again
glimpse(passwords)

##There is potentially some additional information in the category variable. Let's split that up and see if we can figure out how to use both what's before the hyphen and what's after the hyphen.
##This is something we have to do in MNRISKS data analysis because facility names and ids are joined by a forward slash and they are contained in the same column
##Example - Facility = `AB Machinists / 270130045`

## You can keep the old column or not with the argument remove = 

passwords <- passwords %>%
  separate(category, into = c("category", "category descriptor"), sep = "-")

unique(passwords$category)
unique(passwords$`category descriptor`)


####################################################
##Now for all of the passwords that are rude/macho vs those passwords that are alphanumeric. Let us see which was faster to crack, based on a box plot

passwords_fil2 <- passwords %>%
  filter(`category descriptor` %in% c("alphanumeric", "macho", "rude")) %>%
  mutate(comparator = ifelse(`category descriptor` == "alphanumeric", "alphanumeric", "humanized"))


ggplot(passwords_fil2, aes(x = comparator, y = offline_crack_sec)) +
  geom_boxplot()

passwords_fil2 <- passwords_fil2 %>%
  filter(offline_crack_sec < 10)

ggplot(passwords_fil2, aes(x = comparator, y = offline_crack_sec)) +
  geom_jitter(width = 0.1, alpha = 0.3)

##Oooohhh we found another passwords file

passwords_creation_dates <- read_csv("C:/Users/kmell/Desktop/TidyTuesdayRandomTips/password_creation_dates.csv")

passwords_dates <- left_join(passwords, passwords_creation_dates) %>% filter(!is.na(password))

##Lets make a calendar plot and see when people created the dumbest passwords. The higher the rank, the easier the password was to crack 

library(lubridate)

passwords_dates <- passwords_dates %>%
  mutate(day = wday(date_of_creation, label = TRUE),
         month = month(date_of_creation, label = T))

ggplot(passwords_dates, aes(day, month, fill = offline_crack_sec)) +
  geom_tile() 

##install.packages("forcats")

library(forcats)

ggplot(passwords_dates, aes(day, fct_rev(month), fill = offline_crack_sec)) +
  geom_tile() 


library(openair) #install.packages("openair") 


passwords_dates <- passwords_dates %>%
  rename(date = date_of_creation)

calendarPlot(passwords_dates, pollutant  = "offline_crack_sec", statistic  = "mean", year = 2017, 
             annotate   = "value", digits = 0, key.footer = "seconds", par.settings = list(fontsize=list(text=12), layout.heights=list(top.padding=-1)),
             main = "Time to crack a password offline")


##Time series
passwords_dates_counts <- passwords_dates %>%
  group_by(offline_crack_sec, date_of_creation, day, month) %>%
  summarise(count = n())

ggplot(passwords_dates_counts, aes(date_of_creation, count, color = offline_crack_sec)) +
  geom_line()

#######################
##How to make a zip file

##install.packages("zip")

passwords <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-01-14/passwords.csv') %>% filter(!is.na(password))
##How I made the zipfile to start

write_csv(passwords, "C:/Users/kmell/Desktop/CrossMedia/passwords.csv")

##install.packages("zip")
library(zip)

zipr("C:/Users/kmell/Desktop/CrossMedia/passwords.zip", "C:/Users/kmell/Desktop/CrossMedia/passwords.csv")


##How I made the date dataset
library(lubridate)

passwords_use_dates <- passwords %>%
  rowwise() %>%
  mutate(date_of_creation = sample(seq(ymd("2017/01/01"), ymd("2017/12/31"), by = "day"), 1)) %>%
  mutate(date_of_creation = as.character(date_of_creation))

passwords_use_dates <- passwords_use_dates %>%
  mutate(date_of_creation = 
           ifelse(offline_crack_sec < 1E-2, "2017/12/23",            ifelse(between(offline_crack_sec, 1E-1, 1E-2), "2017/04/01", 
           ifelse(between(offline_crack_sec, 1E-1, 1), "2017/07/05", date_of_creation)))) %>%
  select(rank, password, date_of_creation) %>%
  mutate(date_of_creation = ymd(date_of_creation)) %>%
  filter(!is.na(password))

write_csv(passwords_use_dates, "C:/Users/kmell/Desktop/TidyTuesdayRandomTips/password_creation_dates.csv")

