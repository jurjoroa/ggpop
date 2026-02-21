# *****************************************************************************
#
# Script: test-10_scale_legend_icon.R
#
# Purpose: Integration tests for scale_legend_icon() with geom_pop() and 
#          geom_icon_point() - organized by errors, warnings, and pass checks
#
# Author: Jorge Roa
#
# Email: jorgeroa@stanford.edu
#
# Date Created: 03-Feb-2026
#
# *****************************************************************************
#
# Notes:
#   - Tests scale_legend_icon() with 2x multiplier behavior
#   - Organized into: Errors (hard stops), Warnings (soft), Pass Checks (success)
#   - Tests integration with both geom_pop() and geom_icon_point()
#   - Verifies 2x size multiplier is applied correctly
#
# *****************************************************************************

# ******************************************************************************
# 01 Load inputs ---------------------------------------------------------------
# ******************************************************************************

testthat::skip_if_not_installed("ggplot2")
testthat::skip_if_not_installed("grid")

df_pop <- data.frame(
  type = rep(c("male", "female"), each = 50),
  icon = rep(c("mars", "venus"), each = 50),
  stringsAsFactors = FALSE
)

df_scatter <- data.frame(
  x = rnorm(100),
  y = rnorm(100),
  category = sample(c("A", "B", "C"), 100, replace = TRUE),
  stringsAsFactors = FALSE
)
df_scatter$icon <- c("A" = "circle", "B" = "square", "C" = "star")[df_scatter$category]


.build_plot <- function(p) ggplot2::ggplot_build(p)

# ******************************************************************************
# 02 Start tests ---------------------------------------------------------------
# ******************************************************************************

# ******************************************************************************
# 03 scale_legend_icon ---------------------------------------------------------
# ******************************************************************************

# ******************************************************************************
## 03.01 Errors: size parameter (hard stops) -----------------------------------
# ******************************************************************************

### 03.01.01 Non-numeric size - geom_pop ---------------------------------------

testthat::test_that("Error: non-numeric size - geom_pop", {
  testthat::expect_error(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = "big")
  )
})

testthat::test_that("Error: character size - geom_pop", {
  testthat::expect_error(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = "10")
  )
})

testthat::test_that("Error: logical size - geom_pop", {
  testthat::expect_error(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = TRUE)
  )
})

### 03.01.02 Non-numeric size - geom_icon_point --------------------------------

testthat::test_that("Error: non-numeric size - geom_icon_point", {
  testthat::expect_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point() +
      scale_legend_icon(size = "large")
  )
})

testthat::test_that("Error: list size - geom_icon_point", {
  testthat::expect_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point() +
      scale_legend_icon(size = list(10))
  )
})

### 03.01.03 Vector size - geom_pop --------------------------------------------

testthat::test_that("Error: vector size - geom_pop", {
  testthat::expect_error(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = c(10, 20))
  )
})

testthat::test_that("Error: multiple values size - geom_pop", {
  testthat::expect_error(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = 1:5)
  )
})


### 03.01.04 Non-positive size - geom_pop --------------------------------------

testthat::test_that("Error: negative size - geom_pop", {
  testthat::expect_error(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = -10)
  )
})

testthat::test_that("Error: zero size - geom_pop", {
  testthat::expect_error(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = 0)
  )
})

testthat::test_that("Error: negative decimal size - geom_pop", {
  testthat::expect_error(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = -0.5)
  )
})

### 03.01.05 Non-positive size - geom_icon_point -------------------------------

testthat::test_that("Error: negative size - geom_icon_point", {
  testthat::expect_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point() +
      scale_legend_icon(size = -5)
  )
})

testthat::test_that("Error: zero size - geom_icon_point", {
  testthat::expect_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point() +
      scale_legend_icon(size = 0)
  )
})

### 03.01.06 Non-finite size - geom_pop ----------------------------------------

testthat::test_that("Error: Inf size - geom_pop", {
  testthat::expect_error(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = Inf)
  )
})

testthat::test_that("Error: NA size - geom_pop", {
  testthat::expect_error(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = NA)
  )
})

### 03.01.07 Non-finite size - geom_icon_point ---------------------------------

testthat::test_that("Error: Inf size - geom_icon_point", {
  testthat::expect_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point() +
      scale_legend_icon(size = Inf)
  )
})

