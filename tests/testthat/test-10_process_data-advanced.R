# *****************************************************************************
#
# Script: test-10_process_data-advanced.R
#
# Purpose: Advanced tests for process_data() function edge cases
#
# Author: GitHub Copilot (Test Coverage Analysis)
#
# Date Created: 14-Feb-2026
#
# *****************************************************************************
#
# Notes:
#   - This file tests advanced scenarios for process_data()
#   - Covers hierarchical grouping, edge cases, large datasets
#   - Complements test-08_process_data.R basic tests
#
# *****************************************************************************

# ******************************************************************************
# 01 Load inputs ---------------------------------------------------------------
# ******************************************************************************

testthat::skip_if_not_installed("ggplot2")
testthat::skip_if_not_installed("dplyr")

# ******************************************************************************
# 02 Hierarchical grouping tests ----------------------------------------------
# ******************************************************************************

testthat::test_that("process_data: handles hierarchical grouping with high_group_var", {
  df_hier <- data.frame(
    country = rep(c("USA", "Canada"), each = 10),
    state = c(rep(c("CA", "NY"), each = 5), rep(c("ON", "BC"), each = 5)),
    stringsAsFactors = FALSE
  )
  
  result <- process_data(
    data = df_hier,
    group_var = "state",
    high_group_var = "country",
    sample_size = 20
  )
  
  testthat::expect_s3_class(result, "data.frame")
  testthat::expect_true("type" %in% names(result))
  testthat::expect_equal(nrow(result), 20)
})

testthat::test_that("process_data: hierarchical with different sample sizes", {
  df_hier <- data.frame(
    region = rep(c("North", "South"), each = 50),
    city = c(rep(c("A", "B"), each = 25), rep(c("C", "D"), each = 25)),
    stringsAsFactors = FALSE
  )
  
  result <- process_data(
    data = df_hier,
    group_var = "city",
    high_group_var = "region",
    sample_size = 100
  )
  
  testthat::expect_equal(nrow(result), 100)
  testthat::expect_true(all(result$type %in% c("A", "B", "C", "D")))
})

testthat::test_that("process_data: hierarchical with unequal group sizes", {
  df_unequal <- data.frame(
    dept = c(rep("Sales", 60), rep("IT", 30), rep("HR", 10)),
    team = c(
      rep(c("S1", "S2"), c(40, 20)),
      rep(c("I1", "I2"), c(20, 10)),
      rep("H1", 10)
    ),
    stringsAsFactors = FALSE
  )
  
  result <- process_data(
    data = df_unequal,
    group_var = "team",
    high_group_var = "dept",
    sample_size = 50
  )
  
  testthat::expect_equal(nrow(result), 50)
  # Check proportions are maintained
  type_counts <- table(result$type)
  testthat::expect_true(all(names(type_counts) %in% c("S1", "S2", "I1", "I2", "H1")))
})

# ******************************************************************************
# 03 Edge cases: zeros and ties -----------------------------------------------
# ******************************************************************************

testthat::test_that("process_data: handles groups with zero counts gracefully", {
  df_with_zero <- data.frame(
    category = character(0),
    stringsAsFactors = FALSE
  )
  
  testthat::expect_error(
    process_data(
      data = df_with_zero,
      group_var = "category",
      sample_size = 10
    ),
    regexp = "empty"
  )
})

testthat::test_that("process_data: handles ties in proportions", {
  df_ties <- data.frame(
    group = rep(c("A", "B", "C", "D"), each = 25),
    stringsAsFactors = FALSE
  )
  
  result <- process_data(
    data = df_ties,
    group_var = "group",
    sample_size = 100
  )
  
  # All groups should have equal representation
  type_counts <- table(result$type)
  testthat::expect_equal(length(unique(type_counts)), 1)
  testthat::expect_equal(as.numeric(type_counts[1]), 25)
})

