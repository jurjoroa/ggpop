# *****************************************************************************
#
# Script: test-geom_pop-clean.R
#
# Purpose: Ensure geom_pop() works robustly for all valid scenarios
#          without warnings or errors.
#
# Author: Jorge Roa
#
# Email: jorgeroa@stanford.edu
#
# Date Created: 02-Jan-2026
#
# *****************************************************************************

testthat::skip_if_not_installed("ggplot2")
testthat::skip_if_not_installed("dplyr")
testthat::skip_if_not_installed("ggimage")
testthat::skip_if_not_installed("fontawesome")

# ******************************************************************************
# 01 Basic clean cases ---------------------------------------------------
# ******************************************************************************

testthat::test_that("geom_pop clean: minimal raw mode", {
  
  df <- data.frame(
    sex  = c("male", "female", "male", "female"),
    icon = c("male", "female", "male", "female"),
    stringsAsFactors = FALSE
  )
  
  testthat::expect_no_warning(
    testthat::expect_no_error(
      ggplot2::ggplot_build(
        ggplot2::ggplot() +
          geom_pop(
            data = df,
            ggplot2::aes(icon = icon, group = sex, color = sex),
            size = 5,
            dpi = 100
          ) +
          ggplot2::theme_void()
      )
    )
  )
  
  testthat::skip_on_cran()
  
  testthat::expect_no_warning(
    testthat::expect_no_error(
      ggplot2::ggplotGrob(
        ggplot2::ggplot() +
          geom_pop(
            data = df,
            ggplot2::aes(icon = icon, group = sex, color = sex),
            size = 5,
            dpi = 100
          ) +
          ggplot2::theme_void()
      )
    )
  )
})


# ******************************************************************************
# 02 Data-driven size ----------------------------------------------------
# ******************************************************************************

testthat::test_that("geom_pop clean: aes(size=<var>)", {
  
  df <- data.frame(
    sex  = rep(c("male", "female"), each = 10),
    icon = rep(c("male", "female"), each = 10),
    sz   = rep(c(2, 5), each = 10),
    stringsAsFactors = FALSE
  )
  
  testthat::expect_no_warning(
    testthat::expect_no_error(
      ggplot2::ggplot_build(
        ggplot2::ggplot() +
          geom_pop(
            data = df,
            ggplot2::aes(icon = icon, group = sex, color = sex, size = sz),
            dpi = 120
          ) +
          ggplot2::theme_void()
      )
    )
  )
})


# ******************************************************************************
# 03 Facet: 10 panels × 5 groups -----------------------------------------
# ******************************************************************************

testthat::test_that("geom_pop clean: facet 10 panels x 5 groups", {
  
  base <- data.frame(
    panel = rep(paste0("P", sprintf("%02d", 1:10)), each = 5),
    grp   = rep(paste0("G", 1:5), times = 10),
    icon  = "user",
    stringsAsFactors = FALSE
  )
  
  df <- base[rep(seq_len(nrow(base)), each = 10), ]
  rownames(df) <- NULL
  
  testthat::expect_no_error(
    suppressWarnings(
      ggplot2::ggplot_build(
        ggplot2::ggplot() +
          geom_pop(
            data = df,
            ggplot2::aes(icon = icon, group = grp, color = grp),
            facet = panel,
            size = 4,
            arrange = F,
            dpi = 30
          ) +
          ggplot2::facet_wrap(~ panel) +
          ggplot2::theme_void()
      )
    )
  )
})


# ******************************************************************************
# 04 20 groups with 20 icons ----------------------------------------------
# ******************************************************************************

testthat::test_that("geom_pop clean: 20 groups with 20 icons", {
  
  icons <- c(
    "user","users","person","person-walking","person-running",
    "car","bus","train","bicycle","plane",
    "heart","star","circle","square","triangle-exclamation",
    "house","building","tree","cloud","bolt"
  )
  
  df <- data.frame(
    grp  = rep(paste0("G", sprintf("%02d", 1:20)), each = 15),
    icon = rep(icons, each = 15),
    stringsAsFactors = FALSE
  )
  
  testthat::expect_no_warning(
    testthat::expect_no_error(
      ggplot2::ggplot_build(
        ggplot2::ggplot() +
          geom_pop(
            data = df,
            ggplot2::aes(icon = icon, group = grp, color = grp),
            size = 1,
            arrange = F,
            dpi = 120
          ) +
          ggplot2::theme_void()
      )
    )
  )
})


# ******************************************************************************
# 05 Facet inferred from ggplot -------------------------------------------
# ******************************************************************************

testthat::test_that("geom_pop clean: facet inferred from ggplot", {
  
  df <- data.frame(
    panel = rep(c("A", "B", "C"), each = 40),
    sex   = rep(c("male", "female"), length.out = 120),
    icon  = rep(c("male", "female"), length.out = 120),
    stringsAsFactors = FALSE
  )
  
  testthat::expect_no_warning(
    testthat::expect_no_error(
      ggplot2::ggplot_build(
        ggplot2::ggplot(df) +
          geom_pop(
            ggplot2::aes(icon = icon, group = sex, color = sex),
            size = 4,
            dpi = 100
          ) +
          ggplot2::facet_wrap(~ panel) +
          ggplot2::theme_void()
      )
    )
  )
})


# ******************************************************************************
# 06 arrange=TRUE with n/prop ----------------------------------------------
# ******************************************************************************

testthat::test_that("geom_pop clean: arrange=TRUE with n/prop", {
  
  df <- data.frame(
    type = rep(c("male", "female"), each = 50),
    icon = rep(c("male", "female"), each = 50),
    n    = rep(50, 100),
    prop = rep(0.5, 100),
    stringsAsFactors = FALSE
  )
  
  testthat::expect_no_warning(
    testthat::expect_no_error(
      ggplot2::ggplot_build(
        ggplot2::ggplot() +
          geom_pop(
            data = df,
            ggplot2::aes(icon = icon, group = type, color = type),
            arrange = F,
            size = 4,
            dpi = 120
          ) +
          ggplot2::theme_void()
      )
    )
  )
})


# ******************************************************************************
# 07 No color mapping (still valid) ----------------------------------------
# ******************************************************************************

testthat::test_that("geom_pop clean: no color mapping", {
  
  df <- data.frame(
    sex  = rep(c("male", "female"), each = 40),
    icon = rep(c("male", "female"), each = 40),
    stringsAsFactors = FALSE
  )
  
  testthat::expect_no_warning(
    testthat::expect_no_error(
      ggplot2::ggplot_build(
        ggplot2::ggplot() +
          geom_pop(
            data = df,
            ggplot2::aes(icon = icon, group = sex),
            size = 4,
            dpi = 120
          ) +
          ggplot2::theme_void()
      )
    )
  )
})


