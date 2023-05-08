################

# Last run May 5, 2023

# Written by A. Mendez

### OBJECTIVE

# Compute the reasonable potential analysis for the effluent toxic concentrations 
# of a wastewater treatment plant


#############
### NOTES

# If you haven't yet, complete the following steps:
# Open Control Panel > Administrative Tools > Data Sources (ODBC)
# Click the [Add..] button
# Driver Name: Oracle in OraClient11g_home2
# Data Source Name: deltaw
# TNS Service Name: delta.pca.state.mn.us
# See the steps here: https://mpca-air.github.io/RCamp/03-Day3_db_connect.html
# Also, as of spring 2022, need to set up account to access tempo, contact Jason Ewert

#############################
### NEEDED EDITS TO SCRIPT

# Wastewater treatment plant ID (line 104), outfall (line 133) ADWDF, Background (stream) concentrations and 7Q10 flow: 
# lines 234 - 259

#################### 
### SET DIRECTORY

directory <- "X:\\Agency_Files\\Water\\Standards\\Effluent Limit Review Documents\\Aida Mendez\\ROutput"
#setwd()
setwd(directory)
getwd()

###########################################
### INSTALL AND/OR CALL DESIRED PACKAGES

### Install the below packages if you haven't yet. You only need to install them once.
#install.packages(c('plyr','dplyr','RODBC','readr','plotrix'))### If you haven't tried directly connecting to Tempo or Delta before, follow the steps noted here: https://mpca-air.github.io/RCamp/03-Day3_db_connect.html

### Install the below packages if you haven't done so yet
library(RODBC)
library(sqldf)
library(readr)
library(janitor)
library(lubridate)
library(dplyr)
library(readr)
library(plotrix)
library(tidyr)
library(openxlsx)
####################################
### LOAD CREDENTIALS AND CONNNECT

odbcDataSources()
credentials <- read_csv("H:/Aida/R/credentials.csv")
user      <- credentials$delta_user
password  <- credentials$delta_pwd
# Or use your own
#user      <- "ta*******"
#password  <- "da**_*******"

# Connect to Delta
deltaw <- odbcConnect("deltaw", 
                      uid = user, 
                      pwd = password,
                      believeNRows = FALSE)  

#########################################################
######## PULL DAILY SAMPLE VALUES FOR A FACILITY ########

### In the below code, the sql query ("Filter") is designed to pull all the data for Permit ID MN0029815; change the ID to pull data for a different permittee


