### Install RDCOMClient from zip (not available on CRAN)

# install.packages("https://github.com/MPCA-data/tidytuesdays/raw/master/show-n-tell/emails/RDCOMClient_0.94-0.zip",
#                  repos = NULL, type = "binary")


library(RDCOMClient)
library(tidyverse)
library(lubridate)
library(data.table)
library(glue)

#Create outlook application
OutApp <- COMCreate("Outlook.Application")

#Get namespace for Microsoft API (MAPI)
ns <- OutApp$GetNameSpace("MAPI")

#Count how many folders I have
folder_count <- ns$folders()$Count()

#Get the name of the first folder
ns$folders(1)$Name()

#Walk through each folder to get all names
walk(1:folder_count, ~ns$folders(.)$Name() %>% print())

#This is the folder with my emails
my_folder <- "derek.nagel@state.mn.us"

#Count the number of subfolders in my folder
subfold1_count <- ns$folders(my_folder)$folders()$Count()

#Get subfolder names
walk(1:subfold1_count, ~ns$folders(my_folder)$folders(.)$Name() %>% print())

#Set inbox folder as object
inbox <- ns$folders(my_folder)$folders("Inbox")

#Count number of emails in my inbox
inbox$Items()$Count()

#Print subject of first email
inbox$Items(1)$Subject()

#Print body of first email
inbox$Items(1)$Body() %>% cat()

#Print received date of first email (local time)
inbox$Items(1)$ReceivedTime() %>% as_date(origin = "1899-12-30")

#Print received timestamp of first email
(inbox$Items(1)$ReceivedTime() * 86400) %>% as_datetime(origin = "1899-12-30")

#Save first email as .msg
inbox$Items(1)$SaveAs("H:/Emails/email.msg")

#Extract all inbox emails and convert to tibble (takes a few minutes)
inbox_emails <- map_dfr((1:inbox$Items()$Count())[], function(x) possibly(
  ~tibble(
    subject = inbox$Items(x)$Subject(),
    from = inbox$Items(x)$SenderName(),
    time = (inbox$Items(x)$ReceivedTime() * 86400) %>% as_datetime(origin = "1899-12-30"),
    body = inbox$Items(x)$Body()
  ), NULL
)()
)

#Save emails to csv
fwrite(inbox_emails, "H:/Data/my_emails.csv")

#Read in csv
inbox_emails <- fread(inbox_emails, "H:/Data/my_emails.csv")

#Who sends me the most emails?
count(inbox_emails, from, sort = T)

#Search for "tidy tuesday" (case insensitive)
filter(inbox_emails, str_detect(subject, "(?i)tidy tuesday(?-i)") |
         str_detect(body, "(?i)tidy tuesday(?-i)")) %>%
  count()

#Sent items folder
sent <- ns$folders(my_folder)$folders("Sent Items")

#Extract all sent emails and convert to tibble (takes a few minutes)
sent_emails <- map_dfr((1:sent$Items()$Count())[], function(x) possibly(
  ~tibble(
    subject = sent$Items(x)$Subject(),
    to = sent$Items(x)$To(),
    cc = sent$Items(x)$CC(),
    time = (sent$Items(x)$ReceivedTime() * 86400) %>% as_datetime(origin = "1899-12-30"),
    body = sent$Items(x)$Body()
  ), NULL
)()
)

#Save to csv
fwrite(sent_emails, "H:/Data/sent_emails.csv", dateTimeAs = "write.csv")

#Read in csv
sent_emails <- fread("H:/Data/sent_emails.csv")

#Combine to and cc columns
sent_emails <- unite(sent_emails, "to", to, cc, sep = ";")

#Split recipients
sent_emails <- mutate(sent_emails, to = str_split(to, ";"))

#Unnest list column into separate rows
sent_emails <- unnest_longer(sent_emails, to) %>%
  #Remove extra whitespace
  mutate(across(to, str_squish)) %>%
  #Filter out blank recipients
  filter(to != "")

#Who do I send emails to the most?
count(sent_emails, to, sort = T)


#Get starting date to search Water Gremlin Public folder
search_from <- fread("X:/Programs/Air_Quality_Programs/Air Monitoring Data and Risks/9 Industrial Facilities/Water Gremlin/R Scripts/download emails starting.txt") %>%
  pull(date) %>% as.character()

#Folder to save attachments (need \\ for RDCOMClient)
pdf_output_folder <- "X:\\Programs\\Air_Quality_Programs\\Air Monitoring Data and Risks\\9 Industrial Facilities\\Water Gremlin\\Emissions\\CEMS PDF"

#Get Water Gremlin Public folder
wg_public <- ns$folders("MN_MPCA_Water Gremlin Public")$folders("Inbox")$FolderPath()

#Enclose in single quote for query
wg_public <- paste0("'", wg_public, "'")

#Count number of items in folder
count <- ns$folders("MN_MPCA_Water Gremlin Public")$folders("Inbox")$Items()$Count()

#Create search query for emails past starting date
search_query <- glue("urn:schemas:mailheader:date > '{search_from}'") %>% as.character()

#Serach for emails meeting search query
search <- OutApp$AdvancedSearch(wg_public, search_query)$Results()

#Walk through each email meeting search criteria and save all pdf attachments
walk((1:search$Count())[1], function(item) {
  #If no attachments, skip
  if (search[[item]]$Attachments()$Count() > 0) walk(
    1:search[[item]]$Attachments()$Count(), function(attach){
      #Get file name
      file_name <- search[[item]]$Attachments(attach)$DisplayName()
      #If .pdf in file name, save
      if(str_detect(file_name, ".pdf")) search[[item]]$Attachments(attach)$SaveAsFile(
        #Need \\ notation for SaveAsFile
        paste0(pdf_output_folder, "\\", file_name)
      )
    })
}
)

#Save end date for next time
fwrite(tibble(date = today()), "X:/Programs/Air_Quality_Programs/Air Monitoring Data and Risks/9 Industrial Facilities/Water Gremlin/R Scripts/download emails starting.txt")

#Documentation for Microsoft API methods
# https://docs.microsoft.com/en-us/dotnet/api/microsoft.office.interop.outlook.mailitem?redirectedfrom=MSDN&view=outlook-pia#properties_

