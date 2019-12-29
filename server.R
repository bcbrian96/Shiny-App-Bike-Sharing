#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#


library(shiny)
library(RSQLite)
library(DBI)

library(ggmap)
library(ggplot2)


dbcon = dbConnect(SQLite(), dbname = "stat240Apr3.sqlite")


shinyServer(function(input, output) {
  
  
  x <- reactive({
    if (input$dataSource == "allUsers"){
      query = "SELECT tripduration, starttime, stoptime FROM biketrips"
      x = dbGetQuery(dbcon,query)
    } else {
      if (input$dataSource == "membersOnly"){
        query = "SELECT tripduration, starttime, stoptime FROM biketrips WHERE usertype == 'Member'"
        x = dbGetQuery(dbcon,query)
      } else{
        if (input$dataSource == "passHolder"){
          query = "SELECT tripduration, starttime, stoptime FROM biketrips WHERE usertype == 'Short-Term Pass Holder'"
          x = dbGetQuery(dbcon,query)
        }else{
          x=NULL
        }
      }
    }
  })
  
  
  output$distPlot <- renderPlot({
    
    
    if(input$units == "secs"){
      x <- x()[,1]
      bins <- seq(min(x), max(x), length.out = input$bins + 1)
      XLIMITS = c(input$xmin, input$xmax)
      # draw the histogram with the specified number of bins
      hist(x, breaks = bins, col = 'darkgray', border = 'white', xlim = XLIMITS,
           prob = input$DensityLogical,
           main = "Distribution of Trip Duration",
           xlab = "Trip Duration (Seconds)")
    }else{
      if(input$units == "mins"){
        x <- x()[,1]
        x = x/60
        bins <- seq(min(x), max(x), length.out = input$bins + 1)
        XLIMITS = c(input$xmin, input$xmax)
        
        hist(x, breaks = bins, col = 'darkgray', border = 'white', xlim = XLIMITS,
             prob = input$DensityLogical,
             main = "Distribution of Trip Duration",
             xlab = "Trip Duration (Minutes)")
      }
    }
    
    if(input$DensityLogical){
      if(input$BoundaryCorrect ){  #input$BoundaryCorrect comes from the conditional panel
        xuse = c(-x,x)
        Dens = density(xuse,from = input$xmin)
        Dens$y = Dens$y*2
      }else{
        Dens = density(x)
      }
      lines(Dens)
    }
    
  })
  ##############END OF TAB1
  
  #########START OF TAB 2
  output$otherPlot <- renderPlot({
    
    
    if(input$startStop == "starting"){
      x <- x()[,2]
      hrs = strptime(x, format = "%m/%d/%Y %H:%M")
      hrs = as.numeric(difftime(hrs, trunc(hrs, "days"),
                                tz="PST8PDT", "hours"))
      
      bins <- seq(min(hrs), max(hrs), length.out = input$bins + 1)
      
      # draw the histogram with the specified number of bins
      hist(hrs, breaks = bins, col = 'darkgray', border = 'white',
           prob = input$DensityLogical,
           main = "Trip Start Time by Time of Day",
           xlab = "24-Hour Time")
    }else{
      if(input$startStop == "stopping"){
        x <- x()[,3]
        hrs = strptime(x, format = "%m/%d/%Y %H:%M")
        hrs = as.numeric(difftime(hrs, trunc(hrs, "days"),
                                  tz="PST8PDT", "hours"))
        
        bins <- seq(min(hrs), max(hrs), length.out = input$bins + 1)
        
        # draw the histogram with the specified number of bins
        hist(hrs, breaks = bins, col = 'darkgray', border = 'white',
             prob = input$DensityLogical,
             main = "Trip Stop Time by Time of Day",
             xlab = "24-Hour Time")
      }
    }
    
    # if(input$DensityLogical){
    #  lines(density(hrs,from=0))
    
    # }
    
    if(input$DensityLogical){
      if(input$newColor ){  
        d = density(hrs,from=0)
        lines(d,col="red")
      }else{
        d = density(hrs,from=0)
        lines(d)
      }
      #lines(d)
    }
    
  })
  
  
  output$perDay <- renderPlot({
    x <- x()[,2]
    days = as.Date(x, format = "%m/%d/%Y")
    days = weekdays(days)
    
    barplot(table(days)
            [c("Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday")],
            las = 2, main = "Number of Starting Trips per Day of the Week",
            ylab = "Number of Trips")
    
    
  })
  
  output$stationMap <- renderPlot({
    stations = dbReadTable(dbcon,"stationlocation")
    counts = dbReadTable(dbcon,"tofromcounts")
    colnames(counts)[1] = "station_id"
    counts = merge(stations,counts,by="station_id")
    
    mymap <- get_map(location = c(lon=-122.325, lat = 47.63), 
                     maptype = "terrain",
                     zoom = 13)
    
    if(input$countTo){
      ggmap(mymap) + 
        geom_point(data = counts,
                   aes( x = long, y = lat, 
                        color = count_to,
                        size = count_to
                   ),
                   alpha=0.7
        )
    }else{
      ggmap(mymap) + 
        geom_point(data = counts,
                   aes( x = long, y = lat, 
                        color = count_from,
                        size = count_from
                   ),
                   alpha=0.7
        )
    }
    
  })
  
  output$timeData <- renderPlot({
    if(input$perUnits == "day"){
      x <- x()[,2]
      tripsbyDay = as.Date(x, format = "%m/%d/%Y")
      
      tripsbyDay = as.factor(tripsbyDay)
      everyDay = as.factor(levels(tripsbyDay))
      tabDay = table(tripsbyDay)
      tabDay = as.data.frame(tabDay)
      
      plot(as.numeric(tabDay$tripsbyDay), tabDay$Freq,
           ylab = "Number of Trips", xlab="Date", 
           main = "Number of Trips per Day",xaxt="n")
      axis(1,at=1:811,labels=everyDay[1:811])
      
      if(input$trendsLine){  
        lines(ksmooth(as.numeric(tabDay$tripsbyDay), tabDay$Freq,
                      bandwidth=3), col=2, lwd=3)
      }
     
    }else{
      if(input$perUnits == "month"){
        
        x <- x()[,2]
        tripsbyDay = as.Date(x, format = "%m/%d/%Y")
        tripsbyMonth = format(tripsbyDay, "%Y-%m")
       
        tripsbyMonth = as.factor(tripsbyMonth)
        everyMonth = as.factor(levels(tripsbyMonth))
        tabMonth = table(tripsbyMonth)
        tabMonth = as.data.frame(tabMonth)
        
        plot(as.numeric(tabMonth$tripsbyMonth), tabMonth$Freq,
             ylab = "Number of Trips", xlab="",
             main = "Number of Trips per Month", xaxt="n")
        axis(1,at=1:27,labels=everyMonth[1:27],las=2)
        
        if(input$trendsLine){  
          lines(ksmooth(as.numeric(tabMonth$tripsbyMonth), tabMonth$Freq,
                        bandwidth=3), col=2, lwd=3)
        }
        
      }
    }
 
    
    
  })
  
  
})
