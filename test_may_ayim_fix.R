# Test script to verify May-Ayim Schule fix

# Set working directory
setwd("/home/jakob/Dokumente/03_Projekte/2023_10_18_Sekundarschulwahl_Berlin")

print("=== TESTING MAY-AYIM SCHULE FIX ===")

# Load data
data <- read.csv("data/data.csv", stringsAsFactors = FALSE)

# Test the new joining logic
print("\n1. Checking May-Ayim Schule in CSV data:")
may_ayim_csv <- data[grepl("May-Ayim", data$name), ]
if (nrow(may_ayim_csv) > 0) {
  print("Found in CSV:")
  print(may_ayim_csv)
  print(paste("School ID:", may_ayim_csv$schul_nr[1]))
} else {
  print("❌ Not found in CSV")
}

# Test the name cleaning process
print("\n2. Testing name cleaning process:")
original_name <- "May-Ayim-Schule"
cleaned_name <- original_name

# Apply the same cleaning logic as in get_data.R
cleaned_name <- str_remove_all(cleaned_name, " \(Integrierte Sekundarschule\)")
cleaned_name <- str_remove_all(cleaned_name, " \(Gemeinschaftsschule")

# Be careful with -Schule removal
if (!grepl("^\d{1,2}\. Schule$", cleaned_name)) {
  cleaned_name <- str_remove(cleaned_name, "-Schule$")
}

cleaned_name <- str_remove_all(cleaned_name, "-Gemeinschaftsschule")
cleaned_name <- str_remove_all(cleaned_name, "-Gymnasium")
cleaned_name <- str_remove_all(cleaned_name, "-Oberschule")

print(paste("Original name: 'May-Ayim-Schule'"))
print(paste("Cleaned name: '", cleaned_name, "'", sep = ""))

if (cleaned_name == "May-Ayim-Schule") {
  print("✓ Name preserved correctly")
} else {
  print(paste("❌ Name changed to:", cleaned_name))
}

# Test the joining logic
print("\n3. Testing joining logic:")

# Simulate the reference table
schul_nr_reference <- data %>%
  select(name, bezirk, schul_nr) %>%
  distinct()

# Check if May-Ayim is in the reference
may_ayim_ref <- schul_nr_reference[grepl("May-Ayim", schul_nr_reference$name), ]
if (nrow(may_ayim_ref) > 0) {
  print("✓ May-Ayim found in reference table:")
  print(may_ayim_ref)
} else {
  print("❌ May-Ayim NOT found in reference table")
}

# Test the school summary creation
print("\n4. Testing school summary creation:")
school_summary <- data %>%
  arrange(name, schuljahr) %>%
  group_by(name, bezirk) %>%
  summarise(
    note_years = paste(schuljahr, ":", note, collapse = " | "),
    latest_note = last(note),
    schul_nr = last(schul_nr),
    .groups = "drop"
  )

may_ayim_summary <- school_summary[grepl("May-Ayim", school_summary$name), ]
if (nrow(may_ayim_summary) > 0) {
  print("✓ May-Ayim found in school summary:")
  print(may_ayim_summary)
} else {
  print("❌ May-Ayim NOT found in school summary")
}

# Test the final join
print("\n5. Testing final join logic:")

# Simulate map data with May-Ayim
simulated_map_data <- data.frame(
  name = "May-Ayim-Schule",
  schultyp = "Integrierte Sekundarschule",
  bezirk = "Lichtenberg",
  website = "",
  lon = 13.5,
  lat = 52.5,
  schul_nr = "11K15",  # This should match from the reference
  stringsAsFactors = FALSE
)

# Test the join
final_join_test <- simulated_map_data %>%
  left_join(school_summary, by = c("schul_nr", "bezirk"))

if (!is.na(final_join_test$latest_note[1])) {
  print("✓ Join successful - May-Ayim data found:")
  print(paste("  Note:", final_join_test$latest_note[1]))
  print(paste("  Years:", final_join_test$note_years[1]))
} else {
  print("❌ Join failed - May-Ayim data not found")
  print("This suggests the schul_nr doesn't match between map and CSV data")
}

print("\n=== TEST COMPLETE ===")
print("If all tests pass, the May-Ayim Schule should now appear correctly in the visualization.")
