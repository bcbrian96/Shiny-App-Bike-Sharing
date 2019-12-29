#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Bike Sharing in Seattle"),
  
  radioButtons("dataSource", "Select User Type",
               c("All Users" = "allUsers",
                 "Members" = "membersOnly",
                 "Short-Term Pass Holders" = "passHolder")),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      
      conditionalPanel(
        condition="input.conditionalTab==4 || input.conditionalTab==3",
        sliderInput("bins",
                    "Number of bins:",
                    min = 1,
                    max = 50,
                    value = 30,
                    step = 2)
      ),
      
      conditionalPanel(
        condition="input.conditionalTab==2",
        HTML("<h4> Adjust User Type Above to Observe Differences</h4>"
        )
      ),
      
      conditionalPanel(
        condition="input.conditionalTab==4",
        
        numericInput("xmin", "x-axis minimum:", 0),
        numericInput("xmax", "x-axis maximum value:", 10000)
        
      ),
      
      conditionalPanel(
        condition = "input.conditionalTab==4",
        
        selectInput("units", "X-Axis Units:",
                    c("Seconds" = "secs",
                      "Minutes" = "mins"), multiple = FALSE)
      ),
      
      conditionalPanel(
        condition = "input.conditionalTab==3",
        
        selectInput("startStop", "Trip Start Time or Stop Time",
                    c("Start Time" = "starting",
                      "Stop Time" = "stopping"), multiple = FALSE)
      ),
      
      conditionalPanel(
        condition = "input.conditionalTab==4 || input.conditionalTab==3",
        checkboxInput("DensityLogical", strong("Add density plot?"), FALSE)
      ),
      
      
      conditionalPanel(
        condition = "input.DensityLogical == true && input.conditionalTab==4",   #Note th lowercase logical
        helpText(HTML("<h3>You might want to adjust the boundary estimate</h3>")),  #This is just big text
        checkboxInput("BoundaryCorrect", strong("Correct the density plot at zero?"), FALSE)  #This is a new input
        #
      ),
      
      conditionalPanel(
        condition = "input.DensityLogical == true && input.conditionalTab==3",   #Note th lowercase logical
        helpText(HTML("<h3>New Color</h3>")),  #This is just big text
        checkboxInput("newColor", strong("Change Density Line Color to Red?"), FALSE)  #This is a new input
        #
      ),
      
      conditionalPanel(
        condition = "input.conditionalTab==5",
        checkboxInput("countTo", strong("Compare with Arrivals?"), FALSE)
      ),
      
      conditionalPanel(
        condition = "input.conditionalTab==1",
        selectInput("perUnits", "Per Day or Per Month",
                    c("Per Day" = "day",
                      "Per Month" = "month"), multiple = FALSE)
      ),
      conditionalPanel(
        condition = "input.conditionalTab==1",
        checkboxInput("trendsLine", strong("Add Moving Average Line?"), FALSE)
        
      )
      
      
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      #plotOutput("distPlot")
      
      
      tabsetPanel(type = "tabs", id="conditionalTab",
                  tabPanel("Trip Time Data", value="1", HTML("<h1>Trip Data Overview</h1><p>We plot raw data of the total number of trips over time to see if time trends occur.</p>
                                                             <p>We can clearly see very strong seasonal trends from the plots. It appears as if there are more bike trips during the summer than the winter, which makes sense.</p>"),
                           plotOutput("timeData")),
                  
                  tabPanel("Trips per Day", value="2", HTML("<h1>Digging Deeper into the Data</h1><p>We create a barplot to show the number of trips over days of the week. 
                                                            At first glance, it appears if the trips over days of the week for all users is relatively uniform.</p>
                                                            <p>However, the trips over days of the week differs strongly between members and short-term pass holders. Members tend to bike during the weekday, while short-term pass holders bike more on the weekend.</p>"),
                           plotOutput("perDay")),
                  
                  tabPanel("Time of Day", value="3", HTML("<h1>Trips over a 24 hour time period</h1><p>We plot the distribution of the number of trips during a time of day.</p>
                                                          <p>We can observe very strong differences of the distribution between members and short-term pass holders. Members tend to start their trips during rush hour times.
                                                          Possibly we can assume that the members are biking during the weekday as a form of transportation to work.</p>
                                                          <p>On the other hand, short-term pass holders start their trips more frequently over the afternoon. It may be possible that short-term pass holders are biking more on the weekend as a form of leisure during the afternoon.</p>"),
                           plotOutput("otherPlot")),
                  
                  tabPanel("Trip Duration", value="4", HTML("<h1>Trip Duration</h1><p>We wish to visualize the distribution of trip durations to get a better sense of the data. It appears as if the distribution of trip duration is strongly right skewed, meaning the trip durations are usually quite short.
                                                              Do the trip durations between user-types differ?</p>
                                                            <p>It appears as the trip durations for short-term pass holders are slightly more variable than members. Members are more likely to go on shorter trips than short-term pass holders.</p>"),
                           plotOutput("distPlot")),
                  
                  tabPanel("Stations", value="5", HTML("<h1>Stations Locations/Popularity</h1><br><p><em>Where are the stations located?</em> We have plotted all 60 unique stations below in the map of Seattle below. It appears the location of stations are quite clustered around downtown Seattle and the University of Washington area.</p>
                                                      <p>We also wish to visualize the popularity of stations among <em>all user types</em>. Station departures and arrivals are shown in scale. Most departures and arrivals from stations occur around the downtown Seattle area. </p>"),
                           plotOutput("stationMap")
                           ),
                  
                  
                  
                  
                  
                  tabPanel("About",source("about.R")$value()) #This is the new tab with some info
                  
                  
                  
      )
    )
  )
))
