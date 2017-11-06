
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#
#Map api
library(RCurl)
library(RJSONIO)
library(plyr)
library(dplyr)

# web scraping
library(xml2)
library(httr)
library(rvest)

library(shiny)
library(DT)

url <- function(address, return.call = "json", sensor = "false") {
  root <- "http://maps.google.com/maps/api/geocode/"
  u <- paste(root, return.call, "?address=", address, "&sensor=", sensor, sep = "")
  return(URLencode(u))
}
geoCode <- function(address,verbose=FALSE) {
  if(verbose) cat(address,"\n")
  u <- url(address)
  doc <- getURL(u)
  x <- fromJSON(doc,simplify = FALSE)
  if(x$status=="OK") {
    lat <- x$results[[1]]$geometry$location$lat
    lng <- x$results[[1]]$geometry$location$lng
    location_type <- x$results[[1]]$geometry$location_type
    formatted_address <- x$results[[1]]$formatted_address
    return(c(lat, lng, location_type, formatted_address))
    Sys.sleep(0.5)
  } else {
    return(c(NA,NA,NA,NA))
  }
}


server <- function(input, output) {
    worldcities <- read.csv("world-cities.csv",header = TRUE)
    names(worldcities) <- c("city","country","region","geonameid")
  
    output$mapname <- renderText(paste("You're looking at ", input$location))
    output$type <-renderPrint({
      cat("The location type you have chosen is :", input$locationtype, "\n")
    })
    
    output$info <-renderText({
      thistype <- input$locationtype
      
      if(thistype == "Country"){
        thiscountry <- input$locationtype
        thislocation <- worldcities %>% filter(country == input$location)
        if(length(thislocation[,1])==0){
          output$citytable <-DT::renderDataTable(thislocation %>% select("city"))
          return(paste(input$location, "!!  No such a country."))}
        else{
          word <-paste("Here is all cities of ", input$location, " over 15000 people.")
          output$citytable <-DT::renderDataTable(thislocation %>% select("city","region","geonameid"))
          return(word)
        }
      }
      
      if(thistype == "City"){
        thiscountry <- input$locationtype
        thislocation <- worldcities %>% filter(city == input$location)
        if(length(thislocation[,1])==0){
          output$citytable <-DT::renderDataTable(thislocation %>% select("country"))
          return(paste(input$location, "!!  No such a city."))}
        else{
          word <-paste("The city ",input$location, " is located in following country(ies)")
          output$citytable <-DT::renderDataTable(thislocation %>% select("country","region","geonameid"))
          return(word)
        }
      }
      else{
        word <-paste("Here is some information about ",input$location)
        address <- c(input$location)
        locations <- ldply(address, function(x) geoCode(x))
        names(locations) <- c("Latitude", "Longitude", "Location_type", "Adress")
        longitude <-locations$lon
        latitude <- locations$lat
        output$citytable <-DT::renderDataTable(locations)
        return(word)
      }
      
    })
    output$descrip_text <- renderText({
    tosearch <- list(search = input$location)
    website_language <- "https://en.wikipedia.org/wiki/Main_Page"
    if(input$language == "Francais"){
      website_language <- "https://fr.wikipedia.org/wiki/Wikip%C3%A9dia:Accueil_principal"
    }
    res <- POST(website_language, body = tosearch, encode = "form", verbose())
    txt<- res %>% read_html()  %>%
      html_nodes(xpath = '//*[@id="mw-content-text"]/div/p[1]') %>% 
      html_text()
    txt
  })
    
  output$map <- renderPlot({
    address <- c(input$location)
    locations <- ldply(address, function(x) geoCode(x))
    names(locations) <- c("lat", "lon", "location_type", "formatted")
    longitude <- as.numeric(locations$lon)
    print(longitude)
    latitude <- as.numeric(locations$lat)
    print(latitude)
    
    thisplot <- ggmap::get_googlemap(center = c(lon= longitude, lat= latitude), 
                                     zoom = input$slider, size = c(640,640),maptype = c(input$mapmode))
    thisplot <- thisplot %>% ggmap::ggmap(extent = "device",
                      ylab = "Latitude",
                      xlab = "Longitude")
    thisplot
    })
}
