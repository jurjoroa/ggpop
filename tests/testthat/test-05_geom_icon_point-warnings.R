# *****************************************************************************
#
# Script: test-05_geom_icon_point-warnings.R
#
# Purpose: Test warnings produced by geom_icon_point().
#
# Author: Jorge Roa
#
# Email: jorgeroa@stanford.edu
#
# Date Created: 26-Jan-2026
#
# *****************************************************************************
#
# Notes:
#   - This file tests ONLY warnings (non-fatal behavior).
#   - We avoid matching warning text to keep tests robust.
#   - We test multiple usage patterns (data in ggplot() vs geom_icon_point())
#
# *****************************************************************************

# ******************************************************************************
# 01 Load inputs ---------------------------------------------------------------
# ******************************************************************************

testthat::skip_if_not_installed("ggplot2")
testthat::skip_if_not_installed("dplyr")
testthat::skip_if_not_installed("ggimage")
testthat::skip_if_not_installed("fontawesome")

# ******************************************************************************
## 01.01 Test dataframes -------------------------------------------------------
# ******************************************************************************

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

# Helpers (only where needed)
.build_plot <- function(p) ggplot2::ggplot_build(p)

# ******************************************************************************
# 02 Start tests ---------------------------------------------------------------
# ******************************************************************************

# ******************************************************************************
# 03 geom_icon_point -----------------------------------------------------------
# ******************************************************************************

# ******************************************************************************
## 03.01 Warnings: parameter conflicts -----------------------------------------
# ******************************************************************************

### 03.01.01 size in aes() overrides geom parameter (pattern 1: data in ggplot) ---

testthat::test_that("Warning: size in aes() overrides geom param (ggplot pattern)", {
  testthat::expect_warning(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, color = category, size =point_size)) +
      geom_icon_point(size=10, dpi = 100)
  )
})

### 03.01.02 size in aes() overrides geom parameter (pattern 2: data in geom) ---

testthat::test_that("Warning: size in aes() overrides geom param (geom pattern)", {
  testthat::expect_warning(
    ggplot2::ggplot() +
      geom_icon_point(
        data = df_scatter,
        ggplot2::aes(x = x, y = y, icon = icon, size = point_size, color = category),
        size = 10,
        dpi = 100
      )
  )
})

### 03.01.03 size in layer aes() overrides geom parameter (pattern 3: mixed) ---

testthat::test_that("Warning: size in layer aes() overrides geom param (mixed pattern)", {
  testthat::expect_warning(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y)) +
      geom_icon_point(
        ggplot2::aes(icon = icon, size = point_size, color = category),
        size = 10,
        dpi = 100
      )
  )
})

# ******************************************************************************
## 03.02 Warnings: dpi values --------------------------------------------------
# ******************************************************************************

### 03.02.01 dpi very high (pattern 1: data in ggplot) -------------------------

testthat::test_that("Warning: dpi very high (ggplot pattern)", {
  testthat::expect_warning(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, color = category)) +
      geom_icon_point(dpi = 800)
  )
})

### 03.02.02 dpi very high (pattern 2: data in geom) ---------------------------

testthat::test_that("Warning: dpi very high (geom pattern)", {
  testthat::expect_warning(
    ggplot2::ggplot() +
      geom_icon_point(
        data = df_scatter,
        ggplot2::aes(x = x, y = y, icon = icon, color = category),
        dpi = 800
      )
  )
})


# ******************************************************************************
## 03.03 Warnings: size parameters ---------------------------------------------
# ******************************************************************************

### 03.03.01 size very small (ggplot pattern) ----------------------------------

testthat::test_that("Edge case: size triggers warning (ggplot pattern)", {
  testthat::expect_warning(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point(size = 0.4, color = "blue")
  )
})

### 03.03.02 size very small (geom pattern) ------------------------------------

testthat::test_that("Edge case: size triggers warning (geom pattern)", {
  testthat::expect_warning(
    ggplot2::ggplot() +
      geom_icon_point(
        data = df_scatter,
        ggplot2::aes(x = x, y = y, icon = icon, color = category),
        size = 0.4
      )
  )
})

