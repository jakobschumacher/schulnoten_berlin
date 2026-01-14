# Debug script for May-Ayim Schule issue

# Set working directory
setwd("/home/jakob/Dokumente/03_Projekte/2023_10_18_Sekundarschulwahl_Berlin")

print("=== DEBUGGING MAY-AYIM SCHULE ISSUE ===")

# Load data
data <- read.csv("data/data.csv", stringsAsFactors = FALSE)

# 1. Check what's in the CSV for May-Ayim
print("\n1. May-Ayim Schule in data.csv:")
may_ayim_data <- data[grepl("May-Ayim", data$name), ]
if (nrow(may_ayim_data) > 0) {
  print(paste("Found", nrow(may_ayim_data), "entries:"))
  print(may_ayim_data)
} else {
  print("❌ May-Ayim Schule NOT found in data.csv")
}

# 2. Check for similar names that might be the issue
print("\n2. Checking for similar school names:")
similar_names <- data[grepl("May.*Ayim|Ayim.*May", data$name, ignore.case = TRUE), ]
if (nrow(similar_names) > 0) {
  print("Similar names found:")
  print(similar_names$name)
} else {
  print("No similar names found")
}

# 3. Check the data processing in get_data.R
print("\n3. Checking data processing issues:")
print("The issue might be in how school names are cleaned/standardized")

# Check what the name looks like before/after cleaning
original_names <- data$name[grepl("May.*Ayim|Ayim.*May", data$name, ignore.case = TRUE)]
if (length(original_names) > 0) {
  print("Original names in CSV:")
  print(original_names)
} else {
  print("❌ No May-Ayim related names found in CSV")
}

# 4. Check if the school exists in the map data
print("\n4. Checking if school exists in map data:")
print("This would require loading the map data, but we can check the expected name format")
print("Expected formats that might cause matching issues:")
print("- 'May-Ayim-Schule'")
print("- 'May Ayim Schule'")
print("- 'May-Ayim-Oberschule'")
print("- 'May-Ayim-Schule (Integrierte Sekundarschule)'")

# 5. Suggest fixes
print("\n5. SUGGESTED FIXES:")
print("If May-Ayim Schule is in data.csv but not showing in index.html:")
print("a) Check name matching in the join operation")
print("b) Verify the school name cleaning process")
print("c) Ensure the school exists in the map data with matching name")
print("d) Check if there are special characters or encoding issues")

# 6. Check encoding
print("\n6. Checking for encoding issues:")
if (nrow(may_ayim_data) > 0) {
  print("Name in CSV:")
  print(enc2native(may_ayim_data$name[1]))
  print("Note in CSV:")
  print(enc2native(may_ayim_data$note[1]))
}

print("\n=== DEBUG COMPLETE ===")
print("Recommendation: Check the name matching between data.csv and map data")
