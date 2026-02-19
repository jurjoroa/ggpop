# *****************************************************************************
#
# Script: validators.R
#
# Purpose: Validation functions for geom_pop() - parameter and data validation
#
# Author: Jorge Roa
# Email: jorgeroa@stanford.edu
#
# Date Created: 02-Jan-2026
#
# *****************************************************************************
#
# Notes:
#   - Internal validators for geom_pop() function
#   - All functions are @keywords internal and @noRd
#   - Hard stops use cli::cli_abort(), soft warnings use cli::cli_warn()
#   - Organized by validation type: Parameters, Data, Aesthetics, Grouping, etc.
#
# *****************************************************************************

#' Validation Functions for geom_pop
#' 
#' Internal validators for parameter and data validation in geom_pop().
#' These functions are not exported and are used internally by the package.
#' 
#' @name validators
#' @keywords internal
NULL

# ******************************************************************************
# 01 Parameter Validators ------------------------------------------------------
# ******************************************************************************

# ******************************************************************************
## 01.01 Stroke Width ----------------------------------------------------------
# ******************************************************************************

#' Validate stroke_width parameter
#' 
#' @param stroke_width Numeric stroke width value or NULL
#' @param arg_name Name of the argument for error messages
#' @param size Icon size (optional, for relative warnings)
#' @return Invisible stroke_width if valid
#' @keywords internal
#' @noRd
validate_stroke_width <- function(stroke_width, arg_name = "stroke_width", size = NULL) {
  if (missing(stroke_width) || is.null(stroke_width)) {
    return(invisible(NULL))
  }
  
  # Type check
  if (!is.numeric(stroke_width) || length(stroke_width) != 1) {
    cli::cli_abort(c(
      "Invalid `{arg_name}` parameter.",
      "x" = "Must be a single numeric value.",
      "i" = "You provided: {.val {stroke_width}} ({.cls {class(stroke_width)[1]}})",
      " " = "",
      "i" = "Fix:",
      " " = "  {.code {arg_name} = 2}      # Thin outline",
      " " = "  {.code {arg_name} = 5}      # Thick outline",
      " " = "  {.code {arg_name} = NULL}   # No outline (default)"
    ),
    call = NULL)
  }
  
  # Value checks: NA
  if (is.na(stroke_width)) {
    cli::cli_abort(c(
      "Invalid `{arg_name}` value.",
      "x" = "Cannot be {.val NA}.",
      " " = "",
      "i" = "Fix:",
      " " = "  {.code {arg_name} = 2}     # Valid stroke",
      " " = "  {.code {arg_name} = 0}     # No stroke",
      " " = "  {.code {arg_name} = NULL}  # No stroke (default)"
    ),
    call = NULL)
  }
  
  # Value checks: Inf
  if (!is.finite(stroke_width)) {
    cli::cli_abort(c(
      "Invalid `{arg_name}` value.",
      "x" = "Cannot be {.val Inf} or {.val -Inf}.",
      "i" = "You provided: {.val {stroke_width}}",
      " " = "",
      "i" = "Fix:",
      " " = "  {.code {arg_name} = 2}  # Use finite value"
    ),
    call = NULL)
  }
  
  # Value checks: Negative (HARD STOP)
  if (stroke_width < 0) {
    cli::cli_abort(c(
      "Invalid `{arg_name}` value.",
      "x" = "Cannot be negative.",
      "i" = "You provided: {.val {stroke_width}}",
      " " = "",
      "i" = "Fix:",
      " " = "  {.code {arg_name} = 0}     # No stroke",
      " " = "  {.code {arg_name} = 2}     # Visible stroke",
      " " = "  {.code {arg_name} = NULL}  # No stroke (default)"
    ),
    call = NULL)
  }
  
  # Soft warning for extreme values (absolute)
  if (stroke_width > 30) {
    cli::cli_warn(c(
      "Very large `{arg_name}` value.",
      "!" = "{.val {stroke_width}} is unusually large.",
      "i" = "The stroke may overwhelm the icon fill.",
      " " = "",
      "i" = "Typical values:",
      " " = "  Subtle outline: 1-2",
      " " = "  Medium outline: 3-5",
      " " = "  Bold outline: 6-10"
    ),
    call = NULL)
  }
  
  # Relative warnings (if size is provided)
  if (!is.null(size) && is.numeric(size) && length(size) == 1 && !is.na(size) && size > 0) {
    
    # Warn if stroke is too thin relative to size
    if (stroke_width > 0 && stroke_width < 1 && size < 2) {
      cli::cli_warn(c(
        "Stroke may be too thin to see clearly.",
        "!" = "You set {.code {arg_name} = {stroke_width}} with {.code size = {size}}.",
        " " = "",
        "i" = "The stroke may be barely visible at this scale.",
        " " = "",
        "i" = "Recommended fixes:",
        " " = "  - Increase stroke: {.code {arg_name} = 2}",
        " " = "  - Increase size: {.code size = 3}",
        " " = "  - Or both for better visibility"
      ),
      call = NULL)
    }
    
    # Warn if stroke overwhelms the icon
    if (stroke_width > (size * 5)) {
      cli::cli_warn(c(
        "Stroke may overwhelm the icon fill.",
        "!" = "You set {.code {arg_name} = {stroke_width}} with {.code size = {size}}.",
        " " = "",
        "i" = "The stroke is very thick relative to the icon size.",
        "i" = "The fill area may be barely visible.",
        " " = "",
        "i" = "Recommended fixes:",
        " " = "  - Reduce stroke: {.code {arg_name} = {max(1, round(size * 2))}}",
        " " = "  - Increase size: {.code size = {max(1, round(stroke_width / 3))}}",
        " " = "",
        "i" = "Typical ratios:",
        " " = "  - Subtle outline: stroke = size * 0.5 to size * 1",
        " " = "  - Medium outline: stroke = size * 1 to size * 2",
        " " = "  - Bold outline: stroke = size * 2 to size * 3"
      ),
      call = NULL)
    }
  }
  
  invisible(stroke_width)
}
# ******************************************************************************
## 01.02 DPI -------------------------------------------------------------------
# ******************************************************************************

#' Validate dpi parameter
#' 
#' @param dpi DPI value for icon rendering
#' @param arg_name Name of the argument for error messages
#' @return Invisible dpi if valid
#' @keywords internal
#' @noRd
validate_dpi <- function(dpi, arg_name = "dpi") {
  
  # Type check
  if (!is.numeric(dpi) || length(dpi) != 1 || is.na(dpi) || !is.finite(dpi)) {
    cli::cli_abort(c(
      "Invalid `{arg_name}` parameter.",
      "x" = "Must be a single positive number.",
      "i" = "You provided: {.val {dpi}} ({.cls {class(dpi)[1]}})",
      " " = "",
      "i" = "Fix:",
      " " = "  {.code {arg_name} = 50}   # Default (good quality)",
      " " = "  {.code {arg_name} = 100}  # High quality",
      " " = "  {.code {arg_name} = 200}  # Very sharp icons"
    ),
    call = NULL)
  }
  
  # Hard stop for too low dpi (blurry icons)
  if (dpi < 30) {
    cli::cli_abort(c(
      "`{arg_name} = {dpi}` is too low.",
      "x" = "Icons will be blurry when rendered with {.fn fontawesome::fa_png}.",
      " " = "",
      "i" = "Fix:",
      " " = "  Use {.field {arg_name} >= 30}",
      " " = "  Recommended: 50-200 for crisp icons",
      " " = "",
      "!" = "If you want smaller icons, change {.field size}, not {.field dpi}."
    ),
    call = NULL)
  }
  
  # Soft warning: Borderline low DPI (30-50)
  if (dpi >= 30 && dpi < 50) {
    cli::cli_warn(c(
      "Borderline low `{arg_name}` value.",
      "!" = "{.val {dpi}} may produce slightly blurry icons.",
      "i" = "Recommended: {.field dpi >= 50} for crisp rendering",
      " " = "",
      "i" = "Typical values:",
      " " = "  Minimum acceptable: 30-40 (may be blurry)",
      " " = "  Good quality: 50-100 (default: 50)",
      " " = "  High quality: 100-200",
      " " = "",
      "!" = "If you want smaller icons, use {.field size}, not {.field dpi}."
    ),
    call = NULL)
  }
  
  # Soft warning for very high dpi (performance)
  if (dpi > 300) {
    cli::cli_warn(c(
      "Very high `{arg_name}` value.",
      "!" = "{.val {dpi}} may slow down rendering.",
      "i" = "Typical range: 50-200",
      "i" = "Higher values don't significantly improve visual quality."
    ),
    call = NULL)
  }
  
  invisible(dpi)
}

