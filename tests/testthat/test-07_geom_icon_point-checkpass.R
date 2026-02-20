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

expect_doppelganger <- function(title, fig, path = NULL, ...) {
  testthat::skip_if_not_installed("vdiffr")
  vdiffr::expect_doppelganger(title, fig, ...)
}

# ******************************************************************************
## 01.01 Test dataframes -------------------------------------------------------
# ******************************************************************************

# ******************************************************************************
# Test fixtures -------------------------------------------------------------
# ******************************************************************************

df_pop <- data.frame(
  sex = rep(c("M", "F"), each = 20),
  icon = rep(c("male", "female"), each = 20),
  stringsAsFactors = FALSE
)

df_scatter <- data.frame(
  x = c(1, 2, 3, 4, 5),
  y = c(2, 4, 3, 5, 6),
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
  testthat::expect_no_error({
    p <- ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point()
    ggplot2::ggplot_build(p)
  })
})

testthat::test_that("Basic: plot with icon parameter", {
  testthat::expect_no_error({
    p <- ggplot2::ggplot(df_scatter_no_icon, ggplot2::aes(x = x, y = y)) +
      geom_icon_point(icon = "circle")
    ggplot2::ggplot_build(p)
  })
})

### 02.02 Icon mapping variations ----------------------------------------------

testthat::test_that("Basic: icon mapped in ggplot() aes", {
  testthat::expect_no_error({
    p <- ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point(size = 3)
    ggplot2::ggplot_build(p)
  })
})

testthat::test_that("Basic: icon mapped in geom aes", {
  testthat::expect_no_error({
    p <- ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y)) +
      geom_icon_point(ggplot2::aes(icon = icon))
    ggplot2::ggplot_build(p)
  })
})

testthat::test_that("Basic: different icons per row", {
  testthat::expect_no_error({
    p <- ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, color = category)) +
      geom_icon_point()
    ggplot2::ggplot_build(p)
  })
})

testthat::test_that("Basic: multiple geom_icon_point layers work together", {
  
  df_scatter <- data.frame(
    x = 1:10,
    y = 1:10,
    icon = rep(c("circle", "star"), 5),
    category = rep(c("A", "B"), 5),
    stringsAsFactors = FALSE
  )
  
  df1 <- df_scatter[1:5, ]
  df2 <- df_scatter[6:10, ]
  
  p <- ggplot2::ggplot() +
    geom_icon_point(
      data = df1,
      ggplot2::aes(x = x, y = y, icon = icon),
      size = 2,
      color = "blue"
    ) +
    geom_icon_point(
      data = df2,
      ggplot2::aes(x = x, y = y, icon = icon),
      size = 3,
      color = "red"
    )
  
  testthat::expect_s3_class(p, "ggplot")
  testthat::expect_equal(length(p$layers), 2)
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
    ggplot2::ggplot(df_scatter, ggplot2::aes(
      x = x, y = y, icon = icon,
      color = point_size, size = point_size
    )) +
      geom_icon_point()
  )
})

testthat::test_that("Color: scale_color_manual works", {
  p <- ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, color = category)) +
    geom_icon_point(size = 2) +
    ggplot2::scale_color_manual(values = c("A" = "red", "B" = "blue"))
  
  testthat::expect_no_error(ggplot2::ggplot_build(p))
})

testthat::test_that("Color: scale_color_viridis works", {
  testthat::skip_if_not_installed("viridis")
  
  df_numeric_color <- df_scatter
  df_numeric_color$value <- 1:5
  
  p <- ggplot2::ggplot(df_numeric_color, ggplot2::aes(x = x, y = y, icon = icon, color = value)) +
    geom_icon_point(size = 2) +
    ggplot2::scale_color_viridis_c()
  
  testthat::expect_no_error(ggplot2::ggplot_build(p))
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

### 03.03 stroke parameter ---------------------------------------------------

testthat::test_that("Stroke: valid stroke width", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, color = icon)) +
      geom_icon_point(size = 4, stroke_width = 0.5)
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
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, size = point_size, color = category)) +
      geom_icon_point()
  )
})

