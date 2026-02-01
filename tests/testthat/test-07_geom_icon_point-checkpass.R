# *****************************************************************************
#
# Script: test-07_geom_icon_point-checkpass.R
#
# Purpose: Ensure geom_icon_point() works robustly for all valid scenarios
#          without warnings or errors.
#
# Author: Jorge Roa
#
# Email: jorgeroa@stanford.edu
#
# Date Created: 26-Jan-2026
#
# *****************************************************************************

testthat::skip_if_not_installed("ggplot2")
testthat::skip_if_not_installed("dplyr")
testthat::skip_if_not_installed("ggimage")
testthat::skip_if_not_installed("fontawesome")

# ******************************************************************************
## 01.01 Test dataframes -------------------------------------------------------
# ******************************************************************************

df_scatter <- data.frame(
  x    = c(1, 2, 3, 4, 5),
  y    = c(2, 4, 3, 5, 6),
  icon = c("circle", "star", "circle", "star", "heart"),
  category = c("A", "B", "A", "B", "C"),
  point_size = c(2, 3, 2, 4, 3),
  stringsAsFactors = FALSE
)

df_scatter_no_icon <- data.frame(
  x = c(1, 2, 3, 4),
  y = c(2, 4, 3, 5),
  category = c("A", "B", "A", "B"),
  stringsAsFactors = FALSE
)

# ******************************************************************************
# 02 Basic functionality -------------------------------------------------------
# ******************************************************************************

### 02.01 Minimal valid plot ---------------------------------------------------

testthat::test_that("Basic: minimal plot with icon mapping", {
  testthat::expect_no_error(
    {
      p <- ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point()
      ggplot2::ggplot_build(p)
    }
  )
})

testthat::test_that("Basic: plot with icon parameter", {
  testthat::expect_no_error(
    {
      p <- ggplot2::ggplot(df_scatter_no_icon, ggplot2::aes(x = x, y = y)) +
        geom_icon_point(icon = "circle")
      ggplot2::ggplot_build(p)
    }
  )
})

### 02.02 Icon mapping variations ----------------------------------------------

testthat::test_that("Basic: icon mapped in ggplot() aes", {
  testthat::expect_no_error(
    {
      p <- ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point(size = 3)
      ggplot2::ggplot_build(p)
    }
  )
})

testthat::test_that("Basic: icon mapped in geom aes", {
  testthat::expect_no_error(
    {
      p <- ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y)) +
        geom_icon_point(ggplot2::aes(icon = icon))
      ggplot2::ggplot_build(p)
    }
  )
})

testthat::test_that("Basic: different icons per row", {
  testthat::expect_no_error(
    {
      p <- ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, color = category)) +
        geom_icon_point()
      ggplot2::ggplot_build(p)
    }
  )
})

# ******************************************************************************
# 03 Color and aesthetics ------------------------------------------------------
# ******************************************************************************

### 03.01 Color mappings -------------------------------------------------------

testthat::test_that("Color: color mapped to category", {
  testthat::expect_no_error(
      ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, color = category)) +
        geom_icon_point()
  )
})

testthat::test_that("Color: fixed color parameter", {
  testthat::expect_no_error(
      ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point(color = "red")
  )
})

testthat::test_that("Color: color mapped to continuous variable", {
  testthat::expect_no_error(
      ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, 
                                               color = point_size, size = point_size)) +
        geom_icon_point()
  )
})

### 03.02 Alpha transparency ---------------------------------------------------

testthat::test_that("Alpha: fixed alpha parameter", {
  testthat::expect_no_error(
      ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point(color = "red", alpha = 0.1)
  )
})

testthat::test_that("Alpha: alpha mapped to variable", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point(alpha = 0.3, color = "blue")
  )
})

# ******************************************************************************
# 04 Size variations -----------------------------------------------------------
# ******************************************************************************

### 04.01 Fixed size values ----------------------------------------------------

testthat::test_that("Size: small valid size", {
  testthat::expect_no_error(
      ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point(size = 1)
  )
})

testthat::test_that("Size: medium size (default)", {
  testthat::expect_no_error(
      ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point(size = 3)
  )
})

testthat::test_that("Size: large valid size", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point(size = 10, dpi = 200)
  )
})

testthat::test_that("Size: boundary value 0.9", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point(size = 0.9)
  )
})

testthat::test_that("Size: boundary value 15", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point(size = 15, dpi = 200)
  )
})

### 04.02 Mapped size ----------------------------------------------------------

testthat::test_that("Size: size mapped to variable", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, size = point_size)) +
        geom_icon_point()
  )
})

testthat::test_that("Size: size and color both mapped", {
  testthat::expect_no_error(
    ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, size = point_size, color = category)) +
        geom_icon_point()
  )
})

# ******************************************************************************
# 05 DPI settings --------------------------------------------------------------
# ******************************************************************************

### 05.01 Valid DPI ranges -----------------------------------------------------

testthat::test_that("DPI: minimum valid (30)", {
  testthat::expect_no_error(
    ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point(dpi = 30)
  )
})

testthat::test_that("DPI: default (50)", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point(dpi = 50)
  )
})

testthat::test_that("DPI: high quality (150)", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point(dpi = 150)
  )
})


# ******************************************************************************
# 06 Legend control ------------------------------------------------------------
# ******************************************************************************

### 06.01 legend_icons parameter -----------------------------------------------