testthat::test_that("Error: NA_real size - geom_icon_point", {
  testthat::expect_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point() +
      scale_legend_icon(size = NA_real_)
  )
})

# ******************************************************************************
## 03.02 Errors: unit parameter (hard stops) -----------------------------------
# ******************************************************************************

### 03.02.01 Non-character unit - geom_pop -------------------------------------

testthat::test_that("Error: numeric unit - geom_pop", {
  testthat::expect_error(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = 10, unit = 123)
  )
})

testthat::test_that("Error: numeric unit - geom_pop", {
  testthat::expect_error(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = 10, unit = "npc")
  )
})

testthat::test_that("Error: logical unit - geom_pop", {
  testthat::expect_error(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = 10, unit = TRUE)
  )
})

testthat::test_that("Error: list unit - geom_pop", {
  testthat::expect_error(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = 10, unit = list("mm"))
  )
})

### 03.02.02 Non-character unit - geom_icon_point ------------------------------

testthat::test_that("Error: numeric unit - geom_icon_point", {
  testthat::expect_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point() +
      scale_legend_icon(size = 10, unit = 456)
  )
})

testthat::test_that("Error: logical unit - geom_icon_point", {
  testthat::expect_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point() +
      scale_legend_icon(size = 10, unit = FALSE)
  )
})

### 03.02.03 Vector unit - geom_pop --------------------------------------------

testthat::test_that("Error: vector unit - geom_pop", {
  testthat::expect_error(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = 10, unit = c("mm", "cm"))
  )
})

### 03.02.04 Vector unit - geom_icon_point -------------------------------------

testthat::test_that("Error: vector unit - geom_icon_point", {
  testthat::expect_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point() +
      scale_legend_icon(size = 10, unit = c("mm", "cm", "inches"))
  )
})

# ******************************************************************************
## 03.03 Warnings: size too large (> 25mm → 50mm actual) -----------------------
# ******************************************************************************

### 03.03.01 Large mm - geom_pop -----------------------------------------------

testthat::test_that("Warning: size > 25mm - geom_pop", {
  testthat::expect_warning(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = 30, unit = "mm") +
      ggplot2::theme(legend.position = "right")
  )
})

testthat::test_that("Warning: size 26mm shows multiplier message - geom_pop", {
  testthat::expect_warning(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = 26, unit = "mm") +
      ggplot2::theme(legend.position = "right")
  )
})

testthat::test_that("Warning: size 50mm shows actual size - geom_pop", {
  testthat::expect_warning(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = 50, unit = "mm") +
      ggplot2::theme(legend.position = "right")
  )
})

### 03.03.02 Large cm - geom_pop -----------------------------------------------

testthat::test_that("Warning: size > 2.5cm - geom_pop", {
  testthat::expect_warning(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = 3, unit = "cm") +
      ggplot2::theme(legend.position = "right")
  )
})

testthat::test_that("Warning: size 4cm shows multiplier - geom_pop", {
  testthat::expect_warning(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = 4, unit = "cm") +
      ggplot2::theme(legend.position = "right")
  )
})

### 03.03.03 Large inches - geom_pop -------------------------------------------

testthat::test_that("Warning: size > 1 inch - geom_pop", {
  testthat::expect_warning(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = 1.2, unit = "inches") +
      ggplot2::theme(legend.position = "right")
  )
})

### 03.03.04 Large mm - geom_icon_point ----------------------------------------

testthat::test_that("Warning: size > 25mm - geom_icon_point", {
  testthat::expect_warning(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point() +
      scale_legend_icon(size = 30, unit = "mm")
  )
})


# ******************************************************************************
## 03.04 Warnings: size too small (< 1.5mm → 3mm actual) -----------------------
# ******************************************************************************

### 03.04.01 Small mm - geom_pop -----------------------------------------------

testthat::test_that("Warning: size < 1.5mm - geom_pop", {
  testthat::expect_warning(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = 1, unit = "mm") +
      ggplot2::theme(legend.position = "right")
  )
})

testthat::test_that("Warning: size 0.5mm shows multiplier - geom_pop", {
  testthat::expect_warning(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = 0.5, unit = "mm") +
      ggplot2::theme(legend.position = "right")
  )
})

testthat::test_that("Warning: size 1mm shows actual size - geom_pop", {
  testthat::expect_warning(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = 1, unit = "mm") +
      ggplot2::theme(legend.position = "right")
  )
})

