library(bea.R)
library(blsAPI)
library(data.table)

# Method for measuring source reduction as laid out in the National Source
# Reduction Characterization Report for Municipal Solid Waste in The
# United States

# https://nepis.epa.gov/Exe/ZyPURL.cgi?Dockey=100015V9.txt

bea.key = "enter your key here"

# https://apps.bea.gov/API/signup/index.cfm

bls.key = "enter your key here"

# https://data.bls.gov/registrationEngine/

#Get the PCE estimates from the the BEA
userSpecList <- list('UserID' = bea.key,
                     'Method' = 'GetData',
                     'datasetname'= 'Regional',
                     'TableName' = 'SAPCE1',
                     'Year' = 'All',
                     'GeoFIPS' = 'MN',
                     'LineCode' = 1)
pce <- beaGet(userSpecList) %>% 
  data.table()
pce <- melt(pce, id.vars = names(pce)[1:5],
            measure.vars = names(pce)[-1:-5],
            variable.name = 'Year', value.name = 'PCE') %>% 
  dplyr::mutate(Year = substr(Year,11, 14)) %>% 
  dplyr::select(Year, PCE)

# Get the inflation factors from the BLS (there's a limit on the number of years
# so we have to make two data pulls)
payload1 <- list('seriesid' = 'CUUR0000SA0L1E',
                 'startyear' = '1997',
                 'endyear' = '2016',
                 'annualaverage' = TRUE,
                 'registrationkey' = bls.key)

payload2 <- list('seriesid' = 'CUUR0000SA0L1E',
                 'startyear' = '2017',
                 'endyear' = '2020',
                 'annualaverage' = TRUE,
                 'registrationkey' = bls.key)

CPI_U <- blsAPI(payload1, api_version = 2, return_data_frame = TRUE) %>% 
  bind_rows(blsAPI(payload2, api_version = 2, return_data_frame = TRUE)) %>% 
  dplyr::filter(periodName == 'Annual') %>% 
  dplyr::arrange(year) %>% 
  dplyr::select(Year = year, Inflation_Correction = value) %>% 
  dplyr::mutate(Inflation_Correction = as.numeric(Inflation_Correction))

# merge the two together and correct the PCE for inflation
source_reduction <- left_join(pce, CPI_U, by = 'Year') %>% 
  dplyr::mutate(PCE_Adj = PCE*(max(Inflation_Correction)/Inflation_Correction))

