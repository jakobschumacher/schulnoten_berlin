# Comprehensive data validation script

# Set working directory
setwd("/home/jakob/Dokumente/03_Projekte/2023_10_18_Sekundarschulwahl_Berlin")

# Load required libraries (using base R to avoid dependency issues)
print("=== Data Validation Report ===")
print(paste("Generated:", Sys.time()))

# 1. Basic data structure check
print("\n1. BASIC DATA STRUCTURE")
if (file.exists("data/data.csv")) {
  data <- read.csv("data/data.csv", stringsAsFactors = FALSE)
  print(paste("- Rows:", nrow(data)))
  print(paste("- Columns:", paste(names(data), collapse = ", ")))
  print(paste("- Complete rows:", sum(complete.cases(data))))
  print(paste("- Missing values:", sum(!complete.cases(data))))
} else {
  print("- ERROR: data.csv not found!")
  quit()
}

# 2. District validation
print("\n2. DISTRICT VALIDATION")
unique_districts <- unique(data$bezirk)
print(paste("- Unique districts:", paste(unique_districts, collapse = ", ")))
expected_districts <- c("Lichtenberg", "Pankow")
unexpected_districts <- setdiff(unique_districts, expected_districts)
if (length(unexpected_districts) > 0) {
  print(paste("- WARNING: Unexpected districts:", paste(unexpected_districts, collapse = ", ")))
} else {
  print("- ✓ All districts are valid")
}

# 3. Year validation
print("\n3. YEAR VALIDATION")
unique_years <- unique(data$schuljahr)
print(paste("- Unique years:", paste(unique_years, collapse = ", ")))
if (all(unique_years >= 2023 & unique_years <= 2025)) {
  print("- ✓ All years are in expected range (2023-2025)")
} else {
  print(paste("- WARNING: Years outside expected range"))
}

# 4. School name validation
print("\n4. SCHOOL NAME VALIDATION")
print(paste("- Total unique schools:", length(unique(data$name))))

# Check for common patterns that might indicate data issues
name_issues <- data$name[grepl("NA|NULL|#N/A|#VALUE!", data$name)]
if (length(name_issues) > 0) {
  print(paste("- WARNING: Problematic school names found:", length(name_issues)))
  print(paste("  Examples:", paste(head(name_issues, 3), collapse = ", ")))
} else {
  print("- ✓ No obvious name issues detected")
}

# 5. Note validation
print("\n5. NOTE VALIDATION")
note_summary <- table(data$note)
print("- Note distribution:")
print(note_summary)

# Check for valid note patterns
valid_note_patterns <- c("ohne Note", "alle", "\\*\\*", "Punktsumme")
problematic_notes <- data$note[!sapply(data$note, function(x) {
  any(grepl(paste(valid_note_patterns, collapse = "|"), x)) || 
  grepl("^[0-9][.][0-9]?$", x) || 
  grepl("nicht übernachgefragt", x)
})]

if (length(problematic_notes) > 0) {
  print(paste("- WARNING: Potentially problematic notes:", length(problematic_notes)))
  print(paste("  Examples:", paste(head(problematic_notes, 3), collapse = ", ")))
} else {
  print("- ✓ All notes appear valid")
}

# 6. School ID validation
print("\n6. SCHOOL ID VALIDATION")
print(paste("- Schools with IDs:", sum(!is.na(data$schul_nr))))
print(paste("- Schools without IDs:", sum(is.na(data$schul_nr))))

# Check ID patterns
id_patterns <- unique(data$schul_nr[!is.na(data$schul_nr)])
print(paste("- ID patterns found:", paste(head(id_patterns, 5), collapse = ", ")))

# 7. Data completeness by district and year
print("\n7. DATA COMPLETENESS ANALYSIS")
completeness <- aggregate(schul_nr ~ bezirk + schuljahr, data = data, 
                         function(x) c(Total = length(x), With_ID = sum(!is.na(x))))
print("Completeness by district and year:")
print(completeness)

# 8. Check for duplicates
print("\n8. DUPLICATE CHECK")
duplicates <- data[duplicated(data[c("bezirk", "schuljahr", "name")]), ]
if (nrow(duplicates) > 0) {
  print(paste("- WARNING: Found", nrow(duplicates), "duplicate entries"))
  print(paste("  Example duplicates:"))
  print(head(duplicates[c("bezirk", "schuljahr", "name")]))
} else {
  print("- ✓ No duplicate entries found")
}

# 9. Data consistency check
print("\n9. DATA CONSISTENCY CHECK")

# Check if same school has different notes in same year
consistency_issues <- NULL
for (district in unique(data$bezirk)) {
  for (year in unique(data$schuljahr)) {
    district_year_data <- data[data$bezirk == district & data$schuljahr == year, ]
    school_notes <- aggregate(note ~ name, data = district_year_data, 
                             function(x) length(unique(x)))
    inconsistent_schools <- school_notes[school_notes$note > 1, ]
    if (nrow(inconsistent_schools) > 0) {
      consistency_issues <- rbind(consistency_issues, 
                                 data.frame(district, year, inconsistent_schools))
    }
  }
}

if (!is.null(consistency_issues) && nrow(consistency_issues) > 0) {
  print(paste("- WARNING: Found", nrow(consistency_issues), "consistency issues"))
  print(paste("  Schools with multiple notes in same year:"))
  print(head(consistency_issues$name))
} else {
  print("- ✓ No consistency issues detected")
}

# 10. Summary statistics
print("\n10. SUMMARY STATISTICS")
print(paste("- Total data points:", nrow(data)))
print(paste("- Unique schools:", length(unique(data$name))))
print(paste("- Districts covered:", length(unique(data$bezirk))))
print(paste("- Years covered:", length(unique(data$schuljahr))))

# 11. Sample data preview
print("\n11. SAMPLE DATA PREVIEW")
print("First 10 rows:")
print(head(data, 10))

print("\n=== END OF VALIDATION REPORT ===")
print("Recommendation: Review any WARNING messages above for data quality issues.")