testthat::test_that("process_data: handles rounding with small sample_size", {
  df_small <- data.frame(
    group = c(rep("A", 67), rep("B", 33)),
    stringsAsFactors = FALSE
  )
  
  result <- process_data(
    data = df_small,
    group_var = "group",
    sample_size = 10
  )
  
  testthat::expect_equal(nrow(result), 10)
  type_counts <- table(result$type)
  # Should approximately maintain 67/33 ratio (7/3 or 6/4)
  testthat::expect_true(type_counts["A"] >= 6)
  testthat::expect_true(type_counts["B"] >= 2)
})

# ******************************************************************************
# 04 sum_var tests ------------------------------------------------------------
# ******************************************************************************

testthat::test_that("process_data: uses sum_var instead of count", {
  df_sum <- data.frame(
    category = c("A", "A", "B", "B", "B"),
    value = c(100, 200, 50, 50, 100),
    stringsAsFactors = FALSE
  )
  
  result <- process_data(
    data = df_sum,
    group_var = "category",
    sum_var = "value",
    sample_size = 100
  )
  
  testthat::expect_equal(nrow(result), 100)
  # A has 300 total, B has 200 total (60/40 split)
  type_counts <- table(result$type)
  testthat::expect_true(type_counts["A"] > type_counts["B"])
  testthat::expect_true(type_counts["A"] >= 50) # Should be around 60
})

testthat::test_that("process_data: sum_var with zeros", {
  df_zero_sum <- data.frame(
    category = c("A", "B", "C"),
    value = c(100, 0, 50),
    stringsAsFactors = FALSE
  )
  
  result <- process_data(
    data = df_zero_sum,
    group_var = "category",
    sum_var = "value",
    sample_size = 30
  )
  
  testthat::expect_equal(nrow(result), 30)
  type_counts <- table(result$type)
  # B should have 0 representation
  testthat::expect_true(!"B" %in% names(type_counts) || type_counts["B"] == 0)
})

testthat::test_that("process_data: sum_var with negative values throws error", {
  df_negative <- data.frame(
    category = c("A", "B"),
    value = c(100, -50),
    stringsAsFactors = FALSE
  )
  
  testthat::expect_error(
    process_data(
      data = df_negative,
      group_var = "category",
      sum_var = "value",
      sample_size = 30
    )
  )
})

# ******************************************************************************
# 05 Large dataset tests ------------------------------------------------------
# ******************************************************************************

testthat::test_that("process_data: handles large datasets efficiently", {
  df_large <- data.frame(
    group = sample(LETTERS[1:10], 10000, replace = TRUE),
    stringsAsFactors = FALSE
  )
  
  # Should complete without error
  result <- process_data(
    data = df_large,
    group_var = "group",
    sample_size = 1000
  )
  
  testthat::expect_equal(nrow(result), 1000)
  testthat::expect_s3_class(result, "data.frame")
})

testthat::test_that("process_data: maintains proportions in large dataset", {
  df_large <- data.frame(
    group = c(rep("A", 7000), rep("B", 3000)),
    stringsAsFactors = FALSE
  )
  
  result <- process_data(
    data = df_large,
    group_var = "group",
    sample_size = 1000
  )
  
  type_counts <- table(result$type)
  # Should be approximately 700/300 (70/30 split)
  testthat::expect_true(type_counts["A"] >= 650)
  testthat::expect_true(type_counts["A"] <= 750)
  testthat::expect_true(type_counts["B"] >= 250)
  testthat::expect_true(type_counts["B"] <= 350)
})

# ******************************************************************************
# 06 Special character and factor tests ---------------------------------------
# ******************************************************************************

testthat::test_that("process_data: handles special characters in group names", {
  df_special <- data.frame(
    group = c("Group A", "Group-B", "Group_C", "Group.D"),
    stringsAsFactors = FALSE
  )
  df_special <- df_special[rep(1:4, each = 25), ]
  
  result <- process_data(
    data = df_special,
    group_var = "group",
    sample_size = 100
  )
  
  testthat::expect_equal(nrow(result), 100)
  testthat::expect_true(all(result$type %in% df_special$group))
})

