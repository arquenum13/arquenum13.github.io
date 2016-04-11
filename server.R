library(htmlwidgets)
library(shiny)
library(leaflet)
library(RJSONIO)
library(rgdal)
library(maptools)

server <- function(input, output, session) {
  
  off.df <- reactive({
    if(input$offense == "Show All")
    {subset(dcMap2, OFFENSE %in% off)} 
    else 
    {subset(dcMap2, OFFENSE %in% input$offense)}})
  
  date <- reactive({format(as.Date(as.POSIXlt(off.df()$REPORTDATETIME)), format="%B %d, %Y")}) #extrating the date from the date time format
  date.df <- reactive({paste("<b>Date: </b>",as.character(date()),"<br><b>Offense: </b>",off.df()$OFFENSE)}) #concatenating 2 text columns in a data.frame
  
  #Associates icon color with criminal offense
  leafIcons <- reactive({icons(iconUrl = ifelse(off.df()$OFFENSE == "ARSON", "pink.png",ifelse(off.df()$OFFENSE == "ASSAULT W/DANGEROUS WEAPON", 
               "blue.png",ifelse(off.df()$OFFENSE == "BURGLARY", "green.png",ifelse(off.df()$OFFENSE == "HOMICIDE", "orange.png",
               ifelse(off.df()$OFFENSE == "MOTOR VEHICLE THEFT", "black.png",ifelse(off.df()$OFFENSE == "ROBBERY","yellow.png",
               ifelse(off.df()$OFFENSE == "SEX ABUSE", "gray.png",ifelse(off.df()$OFFENSE == "THEFT F/AUTO", "violet.png",
               "red.png")))))))), iconWidth = 20, iconHeight = 40)})
  
  output$m <- renderLeaflet({
    leaflet() %>%
      setView(lng = -77.015734, lat = 38.877077, zoom = 14) %>% 
      addTiles() %>%  # Add default OpenStreetMap map tiles
      addMarkers(lng=off.df()$coords.x1, lat=off.df()$coords.x2,popup = date.df(), icon = leafIcons()) %>% #add markers and colors
      addLegend(position = 'topright', colors = cMarker, labels = off, opacity = 0.6, 
                title = "Legend")
  })  
  
}