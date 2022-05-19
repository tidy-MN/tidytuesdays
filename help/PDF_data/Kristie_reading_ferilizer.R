library(tidyverse)
library(pdftools)
library(janitor)

#pdf in file
pdf_file <- "https://github.com/MPCA-data/tidytuesdays/raw/master/help/PDF_data/2017fertsalesreport.pdf"


#read in pdf data
fert_data <- pdf_data(pdf_file)
fert_text <- pdf_text(pdf_file)
view (fert_data)
#each page is a line, but can be read as a tibble, even though each word or data point is in its own row

pages_wanted <- c(16, 17, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40)

fert_all <- data.frame()

for(i in pages_wanted){
  
fert_test <- sub(".*CONTAINER", "", fert_text[i])

fert_test <- read_lines(fert_test)

if(length(fert_test) > 0){
  
fert_test <- fert_test[nchar(fert_test) > 12]
  
  for(i in 1:length(fert_test)){
    fert_test[i] <- paste(fert_test[i], "\n")
  }
}

names <- fert_test[1]

df <- read_csv(paste(fert_test, collapse=""), 
               col_names=FALSE, 
               col_types= "cccdddc") %>%
  filter(!row_number() == 1) %>%
  rowwise() %>%
  separate(X1, into = c("ANALYSIS CODE IDENTIFICATION", "TOTAL", "BAG", "BULK", "LIQUID"), sep = "\\s{2,}")


fert_all <- bind_rows(df, fert_all)

}

colnames(fert_all) <- names
