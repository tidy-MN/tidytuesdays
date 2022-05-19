library(pdftools)
library(rebus)
library(tidyverse)
library(lubridate)

#pdf on github
pdf_file <- "https://github.com/MPCA-data/tidytuesdays/raw/master/show-n-tell/strings/Water%20Gremlin%20Carbon%20Adsorption%20Stack%206-19-2020.pdf"

#read in pdf text
cems_text <- pdf_text(pdf_file)

#Extract dates from text

#Look for "Date of Run..." until end of line
dates <- str_extract_all(cems_text, "Date of Run" %R% any_char(1, Inf) %R% "\\r\\n") %>%
  #Extract all mm/dd dates with a preceding space
  str_extract_all(SPC %R% digit(1,2) %R% "/" %R% digit(1,2)) %>%
  unlist %>%
  str_trim %>%
  #Convert to date with year 2020
  {mdy(paste(., 2020))}

#Extract emissions from text

#Extract 4 lines after "LB/HR"
emit_rates <- str_extract_all(cems_text, "LB/HR" %R% spc(1, Inf) %R% any_char(1, Inf) %R%
                                spc(1, Inf) %R% any_char(1, Inf) %R%
                                spc(1, Inf) %R% any_char(1, Inf) %R%
                                spc(1, Inf) %R% any_char(1, Inf)) %>%
  #Look for line containing with "THC as Trans-1,2-"
  str_extract_all("THC as Trans-1,2-" %R% any_char(1, Inf)) %>%
  #Extract all numbers including decimal separator
  str_extract_all(digit(1, Inf) %R% DOT %R% digit(0, Inf)) %>%
  unlist %>%
  as.numeric %>%
  #Keep only values associated with a date and remove average column
  head(length(dates))

#Create table of dates and values
tibble(date = dates, emit_rate = emit_rates)
