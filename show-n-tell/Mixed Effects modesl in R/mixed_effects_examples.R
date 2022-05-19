#### NOTE: This is a small and edited snippet of the analysis conducted for 
# Stenoien et al 2019 (Arthropod-Plant Interactions).
# It's purpose is to demonstrate linear mixed effects modeling and 
# generalized linear mixed effects modeling for the MPCA Tidy Tuesday group. 
# Demo on 2020-07-14.

#load packages
library(ggplot2)
library(lme4)
library(doBy)


#set working directory
setwd("H:/R TidyTues 20200714 mixed effects models pteromalus")

##### ##### ##### ##### ##### ##### ##### ##### ##### ##### 
##### Linear Mixed Effects Model
# Question: does the rearing environment (monarch reared on different plants) 
# of parasitoids affect their adult lifespan?

# lifespan 
lifespan<-read.csv(file="pc_lifespan.csv", header=TRUE)
str(lifespan)

#check response variable. I'd say it looks close enough to normal for this example.
ggplot(lifespan, aes(x=lifespan))+
  geom_histogram(binwidth = 0.5)+
  facet_grid(host.plant~.)


# WRONG MODEL: basic lm doesnt account for shared genetics and environments within broods
summary(lm<-lm(lifespan~host.plant, data=lifespan))

# WRONG MODEL: poisson requires integer response variable
summary(glm<-glm(lifespan~host.plant, data=lifespan, family="poisson"))

#Right(ish) model: mixed effect accounting for host identity
summary(lm_ls<-lmer(lifespan~host.plant + (1|host.ID), data=lifespan))
plot(lm_ls) # not great, but reviewers didn't complain. Perhaps consider dropping short surviving outliers?


#Note: The calculation of P-values for mixed effects models is a highly controversial topic
#Packages exist that will give p-values, but I recommend understanding the arguments on both sides
#before proceeding with p-values. Here is an example of how to get them:

library(lmerTest)
summary(lm_ls)


#########  Generate table of summary stats with confidence intervals:##########
## This function Summarizes data. 
## from: http://www.cookbook-r.com/Manipulating_data/Summarizing_data/
#  more extensions and applications can be found there
## Gives count, mean, standard deviation, standard error of the mean, and confidence 
## interval (default 95%).
##   data: a data frame.
##   measurevar: the name of a column that contains the variable to be summariezed
##   groupvars: a vector containing names of columns that contain grouping variables
##   na.rm: a boolean that indicates whether to ignore NA's
##   conf.interval: the percent range of the confidence interval (default is 95%)
summarySE <- function(data=NULL, measurevar, groupvars=NULL, na.rm=FALSE, conf.interval=.95) {
  library(doBy)
  
  # New version of length which can handle NA's: if na.rm==T, don't count them
  length2 <- function (x, na.rm=FALSE) {
    if (na.rm) sum(!is.na(x))
    else       length(x)
  }
  
  # Collapse the data
  formula <- as.formula(paste(measurevar, paste(groupvars, collapse=" + "), sep=" ~ "))
  datac <- summaryBy(formula, data=data, FUN=c(length2,mean,sd), na.rm=na.rm)
  
  # Rename columns
  names(datac)[ names(datac) == paste(measurevar, ".mean",    sep="") ] <- measurevar
  names(datac)[ names(datac) == paste(measurevar, ".sd",      sep="") ] <- "sd"
  names(datac)[ names(datac) == paste(measurevar, ".length2", sep="") ] <- "N"
  
  datac$se <- datac$sd / sqrt(datac$N)  # Calculate standard error of the mean
  
  # Confidence interval multiplier for standard error
  # Calculate t-statistic for confidence interval: 
  # e.g., if conf.interval is .95, use .975 (above/below), and use df=N-1
  ciMult <- qt(conf.interval/2 + .5, datac$N-1)
  datac$ci <- datac$se * ciMult
  
  return(datac)
}

sum_ls<-summarySE(lifespan, measurevar="lifespan", groupvars=c("host.plant"), na.rm=TRUE)
sum_ls


#set ggplot theme
theme_new <- theme_set(theme_bw())
theme_new <- theme_update(panel.grid.major = element_blank(), panel.grid.minor = element_blank())

# create figure
fig4e<-ggplot(sum_ls, aes(x=host.plant, y=lifespan)) + 
  geom_bar(stat="identity", fill="#999999") +
  geom_errorbar(aes(ymin=lifespan-ci, ymax=lifespan+ci),
                width=.2,                    
                position=position_dodge(.9))+
  ylab("Adult lifespan (+/- 95% CI)")+
  xlab("Host plant")+
  annotate("text", x=1, y=0.3, label= "n=40", size=3.5) + 
  annotate("text", x = 2, y=0.3, label = "n=40", size=3.5)+
  theme(axis.text.x=element_text(face="italic"))

fig4e

#Print file to PDF
#pdf(file = "fig4e.pdf", width= 3, height = 3)
#fig4e #print our plot
#dev.off() #stop making pdfs


##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### 
##### Generalized Linear Mixed Effects Model - can handle non-normally distributed response variables
# such as counts (poisson or negative binomial) or binary data.

#Question: Does caterpillar diet influence their liklihood of survival when exposed to a specialist parasitoid?

dat<-read.csv(file="dat.csv", header=T)

#Monarch surv based on host plant when exposed to Pteromalus cassotis
# Is there a defensive function of diet against this specialist parasitoid?
#subset to only include the parasitoid of interest
monsurvpc<-subset(dat, wasp.lineage=="P. cassotis")

#run model
summary(monsurvpc_lm<-glmer(bfly_success ~ host.plant + wasp.age.days + pupa.mass +
                              pupa.age.days + (1|start3), family=binomial(logit), data=monsurvpc))

plot(monsurvpc_lm) # not great, but residual plots are not the best method for assessing model fit for binomials
# https://stats.stackexchange.com/questions/70783/how-to-assess-the-fit-of-a-binomial-glmm-fitted-with-lme4-1-0


###plot glmer results
#color-blind palette
cbbPalette <- c("#000000", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

#frequency table of outcomes 
fig1<-as.data.frame(ftable(dat$wasp.lineage, dat$host.plant,  dat$host.fate.no8))

ggplot(data=fig1, aes(x=Var2, y=Freq, fill=Var3))+
  geom_bar(position = "fill", stat = 'identity')+
  scale_fill_manual(values=cbbPalette, name="Trial result")+
  xlab("Host plant")+
  ylab("Proportion of trials")+
  facet_grid(.~Var1)+
  theme(axis.text.x=element_text(face="italic"))
