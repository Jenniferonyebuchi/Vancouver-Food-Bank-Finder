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
  
  