### 03.03.03 size very large (ggplot pattern) ----------------------------------

testthat::test_that("Edge case: size = 16 triggers warning (ggplot pattern)", {
  testthat::expect_warning(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, color = category)) +
      geom_icon_point(size = 16)
  )
})

### 03.03.05 size very large (geom pattern) ------------------------------------

testthat::test_that("Edge case: size = 16 triggers warning (geom pattern)", {
  testthat::expect_warning(
    ggplot2::ggplot() +
      geom_icon_point(
        data = df_scatter,
        ggplot2::aes(x = x, y = y, icon = icon, color = category),
        size = 16
      )
  )
})


# ******************************************************************************
## 03.04 Warnings: alpha parameters ---------------------------------------------
# ******************************************************************************

### 03.04.01 alpha very small (ggplot pattern) ---------------------------------

testthat::test_that("Edge case: alpha = 0.05 triggers warning (ggplot pattern)", {
  testthat::expect_warning(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point(alpha = 0.05, color = "blue"),
    regexp = "Very low `alpha` value"
  )
})

### 03.04.02 alpha very small (geom pattern) -----------------------------------

testthat::test_that("Edge case: alpha = 0.05 triggers warning (geom pattern)", {
  testthat::expect_warning(
    ggplot2::ggplot() +
      geom_icon_point(
        data = df_scatter,
        ggplot2::aes(x = x, y = y, icon = icon, color = category),
        alpha = 0.05
      ),
    regexp = "Very low `alpha` value"
  )
})

### 03.04.03 alpha boundaries (no warnings) ------------------------------------

testthat::test_that("Edge case: alpha = 0.09 triggers warning (mixed)", {
  testthat::expect_warning(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y)) +
      geom_icon_point(
        ggplot2::aes(icon = icon, color = category),
        alpha = 0.09
      ),
    regexp = "Very low `alpha` value"
  )
})


### 03.04.04 alpha in both aes() and parameter triggers warning ---------------

testthat::test_that("Warning: alpha in both aes() and parameter", {
  testthat::expect_warning(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, alpha = point_size)) +
      geom_icon_point(alpha = 0.5, color = "blue")
  )
})


# ******************************************************************************
## 03.05 Warnings: icon-related ------------------------------------------------
# ******************************************************************************

### 03.05.01 multiple icons per legend group (ggplot pattern) ------------------

testthat::test_that("Warning: multiple icons per color group (ggplot pattern)", {
  df_multi_icon <- data.frame(
    x = c(1, 2, 3, 4),
    y = c(2, 4, 3, 5),
    category = c("A", "A", "B", "B"),
    icon = c("circle", "star", "heart", "square"),
    stringsAsFactors = FALSE
  )
  
  testthat::expect_warning(
    ggplot2::ggplot(df_multi_icon, ggplot2::aes(x = x, y = y, icon = icon, color = category)) +
      geom_icon_point(legend_icons = TRUE, dpi = 60)
  )
})

### 03.05.02 multiple icons per legend group (geom pattern) --------------------

testthat::test_that("Warning: multiple icons per color group (geom pattern)", {
  df_multi_icon <- data.frame(
    x = c(1, 2, 3, 4),
    y = c(2, 4, 3, 5),
    category = c("A", "A", "B", "B"),
    icon = c("circle", "star", "heart", "square"),
    stringsAsFactors = FALSE
  )
  
  testthat::expect_warning(
    ggplot2::ggplot() +
      geom_icon_point(
        data = df_multi_icon,
        ggplot2::aes(x = x, y = y, icon = icon, color = category),
        legend_icons = TRUE
      )
  )
  
  testthat::expect_warning(
    ggplot2::ggplot(
      data = df_multi_icon,
      ggplot2::aes(
        x = x, y = y, icon = icon,
        color = category
      )
    ) +
      geom_icon_point(legend_icons = TRUE)
  )
})

# ******************************************************************************
## 03.06 Warnings: inherited aesthetics ----------------------------------------
# ******************************************************************************

