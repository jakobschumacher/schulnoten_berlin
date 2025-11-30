library(tidyverse)
library(httr)
library(sf)


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
get_school_mapdata <- function(url = "https://fbinter.stadt-berlin.de/fb/wfs/data/senstadt/s_schulen") {
  typenames <- basename(url)
  url <- httr::parse_url(url)
  url$query <- list(service = "wfs",
                    version = "2.0.0",
                    request = "GetFeature",
                    srsName = "EPSG:25833",
                    TYPENAMES = typenames)
  request <- httr::build_url(url)
  out <- sf::read_sf(request)
  out <- sf::st_transform(out, 4326)
  out <- get_X_Y_coordinates(out)
  out <- out %>% select(-fax, -email, -telefon)
  return(out)
}



# Lichtenberg -------------------------------------------------------------
get_school_grades_lichtenberg <- function(){
url <- "https://fragdenstaat.de/anfrage/durchschnittsnote-als-aufnahmekriterium-fuer-weiterfuehrende-schulen-in-lichtenberg/866253/anhang/bersichtaufnahmeinfoaneltern.xlsx"

data <- rio::import("bersichtaufnahmeinfoaneltern.xlsx", skip = 1) %>%
  select(!starts_with("...")) %>%
  janitor::clean_names() %>%
  pivot_longer(cols = starts_with("sj_"), names_to = "schuljahr", values_to = "note") %>%
  mutate(schuljahr = str_extract(schuljahr, "\\d{4}")) %>%
  mutate(note = str_extract(note, "\\d,\\d")) %>%
  mutate(note = as.numeric(str_replace(note, ",", "."))) %>%
  rename("name" = "schulname") %>%
  mutate(name = str_remove(name, pattern ="-Oberschule"))  %>%
  mutate(name = str_remove(name, pattern ="-Schule")) %>%
  mutate(name = str_replace(name, "Schule am Tierpark", "Schule-am-Tierpark")) %>%
  mutate(name = str_replace(name, "11K13", "13. Schule")) %>%
  mutate(name = str_replace(name, "11K14", "14. Schule"))

}


# Lichtenberg 2025 --------------------------------------------------------
get_school_grades_lichtenberg_2025 <- function(){

  # Data from PDF: 2025lichtenberg.pdf
  # Admission data for school year 2025/2026

  lichtenberg_2025 <- c(
    "11K01", "Alexander-Puschkin-Schule", 2.0,
    "11K02", "Mildred-Harnack-Schule", 2.4,
    "11K04", "Gutenberg-Schule", 1.5,
    "11K05", "Fritz-Reuter-Schule", 2.2,
    "11K06", "Schule am Rathaus", "ohne Note",
    "11K07", "Vincent-van-Gogh-Schule", "ohne Note",
    "11K08", "Schule am Tierpark", "ohne Note",
    "11K09", "Philipp-Reis-Schule", "ohne Note",
    "11K10", "Grüner Campus Malchow", "ohne Note",
    "11K11", "Paul-Schmidt-Schule", "ohne Note",
    "11K12", "Paul-und-Charlotte-Kniese-Schule", "ohne Note",
    "11K13", "13. Schule", "ohne Note",
    "11K14", "14. Schule", "ohne Note",
    "11K15", "May-Ayim-Schule", 2.2,
    "11K16", "Sekundarschule Falkenberger Chaussee", "ohne Note",
    "11Y02", "Johann-Gottfried-Herder-Gymnasium", 1.4,
    "11Y05", "Hans-und-Hilde-Coppi-Gymnasium", "ohne Note",
    "11Y09", "Barnim-Gymnasium", 1.4,
    "11Y10", "Manfred-von-Ardenne-Gymnasium", "ohne Note",
    "11Y11", "Immanuel-Kant-Gymnasium", 1.2,
    "11Y12", "Gymnasium Allee der Kosmonauten", "ohne Note"
  )

  # Change to tibble
  matrix(lichtenberg_2025, nrow = 21, ncol = 3, byrow = T) %>%
    as_tibble() %>%
    rename("schul_nr" = "V1", "name" = "V2", "note" = "V3") %>%
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



