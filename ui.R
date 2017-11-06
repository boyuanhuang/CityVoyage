
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(shinydashboard)

ui <- dashboardPage(
  dashboardHeader(title = "Global city viewer"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("About", tabName = 'about', icon = icon("info")),
      menuItem("Dashboard", tabName = "dashboard", icon = icon("globe")),
      menuItem("Map", tabName = "map", icon = icon("map")),
      menuItem("Presentation of chosen location", tabName = "Description", icon = icon("comment"))
    )
  ),
  dashboardBody(
    tabItems(
      # First tab content
      tabItem(tabName = "about",
              h1("About"),
              h2("This is a useful tool for geography"),
              h1(""),
              h3("Dashboard"),
              span("In the control panel, you can enter any place you want on the world."),
              span("Please try these 3 modes" ),
              h3("Map"),
              span("A zoomable map of the chosen place will be desplay here, it uses a google map api"),
              h3("Presentation"),
              span("You can have a brief presentation of this place, it uses the web scraped from wikipedia.")
      ),
      tabItem(tabName = "dashboard",
              fluidPage(
                
                box(width = 20,
                  title = "Control panel",
                  selectInput('locationtype', 'Location type', c("Country","City","Any location, e.g.<<Eiffel Tower>>")),
                  textInput(inputId= "location", label = "Location(Mind the case)", placeholder = "Enter a place", value = "France"),
                  h5("If the display table doesn't appear below, please press load button."),
                  actionButton("load", label = "Load")
                  
                )),
              box(width = 20,
                  h4(textOutput("type")),
                  h4(textOutput("info")),
                  dataTableOutput("citytable")
                )
              
      )
      ,
      
      # Second tab content
      tabItem(tabName = "map",
              h1(textOutput("mapname")),
              h3("Use the slidebar to zoom"),
              sliderInput("slider", value = 10, "Zoom:", 1, 21, 1),
              selectInput("mapmode", label = "Displaymode", choices = c("roadmap","terrain","satellite")),
              plotOutput("map", height = 500, width = 500)
              
      ),
      tabItem(tabName = "Description",
              h2(textOutput(outputId = "descrip_location")),
              fluidRow(
                box(
                  selectInput('language', label = 'Language', c("English","Francais"))
                )),
              p(textOutput(outputId = "descrip_text"))
    )
  )
))
