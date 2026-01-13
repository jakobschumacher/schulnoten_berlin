library(tidyverse)
library(httr)
library(sf)
library(janitor)
library(rio)
library(stringr)


# Get map data ------------------------------------------------------------

# Following https://github.com/patperu/fisbroker_data

# Helper functions
get_X_Y_coordinates <- function(x) {
  sftype <- as.character(sf::st_geometry_type(x, by_geometry = FALSE))
  if(sftype == "POINT") {
    xy <- as.data.frame(sf::st_coordinates(x))
    dplyr::bind_cols(x, xy)
  } else {
    x
  }
}

# get map data function
get_school_mapdata <- function(url = "https://gdi.berlin.de/services/wfs/schulen") {
  # Build WFS request URL
  request_url <- httr::parse_url(url)
  request_url$query <- list(
    service = "WFS",
    version = "1.1.0",
    request = "GetFeature",
    typeName = "schulen:schulen",
    outputFormat = "json",
    srsName = "EPSG:4326"
  )
  request <- httr::build_url(request_url)

  # Read spatial data
  out <- sf::read_sf(request)

  # Extract coordinates
  out <- get_X_Y_coordinates(out)

  # Clean up columns - keep only relevant columns
  cols_to_keep <- c("bsn", "schulname", "schulart", "bezirk", "email", "internet", "geometry", "X", "Y")
  existing_cols <- intersect(cols_to_keep, names(out))
  out <- out %>% select(all_of(existing_cols))

  # Rename columns to match old format
  if ("schulname" %in% names(out)) out <- out %>% rename(name = schulname)
  if ("schulart" %in% names(out)) out <- out %>% rename(schultyp = schulart)
  if ("internet" %in% names(out)) out <- out %>% rename(website = internet)

  return(out)
}




# Lichtenberg -------------------------------------------------------------
get_school_grades_lichtenberg <- function(){
  # This function previously loaded historical Lichtenberg data from an Excel file
  # Since we're consolidating to CSV-only data handling, this function now returns
  # an empty data frame with the correct structure
  
  # Check if the Excel file exists (for backward compatibility)
  if (file.exists("data/bersichtaufnahmeinfoaneltern.xlsx")) {
    data <- rio::import("data/bersichtaufnahmeinfoaneltern.xlsx", skip = 1) %>% 
      select(!starts_with("...")) %>% 
      janitor::clean_names() %>% 
      pivot_longer(cols = starts_with("sj_"), names_to = "schuljahr", values_to = "note") %>% 
      mutate(schuljahr = str_extract(schuljahr, "\\\\d{4}")) %>% 
      mutate(note = str_extract(note, "\\\\d,\d")) %>% 
      mutate(note = as.numeric(str_replace(note, ",", "."))) %>% 
      rename("name" = "schulname") %>% 
      mutate(name = str_remove(name, pattern ="-Oberschule"))  %>% 
      mutate(name = str_remove(name, pattern ="-Schule")) %>% 
      mutate(name = str_replace(name, "Schule am Tierpark", "Schule-am-Tierpark")) %>% 
      mutate(name = str_replace(name, "11K13", "13. Schule")) %>% 
      mutate(name = str_replace(name, "11K14", "14. Schule"))
  } else {
    # Return empty data frame with correct structure
    # This maintains compatibility while avoiding hardcoded data
    data <- tibble(name = character(), note = numeric(), schuljahr = character())
    warning("Historical Lichtenberg data not available. Using 2025 data only.")
  }
  
  return(data)
}


# Lichtenberg 2025 --------------------------------------------------------
get_school_grades_lichtenberg_2025 <- function(){

  # Data from PDF: 2025lichtenberg.pdf
  # Admission data for school year 2025/2026
  # Now reading from CSV file instead of hardcoded values

  # Read from CSV file
  if (!file.exists("data/lichtenberg_2025_data.csv")) {
    stop("Required data file 'data/lichtenberg_2025_data.csv' not found. Please ensure the data file is present.")
  }

  read.csv("data/lichtenberg_2025_data.csv", stringsAsFactors = FALSE) %>% 
    mutate(name = str_remove(name, pattern = "-Gymnasium")) %>% 
    mutate(name = str_remove(name, pattern = "-Schule")) %>% 
    mutate(schuljahr = "2025")

}


# Pankow ------------------------------------------------------------------

