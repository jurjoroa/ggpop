# *****************************************************************************
#
# Script: test-geom_pop-warnings.R
#
# Purpose: Test warnings produced by geom_pop().
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
#   - This file tests ONLY warnings (non-fatal behavior).
#   - We avoid matching warning text to keep tests robust.
#   - We use ggplot() + geom_pop() directly.
#
# *****************************************************************************

# ******************************************************************************
# 01 Load inputs ----------------------------------------------------------
# ******************************************************************************

testthat::skip_if_not_installed("ggplot2")
testthat::skip_if_not_installed("dplyr")
testthat::skip_if_not_installed("ggimage")
testthat::skip_if_not_installed("fontawesome")


# ******************************************************************************
## 01.01 Test dataframes ------------------------------------------------
# ******************************************************************************

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

# Helpers (only where needed)
.build_plot <- function(p) ggplot2::ggplot_build(p)

# ******************************************************************************
# 02 Start tests ----------------------------------------------------------
# ******************************************************************************

# ******************************************************************************
# 03 geom_pop --------------------------------------------------------------
# ******************************************************************************

# ******************************************************************************
## 03.01 Warnings -----------------------------------------------------------
# ******************************************************************************

### 03.01.01 size specified both inside aes() and as argument ------------------

testthat::test_that("Warning: size inside aes() overrides geom_pop(size = ...)", {
  df_sz <- df_raw
  df_sz$size <- c(5, 2, 5, 2)
  
  testthat::expect_warning(
    ggplot2::ggplot() +
      geom_pop(
        data = df_sz,
        ggplot2::aes(icon = icon, size = size, color = sex),
        size = 10,
        dpi  = 100
      )
  )
})


### 03.01.02 facet/group caution when multiple groups exist --------------------

testthat::test_that("Warning: facet/group caution (data has group column)", {
  df_grp <- df_raw
  df_grp$group <- df_grp$sex
  
  testthat::expect_warning(
    ggplot2::ggplot() +
      geom_pop(
        data = df_grp,
        ggplot2::aes(icon = icon, group = group)
      )
  )
})

### 03.01.03 facet/group caution when facet is passed inside geom_pop ----------

testthat::test_that("Warning: facet specified inside geom_pop()", {
  df_facet <- df_processed
  df_facet$status <- c("A", "A", "B", "B")
  
  testthat::expect_warning(
    ggplot2::ggplot() +
      geom_pop(
        data  = df_facet,
        ggplot2::aes(icon = icon, group = type),
        facet = status
      )
  )
})

### 03.01.04 warn_geom_pop_inputs: x/y aesthetics ignored ----------------------

testthat::test_that("Warning: x/y mapped are ignored", {
  # x/y are not part of geom_pop API; warn_geom_pop_inputs should warn.
  testthat::expect_warning(
    ggplot2::ggplot() +
      geom_pop(
        data = df_raw,
        ggplot2::aes(icon = icon, group = sex, x = sex, y = sex),
        dpi = 60
      )
  )
})

### 03.01.05 warn_geom_pop_inputs: dpi high warning ---------------------------

testthat::test_that("Warning: dpi very high", {
  testthat::expect_warning(
    ggplot2::ggplot() +
      geom_pop(
        data = df_raw,
        ggplot2::aes(icon = icon, group = sex),
        dpi = 800
      )
  )
})

### 03.01.06 warn_geom_pop_inputs: multiple icons per legend group ------------

testthat::test_that("Warning: multiple icons per color group", {
  df_icons <- data.frame(
    sex  = c("A", "A", "B", "B"),
    icon = c("male", "female", "male", "female"),
    stringsAsFactors = FALSE
  )
  
  # Same color group "A" maps to 2 icons; should warn.
  testthat::expect_warning(
    ggplot2::ggplot() +
      geom_pop(
        data = df_icons,
        ggplot2::aes(icon = icon, group = sex, color = sex),
        legend_icons = TRUE,
        dpi = 60
      )
  )
})

# ******************************************************************************
## 03.02 Smoke: warnings should still allow build ---------------------------
# ******************************************************************************

### 03.02.01 build succeeds even if a warning is emitted -----------------------

testthat::test_that("Build: plot still builds when warning occurs", {
  df_grp <- df_raw
  df_grp$group <- df_grp$sex
  
  testthat::expect_warning(
    ggplot2::ggplot() +
         geom_pop(
            data = df_grp,
            ggplot2::aes(icon = icon, group = group),
            dpi = 60
           )
  )
})
