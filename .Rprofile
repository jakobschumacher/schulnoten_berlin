project_dir <- "/home/rstudio/project"
if (!dir.exists(project_dir)) project_dir <- "/project"

if (dir.exists(project_dir)) {
  setwd(project_dir)

  proj_file <- file.path(project_dir, "2023_10_18_Sekundarschulwahl_Berlin.Rproj")
  if (file.exists(proj_file) &&
      Sys.getenv("RSTUDIO", "") == "1" &&
      is.null(getOption("sekundarschulwahl.project_opened"))) {
    options(sekundarschulwahl.project_opened = TRUE)
    try({
      if (requireNamespace("rstudioapi", quietly = TRUE) &&
          rstudioapi::isAvailable()) {
        rstudioapi::openProject(proj_file, newSession = FALSE)
      }
    }, silent = TRUE)
  }
}
