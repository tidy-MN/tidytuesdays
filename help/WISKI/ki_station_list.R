## 2021-10-14
# Edited version of kiwisR: https://github.com/rywhale/kiwisR/tree/master/R
## Adds 'custom' argument to return special MPCA columns
## Example:: 
# stn_url <- "https://wiskiweb01.pca.state.mn.us/KiWIS/KiWIS?"
#
# stations <- ki_station_list(stn_url,
#                            return_fields = 'station_name,site_name',
#                            custom = 'stn_AUID,stn_EQuIS_ID,stn_HUC12')
#

ki_station_list <- function (hub, search_term, bounding_box, group_id, return_fields, custom) {

source("https://raw.githubusercontent.com/rywhale/kiwisR/master/R/utils.R")

garbage <- c("^#", "^--", "testing", "^Template\\s",
             "\\sTEST$", "\\sTEMP$", "\\stest\\s")

if (missing(return_fields)) {
  return_fields <- "station_name,station_no,station_id,station_latitude,station_longitude"
}
else {
  if (!inherits(return_fields, "character")) {
    stop("User supplied return_fields must be comma separated string or vector of strings")
  }
}

api_url <- check_hub(hub)

api_query <- list(service = "kisters", type = "queryServices",
                  request = "getStationList", format = "json",
                  kvp = "true", returnfields = paste(return_fields,
                                                     collapse = ","))
if (!missing(search_term)) {
  search_term <- paste(search_term, toupper(search_term),
                       tolower(search_term), sep = ",")
  api_query[["station_name"]] <- search_term
}

if (!missing(bounding_box)) {
  bounding_box <- paste(bounding_box, collapse = ",")
  api_query[["bbox"]] <- bounding_box
}

if (!missing(group_id)) {
  api_query[["stationgroup_id"]] <- group_id
}

if (!missing(custom)) {

  api_query[["returnfields"]] <- paste0(api_query[["returnfields"]], ",ca_sta")

  api_query[["ca_sta_returnfields"]] <- custom
}

raw <- tryCatch({
  httr::GET(url = api_url, query = api_query, httr::timeout(15))
}, error = function(e) {
  return(e)
})

check_ki_response(raw)

raw_content <- httr::content(raw, "text")

json_content <- jsonlite::fromJSON(raw_content)

if (inherits(json_content, "character")) {
  return("No matches for search term.")
}

content_dat <- tibble::as_tibble(x = json_content,
                                 .name_repair = "minimal")[-1, ]

names(content_dat) <- json_content[1, ]

if ("station_name" %in% names(content_dat)) {

  content_dat <- content_dat[!grepl(paste(garbage, collapse = "|"),
                                    content_dat$station_name), ]
}

content_dat <- suppressWarnings(dplyr::mutate_at(content_dat,
                                                 dplyr::vars(dplyr::one_of(c("station_latitude",
                                                                             "station_longitude"))), as.double))

}
