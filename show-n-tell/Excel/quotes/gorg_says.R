
gorg_says <- function () {

library(dplyr)
library(httr)
library(jsonlite)
library(readxl)

path <- "https://github.com/MPCA-data/tidytuesdays/blob/main/show-n-tell/Excel/quotes/"

api_url <- "https://api.github.com/repositories/236574832/contents/show-n-tell/Excel/quotes"

files <- GET(api_url) 

# Pull out the file names
files <- fromJSON(content(files, as = "text"))$name

# Keep only Excel files
files <- files[grepl("xlsx", tolower(files))]


# Get random file
i <- sample(files, 1)
  
#print(i)
  
GET(paste0(path, i, "?raw=true"), 
    write_disk(tmp <- tempfile(fileext = ".xlsx")))
  
df <- read_excel(tmp)


# Clean names
names(df) <- tolower(names(df))

n <- sample(1:nrow(df), 1) 
  
df <- df[n, c("quote", "author")]

# Print quote
linez <- paste(rep("-", 52), collapse="")

cat(
    "\n",
    #linez,"\n","\n",
    df$quote %>% strwrap(width = getOption("width")), #"\n",
    paste("--", df$author), "\n", #"\n",
    #linez, "\n",
    sep = "\n"
)
  
}

gorg_says()


if (FALSE) {
# Read all the files

## Blank table
all_quotes <- tibble()

for (i in files) {
  
  print(i)
  
  GET(paste0(path, i, "?raw=true"), write_disk(tmp <- tempfile(fileext = ".xlsx")))
  
  df <- read_excel(tmp)
  
  all_quotes <- bind_rows(df, all_quotes)
  }
}
