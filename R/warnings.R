# --- Internal warning function (API-aligned) ---
warn_geom_pop_inputs <- function(data,
                                 mapping_list,
                                 inherited_mapping_list,
                                 icon,
                                 missing_size,
                                 legend_icons = TRUE,
                                 dpi = 50) {
  
  .has <- function(x, nm) !is.null(x) && nm %in% names(x)
  .msg <- function(...) paste0(...)
  
  warnings <- character(0)
  
  # ------------------------------------------------------------------
  # 1) ICON HANDLING (single, clear source of truth)
  # ------------------------------------------------------------------
  icon_mapped  <- .has(mapping_list, "icon")
  has_icon_col <- "icon" %in% names(data)
  
  if (!icon_mapped && !has_icon_col) {
    warnings <- c(warnings, .msg(
      "[geom_pop] No icon provided.\n",
      "  • Neither `aes(icon = ...)` nor an `icon` column was found.\n",
      "  • Using default icon: '", icon, "'.\n",
      "  → Fix: add `aes(icon = icon)` and create an `icon` column, or pass `icon = \"...\"`."
    ))
  }
  
  if (icon_mapped) {
    icon_var <- tryCatch(rlang::as_name(mapping_list[["icon"]]), error = function(e) NULL)
    if (!is.null(icon_var) && !icon_var %in% names(data)) {
      warnings <- c(warnings, .msg(
        "[geom_pop] `aes(icon = ", icon_var, ")` was mapped, but column '",
        icon_var, "' is not present in `data`.\n",
        "  → Fix: create that column or map `icon` to an existing variable."
      ))
    }
  }
  
  # ------------------------------------------------------------------
  # 3) x / y ARE NOT PART OF THE API (important clarification)
  # ------------------------------------------------------------------
  xy_mapped <- intersect(
    union(names(mapping_list), names(inherited_mapping_list)),
    c("x", "y")
  )
  
  if (length(xy_mapped) > 0) {
    warnings <- c(warnings, .msg(
      "[geom_pop] `x` and `y` aesthetics are not used by `geom_pop()`.\n",
      "  • Positions are computed internally to form the circular layout.\n",
      "  • Any mapping to ", paste(xy_mapped, collapse = ", "), " is ignored.\n",
      "  → Fix: remove `x` / `y` from `aes()` when using `geom_pop()`."
    ))
  }
  
  # ------------------------------------------------------------------
  # 4) Legend icons expectation
  # ------------------------------------------------------------------
  has_colour_mapping <- any(c("colour", "color") %in%
                              union(names(mapping_list), names(inherited_mapping_list)))
  
  if (legend_icons && !has_colour_mapping) {
    warnings <- c(warnings, .msg(
      "[geom_pop] `legend_icons = TRUE` but no `color` / `colour` aesthetic is mapped.\n",
      "  • Icon legends require a colour-based grouping.\n",
      "  → Fix: add `aes(color = <group>)` and a corresponding scale."
    ))
  }
  
  # ------------------------------------------------------------------
  # 5) DPI guidance (educational, not noisy)
  # ------------------------------------------------------------------
  if (is.numeric(dpi) && length(dpi) == 1) {
    if (dpi < 20) {
      warnings <- c(warnings, .msg(
        "[geom_pop] `dpi = ", dpi, "` is very low.\n",
        "  • Icons may appear blurry.\n",
        "  → Tip: use `dpi = 80–200` for crisp rendering."
      ))
    }
    if (dpi > 600) {
      warnings <- c(warnings, .msg(
        "[geom_pop] `dpi = ", dpi, "` is very high.\n",
        "  • This may slow rendering and increase memory use.\n",
        "  → Tip: values above ~300 rarely improve visual quality."
      ))
    }
  }
  
  # ------------------------------------------------------------------
  # Emit (one warning per conceptual issue)
  # ------------------------------------------------------------------
  if (length(warnings)) {
    for (w in warnings) warning(w, call. = FALSE)
  }
  
  invisible(NULL)
}