# ******************************************************************************
## 01.03 Size ------------------------------------------------------------------
# ******************************************************************************

#' Validate size parameter
#' 
#' @param size Icon size value
#' @param missing_size Logical indicating if size was missing in the call
#' @param arg_name Name of the argument for error messages
#' @return Invisible size if valid
#' @keywords internal
#' @noRd
validate_size <- function(size, missing_size = FALSE, arg_name = "size") {
  
  # Skip validation if not provided
  if (missing_size) return(invisible(NULL))
  
  # Type check
  if (!is.numeric(size) || length(size) != 1) {
    cli::cli_abort(c(
      "Invalid `{arg_name}` parameter.",
      "x" = "Must be a single numeric value.",
      "i" = "You provided: {.val {size}} ({.cls {class(size)[1]}})",
      " " = "",
      "i" = "Fix:",
      " " = "  {.code {arg_name} = 3}           # Default",
      " " = "  {.code {arg_name} = 5}           # Larger icons",
      " " = "  {.code aes(size = var)}  # Map to variable (inside aes)"
    ),
    call = NULL)
  }
  
  # Value checks
  if (is.na(size)) {
    cli::cli_abort(c(
      "Invalid `{arg_name}` value.",
      "x" = "Cannot be {.val NA}.",
      " " = "",
      "i" = "Fix:",
      " " = "  {.code {arg_name} = 3}  # Use numeric value",
      " " = "  Or omit to use default ({.code {arg_name} = 3})"
    ),
    call = NULL)
  }
  
  if (!is.finite(size)) {
    cli::cli_abort(c(
      "Invalid `{arg_name}` value.",
      "x" = "Cannot be {.val Inf} or {.val -Inf}.",
      "i" = "You provided: {.val {size}}",
      " " = "",
      "i" = "Fix:",
      " " = "  {.code {arg_name} = 3}  # Use finite value"
    ),
    call = NULL)
  }
  
  if (size <= 0) {
    cli::cli_abort(c(
      "Invalid `{arg_name}` value.",
      "x" = "Must be positive (> 0).",
      "i" = "You provided: {.val {size}}",
      " " = "",
      "i" = "Fix:",
      " " = "  {.code {arg_name} = 3}  # Positive number",
      " " = "  Typical range: 1 to 10"
    ),
    call = NULL)
  }
  
  # Soft warnings for extreme values
  if (size > 15) {
    cli::cli_warn(c(
      "Very large `{arg_name}` value.",
      "!" = "{.val {size}} is unusually large.",
      "i" = "Icons may overlap or extend beyond the plot area.",
      " " = "",
      "i" = "Typical values:",
      " " = "  Small icons: 1-2",
      " " = "  Medium icons: 3-5 (default: 3)",
      " " = "  Large icons: 6-10"
    ),
    call = NULL)
  }
  
  if (size < 0.5) {
    cli::cli_warn(c(
      "Very small `{arg_name}` value.",
      "!" = "{.val {size}} is very small.",
      "i" = "Icons may be difficult to see or distinguish.",
      " " = "",
      "i" = "Recommended:",
      " " = "  Use {.field size >= 1} for visible icons",
      " " = "  Default is 3"
    ),
    call = NULL)
  }
  
  invisible(size)
}

# ******************************************************************************
## 01.04 Arrange ---------------------------------------------------------------
# ******************************************************************************

#' Validate arrange parameter
#' 
#' @param arrange Logical value for arrange parameter
#' @param arg_name Name of the argument for error messages
#' @return Invisible arrange if valid
#' @keywords internal
#' @noRd
validate_arrange <- function(arrange, arg_name = "arrange") {
  
  if (!is.logical(arrange) || length(arrange) != 1 || is.na(arrange)) {
    cli::cli_abort(c(
      "Invalid `{arg_name}` parameter.",
      "x" = "Must be a single logical value ({.val TRUE} or {.val FALSE}).",
      "i" = "You provided: {.val {arrange}} ({.cls {class(arrange)[1]}})",
      " " = "",
      "i" = "Fix:",
      " " = "  {.code {arg_name} = TRUE}   # Sort icons by group",
      " " = "  {.code {arg_name} = FALSE}  # Randomized layout (default)"
    ),
    call = NULL)
  }
  
  invisible(arrange)
}

# ******************************************************************************
## 01.05 Legend Icons ----------------------------------------------------------
# ******************************************************************************

#' Validate legend_icons parameter
#' 
#' @param legend_icons Logical value for legend_icons parameter
#' @param arg_name Name of the argument for error messages
#' @return Invisible legend_icons if valid
#' @keywords internal
#' @noRd
validate_legend_icons <- function(legend_icons, arg_name = "legend_icons") {
  
  if (!is.logical(legend_icons) || length(legend_icons) != 1 || is.na(legend_icons)) {
    cli::cli_abort(c(
      "Invalid `{arg_name}` parameter.",
      "x" = "Must be a single logical value ({.val TRUE} or {.val FALSE}).",
      "i" = "You provided: {.val {legend_icons}} ({.cls {class(legend_icons)[1]}})",
      " " = "",
      "i" = "Fix:",
      " " = "  {.code {arg_name} = TRUE}   # Show Font Awesome icons in legend",
      " " = "  {.code {arg_name} = FALSE}  # Standard ggplot2 point markers",
      " " = "",
      "i" = "Examples:",
      " " = "  {.code geom_pop(..., legend_icons = TRUE)}   # Icons (recommended)",
      " " = "  {.code geom_pop(..., legend_icons = FALSE)}  # Points",
      " " = "",
      "x" = "Common mistakes:",
      " " = "  {.code legend_icons = 'yes'}           # Character not allowed",
      " " = "  {.code legend_icons = 1}               # Numeric not allowed",
      " " = "  {.code legend_icons = c(TRUE, FALSE)}  # Must be single value",
      " " = "  {.code legend_icons = NA}              # NA not allowed"
    ),
    call = NULL)
  }
  
  invisible(legend_icons)
}

# ******************************************************************************
## 01.06 Seed ------------------------------------------------------------------
# ******************************************************************************