testthat::test_that("Size: handles NA in size aesthetic", {
  
  df_scatter <- data.frame(
    x = 1:10,
    y = 1:10,
    icon = rep(c("circle", "star"), 5),
    category = rep(c("A", "B"), 5),
    stringsAsFactors = FALSE
  )
  
  df_na_size <- df_scatter
  df_na_size$size_var <- c(1, 2, NA, 3, 4, 1, 2, 3, 4, 5)
  
  testthat::expect_warning({
    tmp <- tempfile(fileext = ".png")
    png(tmp)
    print(
      ggplot2::ggplot(df_na_size, ggplot2::aes(x = x, y = y, icon = icon, size = size_var)) +
        geom_icon_point()
    )
    dev.off()
    unlink(tmp)
  })
})

# ******************************************************************************
# 05 DPI settings --------------------------------------------------------------
# ******************************************************************************

### 05.01 Valid DPI ranges -----------------------------------------------------

testthat::test_that("DPI: minimum valid (50)", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point(dpi = 50)
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

testthat::test_that("Theme: custom theme with blank grid", {
  p <- ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, color = category)) +
    geom_icon_point(size = 2) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      legend.position = "bottom",
      panel.grid = ggplot2::element_blank()
    )
  
  testthat::expect_s3_class(p, "ggplot")
})

testthat::test_that("Theme: legend can be positioned", {
  positions <- c("top", "bottom", "left", "right", "none")
  
  for (pos in positions) {
    p <- ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, color = category)) +
      geom_icon_point(size = 2) +
      ggplot2::theme(legend.position = pos)
    
    testthat::expect_s3_class(p, "ggplot")
  }
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
# 13.04 Custom icon column names -----------------------------------------------
# ******************************************************************************

#' Extract icon names from PNG file paths
#' 
#' @param png_paths Character vector of PNG file paths
#' @return Character vector of icon names extracted from filenames
extract_icon_names <- function(png_paths) {
  basenames <- basename(png_paths)
  # Icon name is the first part before "_c" (color marker)
  icon_names <- sub("_.*", "", basenames)
  icon_names
}

testthat::test_that("Icons: custom column 'my_icons' renders CORRECT icons", {
  # Data with custom icon column name
  df_custom <- data.frame(
    x = c(1, 2, 3, 4),
    y = c(1, 2, 3, 4),
    my_icons = c("circle", "square", "star", "heart"),  # Custom column name!
    category = c("A", "B", "C", "D"),
    stringsAsFactors = FALSE
  )
  
  p <- ggplot2::ggplot(df_custom, ggplot2::aes(x = x, y = y, icon = my_icons, color = category)) +
    geom_icon_point(dpi = 60)
  
  built <- ggplot2::ggplot_build(p)
  layer_data <- built$data[[1]]
  
  # Extract rendered icons
  rendered_icons <- extract_icon_names(layer_data$image)
  
  # Should match exactly what's in my_icons column
  testthat::expect_setequal(rendered_icons, c("circle", "square", "star", "heart"))
  testthat::expect_true("circle" %in% rendered_icons)
  testthat::expect_true("square" %in% rendered_icons)
  testthat::expect_true("star" %in% rendered_icons)
  testthat::expect_true("heart" %in% rendered_icons)
})

testthat::test_that("Icons: column 'icon_2' renders male and female icons", {
  df_icon2 <- data.frame(
    x = c(1, 2),
    y = c(1, 2),
    icon_2 = c("male", "female"),  # Custom column name
    stringsAsFactors = FALSE
  )
  
  p <- ggplot2::ggplot(df_icon2, ggplot2::aes(x = x, y = y, icon = icon_2)) +
    geom_icon_point(dpi = 60)
  
  built <- ggplot2::ggplot_build(p)
  layer_data <- built$data[[1]]
  
  rendered_icons <- extract_icon_names(layer_data$image)
  
  # Should be male and female, NOT "user" or any default fallback
  testthat::expect_setequal(rendered_icons, c("male", "female"))
  testthat::expect_false("user" %in% rendered_icons)
  testthat::expect_false("circle" %in% rendered_icons)
})

