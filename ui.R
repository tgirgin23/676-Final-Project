library(shiny)
library(ShinyDash)
library(leaflet)
source("sql.R")
library(shinydashboard)
library(dygraphs)


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
      tags$head(tags$link(rel="stylesheet", type="text/css", href="style.css")),
      column(width = 9,
        box(width = NULL,
          leafletMap(
            "map", "100%", 400,
            initialTileLayer = "//{s}.tiles.mapbox.com/v3/tgirgin.ll67dej8/{z}/{x}/{y}.png",
            initialTileLayerAttribution = HTML('Maps by <a href="http://www.mapbox.com/">Mapbox</a>'),
            options=list(
              center = c(38.833333, -98.583333),
              zoom = 4
              #maxBounds = list(list(17, -180), list(59, 180))
            )
          )
        )
      ),
      column(width = 3,
        tabBox(title = NULL, id = "boxes", width = NULL,
          tabPanel("Country",
            selectInput("select", label = NULL, 
                        choices = test, 
                        selected = "United States")
          ),
          tabPanel("Magnitude",
            sliderInput("magSlider", label = NULL, min = 0, 
                        max = 10, value = c(0, 10))
          )
        ),
#         box(
#           dygraphOutput("dygraph")
#         ),
      
        textOutput("text1"),
        textOutput("first"),
        textOutput("second")
      )
    )
  )
)