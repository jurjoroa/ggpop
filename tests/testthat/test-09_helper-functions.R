# *****************************************************************************
#
# Script: test-09_helper-functions.R
#
# Purpose: Test helper functions for geom_pop and geom_icon_point
#
# Author: GitHub Copilot (Test Coverage Analysis)
#
# Date Created: 14-Feb-2026
#
# *****************************************************************************
#
# Notes:
#   - This file tests helper functions that support both geoms
#   - Focuses on functions in geom_pop-helpers.R, geom-icon-point-helpers.R
#   - Tests internal logic that's not covered by integration tests
#
# *****************************************************************************

# ******************************************************************************
# 01 Load inputs ---------------------------------------------------------------
# ******************************************************************************

testthat::skip_if_not_installed("ggplot2")
testthat::skip_if_not_installed("dplyr")
testthat::skip_if_not_installed("rlang")

# ******************************************************************************
# 02 Test fixtures -------------------------------------------------------------
# ******************************************************************************

df_test <- data.frame(
  x = 1:5,
  y = 1:5,
  icon = c("circle", "star", "heart", "square", "triangle-exclamation"),
  category = c("A", "B", "A", "B", "C"),
  size_col = c(2, 3, 2, 4, 3),
  stringsAsFactors = FALSE
)

# ******************************************************************************
# 03 handle_size_aesthetic tests ----------------------------------------------
# ******************************************************************************

testthat::test_that("handle_size_aesthetic: uses parameter when no size in mapping", {
  combined_mapping <- list()
  mapping_list <- list()
  inherited_mapping_list <- list()
  
  result <- ggpop:::handle_size_aesthetic(
    data = df_test,
    combined_mapping = combined_mapping,
    mapping_list = mapping_list,
    inherited_mapping_list = inherited_mapping_list,
    size = 5
  )
  
  testthat::expect_true("icon_size" %in% names(result$data))
  testthat::expect_equal(result$data$icon_size[1], 5 * 0.03)
  testthat::expect_equal(length(result$mapping_list), 0)
})

testthat::test_that("handle_size_aesthetic: uses mapped size column", {
  combined_mapping <- list(size = rlang::sym("size_col"))
  mapping_list <- list(size = rlang::sym("size_col"))
  inherited_mapping_list <- list()
  
  result <- ggpop:::handle_size_aesthetic(
    data = df_test,
    combined_mapping = combined_mapping,
    mapping_list = mapping_list,
    inherited_mapping_list = inherited_mapping_list,
    size = 5
  )
  
  testthat::expect_true("icon_size" %in% names(result$data))
  testthat::expect_equal(result$data$icon_size[1], df_test$size_col[1] * 0.03)
  testthat::expect_null(result$mapping_list$size)
})

testthat::test_that("handle_size_aesthetic: inherits size from ggplot", {
  combined_mapping <- list(size = rlang::sym("size_col"))
  mapping_list <- list()
  inherited_mapping_list <- list(size = rlang::sym("size_col"))
  
  result <- ggpop:::handle_size_aesthetic(
    data = df_test,
    combined_mapping = combined_mapping,
    mapping_list = mapping_list,
    inherited_mapping_list = inherited_mapping_list,
    size = 5
  )
  
  testthat::expect_true("icon_size" %in% names(result$data))
  testthat::expect_equal(result$data$icon_size[2], df_test$size_col[2] * 0.03)
})

# ******************************************************************************
# 04 detect_legend_variable tests ---------------------------------------------
# ******************************************************************************

testthat::test_that("detect_legend_variable: detects colour aesthetic", {
  combined_mapping <- list(colour = rlang::sym("category"))
  
  legend_var <- ggpop:::detect_legend_variable(combined_mapping, df_test)
  
  testthat::expect_equal(legend_var, "category")
})

testthat::test_that("detect_legend_variable: detects color aesthetic (US spelling)", {
  combined_mapping <- list(color = rlang::sym("category"))
  
  legend_var <- ggpop:::detect_legend_variable(combined_mapping, df_test)
  
  testthat::expect_equal(legend_var, "category")
})

testthat::test_that("detect_legend_variable: detects group aesthetic", {
  combined_mapping <- list(group = rlang::sym("category"))
  
  legend_var <- ggpop:::detect_legend_variable(combined_mapping, df_test)
  
  testthat::expect_equal(legend_var, "category")
})

