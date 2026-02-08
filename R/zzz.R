# Suppress CMD CHECK notes for dplyr-generated columns
if (getRversion() >= "2.15.1") {
  utils::globalVariables(
    c("group", "prop", "type", "original_order", "df_coordinates_final")
  )
}

# Package-level environment for internal state management
# This avoids polluting .GlobalEnv and passes R CMD CHECK
.ggpop_env <- new.env(parent = emptyenv())

.ggpop_env$legend_icon_map <- new.env(parent = emptyenv())  # build_id -> named character vector

.onLoad <- function(libname, pkgname) {
  # Suppress additional dplyr-generated variables
  utils::globalVariables(c(".legend"))

  # Initialize legend settings registry
  # Used to track legend_icons settings across multiple geom_icon_point() layers
  .ggpop_env$legend_settings <- list()
}

# Optional: Reset state when package is unloaded (good practice)
.onUnload <- function(libpath) {
  # Clean up package environment
  if (exists("legend_settings", envir = .ggpop_env)) {
    rm(list = "legend_settings", envir = .ggpop_env)
  }
}