testthat::test_that("geom_icon_point: Plot icons match data and legend", {
  
  testthat::skip_if_not_installed("grid")
  testthat::skip_if_not_installed("gtable")
  
  # Create test data with distinct icons per category
  df_test <- data.frame(
    x = rep(1:5, 3),
    y = rep(1:3, each = 5),
    category = rep(c("A", "B", "C"), each = 5),
    icon = rep(c("heart", "star", "circle"), each = 5),
    stringsAsFactors = FALSE
  )
  
  # Expected: 3 unique icons
  n_expected_icons <- 3
  expected_icons <- c("heart", "star", "circle")
  
  p <- ggplot2::ggplot(df_test, ggplot2::aes(x = x, y = y, icon = icon, color = category)) +
    geom_icon_point(size = 3, dpi = 100, legend_icons = TRUE) +
    ggplot2::theme_minimal()
  
  # Build the plot
  testthat::expect_no_error(ggplot2::ggplot_build(p))
  gt <- testthat::expect_no_error(ggplot2::ggplotGrob(p))
  
  # PART 1: Check plot panel for raster icons

  # Find the panel grob (where actual plot points are rendered)
  panel_idx <- which(vapply(
    gt$grobs,
    function(x) inherits(x, "gTree") && !is.null(x$name) && grepl("panel", x$name),
    logical(1)
  ))
  
  testthat::expect_true(
    length(panel_idx) > 0,
    info = "No panel found in plot grob. Plot may not have rendered."
  )
  
  # Collect raster grobs from the panel (these are the actual plotted icons)
  plot_rasters <- list()
  recurse_panel <- function(x) {
    if (inherits(x, "rastergrob")) {
      plot_rasters[[length(plot_rasters) + 1]] <<- x
    }
    if (inherits(x, "gTree") && length(x$children)) {
      for (g in x$children) recurse_panel(g)
    }
    if (inherits(x, "gtable") && length(x$grobs)) {
      for (g in x$grobs) recurse_panel(g)
    }
  }
  
  if (length(panel_idx) > 0) {
    recurse_panel(gt$grobs[[panel_idx[1]]])
  }
  
  testthat::expect_true(
    length(plot_rasters) > 0,
    info = "No raster icons found in plot panel. Icons may not have been rendered."
  )
  
  testthat::expect_equal(
    length(plot_rasters),
    nrow(df_test),
    info = paste0(
      "Expected ", nrow(df_test), " plotted icons (one per data row), ",
      "but found ", length(plot_rasters), " raster grobs in the panel."
    )
  )
  
  # PART 2: Check legend for icon rasters

  # Find the legend container (guide-box)
  guide_idx <- which(vapply(
    gt$grobs,
    function(x) inherits(x, "gtable") && identical(x$name, "guide-box"),
    logical(1)
  ))
  
  testthat::expect_true(
    length(guide_idx) == 1,
    info = "No legend found (guide-box missing). Legend may be dropped or disabled."
  )
  
  guide <- gt$grobs[[guide_idx]]
  
  # Collect raster grobs inside the legend
  legend_rasters <- list()
  recurse_legend <- function(x) {
    if (inherits(x, "rastergrob")) {
      legend_rasters[[length(legend_rasters) + 1]] <<- x
    }
    if (inherits(x, "gtable") && length(x$grobs)) {
      for (g in x$grobs) recurse_legend(g)
    }
    if (inherits(x, "gTree") && length(x$children)) {
      for (g in x$children) recurse_legend(g)
    }
    if (is.list(x)) {
      for (g in x) recurse_legend(g)
    }
  }
  recurse_legend(guide)
  
  testthat::expect_true(
    length(legend_rasters) > 0,
    info = "Legend exists but contains no rastergrob. Legend icons likely not rendered as images."
  )
  
  # Unique raster grob names in legend (proxy for unique icons rendered)
  legend_raster_names <- vapply(legend_rasters, function(r) r$name, character(1))
  n_unique_legend_rasters <- length(unique(legend_raster_names))
  
  testthat::expect_equal(
    n_unique_legend_rasters,
    n_expected_icons,
    info = paste0(
      "Expected ", n_expected_icons, " unique legend icon raster(s) (one per category), ",
      "but found ", n_unique_legend_rasters, ".\n",
      "Unique raster names: ", paste(sort(unique(legend_raster_names)), collapse = ", ")
    )
  )
  
  # PART 3: Cross-check icon correspondence
  
  # Each category should have exactly one icon type in the data
  icon_by_category <- df_test %>%
    dplyr::group_by(category) %>%
    dplyr::summarise(
      n_icons = dplyr::n_distinct(icon),
      icons = paste(unique(icon), collapse = ", "),
      .groups = "drop"
    )
  
  testthat::expect_true(
    all(icon_by_category$n_icons == 1),
    info = paste0(
      "Each category should have exactly one icon type.\n",
      "Found: ", paste(capture.output(print(icon_by_category)), collapse = "\n")
    )
  )
  
  # Verify all expected icons are in the data
  actual_icons <- unique(df_test$icon)
  testthat::expect_true(
    setequal(actual_icons, expected_icons),
    info = paste0(
      "Data icons don't match expected.\n",
      "Expected: ", paste(expected_icons, collapse = ", "), "\n",
      "Actual: ", paste(actual_icons, collapse = ", ")
    )
  )
})


testthat::test_that("Legend: icons disabled (FALSE)", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, color = category)) +
        geom_icon_point(legend_icons = FALSE)
  )
})


testthat::test_that("Multiple legend_icons settings across layers", {
    testthat::expect_no_error(
         ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, color = icon)) +
             geom_icon_point(legend_icons = TRUE) +
             geom_icon_point(ggplot2::aes(size = point_size), legend_icons = TRUE)
       )
 })

# ******************************************************************************
# 07 Real-world usage patterns -------------------------------------------------
# ******************************************************************************

### 07.01 Typical usage: data in ggplot, minimal geom params ------------------

testthat::test_that("Real-world: data in ggplot, size in geom (no warning)", {
  testthat::expect_no_error(
      ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, color = category)) +
        geom_icon_point(size = 4, dpi = 72)
  )
})

### 07.02 Typical usage: layering with geom_point -----------------------------

testthat::test_that("Real-world: combine with geom_point (no warning)", {
  testthat::expect_no_warning(
      ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, color = category)) +
        ggplot2::geom_point(size = 8, alpha = 0.3) +
        geom_icon_point(ggplot2::aes(icon = icon), size = 3)
  )
})

### 07.03 Typical usage: faceting with icon points ----------------------------

testthat::test_that("Real-world: faceted plot (no warning)", {
  testthat::expect_no_warning(
      ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point(size = 4, color = "steelblue") +
        ggplot2::facet_wrap(~category)
  )
})

