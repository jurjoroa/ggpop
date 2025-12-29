# --- Internal validation function ---
validate_geom_pop_inputs <- function(data, mapping_list, icon, size, quality, inherited_data) {
  if ("image" %in% names(mapping_list)) {
    stop("Please do not specify the 'image' aesthetic directly. Use 'icon' instead.")
  }
  
  if ("size" %in% names(mapping_list)) {
    size_var <- rlang::as_name(mapping_list[["size"]])
    if (!size_var %in% names(data)) {
      stop(paste0("Variable '", size_var, "' used for size not found in the dataset."))
    }
  }
  
  if (!is.numeric(quality) || length(quality) != 1 || quality <= 0) {
    stop("`quality` must be a positive numeric scalar.")
  }
  
  # NOTE: removed the restriction about ggplot(data=...) + geom_pop(data=...)
  # NOTE: removed unused parent_data lookup
}