#' Validate seed parameter
#' 
#' @param seed Numeric seed value or NULL
#' @param arg_name Name of the argument for error messages
#' @return Invisible seed if valid
#' @keywords internal
#' @noRd
validate_seed <- function(seed, arg_name = "seed") {
  
  if (is.null(seed)) return(invisible(NULL))
  
  if (!is.numeric(seed) || length(seed) != 1 || is.na(seed)) {
    cli::cli_abort(c(
      "Invalid `{arg_name}` parameter.",
      "x" = "Must be a single numeric value or {.val NULL}.",
      "i" = "You provided: {.val {seed}} ({.cls {class(seed)[1]}})",
      " " = "",
      "i" = "Fix:",
      " " = "  {.code {arg_name} = 123}   # Reproducible randomization",
      " " = "  {.code {arg_name} = NULL}  # Different each time (default)"
    ),
    call = NULL)
  }
  
  invisible(seed)
}

# ******************************************************************************
# 02 Data Validators -----------------------------------------------------------
# ******************************************************************************

# ******************************************************************************
## 02.01 Data Frame Validation -------------------------------------------------
# ******************************************************************************

#' Validate data is a data frame
#' 
#' @param data Data object to validate
#' @return Invisible data if valid
#' @keywords internal
#' @noRd
validate_data_is_dataframe <- function(data) {
  
  if (is.null(data)) return(invisible(NULL))
  
  is_valid <- inherits(data, "data.frame") || 
    inherits(data, "tbl_df") || 
    inherits(data, "tbl") ||
    inherits(data, "data.table")
  
  if (!is_valid) {
    data_class <- class(data)[1]
    data_type <- typeof(data)
    
    # Custom fix suggestions based on type
    fix_suggestion <- if (is.matrix(data)) {
      c(
        "i" = "For matrix:",
        " " = "  {.code data <- as.data.frame(your_matrix)}"
      )
    } else if (is.list(data) && !is.data.frame(data)) {
      c(
        "i" = "For list:",
        " " = "  {.code data <- as.data.frame(your_list)}",
        " " = "  {.code # or}",
        " " = "  {.code data <- dplyr::bind_rows(your_list)}"
      )
    } else if (is.vector(data)) {
      c(
        "i" = "For vector:",
        " " = "  {.code data <- data.frame(value = your_vector)}"
      )
    } else {
      c(
        "i" = "Convert to data frame:",
        " " = "  {.code data <- as.data.frame(your_data)}"
      )
    }
    
    cli::cli_abort(c(
      "Invalid `data` type.",
      "x" = "Must be a data frame, tibble, or data.table.",
      "i" = "You provided: {.cls {data_class}} (type: {.val {data_type}})",
      " " = "",
      fix_suggestion,
      " " = "",
      "i" = "Accepted types:",
      " " = "  - data.frame (base R)",
      " " = "  - tibble / tbl_df (tidyverse)",
      " " = "  - data.table (data.table package)",
      " " = "",
      "i" = "Examples:",
      " " = "  {.code df <- data.frame(sex = c('M', 'F'), icon = c('male', 'female'))}",
      " " = "  {.code geom_pop(data = df, aes(icon = icon, group = sex))}"
    ),
    call = NULL)
  }
  
  invisible(data)
}

# ******************************************************************************
## 02.02 Reserved Column Names -------------------------------------------------
# ******************************************************************************

#' Validate no reserved column names in data
#' 
#' @param data Data frame to check
#' @return Invisible data if valid
#' @keywords internal
#' @noRd
validate_no_reserved_columns <- function(data) {
  
  reserved_cols <- c("x1", "y1", "pos", "image", "coord_size", "icon_size", "icon_stroke_width")
  user_cols <- names(data)
  conflicts <- intersect(reserved_cols, user_cols)
  
  if (length(conflicts) > 0) {
    
    # Generate rename code suggestions
    rename_code <- if (length(conflicts) == 1) {
      sprintf("data <- data %%>%% rename(%s_orig = %s)", conflicts[1], conflicts[1])
    } else {
      paste0(
        "data <- data %>% rename(\n  ",
        paste0(conflicts, "_orig = ", conflicts, collapse = ",\n  "),
        "\n)"
      )
    }
    
    cli::cli_abort(c(
      "Reserved column name(s) detected in data.",
      "x" = "Found: {.field {conflicts}}",
      "i" = "These are internal column names used by {.fn geom_pop}.",
      " " = "",
      "!" = "Why this is an error:",
      " " = "  Using these names will cause coordinate calculation failures or visual errors.",
      " " = "",
      "i" = "Reserved column names:",
      " " = "  - x1, y1        (icon coordinates)",
      " " = "  - pos           (icon position index)",
      " " = "  - image         (PNG file path)",
      " " = "  - coord_size    (coordinate lookup key)",
      " " = "  - icon_size     (internal size calculation)",
      " " = "  - icon_stroke_width (internal stroke calculation)",
      " " = "",
      "i" = "Fix - rename the conflicting column(s):",
      " " = "  {.code {rename_code}}",
      " " = "",
      "i" = "Example:",
      " " = "  {.code # Before:}",
      " " = "  {.code df <- data.frame(sex = c('M', 'F'), pos = c(1, 2))}  # 'pos' conflicts",
      " " = "",
      " " = "  {.code # After:}",
      " " = "  {.code df <- df %>% rename(position = pos)}",
      " " = "  {.code geom_pop(data = df, aes(icon = icon, group = sex))}"
    ),
    call = NULL)
  }
  
  invisible(data)
}

# ******************************************************************************
## 02.03 Icon Column Validation ------------------------------------------------
# ******************************************************************************

#' Validate icon column exists and has valid values
#' 
#' @param data Data frame to check
#' @param icon_var Name of the icon column
#' @return Invisible data if valid
#' @keywords internal
#' @noRd
validate_icon_column <- function(data, icon_var) {
  
  # Check column exists
  if (!icon_var %in% names(data)) {
    cli::cli_abort(c(
      "Icon column not found in data.",
      "x" = "You mapped {.code aes(icon = {icon_var})}, but this column doesn't exist.",
      " " = "",
      "i" = "Available columns:",
      " " = "  {.field {names(data)}}",
      " " = "",
      "i" = "Fix:",
      " " = "  - Check your column name: {.code names(data)}",
      " " = "  - Use the correct column name in {.code aes(icon = ...)}",
      " " = "  - Or add the column to your data before calling {.fn geom_pop}"
    ),
    call = NULL)
  }
  
  # Check for missing/empty icon values
  icon_values <- data[[icon_var]]
  bad_icon <- is.na(icon_values) | !nzchar(as.character(icon_values))
  
  if (any(bad_icon)) {
    n_bad <- sum(bad_icon)
    n_total <- length(icon_values)
    
    # Show first few bad rows
    bad_rows <- which(bad_icon)[1:min(5, n_bad)]
    
    cli::cli_abort(c(
      "Invalid icon values detected.",
      "x" = "Found {n_bad} row(s) with missing or empty {.field icon} values out of {n_total} total.",
      " " = "",
      "i" = "Bad rows (first {length(bad_rows)}): {.val {bad_rows}}",
      " " = "",
      "i" = "Fix:",
      " " = "  - Ensure all rows have valid icon names",
      " " = "  - Remove rows with missing icons:",
      " " = "    {.code data <- data %>% filter(!is.na({icon_var}), nchar({icon_var}) > 0)}",
      " " = "",
      "i" = "Valid icon examples:",
      " " = "  'person', 'user', 'male', 'female', 'child', 'baby'"
    ),
    call = NULL)
  }
  
  invisible(data)
}

# ******************************************************************************
## 02.04 Empty Data Frame ------------------------------------------------------
# ******************************************************************************

