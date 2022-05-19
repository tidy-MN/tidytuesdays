library(tidyverse)
library(sf)
library(leaflet)
library(leaflet.extras)
library(leafem)
library(shiny)

## Data from Crew & Captain: https://share.garmin.com/crewandcaptain/
## Shiny animated maps ref: https://towardsdatascience.com/eye-catching-animated-maps-in-r-a-simple-introduction-3559d8c33be1
## Icons ref: https://rstudio.github.io/leaflet/markers.html

st_layers("Sea_Note_Caribbean_2021.gpx")

wayp <- st_read("Sea_Note_Caribbean_2021.gpx",
                layer = "waypoints")

trip <- st_read("Sea_Note_Caribbean_2021.gpx",
                layer = "track_points") %>%
        mutate(NAME = "Crew")

path <- st_read("Sea_Note_Caribbean_2021.gpx",
                layer = "tracks")


# Add lat/long
trip$long <- st_coordinates(trip)[, 1]
trip$lat  <- st_coordinates(trip)[, 2]



# Date format
format(lubridate::now(), "%b %d - %H:00")

# A pretty map
map <- leaflet(path) %>%
        addProviderTiles(providers$Stamen.Watercolor) %>%
        addPolylines(color     = "grey", 
                     dashArray = "5,11,3,11", 
                     weight    = 3, 
                     opacity   = 0.85) %>%
        addCircles(data = trip, 
                   radius      = 5000, # meters
                   fillColor   = "#d47fff", #ff7faa", 
                   fillOpacity = 0.8, 
                   stroke      = FALSE) 
      


# Reduce to 6 data points per day
trip <- trip %>% 
        group_by(date = as.Date(time)) %>%
        mutate(day_record = 1:n(),
               day_tracks = n(),
               day_quarters = list(ceiling(seq(1, n(), n()/6))),
               mid_record = ceiling(n()/2)) %>%
        filter(day_record %in% unlist(day_quarters))


# Add a web image (logo)
map <- map %>% 
       addLogo("https://crewandcaptain.files.wordpress.com/2020/12/cropped-crew-and-captain-words-1-1.png", 
                       position = "bottomright", 
                       alpha  = 0.85, 
                       height = 110,
                       width  = 110,
                       offset.x = 15,
                       offset.y = 30) 


# Add icons
treasure <- awesomeIcons(icon = c('music', 'question'),
                         iconColor   = 'black', 
                         library     = 'fa',
                         markerColor = 'white')

#boat <- makeIcon("https://user-images.githubusercontent.com/36082558/37559838-94f320d6-2a35-11e8-8241-954f366799be.png", "https://user-images.githubusercontent.com/36082558/37559838-94f320d6-2a35-11e8-8241-954f366799be.png", 36, 36)


boat <- makeIcon("boat_sketch.png", "boat_sketch.png", 36, 36)

# Shiny UI
ui <- fluidPage(
  
  tags$style(type='text/css', ".irs-single { font-size: 15px !important;} .irs-grid-text {font-size: 13px;}"),
  
  titlePanel("Sailing the seas"),
  
  mainPanel(width = 12,
          
            
            leafletOutput("map", width = "100%", height = "450px"),
              
            tags$div(style = "margin-left: auto; margin-right: auto; width: 33%;", uiOutput("dateUI", width = "100%"))
            
  )
)


# Shiny server
server <- function(input, output, session) {
  
  #create slider input depending on data frequency
  observe({
    
   allDates <- unique(trip$time)

   eligibleDates <- allDates #[xts::endpoints(allDates, on = 'days')]


    output$dateUI <- renderUI({
      sliderInput("dateSel", "",
                  min = min(eligibleDates),
                  max = max(eligibleDates),
                  value = min(eligibleDates),
                  step  = 8*60*60,
                  timeFormat = "%b %d - %H:00",
                  animate = animationOptions(interval = 110, loop = FALSE)
      )
    })
  })
  
  # Filter data depending on selected date
  filteredData <- reactive({
    
    req(input$dateSel)
    
    #print(input$dateSel)
    
    #print(glimpse(trip[trip$time == input$dateSel, ]))
    
    tmp <- trip[trip$time <= input$dateSel+60, ] 
       
    
    if (nrow(tmp) > 1) {
      tmp <- tmp[nrow(tmp), ]
    }
    
      tmp
    
 })
  
  # Create the base leaflet map
  output$map <- renderLeaflet({
    
    leaflet(path) %>% 
      enableTileCaching() %>% 
      addProviderTiles(providers$Stamen.Watercolor) %>%
      addPolylines(color     = "grey", 
                   dashArray = "5,11,3,11", 
                   weight    = 2.5, 
                   opacity   = 0.7) %>%
      addMarkers(data = trip, icon = boat) %>%
      addAwesomeMarkers(data = wayp, icon = treasure)  %>% 
      addLogo("https://crewandcaptain.files.wordpress.com/2020/12/cropped-crew-and-captain-words-1-1.png", 
              position = "topright", 
              alpha  = 0.85, 
              height = 126,
              width  = 126,
              offset.x = 15,
              offset.y = 20) 
  })
  
  
  # prepare data depending on selected date and draw markers
  observe({
    
    tmp <- filteredData()
    
  if (tmp$date == "2020-12-16") {
    
    leafletProxy("map") %>%
      clearMarkers() %>%
      addMarkers(data = tmp, icon = boat) %>%
      addAwesomeMarkers(data = wayp, icon = treasure)
    
  } else {
    
    leafletProxy("map") %>%
      clearMarkers() %>%
      addMarkers(data = tmp, icon = boat)
  } 
    
  })
  
}

shinyApp(ui, server)  

