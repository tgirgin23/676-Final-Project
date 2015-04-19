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

USAQuery <- dbGetQuery(con, "SELECT USAlon as lon, USAlat as lat, USAdepth as depth, mag, ids 
                     FROM month_earthquake 
                     WHERE USAlon IS NOT NULL")

dbDisconnect(con)
dbUnloadDriver(drv)