### 03.06.01 Size inherited + specified (classic ggplot pattern) ---------------

testthat::test_that("Warning: size in ggplot() aes and geom param", {
  testthat::expect_warning(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, size = point_size)) +
      geom_icon_point(
        ggplot2::aes(icon = icon, color = category),
        size = 5,
        dpi = 60
      )
  )
})


# ******************************************************************************
## 03.06 Warnings: multiple layers ---------------------------------------------
# ******************************************************************************

### 03.06.01 Multiple geom_icon_point layers with different sizes --------------

testthat::test_that("Warning in one layer doesn't affect others", {
  df1 <- df_scatter[1:3, ]
  df2 <- df_scatter[4:5, ]
  
  testthat::expect_warning(
    ggplot2::ggplot() +
      geom_icon_point(
        data = df1,
        ggplot2::aes(x = x, y = y, icon = icon),
        size = 0.1 # Should warn
      ) +
      geom_icon_point(
        data = df2,
        ggplot2::aes(x = x, y = y, icon = icon),
        size = 3, # Should not warn
        color = "red"
      )
  )
})

# ******************************************************************************
## 03.07 Smoke: warnings should still allow build ------------------------------
# ******************************************************************************

### 03.07.01 build succeeds with size warning (ggplot pattern) -----------------

testthat::test_that("Build: plot builds with size warning (ggplot pattern)", {
  testthat::expect_warning(
    p <- ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, size = point_size)) +
      geom_icon_point(size = 10, dpi = 60)
  )
  
  testthat::expect_s3_class(p, "ggplot")
})

### 03.07.02 build succeeds with dpi warning (geom pattern) --------------------

testthat::test_that("Build: plot builds with high dpi warning (geom pattern)", {
  testthat::expect_warning(
    p <- ggplot2::ggplot() +
      geom_icon_point(
        data = df_scatter,
        ggplot2::aes(x = x, y = y, icon = icon, color = category),
        dpi = 800
      )
  )
  
  testthat::expect_s3_class(p, "ggplot")
})

### 03.07.03 build succeeds with multiple warnings (mixed pattern) -------------

testthat::test_that("Build: plot builds with multiple warnings", {
  warns <- testthat::capture_warnings(
    p <- ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y)) +
      geom_icon_point(
        ggplot2::aes(icon = icon, size = point_size, color = category),
        size = 0.1, # Size warning
        dpi = 800 # DPI warning
      )
  )
  
  # Should have 3 warnings: size conflict + small size + high DPI
  testthat::expect_true(length(warns) >= 2)
  
  # Verify the plot object was created
  testthat::expect_s3_class(p, "ggplot")
})
# ******************************************************************************
## 03.08 Warnings: data validation ---------------------------------------------
# ******************************************************************************

### 03.08.01 Warning when x contains NA values (ggplot pattern) ----------------

testthat::test_that("Warning: NA values in x coordinate (ggplot pattern)", {
  df_na <- df_scatter
  df_na$x[2] <- NA
  
  testthat::expect_warning(
    {
      pdf(NULL)
      print(
        ggplot2::ggplot(df_na, ggplot2::aes(x = x, y = y, icon = icon)) +
          geom_icon_point(dpi = 60)
      )
      dev.off()
    },
    regexp = "Removed.*missing values"
  )
})


### 03.08.02 Warning when y contains NA values (geom pattern) ------------------

testthat::test_that("Warning: NA values in y coordinate (geom pattern)", {
  df_na <- df_scatter
  df_na$y[3] <- NA
  
  testthat::expect_warning(
    {
      tmp <- tempfile(fileext = ".png")
      png(tmp)
      print(
        ggplot2::ggplot() +
          geom_icon_point(
            data = df_na,
            ggplot2::aes(x = x, y = y, icon = icon),
            dpi = 60
          )
      )
      dev.off()
      unlink(tmp)
    },
    regexp = "Removed.*missing values"
  )
})

### 03.08.03 Warning when both x and y contain NA values (mixed pattern) -------