#' Validate data is not empty
#' 
#' @param data Data frame to check
#' @return Invisible data if valid
#' @keywords internal
#' @noRd
validate_data_not_empty <- function(data) {
  
  if (!is.null(data) && is.data.frame(data) && nrow(data) == 0) {
    cli::cli_abort(c(
      "Empty data detected.",
      "x" = "Cannot create plot with 0 rows.",
      " " = "",
      "i" = "Fix:",
      " " = "  - Ensure your data has at least one row",
      " " = "  - Check your filtering operations",
      " " = "",
      "i" = "Example:",
      " " = "  {.code df <- data.frame(x = 1:10, y = 1:10, icon = 'circle')}",
      " " = "  {.code geom_icon_point(data = df, aes(x = x, y = y))}"
    ),
    call = NULL)
  }
  
  invisible(data)
}

# ******************************************************************************
# 03 Aesthetic mapping validators ----------------------------------------------
# ******************************************************************************

# ******************************************************************************
## 03.01 Icon Aesthetic --------------------------------------------------------
# ******************************************************************************

#' Validate icon aesthetic is mapped
#' 
#' @param mapping_list List of aesthetic mappings from the layer
#' @param inherited_mapping_list List of aesthetic mappings from ggplot()
#' @param data Data frame
#' @return Invisible icon variable name if valid
#' @keywords internal
#' @noRd
validate_icon_aesthetic <- function(mapping_list, inherited_mapping_list, data) {
  
  combined_mapping <- c(inherited_mapping_list, mapping_list)
  icon_mapped <- "icon" %in% names(combined_mapping)
  
  # Hard stop if icon not mapped
  if (!icon_mapped) {
    has_icon_col <- "icon" %in% names(data)
    
    extra_hint <- if (has_icon_col) {
      c(
        " " = "",
        "!" = "Note: Your data has an 'icon' column, but you must still map it explicitly."
      )
    } else {
      character(0)
    }
    
    cli::cli_abort(c(
      "No icon aesthetic specified.",
      "x" = "You must explicitly map the {.field icon} aesthetic.",
      extra_hint,
      " " = "",
      "i" = "Fix - add {.code aes(icon = <column_name>)} to your {.fn geom_pop} call:",
      " " = "",
      "i" = "Examples:",
      " " = "  {.code # Map to a column:}",
      " " = "  {.code geom_pop(aes(icon = icon, group = sex))}",
      " " = "",
      " " = "  {.code # Map to a different column:}",
      " " = "  {.code geom_pop(aes(icon = icon_type, group = sex))}",
      " " = "",
      "x" = "Common mistake:",
      " " = "  {.code geom_pop(data = df, aes(group = sex))}  # Missing icon mapping"
    ),
    call = NULL)
  }
  
  # Extract and validate icon variable
  icon_var <- tryCatch(
    rlang::as_name(combined_mapping[["icon"]]), 
    error = function(e) NULL
  )
  
  if (!is.null(icon_var) && !icon_var %in% names(data)) {
    cli::cli_abort(c(
      "Icon column not found in data.",
      "x" = "You mapped {.code aes(icon = {icon_var})}, but this column doesn't exist.",
      " " = "",
      "i" = "Available columns:",
      " " = "  {.field {names(data)}}",
      " " = "",
      "i" = "Fix:",
      " " = "  - Check your column name: {.code names(data)}",
      " " = "  - Use the correct column name in {.code aes(icon = ...)}",
      " " = "  - Or add the column to your data before calling {.fn geom_pop}"
    ),
    call = NULL)
  }
  
  invisible(icon_var)
}

# ******************************************************************************
## 03.02 Image Aesthetic (Not Allowed) -----------------------------------------
# ******************************************************************************

#' Validate that 'image' aesthetic is not used directly
#' 
#' @param mapping_list List of aesthetic mappings
#' @return Invisible NULL if valid
#' @keywords internal
#' @noRd
validate_no_image_aesthetic <- function(mapping_list) {
  
  if ("image" %in% names(mapping_list)) {
    cli::cli_abort(c(
      "Do not use the {.field image} aesthetic directly.",
      "x" = "The {.field image} aesthetic is generated internally by {.fn geom_pop}.",
      " " = "",
      "i" = "Fix:",
      " " = "  Use {.code aes(icon = ...)} instead of {.code aes(image = ...)}"
    ),
    call = NULL)
  }
  
  invisible(NULL)
}

# ******************************************************************************
## 03.03 Alpha Parameter (Not Allowed) -----------------------------------------
# ******************************************************************************

#' Validate alpha is not used as a parameter
#' 
#' @param dots List of additional arguments (...)
#' @return Invisible NULL if valid
#' @keywords internal
#' @noRd
validate_alpha_not_parameter <- function(dots) {
  
  if ("alpha" %in% names(dots)) {
    cli::cli_abort(c(
      "`alpha` cannot be used as a parameter.",
      "x" = "Alpha must be mapped inside {.code aes()} to work correctly with icon coloring.",
      " " = "",
      "!" = "Why this is an error:",
      " " = "  Parameter-based alpha creates conflicts between PNG transparency and rendering.",
      " " = "",
      "i" = "Fix - for fixed transparency, add an alpha column:",
      " " = "  {.code data$alpha_val <- 0.5}",
      " " = "  {.code geom_pop(aes(icon = icon, group = sex, color = sex, alpha = alpha_val))}",
      " " = "",
      "i" = "For variable transparency:",
      " " = "  {.code geom_pop(aes(icon = icon, group = sex, color = sex, alpha = confidence))}",
      " " = "",
      "i" = "To hide alpha legend entries:",
      " " = "  {.code + guides(alpha = 'none')}"
    ),
    call = NULL)
  }
  
  invisible(NULL)
}

# ******************************************************************************
## 03.04 Fill Aesthetic (Not Allowed) ------------------------------------------
# ******************************************************************************

#' Validate fill aesthetic is not used
#' 
#' @param combined_mapping Combined list of aesthetic mappings
#' @return Invisible NULL if valid
#' @keywords internal
#' @noRd
validate_no_fill_aesthetic <- function(combined_mapping) {
  
  if ("fill" %in% names(combined_mapping)) {
    cli::cli_abort(c(
      "`fill` aesthetic is not supported.",
      "x" = "Only {.field color} or {.field colour} are supported for icon coloring.",
      " " = "",
      "!" = "Why this is an error:",
      " " = "  To keep the API simple, we only support the {.field color} aesthetic.",
      " " = "  FontAwesome icons use 'fill' internally, but we map {.field color} to it.",
      " " = "",
      "i" = "Fix - use {.code aes(color = <variable>)} instead:",
      " " = "",
      "i" = "Examples:",
      " " = "  {.code geom_pop(aes(icon = icon, group = sex, color = sex))}  # Correct",
      " " = "  {.code geom_pop(aes(icon = icon, group = sex, colour = sex))} # Also correct",
      " " = "  {.code geom_pop(aes(icon = icon, group = sex, fill = sex))}   # Not allowed"
    ), 
    call = NULL)
  }
  
  invisible(NULL)
}

# ******************************************************************************
## 03.05 Stroke Width in aes() (Warning) ---------------------------------------
# ******************************************************************************