### 03.04.02 Small cm - geom_pop -----------------------------------------------

testthat::test_that("Warning: size < 0.15cm - geom_pop", {
  testthat::expect_warning(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = 0.1, unit = "cm") +
      ggplot2::theme(legend.position = "right")
  )
})

### 03.04.03 Small mm - geom_icon_point ----------------------------------------

testthat::test_that("Warning: size < 1.5mm - geom_icon_point", {
  testthat::expect_warning(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, color = category)) +
      geom_icon_point() +
      scale_legend_icon(size = 1, unit = "mm")
  )
})

testthat::test_that("Warning: size 0.8mm shows actual - geom_icon_point", {
  testthat::expect_warning(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, color = category)) +
      geom_icon_point() +
      scale_legend_icon(size = 0.8, unit = "mm")
  )
})

### 03.04.04 Small inches - geom_icon_point ------------------------------------

testthat::test_that("Warning: size < 0.06 inches - geom_icon_point", {
  testthat::expect_warning(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, color = category)) +
      geom_icon_point() +
      scale_legend_icon(size = 0.05, unit = "inches")
  )
})


# ******************************************************************************
## 03.06 Warnings: invalid spacing (soft) --------------------------------------
# ******************************************************************************

### 03.06.01 Negative spacing - geom_pop ---------------------------------------

testthat::test_that("Warning: negative spacing - geom_pop", {
  testthat::expect_warning(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = 10, spacing = -0.5) +
      ggplot2::theme(legend.position = "right")
  )
})

testthat::test_that("Warning: non-numeric spacing - geom_pop", {
  testthat::expect_warning(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = 10, spacing = "large") +
      ggplot2::theme(legend.position = "right")
  )
})

testthat::test_that("Warning: vector spacing - geom_pop", {
  testthat::expect_warning(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = 10, spacing = c(0.2, 0.3)) +
      ggplot2::theme(legend.position = "right")
  )
})

### 03.06.02 Negative spacing - geom_icon_point --------------------------------

testthat::test_that("Warning: negative spacing - geom_icon_point", {
  testthat::expect_warning(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, color = category)) +
      geom_icon_point() +
      scale_legend_icon(size = 10, spacing = -1)
  )
})

testthat::test_that("Warning: logical spacing - geom_icon_point", {
  testthat::expect_warning(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, color = category)) +
      geom_icon_point() +
      scale_legend_icon(size = 10, spacing = TRUE)
  )
})

# ******************************************************************************
## 03.07 Pass checks: valid sizes (no warnings) --------------------------------
# ******************************************************************************

### 03.07.01 Valid sizes - geom_pop --------------------------------------------

testthat::test_that("Pass: size 5mm - geom_pop", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = 5, unit = "mm") +
      ggplot2::theme(legend.position = "right")
  )
})

testthat::test_that("Pass: size 10mm - geom_pop", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = 10, unit = "mm") +
      ggplot2::theme(legend.position = "right")
  )
})

testthat::test_that("Pass: size 20mm - geom_pop", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = 20, unit = "mm") +
      ggplot2::theme(legend.position = "right")
  )
})

testthat::test_that("Pass: size at threshold 25mm - geom_pop", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = 25, unit = "mm") +
      ggplot2::theme(legend.position = "right")
  )
})

### 03.07.02 Valid sizes - geom_icon_point -------------------------------------

testthat::test_that("Pass: size 3mm - geom_icon_point", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, color = category)) +
      geom_icon_point() +
      scale_legend_icon(size = 3, unit = "mm")
  )
})

testthat::test_that("Pass: size 10mm - geom_icon_point", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, color = category)) +
      geom_icon_point() +
      scale_legend_icon(size = 10, unit = "mm")
  )
})

testthat::test_that("Pass: size 15mm - geom_icon_point", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, color = category)) +
      geom_icon_point() +
      scale_legend_icon(size = 15, unit = "mm")
  )
})

# ******************************************************************************
## 03.08 Pass checks: different units ------------------------------------------
# ******************************************************************************

### 03.08.01 Different units - geom_pop ----------------------------------------

testthat::test_that("Pass: cm unit - geom_pop", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = 1, unit = "cm") +
      ggplot2::theme(legend.position = "right")
  )
})

testthat::test_that("Pass: inches unit - geom_pop", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = 0.5, unit = "inches") +
      ggplot2::theme(legend.position = "right")
  )
})

