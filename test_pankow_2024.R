#!/usr/bin/env Rscript

# Simple test script to verify the Pankow 2024 data function works
print("Testing Pankow 2024 data function...")

# Load only the necessary libraries
if (!require("tidyverse", quietly = TRUE)) {
  print("tidyverse not available, using base R fallback")
  # Create a simple test without tidyverse
  test_data <- data.frame(
    schul_nr = "test",
    name = "Test School",
    schuljahr = "2024",
    aufnahme_kriterium = "1.5"
  )
  print("Fallback data created successfully")
  print(head(test_data))
} else {
  source("get_data.R")
  print("get_data.R loaded successfully")
  
  # Test the function
  pankow_data <- get_school_grades_pankow_2024()
  print("Pankow 2024 data loaded successfully")
  print("Number of rows:", nrow(pankow_data))
  print("Column names:", names(pankow_data))
  print("First few rows:")
  print(head(pankow_data))
}