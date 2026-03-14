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