testthat::test_that("detect_legend_variable: falls back to icon if multiple icons", {
  combined_mapping <- list()
  
  legend_var <- ggpop:::detect_legend_variable(combined_mapping, df_test)
  
  testthat::expect_equal(legend_var, "icon")
})

testthat::test_that("detect_legend_variable: returns NULL when no legend needed", {
  df_single_icon <- data.frame(
    x = 1:5,
    y = 1:5,
    icon = "circle",
    stringsAsFactors = FALSE
  )
  combined_mapping <- list()
  
  legend_var <- ggpop:::detect_legend_variable(combined_mapping, df_single_icon)
  
  testthat::expect_null(legend_var)
})

# ******************************************************************************
# 05 create_icon_by_legend tests ----------------------------------------------
# ******************************************************************************

testthat::test_that("create_icon_by_legend: creates mapping for legend variable", {
  legend_var <- "category"
  
  icon_by_legend <- ggpop:::create_icon_by_legend(
    data = df_test,
    legend_var = legend_var,
    icon = NULL,
    has_icon_param = FALSE
  )
  
  testthat::expect_type(icon_by_legend, "character")
  testthat::expect_true(all(names(icon_by_legend) %in% c("A", "B", "C")))
  testthat::expect_true(all(icon_by_legend %in% df_test$icon))
})

testthat::test_that("create_icon_by_legend: picks most common icon per group", {
  df_multi <- data.frame(
    category = c("A", "A", "A", "B", "B"),
    icon = c("circle", "circle", "star", "heart", "heart"),
    stringsAsFactors = FALSE
  )
  
  icon_by_legend <- ggpop:::create_icon_by_legend(
    data = df_multi,
    legend_var = "category",
    icon = NULL,
    has_icon_param = FALSE
  )
  
  testthat::expect_equal(icon_by_legend["A"], c(A = "circle"))
  testthat::expect_equal(icon_by_legend["B"], c(B = "heart"))
})

testthat::test_that("create_icon_by_legend: uses first icon when no legend_var", {
  icon_by_legend <- ggpop:::create_icon_by_legend(
    data = df_test,
    legend_var = NULL,
    icon = NULL,
    has_icon_param = FALSE
  )
  
  testthat::expect_equal(icon_by_legend, c(default = "circle"))
})

testthat::test_that("create_icon_by_legend: uses icon parameter when provided", {
  icon_by_legend <- ggpop:::create_icon_by_legend(
    data = df_test,
    legend_var = NULL,
    icon = "star",
    has_icon_param = TRUE
  )
  
  testthat::expect_equal(icon_by_legend, c(default = "star"))
})

# ******************************************************************************
# 06 normalize_icon_column tests ----------------------------------------------
# ******************************************************************************

testthat::test_that("normalize_icon_column: renames icon column", {
  df_renamed <- data.frame(
    x = 1:3,
    y = 1:3,
    my_icon = c("circle", "star", "heart"),
    stringsAsFactors = FALSE
  )
  
  result <- ggpop:::normalize_icon_column(df_renamed, "my_icon")
  
  testthat::expect_true("icon" %in% names(result))
  testthat::expect_equal(result$icon, df_renamed$my_icon)
})

testthat::test_that("normalize_icon_column: keeps icon column if already named icon", {
  result <- ggpop:::normalize_icon_column(df_test, "icon")
  
  testthat::expect_true("icon" %in% names(result))
  testthat::expect_equal(result$icon, df_test$icon)
})

testthat::test_that("normalize_icon_column: handles NULL icon_var", {
  result <- ggpop:::normalize_icon_column(df_test, NULL)
  
  testthat::expect_equal(result, df_test)
})

# ******************************************************************************
# 07 add_icon_to_mapping tests ------------------------------------------------
# ******************************************************************************

testthat::test_that("add_icon_to_mapping: adds icon if not present", {
  mapping_list <- list()
  inherited_mapping_list <- list(icon = rlang::sym("icon"))
  
  result <- ggpop:::add_icon_to_mapping(
    mapping_list = mapping_list,
    inherited_mapping_list = inherited_mapping_list,
    icon_var = "icon"
  )
  
  testthat::expect_true("icon" %in% names(result))
})

testthat::test_that("add_icon_to_mapping: preserves existing icon mapping", {
  mapping_list <- list(icon = rlang::sym("my_icon"))
  inherited_mapping_list <- list()
  
  result <- ggpop:::add_icon_to_mapping(
    mapping_list = mapping_list,
    inherited_mapping_list = inherited_mapping_list,
    icon_var = "my_icon"
  )
  
  testthat::expect_equal(result$icon, rlang::sym("my_icon"))
})

