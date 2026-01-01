
# --- Internal warning function (API-aligned, ASCII-safe) ---
warn_geom_pop_inputs <- function(data,
                                 mapping_list,
                                 inherited_mapping_list,
                                 icon,
                                 missing_size,
                                 size,
                                 legend_icons = TRUE,
                                 dpi = 50,
                                 arrange = FALSE) {
  
  
  .has <- function(x, nm) !is.null(x) && nm %in% names(x)
  .msg <- function(...) paste0(...)
  
  warnings <- character(0)
  
  # ------------------------------------------------------------------
  # 1) ICON HANDLING (single, clear source of truth)
  # ------------------------------------------------------------------
  icon_mapped  <- .has(mapping_list, "icon")
  has_icon_col <- "icon" %in% names(data)
  
  if (icon_mapped) {
    icon_var <- tryCatch(rlang::as_name(mapping_list[["icon"]]), error = function(e) NULL)
    if (!is.null(icon_var) && !icon_var %in% names(data)) {
      warnings <- c(warnings, .msg(
        "[geom_pop] `aes(icon = ", icon_var, ")` was mapped, but column '",
        icon_var, "' is not present in `data`.\n",
        "  -> Fix: create that column or map `icon` to an existing variable."
      ))
    }
  }
  
  # ------------------------------------------------------------------
  # 2) REQUIRED COLUMNS (helps when users bypass process_data())
  # ------------------------------------------------------------------
  if (!"type" %in% names(data)) {
    warnings <- c(warnings, .msg(
      "[geom_pop] Column `type` not found in `data`.\n",
      "  - `process_data()` typically creates `type`.\n",
      "  -> Fix: run process_data(...) first, or provide a `type` column."
    ))
  }
  
  if (isTRUE(arrange) && (!all(c("n", "prop") %in% names(data)))) {
    warnings <- c(warnings, .msg(
      "[geom_pop] `arrange = TRUE` requires `n` and `prop` columns.\n",
      "  -> Fix: run process_data(...), or set arrange = FALSE."
    ))
  }
  
  # ------------------------------------------------------------------
  # 3) x / y ARE NOT PART OF THE API
  # ------------------------------------------------------------------
  xy_mapped <- intersect(
    union(names(mapping_list), names(inherited_mapping_list)),
    c("x", "y")
  )
  
  if (length(xy_mapped) > 0) {
    warnings <- c(warnings, .msg(
      "[geom_pop] `x` and `y` aesthetics are not used by `geom_pop()`.\n",
      "  - Positions are computed internally to form the circular layout.\n",
      "  - Any mapping to ", paste(xy_mapped, collapse = ", "), " is ignored.\n",
      "  -> Fix: remove `x` / `y` from `aes()` when using `geom_pop()`."
    ))
  }
  
  # ------------------------------------------------------------------
  # 5) dpi validity + guidance
  # ------------------------------------------------------------------
  if (!is.numeric(dpi) || length(dpi) != 1 || is.na(dpi) || !is.finite(dpi)) {
    warnings <- c(warnings, .msg(
      "[geom_pop] `dpi` must be a single finite number.\n",
      "  - You provided: ", paste(dpi, collapse = ", "), "\n",
      "  -> Fix: use dpi = 50 (or 50-200 for crisp icons)."
    ))
  } else {
    if (dpi < 50) {
      warnings <- c(warnings, .msg(
        "[geom_pop] `dpi = ", dpi, "` is on the low side.\n",
        "  - Icons may still look soft at 30-49.\n",
        "  -> Tip: use 50-200 for crisp icons (change `size` to resize, not `dpi`)."
      ))
    }
    
    if (dpi > 600) {
      warnings <- c(warnings, .msg(
        "[geom_pop] `dpi = ", dpi, "` is very high.\n",
        "  - This may slow rendering and increase memory use.\n",
        "  -> Tip: values above ~300 rarely improve visual quality."
      ))
    }
  }
  
  # ------------------------------------------------------------------
  # 6) size validity (only when not missing / not mapped)
  # ------------------------------------------------------------------
  if (!missing_size) {
    if (!is.numeric(size) || length(size) != 1 || is.na(size) || !is.finite(size) || size <= 0) {
      warnings <- c(warnings, .msg(
        "[geom_pop] `size` must be a single positive number.\n",
        "  - You provided: ", paste(size, collapse = ", "), "\n",
        "  -> Fix: use size > 0 (e.g., size = 3)."
      ))
    }
  }
  
  # ------------------------------------------------------------------
  # 8) Legend ambiguity: >1 icon per color group (only matters if a legend group exists)
  # ------------------------------------------------------------------
  if (isTRUE(legend_icons) && icon_mapped) {
    
    col_nm <- if ("colour" %in% names(mapping_list)) {
      "colour"
    } else if ("color" %in% names(mapping_list)) {
      "color"
    } else {
      NULL
    }
    
    # If there's no color/colour mapping, there is no legend grouping to be ambiguous about.
    if (!is.null(col_nm)) {
      
      col_var  <- tryCatch(rlang::as_name(mapping_list[[col_nm]]), error = function(e) NULL)
      icon_var <- tryCatch(rlang::as_name(mapping_list[["icon"]]), error = function(e) NULL)
      
      if (!is.null(col_var) && !is.null(icon_var) &&
          col_var %in% names(data) && icon_var %in% names(data)) {
        
        n_icon_per_group <- data |>
          dplyr::distinct(.g = .data[[col_var]], .i = .data[[icon_var]]) |>
          dplyr::count(.g, name = "n_icons")
        
        if (any(n_icon_per_group$n_icons > 1)) {
          
          offenders <- paste0(
            n_icon_per_group$.g[n_icon_per_group$n_icons > 1],
            collapse = ", "
          )
          
          warnings <- c(warnings, .msg(
            "[geom_pop] Some legend groups map to multiple icons.\n",
            "  - Offenders: ", offenders, "\n",
            "  -> Fix: ensure exactly 1 icon per color group, or set legend_icons = FALSE."
          ))
        }
      }
    }
  }
  
  
  # ------------------------------------------------------------------
  # Emit warnings (one per conceptual issue)
  # ------------------------------------------------------------------
  if (length(warnings)) {
    for (w in warnings) warning(w, call. = FALSE)
  }
  
  invisible(NULL)
}