get_school_grades_pankow <- function(){

  # Copy of Fragdenstaat-PDF ------------------------------------------------
  # https://fragdenstaat.de/anfrage/durchschnittsnote-als-aufnahmekriterium-fuer-weiterfuehrende-schulen-in-pankow/867674/anhang/antwort-anfrage-fragendenstaat-durchschnittsnoteanpankoweroberschulen.pdf

  pankow <- c("Heinz-Brandt-Schule", 1.5,
              "Carl-von-Ossietzky-Gymnasium", 1.0,
              "Kurt-Tucholsky-Schule", 1.8,
              "Felix-Mendelssohn-Bartholdy-Gymnasium", 1.4,
              "Konrad-Duden-Schule", 2.4,
              "Heinrich-Schliemann-Gymnasium", 1.4,
              "Kurt-Schwitters-Schule", 1.6,
              "Käthe-Kollwitz-Gymnasium", "Punktsumme 5",
              "Reinhold-Burger-Schule", 2.4,
              "Primo-Levi-Gymnasium", 1.2,
              "Hagenbeck-Schule", 2.5,
              "Max-Delbrück-Gymnasium", 1.4,
              "Wilhelm-von-Humboldt-Schule", "ohne Note",
              "Rosa-Luxemburg-Gymnasium", "Punktsumme 10-8",
              "Janusz-Korczak-Schule", 2.7,
              "Robert-Havemann-Gymnasium", "ohne Note",
              "Tesla-Schule", "ohne Note",
              "Gymnasium am Europasportpark", "ohne Note",
              "Hufeland-Schule", "ohne Note",
              "Gustave-Eiffel-Schule", "ohne Note")

  # Change to tibble
  matrix(pankow, nrow = 20, ncol = 2, byrow = T) %>%
    as_tibble() %>%
    rename("name" = "V1", note = "V2") %>%
    mutate(name = str_remove(name, pattern ="-Gymnasium"))  %>%
    mutate(name = str_remove(name, pattern ="-Schule"))

}

# Pankow 2024 ------------------------------------------------------------------
get_school_grades_pankow_2024 <- function(){
  
# Pankow 2024 ------------------------------------------------------------------
get_school_grades_pankow_2024 <- function(){
  
  # Read CSV data from pankow_2024.pdf extraction
  if (!file.exists("data/pankow_2024_data.csv")) {
    stop("Required data file 'data/pankow_2024_data.csv' not found. Please ensure the data file is present.")
  }

  pankow_2024 <- read.csv("data/pankow_2024_data.csv", stringsAsFactors = FALSE) %>% 
    rename(note = aufnahme_kriterium) %>% 
    mutate(name = str_remove(name, "-Gymnasium"))  %>% 
    mutate(name = str_remove(name, "-Schule")) %>% 
    mutate(name = str_remove(name, "-GemS")) %>% 
    mutate(name = str_remove(name, " Engl\\.")) %>% 
    mutate(name = str_remove(name, " Franz\\.")) %>% 
    mutate(schuljahr = as.character(schuljahr))

  return(pankow_2024)

}

  return(pankow_2024)

}




# Consolidated data loading function --------------------------------------------
# This function provides a unified interface for loading all school data
get_all_school_data <- function() {
  
  # Load map data (school locations)
  map_data <- get_school_mapdata()
  
  # Load Pankow 2023 data
  if (!file.exists("data/pankow_2023_data.csv")) {
    stop("Required data file 'data/pankow_2023_data.csv' not found.")
  }
  pankow_2023 <- read.csv("data/pankow_2023_data.csv", stringsAsFactors = FALSE) %>%
    mutate(bezirk = "Pankow", schuljahr = "2023")
  
  # Load Pankow 2024/2025 data
  if (!file.exists("data/pankow_2024_data.csv")) {
    stop("Required data file 'data/pankow_2024_data.csv' not found.")
  }
  pankow_2024_2025 <- get_school_grades_pankow_2024()  # Uses existing function
  
  # Load Lichtenberg 2025 data
  if (!file.exists("data/lichtenberg_2025_data.csv")) {
    stop("Required data file 'data/lichtenberg_2025_data.csv' not found.")
  }
  lichtenberg_2025 <- get_school_grades_lichtenberg_2025()  # Uses existing function
  
  # Combine all data
  all_data <- bind_rows(
    pankow_2023,
    pankow_2024_2025,
    lichtenberg_2025
  )
  
  # Join with map data to add coordinates
  if ("name" %in% names(map_data) && "name" %in% names(all_data)) {
    all_data <- left_join(all_data, 
                         map_data %>% select(name, lon = X, lat = Y, schultyp, website), 
                         by = "name")
  }
  
  return(all_data)
}

# Helper function to get data for a specific district and year
get_school_data <- function(bezirk = NULL, schuljahr = NULL) {
  all_data <- get_all_school_data()
  
  # Filter by district if specified
  if (!is.null(bezirk)) {
    all_data <- all_data %>% filter(bezirk == bezirk)
  }
  
  # Filter by year if specified
  if (!is.null(schuljahr)) {
    all_data <- all_data %>% filter(schuljahr == schuljahr)
  }
  
  return(all_data)
}