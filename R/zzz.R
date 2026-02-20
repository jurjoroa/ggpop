# Suppress R CMD CHECK notes for non-standard evaluation (NSE) columns
# created by dplyr or internal processing.
if (getRversion() >= "2.15.1") {
  utils::globalVariables(
    c("group", "prop", "type", "original_order", "df_coordinates_final")
  )
}

# Package-level environment for internal state management.
# Keeps internal state out of .GlobalEnv and passes R CMD CHECK.
.ggpop_env <- new.env(parent = emptyenv())

# Map of build_id -> named character vector of legend icon mappings.
.ggpop_env$legend_icon_map <- new.env(parent = emptyenv())

.onLoad <- function(libname, pkgname) {
  # Suppress additional dplyr-generated variables used in legends.
  utils::globalVariables(c(".legend"))

  # Initialize legend settings registry.
  # Tracks legend_icons settings across multiple geom_icon_point() layers.
  .ggpop_env$legend_settings <- list()
}

# Optional: reset state when package is unloaded (good practice).
.onUnload <- function(libpath) {
  # Clean up package environment to avoid stale state.
  if (exists("legend_settings", envir = .ggpop_env)) {
    rm(list = "legend_settings", envir = .ggpop_env)
  }
}
