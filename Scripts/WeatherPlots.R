####################################################
### Filename: WeatherPlots.R
####################################################
### Description: 
##  Plotting functions for single year and batch
##  version of weather API
##
### Author: 
##  Perry Oddo [perry.oddo@nasa.gov]
##
### Last Modified:
##  4.25.18 [version 2]
####################################################

weather_plot = function(export){
  
  # plot limits
  plot.max = 5*ceiling(max(export[,c("Tmax", "Tmin", "GDD_Base4")], na.rm = T)/5)
  plot.min = 5*floor(min(export[,c("Tmax", "Tmin", "GDD_Base4")], na.rm = T)/5)  
  
  # plot results
  plot(export$Tmax~export$Julian_Day, 
       type = 'n', 
       xlab = "Julian Day",
       ylab = "Temperature [C]",
       xaxt = 'n',
       yaxt = 'n',
       ylim = c(plot.min, plot.max))
  
  temp.cols = c(rgb(.8, 0, .2, 0.65), 
                rgb(0, .20, .80, 0.65), 
                rgb(0,0,0,0.65))
  
  matpoints(x = export$Julian_Day, y = export[,4:6],
            pch = 21,
            col = "black",
            bg = temp.cols)
  
  axis(2, at = seq(plot.min, plot.max, by = 5), 
       labels = seq(plot.min, plot.max, by = 5), las = 1)
  
  axis(1, at = c(1, 60, 120, 180, 240, 300, 365),
       labels = c(1, 60, 120, 180, 240, 300, 365))
  
  box(lwd = 1.5)
  
  legend("topleft",
         c("Tmax",
           "Tmin",
           "GDD"),
         col = "black",
         pt.bg = temp.cols,
         pch = 21,
         bty = 'n')
  
  text(x = max(export$Julian_Day),
       y = plot.max,
       labels = paste(county,"County","\n",year,""),
       font = 2,
       adj = c(1,1))
}

weather_plot_batch = function(export_batch){
  
  # plot limits
  plot.max = 5*ceiling(max(export_batch[,c("Tmax", "Tmin", "GDD_Base4")], na.rm = T)/5)
  plot.min = 5*floor(min(export_batch[,c("Tmax", "Tmin", "GDD_Base4")], na.rm = T)/5)    
  
  # plot results
  plot(export_batch$Tmax~export_batch$Date, 
       type = 'n', 
       xlab = "Time",
       ylab = "Temperature [C]",
       yaxt = 'n',
       ylim = c(plot.min, plot.max))
  
  temp.cols = c(rgb(.8, 0, .2, 0.65), 
                rgb(0, .20, .80, 0.65), 
                rgb(0,0,0,0.65))
  
  matpoints(x = export_batch$Date, y = export_batch[,4:6],
            pch = 21,
            col = "black",
            bg = temp.cols)
  
  axis(2, at = seq(plot.min, plot.max, by = 5), 
       labels = seq(plot.min, plot.max, by = 5), las = 1)
  
  box(lwd = 1.5)
  
  legend("topleft",
         c("Tmax",
           "Tmin",
           "GDD"),
         col = "black",
         pt.bg = temp.cols,
         pch = 21,
         bty = 'n')
  
  text(x = max(export_batch$Date),
       y = plot.max,
       labels = paste(county,"County","\n",
                      start_year, "-", end_year,""),
       font = 2,
       adj = c(1,1))
}
