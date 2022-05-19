
##This short tutorial is available in this vignette
##We are going to change it a bit to run this on our own data
##https://cran.r-project.org/web/packages/fitdistrplus/vignettes/paper2JSS.pdf

library(fitdistrplus)
library(tidyverse)
data("groundbeef")
glimpse(groundbeef)

plotdist(groundbeef$serving, histo = TRUE, demp = TRUE)
descdist(groundbeef$serving, boot = 1000)
fw <- fitdist(groundbeef$serving, "weibull")
fg <- fitdist(groundbeef$serving, "gamma")
fln <- fitdist(groundbeef$serving, "lnorm")

par(mfrow = c(2, 2))

plot.legend <- c("Weibull", "lognormal", "gamma")
denscomp(list(fw, fln, fg), legendtext = plot.legend)
qqcomp(list(fw, fln, fg), legendtext = plot.legend)
cdfcomp(list(fw, fln, fg), legendtext = plot.legend)
ppcomp(list(fw, fln, fg), legendtext = plot.legend)

##Here's how I tested my data
library(fitdistrplus)
library(tidyverse)
pah_data <- read_csv("X:/Programs/Air_Quality_Programs/Air Focus Areas/EPA Community Scale Monitoring of PAHs Project/Data Analysis/Data Processing/allPAHconcentrations.csv") %>%
  filter(Analyte == "Naphthalene",
         Sampler_Type == "Total")

plotdist(pah_data$Result, histo = TRUE, demp = TRUE)
descdist(pah_data$Result, boot = 1000)
fw <- fitdist(pah_data$Result, "weibull")
fg <- fitdist(pah_data$Result, "gamma")
fln <- fitdist(pah_data$Result, "lnorm")

par(mfrow = c(2, 2))

plot.legend <- c("Weibull", "lognormal", "gamma")
denscomp(list(fw, fln, fg), legendtext = plot.legend)
qqcomp(list(fw, fln, fg), legendtext = plot.legend)
cdfcomp(list(fw, fln, fg), legendtext = plot.legend)
ppcomp(list(fw, fln, fg), legendtext = plot.legend)

########
##Now we're going to go through a Machine Learning Tutorial here: https://www.kaggle.com/rtatman/welcome-to-data-science-in-r 


library(tidyverse) # utility functions
library(rpart) # for regression trees
install.packages("randomForest")
library(randomForest) # for random forests

# read the data and store data in DataFrame titled melbourne_data
melbourne_data <- read_csv("https://raw.githubusercontent.com/MPCA-data/tidytuesdays/master/show-n-tell/distributions%20and%20random%20forests/melb_data.csv")

summary(melbourne_data)

fit <- rpart(Price ~ Rooms + Bathroom + Landsize + BuildingArea +
               YearBuilt + Lattitude + Longtitude, data = melbourne_data)

# plot our regression tree 
plot(fit, uniform=TRUE)
# add text labels & make them 60% as big as they are by default
text(fit, cex=.6)


print("Making predictions for the following 5 houses:")
print(head(melbourne_data))

print("The predictions are")
print(predict(fit, head(melbourne_data)))

print("Actual price")
print(head(melbourne_data$Price))


# package with the mae function
library(modelr)

# get the mean average error for our model
mae(model = fit, data = melbourne_data)


# split our data so that 30% is in the test set and 70% is in the training set
splitData <- resample_partition(melbourne_data, c(test = 0.3, train = 0.7))

# how many cases are in test & training set? 
lapply(splitData, dim)

# fit a new model to our training set
fit2 <- rpart(Price ~ Rooms + Bathroom + Landsize + BuildingArea +
                YearBuilt + Lattitude + Longtitude, data = splitData$train)

# get the mean average error for our new model, based on our test data
mae(model = fit2, data = splitData$test)
