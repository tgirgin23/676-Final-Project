library(RPostgreSQL)

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

# Querying for ids
ids <- dbGetQuery(con, "SELECT ids FROM month_earthquake")

# Querying the country names
countryName <- dbGetQuery(con, "SELECT rtrim(name) FROM countries")

timsFunction <- function(a) {
  list(a)
}
test <- sapply(countryName[[1]], timsFunction)

selectCountry <- function(countryName)
{
#   testQuery <- dbSendQuery(con, "SELECT place FROM month_earthquake, countries 
#     WHERE st_within(ST_GeomFromWKB(month_earthquake.wkb_geometry, 4326), countries.geom) 
#     and countries.name LIKE 'United%'")
}