testthat::test_that("Pass: points unit - geom_pop", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = 50, unit = "points") +
      ggplot2::theme(legend.position = "right")
  )
})


### 03.08.02 Different units - geom_icon_point ---------------------------------

testthat::test_that("Pass: cm unit - geom_icon_point", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, color = category)) +
      geom_icon_point() +
      scale_legend_icon(size = 1.5, unit = "cm")
  )
})

testthat::test_that("Pass: inches unit - geom_icon_point", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, color = category)) +
      geom_icon_point() +
      scale_legend_icon(size = 0.4, unit = "inches")
  )
})

testthat::test_that("Pass: points unit - geom_icon_point", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, color = category)) +
      geom_icon_point() +
      scale_legend_icon(size = 60, unit = "points")
  )
})

# ******************************************************************************
## 03.09 Pass checks: spacing values -------------------------------------------
# ******************************************************************************

### 03.09.01 Spacing values - geom_pop -----------------------------------------

testthat::test_that("Pass: default spacing - geom_pop", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = 10) +
      ggplot2::theme(legend.position = "right")
  )
})

testthat::test_that("Pass: tight spacing - geom_pop", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = 10, spacing = 0.1) +
      ggplot2::theme(legend.position = "right")
  )
})

testthat::test_that("Pass: loose spacing - geom_pop", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = 10, spacing = 0.5) +
      ggplot2::theme(legend.position = "right")
  )
})

testthat::test_that("Pass: zero spacing - geom_pop", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = 10, spacing = 0) +
      ggplot2::theme(legend.position = "right")
  )
})

### 03.09.02 Spacing values - geom_icon_point ----------------------------------

testthat::test_that("Pass: custom spacing - geom_icon_point", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, color = category)) +
      geom_icon_point() +
      scale_legend_icon(size = 10, spacing = 0.3)
  )
})

testthat::test_that("Pass: zero spacing - geom_icon_point", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, color = category)) +
      geom_icon_point() +
      scale_legend_icon(size = 10, spacing = 0)
  )
})

# ******************************************************************************
## 03.11 Pass checks: theme compatibility --------------------------------------
# ******************************************************************************

### 03.11.01 Theme compatibility - geom_pop ------------------------------------

testthat::test_that("Pass: theme_void compatibility - geom_pop", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = 10) +
      ggplot2::theme(legend.position = "right")
  )
})

testthat::test_that("Pass: theme_minimal compatibility - geom_pop", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_minimal() +
      scale_legend_icon(size = 10) +
      ggplot2::theme(legend.position = "right")
  )
})

testthat::test_that("Pass: theme_bw compatibility - geom_pop", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_bw() +
      scale_legend_icon(size = 10) +
      ggplot2::theme(legend.position = "right")
  )
})

### 03.11.02 Theme compatibility - geom_icon_point -----------------------------

testthat::test_that("Pass: theme_minimal compatibility - geom_icon_point", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, color = category)) +
      geom_icon_point() +
      ggplot2::theme_minimal() +
      scale_legend_icon(size = 10)
  )
})

testthat::test_that("Pass: theme_classic compatibility - geom_icon_point", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, color = category)) +
      geom_icon_point() +
      ggplot2::theme_classic() +
      scale_legend_icon(size = 10)
  )
})

# ******************************************************************************
## 03.12 Pass checks: default values -------------------------------------------
# ******************************************************************************

### 03.12.01 Default values - geom_pop -----------------------------------------

testthat::test_that("Pass: all defaults - geom_pop", {
  testthat::expect_no_error(
  ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
    geom_pop(size = 1) +
    ggplot2::theme_void() +
    scale_legend_icon() +
    ggplot2::theme(legend.position = "right")
  )
})

testthat::test_that("Pass: only size specified - geom_pop", {
  testthat::expect_no_error(
  ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
    geom_pop(size = 1) +
    ggplot2::theme_void() +
    scale_legend_icon(size = 15) +
    ggplot2::theme(legend.position = "right")
  )
})

### 03.12.02 Default values - geom_icon_point ----------------------------------

testthat::test_that("Pass: all defaults - geom_icon_point", {
  testthat::expect_no_error(
  ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, color = category)) +
    geom_icon_point() +
    scale_legend_icon()
  )
})

