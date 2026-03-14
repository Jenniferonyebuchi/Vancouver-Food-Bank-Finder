# Vancouver Food Bank Finder

A central resource to help Vancouver residents find accessible food options near them.

## Overview

The **Vancouver Food Bank Finder** is an interactive Shiny dashboard that allows residents and community workers to explore food assistance programs across Vancouver. Using an interactive map and filters, users can quickly identify programs that match their needs — whether that's free meals, hamper pickup, delivery, or wheelchair-accessible locations.

## Features

- **Interactive Map** — Visualizes all food program locations across Vancouver. Click a marker to view program details.
- **Program Details Panel** — Displays the program name, description, organization, address, meal cost, and service availability for the selected location.
- **Contact Information Panel** — Shows signup email and phone number for the selected program.
- **Summary Statistics** — At-a-glance value boxes showing:
  - Total number of filtered locations
  - Percentage of programs with free meals
  - Percentage of wheelchair-accessible locations
- **Filters (Sidebar)**:
  - **Meal Cost** — Filter by cost category (e.g., Free, Low cost)
  - **Local Area** — Filter by one or more Vancouver neighbourhoods
  - **Features** — Filter by service type: Delivery Available, Provides Hampers, Takeout Available, Wheelchair Accessible

## Data

The app uses `data/food_program_data.csv`, a semicolon-delimited dataset of Vancouver food programs containing fields such as program name, organization, address, local area, meal/hamper availability, accessibility, coordinates, and contact details.

## Getting Started

### Prerequisites

- R (≥ 4.1)
- The following R packages: `shiny`, `bslib`, `dplyr`, `tidyr`, `jsonlite`, `leaflet`, `scales`

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/YOUR_USERNAME/Vancouver-Food-Bank-Finder.git
   cd Vancouver-Food-Bank-Finder
   ```

2. Restore the R environment using renv:
   ```r
   renv::restore()
   ```

3. Run the app:
   ```r
   shiny::runApp("src/app.R")
   ```
   Or from the terminal:
   ```bash
   Rscript -e 'shiny::runApp("src/app.R")'
   ```

## Project Structure

```
Vancouver-Food-Bank-Finder/
├── data/
│   └── food_program_data.csv   # Food program dataset
├── renv/                        # renv environment files
├── src/
│   └── app.R                   # Main Shiny application
└── README.md
```

## Author

**Jennifer Ezinne Onyebuchi** — Last Updated: 2026-03-14

## License

This project is licensed under the terms of the [LICENSE](LICENSE) file included in this repository.
