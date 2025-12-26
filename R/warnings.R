# --- Internal warning function ---
warn_geom_pop_inputs <- function(data, mapping_list, inherited_mapping_list, icon, missing_size) {
  # Warn if fallback icon is used
  if (!"icon" %in% names(mapping_list)) {
    if (!"icon" %in% colnames(data) || all(data$icon == icon)) {
      warning(paste(
        "⚠️ [geom_pop] No icon specified via `aes(icon = ...)`.",
        "Falling back to default icon: '", icon, "'.",
        sep = ""
      ), call. = FALSE)
    }
  }
  # Warn if both aes(size=...) and size argument are used
  if ("size" %in% names(mapping_list) && missing_size == FALSE) {
    warning(paste(
      "⚠️ [geom_pop] You specified `size` both in `aes()` and as an argument.",
      "The mapped `size` in `aes()` will be used."
    ), call. = FALSE)
  }
  
  # Warn if x or y were mapped — they will be ignored
  ignored_vars <- intersect(
    union(names(mapping_list), names(inherited_mapping_list)),
    c("x", "y")
  )
  if (length(ignored_vars) > 0) {
    warning(paste0(
      "⚠️ [geom_pop] You mapped aesthetic(s) ",
      paste(ignored_vars, collapse = ", "),
      ", but `geom_pop()` overrides `x` and `y` internally. These values will be ignored."
    ), call. = FALSE)
  }
  
  if (!"icon" %in% colnames(data)) {
    warning(paste0(
      "⚠️ [geom_pop] The dataframe does not include a column named `icon`. ",
      "Falling back to default icon: '", icon, "'."
    ), call. = FALSE)
  }
  
}
