library(shiny)
library(RCurl)
library(leaflet)
library(ggplot2)
library(maps)
library(gdalUtils)
library(RPostgreSQL)
source("sql.R")

# Initializing the PostgreSQL driver
drv <- dbDriver("PostgreSQL")

# Connecting to the database
con <- dbConnect(drv, dbname="final_project")

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
      
      #mapply(circleMarker, lat[[1]], lon[[1]], mag[[1]], ids[[1]])
#     })
   

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

    selectionListener <- observe({
      selectedCountry <- input$select
      if(selectedCountry == "United States")
      {      
        for (i in seq_len(6904)) {
          timsVector <- USAQuery[i,]
          circleMarker(as.numeric(timsVector[2]), 
                       as.numeric(timsVector[1]), 
                       as.numeric(timsVector[4]), 
                       as.character(timsVector[5]))
        }
      }
      else
      {
        map$clearMarkers()
#         countryQuery <- dbGetQuery(con, "SELECT ST_AsText(wkb_geometry) FROM month_earthquake AS e, countries AS c 
#                                     WHERE st_within(e.wkb_geometry, c.geom) 
#                                     and name = 'Canada'")
      }
    })

    selectionListener <- observe({
      magRange <- input$magSlider
      output$text1 <- renderText({ 
        paste("You have selected ", magRange[1])
      })
      
      # This is done for efficiency
      if(inputy$select != "United States")
      {
        magUSAQuery <- paste("SELECT usalat, usalon, mag, usadepth, ids FROM month_earthquake WHERE mag BETWEEN ", 
                          magRange[1], " AND ", magRange[2], " AND usalat IS NOT NULL", sep = "")
        magUpdateUSA <- dbGetQuery(con, magUSAQuery)
      }
      else
      {
        magQuery <- paste("SELECT mag, depth, ids, place FROM month_earthquake, county 
                          WHERE mag BETWEEN ", magRange[1], " AND ", magRange[2], 
                          " AND st_within(month_earthquake.wkb_geometry, county.geom) 
                          AND county.name_0 = '", input$select, "'", sep = "")
        magUpdate <- dbGetQuery(con, magQuery)
        
      }
    })

    showMapPopup <- function(lat, lon, id) 
    {
      query <- paste("SELECT mag, depth, ids, place FROM month_earthquake WHERE ids = '", id, "'", sep = "")
      infoPopup <- dbGetQuery(con, query)
      closeTo <- unlist(strsplit(as.character(infoPopup[4]), split='of ', fixed=TRUE))[2]
      textBox <- as.character(tagList(
                              tags$h4("Magnitude: ", infoPopup[1]),
                              tags$strong(infoPopup[4]), tags$br(),
                              sprintf("Depth of the earthquake: %s", infoPopup[2]))
                              )
      map$showPopup(lat, lon, content = textBox, layerId = id)
    }
  })
})
