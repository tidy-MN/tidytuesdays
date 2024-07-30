##This script was built by Andrea Borich with help from Dorian Kvale and Derek Nagel. 06/14/24

#https://cran.r-project.org/web/packages/esquisse/vignettes/shiny-usage.html
library(shiny)
library(plyr)
library(tidyverse)

library(colorspace)
library(janitor)
library(chroma)
library(gt)
library(colorjam)
library(DescTools)
library(DT)
library(bslib)
library(colourpicker)
library(dichromat)
library(scales)
library(esquisse)
library(RColorBrewer)
# library(paletteer)
library(ggthemes)
#library(RColor) --https://www.stat.ubc.ca/~jenny/STAT545A/block14_colors.html
#https://search.r-project.org/CRAN/refmans/gt/html/info_paletteer.html


#Dorian suggested using round_any <- function(x, accuracy, f = round){ f(x/ accuracy) * accuracy } instead of plyr::round_any to simpl libraries

##Not being used; just default values in case it needed it from when I started everything
clrs = c("#366143","#465a79","#986b39",
         "#648b60","#9c695b","#507f94",
         "#988d6a","#928f87","#939f7e",
         "#e0deba","#7D98A9")

prcnt_transp = 40 #could ask for this number
min_luminance = -1.5 
max_luminance = 2

Optimize_Color_Palette <- function(clrs,prcnt_transp,min_luminance,max_luminance){
  ##This function finds the optimal luminance (I keep calling it contrast) of the hex values given by the user
  clrs = Filter(function(x) grepl("#", x),clrs)
  prcnt_transp <- as.numeric(prcnt_transp)
  min_luminance <- as.numeric(min_luminance)
  max_luminance <- as.numeric(max_luminance)
  
  Color_Deets<-function(clrs){
    ##Return a table with RGB,Grayscale, and HLC values
    if("matrix.unlist.clrs...nrow...length.clrs...byrow...TRUE." %in% colnames(as.data.frame(clrs))){
      df <- data.frame(matrix(unlist(clrs), nrow=length(clrs), byrow=TRUE)) %>%
        rename("HEX"="matrix.unlist.clrs...nrow...length.clrs...byrow...TRUE.") 
    }else{
      df <- as.data.frame(matrix(unlist(clrs), nrow=length(clrs), byrow=TRUE)) %>%
        rename_at( 1, ~"HEX" )
    }
    
    df <- df %>% 
      mutate(Red = col2rgb(HEX)[1,],
             Green = col2rgb(HEX)[2,],
             Blue = col2rgb(HEX)[3,]) %>%
      mutate(NTSC_Gray = 0.299*Red + 0.587*Green + 0.114*Blue) 
    #hue, chroma and luminance
    fvr <- as.data.frame(farver::decode_colour(
      clrs, "rgb", "hcl")) 
    colnames(fvr) <- c('Hue',
                       'Chroma',
                       'Luminance')
    fvr$hexval <- as.list(clrs)
    df <- merge(df,fvr,by.x='HEX',by.y='hexval')
    
    return(df)
  }
  
  #apply transparency or not ------------------
  if(prcnt_transp<=90 & prcnt_transp>=10){
    prcnt_transparency = (100-prcnt_transp)/100
    clrs_with_transparency = alpha(clrs,prcnt_transparency)
    track_hex <- data.frame(
      original = unlist(clrs),
      org_trans = unlist(clrs_with_transparency))
    clrs <- clrs_with_transparency
  }else{
    track_hex <- data.frame(
      original = unlist(clrs))
  }

  #figure out the differences of color and rank by luminance

  edists <- data.frame(lumin_dist = Polychrome::computeDistances(clrs))

  edists <- tibble::rownames_to_column(edists,"colorindex") 
  edists <- edists %>%
    mutate(lumorder = rank(lumin_dist,
                           ties.method = "first"))

  indexinghex <- data.frame(indexval = unlist(as.list(seq(from=1,to=length(clrs)))),
                            hexval = unlist(clrs))
  
  indexinghex$indexval <- paste0("X", indexinghex$indexval)
  edists <- merge(edists,indexinghex,by.x='colorindex',by.y='indexval')

  #find the maximum and minimum luminance between the colors
  max_lum <- round_any(max(edists$lumin_dist),10,f=ceiling)
  min_lum <- round_any(min(edists$lumin_dist),10,f=floor)
  number_colors <- length(clrs)
  lum_interval <- (max_lum - min_lum)/number_colors
  desired_lums <- seq(min_lum,max_lum,lum_interval)

  luminance_list <- c()
  for(c in clrs){
    luminance_list <- c(luminance_list,luminance(c))
  }

  #determine exiting luminance

  max_lum1<- max(luminance_list)
  min_lum1<- min(luminance_list)
  inrvl_lum1 <- round((max_lum1-min_lum1)/number_colors,4)

  df_lum <- data.frame(hexclr = clrs,
                       lums = luminance_list) %>%
    mutate(sort_lums = rank(lums))   %>% 
    mutate(updated_lum = seq(min_luminance,max_luminance,abs(min_luminance-max_luminance)/(length(luminance_list)-1))[sort_lums]) %>%
    mutate(adjust_lum_val = updated_lum - round(lums,4))

  #update the color list
  clrs_lum_fixed = c()
  for(c in clrs){

    new_clr = adjust_luminance(c,df_lum$adjust_lum_val[df_lum$hexclr==c])

    clrs_lum_fixed = c(clrs_lum_fixed,new_clr)
  }
  updatedcheck <- data.frame(orig = clrs,
                             new = clrs_lum_fixed)
  
  
  checkingupdated <- Color_Deets(clrs_lum_fixed)

  final_pick <- merge(track_hex,updatedcheck,by.x='original',by.y='orig',all.x=TRUE)

  final_pick$Deutanopia <- dichromat(final_pick$new, type = "deutan")
  final_pick$Protanopia <- dichromat(final_pick$new, type = "protan")
  final_pick$Tritanopia <- dichromat(final_pick$new, type = "tritan")
  final_pick$Grayscale <- ColToGray(final_pick$new)

  final_pick <- final_pick %>%
    dplyr::rename("Original" = "original",
           "Updated Luminance" = "new")

  return(final_pick)
}