testthat::test_that("Warning: NA values in both coordinates (mixed pattern)", {
  df_na <- df_scatter
  df_na$x[2] <- NA
  df_na$y[4] <- NA
  
  testthat::expect_warning(
    {
      tmp <- tempfile(fileext = ".png")
      png(tmp)
      print(
        ggplot2::ggplot(df_na, ggplot2::aes(x = x, y = y)) +
          geom_icon_point(
            ggplot2::aes(icon = icon, color = category),
            dpi = 60
          )
      )
      dev.off()
      unlink(tmp)
    },
    regexp = "Removed.*missing values"
  )
})

### 03.08.04 Inconsistent icons within same legend group (ggplot pattern) ------

testthat::test_that("Warning: inconsistent icons per group (ggplot pattern)", {
  df_inconsistent <- data.frame(
    x = 1:6,
    y = 1:6,
    group = c("A", "A", "A", "B", "B", "B"),
    icon = c("circle", "star", "circle", "heart", "heart", "square"),
    stringsAsFactors = FALSE
  )
  
  testthat::expect_warning(
    ggplot2::ggplot(df_inconsistent, ggplot2::aes(x = x, y = y, icon = icon, color = group)) +
      geom_icon_point(legend_icons = TRUE, dpi = 60)
  )
})

### 03.08.05 Inconsistent icons within same legend group (geom pattern) --------

testthat::test_that("Warning: inconsistent icons per group (geom pattern)", {
  df_inconsistent <- data.frame(
    x = 1:6,
    y = 1:6,
    group = c("A", "A", "A", "B", "B", "B"),
    icon = c("circle", "star", "circle", "heart", "heart", "square"),
    stringsAsFactors = FALSE
  )
  
  testthat::expect_warning(
    ggplot2::ggplot() +
      geom_icon_point(
        data = df_inconsistent,
        ggplot2::aes(x = x, y = y, icon = icon, color = group),
        legend_icons = TRUE,
        dpi = 60
      )
  )
})


# ******************************************************************************
## 03.09 Pattern comparisons: same warning, different syntax -------------------
# ******************************************************************************

### 03.09.01 Size conflict: all three patterns ---------------------------------

testthat::test_that("Pattern comparison: size conflict (ggplot)", {
  testthat::expect_warning(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, size = point_size)) +
      geom_icon_point(size = 10)
  )
})

testthat::test_that("Pattern comparison: size conflict (geom)", {
  testthat::expect_warning(
    ggplot2::ggplot() +
      geom_icon_point(
        data = df_scatter,
        ggplot2::aes(x = x, y = y, icon = icon, size = point_size),
        size = 10
      )
  )
})

testthat::test_that("Pattern comparison: size conflict (mixed)", {
  testthat::expect_warning(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y)) +
      geom_icon_point(
        ggplot2::aes(icon = icon, size = point_size),
        size = 10
      )
  )
})

### 03.09.02 DPI high: all three patterns --------------------------------------

testthat::test_that("Pattern comparison: high dpi (ggplot)", {
  testthat::expect_warning(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point(dpi = 800)
  )
})

testthat::test_that("Pattern comparison: high dpi (geom)", {
  testthat::expect_warning(
    ggplot2::ggplot() +
      geom_icon_point(
        data = df_scatter,
        ggplot2::aes(x = x, y = y, icon = icon),
        dpi = 800
      )
  )
})

testthat::test_that("Pattern comparison: high dpi (mixed)", {
  testthat::expect_warning(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y)) +
      geom_icon_point(ggplot2::aes(icon = icon), dpi = 800)
  )
})

# ******************************************************************************
## 03.10 Warnings: stroke_width -----------------------------------------------
# ******************************************************************************

### 03.10.01 stroke_width very large (absolute) --------------------------------

testthat::test_that("Warning: very large stroke_width (ggplot pattern)", {
  testthat::expect_warning(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point(stroke_width = 40, dpi = 60)
  )
})

# ******************************************************************************
# END --------------------------------------------------------------------------
# ******************************************************************************