daily <- sqlQuery(deltaw, "SELECT
                
                l.MASTER_AI_ID,
                l.PREFERRED_ID,
                l.HUC8_CODE,
                l.WATERSHED_NAME,
                l.FACILITY_DESIGN_FLOW,
                l.ind_vs_dom,
                l.permit_status,
                r.SAMPLE_RPT_ID,
                r.SEQUENCE_NUM,
                r.DMR_INT_DOC_ID,
                r.SUBJECT_ITEM_DESIGNATION,
                r.PARAMETER_CODE,
                r.PARAMETER_DESC,
                r.ABBR_UNITS_DESC,
                r.SAMPLE_DATE,
                r.VALUE_QUALIFIER_IND,
                r.SAMPLE_VALUE,
                s.OPERATIONAL_FLAG,
                s.SUBMITTED_FLAG,
                s.LATEST_SUBMITTAL_FLAG
                                
                FROM WH_TEMPO.WW_FACILITY l
                JOIN WH_TEMPO.DMR_SAMPLE_DTL r ON l.MASTER_AI_ID=r.MASTER_AI_ID
                JOIN WH_TEMPO.DMR_SAMPLE_RPT s ON r.SAMPLE_RPT_ID=s.SAMPLE_RPT_ID
                
                WHERE l.PREFERRED_ID = 'MN0051284'
                
                ")
                

### export raw daily data
getwd()
write.xlsx(daily,'DailySampleValues_Raw.xlsx')
 
### DO SOME FILTERING OF RAW DATA AND EXPORT

options(scipen=999)

names(daily)

daily2 <- daily %>%
  dplyr::filter(LATEST_SUBMITTAL_FLAG!="N", ### remove data that are the latest submitted values
                !is.na(SAMPLE_VALUE)) ### remove NA data

# Convert the date column from character to date

daily2$SAMPLE_DATE<-as.Date(daily2$SAMPLE_DATE,format = "%m/%d/%Y")
Analytes<-mutate(daily2,"Month"=month(SAMPLE_DATE)) %>% mutate(daily2,"Year"=year(SAMPLE_DATE)) 

# Keep only stations that are SD stations
Analytes <- filter(Analytes,SUBJECT_ITEM_DESIGNATION == "SD 001")

# Keep data newer than specific year.  Keep data newer than specific year.
Analytes <- filter(Analytes, Analytes$Year >=2011 & Analytes$Year< 2020)

head (Analytes)
tail(Analytes)

# Keep only the concentrations or the specific conductance

Analytes <- filter(Analytes,ABBR_UNITS_DESC %in% c("mg/L", "umhos/cm"))

ChlorideDF <- Analytes %>% filter(PARAMETER_DESC == "Chloride, Total") %>%
  rename("Chloride" = "SAMPLE_VALUE") %>%
  select(-SAMPLE_RPT_ID, -SEQUENCE_NUM, -PARAMETER_CODE, -DMR_INT_DOC_ID, 
         -LATEST_SUBMITTAL_FLAG, - SUBMITTED_FLAG)

  ChlorideDF <- unique(ChlorideDF)
  ChlorideDF <- mutate (ChlorideDF, lnCl = log(Chloride))
  ChlorideDFSummary <-summarize(ChlorideDF, Var = round(var(lnCl),digits =3),
                                STD = round(Var^0.5,digits=3), Count = n(), 
                                CV = round((exp(Var) - 1)^0.5,digits =3),
                                Max = max(Chloride) )

SulfateDF <- Analytes %>% filter(PARAMETER_DESC == "Sulfate, Total (as SO4)") %>%
  rename("Sulfate" = "SAMPLE_VALUE", "Sulfate_units" = "ABBR_UNITS_DESC", "Sulfate_Value_qual" = "VALUE_QUALIFIER_IND" ) %>%
  select (SAMPLE_DATE, Sulfate, Sulfate_units,Sulfate_Value_qual)
  SulfateDF <- unique(SulfateDF)
  SulfateDF <- mutate (SulfateDF, lnSulf = log(Sulfate))
  SulfateDFSummary <- summarize(SulfateDF, Var = round(var(lnSulf),digits =3),
                                STD = round(Var^0.5,digits=3), Count = n(), 
                                CV = round((exp(Var) - 1)^0.5,digits =3),
                                Max = max(Sulfate) )
  
TDSDF <- Analytes %>% filter(PARAMETER_DESC == "Solids, Total Dissolved (TDS)") %>%
  rename("TDS" = "SAMPLE_VALUE", "TDS_units" = "ABBR_UNITS_DESC", 
          "TDS_Value_qual" = "VALUE_QUALIFIER_IND" )%>%
  select (SAMPLE_DATE, TDS, TDS_units,TDS_Value_qual)
  TDSDF <- unique(TDSDF)
  TDSDF <- mutate (TDSDF, lnTDS = log(TDS))
  TDSDFSummary <- summarize(TDSDF, Var = round(var(lnTDS),digits =3),
                            STD = round(Var^0.5,digits=3), Count = n(), 
                            CV = round((exp(Var) - 1)^0.5,digits =3),
                                Max = max(TDS) )

  SpecCondDF <- Analytes %>% filter(PARAMETER_DESC == "Specific Conductance") %>%
   rename("Specific_Conductance" = "SAMPLE_VALUE", "SpecCond_units" = "ABBR_UNITS_DESC", 
       "SpecCond_Value_qual" = "VALUE_QUALIFIER_IND" )%>%
   select (SAMPLE_DATE, Specific_Conductance, SpecCond_units,SpecCond_Value_qual)
   SpecCondDF <- unique(SpecCondDF)
   SpecCondDF <- mutate (SpecCondDF, lnSpecCond = log(Specific_Conductance))
   SpecCondDFSummary <- summarize(SpecCondDF, Var = round(var(lnSpecCond),digits =3),
                                  STD = round(Var^0.5,digits=3), Count = n(), 
                                  CV = round((exp(Var) - 1)^0.5,digits =3),
                          Max = max(Specific_Conductance) )


Bicarbonates<- Analytes %>% filter(PARAMETER_DESC == "Bicarbonates (HCO3)")
Hardness <- Analytes %>% filter(PARAMETER_DESC == "Hardness, Calcium & Magnesium, Calculated (as CaCO3)")

CalciumDF <- Analytes %>% filter(PARAMETER_DESC == "Calcium, Total (as Ca)") %>%
  rename("Calcium" = "SAMPLE_VALUE")%>%
  select (SAMPLE_DATE, Calcium, ABBR_UNITS_DESC,VALUE_QUALIFIER_IND)
  CalciumDF <- unique(CalciumDF)
CaDFSummary <-summarize(CalciumDF, CaMedian = median(Calcium) )
 
MagnesiumDF <- Analytes %>% filter(PARAMETER_DESC == "Magnesium, Total (as Mg)") %>%
  rename("Magnesium" = "SAMPLE_VALUE")%>%
  select (SAMPLE_DATE, Magnesium, ABBR_UNITS_DESC,VALUE_QUALIFIER_IND)
  MagnesiumDF <- unique(MagnesiumDF)
MgDFSummary <-summarize(MagnesiumDF, MgMedian = median(Magnesium) )

PotassiumDF <- Analytes %>% filter(PARAMETER_DESC == "Potassium, Total (as K)")%>%
  rename("Potassium" = "SAMPLE_VALUE")%>%
  select (SAMPLE_DATE, Potassium, ABBR_UNITS_DESC,VALUE_QUALIFIER_IND)
  PotassiumDF <- unique(PotassiumDF)
KDFSummary <-summarize(PotassiumDF, KMedian = median(Potassium) )

SodiumDF <- Analytes %>% filter(PARAMETER_DESC == "Sodium, Total (as Na)")%>%
  rename("Sodium" = "SAMPLE_VALUE")%>%
  select (SAMPLE_DATE, Sodium, ABBR_UNITS_DESC,VALUE_QUALIFIER_IND)
  SodiumDF <- unique(SodiumDF)
NaDFSummary <-summarize(SodiumDF, NaMedian = median(Sodium) )

CaMgKNaSARSummary <-data.frame(CaDFSummary, MgDFSummary, KDFSummary,NaDFSummary, 
                  SAR = ((NaDFSummary$NaMedian/23)/((CaDFSummary$CaMedian/20.03 + MgDFSummary$MgMedian/12.16)/2)^0.5))

Together <- left_join(ChlorideDF, SulfateDF, by = "SAMPLE_DATE")


# Reasonable potential calculations

#options(scipen=999)

ReasonablPotDF <-rbind(ChlorideDFSummary,SulfateDFSummary,TDSDFSummary,SpecCondDFSummary)
WQ_Parameter <- c("Chloride","Sulfate","TDS","Spec_Cond")
ReasonablPotDF <- mutate(ReasonablPotDF,WQ_Parameter)
ReasonablPotDF <- select(ReasonablPotDF,WQ_Parameter, everything())



### Waste Load Allocations
#
# Cr = chronic
# Ac = acute
#
#  Acute, chronic and FAV standards

ClCrStandard = 230.0
ClAcStandard = 860
ClsFAV       = 1720
ClStandardDur = 4
  
SO4CrStandard = 600.0
SO4StandardDur = 30

TDSCrStandard = 3000.0
TDSStandardDur = 30

# The specific conductance no longer has a Chronic value, therefore I am calling this a reference value
SpecConCrRef = 1500
SpecCondStandardDur = 30

# Effluent ADWDF or MDF and river 7Q10

EffFlow_MGD = 5.89
X7Q10Flow_CFS = 9.3

EffFlow = c(EffFlow_MGD,EffFlow_MGD,EffFlow_MGD,EffFlow_MGD)
X7Q10Flow = c(X7Q10Flow_CFS, X7Q10Flow_CFS, X7Q10Flow_CFS, X7Q10Flow_CFS)
# Receiving/background water quality

BckgrCl = 22.15
BckgrTDS = 295
BckgrSO4 = 55
BckgrSpecCon = 694

Bckgr = c(BckgrCl,BckgrSO4,BckgrTDS, BckgrSpecCon)

# Creating a vector to store the chronic WQ standards

CrStd = c(ClCrStandard,SO4CrStandard,TDSCrStandard,SpecConCrRef)

AcStd = c(ClAcStandard,NA,NA,NA)

FAV = c(ClsFAV,NA,NA,NA)


#AcStd <- as.numeric(AcStd)

Duration = c(ClStandardDur,SO4StandardDur,TDSStandardDur,SpecCondStandardDur)

ReasonablPotDF <- mutate(ReasonablPotDF,CrStd,AcStd,FAV,Duration, Bckgr,EffFlow,X7Q10Flow)



# WLA chronic & WLA acute

#ClWLACr <- ((EffFlow_MGD + X7Q10Flow_CFS/1.547)* ClCrStandard - (X7Q10Flow_CFS/1.547)*BckgrCl)/EffFlow_MGD
#SO4WLACr<-((EffFlow_MGD + X7Q10Flow_CFS/1.547)* SO4CrStandard - (X7Q10Flow_CFS/1.547)*BckgrSO4)/EffFlow_MGD
#TDSWLACr<- ((EffFlow_MGD + X7Q10Flow_CFS/1.547)* TDSCrStandard - (X7Q10Flow_CFS/1.547)*BckgrTDS)/EffFlow_MGD
#SpecConWLACr<-((EffFlow_MGD + X7Q10Flow_CFS/1.547)* SpecConCrRef - (X7Q10Flow_CFS/1.547)*BckgrSpecCon)/EffFlow_MGD
#WLACr <- c(ClWLACr,SO4WLACr,TDSWLACr,SpecConWLACr)


ClWLAAc <- round(((EffFlow_MGD + X7Q10Flow_CFS/1.547)* ClAcStandard - (X7Q10Flow_CFS/1.547)*BckgrCl)/EffFlow_MGD, digits=2)
WLAAc <- c(ClWLAAc,NA,NA,NA)

ReasonablPotDF <- mutate(ReasonablPotDF,WLACr=round(((EffFlow + X7Q10Flow/1.547)* CrStd - 
                                                 (X7Q10Flow/1.547)*Bckgr)/EffFlow, digits =1),WLAAc)

#ReasonablPotDF <- mutate(ReasonablPotDF,WLACr=((EffFlow + X7Q10Flow/1.547)* CrStd - 
#                                                (X7Q10Flow/1.547)*Bckgr)/EffFlow,WLAAc)

# Long Term Average for the chronic standard

 colnames(ReasonablPotDF)
 
 ReasonablPotDF <- mutate(ReasonablPotDF,u4U30= round(log(ReasonablPotDF$WLACr)-2.326*
                           sqrt(log(1+((exp(ReasonablPotDF$Var)-1))/ReasonablPotDF$Duration)), digits=2))
 
 ReasonablPotDF <- mutate(ReasonablPotDF,u = round(ReasonablPotDF$u4U30-0.5*
                           ReasonablPotDF$Var+0.5*log(1+((exp(ReasonablPotDF$Var)-1)/ReasonablPotDF$Duration)),digits =2))

# ReasonablPotDF <- mutate(ReasonablPotDF,u = ReasonablPotDF$u4U30-0.5*
#                            ReasonablPotDF$Var+0.5*log(1+((exp(ReasonablPotDF$Var)-1)/ReasonablPotDF$Duration)))
 ReasonablPotDF <- mutate(ReasonablPotDF,LTA_chronic = round(exp(ReasonablPotDF$u+0.5*ReasonablPotDF$Var), digits = 1))
 
 
 # Long Term average for maximum/acute standard
 
 ReasonablPotDF<- mutate(ReasonablPotDF,u1 = ifelse(!is.na(ReasonablPotDF$WLAAc), 
                                                    round(log(ReasonablPotDF$WLAAc)-2.326*
                                                            ReasonablPotDF$STD, digits=1), NA))

 ReasonablPotDF<- mutate(ReasonablPotDF, LTA_acute = ifelse(!is.na(ReasonablPotDF$u1), 
                                                            round(exp(ReasonablPotDF$u1+0.5*
                                                                        ReasonablPotDF$Var), digits=1), NA))
 
 
 # Selecting the either the mean of the LTA_acute or the mean of the LTA_chronic 
 # to compute the daily maximum limit. Computation of the daily max limit

 ReasonablPotDF <- mutate(ReasonablPotDF, 
                           Daily_Max_Lmt = case_when(is.na(LTA_acute) ~ 
                                                       round(exp(ReasonablPotDF$u+
                                                              2.326*ReasonablPotDF$STD),digits=2),
                                                  LTA_chronic < LTA_acute ~ 
                                                    round(exp(ReasonablPotDF$u+
                                                              2.326*ReasonablPotDF$STD),digits=2),
                                                  LTA_chronic > LTA_acute ~ 
                                                    round(exp(ReasonablPotDF$u1+
                                                              2.326*ReasonablPotDF$STD),digits=2),
                                                  LTA_chronic == LTA_acute ~ 
                                                    round(exp(ReasonablPotDF$u+
                                                              2.326*ReasonablPotDF$STD),digits=2),
                                                  TRUE ~ NA))

 #for (i in ReasonablPotDF$id) {
#  #i <- '2068SD002'
#  if (ReasonablPotDF$LTAas_Over_LTAcs[ReasonablPotDF$id==i]=='FALSE'){
#    ReasonablPotDF$Daily_Max[ReasonablPotDF$id==i] <- round(exp(ReasonablPotDF$u1[ReasonablPotDF$id==i]+2.326*ReasonablPotDF$STDEV_LnNData[ReasonablPotDF$id==i]),digits=2)
#  } else{
#    ReasonablPotDF$Daily_Max[ReasonablPotDF$id==i] <- round(exp(ReasonablPotDF$u[ReasonablPotDF$id==i]+2.326*ReasonablPotDF$STDEV_LnNData[ReasonablPotDF$id==i]),digits=2)
#  }
#}

#ReasonablPotDF$Daily_Max <- exp(ReasonablPotDF$u+2.326*ReasonablPotDF$STDEV_LnNData)
 

 # Selecting the either the mean of the LTA_acute or the mean of the LTA_chronic 
 # to compute the average monthly limit. Computation of the average monthly limit


ReasonablPotDF <- mutate(ReasonablPotDF,S2n = round(log(1+((exp(ReasonablPotDF$Var)-1))/2), digits=3))

ReasonablPotDF <- mutate(ReasonablPotDF,Sn = round(sqrt(log(1+((exp(ReasonablPotDF$Var)-1))/2)), digits=3))


ReasonablPotDF <- mutate(ReasonablPotDF, 
                         Un = case_when(is.na(LTA_acute) ~ round(ReasonablPotDF$u+(ReasonablPotDF$Var-ReasonablPotDF$S2n)/2, digits=2),
                                                LTA_chronic < LTA_acute ~ 
                                          round(ReasonablPotDF$u+(ReasonablPotDF$Var-ReasonablPotDF$S2n)/2, digits=2),
                                                LTA_chronic > LTA_acute ~ 
                                          round(ReasonablPotDF$u1+(ReasonablPotDF$Var-ReasonablPotDF$S2n)/2, digits=2),
                                                LTA_chronic == LTA_acute ~ 
                                          round(ReasonablPotDF$u+(ReasonablPotDF$Var-ReasonablPotDF$S2n)/2, digits=2),
                                                TRUE ~ NA))

ReasonablPotDF <- mutate(ReasonablPotDF, Monthly_Avg_Lmt = round(exp(ReasonablPotDF$Un+1.645*ReasonablPotDF$Sn), digits=2))
#}
# for (i in ReasonablPotDF$id) {
  #i <- '2068SD002'
#  if (ReasonablPotDF$LTAas_Over_LTAcs[ReasonablPotDF$id==i]=='FALSE'){
#    ReasonablPotDF$Un[ReasonablPotDF$id==i] <- ReasonablPotDF$u1[ReasonablPotDF$id==i]+(ReasonablPotDF$VAR_LnNData[ReasonablPotDF$id==i]-ReasonablPotDF$S2n[ReasonablPotDF$id==i])/2
#  } else{
#    ReasonablPotDF$Un[ReasonablPotDF$id==i] <- ReasonablPotDF$u[ReasonablPotDF$id==i]+(ReasonablPotDF$VAR_LnNData[ReasonablPotDF$id==i]-ReasonablPotDF$S2n[ReasonablPotDF$id==i])/2
#  }
# }
#ReasonablPotDF$Un <- ReasonablPotDF$u+(ReasonablPotDF$VAR_LnNData-ReasonablPotDF$S2n)/2



### PEQ

PEQ_pvalue <- 0.95
ReasonablPotDF <- mutate(ReasonablPotDF,S= round(sqrt(log(ReasonablPotDF$CV^2+1)), digits =3))
ReasonablPotDF <- mutate(ReasonablPotDF,Pn = round((1-0.95)^(1/ReasonablPotDF$Count), digits =3))
ReasonablPotDF <- mutate(ReasonablPotDF,
                         PEQFCalc = 
                          round(exp((qnorm(PEQ_pvalue))*ReasonablPotDF$S-0.5*
                                                  (ReasonablPotDF$S^2))/
                           exp((qnorm(ReasonablPotDF$Pn))*ReasonablPotDF$S-0.5*(ReasonablPotDF$S^2)), digits =2))

### Force PEQ factor to 1.5 if greater than 2
#high <- subset(ReasonablPotDF,ReasonablPotDF$PEQFCalc > 2)
#ok <- subset(ReasonablPotDF,ReasonablPotDF$PEQFCalc <= 2)
#high$PEQFCalc <- 1.5
#high$PEQFCalc
#ReasonablPotDF <- rbind(ok,high)
#write.csv(high,'High_PEQFCalc.csv')
#getwd()


ReasonablPotDF<- mutate(ReasonablPotDF,PEQ = round(ReasonablPotDF$Max*ReasonablPotDF$PEQFCalc, digits=2))

### RP

ReasonablPotDF$PEQoverDailyMax[ReasonablPotDF$PEQ > ReasonablPotDF$Daily_Max_Lmt] <- 'Y'  
ReasonablPotDF$PEQoverDailyMax[ReasonablPotDF$PEQ < ReasonablPotDF$Daily_Max_Lmt] <- 'N' 

ReasonablPotDF$PEQoverFAV[ReasonablPotDF$PEQ > ReasonablPotDF$FAV] <- 'Y'
ReasonablPotDF$PEQoverFAV[ReasonablPotDF$PEQ < ReasonablPotDF$FAV] <- 'N' 
ReasonablPotDF$PEQoverFAV[is.na(ReasonablPotDF$FAV)] <- 'N'

ReasonablPotDF$PEQoverMonAvg[ReasonablPotDF$PEQ > ReasonablPotDF$Monthly_Avg_Lmt] <- 'Y'  
ReasonablPotDF$PEQoverMonAvg[ReasonablPotDF$PEQ < ReasonablPotDF$Monthly_Avg_Lmt] <- 'N'  

ReasonablPotDF$RP[ReasonablPotDF$PEQoverDailyMax=='Y' & ReasonablPotDF$PEQoverMonAvg=='Y' & ReasonablPotDF$PEQoverFAV=='Y' ] <- 'Yes' 
ReasonablPotDF$RP[ReasonablPotDF$PEQoverDailyMax=='Y' & ReasonablPotDF$PEQoverMonAvg=='Y' & ReasonablPotDF$PEQoverFAV=='N' ] <- 'Yes'
ReasonablPotDF$RP[ReasonablPotDF$PEQoverDailyMax=='Y' & ReasonablPotDF$PEQoverMonAvg=='N' & ReasonablPotDF$PEQoverFAV=='Y' ] <- 'Yes'   
ReasonablPotDF$RP[ReasonablPotDF$PEQoverDailyMax=='Y' & ReasonablPotDF$PEQoverMonAvg=='N' & ReasonablPotDF$PEQoverFAV=='N' ] <- 'Yes'  
ReasonablPotDF$RP[ReasonablPotDF$PEQoverDailyMax=='N' & ReasonablPotDF$PEQoverMonAvg=='Y' & ReasonablPotDF$PEQoverFAV=='Y' ] <- 'Yes'  
ReasonablPotDF$RP[ReasonablPotDF$PEQoverDailyMax=='N' & ReasonablPotDF$PEQoverMonAvg=='Y' & ReasonablPotDF$PEQoverFAV=='N'] <- 'Yes'  
ReasonablPotDF$RP[ReasonablPotDF$PEQoverDailyMax=='N' & ReasonablPotDF$PEQoverMonAvg=='N' & ReasonablPotDF$PEQoverFAV=='Y'] <- 'Yes'  
ReasonablPotDF$RP[ReasonablPotDF$PEQoverDailyMax=='N' & ReasonablPotDF$PEQoverMonAvg=='N' & ReasonablPotDF$PEQoverFAV=='N'] <- 'No'



# Reorganize the columns in the Reasonable Potential data frame so that it looks like our
# spreadsheet 

colnames(ReasonablPotDF)

ReasonablPotDF1 <-select(ReasonablPotDF,WQ_Parameter,EffFlow,X7Q10Flow,Bckgr,CrStd, AcStd, FAV,WLACr, WLAAc, CV, Var, STD, Duration,
       u4U30,u,LTA_chronic,u1,LTA_acute,Daily_Max_Lmt, S2n,Sn, Un,Monthly_Avg_Lmt, Max, Count, 
       S, Pn,PEQFCalc,PEQ,PEQoverDailyMax,PEQoverFAV,PEQoverMonAvg,RP)

colnames(ReasonablPotDF1)

# Write Reasonable potential data frame and SAR to excel

l2 <- list("Reasonable_Potential" = ReasonablPotDF1,"Cations_SAR" = CaMgKNaSARSummary)

write.xlsx(l2,file = "ReasonablePotential&SAR.xlsx")
 


#write.xlsx(ReasonablPotDF,file = "ReasonablePotAnalysis.xlsx", asTable = TRUE)

# Note, if you want data for a parameter that is text only (e.g., "Stream recreational suitability (choice list)"), then do not use the below step
#analytesmedian <-analytes2 %>% group_by(PARAMETER_DESC) %>% summarise_if(is.numeric, median, na.rm=TRUE)
#AnalyteSummary <-Analytes %>% group_by(PARAMETER_DESC)%>%summarise(Median=median(SAMPLE_VALUE), Count = n())

#write_excel_csv(analytesmedian, "Analytes_Medians.csv")




### export processed daily data
#write_csv(daily2,"DailySampleValues_Processed.csv")

#######################################
### BELOW ARE PARAMETER DESCRIPTIONS

# Bicarbonates (HCO3)
# BOD, 05 Day (20 Deg C)
# BOD, Carbonaceous 05 Day (20 Deg C)
# BOD, Carbonaceous 05 Day (20 Deg C) Percent Removal
# Calcium, Total (as Ca)
# Chloride, Total
# Chlorine, Total Residual
# Chromium, Dissolved (as Cr)
# Chromium, Hexavalent (as Cr)
# Copper, Total (as Cu)
# Fecal Coliform, MPN or Membrane Filter 44.5C
# Flow
# Hardness, Calcium & Magnesium, Calculated (as CaCO3)
# Magnesium, Total (as Mg)
# Nitrite Plus Nitrate, Total (as N)
# Nitrogen, Ammonia, Total (as N)
# Nitrogen, Ammonia, Un-ionized (as N)
# Nitrogen, Kjeldahl, Total
# Nitrogen, Nitrate, Total (as N)
# Nitrogen, Nitrite, Total (as N)
# Nitrogen, Total (as N)
# Mercury, Total (as Hg)
# Mercury, Dissolved (as Hg)
# Oxygen, Dissolved
# pH
# Phosphorus, Total (as P)
# Potassium, Total (as K)
# Salinity, Total
# Selenium, Total (as Se)
# Silver, Total (as Ag)
# Sodium, Total (as Na)
# Solids, Total Dissolved (TDS)
# Solids, Total Suspended (TSS)
# Specific Conductance
# Sulfate, Total (as SO4)
# Temperature, Water (C)
# Turbidity

