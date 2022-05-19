---
title: "multiple correlation plots"
author: "Kristie Ellickson"
date: "4/21/2020"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

## Getting the data and cleaning it up

<br>

We were given some data in an Excel `xlsx` file, so we need to assume there are several worksheets. Let's also assume we may need to clean up the column names.

<br>

```{r getpackages}

library(readxl)
library(janitor)
library(tidyverse)

```

<br>

First, we read in the data with the read_excel() function.

<br>

```{r get data}

excel_sheets("X:/Agency_Files/Outcomes/Risk_Eval_Air_Mod/_Air_Risk_Evaluation/R/R_Camp/TidyTuesday/multiple_correlation_viz/Algae Toxin Analysis for R.xlsx")

water_data <- read_excel("X:/Agency_Files/Outcomes/Risk_Eval_Air_Mod/_Air_Risk_Evaluation/R/R_Camp/TidyTuesday/multiple_correlation_viz/Algae Toxin Analysis for R.xlsx", sheet = "Clean Sheet")

##skip = 
##n_max = 

names(water_data)

water_data <- clean_names(water_data)

names(water_data)

```

<br>

## Multiple Correlations

<br>

Based on previous conversations with the scientist who is looking at this data set, we want to explore multiple correlations of column 8 - 11

<br>

```{r multiple correlations}

water_data <- water_data %>%
  dplyr::select(mc_mg_l_ros:n_p)

##install.packages("corrplot")

library(corrplot)

water_data_corr <- cor(water_data, method = "kendall", use = "pairwise.complete.obs")

##?cor

#tiff(paste0("X:/Agency_Files/Outcomes/Risk_Eval_Air_Mod/_Air_Risk_Evaluation/R/R_Camp/TidyTuesday/multiple_correlation_viz/water_data_corrplot.tiff"), width=10, height=7, units="in", pointsize=12, res=100, type=c("cairo")) 

corrplot(water_data_corr, method = "circle", type="lower", tl.cex=0.6) #plot matrix

##try square
#dev.off()

water_data_corr <- as.data.frame(water_data_corr)

```

<br>

Check your correlations using plotting. Always plot your data.

<br>


```{r scatter}

ggplot(data = water_data, aes(x = n_p, y = tp_mg_l)) +
  geom_point(size = 5)

##add some transparency

ggplot(data = water_data, aes(x = n_p, y = tp_mg_l)) +
  geom_point(size = 5, alpha = 0.2)


```

<br>

## Principal Component Analysis in R

<br>

Principal component analysis is pretty common in air pollution work. Sometimes certain sources of air pollution have pollutants that co-vary. For example, onroad gasoline sources have covarying benzene, toluene and xylenes ("btex"), and oil combustion tends to have covarying nickel and vanadium (at least it used to).

<br>

I have found the descriptions on this website very helpful: https://pathmind.com/wiki/eigenvector

<br>

I also found this very helpful:
https://georgemdallas.wordpress.com/2013/10/30/principal-component-analysis-4-dummies-eigenvectors-eigenvalues-and-dimension-reduction/


<br>

A clear article on completing Principal Component ANalysis in R: https://www.researchgate.net/profile/Maurice_Ekpenyong2/post/Can_someone_help_me_for_Manova_Cva_analysis/attachment/5b26896bb53d2f63c3d1949d/AS%3A638543588229120%401529252063540/download/PCA+SPSS.pdf

<br>

```{r pca}

library(nFactors)
library(ppcor)
library(psych)

ev <- eigen(water_data_corr) # get eigenvalues
 
#An eigenvalue is a number, telling you how much variance there is in the data in that direction, in the example above the eigenvalue is a number telling us how spread out the data is on the line. The eigenvector with the highest eigenvalue is therefore the principal component.

ap <- parallel(subject = nrow(water_data_corr), var = ncol(water_data_corr), rep = 100, cent = .05)

#Parallel analysis is a method for determining the number of components or factors to retain from pca or factor analysis. Essentially, the program works by creating a random dataset with the same numbers of observations and variables as the original data. A correlation matrix is computed from the randomly generated dataset and then eigenvalues of the correlation matrix are computed. When the eigenvalues from the random data are larger then the eigenvalues from the pca or factor analysis you known that the components or factors are mostly random noise.

nS <- nScree(x = ev$values, aparallel =  ap$eigen$qevpea)
        

plotnScree(nS)
        

fit <- principal(water_data_corr, nfactors = 3, rotate = "varimax")

loadings <- as.data.frame(fit$loadings[,1:3], row.names = T)
        
water_variables <- names(water_data)

loadingstable <- cbind(water_variables, loadings)

##write.csv(loadingstable, "))
        
loadingsmelt <- gather(loadingstable, component, loadings, -water_variables)

loadingsmelt$loadings <- cut(loadingsmelt$loadings, breaks=c(-0.7, 0, .7, 1))


##tiff(component_loadings.tiff", width=10, height=7, units="in", pointsize=12, res=100, type=c("cairo")) 

ggplot(loadingsmelt, aes(component, water_variables)) +
          geom_tile(aes(fill=loadings)) +
          theme(text = element_text(size=0.5)) +
          theme_bw() +
          scale_fill_manual(values = c("cadetblue3", "white", "cadetblue4")) +
          labs(y = "Component Loadings")
        
##dev.off()

        
```

<br>

## Multiple Linear Regression in R

<br>

Sometimes you want to build a model, or you want some way of quantifying how much changes in an independent variable can explain the variability in dependent variable. So, linear regression becomes your friend.

<br>

There are diagnostic plots you should look at to confirm that your data adhere to the assumptions required in linear regression. Here is a good explanation of these diagnostics and their plots..in R!

http://sphweb.bumc.bu.edu/otlt/MPH-Modules/BS/R/R5_Correlation-Regression/R5_Correlation-Regression7.html

<br>

```{r linear regression}

##similar to the multiple correlation analysis, you want your data in wide format, like it was provided to us.

#library(MASS)
#library(leaps)


water_data_reg <- lm(mc_mg_l_ros ~ schmitds_number + chl_a_mg_l + tp_mg_l + area_acres + avg_depth_ft + max_depth_ft + temp_c + sc_u_s_cm + tkn_mg_l + n_p, data = water_data)

water_data_reg <- step(water_data_reg, direction = "backward")

##as you can see, using a backwards linear regression analysis begins by running the entire model. The judgement of goodness of fit of the model, in this function, is judged by the Akaike information criterion (AIC). the AIC is an estimator of out-of-sample prediction error. So, the best fit is demonstrated by the lowest AIC.

##But, what are the parameters?

summary(water_data_reg)

show(water_data_reg)

plot(water_data_reg)


```
