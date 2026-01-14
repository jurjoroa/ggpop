# *****************************************************************************
#
# Script: test-geom_pop-errors.R
#
# Purpose: Test errors (hard stops) produced by geom_pop().
#
# Author: Jorge Roa
#
# Email: jorgeroa@stanford.edu
#
# Date Created: 02-Jan-2026
#
# *****************************************************************************
#
# Notes:
#   - This file tests ONLY errors (hard stops).
#   - We avoid matching exact error text to keep tests robust.
#   - We use ggplot() + geom_pop() directly whenever the error occurs pre-build.
#   - For integration-level failures (render/build), we call ggplot_build() or ggplotGrob().
#
# *****************************************************************************

# ******************************************************************************
# 01 Load inputs ---------------------------------------------------------------
# ******************************************************************************

testthat::skip_if_not_installed("ggplot2")
testthat::skip_if_not_installed("dplyr")
testthat::skip_if_not_installed("ggimage")
testthat::skip_if_not_installed("fontawesome")

# ------------------------------------------------------------------------------
# Test fixtures (minimal, stable)
# ------------------------------------------------------------------------------

df_raw <- data.frame(
  sex  = c("male", "female", "male", "female"),
  icon = c("male", "female", "male", "female"),
  stringsAsFactors = FALSE
)

df_processed <- data.frame(
  type = c("male", "female", "male", "female"),
  icon = c("male", "female", "male", "female"),
  stringsAsFactors = FALSE
)

.build_plot <- function(p) ggplot2::ggplot_build(p)
.grob_plot  <- function(p) ggplot2::ggplotGrob(p)

# ******************************************************************************
# 02 Start tests ---------------------------------------------------------------
# ******************************************************************************

# ******************************************************************************
# 03 geom_pop ------------------------------------------------------------------
# ******************************************************************************

# ******************************************************************************
## 03.01 Errors: input validation (hard stops) ----------------------------------
# ******************************************************************************

### 03.01.01 dpi inputs --------------------------------------------------------

testthat::test_that("Error: dpi too low", {
  testthat::expect_error(
    ggplot2::ggplot() +
      geom_pop(
        data = df_raw,
        ggplot2::aes(icon = icon, group = sex),
        dpi = 20
      )
  )
})

### 03.01.02 icon inputs -------------------------------------------------------

testthat::test_that("Error: icon not specified (no aes(icon=) and no icon column)", {
  df_no_icon <- data.frame(
    sex = c("male", "female"),
    stringsAsFactors = FALSE
  )
  
  testthat::expect_error(
    ggplot2::ggplot() +
      geom_pop(
        data = df_no_icon,
        ggplot2::aes(group = sex)
      )
  )
})

testthat::test_that("Error: invalid icon values (NA / empty)", {
  df_bad_icon <- df_raw
  df_bad_icon$icon[2] <- NA
  
  testthat::expect_error(
    ggplot2::ggplot() +
      geom_pop(
        data = df_bad_icon,
        ggplot2::aes(icon = icon, group = sex),
        dpi = 60
      )
  )
})

### 03.01.03 raw mode detection ------------------------------------------------

testthat::test_that("Error: raw data without group or color mapping", {
  testthat::expect_error(
    ggplot2::ggplot() +
      geom_pop(
        data = df_raw,
        ggplot2::aes(icon = icon)
      )
  )
})

testthat::test_that("Error: mapped group variable not present in data", {
  testthat::expect_error(
    ggplot2::ggplot() +
      geom_pop(
        data = df_raw,
        ggplot2::aes(icon = icon, group = does_not_exist)
      )
  )
})

### 03.01.04 facet inputs ------------------------------------------------------

testthat::test_that("Error: facet column not found", {
  testthat::expect_error(
    ggplot2::ggplot() +
      geom_pop(
        data  = df_processed,
        ggplot2::aes(icon = icon, group = type),
        facet = not_a_column
      )
  )
})

### 03.01.05 forbidden aesthetics ----------------------------------------------

testthat::test_that("Error: image aesthetic is not allowed", {
  testthat::expect_error(
    ggplot2::ggplot() +
      geom_pop(
        data = df_raw,
        ggplot2::aes(icon = icon, image = icon, group = sex)
      )
  )
})

# ******************************************************************************
## 03.02 Errors: icon volume limits --------------------------------------------
# ******************************************************************************

### 03.02.01 global max icons --------------------------------------------------

