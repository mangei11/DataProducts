
# This is the server logic for the Shiny web application.
# 

library(shiny)

# hardwired constants
diam_true <- 2
center_true <- c(0,0)
nboot <- 1000
set.seed(2323)

# function to generate data
gendat <- function(n,relsd){
        sd <- diam_true*relsd
        phi <- matrix(runif(n*nboot, min=0, max=2.*pi),
                                nrow=nboot)
        nx <- matrix(rnorm(n*nboot, sd=sd),nrow=nboot)
        ny <- matrix(rnorm(n*nboot, sd=sd),nrow=nboot)
        x <- center_true[1] + diam_true/2*cos(phi) + nx
        y <- center_true[2] + diam_true/2*sin(phi) + ny
        list(x=x, y=y)
}

# function to predict center location (true location is hardwired to (0,0))
center <- function(x,y){ c(mean(x),mean(y))}

# function to predicted the diameter from the x-y data
diam <- function(x,y){ 
        cent <- center(x,y)
        2 * mean(sqrt((x-cent[1])^2 + (y-cent[2])^2))
}

# function to predict the area relative to the true area
area_rel <- function(diam){ diam^2/diam_true^2 } # true diameter is 2 units

# distance between true and predicted center location
dist_center <- function(center) { sqrt( sum( (center-center_true)^2) )}

# simulation and analysis function
resvecall <- function(n,relsd){
        dat <- gendat(n, relsd)
        cent1 <- center(dat$x[1,],dat$y[1,])
        for (i in 1:nboot){
                cent <- center(dat$x[i,],dat$y[i,])
                d <- diam(dat$x[i,],dat$y[i,])
                a <- area_rel(d)
                dist <- dist_center(cent)
                resi <- data.frame(diameter=d/diam_true, 
                                   area=a, dcenter=dist/diam_true)
                if (i == 1) {
                        statdat <- resi
                } else {
                        statdat <- rbind(statdat,resi)
                }
        }
        # compute mean, standard deviation, and bias
        means <- sapply(statdat,mean)
        sdev <- sapply(statdat, sd)
        bias <- means - c(1, 1, 0) # subtract the true values from the means
        rmse <- sqrt(sdev^2+bias^2)
        list(x1=dat$x[1,], y1=dat$y[1,], simdat = statdat, 
                means=as.list(means), sdev=as.list(sdev), bias = as.list(bias),
                rmse = as.list(rmse), xc=cent1[1],yc=cent1[2])
}

# Now the shiny Server function
shinyServer(function(input, output) {
        output$ondat <- renderPrint({input$ndat})
        output$osigma <- renderPrint({input$sigma})
        # calculate output data
        res <- reactive(resvecall(input$ndat, input$sigma/100.))
        output$odiam <- renderPrint({round(c(res()$means$diameter, 
                                             res()$sdev$diameter,
                                             res()$bias$diameter,
                                             res()$rmse$diameter),3)})
        output$oarea <-  renderPrint({round(c(res()$means$area, 
                                              res()$sdev$area,
                                              res()$bias$area,
                                              res()$rmse$area),3)})
        output$odist <- renderPrint({round(c(res()$means$dcenter, 
                                             res()$sdev$dcenter,
                                             res()$bias$dcenter,
                                             res()$rmse$dcenter),3)})
          
        output$distPlot <- renderPlot({    
                # make a scatter plot of the data
                plot(x=res()$x1, y=res()$y1, 
                     xlab="x", ylab="y", main="Data", col="red", pch=19, cex=2)
                points(res()$xc,res()$yc, col="red",pch=3,cex=2)
                points(center_true[1],center_true[2], col="blue",pch=3,cex=2)
        #pdat <- data.frame(x=res()$x1, y=res()$y1)
        #cdat <- data.frame(x=xc_true, y=yc_true)
        #ggplot(pdat,aes(x = x, y = y)) + geom_point(size=I(3), alpha=I(0.5)) #+ 
                #geom_point(aes(x=dat$xc_true, y=dat$yc_true, colour="red", size=I(5))) # +
                #geom_point(aes(x=xc, y=yc, colour="blue", size=I(5) ))
        })
        
        output$histPlotd <- renderPlot({
                # make a histogram of the diameter data
                hist(res()$simdat$diameter, xlab="relative diameter", 
                     main="Histogram of diameters")
        })        
        output$histPlotA <- renderPlot({
                # make a histogram of the area data
                hist(res()$simdat$area, xlab="relative area", 
                     main="Histogram of areas")
        })
        output$histPlotdist <- renderPlot({
                # make a histogram of the center distances
                hist(res()$simdat$dcenter,xlab="relative center distance", 
                     main="Histogram of center-offset distances")
        })
        
})