HTML_DF <- function(final_pick){
  final_pick<-final_pick %>%
    mutate_all(color_html)
  
  return(final_pick)
}


color_html <- function(hex_color) {
  ##This returns html so that the colors change w/hex - Dorian helped with this! 
  paste0('<div style="background-color:',hex_color,';"><text style="font-weight:bold;color:',hex_color,';filter:invert(100%) grayscale(100%);font-size=12pt;">', hex_color, '</text></div>')
}

colors_palettes_fuct <- function(numIndividuals){
  ##This function tells the palettes how many colors the user wants and returns the list for the drop down

  colors_palettes <- list(
    "Viridis" = list(
      "viridis" = viridis_pal(option = "viridis")(numIndividuals),
      "magma" = viridis_pal(option = "magma")(numIndividuals),
      "inferno" = viridis_pal(option = "inferno")(numIndividuals),
      "plasma" = viridis_pal(option = "plasma")(numIndividuals),
      "cividis" = viridis_pal(option = "cividis")(numIndividuals)
    ),
    "Brewer" = list(
      "Brown/Blue/Green"  = brewer_pal(palette = "BrBG")(numIndividuals),
      "Pink/Green" = brewer_pal(palette = "PiYG")(numIndividuals),
      "Purple/Green" = brewer_pal(palette = "PRGn")(numIndividuals),
      "Purple/Orange" = brewer_pal(palette = "PuOr")(numIndividuals),
      "Red/Blue" = brewer_pal(palette = "RdBu")(numIndividuals),
      "Red/Gray" = brewer_pal(palette = "RdGy")(numIndividuals),
      "Red/Yellow/Blue" = brewer_pal(palette = "RdYlBu")(numIndividuals),
      "Red/Yellow/Green" = brewer_pal(palette = "RdYlGn")(numIndividuals),
      "Rainbow" = brewer_pal(palette = "Spectral")(numIndividuals),
      "Set3" = brewer_pal(palette = "Set3")(numIndividuals),
      "Paired" = brewer_pal(palette = "Paired")(numIndividuals)
    )
    )
  
  return(colors_palettes)
}

