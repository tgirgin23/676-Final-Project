library(shiny)
library(RCurl)
library(leaflet)
library(gdalUtils)
library(RPostgreSQL)
source("sql.R")

# Initializing the PostgreSQL driver
drv <- dbDriver("PostgreSQL")

# Connecting to the database
con <- dbConnect(drv, user=" ", host="localhost", port="5432", dbname="final_project", password=" ")
#con <- dbConnect(drv, dbname="final_project")

# Define server logic required to draw a histogram;
# Added sesssion argument so that we can create the map
shinyServer(function(input, output, session) {
  
  # Creates the map
  map <- createLeafletMap(session, 'map')
  
  # Wait until map is loaded
  session$onFlushed(once = TRUE, function() {
  
# The 4 commented lines below were written to add a progress bar. 
# However, the progress bar made adding circles to the map extremely slow.
#   n <- 0
#   withProgress(message = 'Making plot', value = 0, max = countRows, session = session, {
    
      circleMarker <- function(lat, lon, mag, id) 
      {
         map$addCircleMarker(lat, lon, mag+9, layerId = id)  
#          n <- n + 1
#          incProgress(1/n, session = session)
      }
#   }

    # When map is CLICKED, show a popup with city info
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

    # Checking for any change in the COUNTRY dropdown menu
    selectionListener <- observe({
      selectedCountry <<- input$select
      updateMarkers()
    })

    
    # Checking for any change in the MAGNITUDE slider
    sliderListener <- observe({

        # This variable has a global scope so that I can access it in my updateMarkers function
        magRange <<- input$magSlider
        updateMarkers() 
    })

    # This function will update the markers on the map
    updateMarkers <- function()
    {

      # Clearing all markers that are on the map so that new ones can be added depending on the inputs
      map$clearMarkers()
      
      # This is done for efficiency as there is a lot of data for USA
      if(selectedCountry == "United States")
      {        
        # Re-center the map for USA
        map$setView(38.833333, -98.583333, 4)
        # Calling the function to query for the data using the available information
        USAFunction(magRange[1], magRange[2])
        
        # Looping through the downloaded data from the database 
        for (i in seq_len(length(USAQuery[,1]))) 
        {
          # Storing the information from the query in a variable
          info <- USAQuery[i,]
                  
          # Calling the function that will plot the circles on the map
          circleMarker(as.numeric(info[2]),
                       as.numeric(info[1]),
                       as.numeric(info[4]),
                       as.character(info[5]))
        }
        # For debugging purposes
        #write.table(USAQuery, "mydata.txt", sep="\t")
        
      }
      else
      {
        # Clearing all markers that are on the map so that new ones can be added depending on the inputs
        map$clearMarkers()
        
        # Changing the view of the map to the country selected by the user
        newView <- changeCountryView(selectedCountry)
        map$setView(newView[,1], newView[,2], 4)
        
        # Getting the data from the database from the user input
        countryQuery <- otherCountry(magRange[1], magRange[2], selectedCountry)
        
        # Looping through the data downloaded from the database
        for (i in seq_len(length(countryQuery[,1])))
        {
          # Creating the proportional symbols
          circleMarker(as.numeric(countryQuery[i,1]),
                       as.numeric(countryQuery[i,2]),
                       as.numeric(countryQuery[i,4]),
                       as.character(countryQuery[i,3]))
        }
      }
    }

    showMapPopup <- function(lat, lon, id) 
    {
      # Querying the necessary data
      query <- paste("SELECT mag, depth, ids, place FROM month_earthquake WHERE ids = '", id, "'", sep = "")
      infoPopup <- dbGetQuery(con, query)
      # Rearanging the data
      closeTo <- unlist(strsplit(as.character(infoPopup[4]), split='of ', fixed=TRUE))[2]
      # Everything that will be contained in the popup is below
      textBox <- as.character(tagList(
                              tags$h4("Magnitude: ", infoPopup[1]),
                              tags$strong(infoPopup[4]), tags$br(),
                              sprintf("Depth of the earthquake (KM): %s", infoPopup[2]))
                              )
      # Will show the popup on the pressed marker with the above text
      map$showPopup(lat, lon, content = textBox, layerId = id)
    }
  
    # When the session has ended (browser closed), disconnect from the database
    session$onSessionEnded(function() {
      dbDisconnect(con)
      dbUnloadDriver(drv)
    })
  })
})
