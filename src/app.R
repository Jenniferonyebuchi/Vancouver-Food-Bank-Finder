#load required libraries
library(shiny)
library(bslib)
library(dplyr)
library(jsonlite)
library(tidyr)
library(leaflet)

# Read in the food program data
food_bank <- read.csv("../data/food_program_data.csv", sep=";", fill = TRUE, header = TRUE)
# Normalize names to snake_case to match app code (e.g., Program Name -> program_name)
names(food_bank) <- names(food_bank) |>
  tolower() |>
  gsub("[^a-z0-9]+", "_", x = _) |>
  gsub("^_|_$", "", x = _)

head(food_bank)

meal_cost_choices <- c("All", sort(unique(na.omit(as.character(food_bank$meal_cost)))))
area_choices      <- sort(unique(na.omit(as.character(food_bank$local_areas))))

# --- UI ---
ui <- page_fillable(
  tags$head(tags$style(HTML("
    .value-box-title { font-size: 0.85rem; }
    .detail-card p { margin-bottom: 0.4rem; }
  "))),
  
  layout_sidebar(
    sidebar = sidebar(
      tags$h4("Vancouver Food Programs"),
      tags$hr(),
      selectInput("meal_cost", "Meal Cost", choices = meal_cost_choices, selected = "All"),
      tags$hr(),
      selectizeInput("area", "Local Area", choices = area_choices, multiple = TRUE),
      tags$hr(),
      checkboxGroupInput(
        "features", "Features",
        choices = c(
          "Delivery Available",
          "Provides Hampers",
          "Takeout Available",
          "Wheelchair Accessible"
        )
      ),
      open = "desktop"
    ),
    
    layout_columns(
      value_box("Total Locations",    textOutput("total_locations"),   theme = "primary"),
      value_box("Free Programs (%)",  textOutput("free_prop"),         theme = "success"),
      value_box("Accessibility (%)",  textOutput("accessibility_prop"), theme = "info"),
      fill = FALSE
    ),
    
    layout_columns(
      card(
        card_header("Location Map"),
        leafletOutput("map", height = "500px"),
        full_screen = TRUE
      ),
      layout_columns(
        card(
          card_header("Program Details"),
          uiOutput("selected_details"),
          full_screen = TRUE
        ),
        card(
          card_header("Contact Information"),
          uiOutput("contact_info"),
          full_screen = TRUE
        ),
        col_widths = 12
      ),
      col_widths = c(8, 4)
    )
  )
)

# --- Server ---
server <- function(input, output, session) {
  
  selected_row <- reactiveVal(NULL)
  
  filtered_df <- reactive({
    dff <- food_bank %>% drop_na(latitude, longitude)
    
    if (input$meal_cost != "All") {
      dff <- dff %>% filter(as.character(meal_cost) == input$meal_cost)
    }
    
    if (length(input$area) > 0) {
      dff <- dff %>% filter(as.character(local_areas) %in% input$area)
    }
    
    feats <- input$features
    
    if ("Delivery Available" %in% feats) {
      dff <- dff %>% filter(tolower(as.character(delivery_available)) == "yes")
    }
    if ("Provides Hampers" %in% feats) {
      dff <- dff %>% filter(tolower(as.character(provides_hampers)) == "true")
    }
    if ("Takeout Available" %in% feats) {
      dff <- dff %>% filter(tolower(as.character(takeout_available)) == "yes")
    }
    if ("Wheelchair Accessible" %in% feats) {
      dff <- dff %>% filter(tolower(as.character(wheelchair_accessible)) == "yes")
    }
    
    dff
  })
  
  output$total_locations <- renderText({
    nrow(filtered_df())
  })
  
  output$free_prop <- renderText({
    dff <- filtered_df()
    if (nrow(dff) == 0) return("0%")
    pct <- mean(tolower(as.character(dff$meal_cost)) == "free", na.rm = TRUE)
    scales::percent(pct, accuracy = 0.1)
  })
  
  output$accessibility_prop <- renderText({
    dff <- filtered_df()
    if (nrow(dff) == 0) return("0%")
    pct <- mean(tolower(as.character(dff$wheelchair_accessible)) == "yes", na.rm = TRUE)
    scales::percent(pct, accuracy = 0.1)
  })
  
  output$map <- renderLeaflet({
    dff <- filtered_df()
    
    m <- leaflet(dff) %>%
      addTiles() %>%
      setView(lng = -123.1207, lat = 49.2827, zoom = 12)
    
    if (nrow(dff) > 0) {
      m <- m %>%
        addMarkers(
          lng        = ~as.numeric(longitude),
          lat        = ~as.numeric(latitude),
          label      = ~as.character(program_name),
          layerId    = ~as.character(row.names(dff))  # unique id per marker
        )
    }
    
    m
  })
  
  # Capture marker clicks
  observeEvent(input$map_marker_click, {
    click <- input$map_marker_click
    row_id <- click$id
    dff <- filtered_df()
    row <- dff[row.names(dff) == row_id, ]
    if (nrow(row) > 0) selected_row(as.list(row[1, ]))
  })
  
  safe_val <- function(row, key) {
    val <- row[[key]]
    if (is.null(val) || (length(val) == 1 && is.na(val))) return("Not available")
    as.character(val)
  }
  
  output$selected_details <- renderUI({
    row <- selected_row()
    if (is.null(row)) return(p("Select a location on the map to view program details."))
    
    