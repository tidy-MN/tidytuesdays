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

# directory <- "X:\\Agency_Files\\Water\\Standards\\Effluent Limit Review Documents\\Aida Mendez\\ROutput"
# #setwd()
# setwd(directory)
# getwd()

###########################################
### INSTALL AND/OR CALL DESIRED PACKAGES

### Install the below packages if you haven't yet. You only need to install them once.
#install.packages(c('plyr','dplyr','RODBC','readr','plotrix'))### If you haven't tried directly connecting to Tempo or Delta before, follow the steps noted here: https://mpca-air.github.io/RCamp/03-Day3_db_connect.html

### Install the below packages if you haven't done so yet
library(RODBC)
library(sqldf)
library(tidyverse)
library(janitor)
library(lubridate)
library(plotrix)
library(openxlsx)

options(scipen=999)
####################################
### LOAD CREDENTIALS AND CONNNECT

# odbcDataSources()
# credentials <- read_csv("H:/Aida/R/credentials.csv")
# user      <- credentials$delta_user
# password  <- credentials$delta_pwd
# Or use your own
#user      <- "ta*******"
#password  <- "da**_*******"

# Connect to Delta
# deltaw <- odbcConnect("deltaw",
#                       uid = user,
#                       pwd = password,
#                       believeNRows = FALSE)

#########################################################
######## PULL DAILY SAMPLE VALUES FOR A FACILITY ########

### In the below code, the sql query ("Filter") is designed to pull all the data for Permit ID MN0029815; change the ID to pull data for a different permittee


# daily <- sqlQuery(deltaw, "SELECT
#
#                 l.MASTER_AI_ID,
#                 l.PREFERRED_ID,
#                 l.HUC8_CODE,
#                 l.WATERSHED_NAME,
#                 l.FACILITY_DESIGN_FLOW,
#                 l.ind_vs_dom,
#                 l.permit_status,
#                 r.SAMPLE_RPT_ID,
#                 r.SEQUENCE_NUM,
#                 r.DMR_INT_DOC_ID,
#                 r.SUBJECT_ITEM_DESIGNATION,
#                 r.PARAMETER_CODE,
#                 r.PARAMETER_DESC,
#                 r.ABBR_UNITS_DESC,
#                 r.SAMPLE_DATE,
#                 r.VALUE_QUALIFIER_IND,
#                 r.SAMPLE_VALUE,
#                 s.OPERATIONAL_FLAG,
#                 s.SUBMITTED_FLAG,
#                 s.LATEST_SUBMITTAL_FLAG
#
#                 FROM WH_TEMPO.WW_FACILITY l
#                 JOIN WH_TEMPO.DMR_SAMPLE_DTL r ON l.MASTER_AI_ID=r.MASTER_AI_ID
#                 JOIN WH_TEMPO.DMR_SAMPLE_RPT s ON r.SAMPLE_RPT_ID=s.SAMPLE_RPT_ID
#
#                 WHERE l.PREFERRED_ID = 'MN0051284'
#
#                 ")

### DO SOME FILTERING OF RAW DATA AND EXPORT

daily <- read_csv("https://github.com/tidy-MN/tidytuesdays/raw/main/help/Aida_wastewater_analysis/MN0051284_DailySampleValues_Raw.csv")
params <- read_csv("https://github.com/tidy-MN/tidytuesdays/raw/main/help/Aida_wastewater_analysis/reasonable_potential_analysis_params.csv")
names(daily)

daily2 <- daily %>%
  dplyr::filter(LATEST_SUBMITTAL_FLAG!="N", ### remove data that are the latest submitted values
                !is.na(SAMPLE_VALUE)) ### remove NA data

# Convert the date column from character to date

# daily2$SAMPLE_DATE<-as.Date(daily2$SAMPLE_DATE,format = "%m/%d/%Y")
Analytes <- mutate(daily2,
                   # across(SAMPLE_DATE, mdy),
                   across(SAMPLE_DATE, list(Month = month, Year = year), .names = "{.fn}")
                   ) %>%
  filter(
    # Keep only stations that are SD stations
    SUBJECT_ITEM_DESIGNATION == "SD 001",
    # Keep data newer than specific year.
    Year > 2011,
    # Keep data older than specific year.
    Year < 2020,
    # Keep only the concentrations or the specific conductance
    ABBR_UNITS_DESC %in% c("mg/L", "umhos/cm")
    )

head(Analytes)
tail(Analytes)

ReasonablPotDF <- Analytes %>%
  distinct(PARAMETER_CODE, PARAMETER_DESC, SAMPLE_DATE, SAMPLE_VALUE, ABBR_UNITS_DESC, VALUE_QUALIFIER_IND) %>%
  mutate(ln_sv = log(SAMPLE_VALUE)) %>%
  group_by(PARAMETER_CODE, PARAMETER_DESC) %>%
  summarize(across(ln_sv, list(
    Var = var,
    STD = sd,
    Count = length,
    Max = max,
    median = median
  ),
  .names = "{.fn}"
  )) %>%
  ungroup() %>%
  mutate(
    across(c(Var, STD), ~round(., digits = 3)),
    CV = round(sqrt(exp(Var) - 1),digits =3),
    short_desc = str_extract(PARAMETER_DESC, "^\\w+"),
    median = median %>% set_names(short_desc),
    SAR = ((median['Sodium']/23)/((median['Calcium']/20.03 + median['Magnesium']/12.16)/2)^0.5)
    )

