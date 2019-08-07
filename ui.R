#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(dplyr)
library(shiny)
library(ggplot2)
library(sourcetools)
library(shinythemes)
library(plotly)

US_df <- read.csv(file = "./data/US_nlp_df.csv")


# Use a fluid Bootstrap layout
navbarPage("Trending YouTube Videos", id="nav",
  tabPanel("Exploration",
    fluidRow(theme = shinytheme("lumen"),
      column(3,
             wellPanel(
               h4("Filter"),
               selectInput("country", "Country",
                           c("United States", "Great Britain", "Canada")
                           ),
               dateRangeInput('dateRange',
                              label = 'Trending Date (Min: 2017-11-14, Max: 2018-06-14):',
                              start = as.Date("2017-11-14", "%Y-%m-%d"), end = as.Date("2018-06-14", "%Y-%m-%d")
               ),
               selectInput("category", "Category:",
                           c("All", "People & Blogs", "Entertainment","Comedy", "Science & Technology", "Film & Animation",
                             "News & Politics", "Sports", "Music", "Pets & Animals", "Education", "Howto & Style",
                             "Autos & Vehicles", "Travel & Events", "Gaming", "Nonprofits & Activism", "Shows")
                           )
               # textInput("channel_name", "Channel name contains (e.g., Music)"),
               # textInput("title", "Title contains (e.g. Trump)")
             ),
             wellPanel(
               sliderInput("bins", "Number of bins:", min = 1, max = 50, value = 10),
               selectInput("var_hp", "Variable name:", c("Views", "Likes", "Dislikes", "Comment_count"))
             )
       ),
      column(9,
             wellPanel(
               plotlyOutput("HisPlot"),
               verbatimTextOutput("dateRangeText")
             )
      )
    )
  ),
  tabPanel("Bar Plot",
    fluidRow(theme = shinytheme("lumen"),
             column(3,
               wellPanel(
               selectInput("var_BP", "Variable:",
                           c("Title", "Channel_Title", "Category", "Publish_Moment")
                  
               ),
               sliderInput("top_BP", "Number of bars:", min = 1, max = 20, value = 5),
               sliderInput("diffday", "Number of days to achieve Trending",
                           min = 0, max = 100, value = 10)
             )
             )
             ,
             column(12,
               wellPanel(
               plotlyOutput("BarPlot")
             )
             )
             
    )
  ),
  # ###### HISTOGRAM
  # tabPanel("Histogram",
  #    fluidRow(theme = shinytheme("lumen"),
  #       column(3,
  #         wellPanel(
  #         sliderInput("bins", "Number of bins:", min = 1, max = 50, value = 10),
  #         selectInput("var_hp", "Variable name:", c("Views", "Likes", "Dislikes", "Comment_count"))
  #         )
  #       ),
  #             
  #       column(12,
  #         wellPanel(
  #            plotlyOutput("HisPlot")
  #         )
  #       )
  #       
  #       
  #       # column(3,
  #       #    wellPanel(
  #       #      h4("Histogram Plot"),
  #       #      selectInput("xvar_hp", "X-axis variable:",
  #       #                  c("category", "publish_moment")
  #       #      )
  #       #    )
  #       # ),
  #       # column(12,
  #       #        wellPanel(
  #       #          plotOutput("hisPlot")
  #       #        )
  #       # )
  #    )
  # ),
  tabPanel("Time Series Analysis",
     fluidRow(theme = shinytheme("lumen"),
        column(3,
           wellPanel(
             numericInput('clusters', 'Which Top Trending Video?', 3, min = 1, max = 10)
           )
        ),
        column(12,
               wellPanel(
                 plotlyOutput("TSPlot")
               )
        )
     )
  ),
  tabPanel("Sentiment Analysis",
     fluidRow(theme = shinytheme("lumen"),
              column(3,
                wellPanel(
                  selectInput("xvar_SA", "X-axis variable:", c("Polarity", "Subjectivity")),
                  selectInput("yvar_SA", "Y-axis variable:", c("Views", "Likes", "Ratio"))
                )
              ),
              column(12,
                wellPanel(
                  plotlyOutput("SentiPlot")
                )
              )
     )
  ),
  tabPanel("Dataset"
    
  ),
  tabPanel("About"
    
  )
)


