library(shiny)
library(ShinyDash)
library(leaflet)
source("sql.R")
library(shinydashboard)

setwd("~/Google Drive/Spring 2015/CS 368/Final_project/")

dashboardPage(
  dashboardHeader(title = "Earthquakes map"),
  dashboardSidebar
  (
    disable = TRUE
  ),
  dashboardBody(
    fluidRow
    (
      #tags$head(tags$link(rel="stylesheet", type="text/css", href="style.css")),
      column(width = 9,
        box(width = NULL, status = "warning",
          leafletMap(
            "map", "100%", 400,
            initialTileLayer = "//{s}.tiles.mapbox.com/v3/tgirgin.ll67dej8/{z}/{x}/{y}.png",
            initialTileLayerAttribution = HTML('Maps by <a href="http://www.mapbox.com/">Mapbox</a>'),
            options=list(
              center = c(38.833333, -98.583333),
              zoom = 4,
              maxBounds = list(list(17, -180), list(59, 180))
            )
          )
        )
      ),
      column(width = 3,
        box(title = "Country", width = NULL, status = "primary", 
        selectInput("select", label = NULL, 
                  choices = test, 
                  selected = "United States")
        ),
        box(title = "Magnitude", width = NULL, status = "primary",
        sliderInput("slider2", label = NULL, min = 0, 
                    max = 10, value = c(4, 6))
        )
      )
      
#         textOutput("text1"),
#         textOutput("event"),
    )
  )
)

  
  # # Define UI for application that draws a histogram
  # shinyUI(fluidPage(
  #   
  #   # Application title
  #   titlePanel("Earthquakes throughout the world"),
  #   
  #   tags$head(tags$link(rel='stylesheet', type='text/css', href='www/styles.css')),
  #   leafletMap(
  #     "map", "100%", 400,
  #     initialTileLayer = "//{s}.tiles.mapbox.com/v3/tgirgin.ll67dej8/{z}/{x}/{y}.png",
  #     initialTileLayerAttribution = HTML('Maps by <a href="http://www.mapbox.com/">Mapbox</a>'),
  #     options=list(
  #       center = c(39.833333, -98.583333),
  #       zoom = 4,
  #       maxBounds = list(list(17, -180), list(59, 180))
  #     )
  #   ),
  #   
  # #   # Sidebar with a slider input for the number of bins
  # 
  #     # Show a plot of the generated distribution
  #     mainPanel(
  #       textOutput("text1")
  #     )
  #  )
  # ))