# Weather API
### Tool information
##### Background:
The tool identifies a list of Maryland weather stations that provide Global Historical Climatology Network (GHCN) Daily data using the National Climate Data Center (NCDC) [API](https://www.ncdc.noaa.gov/cdo-web/webservices/v2#gettingStarted). Weather stations are linked to county FIPS code by feeding the lat/long coordinates of each station into the Federal Communications Commission (FCC) [Area API](https://geo.fcc.gov/api/census/). The code used to scrape station information and link to FIPS code can be found at: `WeatherAPI\Scripts\StationData.R`. For the selected county and year, daily minimum and maximum temperature values are downloaded and used to calculate growing degree days (GDD).

##### Growing Degree Day (GDD) calculation:
Applies the formula describe in [Prabhakara et al. 2015](https://www.sciencedirect.com/science/article/pii/S0303243415000525) (section 2.4 *Growing degree days*):

>![\Large GDD=\frac{[T_{max} + T_{min}]}{2}-T_{base}](http://latex.codecogs.com/svg.latex?GDD%3D%5Cfrac%7BT_%7Bmax%7D%2BT_%7Bmin%7D%7D%7B2%7D-T_%7Bbase%7D)

where *T<sub>base</sub>* equals 4 degrees Celcius.



### Instructions
1. Sign up for web services token at the NOAA Climate Data Online (CDO) [token request page](https://www.ncdc.noaa.gov/cdo-web/token).
2. Replace "username" and "password" information in the `WeatherFunctions.R` file: `WeatherAPI\Scripts\WeatherFunctions.R` (line 42-43)
3. Generate weather data using `WeatherAPI.R` file:
	* **Single year run**: Change inputs for *county* (line 53) and *year* (line 56)
	*  **Multi-year batch run**: Change inputs for *county* (line 77) and *start*/*end year* (lines 80-81)
4. Plot time series data
5. Export time series data to .csv `WeatherAPI\Output\export_file.csv`

***NOTE:** Processing time will vary depending on selected county and time period. Counties with more data stations and wide data coverage will likely take longer. Full list of all 609 Maryland-based stations (includes some DC, WV, VA) can be found [here](https://www.ncdc.noaa.gov/cdo-web/datasets/GHCND/locations/FIPS:24/detail#stationlist).

### Required R Packages
* httr
* jsonlite
* lubridate
* dplyr

### Contact:
Author: [Perry Oddo](mailto:perry.oddo@nasas.gov)