#' Validate stroke_width is not in aes()
#' 
#' @param combined_mapping Combined list of aesthetic mappings
#' @return Invisible NULL if valid (warnings only, no hard stop)
#' @keywords internal
#' @noRd
validate_stroke_width_not_aesthetic <- function(combined_mapping) {
  
  if ("stroke_width" %in% names(combined_mapping)) {
    
    # Extract the attempted value
    stroke_attempted <- tryCatch({
      stroke_expr <- combined_mapping[["stroke_width"]]
      if (rlang::is_symbol(stroke_expr)) {
        paste0("<variable: ", rlang::as_name(stroke_expr), ">")
      } else if (is.numeric(stroke_expr)) {
        as.character(stroke_expr)
      } else {
        deparse(stroke_expr)
      }
    }, error = function(e) "<unknown>")
    
    cli::cli_warn(c(
      "`stroke_width` inside {.code aes()} will be IGNORED.",
      " " = "",
      "!" = "What you did:",
      " " = "  You provided: {.code aes(stroke_width = {stroke_attempted})}",
      " " = "",
      "x" = "Why this doesn't work:",
      " " = "  - {.field stroke_width} is a PARAMETER, not an aesthetic",
      " " = "  - It must be specified OUTSIDE {.code aes()} to take effect",
      " " = "  - Values inside {.code aes()} are not applied to icon rendering",
      " " = "",
      "i" = "Fix - move {.field stroke_width} OUTSIDE {.code aes()}:",
      " " = "  {.code geom_pop(aes(icon = icon, group = sex), stroke_width = 2)}",
      " " = "",
      "!" = "Note:",
      " " = "  Variable stroke widths per row are not yet supported.",
      " " = "  All icons in one {.fn geom_pop} layer must have the same stroke_width."
    ),
    call = NULL)
  }
  
  invisible(NULL)
}

# ******************************************************************************
# 04 Grouping & faceting validators --------------------------------------------
# ******************************************************************************

# ******************************************************************************
## 04.01 Raw Data Grouping -----------------------------------------------------
# ******************************************************************************

#' Validate grouping variable for raw data mode
#' 
#' @param data Data frame
#' @param mapping_list Layer aesthetic mappings
#' @param inherited_mapping_list Inherited aesthetic mappings
#' @return Invisible grouping variable name if valid
#' @keywords internal
#' @noRd
validate_raw_data_grouping <- function(data, mapping_list, inherited_mapping_list) {
  
  # Skip if data was processed (has 'type' column)
  if ("type" %in% names(data)) {
    return(invisible(NULL))
  }
  
  # Helper to get mapped variable
  .get_mapped_var <- function(aes_name) {
    combined <- c(inherited_mapping_list, mapping_list)
    if (aes_name %in% names(combined)) {
      tryCatch(rlang::as_name(combined[[aes_name]]), error = function(e) NULL)
    } else {
      NULL
    }
  }
  
  `%||%` <- function(x, y) if (is.null(x)) y else x
  
  group_var_m <- .get_mapped_var("group")
  col_var_m   <- .get_mapped_var("colour")
  if (is.null(col_var_m)) col_var_m <- .get_mapped_var("color")
  
  src_var <- group_var_m %||% col_var_m
  
  if (is.null(src_var)) {
    cli::cli_abort(c(
      "Raw data detected - grouping variable required.",
      "x" = "Your data was not created with {.fn process_data}.",
      "i" = "{.fn geom_pop} needs a grouping variable to build the circle layout.",
      " " = "",
      "i" = "Fix - map {.code aes(group = <variable>)} (recommended), OR",
      " " = "     map {.code aes(color = <variable>)}:",
      " " = "",
      "i" = "Example:",
      " " = "  {.code ggplot() +}",
      " " = "  {.code   geom_pop(}",
      " " = "  {.code     data = df,}",
      " " = "  {.code     aes(icon = icon, group = sex),}",
      " " = "  {.code     size = 4}",
      " " = "  {.code   )}"
    ),
    call = NULL)
  }
  
  # Validate the mapped variable exists in data
  if (!src_var %in% names(data)) {
    cli::cli_abort(c(
      "Grouping variable not found in data.",
      "x" = "Mapped grouping variable {.field {src_var}} doesn't exist in your data.",
      " " = "",
      "i" = "Available columns:",
      " " = "  {.field {names(data)}}",
      " " = "",
      "i" = "Fix:",
      " " = "  - Check the column name exists in your data",
      " " = "  - Update your {.code aes()} to use the correct column name"
    ),
    call = NULL)
  }
  
  invisible(src_var)
}

# ******************************************************************************
## 04.02 Facet Column ----------------------------------------------------------
# ******************************************************************************

#' Validate facet column exists in data
#' 
#' @param data Data frame
#' @param facet_col Name of facet column (can be NULL)
#' @return Invisible facet_col if valid
#' @keywords internal
#' @noRd
validate_facet_column <- function(data, facet_col) {
  
  if (is.null(facet_col)) return(invisible(NULL))
  
  if (!facet_col %in% names(data)) {
    cli::cli_abort(c(
      "Facet column not found in data.",
      "x" = "You specified {.code facet = {facet_col}}, but this column doesn't exist.",
      " " = "",
      "i" = "Available columns:",
      " " = "  {.field {names(data)}}",
      " " = "",
      "i" = "Fix:",
      " " = "  - Check your column name: {.code names(data)}",
      " " = "  - Use the correct column in {.code facet = ...}",
      " " = "  - Or remove the {.code facet} parameter if not needed"
    ),
    call = NULL)
  }
  
  invisible(facet_col)
}

# ******************************************************************************
## 04.03 Facet Consistency -----------------------------------------------------
# ******************************************************************************

#' Validate facet consistency between geom_pop and plot
#' 
#' @param facet_col Facet column specified in geom_pop (can be NULL)
#' @param inferred_plot_facet Facet variable inferred from plot object (can be NULL)
#' @param facet_explicit Logical indicating if facet was explicitly provided
#' @return Invisible NULL if valid
#' @keywords internal
#' @noRd
validate_facet_consistency <- function(facet_col, inferred_plot_facet, facet_explicit) {
  
  # Only check if user explicitly provided facet= in geom_pop()
  if (!facet_explicit) return(invisible(NULL))
  
  # Check for mismatch
  if (!is.null(inferred_plot_facet) && !identical(inferred_plot_facet, facet_col)) {
    cli::cli_abort(c(
      "Facet mismatch detected.",
      "x" = "geom_pop(facet = {facet_col}) but plot is faceted by {.field {inferred_plot_facet}}.",
      " " = "",
      "i" = "Fix - make them match:",
      " " = "  {.code facet_wrap(~ {facet_col})}  # Match geom_pop's facet",
      " " = "",
      "i" = "Or update geom_pop:",
      " " = "  {.code geom_pop(..., facet = {inferred_plot_facet})}"
    ),
    call = NULL)
  }
  
  invisible(NULL)
}

# ******************************************************************************
## 04.04 Maximum Icons ---------------------------------------------------------
# ******************************************************************************

#' Validate maximum number of icons per group
#' 
#' @param data Data frame with pos column
#' @param has_facet Logical indicating if faceting is used
#' @param facet_col Name of facet column (can be NULL)
#' @param max_icons Maximum allowed icons (default 1000)
#' @return Invisible data if valid
#' @keywords internal
#' @noRd
validate_max_icons <- function(data, has_facet, facet_col, max_icons = 1000L) {
  
  if (!has_facet) {
    # Single group - check total
    n_icons <- dplyr::n_distinct(data$pos)
    if (n_icons > max_icons) {
      cli::cli_abort(c(
        "Too many icons requested.",
        "x" = "Requested {n_icons} icons, but maximum is {max_icons}.",
        " " = "",
        "i" = "Fix - reduce {.code sample_size} in {.fn process_data}:",
        " " = "  {.code process_data(..., sample_size = {max_icons})}"
      ),
      call = NULL)
    }
  } else {
    # Multiple groups - check per group
    per_group <- data %>%
      dplyr::group_by(.data[[facet_col]]) %>%
      dplyr::summarise(n_icons = dplyr::n_distinct(pos), .groups = "drop")
    
    too_big <- per_group %>% dplyr::filter(n_icons > max_icons)
    
    if (nrow(too_big) > 0) {
      bad <- paste0(too_big[[facet_col]], " (", too_big$n_icons, ")", collapse = ", ")
      cli::cli_abort(c(
        "Too many icons in facet group(s).",
        "x" = "Maximum is {max_icons} per group.",
        "i" = "Offending groups: {bad}",
        " " = "",
        "i" = "Fix - reduce {.code sample_size} per group:",
        " " = "  {.code process_data(..., high_group_var = ..., sample_size = {max_icons})}"
      ),
      call = NULL)
    }
  }
  
  invisible(data)
}