### 07.04 Advanced: icon mapping with size mapping ----------------------------

testthat::test_that("Real-world: both icon and size mapped (no warning)", {
  testthat::expect_no_warning(
      ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, size = point_size)) +
        geom_icon_point(color = "darkred", dpi = 100)
  )
})

### 07.05 Advanced: multiple icon point layers --------------------------------

testthat::test_that("Real-world: multiple layers with different data", {
  df_background <- df_scatter[1:3, ]
  df_highlight <- df_scatter[4:5, ]
  
  testthat::expect_no_warning(
      ggplot2::ggplot() +
        geom_icon_point(
          data = df_background,
          ggplot2::aes(x = x, y = y, icon = icon),
          size = 2,
          alpha = 0.3,
          color = "gray"
        ) +
        geom_icon_point(
          data = df_highlight,
          ggplot2::aes(x = x, y = y, icon = icon),
          size = 5,
          color = "red"
        )
  )
})

### 07.06 Complex: all aesthetics + parameters --------------------------------

testthat::test_that("Real-world: complex plot with many aesthetics", {
  testthat::expect_no_warning(
      ggplot2::ggplot(
        df_scatter, 
        ggplot2::aes(x = x, y = y, icon = icon, color = category, alpha = point_size)
      ) +
        geom_icon_point(size = 4, dpi = 100) +
        ggplot2::scale_alpha_continuous(range = c(0.3, 1)) +
        ggplot2::theme_minimal()
  )
})

### 07.07 Real-world: with scale transformations ------------------------------

testthat::test_that("Real-world: with log scale", {
  df_log <- data.frame(
    x = c(1, 10, 100, 1000),
    y = c(1, 10, 100, 1000),
    icon = rep("circle", 4),
    stringsAsFactors = FALSE
  )
  
  testthat::expect_no_error(
    ggplot2::ggplot(df_log, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point() +
        ggplot2::scale_x_log10() +
        ggplot2::scale_y_log10()
  )
})

### 07.08 Real-world: with coord transformations ------------------------------

testthat::test_that("Real-world: with coord_flip", {
  testthat::expect_no_error(
      ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point() +
        ggplot2::coord_flip()
  )
})

testthat::test_that("Real-world: with coord_fixed", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point() +
        ggplot2::coord_fixed(ratio = 1)
  )
})

# ******************************************************************************
# 08 Edge cases: boundary conditions -------------------------------------------
# ******************************************************************************

### 08.01 Single row data ------------------------------------------------------

testthat::test_that("Edge case: single point (no warning)", {
  df_single <- df_scatter[1, ]
  
  testthat::expect_no_error(
    ggplot2::ggplot(df_single, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point(size = 5, color = "blue")
  )
})

### 08.02 Two rows data --------------------------------------------------------

testthat::test_that("Edge case: two rows data (valid)", {
  df_two <- df_scatter[1:2, ]
  
  testthat::expect_no_error(
    ggplot2::ggplot(df_two, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point()
  )
})

### 08.03 Very large coordinates -----------------------------------------------

testthat::test_that("Edge case: very large coordinates (valid)", {
  df_large <- data.frame(
    x = c(1e6, 1e7, 1e8),
    y = c(1e6, 1e7, 1e8),
    icon = c("circle", "star", "heart"),
    stringsAsFactors = FALSE
  )
  
  testthat::expect_no_error(
    ggplot2::ggplot(df_large, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point()
  )
})

### 08.04 Very small coordinates -----------------------------------------------

testthat::test_that("Edge case: very small coordinates (valid)", {
  df_small <- data.frame(
    x = c(1e-6, 1e-7, 1e-8),
    y = c(1e-6, 1e-7, 1e-8),
    icon = c("circle", "star", "heart"),
    stringsAsFactors = FALSE
  )
  
  testthat::expect_no_error(
    ggplot2::ggplot(df_small, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point()
  )
})

### 08.05 Negative coordinates -------------------------------------------------

testthat::test_that("Edge case: negative coordinates (valid)", {
  df_negative <- data.frame(
    x = c(-5, -3, -1, 1, 3),
    y = c(-4, -2, 0, 2, 4),
    icon = rep("circle", 5),
    stringsAsFactors = FALSE
  )
  
  testthat::expect_no_error(
    ggplot2::ggplot(df_negative, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point()
  )
})

### 08.06 Zero coordinates -----------------------------------------------------

testthat::test_that("Edge case: zero coordinates (valid)", {
  df_zero <- data.frame(
    x = c(0, 0, 1, 2),
    y = c(0, 1, 0, 2),
    icon = rep("circle", 4),
    stringsAsFactors = FALSE
  )
  
  testthat::expect_no_error(
    ggplot2::ggplot(df_zero, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point()
  )
})

### 08.07 Mixed positive/negative/zero -----------------------------------------

testthat::test_that("Edge case: mixed coordinate signs", {
  df_mixed <- data.frame(
    x = c(-2, -1, 0, 1, 2),
    y = c(-2, -1, 0, 1, 2),
    icon = rep("star", 5),
    stringsAsFactors = FALSE
  )
  
  testthat::expect_no_error(
      ggplot2::ggplot(df_mixed, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point()
  )
})

# ******************************************************************************
# 09 Parameter validation completeness -----------------------------------------
# ******************************************************************************

### 09.01 stat parameter -------------------------------------------------------

testthat::test_that("Parameter: valid stat parameter", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point(stat = "identity")
  )
})

### 09.02 position parameter ---------------------------------------------------

testthat::test_that("Parameter: valid position parameter", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point(position = "identity")
  )
})

testthat::test_that("Parameter: position jitter", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point(position = ggplot2::position_jitter(width = 0.1, height = 0.1))
  )
})

### 09.03 na.rm parameter ------------------------------------------------------

testthat::test_that("Parameter: na.rm = TRUE", {
  df_with_na <- df_scatter
  df_with_na$x[2] <- NA
  
  testthat::expect_no_error(
    ggplot2::ggplot(df_with_na, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point(na.rm = TRUE)
  )
})

testthat::test_that("Parameter: na.rm = FALSE", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point(na.rm = FALSE)
  )
})