testthat::test_that("Icons: per-row rendering with custom column 'icon_column'", {
  # Verify each ROW gets its CORRECT icon from custom column
  df_custom_rows <- data.frame(
    x = 1:5,
    y = 1:5,
    icon_column = c("heart", "star", "circle", "square", "heart"),
    stringsAsFactors = FALSE
  )
  
  p <- ggplot2::ggplot(df_custom_rows, ggplot2::aes(x = x, y = y, icon = icon_column)) +
    geom_icon_point(dpi = 60)
  
  built <- ggplot2::ggplot_build(p)
  layer_data <- built$data[[1]]
  
  # Extract icons IN ORDER
  rendered_icons <- extract_icon_names(layer_data$image)
  
  # Row 1 should be heart
  testthat::expect_equal(rendered_icons[1], "heart")
  # Row 2 should be star
  testthat::expect_equal(rendered_icons[2], "star")
  # Row 3 should be circle
  testthat::expect_equal(rendered_icons[3], "circle")
  # Row 4 should be square
  testthat::expect_equal(rendered_icons[4], "square")
  # Row 5 should be heart (repeated)
  testthat::expect_equal(rendered_icons[5], "heart")
})

testthat::test_that("Icons: very custom name 'fontawesome_symbol' works", {
  df_weird <- data.frame(
    x = 1:3,
    y = 1:3,
    fontawesome_symbol = c("pizza-slice", "coffee", "heart"),
    stringsAsFactors = FALSE
  )
  
  p <- ggplot2::ggplot(df_weird, ggplot2::aes(x = x, y = y, icon = fontawesome_symbol)) +
    geom_icon_point(dpi = 60)
  
  built <- ggplot2::ggplot_build(p)
  layer_data <- built$data[[1]]
  
  rendered_icons <- extract_icon_names(layer_data$image)
  
  # Should use the actual icons from fontawesome_symbol column
  testthat::expect_setequal(rendered_icons, c("pizza-slice", "coffee", "heart"))
  
  # Should NOT fall back to defaults
  testthat::expect_false("user" %in% rendered_icons)
  testthat::expect_false("circle" %in% rendered_icons)
})

testthat::test_that("REGRESSION: 'icon' column does NOT override 'icon_2' content", {
  
  df_regression <- data.frame(
    icon = c("WRONG", "WRONG", "WRONG"),      # Decoy column with wrong icons
    icon_2 = c("heart", "star", "circle"),    # Correct column user mapped
    x = 1:3,
    y = 1:3,
    stringsAsFactors = FALSE
  )
  
  # User explicitly maps icon_2
  p <- ggplot2::ggplot(df_regression, ggplot2::aes(x = x, y = y, icon = icon_2)) +
    geom_icon_point(dpi = 60)
  
  built <- ggplot2::ggplot_build(p)
  layer_data <- built$data[[1]]
  
  rendered_icons <- extract_icon_names(layer_data$image)
  
  # Should render heart, star, circle (from icon_2)
  testthat::expect_setequal(rendered_icons, c("heart", "star", "circle"))
  
  # Should NOT render "WRONG" (from icon column)
  testthat::expect_false("WRONG" %in% rendered_icons)
})

