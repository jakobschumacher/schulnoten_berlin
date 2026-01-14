# Simple grade validation without complex regex

# Set working directory
setwd("/home/jakob/Dokumente/03_Projekte/2023_10_18_Sekundarschulwahl_Berlin")

print("=== SIMPLE GRADE VALIDATION ===")

# Load data
data <- read.csv("data/data.csv", stringsAsFactors = FALSE)

# 1. Check basic data structure
print(paste("Total records:", nrow(data)))
print(paste("Unique schools:", length(unique(data$name))))

# 2. Identify numeric grades (simple approach)
numeric_grades <- character(0)
for (note in data$note) {
  # Check if it looks like a grade (e.g., "1.0", "2.5")
  if (grepl("^[0-9]\\.[0-9]$", note)) {
    numeric_grades <- c(numeric_grades, note)
  }
}

print(paste("Numeric grades found:", length(numeric_grades)))
if (length(numeric_grades) > 0) {
  numeric_values <- as.numeric(numeric_grades)
  print(paste("Grade range:", min(numeric_values), "-", max(numeric_values)))
  print(paste("Average grade:", mean(numeric_values)))
  
  # Check for reasonable grades (German system: 1.0-4.0)
  unreasonable_grades <- numeric_values[numeric_values > 4.0 | numeric_values < 1.0]
  if (length(unreasonable_grades) > 0) {
    print(paste("⚠️  Unreasonable grades:", paste(unreasonable_grades, collapse = ", ")))
  } else {
    print("✓ All numeric grades are in reasonable range (1.0-4.0)")
  }
}

# 3. Check for known schools
print("\n=== KNOWN SCHOOL CHECK ===")

known_schools <- c(
  "Alexander-Puschkin",
  "Gutenberg", 
  "Johann-Gottfried-Herder",
  "Immanuel-Kant",
  "Barnim"
)

for (school in known_schools) {
  school_data <- data[grepl(school, data$name), ]
  
  if (nrow(school_data) > 0) {
    print(paste(school, "(", nrow(school_data), "years):"))
    
    # Order by year
    school_data <- school_data[order(school_data$schuljahr), ]
    
    for (i in 1:nrow(school_data)) {
      row <- school_data[i, ]
      print(paste("  ", row$schuljahr, ":", row$note))
    }
  } else {
    print(paste("⚠️  ", school, "not found"))
  }
}

# 4. Check for suspicious patterns
print("\n=== SUSPICIOUS PATTERN CHECK ===")

suspicious_patterns <- c("Test", "Dummy", "XXX", "TODO", "FIXME", "NA", "NULL")
suspicious_found <- character(0)

for (pattern in suspicious_patterns) {
  matches <- data$note[grepl(pattern, data$note)]
  if (length(matches) > 0) {
    suspicious_found <- c(suspicious_found, matches)
  }
}

if (length(suspicious_found) > 0) {
  print(paste("⚠️  Found suspicious patterns:", length(suspicious_found)))
  print(paste("Examples:", paste(head(suspicious_found, 3), collapse = ", ")))
} else {
  print("✓ No suspicious patterns found")
}

# 5. Check grade distribution
print("\n=== GRADE DISTRIBUTION ===")

note_table <- table(data$note)
print("Most common admission criteria:")
print(head(sort(note_table, decreasing = TRUE), 10))

# 6. Check for schools with multiple different criteria
print("\n=== CONSISTENCY CHECK ===")

schools_with_data <- unique(data$name)
consistency_issues <- 0

for (school in schools_with_data) {
  school_data <- data[data$name == school, ]
  unique_criteria <- length(unique(school_data$note))
  
  if (unique_criteria > 1 && nrow(school_data) > 1) {
    consistency_issues <- consistency_issues + 1
  }
}

print(paste("Schools with changing admission criteria:", consistency_issues, "/", length(schools_with_data)))

# 7. Specific validation examples
print("\n=== SPECIFIC VALIDATION EXAMPLES ===")

# Example 1: Check if Alexander-Puschkin has reasonable grades
ap_data <- data[grepl("Alexander-Puschkin", data$name), ]
if (nrow(ap_data) > 0) {
  print("Alexander-Puschkin School:")
  for (i in 1:nrow(ap_data)) {
    print(paste("  ", ap_data$schuljahr[i], ":", ap_data$note[i]))
  }
  
  # Check if grades are reasonable (should be around 2.0)
  ap_grades <- as.numeric(gsub("[^0-9.]", "", ap_data$note))
  ap_grades <- ap_grades[!is.na(ap_grades)]
  
  if (length(ap_grades) > 0 && all(ap_grades >= 1.5 & ap_grades <= 2.5)) {
    print("  ✓ Grades are in expected range for this school")
  } else {
    print("  ⚠️  Grades may need review")
  }
}

# Example 2: Check top gymnasium grades
top_gymnasiums <- data[grepl("Gymnasium", data$name) & grepl("^[1-2]\\.[0-9]$", data$note), ]
if (nrow(top_gymnasiums) > 0) {
  print(paste("Top Gymnasium grades (sample):"))
  sample_top <- head(top_gymnasiums[order(as.numeric(gsub("[^0-9.]", "", top_gymnasiums$note))), ], 5)
  for (i in 1:min(5, nrow(sample_top))) {
    print(paste("  ", sample_top$name[i], "-", sample_top$note[i], "(", sample_top$schuljahr[i], ")"))
  }
}

print("\n=== VALIDATION COMPLETE ===")
print("The data appears to be well-structured. Review any warnings above.")