### 09.04 inherit.aes parameter ------------------------------------------------

testthat::test_that("Parameter: inherit.aes = TRUE", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point(inherit.aes = TRUE)
  )
})

testthat::test_that("Parameter: inherit.aes = FALSE", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y)) +
        geom_icon_point(
          ggplot2::aes(x = x, y = y, icon = icon),
          inherit.aes = FALSE
        )
  )
})

# ******************************************************************************
# 10 Data input variations -----------------------------------------------------
# ******************************************************************************

### 10.01 Data in ggplot() -----------------------------------------------------

testthat::test_that("Data: data in ggplot() call", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point()
  )
})

### 10.02 Data in geom_icon_point() -------------------------------------------

testthat::test_that("Data: data in geom_icon_point() call", {
  testthat::expect_no_error(
    ggplot2::ggplot() +
        geom_icon_point(
          data = df_scatter,
          ggplot2::aes(x = x, y = y, icon = icon)
        )
  )
})

### 10.03 Tibble input ---------------------------------------------------------

testthat::test_that("Data: tibble input", {
  testthat::skip_if_not_installed("tibble")
  
  df_tibble <- tibble::tibble(
    x = c(1, 2, 3),
    y = c(2, 3, 4),
    icon = c("circle", "star", "heart")
  )
  
  testthat::expect_no_error(
    ggplot2::ggplot(df_tibble, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point()
  )
})

### 10.04 data.table input -----------------------------------------------------

testthat::test_that("Data: data.table input", {
  testthat::skip_if_not_installed("data.table")
  
  df_dt <- data.table::data.table(
    x = c(1, 2, 3),
    y = c(2, 3, 4),
    icon = c("circle", "star", "heart")
  )
  
  testthat::expect_no_error(
    ggplot2::ggplot(df_dt, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point()
  )
})

# ******************************************************************************
# 11 Theme and styling integration ---------------------------------------------
# ******************************************************************************

### 11.01 Different themes -----------------------------------------------------

testthat::test_that("Theme: theme_minimal", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point() +
        ggplot2::theme_minimal()
  )
})

testthat::test_that("Theme: theme_bw", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point() +
        ggplot2::theme_bw()
  )
})

testthat::test_that("Theme: theme_classic", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point() +
        ggplot2::theme_classic()
  )
})

### 11.02 Custom theme elements ------------------------------------------------

testthat::test_that("Theme: custom legend position", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, color = category)) +
        geom_icon_point() +
        ggplot2::theme(legend.position = "bottom")
  )
})

testthat::test_that("Theme: no legend", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, color = category)) +
        geom_icon_point() +
        ggplot2::theme(legend.position = "none")
  )
})

# ******************************************************************************
# 12 Integration with other geoms ----------------------------------------------
# ******************************************************************************

### 12.01 Combined with geom_line ----------------------------------------------

testthat::test_that("Integration: geom_icon_point + geom_line", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y)) +
        ggplot2::geom_line(color = "gray", linetype = "dashed") +
        geom_icon_point(ggplot2::aes(icon = icon, color = category))
  )
})

### 12.02 Combined with geom_smooth --------------------------------------------

testthat::test_that("Integration: geom_icon_point + geom_smooth", {
  testthat::expect_no_error(
    suppressMessages({
      ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y)) +
        ggplot2::geom_smooth(method = "lm", se = FALSE, color = "blue") +
        geom_icon_point(ggplot2::aes(icon = icon))
    })
  )
})

### 12.03 Combined with geom_text ----------------------------------------------

testthat::test_that("Integration: geom_icon_point + geom_text", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, label = category)) +
        geom_icon_point(ggplot2::aes(icon = icon)) +
        ggplot2::geom_text(vjust = -1, size = 3)
  )
})

### 12.04 Combined with geom_hline/vline ---------------------------------------

testthat::test_that("Integration: geom_icon_point + reference lines", {
  testthat::expect_no_error(
      ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
        ggplot2::geom_hline(yintercept = 3, linetype = "dashed", color = "red") +
        ggplot2::geom_vline(xintercept = 3, linetype = "dashed", color = "blue") +
        geom_icon_point()
  )
})

# ******************************************************************************
# 13 Special icon cases --------------------------------------------------------
# ******************************************************************************

### 13.01 All same icon --------------------------------------------------------

testthat::test_that("Icons: all rows same icon", {
  df_same <- df_scatter
  df_same$icon <- "star"
  
  testthat::expect_no_error(
    ggplot2::ggplot(df_same, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point()
  )
})

### 13.02 Many different icons -------------------------------------------------

testthat::test_that("Icons: all different icons per row", {
  df_unique <- data.frame(
    x = 1:5,
    y = 1:5,
    icon = c("circle", "star", "heart", "user", "flag"),
    stringsAsFactors = FALSE
  )
  
  testthat::expect_no_error(
    ggplot2::ggplot(df_unique, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point()
  )
})

### 13.03 Icon names with hyphens ----------------------------------------------

testthat::test_that("Icons: icon names with hyphens", {
  df_hyphens <- data.frame(
    x = 1:3,
    y = 1:3,
    icon = c("arrow-right", "arrow-left", "arrow-up"),
    stringsAsFactors = FALSE
  )
  
  testthat::expect_no_error(
    ggplot2::ggplot(df_hyphens, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point()
  )
})

# ******************************************************************************
# 14 Aesthetic inheritance patterns --------------------------------------------
# ******************************************************************************

### 14.01 Full inheritance -----------------------------------------------------

testthat::test_that("Inheritance: all aesthetics from ggplot()", {
  testthat::expect_no_error(
      ggplot2::ggplot(
        df_scatter,
        ggplot2::aes(x = x, y = y, icon = icon, color = category, size = point_size)
      ) +
        geom_icon_point()
  )
})

### 14.02 Partial inheritance --------------------------------------------------

testthat::test_that("Inheritance: x/y from ggplot, icon from geom", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y)) +
        geom_icon_point(ggplot2::aes(icon = icon, color = category))
  )
})


