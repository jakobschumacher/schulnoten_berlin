# Example: Using the consolidated data loading functions

# Load the data functions
source("get_data.R")

# Example 1: Load all school data
print("Example 1: Loading all school data")
all_schools <- get_all_school_data()
print(paste("Loaded", nrow(all_schools), "schools from", length(unique(all_schools$bezirk)), "districts"))
print(head(all_schools %>% select(name, bezirk, schuljahr, note)))

# Example 2: Load data for a specific district
print("\nExample 2: Loading Pankow schools only")
pankow_schools <- get_school_data(bezirk = "Pankow")
print(paste("Loaded", nrow(pankow_schools), "schools from Pankow"))
print(table(pankow_schools$schuljahr))

# Example 3: Load data for a specific year
print("\nExample 3: Loading 2025 schools only")
schools_2025 <- get_school_data(schuljahr = "2025")
print(paste("Loaded", nrow(schools_2025), "schools for year 2025"))
print(table(schools_2025$bezirk))

# Example 4: Load data for specific district and year
print("\nExample 4: Loading Pankow schools for 2023")
pankow_2023 <- get_school_data(bezirk = "Pankow", schuljahr = "2023")
print(paste("Loaded", nrow(pankow_2023), "Pankow schools for 2023"))
print(head(pankow_2023 %>% select(name, note)))

# Example 5: Analyze admission criteria
print("\nExample 5: Analyzing admission criteria")
criteria_summary <- all_schools %>%
  mutate(criteria_type = case_when(
    grepl("Punktsumme", note) ~ "Point System",
    note == "ohne Note" ~ "No Grade Required",
    note == "alle" ~ "All Accepted",
    note == "**" ~ "Special Case",
    TRUE ~ "Grade Required"
  )) %>%
  count(criteria_type)

print("Admission criteria distribution:")
print(criteria_summary)

# Example 6: Find schools with specific criteria
print("\nExample 6: Finding schools with no grade requirement")
no_grade_schools <- get_all_school_data() %>%
  filter(note == "ohne Note") %>%
  select(name, bezirk, schuljahr)

print(paste("Found", nrow(no_grade_schools), "schools with no grade requirement:"))
print(head(no_grade_schools))

print("\nAll examples completed successfully!")