####################################################
### Filename: AllStations.R
####################################################
### Description: 
##  downloads weather data for Maryland Counties 
##  using NOAA API. Max and min daily values are used 
##  to calculate growing degree day (GDD)
##
### Author: 
##  Perry Oddo [perry.oddo@nasa.gov]
##
### Last Modified:
##  4.25.18 [version 2]
####################################################

### Clear environment
rm(list = ls())
graphics.off()
set.seed(1)

### Load required packages
require(httr)
require(jsonlite)
require(lubridate)
require(dplyr)

### Source weather API and plotting functions
source("Scripts/WeatherFunctions.R")
source("Scripts/WeatherPlots.R")

### Source weather station and county data frames
station_df = dget("Data/station_df")
county_df = dget("Data/county_df")

### List all available counties
counties = (levels(factor(station_df$county)))

### Number of stations per county
data.frame(station_df %>%
             group_by(county) %>%
             summarize(no_rows = length(county)))



##############################
# Run for a single year
##############################

### Show all available counties
print(counties)

### Select county
county = "Talbot"   
                
### Input date range
year = 2017

### Run function
export = weather_fn(county, year)

# Create plots
weather_plot(export)

### Export data to .csv
writeout()



##############################
# Batch run for multiple years
##############################

### Show all available counties
print(counties)

### Select county
county = "Prince George's"   

### Input date range
start_year = 2015
end_year = 2017

### Batch export
export_batch = batch_fn(start_year, end_year)

# Create plots
weather_plot_batch(export_batch)

### Export data to .csv
writeout_batch()
