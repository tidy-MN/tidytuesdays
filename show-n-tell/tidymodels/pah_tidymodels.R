library(tidyverse)
library(tidymodels)
library(skimr)
library(janitor)
library(extdplyr)
library(plotly)

tidymodels_packages()
tidyverse_packages() %>% intersect(tidymodels_packages())

pah_data <- read_csv("https://github.com/MPCA-data/tidytuesdays/raw/master/show-n-tell/tidymodels/data/profiles.csv")

skim(pah_data)

pah_data <- clean_names(pah_data)
names(pah_data)

#Only keep columns of interest
pah_data <- select(pah_data, site_name, setting, date, pah, profile)

#Pivot to wide format
pah_data <- pivot_wider(pah_data,
                        names_from = pah,
                        values_from = profile) %>%
  select(-date)

#Set seed for reproducability
set.seed(20210309)

#Split into training and testing sets with 80% of data from each site in training set
pah_split <- pah_data %>%
  mutate(across(where(is.character), factor)) %>%
  initial_split(prop = 0.8, strata = site_name)

#Create training and testing data sets
train <- training(pah_split)
test <- testing(pah_split)

#Create recipe for predicting setting, normalize numeric columns, and impute missing BAP values
recipe <- recipe(setting ~ ., data = train) %>%
  step_rm(site_name) %>%
  step_normalize(where(is.numeric)) %>%
  step_bagimpute(BAP_prof, impute_with = imp_vars(where(is.numeric))) %>%
  prep()

#View effects of recipe transformations
bake(recipe, train) %>% skim()

#View available models
View(model_db)

#Use kth nearest neighbor model from kknn package
model <- nearest_neighbor(round(sqrt(nrow(train)))) %>%
  set_mode("classification") %>%
  set_engine("kknn")

#Create workflow and fit model
pah_workflow <- workflow() %>%
  add_recipe(recipe) %>%
  add_model(model) %>%
  fit(train)

#Predict settings of testing data
predict <- predict(pah_workflow, test) %>%
  bind_cols(test)

#Show confusion matrix
predict %>% conf_mat(setting, .pred_class)

#Show overall accuracy
predict %>% accuracy(setting, .pred_class)

#Show percent of each setting in test data for reference
predict %>% pct_routine(setting)

#Switch to random forest model
model <- rand_forest() %>%
  set_mode("classification") %>%
  set_engine("ranger")

#Update and fit with random forest
pah_workflow <- pah_workflow %>% update_model(model) %>% fit(train)

#Predict and calculate metrics for random forest model
predict <- predict(pah_workflow, test) %>%
  bind_cols(test)

predict %>% conf_mat(setting, .pred_class)

predict %>% accuracy(setting, .pred_class)

#Change recipe to predict site instead
recipe <- recipe(site_name ~ ., data = train) %>%
  step_rm(setting) %>%
  step_normalize(where(is.numeric)) %>%
  step_bagimpute(BAP_prof, impute_with = imp_vars(where(is.numeric))) %>%
  prep()

#Update recipe
pah_workflow <- pah_workflow %>% update_recipe(recipe) %>% fit(train)

#Predict site names of test data
predict <- predict(pah_workflow, test) %>%
  bind_cols(test)

#Calculate overall accuracy
predict %>% accuracy(site_name, .pred_class)

#Show confusion matrix in plot
(predict %>% conf_mat(site_name, .pred_class) %>% autoplot() +
  theme(axis.text.x = element_text(angle = 270))) %>% ggplotly()

#Get confusion matrix in tibble form and calculate metrics
confusion <- (predict %>% conf_mat(site_name, .pred_class))[["table"]] %>% as_tibble() %>%
  group_by(Truth) %>%
  mutate(truth_percent = 100 * round(n/sum(n), 2)) %>%
  group_by(Prediction) %>%
  mutate(prediction_percent = 100 * round(n/sum(n), 2))

#What percent of a site did the model correctly classify?
(confusion %>%
    ggplot(aes(Truth, Prediction, fill = truth_percent)) +
    geom_tile() +
    theme(axis.text.x = element_text(angle = 270))) %>% ggplotly()

#What percent of the prediction was actually the correct site?
(confusion %>%
    ggplot(aes(Truth, Prediction, fill = prediction_percent)) +
    geom_tile() +
    theme(axis.text.x = element_text(angle = 270))) %>% ggplotly()