# ******************************************************************************
# 05 Layer validators ----------------------------------------------------------
# ******************************************************************************

# ******************************************************************************
## 05.01 Single geom_pop Layer -------------------------------------------------
# ******************************************************************************

#' Validate only one geom_pop per plot
#' 
#' @param plot_obj ggplot object (can be NULL)
#' @return Invisible NULL if valid
#' @keywords internal
#' @noRd
validate_single_geom_pop <- function(plot_obj) {
  
  if (is.null(plot_obj) || length(plot_obj$layers) == 0) {
    return(invisible(NULL))
  }
  
  # Check if any existing layer is a geom_pop
  has_geom_pop <- any(vapply(plot_obj$layers, function(layer) {
    inherits(layer$geom, "GeomImage") && 
      !is.null(layer$aes_params) || 
      inherits(layer, "ggpop_geom_pop") ||
      ("ggpop_geom_pop" %in% class(layer))
  }, logical(1)))
  
  if (has_geom_pop) {
    cli::cli_abort(c(
      "Multiple {.fn geom_pop} layers detected.",
      "x" = "Only ONE {.fn geom_pop} layer is allowed per plot.",
      " " = "",
      "!" = "Why this is an error:",
      " " = "  - Multiple layers create legend conflicts",
      " " = "  - Only the last layer's icons are shown in the legend",
      " " = "",
      "i" = "Fix - Option 1: Combine data into one {.fn geom_pop} call:",
      " " = "  {.code df_all <- bind_rows(df1, df2, df3)}",
      " " = "  {.code ggplot() + geom_pop(data = df_all, aes(icon = icon, color = group))}",
      " " = "",
      "i" = "Option 2: Create separate plots and combine with patchwork:",
      " " = "  {.code library(patchwork)}",
      " " = "  {.code p1 <- ggplot() + geom_pop(data = df1, ...)}",
      " " = "  {.code p2 <- ggplot() + geom_pop(data = df2, ...)}",
      " " = "  {.code p1 | p2}",
      " " = "",
      "i" = "Option 3: Use faceting if appropriate:",
      " " = "  {.code ggplot() + geom_pop(data = df_all, aes(...)) + facet_wrap(~ group)}"
    ),
    call = NULL)
  }
  
  invisible(NULL)
}

# ******************************************************************************
# 06 Warning validators (soft) -------------------------------------------------
# ******************************************************************************

# ******************************************************************************
## 06.01 Size Conflict ---------------------------------------------------------
# ******************************************************************************

#' Warn about size specified both in aes() and as parameter
#' 
#' @param combined_mapping Combined aesthetic mappings
#' @param missing_size Logical indicating if size parameter was missing
#' @param size Size parameter value
#' @return Invisible NULL
#' @keywords internal
#' @noRd
warn_size_conflict <- function(combined_mapping, missing_size, size) {
  
  if ("size" %in% names(combined_mapping) && !missing_size) {
    cli::cli_warn(c(
      "`size` specified both in {.code aes()} and as a parameter.",
      " " = "",
      "!" = "What happens:",
      " " = "  - {.code aes(size = <variable>)} controls icon size per row",
      " " = "  - The parameter {.code geom_pop(aes(), size = {size})} will be IGNORED",
      " " = "",
      "i" = "Tip:",
      " " = "  - Use ONLY {.code aes(size = <variable>)} for data-driven sizes, OR",
      " " = "  - Remove {.field size} from {.code aes()} and set fixed size via {.code geom_pop(size = ...)}"
    ),
    call = NULL)
  }
  
  invisible(NULL)
}

# ******************************************************************************
## 06.02 X/Y Aesthetics Ignored ------------------------------------------------
# ******************************************************************************

#' Warn if x or y aesthetics are mapped (they will be ignored)
#' 
#' @param combined_mapping Combined aesthetic mappings
#' @return Invisible NULL
#' @keywords internal
#' @noRd
warn_xy_aesthetics_ignored <- function(combined_mapping) {
  
  has_x <- "x" %in% names(combined_mapping)
  has_y <- "y" %in% names(combined_mapping)
  
  if (has_x || has_y) {
    
    mapped_vars <- c(
      if (has_x) "x",
      if (has_y) "y"
    )
    
    # Try to extract what they mapped to
    mapped_to <- sapply(mapped_vars, function(aes_name) {
      tryCatch({
        expr <- combined_mapping[[aes_name]]
        if (rlang::is_symbol(expr)) {
          paste0("<variable: ", rlang::as_name(expr), ">")
        } else {
          deparse(expr)
        }
      }, error = function(e) "<unknown>")
    })
    
    cli::cli_warn(c(
      "`{mapped_vars}` aesthetic{?s} will be IGNORED.",
      " " = "",
      "!" = "What you did:",
      " " = "  You provided: {.code aes({paste0(mapped_vars, ' = ', mapped_to, collapse = ', ')})}",
      " " = "",
      "x" = "Why this doesn't work:",
      " " = "  - {.fn geom_pop} uses a circular coordinate system",
      " " = "  - {.field x} and {.field y} positions are calculated internally from {.field pos}",
      " " = "  - User-provided {.field x}/{.field y} mappings are overwritten",
      " " = "",
      "i" = "Fix - remove {.field {mapped_vars}} from {.code aes()}:",
      " " = "  {.code # Before:}",
      " " = "  {.code aes(icon = icon, group = sex, x = sex, y = sex)}",
      " " = "",
      " " = "",
      " " = "  {.code # After:}",
      " " = "  {.code aes(icon = icon, group = sex)}",
      " " = "",
      "!" = "Note:",
      " " = "  Icon positions are determined by the circular packing algorithm,",
      " " = "  not by x/y aesthetics."
    ),
    call = NULL)
  }
  
  invisible(NULL)
}

# ******************************************************************************
## 06.03 Faceting Caution ------------------------------------------------------
# ******************************************************************************

#' Warn about faceting/grouping caution
#' 
#' @param data Data frame
#' @param facet_explicit Logical indicating if facet was explicitly provided
#' @param facet_col Facet column name (can be NULL)
#' @return Invisible NULL
#' @keywords internal
#' @noRd
warn_faceting_caution <- function(data, facet_explicit, facet_col) {
  
  has_multi_groups <- "group" %in% names(data) && dplyr::n_distinct(data$group) > 1
  
  # Determine what message to show
  if (!has_multi_groups && !facet_explicit) {
    return(invisible(NULL))
  }
  
  # Build group variable message
  group_var_msg <- if (facet_explicit) {
    facet_col
  } else if (has_multi_groups) {
    "group"
  } else {
    NULL
  }
  
  if (is.null(group_var_msg)) {
    return(invisible(NULL))
  }
  
  cli::cli_warn(c(
    "Facet / grouping caution.",
    " " = "",
    "!" = "Why you are seeing this warning:",
    if (has_multi_groups && !facet_explicit) {
      c(
        " " = "  - The data contains multiple groups in {.field data$group}",
        " " = "    (often created by {.code process_data(high_group_var = ...)})",
        " " = "  - If the plot is not faceted, icons from different groups may overlap"
      )
    } else {
      character(0)
    },
    if (facet_explicit) {
      c(
        " " = "  - You provided {.code facet = {facet_col}} inside {.fn geom_pop}",
        " " = "  - Icons are positioned per {.field {facet_col}}",
        " " = "  - If the final plot is not faceted, everything may render into one panel"
      )
    } else {
      character(0)
    },
    " " = "",
    "i" = "Recommended patterns:",
    if (!is.null(group_var_msg)) {
      c(
        " " = "  - Facet in ggplot2:",
        " " = "    {.code ggplot() + geom_pop(..., facet = {group_var_msg}) + facet_wrap(~ {group_var_msg})}"
      )
    } else {
      character(0)
    },
    " " = "",
    " " = "  - Alternative layout:",
    " " = "    Create one plot per subgroup and combine with cowplot or patchwork",
    " " = "",
    "i" = "If you want one pooled circle:",
    " " = "  - Re-run {.fn process_data} without {.code high_group_var}"
  ),
  call = NULL)
  
  invisible(NULL)
}

