# *****************************************************************************
#
# Script: test-11_fa_icons.R
#
# Purpose: Unit tests for fa_icons() — errors, warnings, and pass checks
#
# Author: Jorge Roa
#
# Email: jorgeroa@stanford.edu
#
# Date Created: 27-Feb-2026
#
# *****************************************************************************
#
# Notes:
#   - Tests fa_icons() in fa-icons.R
#   - Organized into: Errors (hard stops), Warnings (soft), Pass Checks
#   - Uses query = "user" to limit icon set in classification tests (~30 icons
#     instead of 2000+) — keeps suite fast without losing coverage
#
# *****************************************************************************

# ******************************************************************************
# 01 Load inputs ---------------------------------------------------------------
# ******************************************************************************

testthat::skip_if_not_installed("fontawesome")
testthat::skip_if_not_installed("tibble")

# Category whose regex matches nothing — used for zero-result warning tests
.impossible_map <- list(impossible = "^ZZZZ_NEVER_MATCHES_9999$")

# ******************************************************************************
# 02 Start tests ---------------------------------------------------------------
# ******************************************************************************

# ******************************************************************************
# 03 Errors: input type checks -------------------------------------------------
# ******************************************************************************

## 03.01 query -----------------------------------------------------------------

testthat::test_that("Error: non-character query", {
  testthat::expect_error(fa_icons(query = 123))
})

testthat::test_that("Error: query length > 1", {
  testthat::expect_error(fa_icons(query = c("heart", "star")))
})

## 03.02 category --------------------------------------------------------------

testthat::test_that("Error: non-character category", {
  testthat::expect_error(fa_icons(category = TRUE))
})

## 03.03 logical scalar params (one test each) ---------------------------------

testthat::test_that("Error: invalid regex arg", {
  testthat::expect_error(fa_icons(regex = "TRUE"))
  testthat::expect_error(fa_icons(regex = NA))
})

testthat::test_that("Error: invalid classify arg", {
  testthat::expect_error(fa_icons(classify = "yes"))
  testthat::expect_error(fa_icons(classify = NA))
})

testthat::test_that("Error: invalid include_unclassified arg", {
  testthat::expect_error(fa_icons(include_unclassified = 1))
  testthat::expect_error(fa_icons(include_unclassified = NA))
})

testthat::test_that("Error: invalid primary_only arg", {
  testthat::expect_error(fa_icons(primary_only = "no"))
  testthat::expect_error(fa_icons(primary_only = NA))
})

testthat::test_that("Error: invalid as_vector arg", {
  testthat::expect_error(fa_icons(as_vector = 1))
  testthat::expect_error(fa_icons(as_vector = NA))
})

# ******************************************************************************
# 04 Errors: class_map structure -----------------------------------------------
# ******************************************************************************

testthat::test_that("Error: class_map not a list", {
  testthat::expect_error(fa_icons(class_map = "people"))
})

testthat::test_that("Error: class_map unnamed list", {
  testthat::expect_error(fa_icons(class_map = list("^heart", "^star")))
})

testthat::test_that("Error: class_map partially unnamed list", {
  testthat::expect_error(fa_icons(class_map = list(people = "^user", "^heart")))
})

# ******************************************************************************
# 05 Errors: unknown category --------------------------------------------------
# ******************************************************************************

testthat::test_that("Error: unknown category name", {
  testthat::expect_error(fa_icons(category = "not_a_real_category_xyz"))
})

testthat::test_that("Error: mix of valid and invalid categories", {
  testthat::expect_error(fa_icons(category = c("people_users", "fake_category")))
})

# ******************************************************************************
# 06 Errors: invalid regex pattern ---------------------------------------------
# ******************************************************************************

testthat::test_that("Error: malformed regex query", {
  testthat::expect_error(fa_icons(query = "[unclosed", regex = TRUE))
})

# ******************************************************************************
# 07 Warnings: contradictory arguments -----------------------------------------
# ******************************************************************************

testthat::test_that("Warning: classify FALSE + include_unclassified FALSE", {
  testthat::expect_warning(fa_icons(query = "user", classify = FALSE, include_unclassified = FALSE))
})

testthat::test_that("Warning: primary_only FALSE ignored when as_vector TRUE", {
  testthat::expect_warning(fa_icons(query = "user", as_vector = TRUE, primary_only = FALSE))
})

# ******************************************************************************
# 08 Warnings: zero results ----------------------------------------------------
# ******************************************************************************

testthat::test_that("Warning: no match with as_vector = TRUE", {
  testthat::expect_warning(fa_icons(query = "zzznonexistent999", as_vector = TRUE))
})