testthat::test_that("Icons: renders ALL hearts from 'icon_custom' column", {
  df_hearts <- data.frame(
    x = c(1, 2, 3),
    y = c(1, 2, 3),
    icon_custom = c("heart", "heart", "heart"),  # All hearts
    category = c("A", "A", "A"),
    stringsAsFactors = FALSE
  )
  
  p <- ggplot2::ggplot(df_hearts, ggplot2::aes(x = x, y = y, icon = icon_custom)) +
    geom_icon_point(dpi = 60)
  
  built <- ggplot2::ggplot_build(p)
  layer_data <- built$data[[1]]
  
  rendered_icons <- extract_icon_names(layer_data$image)
  
  # ALL should be "heart"
  testthat::expect_true(all(rendered_icons == "heart"))
  testthat::expect_equal(length(unique(rendered_icons)), 1)
  testthat::expect_equal(unique(rendered_icons), "heart")
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

testthat::test_that("Coords: coord_cartesian with limits", {
  p <- ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
    geom_icon_point(size = 2) +
    ggplot2::coord_cartesian(xlim = c(0, 15), ylim = c(0, 15))
  
  testthat::expect_s3_class(p, "ggplot")
})

testthat::test_that("Coords: reversed axes", {
  p <- ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
    geom_icon_point(size = 2) +
    ggplot2::scale_x_reverse() +
    ggplot2::scale_y_reverse()
  
  testthat::expect_s3_class(p, "ggplot")
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

### 17.03 other geoms --------------------------------------------------

testthat::test_that("geom_icon_point works with multiple ggplot2 layers", {
  
  df <- data.frame(
    x = 1:10,
    y = rnorm(10),
    category = rep(c("A", "B"), each = 5),
    icon = rep(c("star", "heart"), each = 5)
  )
  
  p <- ggplot2::ggplot(df, ggplot2::aes(x = x, y = y)) +
    ggplot2::geom_smooth(method = "lm", se = FALSE, color = "gray50") +  # Layer 1: Trend line
    ggplot2::geom_hline(yintercept = 0, linetype = "dashed") +           # Layer 2: Reference line
    geom_icon_point(ggplot2::aes(icon = icon, color = category), size = 5, dpi = 100) +       # Layer 3: Icon points
    ggplot2::geom_text(ggplot2::aes(label = category), nudge_y = 0.3) +  # Layer 4: Labels
    ggplot2::theme_minimal()                                              # Layer 5: Theme
  
  testthat::expect_s3_class(p, "ggplot")
  testthat::expect_length(p$layers, 4)  # smooth, hline, icon_point, text
  testthat::expect_s3_class(p$layers[[3]], "ggpop_icon_point_layer")
})

### 17.04 ggrepel for non-overlapping labels --------------------

testthat::test_that("works with ggrepel layers", {
  testthat::skip_if_not_installed("ggrepel")
  
  df <- data.frame(
    x = rnorm(15),
    y = rnorm(15),
    label = paste0("Point", 1:15),
    icon = sample(c("circle", "square", "heart"), 15, replace = TRUE),
    size_val = runif(15, 0.5, 2)
  )
  
  p <- ggplot2::ggplot(df, ggplot2::aes(x = x, y = y)) +
    ggplot2::geom_density_2d(color = "lightgray") +                      # Layer 1: Density contours
    geom_icon_point(ggplot2::aes(icon = icon, size = size_val, color = icon)) +        # Layer 2: Icon points
    ggrepel::geom_text_repel(ggplot2::aes(label = label),                # Layer 3: Non-overlapping labels
                             max.overlaps = 20) +
    ggplot2::geom_vline(xintercept = 0, alpha = 0.3) +                   # Layer 4: Vertical reference
    ggplot2::geom_hline(yintercept = 0, alpha = 0.3)                     # Layer 5: Horizontal reference
  
  testthat::expect_s3_class(p, "ggplot")
  testthat::expect_length(p$layers, 5)
})

### 17.05 ggforce for circles and hulls ------------------------------

testthat::test_that("works with ggforce layers", {
  testthat::skip_if_not_installed("ggforce")
  
  df <- data.frame(
    x = c(1, 2, 3, 4, 5, 1.5, 2.5, 3.5, 4.5),
    y = c(2, 3, 2, 4, 3, 1, 2, 3, 2),
    group = c(rep("A", 5), rep("B", 4)),
    icon = c(rep("star", 5), rep("heart", 4))
  )
  
  p <- ggplot2::ggplot(df, ggplot2::aes(x = x, y = y, color = group)) +
    ggforce::geom_mark_hull(ggplot2::aes(fill = group),                 # Layer 1: Convex hull
                            alpha = 0.1, expand = 0.05) +
    ggforce::geom_circle(ggplot2::aes(x0 = x, y0 = y, r = 0.2),        # Layer 2: Circles around points
                         alpha = 0.2) +
    geom_icon_point(ggplot2::aes(icon = icon), size = 2) +              # Layer 3: Icon points
    ggplot2::geom_path(alpha = 0.5) +                                    # Layer 4: Connect points
    ggplot2::coord_equal()                                               # Layer 5: Equal scales
  
  testthat::expect_s3_class(p, "ggplot")
  testthat::expect_true(length(p$layers) >= 4)
})

### 17.05 gghighlight for animated plots ------------------------------

testthat::test_that("works with gghighlight", {
  testthat::skip_if_not_installed("gghighlight")
  
  df <- data.frame(
    x = 1:20,
    y = cumsum(rnorm(20)),
    category = rep(c("A", "B", "C", "D"), each = 5),
    icon = rep(c("arrow-up", "arrow-down", "circle", "square"), each = 5)
  )
  
  p <- ggplot2::ggplot(df, ggplot2::aes(x = x, y = y, color = category)) +
    ggplot2::geom_line(linewidth = 1) +                                  # Layer 1: Lines
    geom_icon_point(ggplot2::aes(icon = icon), size = 1.5) +            # Layer 2: Icon points
    gghighlight::gghighlight(use_direct_label = FALSE) +
    ggplot2::geom_ribbon(ggplot2::aes(ymin = y - 0.5, ymax = y + 0.5), # Layer 4: Ribbon
                         alpha = 0.2) +
    ggplot2::theme_minimal()                                             # Layer 5: Theme
  
  testthat::expect_s3_class(p, "ggplot")
  testthat::expect_true(length(p$layers) >= 3)
})

### 17.06 patchwork for circles and hulls ------------------------------

testthat::test_that("works in patchwork compositions", {
  testthat::skip_if_not_installed("patchwork")
  
  df <- data.frame(
    x = rnorm(25),
    y = rnorm(25),
    category = sample(c("A", "B", "C"), 25, replace = TRUE)
  )
  
  df$icon <- ifelse(df$category == "A", "star",
                    ifelse(df$category == "B", "heart", "circle"))
  
  # Plot 1: Scatter with icons
  p1 <- ggplot2::ggplot(df, ggplot2::aes(x = x, y = y, color = category)) +
    geom_icon_point(ggplot2::aes(icon = icon)) +
    ggplot2::ggtitle("Icon Scatter")
  
  # Plot 2: Boxplot
  p2 <- ggplot2::ggplot(df, ggplot2::aes(x = category, y = y, fill = category)) +
    ggplot2::geom_boxplot() +
    ggplot2::ggtitle("Boxplot by Category")
  
  # Plot 3: Density with icons
  p3 <- ggplot2::ggplot(df, ggplot2::aes(x = x)) +
    ggplot2::geom_density(fill = "lightblue", alpha = 0.5) +
    ggplot2::ggtitle("Density")
  
  # Plot 4: Bar chart with icon annotations
  df_summary <- dplyr::count(df, category, icon)
  p4 <- ggplot2::ggplot(df_summary, ggplot2::aes(x = category, y = n, 
                                                 fill = category)) +
    ggplot2::geom_col() +
    ggplot2::ggtitle("Counts")
  
  # Combine with patchwork
  combined <- patchwork::wrap_plots(p1, p2, p3, p4, ncol = 2)
  
  testthat::expect_s3_class(combined, "patchwork")
  testthat::expect_s3_class(p1$layers[[1]], "ggpop_icon_point_layer")
})

### 17.07 multiple annotation layers -------------------------------------------

testthat::test_that("works with complex annotations", {
  
  df <- data.frame(
    x = 1:8,
    y = c(3, 5, 4, 7, 6, 8, 7, 9),
    label = letters[1:8],
    icon = rep(c("star", "circle"), each = 4)
  )
  
  p <- ggplot2::ggplot(df, ggplot2::aes(x = x, y = y)) +
    ggplot2::geom_area(fill = "lightgray", alpha = 0.3) + # Layer 1: Area
    ggplot2::geom_line(color = "blue", linewidth = 1) +   # Layer 2: Line
    geom_icon_point(ggplot2::aes(icon = icon, color = icon), size = 2) + # Layer 3: Icons
    ggplot2::annotate("rect", xmin = 2, xmax = 4, ymin = 3, ymax = 8,  # Layer 4: Rectangle
                      alpha = 0.1, fill = "red") +
    ggplot2::annotate("text", x = 3, y = 9, label = "Peak",            # Layer 5: Annotation
                      size = 5, fontface = "bold")
  
  testthat::expect_s3_class(p, "ggplot")
  testthat::expect_length(p$layers, 5)
  testthat::expect_s3_class(p$layers[[3]], "ggpop_icon_point_layer")
})

### 17.08 facets and multiple geoms --------------------------------------------

testthat::test_that("works with facets and multiple layers", {
  
  df <- data.frame(
    x = rep(1:10, 3),
    y = c(cumsum(rnorm(10)), cumsum(rnorm(10)), cumsum(rnorm(10))),
    panel = rep(c("Panel A", "Panel B", "Panel C"), each = 10),
    icon = rep(c("arrow-up", "arrow-down", "circle"), each = 10),
    highlight = rep(c(TRUE, FALSE), length.out = 30)
  )
  
  p <- ggplot2::ggplot(df, ggplot2::aes(x = x, y = y)) +
    ggplot2::geom_ribbon(ggplot2::aes(ymin = y - 1, ymax = y + 1),# Layer 1: Ribbon
                         fill = "lightblue", alpha = 0.3) +
    ggplot2::geom_line(color = "darkblue") +                     # Layer 2: Line
    geom_icon_point(ggplot2::aes(icon = icon,
                                 color = icon),
                    size = 1.5,
                    alpha = .8) +
    ggplot2::geom_hline(yintercept = 0, linetype = "dashed") + # Layer 4: Reference
    ggplot2::facet_wrap(~panel) +                              # Layer 5: Facets
    ggplot2::theme_bw()
  
  testthat::expect_s3_class(p, "ggplot")
  testthat::expect_length(p$layers, 4)
  testthat::expect_equal(length(p$facet$params$facets), 1)
})

### 17.09 stress test ------------------------------------------------------------
testthat::test_that("handles many layers gracefully", {
  
  df <- data.frame(
    x = 1:50,
    y = cumsum(rnorm(50)),
    category = sample(c("A", "B", "C"), 50, replace = TRUE)
  )
  
  df$icon <- ifelse(df$category == "A", "star",
                    ifelse(df$category == "B", "heart", "circle"))
  
  p <- ggplot2::ggplot(df, ggplot2::aes(x = x, y = y)) +
    ggplot2::geom_ribbon(ggplot2::aes(ymin = y - 2, ymax = y + 2),     # Layer 1
                         fill = "gray90") +
    ggplot2::geom_ribbon(ggplot2::aes(ymin = y - 1, ymax = y + 1),     # Layer 2
                         fill = "gray70") +
    ggplot2::geom_line(color = "black", linewidth = 0.5) +              # Layer 3
    ggplot2::geom_smooth(method = "loess", se = FALSE,                  # Layer 4
                         color = "red", linetype = "dashed") +
    geom_icon_point(ggplot2::aes(icon = icon, color = category),       # Layer 5
                    size = 1.2) +
    ggplot2::geom_hline(yintercept = mean(df$y), color = "blue") +     # Layer 6
    ggplot2::geom_vline(xintercept = 25, color = "green", alpha = 0.5) + # Layer 7
    ggplot2::theme_minimal() +
    ggplot2::labs(title = "Multi-layer plot with icons")
  
  testthat::expect_s3_class(p, "ggplot")
  testthat::expect_true(length(p$layers) >= 7)
})

# ******************************************************************************
# 18 Snapshot ------------------------------------------------------------------
# ******************************************************************************

testthat::test_that("geom_icon_point", {
  set.seed(1)
  n <- 5
  df <- data.frame(
    x = rnorm(n),
    y = rnorm(n),
    grp = rep(c("A", "B", "C"), length.out = n),
    icon = rep(c("user", "car", "heart"), length.out = n),
    stringsAsFactors = FALSE
  )
  
  p <- ggplot2::ggplot(df, ggplot2::aes(x = x, y = y)) +
    geom_icon_point(
      ggplot2::aes(icon = icon, color = grp),
      size = 0.8,
      legend_icons = TRUE
    ) +
    scale_legend_icon(size = 2.5) +
    ggplot2::theme_void(base_size = 8) +
    ggplot2::theme(
      legend.position = "right",
      plot.margin = grid::unit(rep(2, 4), "pt")
    ) +
    ggplot2::geom_blank()
  
  expect_doppelganger(
    title = "geom_icon_point",
    fig = p
  )
})


# ******************************************************************************
# END --------------------------------------------------------------------------
# ******************************************************************************