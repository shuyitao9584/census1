library(shiny)
library(ggplot2)
library(dplyr)

# user interface
ui <- fluidPage(
  titlePanel("USA Census Visulaization"),
  sidebarLayout(
    sidebarPanel(
      helpText("Create demographic maps with information from the 2010 Census"),
      selectInput(inputId = "var",
                  label = "Race",
                  choices = list("Percent White", 
                                 "Percent Black", 
                                 "Percent Hispanic", 
                                 "Percent Asian"),
                  selected = "Percent White")
    ),
    mainPanel(
      textOutput(outputId = "selected_var"),
      plotOutput(outputId = "map")
    )
  )
)

# server

server <- function(input, output){
  
  #output$selected_var = renderText(
    #paste("You have selected", input$var)

  output$map = renderPlot({
    
    counties <- reactive({
      race = readRDS("censusVis/data/counties.rds")
      
      counties_map = map_data("county")
      
      counties_map = counties_map %>%
        mutate(name = paste(region, subregion, sep = ","))
      
      counties = left_join(counties_map, race, by = "name")
    })
    
    myrace = switch(input$var,
                    "Percent White" = counties()$white,
                    "Percent Black" = counties()$black,
                    "Percent Hispanic" = counties()$hispanic,
                    "Percent Asian" = counties()$asian)
    
  ggplot(counties(), aes(x = long, 
                       y = lat,
                       group = group,
                       fill = myrace)) +
    geom_polygon() +
    scale_fill_gradient(low = "white", high = "darkred") +
    theme_void()
  })
}

# Error: Operation not allowed without an active reactive context. 
# (You tried to do something that can only be done from inside a reactive expression 
# or observer.)
# It means that anytime I wanna use the data, it should be reactive. Add reactive

shinyApp(ui, server)