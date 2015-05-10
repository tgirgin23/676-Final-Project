library(RPostgreSQL)

# Initializing the PostgreSQL driver
drv <- dbDriver("PostgreSQL")

# Connecting to the database
con <- dbConnect(drv, dbname="final_project")

# Querying for the number of rows in the tables
countRows <- dbGetQuery(con, "SELECT count(*) FROM month_earthquake")[[1]]
countCountries <- dbGetQuery(con, "SELECT count(*) FROM countries")[[1]]

# Querying the country names
countryName <- dbGetQuery(con, "SELECT rtrim(name) FROM countries")

USAFunction <- function(min, max)
{
  # Reconnecting to the DB
  con <- dbConnect(drv, dbname="final_project")
   
  USAQuery <<- dbGetQuery(con, paste("SELECT USAlon as lon, USAlat as lat, USAdepth as depth, mag, ids 
                     FROM month_earthquake 
                     WHERE USAlon IS NOT NULL
                     AND mag BETWEEN ", min, " AND ", max, sep = ""))

}

# This will get all the info needed to create the proportional symbols and the popups
otherCountry <- function(min, max, country)
{
  con <- dbConnect(drv, dbname="final_project")
  selCountryQuery <- dbGetQuery(con, paste("SELECT lat, lon, ids, depth, mag, place 
                                            FROM month_earthquake, countries 
                                            WHERE st_within(ST_GeomFromEWKB(month_earthquake.wkb_geometry), 
                                            countries.geom) 
                                            and countries.name LIKE '", country, "' 
                                            AND mag BETWEEN ", min, " AND ", max, sep = ""))
  return(selCountryQuery)
}

# This function is used to change the view to the country selected by the user
changeCountryView <- function(country)
{
  con <- dbConnect(drv, dbname="final_project")
  newView <- dbGetQuery(con, paste("SELECT lat, lon FROM country_centroid WHERE name = '", country, "'", sep = ""))
  return(newView)
}

graphCalc <- function()
{
  
}

dbDisconnect(con)
dbUnloadDriver(drv)

