#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
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
CA_df <- read.csv(file = "./data/CA_nlp_df.csv")
GB_df <- read.csv(file = "./data/GB_nlp_df.csv")

US_unique_df = US_df[!duplicated(US_df$title), ]
US_unique_df$trending_date = as.Date(US_unique_df$trending_date, format = "%Y-%m-%d")

# Define a server for the Shiny app
function(input, output, session) {
  
  # Filter the movies, returning a data frame
  videos <- reactive({
    # Due to dplyr issue #318, we need temp variables for input values
    country <- input$country
    category <- input$category
    minday <- input$diffday[1]
    maxday <- input$diffday[2]

    # Apply filters
    m <- all_movies %>%
      filter(
        Reviews >= reviews,
        Oscars >= oscars,
        Year >= minyear,
        Year <= maxyear,
        BoxOffice >= minboxoffice,
        BoxOffice <= maxboxoffice
      ) %>%
      arrange(Oscars)
    
    # Optional: filter by genre
    if (input$genre != "All") {
      genre <- paste0("%", input$genre, "%")
      m <- m %>% filter(Genre %like% genre)
    }
    # Optional: filter by director
    if (!is.null(input$director) && input$director != "") {
      director <- paste0("%", input$director, "%")
      m <- m %>% filter(Director %like% director)
    }
    # Optional: filter by cast member
    if (!is.null(input$cast) && input$cast != "") {
      cast <- paste0("%", input$cast, "%")
      m <- m %>% filter(Cast %like% cast)
    }
  })
  
  output$HisPlot <- renderPlotly({
    #temp_df <- subset(US_unique_df, (trending_date < input$dateRange[2]) & (trending_date > input$dateRange[1]))
    temp_df <- US_unique_df
    
    if (input$category != "All"){
      temp_df = temp_df[temp_df$category == input$category, ]
    }
    
    # size of the bins depend on the input 'bins'
    maxx = max(US_df[, tolower(input$var_hp)])/(input$bins*5)
    minx = min(US_df[, tolower(input$var_hp)])
    size <- (maxx - minx) / input$bins
    
    # a simple histogram of movie ratings
    
    p <- plot_ly(temp_df, x = temp_df[, tolower(input$var_hp)], autobinx = F, type = "histogram",
                 xbins = list(start = minx, end = maxx, size = size))
    
    # style the xaxis
    layout(p, xaxis = list(title = input$var_hp, range = c(minx, maxx), autorange = F,
                           autotick = F, tick0 = minx, dtick = size))
  })
  
  #####
  output$BarPlot <- renderPlotly({
    
    sub_df = US_df[US_df$diff_days >= input$diffday, ]
    temp_data = data.frame(sort(table(sub_df[, tolower(input$var_BP)]), decreasing = TRUE))
    if (input$top_BP < nrow(temp_data)){
      temp_data = temp_data[1:(input$top_BP), ]
    }
    
    f <- list(
      family = "Courier New, monospace",
      size = 18,
      color = "#7f7f7f"
    )
    
    x <- list(
      title = input$var_BP,
      titlefont = f
    )
    y <- list(
      title = 'Frequency',
      titlefont = f
    )
    
    plot_ly(temp_data,  x= ~Var1, y=~Freq, type = 'bar', name = input$var_BP)   %>%
      layout(xaxis = x, yaxis = y)
  })
  
  output$SentiPlot <- renderPlotly({
    f <- list(
      family = "Courier New, monospace",
      size = 18,
      color = "#7f7f7f"
    )
    
    x <- list(
      title = input$xvar_SA,
      titlefont = f
    )
    y <- list(
      title = input$yvar_SA,
      titlefont = f
    )
    plot_ly(US_df, x = ~US_unique_df[,tolower(input$xvar_SA)], y = ~US_unique_df[, tolower(input$yvar_SA)])  %>%
      layout(xaxis = x, yaxis = y)
  })
  
  
  #### Time Series Plot
  output$TSPlot <- renderPlotly({
    title_df = data.frame(sort(table(US_df[, "title"]), decreasing = TRUE)[1:10])
    f <- list(
      family = "Courier New, monospace",
      size = 18,
      color = "#7f7f7f"
    )
    
    x <- list(
      title = as.character(title_df[input$clusters,1]),
      titlefont = f
    )
    y <- list(
      title = "Views",
      titlefont = f
    )
    
    #### Plot time series
    CK = US_df[US_df$title == as.character(title_df[input$clusters,1]), ] %>% select("views", "diff_days") 
    plot_ly(CK, x = ~diff_days, y = ~views, name = 'trace 0', type = 'scatter', mode = 'lines') %>%
      layout(xaxis = x, yaxis = y)
  })
  
  output$dateRangeText  <- renderText({
    paste("input$dateRange is", 
          paste(as.character(input$dateRange[2]))
    )
  })
}