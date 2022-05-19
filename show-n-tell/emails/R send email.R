### Install RDCOMClient from zip (not available on CRAN)

# install.packages("https://github.com/MPCA-data/tidytuesdays/raw/master/show-n-tell/emails/RDCOMClient_0.94-0.zip",
#                  repos = NULL, type = "binary")

### Install RDCOMOutlook

# remotes::install_github("mdneuzerling/RDCOMOutlook")

library(RDCOMClient)
library(RDCOMOutlook)

to <- c(
""#Enter recipients
)

to <- paste(to, collapse = "; ")

subject <- ""

body <- ""

attachments <- ""

prepare_email(embeddings = NULL, body = body, to = to, cc = "",
              subject = subject, attachments = attachments, css = "", send = FALSE, #send = TRUE sends automatically
              max_image_height = 800, max_image_width = 800, data_file_format = "csv",
              col_names = TRUE, image_file_format = "png")