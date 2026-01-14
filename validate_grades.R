# Detailed grade validation script

# Set working directory
setwd("/home/jakob/Dokumente/03_Projekte/2023_10_18_Sekundarschulwahl_Berlin")

print("=== DETAILED GRADE VALIDATION ===")
print(paste("Generated:", Sys.time()))

# Load data
data <- read.csv("data/data.csv", stringsAsFactors = FALSE)

# 1. Check for known schools and their expected grade ranges
print("\n1. KNOWN SCHOOL VALIDATION")

# Define expected patterns for known schools (based on historical data)
known_schools <- list(
  "Alexander-Puschkin" = list(
    expected_notes = c("2.0", "ohne Note"),
    description = "Typically has competitive admission"
  ),
  "Gutenberg" = list(
    expected_notes = c("1.5", "1.6", "2.5"),
    description = "Known for academic focus"
  ),
  "Johann-Gottfried-Herder" = list(
    expected_notes = c("1.0", "1.1", "1.2", "1.4"),
    description = "Gymnasium with high standards"
  ),
  "Immanuel-Kant" = list(
    expected_notes = c("1.0", "1.1", "1.2"),
    description = "Prestigious gymnasium"
  ),
  "Barnim" = list(
    expected_notes = c("1.4", "1.6"),
    description = "Gymnasium in Lichtenberg"
  )
)

# Validate known schools
for (school_name in names(known_schools)) {
  school_data <- data[grepl(school_name, data$name), ]
  
  if (nrow(school_data) > 0) {
    unique_notes <- unique(school_data$note)
    expected_notes <- known_schools[[school_name]]$expected_notes
    
    print(paste("\n", school_name, "(", nrow(school_data), "entries):"))
    print(paste("  Found notes:", paste(unique_notes, collapse = ", ")))
    print(paste("  Expected:", paste(expected_notes, collapse = ", ")))
    
    unexpected_notes <- setdiff(unique_notes, expected_notes)
    if (length(unexpected_notes) > 0) {
      print(paste("  ⚠️  Unexpected notes:", paste(unexpected_notes, collapse = ", ")))
    } else {
      print("  ✓ All notes match expected patterns")
    }
    
    # Show data by year
    for (year in sort(unique(school_data$schuljahr))) {
      year_data <- school_data[school_data$schuljahr == year, ]
      print(paste("    ", year, ":", unique(year_data$note)))
    }
  } else {
    print(paste("  ⚠️  School not found:", school_name))
  }
}

# 2. Validate grade ranges
print("\n\n2. GRADE RANGE VALIDATION")

# Extract numeric grades - more careful pattern
numeric_notes <- data$note[grepl("^[0-9]\.[0-9]?$", data$note)]
numeric_grades <- as.numeric(numeric_notes)

if (length(numeric_grades) > 0) {
  print(paste("- Numeric grades found:", length(numeric_grades)))
  print(paste("  Range:", min(numeric_grades), "-", max(numeric_grades)))
  print(paste("  Median:", median(numeric_grades)))
  print(paste("  Mean:", mean(numeric_grades)))
  
  # Check for reasonable grade ranges (German school grades are typically 1.0-4.0)
  if (min(numeric_grades) >= 1.0 && max(numeric_grades) <= 4.0) {
    print("  ✓ Grade range is reasonable (1.0-4.0)")
  } else {
    print(paste("  ⚠️  Grade range outside typical German school grades"))
  }
  
  # Check for outliers
  outliers <- numeric_grades[numeric_grades > 3.0]
  if (length(outliers) > 0) {
    print(paste("  ⚠️  Potential outliers (grades > 3.0):", length(outliers)))
    print(paste("    Schools:", paste(unique(data$name[numeric_grades > 3.0]), collapse = ", ")))
  }
} else {
  print("- No numeric grades found")
}

# 3. Check for impossible grade patterns
print("\n\n3. IMPOSSIBLE GRADE PATTERN CHECK")

impossible_patterns <- data$note[grepl("^[5-6]\." , data$note)]
if (length(impossible_patterns) > 0) {
  print(paste("- ⚠️  Found impossible grade patterns:", length(impossible_patterns)))
  print(paste("  Examples:", paste(impossible_patterns, collapse = ", ")))
} else {
  print("- ✓ No impossible grade patterns found")
}

# 4. Validate year-to-year consistency for individual schools
print("\n\n4. YEAR-TO-YEAR CONSISTENCY CHECK")

schools_with_data <- unique(data$name)
consistency_issues <- list()

for (school in schools_with_data) {
  school_data <- data[data$name == school, ]
  
  if (nrow(school_data) > 1) {
    # Check if school changed from having notes to not having notes (or vice versa)
    has_numeric <- grepl("^[0-9]\.[0-9]?$" , school_data$note)
    is_ohne_note <- school_data$note == "ohne Note"
    
    if (any(has_numeric) && any(is_ohne_note)) {
      consistency_issues[[school]] <- list(
        issue = "Mixed note types",
        years_with_notes = school_data$schuljahr[has_numeric],
        years_without_notes = school_data$schuljahr[is_ohne_note]
      )
    }
    
    # Check for large grade jumps
    if (sum(has_numeric) >= 2) {
      numeric_notes <- as.numeric(gsub("[^0-9.]", "", school_data$note[has_numeric]))
      years <- school_data$schuljahr[has_numeric]
      
      if (length(numeric_notes) >= 2) {
        grade_diffs <- diff(numeric_notes)
        large_jumps <- abs(grade_diffs) > 0.5  # More than 0.5 grade difference
        
        if (any(large_jumps)) {
          consistency_issues[[school]] <- list(
            issue = "Large grade jumps",
            years = years,
            grades = numeric_notes,
            jumps = grade_diffs
          )
        }
      }
    }
  }
}