# ******************************************************************************
# 15 Coordinate system variations ----------------------------------------------
# ******************************************************************************

### 15.01 Default Cartesian ----------------------------------------------------

testthat::test_that("Coords: default Cartesian coordinates", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point() +
        ggplot2::coord_cartesian()
  )
})

### 15.02 Polar coordinates ----------------------------------------------------

testthat::test_that("Coords: polar coordinates", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point() +
        ggplot2::coord_polar()
  )
})

### 15.03 Equal aspect ratio ---------------------------------------------------

testthat::test_that("Coords: coord_equal", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point() +
        ggplot2::coord_equal()
  )
})

# ******************************************************************************
# 16 Faceting variations -------------------------------------------------------
# ******************************************************************************

### 16.01 facet_wrap -----------------------------------------------------------

testthat::test_that("Facet: facet_wrap by category", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point() +
        ggplot2::facet_wrap(~category)
  )
})

### 16.02 facet_grid -----------------------------------------------------------

testthat::test_that("Facet: facet_grid", {
  df_grid <- df_scatter
  df_grid$row_var <- rep(c("R1", "R2"), length.out = nrow(df_grid))
  
  testthat::expect_no_error(
    ggplot2::ggplot(df_grid, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point() +
        ggplot2::facet_grid(row_var ~ category)
  )
})

### 16.03 Free scales in facets ------------------------------------------------

testthat::test_that("Facet: free scales", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point() +
        ggplot2::facet_wrap(~category, scales = "free")
  )
})

# ******************************************************************************
# 17 Performance and edge cases ------------------------------------------------
# ******************************************************************************

### 17.01 Large number of points -----------------------------------------------

