library(pdftools)
library(tidyverse)

pdf_file <- "https://github.com/MPCA-data/tidytuesdays/raw/master/help/PDF_data/2017fertsalesreport.pdf"

#read in pdf text
text <- pdf_data(pdf_file)

#find starting page
start_page <- map_lgl(text, ~str_detect(paste(.$text, collapse = " "),
                                        "DETAIL FERTILIZER SUMMARY BY COUNTY")) %>%
  which()

#only keep pages after starting page, but remove last page with totals
text2 <- text[start_page:(length(text)-1)]

#get county level data
county_data <- map_dfr(text2[], ~{
  #sort left to right, top to bottom
  page_text <- arrange(., y, x)
  
  #find y location of header row
  y0 <- filter(page_text, text == "CODE") %>% pull(y)
  
  #look for text located between 5 and 20px above header row
  county <- filter(page_text,  between(y, y0 - 20, y0 - 5)) %>%
            pull(text) %>%
            paste(collapse = " ")
          
  #rows in table should be at least 5 px below header row
  page_text <- filter(page_text, y >= y0 + 5)
  
  #remove last 8 items if total row exists (last row + page number), otherwise just remove page number
  page_text <- page_text %>%
               slice(-((n() - ifelse(any(str_detect(.$text, "TOTALS")), 7, 0)) : n()))
  
  #if only total row exists, stop now
  if(nrow(page_text) == 0) return(NULL)
  
  #keep only text column
  pull(page_text, text) %>%
    #8 columns in table
    matrix(ncol = 8, byrow = T) %>%
    as_tibble() %>%
    set_names(c("code", "grade", "total", "bag", "bulk", "liquid", "farm", "nonfarm")) %>%
    # remove commas from numbers
    mutate(across(everything(), ~str_remove_all(., ",")),
           #convert columns to numeric
           across(-grade, as.numeric),
           #add county name
           county = county) %>%
    # reorder columns
    select(county, everything())
}
)