get_palette_hex_vals <- function(numIndividuals,palettename){
  ##This function grabs the hex values from the palette selected by the user
  # numIndividuals <- as.integer(input$clrcnt)

  if(is.null(palettename)){
    palettename = "viridis"
  }
  colors_palettes <- colors_palettes_fuct(numIndividuals)

  if(palettename %in% c("viridis","magma","inferno","plasma","cividis")){

    pickedpalette <- colors_palettes[['Viridis']][palettename]
  }else if(grepl("GGthemes",palettename)|grepl("Carto",palettename)){

    pickedpalette <- colors_palettes[['Paletteer_Misc']][palettename]
  }else{

    pickedpalette <- colors_palettes[['Brewer']][palettename]
  }

  return(pickedpalette)
}
##########################################
###########BEGIN SHINY APP ##########################################################################################
##########################################
ui <- page_sidebar(
  tags$head(
    tags$style(HTML(
      "label { font-size:80%; font-family:Arial; margin-bottom: 
    0px;padding:0px; }"
    )),
  ),
  title = "Color Contrast Optimizer",
  sidebar = sidebar(numericInput("clrcnt",label= paste('How many colors are you working with?', "(min:2; max:10)", sep="\n"),value='3',min=2,max=10,step=1,width='100%'),
                    uiOutput("palettepicker"),
                    uiOutput("hexentry"),
                    sliderInput("lum_range",label='Select your desired luminance range:',min=-2,max=2,value=c(-1.75,2),step=0.25,ticks=TRUE),
                    actionButton("GO",label="Optimize Contrast!")),
  
  "Preview the optimized palette and accessibility versions of it:",
  tableOutput("showThePalette"),
  plotOutput("pieColorsOrig"),
  downloadButton('downloadData', 'Download CSV of HEX values (all)')
)
####################################################SERVER START####################################################
server <- function(input, output, session) {
  ####Interactive color count - hex entry box
  reactive_values <- reactiveValues(
    cnt = TRUE,
    palettespicked = TRUE
    )

  
  observeEvent(input$clrcnt, {
    reactive_values$cnt<-input$clrcnt
  })
  ###GET BELOW TO UPDATE BASED ON PALETTE CHOSEN
  output$hexentry<-renderUI({

    if(reactive_values$cnt>1 & reactive_values$cnt<11){
      numIndividuals <- as.integer(input$clrcnt)
      lapply(1:numIndividuals, function(i){
        colourInput(paste0("hex",i), label = paste0('HEX Value ',i), value = "#")
        #https://www.rdocumentation.org/packages/shinyjs/versions/0.7/topics/updateColourInput
      }
      )

    }else{
      h3("I can only accept 2 - 10 hex values. Please change the number above to continue using the optimizer.",style="color:red;font-size:12pt")
      
    }
      
  })
 
  output$palettepicker<-renderUI({
    if(reactive_values$cnt>1 & reactive_values$cnt<11){
      numIndividuals <- as.integer(input$clrcnt)
      colors_palettes <- colors_palettes_fuct(numIndividuals)
      palettePicker(inputId = "pal",
                    label = "Choose a palette",
                    choices = colors_palettes,
                    selected = 'plasma',
                    textColor = c(rep("white", 5), rep("black", 4)))
      
    }else{
      h3("color picker not updated - please let Andrea know")
      
    }
    
  })
  
  hex_list <- reactive(str_subset(names(input), "^hex") %>%
                         map_chr(\(x) pluck(input, x)) %>%
                         {.[1:input$clrcnt]}
                       )
  
  #### output original palette - after action button
  #alt to try: https://gt.rstudio.com/reference/tab_style.html
  allhexs_html <- reactive(
                           {
                             all_colors <- HTML_DF(Optimize_Color_Palette(hex_list(),
                                                                  0,
                                                                  input$lum_range[1],
                                                                  input$lum_range[2]
                                                                  )
                                                   )
                             all_colors
                           }) %>%
    bindEvent(input$GO)
  
  
  
  
output$showThePalette <- renderTable({allhexs_html()},
                                     sanitize.text.function=function(x)x)
allhexs <- reactive(
                         {
                           all_colors <- Optimize_Color_Palette(hex_list(),
                                                                0,
                                                                input$lum_range[1],
                                                                input$lum_range[2]
                                                                )
                           
                           all_colors
                         }) %>%
  bindEvent(input$GO)

output$pieColorsOrig <- renderPlot(color_pie({allhexs()},
                                             main="Color Palette Preview and Comparison Pie Chart",
                                             sub="Pie chart represents the palettes from the table. \nOuter ring is the original colors through to the grayscale in the middle."))


palettepicked <- eventReactive(paste0(input$pal,input$clrcnt),{
                           palettename <- input$pal

                           numIndividuals <- as.integer(input$clrcnt)
                           pickedpalette <- get_palette_hex_vals(numIndividuals,palettename)
                           pickedpalette
                         })
output$pp <- renderText({
  paste(palettepicked(),collapse=", ")
 })


observeEvent(input$pal,{
  reactive_values$palettespicked <- input$pal
})
#https://github.com/rstudio/shiny/issues/2312
observe({
  lapply(1:input$clrcnt, function(i){

        tpp <-get_palette_hex_vals(input$clrcnt,input$pal)[[1]][i]
        updateColourInput(session,
                          inputId = paste0("hex",i),
                          label = paste0('HEX Value ',i),
                          value = tpp)

    })
})

output$downloadData <- downloadHandler(
  filename = function() { 
    paste("dataset-", Sys.Date(), ".csv", sep="")
  },
  content = function(file) {
    write.csv(allhexs(), file)
  })

}


shinyApp(ui=ui, server=server)