testthat::test_that("Warning: no match with classify = FALSE", {
  testthat::expect_warning(fa_icons(query = "zzznonexistent999", classify = FALSE))
})

testthat::test_that("Warning: category returns zero icons", {
  testthat::expect_warning(fa_icons(category = "impossible", class_map = .impossible_map))
})

testthat::test_that("Warning: query + category returns zero icons", {
  testthat::expect_warning(
    fa_icons(query = "heart", category = "impossible", class_map = .impossible_map)
  )
})

# ******************************************************************************
# 09 Pass checks: return types and column structure ----------------------------
# ******************************************************************************

testthat::test_that("Pass: returns tibble with correct columns", {
  result <- fa_icons(query = "user")
  testthat::expect_s3_class(result, "tbl_df")
  testthat::expect_true("icon" %in% names(result))
  testthat::expect_true("primary_class" %in% names(result))
  testthat::expect_false("all_classes" %in% names(result))
  testthat::expect_type(result$icon, "character")
  testthat::expect_type(result$primary_class, "character")
})

testthat::test_that("Pass: primary_only = FALSE adds all_classes list-column", {
  result <- fa_icons(query = "user", primary_only = FALSE)
  testthat::expect_true("all_classes" %in% names(result))
  testthat::expect_type(result$all_classes, "list")
})

testthat::test_that("Pass: as_vector returns sorted character vector", {
  result <- fa_icons(query = "user", as_vector = TRUE)
  testthat::expect_type(result, "character")
  testthat::expect_equal(result, sort(result))
})

testthat::test_that("Pass: classify = FALSE returns sorted character vector", {
  result <- fa_icons(query = "user", classify = FALSE)
  testthat::expect_type(result, "character")
  testthat::expect_equal(result, sort(result))
})

# ******************************************************************************
# 10 Pass checks: query and category filtering ---------------------------------
# ******************************************************************************

testthat::test_that("Pass: fixed-string query filters correctly", {
  result <- fa_icons(query = "heart")
  testthat::expect_true(nrow(result) > 0)
  testthat::expect_true(all(grepl("heart", result$icon, fixed = TRUE)))
})

testthat::test_that("Pass: regex query filters correctly", {
  result <- fa_icons(query = "^(star|heart)$", regex = TRUE)
  testthat::expect_true(nrow(result) > 0)
  testthat::expect_true(all(result$icon %in% c("star", "heart")))
})

testthat::test_that("Pass: category filter returns only matching icons", {
  result <- fa_icons(category = "people_users")
  testthat::expect_true(nrow(result) > 0)
  testthat::expect_true(all(result$primary_class == "people_users"))
})

testthat::test_that("Pass: as_vector result matches manual filter", {
  result   <- fa_icons(query = "heart", as_vector = TRUE)
  all_icons <- fontawesome::fa_metadata()$icon_names
  expected  <- sort(all_icons[grepl("heart", all_icons, fixed = TRUE)])
  testthat::expect_equal(result, expected)
})

# ******************************************************************************
# 11 Pass checks: flags --------------------------------------------------------
# ******************************************************************************

testthat::test_that("Pass: include_unclassified = FALSE drops NA rows", {
  result <- fa_icons(query = "user", include_unclassified = FALSE)
  testthat::expect_false(any(is.na(result$primary_class)))
})

testthat::test_that("Pass: include_unclassified = TRUE keeps NA rows", {
  result <- fa_icons(class_map = list(has_arrow = "^arrow"), include_unclassified = TRUE)
  testthat::expect_true(any(is.na(result$primary_class)))
})

testthat::test_that("Pass: custom class_map limits categories in output", {
  custom_map     <- list(has_arrow = "^arrow")
  result         <- fa_icons(query = "arrow", class_map = custom_map)
  unique_classes <- unique(result$primary_class[!is.na(result$primary_class)])
  testthat::expect_true(all(unique_classes %in% names(custom_map)))
})

# ******************************************************************************
# 12 Pass checks: clean calls (no spurious conditions) -------------------------
# ******************************************************************************

testthat::test_that("Pass: filtered call raises no error or warning", {
  testthat::expect_no_error(fa_icons(query = "user"))
  testthat::expect_no_warning(fa_icons(query = "user"))
})

testthat::test_that("Pass: classify TRUE + include_unclassified FALSE no warning", {
  testthat::expect_no_warning(
    fa_icons(query = "user", classify = TRUE, include_unclassified = FALSE)
  )
})

testthat::test_that("Pass: valid regex raises no error", {
  testthat::expect_no_error(fa_icons(query = "^user(-|$)", regex = TRUE))
})

# ******************************************************************************
# 13 End of tests --------------------------------------------------------------
# ******************************************************************************
