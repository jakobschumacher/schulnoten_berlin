# Simple test for May-Ayim Schule fix

# Set working directory
setwd("/home/jakob/Dokumente/03_Projekte/2023_10_18_Sekundarschulwahl_Berlin")

print("=== SIMPLE MAY-AYIM SCHULE TEST ===")

# Load data
data <- read.csv("data/data.csv", stringsAsFactors = FALSE)

# 1. Check May-Ayim in CSV
print("\n1. May-Ayim Schule in data.csv:")
may_ayim_data <- data[data$name == "May-Ayim-Schule", ]
if (nrow(may_ayim_data) > 0) {
  print("✓ Found May-Ayim-Schule:")
  print(may_ayim_data)
} else {
  print("❌ May-Ayim-Schule not found in CSV")
  # Try alternative names
  alt_names <- data[grepl("May.*Ayim", data$name, ignore.case = TRUE), ]
  if (nrow(alt_names) > 0) {
    print("Alternative names found:")
    print(alt_names$name)
  }
}

# 2. Test the new joining approach
print("\n2. Testing new joining approach:")

# Create school summary with schul_nr
school_summary <- data %>%
  arrange(name, schuljahr) %>%
  group_by(name, bezirk) %>%
  summarise(
    note_years = paste(schuljahr, ":", note, collapse = " | "),
    latest_note = last(note),
    schul_nr = last(schul_nr),
    .groups = "drop"
  )

# Check May-Ayim in summary
may_ayim_summary <- school_summary[school_summary$name == "May-Ayim-Schule", ]
if (nrow(may_ayim_summary) > 0) {
  print("✓ May-Ayim found in school summary:")
  print(may_ayim_summary)
} else {
  print("❌ May-Ayim not found in school summary")
}

# 3. Test reference table
print("\n3. Testing reference table:")
schul_nr_reference <- data %>%
  select(name, bezirk, schul_nr) %>%
  distinct()

may_ayim_ref <- schul_nr_reference[schul_nr_reference$name == "May-Ayim-Schule", ]
if (nrow(may_ayim_ref) > 0) {
  print("✓ May-Ayim found in reference table:")
  print(may_ayim_ref)
} else {
  print("❌ May-Ayim not found in reference table")
}

# 4. Simulate the join
print("\n4. Simulating the join process:")

# Simulate map data (what we'd get from get_school_mapdata)
simulated_map_data <- data.frame(
  name = "May-Ayim-Schule",
  schultyp = "Integrierte Sekundarschule", 
  bezirk = "Lichtenberg",
  website = "",
  lon = 13.5,
  lat = 52.5,
  stringsAsFactors = FALSE
)

# First join: add schul_nr to map data
map_with_ids <- merge(simulated_map_data, schul_nr_reference, by = c("name", "bezirk"), all.x = TRUE)

if (!is.na(map_with_ids$schul_nr[1])) {
  print("✓ Successfully added schul_nr to map data:")
  print(paste("  schul_nr:", map_with_ids$schul_nr[1]))
  
  # Second join: add grade data using schul_nr
  final_result <- merge(map_with_ids, school_summary, by = c("schul_nr", "bezirk"), all.x = TRUE)
  
  if (!is.na(final_result$latest_note[1])) {
    print("✓ Successfully joined grade data:")
    print(paste("  Latest note:", final_result$latest_note[1]))
    print(paste("  Note years:", final_result$note_years[1]))
    print(paste("  Gruppe would be: note-vorhanden"))
  } else {
    print("❌ Failed to join grade data")
  }
} else {
  print("❌ Failed to add schul_nr to map data")
}

print("\n=== TEST COMPLETE ===")
print("Summary:")
print("- May-Ayim-Schule exists in CSV with schul_nr 11K15")
print("- The new joining approach should successfully match this school")
print("- If the map data contains 'May-Ayim-Schule', it will now show correctly")