CaMgKNaSARSummary <- filter(
  ReasonablPotDF,
  PARAMETER_CODE %in% c("META0003", "META0005", "META0007", "META0107")
  ) %>%
  transmute(
    param_desc = str_extract(PARAMETER_DESC, "\\w{1,2}(?=\\))") %>%
      paste0("Median"),
    median,
    SAR) %>%
  pivot_wider(names_from = param_desc, values_from = median) %>%
  select(-SAR, SAR)

# Reasonable potential calculations

ReasonablPotDFall <- left_join(ReasonablPotDF, params, by = "PARAMETER_CODE")
ReasonablPotDF <- inner_join(ReasonablPotDF, params, by = "PARAMETER_CODE")

# WLA chronic & WLA acute

PEQ_pvalue <- 0.95

WLA <- function(std) expr(((EffFlow + X7Q10Flow / 1.547) * !!enquo(std) - (X7Q10Flow/1.547)*Bckgr)/EffFlow)

ReasonablPotDF <- mutate(
  ReasonablPotDF,
  WLAAc = round(!!WLA(AcStd), 2),
  WLACr = round(!!WLA(CrStd), 1),
  u4U30= round(log(WLACr)-2.326*
                 sqrt(log(1+((exp(Var)-1))/Duration)), digits=2),
  u = round(u4U30-0.5*
              Var+0.5*log(1+((exp(Var)-1)/Duration)),digits =2),
  u1 = round(log(WLAAc) - 2.326 * STD, digits=1),
  LTA_chronic = round(exp(u + 0.5 * Var), digits = 1),
  LTA_acute = round(exp(u1 + 0.5 * Var), digits=1),
  # Selecting the either the mean of the LTA_acute or the mean of the LTA_chronic
  # to compute the daily maximum limit. Computation of the daily max limit
  u_or_u1 = case_when(
    is.na(LTA_acute) | LTA_chronic <= LTA_acute ~ u,
    LTA_chronic > LTA_acute ~ u1,
    TRUE ~ NA
  ),
  Daily_Max_Lmt = round(exp(u_or_u1 + 2.326 * STD), digits=2),
  # Selecting the either the mean of the LTA_acute or the mean of the LTA_chronic
  # to compute the average monthly limit. Computation of the average monthly limit
  s2n = log(1+((exp(Var)-1))/2),
  sn = round(sqrt(s2n), digits = 3),
  s2n = round(s2n, digits = 3),
  Un = round(u_or_u1 + (Var-s2n) / 2, digits=2),
  Monthly_Avg_Lmt = round(exp(Un+1.645*sn), digits=2),
  ### PEQ
  S= round(sqrt(log(CV^2+1)), digits =3),
  Pn = round((1 - PEQ_pvalue)^(1 / Count), digits =3),
  PEQFCalc = round(exp((qnorm(PEQ_pvalue)) * S - 0.5 *
                (S^2)) / exp((qnorm(Pn)) * S - 0.5*(S^2)), digits =2),
  PEQ = round(Max * PEQFCalc, digits=2),
  ### RP
  across(c(Daily_Max_Lmt, FAV, Monthly_Avg_Lmt),
         ~ifelse(PEQ > ., "Y", "N") %>% replace_na("N"),
         .names = "PEQover{.col}"
         ),
  RP = ifelse(if_any(starts_with("PEQover"), ~. == "Y"), "Y", "N")
)

# Reorganize the columns in the Reasonable Potential data frame so that it looks like our
# spreadsheet

ReasonablPotDF1 <- select(
  ReasonablPotDF,
  WQ_Parameter,
  EffFlow,
  X7Q10Flow,
  Bckgr,
  CrStd,
  AcStd,
  FAV,
  WLACr,
  WLAAc,
  CV,
  Var,
  STD,
  Duration,
  u4U30,
  u,
  LTA_chronic,
  u1,
  LTA_acute,
  Daily_Max_Lmt,
  s2n = S2n,
  sn = Sn,
  Un,
  Monthly_Avg_Lmt,
  Max,
  Count,
  S,
  Pn,
  PEQFCalc,
  PEQ,
  PEQoverDailyMax = PEQoverDaily_Max_Lmt,
  PEQoverFAV,
  PEQoverMonAvg = PEQoverMonthly_Avg_Lmt,
  RP
)

# Write Reasonable potential data frame and SAR to excel

l2 <- list("Reasonable_Potential" = ReasonablPotDF1,"Cations_SAR" = CaMgKNaSARSummary)

write.xlsx(l2,file = "ReasonablePotential&SAR.xlsx")

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

