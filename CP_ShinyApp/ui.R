
# This is the user-interface definition of the Shiny web application
# to predict diameter and area of a disk from a small number of coordinate.
# measurements.
#

library(shiny)

shinyUI(pageWithSidebar(
  
# Application title
        headerPanel("Disk Measurements"),
  
# Sidebar with a slider input for number of bins
        sidebarPanel(
                sliderInput("ndat","Number of x-y measurements:",
                            min = 2,max = 100,value = 10),
                numericInput("sigma","Noise, percent of diameter:",5,
                            min = 1,max = 10, step = 1),
                submitButton("Submit"),
                p("Entered value for number of x-y measurements"),
                verbatimTextOutput("ondat"),
                p("Entered value for the noise level"),
                verbatimTextOutput("osigma")
  ),
  
  # Show a plot of the generated distribution
  mainPanel(h3("User input"),
        p("Enter the number of coordinate pairs to be used for estimation of 
          diameter, area, and center location, as well as the noise level 
          defined as the standard deviation of Gaussian noise in both 
          measurements of x- and y- coordinates."),
        p("This app provides an assessment of the performance this technique
          with respect to precision and systematic errors of diameter, area, 
          and center location. Histograms are included to illustrate deviations 
          from normal distributions."),
        h3("Sample scatterplot of a measurement data set"),
        plotOutput("distPlot", height=400, width=400),
        h3("Simulation Results (based on 1000 samples)" ),           
        h4("Diameter, relative to true diameter:" ),
        p("Expected value, standard deviation, bias, rmse"),
        verbatimTextOutput("odiam"),
        plotOutput("histPlotd", height=300, width=500),
        h4("Area, relative to true area:" ),
        p("Expected value, standard deviation, bias, rmse"),
        verbatimTextOutput("oarea"),
        plotOutput("histPlotA", height=300, width=500),
        h4("Distance between true and estimated center location, 
               relative to true diameter:" ),
        p("Expected value, standard deviation, bias, rmse"),
        verbatimTextOutput("odist"),
        plotOutput("histPlotdist", height=300, width=500)         
  )
))
