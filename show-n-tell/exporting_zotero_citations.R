# Helpful Zotero interface website, https://www.rdocumentation.org/packages/RefManageR/versions/1.4.0/topics/ReadZotero

# install.packages("RefManageR")

library(tidyverse)
library(RefManageR)

collections_to_pull <- c("E7PEPGTI", "94RHJCTL", "5X37F8CQ", "TPRBMVGZ", "6LL6DSAA", "NQX6EN9L", "CJ8CQBVL", "2CX7PV69", "2Q3ZDGNB", "HKJTDRF3")

zotero_library <- map(collections_to_pull, ~ReadZotero(user = "", .params=list(key = "", collection = .x)))

zotero_library_df <- map_dfr(zotero_library, ~as.data.frame(.x, row.names = NULL))


