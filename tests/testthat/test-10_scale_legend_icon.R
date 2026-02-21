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
# 03 Errors: size parameter (hard stops) ---------------------------------------
# ******************************************************************************

## 03.01 geom_pop --------------------------------------------------------------

### 03.01.01 Non-numeric size --------------------------------------------------

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

### 03.01.02 Vector size -------------------------------------------------------

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

### 03.01.03 Non-positive size -------------------------------------------------

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

### 03.01.04 Non-finite size ---------------------------------------------------

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

## 03.02 geom_icon_point -------------------------------------------------------

### 03.02.01 Non-numeric size --------------------------------------------------

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

### 03.02.02 Non-positive size -------------------------------------------------

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

### 03.02.03 Non-finite size ---------------------------------------------------

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
# 04 Errors: unit parameter (hard stops) ---------------------------------------
# ******************************************************************************

## 04.01 geom_pop --------------------------------------------------------------

### 04.01.01 Non-character unit ------------------------------------------------

testthat::test_that("Error: numeric unit - geom_pop", {
  testthat::expect_error(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = 10, unit = 123)
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

### 04.01.02 Banned npc unit ---------------------------------------------------

testthat::test_that("Error: npc unit banned - geom_pop", {
  testthat::expect_error(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = 10, unit = "npc")
  )
})

### 04.01.03 Vector unit -------------------------------------------------------

testthat::test_that("Error: vector unit - geom_pop", {
  testthat::expect_error(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = 10, unit = c("mm", "cm"))
  )
})

## 04.02 geom_icon_point -------------------------------------------------------

### 04.02.01 Non-character unit ------------------------------------------------

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

### 04.02.02 Banned npc unit ---------------------------------------------------

testthat::test_that("Error: npc unit banned - geom_icon_point", {
  testthat::expect_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point() +
      scale_legend_icon(size = 10, unit = "npc")
  )
})

### 04.02.03 Vector unit -------------------------------------------------------

testthat::test_that("Error: vector unit - geom_icon_point", {
  testthat::expect_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point() +
      scale_legend_icon(size = 10, unit = c("mm", "cm", "inches"))
  )
})

# ******************************************************************************
# 05 Warnings: size too large (> 25mm → 50mm actual) ---------------------------
# ******************************************************************************

## 05.01 geom_pop --------------------------------------------------------------

### 05.01.01 Large mm ----------------------------------------------------------

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

### 05.01.02 Large cm ----------------------------------------------------------

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

### 05.01.03 Large inches ------------------------------------------------------

testthat::test_that("Warning: size > 1 inch - geom_pop", {
  testthat::expect_warning(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = 1.2, unit = "inches") +
      ggplot2::theme(legend.position = "right")
  )
})

## 05.02 geom_icon_point -------------------------------------------------------

### 05.02.01 Large mm ----------------------------------------------------------

testthat::test_that("Warning: size > 25mm - geom_icon_point", {
  testthat::expect_warning(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point() +
      scale_legend_icon(size = 30, unit = "mm")
  )
})

# ******************************************************************************
# 06 Warnings: size too small (< 1.5mm → 3mm actual) ---------------------------
# ******************************************************************************

## 06.01 geom_pop --------------------------------------------------------------

### 06.01.01 Small mm ----------------------------------------------------------

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

### 06.01.02 Small cm ----------------------------------------------------------

testthat::test_that("Warning: size < 0.15cm - geom_pop", {
  testthat::expect_warning(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = 0.1, unit = "cm") +
      ggplot2::theme(legend.position = "right")
  )
})

## 06.02 geom_icon_point -------------------------------------------------------

### 06.02.01 Small mm ----------------------------------------------------------

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

### 06.02.02 Small inches ------------------------------------------------------

testthat::test_that("Warning: size < 0.06 inches - geom_icon_point", {
  testthat::expect_warning(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, color = category)) +
      geom_icon_point() +
      scale_legend_icon(size = 0.05, unit = "inches")
  )
})

# ******************************************************************************
# 07 Warnings: invalid spacing (soft) ------------------------------------------
# ******************************************************************************

## 07.01 geom_pop --------------------------------------------------------------

### 07.01.01 Negative spacing --------------------------------------------------

testthat::test_that("Warning: negative spacing - geom_pop", {
  testthat::expect_warning(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = 10, spacing = -0.5) +
      ggplot2::theme(legend.position = "right")
  )
})

### 07.01.02 Non-numeric spacing -----------------------------------------------

testthat::test_that("Warning: non-numeric spacing - geom_pop", {
  testthat::expect_warning(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = 10, spacing = "large") +
      ggplot2::theme(legend.position = "right")
  )
})