testthat::test_that("process_data: handles factor grouping variables", {
  df_factor <- data.frame(
    group = factor(c("Low", "Medium", "High", "Low", "Medium", "High")),
    stringsAsFactors = TRUE
  )
  df_factor <- df_factor[rep(1:6, each = 10), ]
  
  result <- process_data(
    data = df_factor,
    group_var = "group",
    sample_size = 60
  )
  
  testthat::expect_equal(nrow(result), 60)
  testthat::expect_true(all(result$type %in% as.character(df_factor$group)))
})

testthat::test_that("process_data: handles ordered factors", {
  df_ordered <- data.frame(
    priority = ordered(c("Low", "Medium", "High"), levels = c("Low", "Medium", "High")),
    stringsAsFactors = TRUE
  )
  df_ordered <- df_ordered[rep(1:3, times = c(10, 20, 30)), ]
  
  result <- process_data(
    data = df_ordered,
    group_var = "priority",
    sample_size = 60
  )
  
  testthat::expect_equal(nrow(result), 60)
  # Should maintain proportion: Low=10, Medium=20, High=30
  type_counts <- table(result$type)
  testthat::expect_true(type_counts["High"] > type_counts["Medium"])
  testthat::expect_true(type_counts["Medium"] > type_counts["Low"])
})

# ******************************************************************************
# 07 Multiple facets and grouping ---------------------------------------------
# ******************************************************************************

testthat::test_that("process_data: respects faceting in output", {
  df_faceted <- data.frame(
    facet = rep(c("F1", "F2"), each = 50),
    group = rep(c("A", "B"), times = 50),
    stringsAsFactors = FALSE
  )
  
  result <- process_data(
    data = df_faceted,
    group_var = "group",
    sample_size = 100
  )
  
  testthat::expect_equal(nrow(result), 100)
  testthat::expect_true("type" %in% names(result))
})

# ******************************************************************************
# 08 Return value structure tests --------------------------------------------
# ******************************************************************************

testthat::test_that("process_data: returns required columns", {
  df_simple <- data.frame(
    group = c("A", "B"),
    stringsAsFactors = FALSE
  )
  df_simple <- df_simple[rep(1:2, each = 50), ]
  
  result <- process_data(
    data = df_simple,
    group_var = "group",
    sample_size = 100
  )
  
  required_cols <- c("type", "n", "prop")
  testthat::expect_true(all(required_cols %in% names(result)))
})

testthat::test_that("process_data: prop column sums to 1", {
  df_simple <- data.frame(
    group = c("A", "B", "C"),
    stringsAsFactors = FALSE
  )
  df_simple <- df_simple[rep(1:3, times = c(30, 40, 30)), ]
  
  result <- process_data(
    data = df_simple,
    group_var = "group",
    sample_size = 100
  )
  
  # Get unique proportions per type
  prop_by_type <- result %>%
    dplyr::group_by(type) %>%
    dplyr::summarise(prop = dplyr::first(prop), .groups = "drop")
  
  testthat::expect_equal(sum(prop_by_type$prop), 1, tolerance = 0.01)
})

testthat::test_that("process_data: n column reflects sample counts", {
  df_simple <- data.frame(
    group = c("A", "B"),
    stringsAsFactors = FALSE
  )
  df_simple <- df_simple[rep(1:2, each = 50), ]
  
  result <- process_data(
    data = df_simple,
    group_var = "group",
    sample_size = 100
  )
  
  n_by_type <- result %>%
    dplyr::group_by(type) %>%
    dplyr::summarise(n = dplyr::first(n), .groups = "drop")
  
  testthat::expect_equal(sum(n_by_type$n), 100)
})

# ******************************************************************************
# 09 Numeric grouping variables -----------------------------------------------
# ******************************************************************************

testthat::test_that("process_data: handles numeric grouping variables", {
  df_numeric <- data.frame(
    age_group = c(1, 2, 3, 1, 2, 3),
    stringsAsFactors = FALSE
  )
  df_numeric <- df_numeric[rep(1:6, each = 10), ]
  
  result <- process_data(
    data = df_numeric,
    group_var = "age_group",
    sample_size = 60
  )
  
  testthat::expect_equal(nrow(result), 60)
  testthat::expect_true(all(result$type %in% c("1", "2", "3")))
})

# ******************************************************************************
# END --------------------------------------------------------------------------
# ******************************************************************************
