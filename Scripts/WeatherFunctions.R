####################################################
### Filename: WeatherFunctions.R
####################################################
### Description: 
##  Functions to fetch weather data from NOAA API and
##  calculate growing degree days (GDD) based on daily
##  maximum and minimum temperatures
##
### Author: 
##  Perry Oddo [perry.oddo@nasa.gov]
##
### Last Modified:
##  4.25.18 [version 2]
####################################################


##############################
# Function for single year run
##############################
weather_fn = function(county, year){
  
  # Check if county was entered correctly
  if(!(county %in% county_df$name)){
    
    stop("Check county name!")
    
  }
  
  # Assign variables
  county = county
  year = year
  
  # Start and end dates
  start = paste(year, "-01-01", sep = "")
  end = paste(year, "-12-31", sep = "")
  
  # Index of selected stations
  county.ind = match(county, 
                     county_df$name)
  
  # API call information 
  username = "perry.oddo@nasa.gov"
  password = "YCpQhsETkaSRMFwEqKUcbWKhurNmcbIM"
  
  base = "https://www.ncdc.noaa.gov/cdo-web/api/v2/"
  
  endpoint = paste("data?datasetid=GHCND",
                   "&locationid=FIPS:",county_df$code[county.ind],  # FIPS code specific to county.ind
                   "&units=metric",
                   "&datacategoryid=TEMP",
                   "&datatypeid=TMIN",
                   "&datatypeid=TMAX",
                   "&limit=1000",
                   "&startdate=",start,
                   "&enddate=",end, sep="")
  
  
  # Full API call
  call = paste(base, endpoint, sep = "")
  
  
  # Submit initial call to extract metadata
  message(paste("Submitting API call for", county, year, "data", sep = " "))
  message() 
  
  result = GET(call, add_headers(token = password))
  result.text = content(result, "text")
  
  # Check for data availability
  if(result.text=="{}"){
    
    stop(paste("No data found for selected date range ", "[", year, "]", sep = ""))
    
  }
  
  # Extract from JSON to text
  call.json = fromJSON(result.text, flatten = T)
  
  # Find total number of records
  # Need to submit requests in batches of 1000 to avoid exceeding call limits
  n_records = call.json$metadata$resultset$count
  n_calls = ceiling(n_records/1000)
  
  # Create object to store data
  datalist = list()
  
  # Re-submit API call in batches 
  # offset by 1000 each loop
  for(i in 1:n_calls){
    
    endpoint = paste("data?datasetid=GHCND",
                     "&locationid=FIPS:",county_df$code[county.ind], 
                     "&units=metric",
                     "&datacategoryid=TEMP",
                     "&datatypeid=TMIN",
                     "&datatypeid=TMAX",
                     "&limit=1000",
                     "&startdate=",start,
                     "&enddate=",end, 
                     "&offset=", (i-1)*1000,
                     sep="")
    
    
    # Full API call
    call = paste(base, endpoint, sep = "")
    
    # Extract from JSON to text
    result = GET(call, add_headers(token = password))
    result.text = content(result, "text")
    
    call.json = fromJSON(result.text, flatten = T)
    datalist[[i]] = call.json$results
    
  }
  
  # Bind output together in single object
  output = do.call(rbind, datalist)
  
  # Remove duplicate values from each date
  unique.vals = which(duplicated(output[,c(1,2)])==F)
  temp.data = output[unique.vals,]
  
  # Reformat date column
  temp.data$date = as.Date(temp.data$date)
  
  #Extract temperatures for each day
  dates = unique(as.Date(temp.data[,1]))
  days = yday(dates)
  
  tmin.ind = temp.data[which(temp.data$datatype=="TMIN"),]
  tmax.ind = temp.data[which(temp.data$datatype=="TMAX"),]
  
  tmerge = merge(tmin.ind, tmax.ind, by = "date", all = T)
  
  # Calculate GDD
  gdd_fn = function(tmax, tmin, tbase=4){
    
    ((tmax+tmin)/2) - tbase
    
  }
  
  dates = unique(as.Date(temp.data[,1]))
  days = yday(dates)
  
  tmin = tmerge$value.x
  tmax = tmerge$value.y
  gdd = gdd_fn(tmax, tmin)
  
  # Convert negative GDD to zero
  gdd[which(gdd<0)] = 0
  
  
  # Combine into data frame to export
  gdd.export = data.frame(dates, days, rep(county, length(dates)), tmax, tmin, gdd)
  colnames(gdd.export) = c("Date", "Julian_Day", "County", "Tmax", "Tmin", "GDD_Base4")
  
  
  # Function to write data to file
  writeout = function(){
    
    input = readline("Export data to csv file? Y/N  ")
    input = toupper(input)
    
    if(input == "Y" | input == "YES"){
      
      write.csv(x = export,
                file = paste("Output/", gsub(" ", "_",county),"_",year,".csv", sep = ""),
                row.names = F,
                quote = F)
      
      message("File written")
      
    }
    
    else if(input == "N" | input == "NO"){
      
      message("No file written")
      
    }
    
    else{
      
      message("Enter Y or N")
      
    }
    
  }
  
  assign("writeout", writeout, globalenv())
  
  
  # Return data frame to Global Environment
  return(gdd.export)

}


##############################
# Function for batch runs
##############################
batch_fn = function(start_year, end_year){
  
  # Sequence of years
  years = seq(start_year, end_year)
  
  # Create object to store each years' data
  datalist = list()
  
  # Loop over each year
  for(i in 1:length(years)){
    
    outfile = paste("outfile", i, sep = "")
    datalist[[i]] = weather_fn(county, years[i])
    
  }
  
  # Bind output into single object
  out = do.call(rbind, datalist)
  
  # Function to write data to file (batch)
  writeout_batch = function(){
    
    input = readline("Export data to csv file? Y/N  ")
    input = toupper(input)
    
    if(input == "Y" | input == "YES"){
      
      write.csv(x = export_batch,
                file = paste("Output/", gsub(" ", "_", county),"_",start_year,"-", end_year, ".csv", sep = ""),
                row.names = F,
                quote = F)
      
      message("File written")
      
    }
    
    else if(input == "N" | input == "NO"){
      
      message("No file written")
      
    }
    
    else{
      
      message("Enter Y or N")
      
    }
    
  }
  
  assign("writeout_batch", writeout_batch, globalenv())
  
  
  # Return data frame to Global Environment
  return(out)
  
}