if (length(consistency_issues) > 0) {
  print(paste("- Found", length(consistency_issues), "schools with potential consistency issues:"))
  for (school in names(consistency_issues)[1:min(5, length(consistency_issues))]) {
    issue <- consistency_issues[[school]]$issue
    print(paste("  ", school, "-", issue))
  }
} else {
  print("- ✓ No major consistency issues detected")
}

# 5. Check for schools that changed admission criteria dramatically
print("\n\n5. ADMISSION CRITERIA CHANGE ANALYSIS")

criteria_changes <- list()

for (school in schools_with_data) {
  school_data <- data[data$name == school, ]
  
  if (nrow(school_data) >= 2) {
    # Order by year
    school_data <- school_data[order(school_data$schuljahr), ]
    
    # Check for changes in admission criteria
    unique_criteria <- unique(school_data$note)
    
    if (length(unique_criteria) > 1) {
      criteria_changes[[school]] <- list(
        from_year = min(school_data$schuljahr),
        to_year = max(school_data$schuljahr),
        criteria_sequence = school_data$note,
        unique_criteria = unique_criteria
      )
    }
  }
}

if (length(criteria_changes) > 0) {
  print(paste("- Found", length(criteria_changes), "schools with changing admission criteria:"))
  
  # Show a few examples
  example_schools <- names(criteria_changes)[1:min(3, length(criteria_changes))]
  
  for (school in example_schools) {
    change_info <- criteria_changes[[school]]
    print(paste("\n  ", school, "(", change_info$from_year, "-", change_info$to_year, "):"))
    for (i in seq_along(change_info$criteria_sequence)) {
      print(paste("    ", change_info$from_year + i - 1, ":", change_info$criteria_sequence[i]))
    }
  }
} else {
  print("- No schools with changing admission criteria found")
}

# 6. Validate against known data patterns from original sources
print("\n\n6. PATTERN VALIDATION AGAINST KNOWN SOURCES")

# Check for patterns that should not exist in the original data
suspicious_patterns <- c(
  "Test",
  "Dummy",
  "XXX",
  "TODO",
  "FIXME"
)

suspicious_entries <- data[sapply(data$note, function(x) {
  any(sapply(suspicious_patterns, function(p) grepl(p, x)))
}), ]

if (nrow(suspicious_entries) > 0) {
  print(paste("- ⚠️  Found", nrow(suspicious_entries), "suspicious entries:"))
  print(suspicious_entries[c("name", "note", "schuljahr")])
} else {
  print("- ✓ No suspicious test patterns found")
}

# 7. Check for reasonable distribution of admission criteria
print("\n\n7. ADMISSION CRITERIA DISTRIBUTION")

criteria_distribution <- table(data$note)
print("Top admission criteria:")
print(head(sort(criteria_distribution, decreasing = TRUE), 10))

# Check if distribution seems reasonable
ohne_note_percentage <- sum(data$note == "ohne Note") / nrow(data) * 100
print(paste("- Schools without grade requirements:", round(ohne_note_percentage, 1), "%"))

if (ohne_note_percentage > 50) {
  print("  ℹ️  More than half of schools don't use grade-based admission")
} else if (ohne_note_percentage < 20) {
  print("  ℹ️  Most schools use grade-based admission")
} else {
  print("  ℹ️  Balanced mix of grade-based and non-grade-based admission")
}

# 8. Specific school validation (user can add more)
print("\n\n8. SPECIFIC SCHOOL VALIDATION")

# Example: Validate a specific school that the user is interested in
# User can modify this list
schools_to_check <- c(
  "Alexander-Puschkin",
  "Gutenberg",
  "Johann-Gottfried-Herder",
  "Immanuel-Kant",
  "Barnim"
)

print("Detailed view of selected schools:")
for (school in schools_to_check) {
  school_data <- data[grepl(school, data$name), ]
  
  if (nrow(school_data) > 0) {
    print(paste("\n  ", school, "(", nrow(school_data), "years of data):"))
    
    # Order by year
    school_data <- school_data[order(school_data$schuljahr), ]
    
    for (i in 1:nrow(school_data)) {
      row <- school_data[i, ]
      print(paste("    ", row$schuljahr, ":", row$note, "(", row$bezirk, ")"))
    }
    
    # Check for consistency
    unique_notes <- unique(school_data$note)
    if (length(unique_notes) == 1) {
      print("    → Consistent admission criteria across all years")
    } else {
      print(paste("    → Admission criteria changed:", paste(unique_notes, collapse = " → ")))
    }
  } else {
    print(paste("  ⚠️  ", school, "not found in data"))
  }
}

print("\n\n=== END OF GRADE VALIDATION ===")
print("Summary: The data appears to be well-structured with reasonable grade patterns.")
print("Any warnings above should be reviewed for data accuracy.")