# ******************************************************************************
## 06.04 Multiple Icons Per Group ----------------------------------------------
# ******************************************************************************

#' Warn if multiple different icons exist per legend group
#' 
#' @param data Data frame with icon column
#' @param legend_var Name of the variable used for legend grouping
#' @param icon_var Name of the icon column
#' @return Invisible NULL
#' @keywords internal
#' @noRd
warn_multiple_icons_per_group <- function(data, legend_var, icon_var) {
  
  if (is.null(legend_var) || is.null(icon_var)) {
    return(invisible(NULL))
  }
  
  if (!legend_var %in% names(data) || !icon_var %in% names(data)) {
    return(invisible(NULL))
  }
  
  # Count unique icons per legend group
  icon_counts <- data %>%
    dplyr::group_by(.data[[legend_var]]) %>%
    dplyr::summarise(
      n_icons = dplyr::n_distinct(.data[[icon_var]], na.rm = TRUE),
      icons = paste(unique(.data[[icon_var]]), collapse = ", "),
      .groups = "drop"
    ) %>%
    dplyr::filter(n_icons > 1)
  
  if (nrow(icon_counts) > 0) {
    
    # Build detailed message about which groups have multiple icons
    problem_groups <- icon_counts %>%
      dplyr::mutate(
        msg = paste0(
          "  - ", .data[[legend_var]], 
          ": ", n_icons, " icons (", icons, ")"
        )
      ) %>%
      dplyr::pull(msg)
    
    cli::cli_warn(c(
      "Multiple icons per color/group detected.",
      " " = "",
      "!" = "Why you are seeing this warning:",
      " " = "  The legend can only display ONE icon per group, but some groups have multiple:",
      " " = "",
      problem_groups,
      " " = "",
      "i" = "What happens:",
      " " = "  - The most frequent icon for each group will be shown in the legend",
      " " = "  - Other icons in that group will still appear in the plot",
      " " = "  - This may confuse viewers if icons have different meanings",
      " " = "",
      "i" = "Recommended fixes:",
      " " = "",
      " " = "  Option 1: Use consistent icons per group",
      " " = "    {.code df <- df %>% mutate(icon = case_when(}",
      " " = "    {.code   sex == 'A' ~ 'male',}",
      " " = "    {.code   sex == 'B' ~ 'female'}",
      " " = "    {.code ))}",
      " " = "",
      " " = "  Option 2: Create a separate grouping variable",
      " " = "    {.code df <- df %>% mutate(group = paste(sex, icon, sep = '_'))}",
      " " = "    {.code ggplot() + geom_pop(aes(icon = icon, color = group))}",
      " " = "",
      " " = "  Option 3: Set legend_icons = FALSE to use point markers",
      " " = "    {.code geom_pop(..., legend_icons = FALSE)}"
    ),
    call = NULL)
  }
  
  invisible(NULL)
}


# ******************************************************************************
## 06.05 Alpha Parameter Validation --------------------------------------------
# ******************************************************************************

#' Validate alpha parameter (for geom_icon_point)
#' 
#' @param alpha_val Alpha parameter value
#' @return Invisible alpha_val if valid
#' @keywords internal
#' @noRd
validate_alpha_parameter <- function(alpha_val) {
  
  if (is.null(alpha_val)) return(invisible(NULL))
  
  # Check if it's a name/symbol (user tried to pass a column name)
  if (is.symbol(alpha_val) || is.name(alpha_val)) {
    cli::cli_abort(c(
      "Invalid `alpha` parameter.",
      "x" = "You passed: {.code alpha = {deparse(alpha_val)}}",
      " " = "",
      "!" = "Problem:",
      " " = "  Parameters expect a single numeric value (e.g., {.code alpha = 0.5})",
      " " = "  To map alpha to a data column, use {.code aes()} instead",
      " " = "",
      "i" = "Fix:",
      " " = "  {.code # Wrong:}",
      " " = "  {.code geom_icon_point(alpha = point_size, color = 'blue')}",
      " " = "",
      " " = "  {.code # Correct:}",
      " " = "  {.code geom_icon_point(aes(alpha = point_size), color = 'blue')}"
    ),
    call = NULL)
  }
  
  # Validate it's a single numeric value in valid range
  if (!is.numeric(alpha_val) || length(alpha_val) != 1 ||
      is.na(alpha_val) || alpha_val < 0 || alpha_val > 1) {
    
    invalid_reason <- if (!is.numeric(alpha_val)) {
      class(alpha_val)[1]
    } else if (length(alpha_val) != 1) {
      paste0("vector of length ", length(alpha_val))
    } else if (is.na(alpha_val)) {
      "NA"
    } else {
      as.character(alpha_val)
    }
    
    cli::cli_abort(c(
      "Invalid `alpha` value.",
      "x" = "Expected: Single numeric value between 0 and 1",
      "i" = "Received: {invalid_reason}",
      " " = "",
      "i" = "Valid range: 0 (transparent) to 1 (opaque)",
      " " = "",
      "i" = "Examples:",
      " " = "  {.code alpha = 0.5}   # Semi-transparent",
      " " = "  {.code alpha = 1.0}   # Fully opaque (default)",
      " " = "  {.code alpha = 0.3}   # More transparent"
    ),
    call = NULL)
  }
  
  # Soft warning: alpha too low
  if (alpha_val < 0.1 && alpha_val > 0) {
    cli::cli_warn(c(
      "Very low `alpha` value.",
      "!" = "{.val {alpha_val}} is very low.",
      "i" = "Icons may be nearly invisible.",
      " " = "",
      "i" = "Recommended:",
      " " = "  Use alpha >= 0.1 for visible icons",
      " " = "  Default is 1.0 (fully opaque)",
      " " = "  Typical range: 0.3-1.0"
    ),
    call = NULL)
  }
  
  invisible(alpha_val)
}

# ******************************************************************************
## 06.06 Alpha Conflict Warning ------------------------------------------------
# ******************************************************************************

#' Warn about alpha specified both in aes() and as parameter
#' 
#' @param combined_mapping Combined aesthetic mappings
#' @param extra_args Additional arguments (...)
#' @return Invisible NULL
#' @keywords internal
#' @noRd
warn_alpha_conflict <- function(combined_mapping, extra_args) {
  
  if ("alpha" %in% names(combined_mapping) && "alpha" %in% names(extra_args)) {
    cli::cli_warn(c(
      "`alpha` specified both in {.code aes()} and as a parameter.",
      " " = "",
      "!" = "What happens:",
      " " = "  - {.code aes(alpha = <variable>)} controls transparency per row",
      " " = "  - The parameter {.code alpha = {extra_args$alpha}} will be IGNORED",
      " " = "",
      "i" = "Tip:",
      " " = "  - Use ONLY {.code aes(alpha = <variable>)} for data-driven transparency, OR",
      " " = "  - Remove {.field alpha} from {.code aes()} and set fixed alpha via parameter"
    ),
    call = NULL)
  }
  
  invisible(NULL)
}

