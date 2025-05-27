library(dplyr)
library(openxlsx)


# SAVE resized header cols ----
save_excel_autofit <- function(data, path, fit_values = TRUE, width_buffer = 0.80) {
  
  wb <- createWorkbook()
  
  # Add worksheet
  addWorksheet(wb, "data")
  
  # Write data
  writeData(wb, "data", data, withFilter = F)
  
  # Size column widths based on header names
  header_lengths <- names(data) %>% nchar()
  
  # Size column widths based on length of text in values
  if (fit_values) {
    value_lengths <- sapply(data, function(col) col %>% as.character %>% nchar %>% max(na.rm = TRUE))
    header_lengths <- pmax(header_lengths, value_lengths) 
  }
  
  setColWidths(wb, "data", 
               cols = 1:length(header_lengths), 
               widths = width_buffer*round(header_lengths*2)/2 + 3.5)
  
  # Bold headers
  addStyle(wb, "data", 
           style = createStyle(textDecoration = "bold"), 
           rows = 1, 
           cols = 1:ncol(data))
  
  # Write Excel file to path
  saveWorkbook(wb, path, overwrite = TRUE)
}
