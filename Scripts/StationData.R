####################################################
### Filename: StationData.R
####################################################
### Description: 
##  downloads metadata for Maryland weatherstations
##  using NOAA API. Adds county information and FIPS
##  codes using FCC API. 
##
### Author: 
##  Perry Oddo [perry.oddo@nasa.gov]
##
### Last Modified:
##  4.23.18 [version 2]
####################################################


### Load required packages
require(httr)
require(jsonlite)
require(lubridate)

### Find all MD stations with Daily Weather data (GHCND)
# Credentials
username = "perry.oddo@nasa.gov"
password = "YCpQhsETkaSRMFwEqKUcbWKhurNmcbIM"

# Base address with parameters
base1 = "https://www.ncdc.noaa.gov/cdo-web/api/v2/"

end1 = paste("stations?locationid=FIPS:24",
                 "&datasetid=GHCND",
                 "&limit=1000",
                 sep = "")

# Full API call
call = paste(base1, end1, sep = "")

result = GET(call, add_headers(token = password))
result.text = content(result, "text")
call.json = fromJSON(result.text, flatten = T)
station_df = call.json$results


### Grab county names for each station by lat/lon
counties = vector("character", length = length(station_df[,1]))
FIPS = vector("numeric", length = length(station_df[,1]))

# County API Call
base2 = "https://geo.fcc.gov/api/census/area?"

# Loop over locations
for(i in 1:length(counties)){
  end2 = paste("lat=", station_df$latitude[i],
                 "&lon=", station_df$longitude[i],
                 "&format=json", sep = "")
  
  call = paste(base2, end2, sep = "")
  
  result = GET(call)
  result.text = content(result, "text")
  call.json = fromJSON(result.text, flatten = T)

  counties[i] = call.json$results$county_name[1]
  FIPS[i] = call.json$results$county_fips[1]

}

### Add county names and FIPS codes to station data frame
station_df$county = counties
station_df$FIPS = FIPS


### New data frame for county names and FIPS codes
name = station_df[!duplicated(station_df$county), "county"]
code = station_df[!duplicated(station_df$county), "FIPS"]
county_df = data.frame(name, code)

### Write station and county data frames to file
dput(station_df, "../Data/station_df")
dput(county_df, "../Data/county_df")