# ******************************************************************************
## 06.07 Mixed Legend Icons Warning --------------------------------------------
# ******************************************************************************

#' Warn about mixed legend_icons settings across layers
#' 
#' @param legend_icons Current legend_icons setting
#' @return Invisible NULL
#' @keywords internal
#' @noRd
warn_mixed_legend_icons <- function(legend_icons) {
  
  # Initialize if needed
  if (is.null(.ggpop_env$legend_settings)) {
    .ggpop_env$legend_settings <- list()
  }
  
  # Add current setting
  .ggpop_env$legend_settings <- c(.ggpop_env$legend_settings, legend_icons)
  
  # Check for mixed settings
  settings_vec <- unlist(.ggpop_env$legend_settings)
  
  if (length(settings_vec) > 1 && 
      any(settings_vec) && 
      any(!settings_vec) &&
      !isTRUE(.ggpop_env$has_warned_mixed_legend)) {
    
    cli::cli_warn(c(
      "Mixed {.field legend_icons} settings detected.",
      " " = "",
      "!" = "Layers have inconsistent settings:",
      " " = "  - Some layer(s): {.val TRUE}",
      " " = "  - Other layer(s): {.val FALSE}",
      " " = "",
      "i" = "Recommendation:",
      " " = "  Use consistent settings across all {.fn geom_icon_point} layers",
      " " = "  Either all TRUE, or all FALSE (not mixed)"
    ),
    call = NULL)
    
    .ggpop_env$has_warned_mixed_legend <- TRUE
  }
  
  # Auto-reset after reasonable accumulation
  if (length(.ggpop_env$legend_settings) > 20) {
    .ggpop_env$legend_settings <- list()
    .ggpop_env$has_warned_mixed_legend <- FALSE
  }
  
  invisible(NULL)
}


# ******************************************************************************
## 06.08 Size Conflict for geom_icon_point -------------------------------------
# ******************************************************************************

#' Warn about size specified both in aes() and as parameter for geom_icon_point
#' 
#' @param size_mapped Logical - is size mapped in aes()?
#' @param size_param Size parameter value
#' @param size_missing Logical - was size parameter missing?
#' @return Invisible NULL
#' @keywords internal
#' @noRd
warn_size_conflict_icon_point <- function(size_mapped, size_param, size_missing) {
  
  # DEBUG
  message("DEBUG in warn_size_conflict_icon_point:")
  message("  size_mapped: ", size_mapped, " (class: ", class(size_mapped), ")")
  message("  size_missing: ", size_missing, " (class: ", class(size_missing), ")")
  message("  size_param: ", size_param)
  
  # Ensure they are logical
  size_mapped <- isTRUE(size_mapped)
  size_missing <- isTRUE(size_missing)
  
  message("  After isTRUE:")
  message("  size_mapped: ", size_mapped)
  message("  size_missing: ", size_missing)
  
  # Warn if both mapped AND provided as parameter
  if (size_mapped && !size_missing) {
    cli::cli_warn(c(
      "`size` specified both in {.code aes()} and as a parameter.",
      " " = "",
      "!" = "What happens:",
      " " = "  - {.code aes(size = <variable>)} would control icon size per point",
      " " = "  - But the parameter {.code size = {size_param}} will OVERRIDE it",
      " " = "",
      "i" = "Fix - choose one approach:",
      " " = "  Option 1: Data-driven sizes (remove size parameter)",
      " " = "    {.code geom_icon_point(aes(icon = icon, size = point_size))}",
      " " = "",
      " " = "  Option 2: Fixed size (remove size from aes)",
      " " = "    {.code geom_icon_point(aes(icon = icon), size = 2)}"
    ),
    call = NULL)
  }
  
  invisible(NULL)
}

# ******************************************************************************
# 07 Composite validators ------------------------------------------------------
# ******************************************************************************

# ******************************************************************************
## 07.01 All Parameters --------------------------------------------------------
# ******************************************************************************

#' Run all parameter validations for geom_pop
#' 
#' @param stroke_width stroke_width parameter
#' @param dpi dpi parameter
#' @param size size parameter
#' @param missing_size Logical indicating if size was missing
#' @param arrange arrange parameter
#' @param legend_icons legend_icons parameter
#' @param seed seed parameter
#' @param dots Additional arguments (...)
#' @return Invisible NULL
#' @keywords internal
#' @noRd
validate_all_parameters <- function(stroke_width, dpi, size, missing_size, 
                                    arrange, legend_icons, seed, dots) {
  
  validate_stroke_width(stroke_width)
  validate_dpi(dpi)
  validate_size(size, missing_size)
  validate_arrange(arrange)
  validate_legend_icons(legend_icons)
  validate_seed(seed)
  validate_alpha_not_parameter(dots)
  
  invisible(NULL)
}

# ******************************************************************************
## 07.02 All Data --------------------------------------------------------------
# ******************************************************************************

#' Run all data validations for geom_pop
#' 
#' @param data Data frame
#' @param icon_var Icon column name
#' @return Invisible data
#' @keywords internal
#' @noRd
validate_all_data <- function(data, icon_var) {
  
  validate_data_is_dataframe(data)
  validate_no_reserved_columns(data)
  validate_icon_column(data, icon_var)
  
  invisible(data)
}

# ******************************************************************************
## 07.03 All Aesthetics --------------------------------------------------------
# ******************************************************************************

#' Run all aesthetic mapping validations for geom_pop
#' 
#' @param mapping_list Layer aesthetic mappings
#' @param inherited_mapping_list Inherited aesthetic mappings
#' @param data Data frame
#' @return Invisible icon variable name
#' @keywords internal
#' @noRd
validate_all_aesthetics <- function(mapping_list, inherited_mapping_list, data) {
  
  combined_mapping <- c(inherited_mapping_list, mapping_list)
  
  icon_var <- validate_icon_aesthetic(mapping_list, inherited_mapping_list, data)
  validate_no_image_aesthetic(mapping_list)
  validate_no_fill_aesthetic(combined_mapping)
  validate_stroke_width_not_aesthetic(combined_mapping)
  
  invisible(icon_var)
}

# ******************************************************************************
## 07.04 All Warnings ----------------------------------------------------------
# ******************************************************************************

#' Run all warning checks for geom_pop
#' 
#' @param combined_mapping Combined aesthetic mappings
#' @param missing_size Logical indicating if size was missing
#' @param size Size parameter value
#' @param data Data frame
#' @param facet_explicit Logical indicating if facet was explicitly provided
#' @param facet_col Facet column name (can be NULL)
#' @return Invisible NULL
#' @keywords internal
#' @noRd
warn_all_geom_pop <- function(combined_mapping, missing_size, size, 
                              data, facet_explicit, facet_col, dots = list()) {
  
  warn_size_conflict(combined_mapping, missing_size, size)
  warn_alpha_conflict(combined_mapping, dots)
  warn_xy_aesthetics_ignored(combined_mapping)
  warn_faceting_caution(data, facet_explicit, facet_col)
  
  invisible(NULL)
}

# ******************************************************************************
# End of file ------------------------------------------------------------------
# ****************************************************************************** 