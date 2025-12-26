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
  
  # Detect if ggplot() already had a dataset
  parent_data <- tryCatch(ggplot_build(last_plot())$plot$data, error = function(e) NULL)
  
  # If both user provided data here AND ggplot() already had data, it's invalid
  # Compare by memory address to detect identical data
  if (!is.null(data) && !is.null(inherited_data)) {
    if (!identical(data, inherited_data)) {
      stop("❌ [geom_pop] You cannot provide different datasets in both `ggplot(data = ...)`\n",
           "and `geom_pop(data = ...)`. Please specify your dataset in only one of them.",
           call. = FALSE)
    } else {
      warning("⚠️ [geom_pop] You provided the same dataset in both `ggplot(data = ...)` and `geom_pop(data = ...)`. ",
              "Please specify your dataset in only one of them to avoid redundancy.",
              call. = FALSE)
    }
  }
  
}
