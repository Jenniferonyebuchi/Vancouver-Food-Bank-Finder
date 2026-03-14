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
    
    