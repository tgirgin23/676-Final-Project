library(shiny)
library(RCurl)
library(leaflet)
library(ggplot2)
library(maps)
library(gdalUtils)
library(RPostgreSQL)

# Define server logic required to draw a histogram;
# Added sesssion argument so that we can create the map
shinyServer(function(input, output, session) {

  # Creates the map
  map <- createLeafletMap(session, 'map')
  
  # Wait until map is loaded
  session$onFlushed(once = TRUE, function() {
  
# The 4 commented lines below were written to add a progress bar. 
# However, the progress bar made adding circles to the map extremely slow.
#     n <- 0
#     withProgress(message = 'Making plot', value = 0, max = countRows, session = session, {
    
      circleMarker <- function(lat, lon, mag, id) 
      {
         map$addCircleMarker(lat, lon, mag*2, layerId = id)
         #n <- n + 1
#          incProgress(1/n, session = session)
      }
      
      mapply(circleMarker, lat[[1]], lon[[1]], mag[[1]], ids[[1]])
#     })
   

    showMapPopup <- function(lat, lon, id) 
    {
      textBox <- as.character(tagList(
        tags$h4("Magnitude: ", n)
      ))
      map$showPopup(lat, lon, content = textBox, layerId = id)
    }

  # When map is clicked, show a popup with city info
  eventListener <- observe({
    map$clearPopups()
    event <- input$map_marker_click
    if (is.null(event))
      return()
    
    isolate({
      event <- input$map_marker_click
      showMapPopup(event$lat, event$lng, event$id)
    })
  })
  }) 
})
