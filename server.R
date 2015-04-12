library(shiny)
library(RCurl)
library(leaflet)
library(ggplot2)
library(maps)
library(gdalUtils)
library(RPostgreSQL)

# setwd("~/Google Drive/Spring 2015/CS 368/")
# Downloading the CSV file containing data about earthquakes
#URL <- "http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_month.geojson"
#download.file(URL, destfile = "./Final_project/www/all_month.geojson", method = "auto", quiet = TRUE)
#x <- getURL(URL)

# Storing the geojson to the database
#system("ogr2ogr -f \"PostgreSQL\" PG:\"dbname=final_project user=timur1\" \"./Final_project/www/all_month.geojson\" -nln month_earthquake -OVERWRITE")

# Initializing the PostgreSQL driver
drv <- dbDriver("PostgreSQL")

# Connecting to the database
con <- dbConnect(drv, dbname="final_project")

# Querying for the number of rows in the tables
countRows <- dbGetQuery(con, "SELECT count(*) FROM month_earthquake")[[1]]
countCountries <- dbGetQuery(con, "SELECT count(*) FROM countries")[[1]]

# Querying for the longitude
lon <- dbGetQuery(con, "SELECT ST_X(ST_AsText(ST_GeomFromEWKB(wkb_geometry)))  FROM month_earthquake")

# Querying for the latitude
lat <- dbGetQuery(con, "SELECT ST_Y(ST_AsText(ST_GeomFromEWKB(wkb_geometry)))  FROM month_earthquake")

# Querying for the depth
depth <- dbGetQuery(con, "SELECT ST_Z(ST_AsText(ST_GeomFromEWKB(wkb_geometry)))  FROM month_earthquake")

# Querying for the mag
mag <- dbGetQuery(con, "SELECT mag FROM month_earthquake")

# Querying the country names
countryName <- dbGetQuery(con, "SELECT rtrim(name) FROM countries")

for(j in 1:countCountries)
{
  # "Choice 1" = 1, "Choice 2" = 2, "Choice 3" = 3
  #name <- noquote(paste("\"", countryName[[1]], "\"", " = ", countryName[[1]], sep = ""))
  name <- paste("\"", countryName[[1]], "\"", " = ", countryName[[1]], sep = "")
  
}

# Define server logic required to draw a histogram;
# Added sesssion argument so that we can create the map
shinyServer(function(input, output, session) {

  # Creates the map
  map <- createLeafletMap(session, 'map')
  
  # Wait until map is loaded
  session$onFlushed(once = TRUE, function() {
    
    # Calculate time it takes to run the for loop
    ptm <- proc.time()
    for(i in 1:countRows)
    {
      map$addCircleMarker(lat[[1]][[i]], lon[[1]][[i]], mag[[1]][[i]])
    }
    # Stops the chrono
    time <- proc.time() - ptm
   
    # Output text
    output$text1 <- renderPrint({ 
      paste("It took ", time)
    })
    # Output name
    output$value <- renderPrint({ 
      input$select 
    })
  }) 
})