testthat::test_that("Error: too many icons requested (global)", {
  big <- data.frame(
    sex  = rep(c("male", "female"), length.out = 1001),
    icon = rep(c("male", "female"), length.out = 1001),
    stringsAsFactors = FALSE
  )
  
  testthat::expect_error(
    ggplot2::ggplot() +
      geom_pop(
        data = big,
        ggplot2::aes(icon = icon, group = sex),
        dpi = 60
      )
  )
})

### 03.02.02 per-facet max icons ------------------------------------------------

testthat::test_that("Error: too many icons per facet group", {
  big_f <- data.frame(
    sex   = rep(c("male", "female"), each = 1001),
    facet = rep(c("A", "B"), each = 1001),
    icon  = rep(c("male", "female"), each = 1001),
    stringsAsFactors = FALSE
  )
  
  testthat::expect_error(
    suppressWarnings(
      ggplot2::ggplot() +
        geom_pop(
          data  = big_f,
          ggplot2::aes(icon = icon, group = sex),
          facet = facet,
          dpi   = 60
        )
    )
  )
})


# ******************************************************************************
## 03.03 Integration errors (build/render) -------------------------------------
# ******************************************************************************

### 03.03.01 unknown icon name (fontawesome render failure) ---------------------

testthat::test_that("Integration: unknown icon name fails (build/render)", {
  testthat::skip_on_cran()
  
  df_unknown <- df_raw
  df_unknown$icon <- "this_icon_does_not_exist"
  
  # Depending on where the failure occurs in your pipeline, this may fail
  # at layer creation OR at build. We accept either by testing build.
  testthat::expect_error(
    .build_plot(
      ggplot2::ggplot() +
        geom_pop(
          data = df_unknown,
          ggplot2::aes(icon = icon, group = sex, color = sex),
          legend_icons = TRUE,
          dpi = 60
        )
    )
  )
})


# ******************************************************************************
# 4 Legend icons: mismatch triggers expected error ----------------------------
# ******************************************************************************

testthat::test_that("Legend icon raster count mismatch triggers error", {
  
  testthat::skip_if_not_installed("grid")
  testthat::skip_if_not_installed("gtable")
  
  icons_50 <- c(
    "user", "users", "person", "person-walking", "person-running",
    "car", "bus", "train", "bicycle", "plane",
    "heart", "star", "circle", "square", "triangle-exclamation",
    "house", "building", "tree", "cloud", "bolt",
    "bell", "bell-slash", "check", "xmark", "ban",
    "info", "question", "shield", "lock", "unlock",
    "flag", "map", "map-location-dot", "location-dot", "compass",
    "briefcase", "suitcase", "passport", "ticket", "route",
    "calendar", "clock", "hourglass", "stopwatch", "battery-full",
    "wifi", "signal", "phone", "envelope", "globe"
  )
  
  testthat::expect_equal(length(icons_50), 50)
  
  df <- data.frame(
    grp  = rep(paste0("G", sprintf("%02d", seq_len(50))), each = 5),
    icon = rep(icons_50, each = 5),
    stringsAsFactors = FALSE
  )
  
  p <- ggplot2::ggplot(df) +
    geom_pop(
      ggplot2::aes(icon = icon, group = grp, color = grp),
      size = 1,
      dpi = 100,
      legend_icons = FALSE   # <- intentionally break the invariant
    ) +
    ggplot2::theme_void() +
    ggplot2::theme(legend.position = "right")
  
  gt <- ggplot2::ggplotGrob(p)
  
  guide_idx <- which(vapply(
    gt$grobs,
    function(x) inherits(x, "gtable") && identical(x$name, "guide-box"),
    logical(1)
  ))
  
  testthat::expect_true(length(guide_idx) == 1)
  
  guide <- gt$grobs[[guide_idx]]
  
  rasters <- list()
  recurse <- function(x) {
    if (inherits(x, "rastergrob")) {
      rasters[[length(rasters) + 1]] <<- x
    }
    if (inherits(x, "gtable") && length(x$grobs)) {
      for (g in x$grobs) recurse(g)
    }
    if (inherits(x, "gTree") && length(x$children)) {
      for (g in x$children) recurse(g)
    }
    if (is.list(x)) {
      for (g in x) recurse(g)
    }
  }
  recurse(guide)
  
  raster_names <- vapply(rasters, function(r) r$name, character(1))
  n_unique_rasters <- length(unique(raster_names))
  n_unique_icons   <- length(unique(df$icon))
  
  # 🔥 EXPECTED FAILURE: counts do NOT match
  testthat::expect_error(
    testthat::expect_equal(n_unique_rasters, n_unique_icons),
    info = "Legend raster/icon mismatch did not trigger an error as expected."
  )
})




# ******************************************************************************
# END --------------------------------------------------------------------------
# ******************************************************************************

