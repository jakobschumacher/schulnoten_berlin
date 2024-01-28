library(tidyverse)


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