### 07.01.03 Vector spacing ----------------------------------------------------

testthat::test_that("Warning: vector spacing - geom_pop", {
  testthat::expect_warning(
    ggplot2::ggplot(df_pop, ggplot2::aes(icon = icon, color = type)) +
      geom_pop(size = 1) +
      ggplot2::theme_void() +
      scale_legend_icon(size = 10, spacing = c(0.2, 0.3)) +
      ggplot2::theme(legend.position = "right")
  )
})

## 07.02 geom_icon_point -------------------------------------------------------

### 07.02.01 Negative spacing --------------------------------------------------

testthat::test_that("Warning: negative spacing - geom_icon_point", {
  testthat::expect_warning(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, color = category)) +
      geom_icon_point() +
      scale_legend_icon(size = 10, spacing = -1)
  )
})

### 07.02.02 Logical spacing ---------------------------------------------------

testthat::test_that("Warning: logical spacing - geom_icon_point", {
  testthat::expect_warning(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, color = category)) +
      geom_icon_point() +
      scale_legend_icon(size = 10, spacing = TRUE)
  )
})

# ******************************************************************************
# 08 Pass checks: valid sizes (no warnings) ------------------------------------
# ******************************************************************************

## 08.01 geom_pop --------------------------------------------------------------

### 08.01.01 Valid mm sizes ----------------------------------------------------

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

## 08.02 geom_icon_point -------------------------------------------------------

### 08.02.01 Valid mm sizes ----------------------------------------------------

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
# 09 Pass checks: different units ----------------------------------------------
# ******************************************************************************

## 09.01 geom_pop --------------------------------------------------------------

### 09.01.01 Unit variations ---------------------------------------------------

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

## 09.02 geom_icon_point -------------------------------------------------------

### 09.02.01 Unit variations ---------------------------------------------------

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
# 10 Pass checks: spacing values -----------------------------------------------
# ******************************************************************************

## 10.01 geom_pop --------------------------------------------------------------

### 10.01.01 Spacing variations ------------------------------------------------

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

## 10.02 geom_icon_point -------------------------------------------------------

### 10.02.01 Spacing variations ------------------------------------------------

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
# 11 Pass checks: theme compatibility ------------------------------------------
# ******************************************************************************

## 11.01 geom_pop --------------------------------------------------------------

### 11.01.01 Theme variations --------------------------------------------------

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

## 11.02 geom_icon_point -------------------------------------------------------

### 11.02.01 Theme variations --------------------------------------------------

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
# 12 Pass checks: default values -----------------------------------------------
# ******************************************************************************

## 12.01 geom_pop --------------------------------------------------------------

### 12.01.01 Default parameters ------------------------------------------------

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

## 12.02 geom_icon_point -------------------------------------------------------

### 12.02.01 Default parameters ------------------------------------------------

testthat::test_that("Pass: all defaults - geom_icon_point", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, color = category)) +
      geom_icon_point() +
      scale_legend_icon()
  )
})

# ******************************************************************************
# 13 Pass checks: boundary values ----------------------------------------------
# ******************************************************************************

## 13.01 geom_pop --------------------------------------------------------------

### 13.01.01 Threshold boundaries ----------------------------------------------

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

## 13.02 geom_icon_point -------------------------------------------------------

### 13.02.01 Threshold boundaries ----------------------------------------------

testthat::test_that("Pass: at 25mm threshold no warning - geom_icon_point", {
  testthat::expect_no_warning(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, color = category)) +
      geom_icon_point() +
      scale_legend_icon(size = 25, unit = "mm")
  )
})

testthat::test_that("Pass: at 1.5mm threshold no warning - geom_icon_point", {
  testthat::expect_no_warning(
    ggplot2::ggplot(df_scatter, ggplot2::aes(
      x = x, y = y, icon = icon,
      color = category
    )) +
      geom_icon_point() +
      scale_legend_icon(size = 1.5, unit = "mm")
  )
})

# ******************************************************************************
# 14 Pass checks: build success ------------------------------------------------
# ******************************************************************************

## 14.01 geom_pop --------------------------------------------------------------

### 14.01.01 Plot builds -------------------------------------------------------

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

## 14.02 geom_icon_point -------------------------------------------------------

### 14.02.01 Plot builds -------------------------------------------------------

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
# 15 Pass checks: relative units (no size warnings) ----------------------------
# ******************************************************************************

## 15.01 geom_pop --------------------------------------------------------------

### 15.01.01 Relative unit types -----------------------------------------------

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

## 15.02 geom_icon_point -------------------------------------------------------

### 15.02.01 Relative unit types -----------------------------------------------

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
# 16 End of tests --------------------------------------------------------------
# ******************************************************************************