# ******************************************************************************
## 03.13 Pass checks: boundary values ------------------------------------------
# ******************************************************************************

### 03.13.01 Boundary values - geom_pop ----------------------------------------

testthat::test_that("Pass: at 25mm threshold no warning - geom_pop", {
  testthat::expect_no_warning(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = 25, unit = "mm") +
      ggplot2::theme(legend.position = "right")
  )
})

testthat::test_that("Pass: at 1.5mm threshold no warning - geom_pop", {
  testthat::expect_no_warning(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = 1.5, unit = "mm") +
      ggplot2::theme(legend.position = "right")
  )
})

testthat::test_that("Pass: very small but valid size - geom_pop", {
  testthat::expect_warning(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = 0.01, unit = "mm") +
      ggplot2::theme(legend.position = "right")
  )
})

### 03.13.02 Boundary values - geom_icon_point ---------------------------------

testthat::test_that("Pass: at 25mm threshold no warning - geom_icon_point", {
  testthat::expect_no_warning(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, color = category)) +
      geom_icon_point() +
      scale_legend_icon(size = 25, unit = "mm")
  )
})

testthat::test_that("Pass: at 1.5mm threshold no warning - geom_icon_point", {
  testthat::expect_no_warning(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, 
                                             color = category)) +
      geom_icon_point() +
      scale_legend_icon(size = 1.5, unit = "mm")
  )
})



# ******************************************************************************
## 03.15 Pass checks: build success --------------------------------------------
# ******************************************************************************

### 03.15.01 Build success - geom_pop ------------------------------------------

testthat::test_that("Pass: basic plot builds successfully - geom_pop", {
  testthat::expect_no_error(
  ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
    geom_pop(size = 1) +
    ggplot2::theme_void() +
    scale_legend_icon(size = 10) +
    ggplot2::theme(legend.position = "right")
  )
})

testthat::test_that("Pass: complex plot builds successfully - geom_pop", {
  testthat::expect_no_error(
  ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
    geom_pop(size = 1) +
    ggplot2::theme_minimal(base_size = 14) +
    scale_legend_icon(size = 15, spacing = 0.3) +
    ggplot2::labs(title = "Test Plot") +
    ggplot2::theme(legend.position = "bottom")
  )
})

### 03.15.02 Build success - geom_icon_point -----------------------------------

testthat::test_that("Pass: basic plot builds successfully - geom_icon_point", {
  testthat::expect_no_error(
  ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, color = category)) +
    geom_icon_point() +
    scale_legend_icon(size = 10)
  )
})

testthat::test_that("Pass: complex plot builds successfully - geom_icon_point", {
  testthat::expect_no_error(
  ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, color = category)) +
    geom_icon_point(size = 2) +
    ggplot2::theme_minimal(base_size = 14) +
    scale_legend_icon(size = 12, unit = "mm", spacing = 0.2) +
    ggplot2::labs(title = "Scatter Plot with Icons") +
    ggplot2::theme(legend.position = "right")
  )
})

# ******************************************************************************
## 03.16 Pass checks: relative units (no size warnings) ------------------------
# ******************************************************************************

### 03.16.01 Relative units - geom_pop -----------------------------------------

testthat::test_that("Pass: cm unit no size warning - geom_pop", {
  testthat::expect_no_warning(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = 1, unit = "cm") +
      ggplot2::theme(legend.position = "right")
  )
})

testthat::test_that("Pass: lines unit no size warning - geom_pop", {
  testthat::expect_no_warning(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = 2, unit = "lines") +
      ggplot2::theme(legend.position = "right")
  )
})

### 03.16.02 Relative units - geom_icon_point ----------------------------------

testthat::test_that("Pass: cm unit no size warning - geom_icon_point", {
  testthat::expect_no_warning(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, color = category)) +
      geom_icon_point() +
      scale_legend_icon(size = 1, unit = "cm")
  )
})

testthat::test_that("Pass: char unit no size warning - geom_icon_point", {
  testthat::expect_no_warning(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, color = category)) +
      geom_icon_point() +
      scale_legend_icon(size = 1, unit = "char")
  )
})

# ******************************************************************************
## 03.17 Pass checks: legend key styling ---------------------------------------
# ******************************************************************************

### 03.17.01 Legend key styling - geom_pop -------------------------------------


# ******************************************************************************
# 04 End of tests --------------------------------------------------------------
# ******************************************************************************