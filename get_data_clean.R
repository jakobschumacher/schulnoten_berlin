#' Functions to load and process school data from consolidated CSV
#' 
#' This file provides functions to read and process school admission data
#' from the unified data.csv file in the data/ directory.

# Get map data ------------------------------------------------------------

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
  out <- out |>
    dplyr::select(dplyr::all_of(existing_cols))

  # Rename columns to match old format
  if ("schulname" %in% names(out)) out <- out |> dplyr::rename(name = schulname)
  if ("schulart" %in% names(out)) out <- out |> dplyr::rename(schultyp = schulart)
  if ("internet" %in% names(out)) out <- out |> dplyr::rename(website = internet)

  return(out)
}

# Main function to load and process all school data from CSV
get_school_data <- function() {
  # Read the consolidated CSV file
  if (!file.exists("data/data.csv")) {
    stop("data.csv not found in data/ directory")
  }

  data <- read.csv("data/data.csv", stringsAsFactors = FALSE) |>
    # Clean up school names by removing common suffixes
    dplyr::mutate(name = stringr::str_remove_all(name, " Integrierte Sekundarschule")) |>
    dplyr::mutate(name = stringr::str_remove_all(name, " Gemeinschaftsschule")) |>
    # Be careful with -Schule removal to preserve names like "May-Ayim-Schule"
    dplyr::mutate(name = ifelse(
      grepl("^[0-9]{1,2} Schule$", name),  # Keep "13. Schule", "14. Schule"
      name,
      stringr::str_remove(name, "-Schule$")
    )) |>
    dplyr::mutate(name = stringr::str_remove_all(name, "-Gemeinschaftsschule")) |>
    dplyr::mutate(name = stringr::str_remove_all(name, "-Gymnasium")) |>
    dplyr::mutate(name = stringr::str_remove_all(name, "-Oberschule")) |>
    
    # Standardize "ohne Note" variations
    dplyr::mutate(note = ifelse(note == "ohne Note" | 
                        note == "alle" | 
                        note == "**" | 
                        grepl("nicht übernachgefragt", note), "ohne Note", note)) |>
    
    # Clean up special cases
    dplyr::mutate(name = stringr::str_replace(name, "Schule am Tierpark", "Schule-am-Tierpark")) |>
    dplyr::mutate(name = stringr::str_replace(name, "11K13", "13. Schule")) |>
    dplyr::mutate(name = stringr::str_replace(name, "11K14", "14. Schule"))

  return(data)
}

# Function to create summary data for visualization
create_school_summary <- function(school_data) {
  school_data |>
    dplyr::arrange(name, schuljahr) |>
    dplyr::group_by(name, bezirk) |>
    dplyr::summarise(
      note_years = paste(schuljahr, ":", note, collapse = " | "),
      latest_note = dplyr::last(note),
      schul_nr = dplyr::last(schul_nr),
      .groups = "drop"
    )
}

# Function to get the latest year for each school
get_latest_year <- function(school_data) {
  school_data |>
    dplyr::group_by(name) |>
    dplyr::summarise(latest_year = max(schuljahr, na.rm = TRUE)) |>
    dplyr::ungroup()
}