# ******************************************************************************
# 08 handle_argument_swap tests -----------------------------------------------
# ******************************************************************************

testthat::test_that("handle_argument_swap: swaps data and mapping when reversed", {
  # User passes data first, mapping second (incorrect order)
  result <- ggpop:::handle_argument_swap(
    mapping = df_test,  # Actually data
    data = ggplot2::aes(x = x, y = y)  # Actually mapping
  )
  
  testthat::expect_true(is.data.frame(result$data))
  testthat::expect_true(inherits(result$mapping, "uneval"))
})

testthat::test_that("handle_argument_swap: keeps correct order unchanged", {
  mapping <- ggplot2::aes(x = x, y = y)
  
  result <- ggpop:::handle_argument_swap(
    mapping = mapping,
    data = df_test
  )
  
  testthat::expect_equal(result$mapping, mapping)
  testthat::expect_equal(result$data, df_test)
})

testthat::test_that("handle_argument_swap: handles NULL mapping", {
  result <- ggpop:::handle_argument_swap(
    mapping = NULL,
    data = df_test
  )
  
  testthat::expect_null(result$mapping)
  testthat::expect_equal(result$data, df_test)
})

# ******************************************************************************
# 09 assign_pop_positions tests -----------------------------------------------
# ******************************************************************************

testthat::test_that("assign_pop_positions: assigns sequential positions without facet", {
  result <- ggpop:::assign_pop_positions(
    data = df_test,
    has_facet = FALSE,
    facet_col = NULL
  )
  
  testthat::expect_true("pos" %in% names(result))
  testthat::expect_equal(result$pos, 1:5)
})

testthat::test_that("assign_pop_positions: assigns positions per facet group", {
  df_faceted <- data.frame(
    icon = c("circle", "star", "heart", "square"),
    facet_var = c("A", "A", "B", "B"),
    stringsAsFactors = FALSE
  )
  
  result <- ggpop:::assign_pop_positions(
    data = df_faceted,
    has_facet = TRUE,
    facet_col = "facet_var"
  )
  
  testthat::expect_true("pos" %in% names(result))
  testthat::expect_equal(result$pos[result$facet_var == "A"], c(1, 2))
  testthat::expect_equal(result$pos[result$facet_var == "B"], c(1, 2))
})

# ******************************************************************************
# 10 maybe_shuffle_pop_data tests ---------------------------------------------
# ******************************************************************************

testthat::test_that("maybe_shuffle_pop_data: preserves order when arrange=TRUE", {
  result <- ggpop:::maybe_shuffle_pop_data(
    data = df_test,
    has_facet = FALSE,
    facet_col = NULL,
    arrange = TRUE,
    seed = NULL
  )
  
  testthat::expect_equal(result, df_test)
})

testthat::test_that("maybe_shuffle_pop_data: shuffles when arrange=FALSE", {
  set.seed(123)
  result1 <- ggpop:::maybe_shuffle_pop_data(
    data = df_test,
    has_facet = FALSE,
    facet_col = NULL,
    arrange = FALSE,
    seed = 123
  )
  
  set.seed(123)
  result2 <- ggpop:::maybe_shuffle_pop_data(
    data = df_test,
    has_facet = FALSE,
    facet_col = NULL,
    arrange = FALSE,
    seed = 123
  )
  
  # Same seed should produce same shuffle
  testthat::expect_equal(result1, result2)
  
  # Should be shuffled (very unlikely to be in original order)
  testthat::expect_false(all(result1$x == df_test$x))
})

testthat::test_that("maybe_shuffle_pop_data: shuffles within facet groups", {
  df_faceted <- data.frame(
    x = 1:6,
    icon = rep("circle", 6),
    facet_var = rep(c("A", "B"), each = 3),
    stringsAsFactors = FALSE
  )
  
  result <- ggpop:::maybe_shuffle_pop_data(
    data = df_faceted,
    has_facet = TRUE,
    facet_col = "facet_var",
    arrange = FALSE,
    seed = 456
  )
  
  # Should maintain facet groups
  testthat::expect_equal(
    table(result$facet_var),
    table(df_faceted$facet_var)
  )
})

# ******************************************************************************
# END --------------------------------------------------------------------------
# ******************************************************************************
