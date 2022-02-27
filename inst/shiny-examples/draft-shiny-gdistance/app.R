#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(magrittr)
library(dplyr)
library(tidyr)
library(kableExtra)
library(shinybusy)

places <- c(
  '4 Gungaroo Pl, Beverly Hills NSW 2209, Australia',
  '71 Broome St, Maroubra NSW 2035, Australia',
  '37 St Pauls Cres, Liverpool NSW 2170, Australia',
  '6 Darley St, Newtown NSW 2042, Australia',
  '6 Amalfi Dr, Wentworth Point NSW 2127, Australia'
)



# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("Toll or roll?"),
  wellPanel(
    fluidRow(
      column(6, 
             selectInput('origin', label =  'Origin', choices = places)
      ),
      column(6, 
             selectInput('destination', label  = 'Destination', choices = rev(places))
      )
    )
  ),
  wellPanel(
    fluidRow(
      column(12, 
             actionButton('get_distance', label = 'Get distances and travel time', width = '100%')
      ),
    )
  ),
  add_busy_spinner(spin = "fading-circle"),
  fluidRow(
    column(6, 
           wellPanel(
             selectInput('fuel_mileage', label  = 'Estimate fuel mileage',
                         choices = c(
                           'low - 6.4 km / km' = 0.064, 
                           'average - 11.1 km / 100 km' = 0.111,
                           'high - 14 km / 100km' = 0.14)
             )
           )
    ),
    column(6, 
           wellPanel(
             selectInput('toll_cost', label  = 'Toll cost',
                         choices = c(
                           'M5 - $4.50' = 4.5,
                           'M5 east - $3.5' = 3.5
                         )
             )
           )
    )
  ),
  fluidRow(
    column(12, 
           uiOutput('calculation_result_div')
    ),
  )
  #,verbatimTextOutput('get_distance_result')
)


# Define server logic required to draw a histogram
server <- function(input, output) {
  
  get_distances_result <- reactive({
    
    # result <- readRDS('single_get_distances_result.rds')
    # noToll <- wrangle_distances(result)
    # 
    # result <- readRDS('single_get_distances_result.rds')
    # toll <-wrangle_distances(result)
    
    # result <-
    #   readRDS('flat_multiple_get_distances_result.rds') %>% 
    #   filter(origin == input$origin & destination == input$destination)
    
    result_list <- get_distances(origins = input$origin, destinations = input$destination)
    
    result <-
      result_list %>% 
      wrangle_distances()
    
    result %>% 
      .[c(1,1),] %>% 
      mutate(toll = c(F,T),
             distance = distance * c(1, 0.85),
             duration = duration * c(1, 0.85))
    
  }) %>% 
    bindEvent(input$get_distance)
  
  output$get_distance_result <- renderPrint({
    get_distances_result()
  })
  
  calculation_result <- reactive({
    
    #toll_cost = 4.50;fuel_cost=0.111
    fuel_cost <- as.numeric(input$fuel_mileage)
    toll_cost <- as.numeric(input$toll_cost)
    
    
    get_distances_result() %>%
      #result %>%
      mutate(fuel_cost = distance * fuel_cost,
             toll_cost = toll_cost * toll,
             total_cost = fuel_cost + toll_cost) %>%
      select(distance, duration, fuel_cost, toll_cost, total_cost,toll) %>%
      pivot_longer(cols = -toll) %>%
      mutate(value = round(value, 2)) %>% 
      pivot_wider(values_from = value, names_from = toll) %>%
      mutate(diff = `TRUE` - `FALSE`) %>%
      mutate(name = c(
        'Distance (km)',
        'travel time (mins)',
        'Fuel cost ($)',
        'Toll cost ($)',
        'Total cost ($)'
      )) %>%
      setNames(c('Variable', 'Toll', 'No toll', 'With toll'))
    
  })
  
  output$calculation_result_div <- renderPrint({
    
    result_kable <-
      calculation_result() %>% 
      kable(align = c('r')) %>% 
      #kable_paper() %>% 
      kable_styling(bootstrap_options = c('bordered', 'hover', 'condensed'),
                    full_width = FALSE) %>% 
      row_spec(0, align = 'c') %>% 
      column_spec(4, color = "white",
                  background = spec_color(calculation_result()$`With toll`, 
                                          direction = -1,
                                          end = 0.7),
                  popover = 'popup text') %>% 
      HTML()
    
    # as.character if textOutput
    withTags({
      tagList(
        h3('Results'),
        p(style = 'text-align:center',
          strong(get_distances_result()[['origin']][1]),
          br(), 'to', br(),
          strong(get_distances_result()[['destination']][1])
        ),
        result_kable
      ) 
    })
    
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