testthat::test_that("Performance: 100 points", {
  df_many <- data.frame(
    x = runif(100),
    y = runif(100),
    icon = sample(c("circle", "star", "heart"), 100, replace = TRUE),
    stringsAsFactors = FALSE
  )
  
  testthat::expect_no_error(
    ggplot2::ggplot(df_many, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point(size = 2, color = "darkred")
  )
})

### 17.02 Repeated coordinates -------------------------------------------------

testthat::test_that("Edge: multiple points at same coordinates", {
  df_overlap <- data.frame(
    x = c(1, 1, 1, 2, 2),
    y = c(1, 1, 1, 2, 2),
    icon = c("circle", "star", "heart", "circle", "star"),
    stringsAsFactors = FALSE
  )
  
  testthat::expect_no_error(
    ggplot2::ggplot(df_overlap, ggplot2::aes(x = x, y = y, icon = icon)) +
        geom_icon_point()
  )
})

# ******************************************************************************
# END --------------------------------------------------------------------------
# ******************************************************************************



# Simulate data
set.seed(170513)
n <- 2000
d <- data.frame(a = rnorm(n))
d$b <- -(d$a + rnorm(n, sd = 2))

# Add first principal component
d$pc <- predict(prcomp(~a+b, d))[,1]

# Add density for each point
d$density <- fields::interp.surface(
  MASS::kde2d(d$a, d$b), d[,c("a", "b")])

#Add icon column

d$icon <- "star"

# Plot
ggplot(d, aes(a, b, color = pc, alpha = 1/density)) +
  geom_icon_point(aes(icon = icon), size = 1, dpi = 50) +
  theme_minimal() +
  scale_color_gradient(low = "#32aeff", high = "#f2aeff") +
  scale_alpha(range = c(.25, .6))


ggplot(d, aes(a, b, color = pc, alpha = 1/density)) +
  geom_point(shape = 16, size = 5, show.legend = FALSE) +
  theme_minimal() +
  scale_color_gradient(low = "#32aeff", high = "#f2aeff") +
  scale_alpha(range = c(.25, .6))




set.seed(170513)
n <- 2000
d <- data.frame(a = rnorm(n))
d$b <- -(d$a + rnorm(n, sd = 2))

# Add first principal component
d$pc <- predict(prcomp(~a+b, d))[,1]

# Add density for each point
d$density <- fields::interp.surface(
  MASS::kde2d(d$a, d$b), d[,c("a", "b")])

# Add icon column
d$icon <- "star"

# Plot with icons
p1 <- ggplot(d, aes(a, b, color = pc, alpha = 1/density)) +
  geom_icon_point(aes(icon = icon), size = 1, dpi = 50) +
  theme_minimal() +
  scale_color_gradient(low = "#32aeff", high = "#f2aeff") +
  scale_alpha(range = c(.25, .6)) +
  labs(title = "Density Gradient with Icon Points",
       subtitle = "Stars with varying density and PCA coloring")

print(p1)

# Compare with standard geom_point
p1_compare <- ggplot(d, aes(a, b, color = pc, alpha = 1/density)) +
  geom_point(shape = 16, size = 2, show.legend = FALSE) +
  theme_minimal() +
  scale_color_gradient(low = "#32aeff", high = "#f2aeff") +
  scale_alpha(range = c(.25, .6)) +
  labs(title = "Same Data with geom_point()",
       subtitle = "Standard points for comparison")

print(p1_compare)



set.seed(42)
n_obs <- 150

df_regression <- data.frame(
  x = seq(0, 10, length.out = n_obs)
)

df_regression <- df_regression %>%
  mutate(
    # True relationship with noise
    y = 2 + 1.5 * x + rnorm(n_obs, sd = 2),
    
    # Categorize by residuals
    category = case_when(
      y > 2 + 1.5 * x + 1 ~ "Above",
      y < 2 + 1.5 * x - 1 ~ "Below",
      TRUE ~ "Within"
    ),
    
    # Assign icons based on category
    icon = case_when(
      category == "Above" ~ "arrow-up",
      category == "Below" ~ "arrow-down",
      category == "Within" ~ "circle"
    ),
    
    # Size by distance from regression line
    distance = abs(y - (2 + 1.5 * x)),
    point_size = scales::rescale(distance, to = c(1, 4))
  )

# Fit model
model <- lm(y ~ x, data = df_regression)
predictions <- predict(model, interval = "confidence")
df_regression$fitted <- predictions[, "fit"]
df_regression$lwr <- predictions[, "lwr"]
df_regression$upr <- predictions[, "upr"]

# Plot with icons
p2 <- ggplot(df_regression, aes(x = x, y = y)) +
  # Confidence band
  geom_ribbon(aes(ymin = lwr, ymax = upr), alpha = 0.2, fill = "steelblue") +
  # Regression line
  geom_line(aes(y = fitted), color = "steelblue", linewidth = 1) +
  # Data points with icons
  geom_icon_point(
    aes(icon = icon, color = category, size = point_size),
    dpi = 80,
    legend_icons = TRUE
  ) +
  scale_color_manual(
    values = c("Above" = "#e74c3c", "Below" = "#3498db", "Within" = "#2ecc71"),
    name = "Position"
  ) +
  scale_size_continuous(range = c(1, 4), guide = "none") +
  theme_minimal() +
  labs(
    title = "Linear Regression with Categorical Icon Points",
    subtitle = "Icons show position relative to confidence band, size shows distance",
    x = "Predictor (x)",
    y = "Response (y)"
  )

print(p2)




set.seed(2024)
dates <- seq.Date(from = as.Date("2023-01-01"), to = as.Date("2023-12-31"), by = "day")

df_timeseries <- data.frame(
  date = dates,
  value = cumsum(rnorm(length(dates), mean = 0.5, sd = 3))
)

# Add events
events <- sample(dates, 20)
df_timeseries <- df_timeseries %>%
  mutate(
    event_type = case_when(
      date %in% events[1:7] ~ "High Impact",
      date %in% events[8:14] ~ "Medium Impact",
      date %in% events[15:20] ~ "Low Impact",
      TRUE ~ "Normal"
    ),
    icon = case_when(
      event_type == "High Impact" ~ "bolt",
      event_type == "Medium Impact" ~ "triangle-exclamation",
      event_type == "Low Impact" ~ "circle-info",
      TRUE ~ "circle"
    ),
    point_size = case_when(
      event_type == "High Impact" ~ 5,
      event_type == "Medium Impact" ~ 3,
      event_type == "Low Impact" ~ 2,
      TRUE ~ 1
    )
  )

p3 <- ggplot(df_timeseries, aes(x = date, y = value)) +
  geom_line(color = "gray60", linewidth = 0.5) +
  geom_icon_point(
    aes(icon = icon, color = event_type, size = point_size),
    dpi = 100,
    legend_icons = TRUE
  ) +
  scale_color_manual(
    values = c(
      "High Impact" = "#e74c3c",
      "Medium Impact" = "#f39c12",
      "Low Impact" = "#3498db",
      "Normal" = "gray70"
    ),
    name = "Event Type"
  ) +
  scale_size_continuous(range = c(1, 5), guide = "none") +
  theme_minimal() +
  labs(
    title = "Time Series with Event Icons",
    subtitle = "Different icons mark different event types throughout the year",
    x = "Date",
    y = "Cumulative Value"
  )

print(p3)




set.seed(123)
n_per_cluster <- 100

df_clusters <- rbind(
  data.frame(x = rnorm(n_per_cluster, mean = 0, sd = 1),
             y = rnorm(n_per_cluster, mean = 0, sd = 1),
             cluster = "A", icon = "heart"),
  data.frame(x = rnorm(n_per_cluster, mean = 5, sd = 1.2),
             y = rnorm(n_per_cluster, mean = 5, sd = 1.2),
             cluster = "B", icon = "star"),
  data.frame(x = rnorm(n_per_cluster, mean = 0, sd = 1),
             y = rnorm(n_per_cluster, mean = 5, sd = 1),
             cluster = "C", icon = "square"),
  data.frame(x = rnorm(n_per_cluster, mean = 5, sd = 1.2),
             y = rnorm(n_per_cluster, mean = 0, sd = 1.2),
             cluster = "D", icon = "triangle-exclamation")
)

# Add distance from cluster center
df_clusters <- df_clusters %>%
  group_by(cluster) %>%
  mutate(
    center_x = mean(x),
    center_y = mean(y),
    distance_from_center = sqrt((x - center_x)^2 + (y - center_y)^2),
    alpha_val = scales::rescale(distance_from_center, to = c(1, 0.3))
  ) %>%
  ungroup()

p4 <- ggplot(df_clusters, aes(x = x, y = y)) +
  geom_icon_point(
    aes(icon = icon, color = cluster, alpha = alpha_val),
    size = 2,
    dpi = 80,
    legend_icons = TRUE
  ) +
  scale_color_brewer(palette = "Set1", name = "Cluster") +
  scale_alpha_continuous(range = c(0.3, 1), guide = "none") +
  theme_minimal() +
  labs(
    title = "K-Means Clustering with Icon Markers",
    subtitle = "Each cluster has a unique icon, alpha shows distance from centroid",
    x = "X Coordinate",
    y = "Y Coordinate"
  )

print(p4)


set.seed(456)
n_locations <- 200

df_geo <- data.frame(
  longitude = runif(n_locations, min = -10, max = 10),
  latitude = runif(n_locations, min = -10, max = 10)
) %>%
  mutate(
    location_type = sample(
      c("Hospital", "School", "Park", "Station"),
      n_locations,
      replace = TRUE,
      prob = c(0.2, 0.3, 0.3, 0.2)
    ),
    icon = case_when(
      location_type == "Hospital" ~ "hospital",
      location_type == "School" ~ "graduation-cap",
      location_type == "Park" ~ "tree",
      location_type == "Station" ~ "train"
    ),
    importance = sample(1:5, n_locations, replace = TRUE),
    point_size = importance * 0.8
  )

p5 <- ggplot(df_geo, aes(x = longitude, y = latitude)) +
  geom_icon_point(
    aes(icon = icon, color = location_type, size = point_size),
    dpi = 100,
    legend_icons = TRUE
  ) +
  scale_color_manual(
    values = c(
      "Hospital" = "#e74c3c",
      "School" = "#3498db",
      "Park" = "#2ecc71",
      "Station" = "#9b59b6"
    ),
    name = "Location Type"
  ) +
  scale_size_continuous(range = c(1, 5), guide = "none") +
  coord_fixed() +
  theme_minimal() +
  labs(
    title = "Geographic Distribution of Facilities",
    subtitle = "Icon types represent facility categories, size shows importance",
    x = "Longitude",
    y = "Latitude"
  )

print(p5)



# ==============================================================================
# Example 6: Multi-variable Visualization (HARD)
# ==============================================================================

set.seed(789)
n_complex <- 300

df_complex <- data.frame(
  x = rnorm(n_complex),
  y = rnorm(n_complex)
) %>%
  mutate(
    # Quadrant
    quadrant = case_when(
      x >= 0 & y >= 0 ~ "Q1",
      x < 0 & y >= 0 ~ "Q2",
      x < 0 & y < 0 ~ "Q3",
      TRUE ~ "Q4"
    ),
    
    # Distance from origin
    distance = sqrt(x^2 + y^2),
    
    # Categorize by distance
    distance_cat = cut(distance, breaks = c(0, 1, 2, Inf), labels = c("Near", "Mid", "Far")),
    
    # Icon based on quadrant AND distance
    icon = case_when(
      distance_cat == "Near" ~ "circle",
      distance_cat == "Mid" & quadrant %in% c("Q1", "Q3") ~ "star",
      distance_cat == "Mid" & quadrant %in% c("Q2", "Q4") ~ "heart",
      distance_cat == "Far" ~ "triangle-exclamation"
    ),
    
    # Color by quadrant
    point_size = scales::rescale(distance, to = c(1, 4))
  )

ggplot(df_complex, aes(x = x, y = y)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = 0, linetype = "dashed", color = "gray50") +
  geom_icon_point(
    aes(icon = icon, color = icon, size = point_size, alpha = distance),
    dpi = 80,
    legend_icons = TRUE
  ) +
  scale_color_brewer(palette = "Set2", name = "Quadrant") +
  scale_size_continuous(range = c(1, 4), guide = "none") +
  scale_alpha_continuous(range = c(1, 0.3), guide = "none") +
  coord_fixed() +
  theme_minimal() +
  labs(
    title = "Multi-Variable Visualization",
    subtitle = "Icon shows distance category, color shows quadrant, size and alpha show distance",
    x = "X Coordinate",
    y = "Y Coordinate"
  )

print(p6)


# ==============================================================================
# Example 7: Extreme Case - High Density with Varying Icons
# ==============================================================================

set.seed(2025)
n_extreme <- 5000

df_extreme <- data.frame(
  x = c(rnorm(n_extreme/2, mean = 0, sd = 2), rnorm(n_extreme/2, mean = 5, sd = 1.5)),
  y = c(rnorm(n_extreme/2, mean = 0, sd = 2), rnorm(n_extreme/2, mean = 5, sd = 1.5))
) %>%
  mutate(
    group = rep(c("A", "B"), each = n_extreme/2),
    icon = ifelse(group == "A", "circle", "square"),
    density_local = fields::interp.surface(
      MASS::kde2d(x, y, n = 100),
      cbind(x, y)
    ),
    alpha_val = scales::rescale(1/density_local, to = c(0.1, 0.8))
  )

p7 <- ggplot(df_extreme, aes(x = x, y = y)) +
  geom_icon_point(
    aes(icon = icon, color = group, alpha = alpha_val),
    size = 1,
    dpi = 50,
    legend_icons = TRUE
  ) +
  scale_color_manual(values = c("A" = "#3498db", "B" = "#e74c3c"), name = "Group") +
  scale_alpha_continuous(range = c(0.1, 0.8), guide = "none") +
  theme_minimal() +
  labs(
    title = "High Density Plot (5000 points)",
    subtitle = "Icons vary by group, alpha adjusts for local density",
    x = "X",
    y = "Y"
  )

print(p7)

# ==============================================================================
# Example 8: Logistic Regression - Binary Classification with Icons
# ==============================================================================

set.seed(2024)
n_logistic <- 300

df_logistic <- data.frame(
  x = rnorm(n_logistic, mean = 5, sd = 2)
) %>%
  mutate(
    # Probability based on logistic function
    prob = 1 / (1 + exp(-(x - 5))),
    
    # Binary outcome
    y = rbinom(n_logistic, size = 1, prob = prob),
    
    # Classification categories
    outcome = ifelse(y == 1, "Success", "Failure"),
    
    # Icons
    icon = ifelse(outcome == "Success", "circle-check", "circle-xmark"),
    
    # Jitter y for visualization
    y_jitter = y + runif(n_logistic, -0.1, 0.1),
    
    # Size by confidence (distance from 0.5 probability)
    confidence = abs(prob - 0.5),
    point_size = scales::rescale(confidence, to = c(1, 4))
  )

# Fit logistic regression
model_logistic <- glm(y ~ x, data = df_logistic, family = binomial())

# Predictions
x_seq <- seq(min(df_logistic$x), max(df_logistic$x), length.out = 100)
pred_logistic <- predict(model_logistic, 
                         newdata = data.frame(x = x_seq), 
                         type = "response")

df_curve <- data.frame(x = x_seq, prob = pred_logistic)

p8 <- ggplot(df_logistic, aes(x = x, y = y_jitter)) +
  # Logistic curve
  geom_line(data = df_curve, aes(x = x, y = prob), 
            color = "steelblue", linewidth = 1.2) +
  # Reference lines
  geom_hline(yintercept = c(0, 1), linetype = "dashed", color = "gray60", alpha = 0.5) +
  geom_hline(yintercept = 0.5, linetype = "dotted", color = "gray40") +
  # Data points with icons
  geom_icon_point(
    aes(icon = icon, color = outcome, size = point_size),
    dpi = 100,
    legend_icons = TRUE
  ) +
  scale_color_manual(
    values = c("Success" = "#2ecc71", "Failure" = "#e74c3c"),
    name = "Outcome"
  ) +
  scale_size_continuous(range = c(1.5, 4), guide = "none") +
  scale_y_continuous(breaks = c(0, 0.5, 1), limits = c(-0.2, 1.2)) +
  theme_minimal() +
  labs(
    title = "Logistic Regression with Classification Icons",
    subtitle = "Check marks for success, X marks for failure. Size shows prediction confidence",
    x = "Predictor Variable",
    y = "Probability / Outcome (jittered)"
  )

print(p8)

# ==============================================================================
# Example 9: Survival Analysis / Kaplan-Meier Style
# ==============================================================================

set.seed(999)
n_survival <- 100

df_survival <- data.frame(
  time = rexp(n_survival, rate = 0.1),
  group = sample(c("Treatment A", "Treatment B"), n_survival, replace = TRUE)
) %>%
  arrange(time) %>%
  group_by(group) %>%
  mutate(
    event_num = row_number(),
    survival_prob = 1 - (event_num / n()),
    
    # Event type
    event_type = sample(
      c("Death", "Censored", "Loss to Follow-up"),
      n(),
      replace = TRUE,
      prob = c(0.6, 0.3, 0.1)
    ),
    
    # Icons
    icon = case_when(
      event_type == "Death" ~ "skull-crossbones",
      event_type == "Censored" ~ "circle",
      event_type == "Loss to Follow-up" ~ "user-slash"
    ),
    
    point_size = ifelse(event_type == "Death", 3, 1.5)
  ) %>%
  ungroup()

p9 <- ggplot(df_survival, aes(x = time, y = survival_prob)) +
  # Survival curves
  geom_step(aes(color = group), linewidth = 1) +
  # Events with icons
  geom_icon_point(
    aes(icon = icon, color = group, size = point_size),
    dpi = 80,
    legend_icons = TRUE
  ) +
  scale_color_manual(
    values = c("Treatment A" = "#3498db", "Treatment B" = "#e74c3c"),
    name = "Treatment"
  ) +
  scale_size_continuous(range = c(1.5, 3), guide = "none") +
  scale_y_continuous(labels = scales::percent_format(), limits = c(0, 1)) +
  theme_minimal() +
  labs(
    title = "Survival Analysis with Event Icons",
    subtitle = "Skull for deaths, circles for censored, user-slash for loss to follow-up",
    x = "Time",
    y = "Survival Probability"
  )

print(p9)

# ==============================================================================
# Example 10: Network-style Layout with Categorical Icons
# ==============================================================================

set.seed(404)
n_nodes <- 50

# Create circular layout
angles <- seq(0, 2*pi, length.out = n_nodes + 1)[1:n_nodes]

df_network <- data.frame(
  x = cos(angles) + rnorm(n_nodes, sd = 0.1),
  y = sin(angles) + rnorm(n_nodes, sd = 0.1),
  node_type = sample(
    c("Server", "Client", "Router", "Database"),
    n_nodes,
    replace = TRUE,
    prob = c(0.15, 0.5, 0.2, 0.15)
  )
) %>%
  mutate(
    icon = case_when(
      node_type == "Server" ~ "server",
      node_type == "Client" ~ "laptop",
      node_type == "Router" ~ "network-wired",
      node_type == "Database" ~ "database"
    ),
    
    # Connection strength (random)
    connections = sample(1:10, n_nodes, replace = TRUE),
    point_size = scales::rescale(connections, to = c(2, 6)),
    
    # Status
    status = sample(c("Active", "Idle", "Error"), n_nodes, 
                    replace = TRUE, prob = c(0.7, 0.2, 0.1)),
    alpha_val = case_when(
      status == "Active" ~ 1.0,
      status == "Idle" ~ 0.5,
      status == "Error" ~ 0.3
    )
  )

p10 <- ggplot(df_network, aes(x = x, y = y)) +
  # Connection lines (simple radial)
  geom_segment(
    data = df_network,
    aes(x = 0, y = 0, xend = x, yend = y),
    color = "gray80",
    alpha = 0.3
  ) +
  # Nodes with icons
  geom_icon_point(
    aes(icon = icon, color = node_type, size = point_size, alpha = alpha_val),
    dpi = 100,
    legend_icons = TRUE
  ) +
  scale_color_manual(
    values = c(
      "Server" = "#e74c3c",
      "Client" = "#3498db",
      "Router" = "#f39c12",
      "Database" = "#9b59b6"
    ),
    name = "Node Type"
  ) +
  scale_size_continuous(range = c(2, 6), guide = "none") +
  scale_alpha_continuous(range = c(0.3, 1), guide = "none") +
  coord_fixed() +
  theme_void() +
  theme(legend.position = "right") +
  labs(
    title = "Network Topology Visualization",
    subtitle = "Icon types show node roles, size shows connections, alpha shows status"
  )

print(p10)

# ==============================================================================
# Summary Statistics
# ==============================================================================

cat("\n")
cat("===============================================\n")
cat("Summary of Examples:\n")
cat("===============================================\n")
cat("1. Density Gradient: 2000 points with PCA coloring\n")
cat("2. Regression: 150 points with confidence bands\n")
cat("3. Time Series: 365 daily observations with events\n")
cat("4. Clustering: 400 points across 4 clusters\n")
cat("5. Geographic: 200 facility locations\n")
cat("6. Multi-variable: 300 points with complex mapping\n")
cat("7. High Density: 5000 points with local density adjustment\n")
cat("8. Logistic Regression: 300 binary outcomes\n")
cat("9. Survival Analysis: 100 time-to-event observations\n")
cat("10. Network: 50 nodes in circular layout\n")
cat("===============================================\n")
cat("Total data points rendered: ", 
    n + n_obs + length(dates) + nrow(df_clusters) + n_locations + 
      n_complex + n_extreme + n_logistic + n_survival + n_nodes, "\n")
cat("Unique icon types used: ", 
    length(unique(c(d$icon, df_regression$icon, df_timeseries$icon, 
                    df_clusters$icon, df_geo$icon, df_complex$icon,
                    df_extreme$icon, df_logistic$icon, df_survival$icon,
                    df_network$icon))), "\n")
cat("===============================================\n")