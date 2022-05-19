# Quotes

<br>

A folder for favorite quotes stored in Excel files with two columns: `quote` and `author`

<br>

**Example**

> | quote | author |
> |-- |-- |  
> | What's up Doc? | Bugs Bunny |

<br>

## Create Excel from R

### Packages
```r
library(tidyverse)
library(openxlsx)
```

### Create data frame
```r
quote <- tibble(quote  = "Winter is coming.",
                author = "Minnesota")
```

### Save Excel file (simple 1 tab)
```r
write.xlsx(quote, file = "quote.xlsx", asTable = TRUE)
```

### 1. Create Excel workbook
```r
wb <- createWorkbook()
```

### 2. Add a tab / worksheet
```r
addWorksheet(wb, sheetName = "quote", gridLines = FALSE)
```

Learn more formatting options at [openxlsx](https://ycphs.github.io/openxlsx/articles/Introduction.html)

### 3. Add the data
```r
writeDataTable(wb,
               sheet = "quote",
               x = quote,
               withFilter = FALSE,
               tableStyle = "TableStyleLight1")
```

### 4. Save Excel file
```r
saveWorkbook(wb, "quote_Me.xlsx", overwrite = TRUE)
```

<br>

### 5. Upload to gitHub

Drag and drop file here: [📂 Excel quotes](https://github.com/MPCA-data/tidytuesdays/tree/main/show-n-tell/Excel/quotes)

<br>

> **Need permission?**
> 
> 1. Sign-up for GitHub at [github.com](github.com)
> 2. Ask one of us to join the **MPCA-data** org


<br>

## We're ready!

### Say random quote
```r
source("https://raw.githubusercontent.com/MPCA-data/tidytuesdays/main/show-n-tell/Excel/quotes/gorg_says.R")
```

`> gorg_says()`
