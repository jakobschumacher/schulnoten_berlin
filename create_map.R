


# Read in data ------------------------------------------------------------

source("get_school_results.R")
pankow <- get_school_grades_pankow() %>% rename(note_pankow = note)
lichtenberg <- get_school_grades_lichtenberg() %>%
  filter(schuljahr == "2023") %>%
  mutate(note = ifelse(is.na(note), "ohne Note", note))


source("get_schools_from_fis_broker.R")
schuldaten <- schulen %>%
  rename(lon = X, lat = Y) %>%
  filter(schultyp %in% c("Integrierte Sekundarschule", "Gymnasium")) %>%
  mutate(name = str_remove(name, pattern =" \\(Integrierte Sekundarschule\\)")) %>%
  mutate(name = str_remove(name, pattern =" \\(Gemeinschaftsschule\\)")) %>%
  mutate(name = str_remove(name, pattern ="-Schule")) %>%
  mutate(name = str_remove(name, pattern ="-Gemeinschaftsschule")) %>%
  mutate(name = str_remove(name, pattern ="-Gymnasium"))











# Join datasets -----------------------------------------------------------

# find_missings in schuldaten for Pankow
# schuldaten %>%
#   full_join(pankow, by = join_by(name)) %>%
#   filter(is.na(schulart)) %>%
#   select(name)
#
# schuldaten %>% filter(bezirk == "Pankow") %>% select(name)



# Do the join
df <- schuldaten %>%
  filter(bezirk == "Pankow" | bezirk == "Lichtenberg") %>%
  select(name, schultyp, bezirk, lon, lat) %>%
  full_join(lichtenberg, by = join_by(name)) %>%
  rename(note_lichtenberg = note) %>%
  full_join(pankow, by = join_by(name)) %>%
  mutate(note = ifelse(bezirk == "Pankow", note_pankow, NA))  %>%
  mutate(note = ifelse(bezirk == "Lichtenberg", note_lichtenberg, note)) %>%
  mutate(gruppe = "note-vorhanden") %>%
  mutate(gruppe = ifelse(note=="ohne Note", "ohne-note", gruppe)) %>%
  mutate(gruppe = ifelse(is.na(note), "keine-daten", gruppe)) %>%
  mutate(note = ifelse(is.na(note), "keine daten", note))



pal <- colorFactor(c('black', 'darkred', 'darkgreen'),
                   domain =c("note-vorhanden", "ohne-note", "keine-daten"))

rr <- tags$div(
  HTML('<b>Warnhinweise:</b><br>
  Es kann keine Haftung übernommen werden. Bitte alle Daten kontrollieren!<br>
  <b>Datenquelle:</b> <br>
       Lichtenberg: <a href="https://fragdenstaat.de/a/297001">Schulamt über Fragdenstaat.de</a><br>
       Pankow: <a href="https://fragdenstaat.de/a/296999">Schulamt über Fragdenstaat.de</a>')
)



  leaflet() %>%
    addTiles() %>%
    setView(lng = 13.48, lat = 52.56, zoom = 12) %>%
    addCircleMarkers(
      lng = df$lon,
      lat = df$lat,
      color = pal(df$gruppe),
      radius = 8,
      label = paste("Schule:", df$name, "- Note:", df$note)
    ) %>%
    addControl(rr, position = "bottomleft")

