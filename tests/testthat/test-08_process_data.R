# *****************************************************************************
#
# Script: test-08_process_data.R
#
# Purpose: Ensure process_data function works correctly within ggpop package
#
# Author: Jorge Roa
#
# Email: jorgeroa@stanford.edu
#
# Date Created: 26-Jan-2026
#
# *****************************************************************************

testthat::skip_if_not_installed("dplyr")
testthat::skip_if_not_installed("tidyr")
testthat::skip_if_not_installed("purrr")
testthat::skip_if_not_installed("rlang")
testthat::skip_if_not_installed("stringr")

# ******************************************************************************
## 01.01 Test dataframes -------------------------------------------------------
# ******************************************************************************

df_simple <- data.frame(
  sex = c("male", "female"),
  n = c(100, 200),
  stringsAsFactors = FALSE
)

df_hierarchical <- data.frame(
  country = rep(c("Mexico", "Canada"), each = 2),
  sex = rep(c("male", "female"), 2),
  n = c(63459580, 67401427, 18000000, 19000000),
  stringsAsFactors = FALSE
)

df_multi_hierarchy <- data.frame(
  continent = rep(c("America", "Europe"), each = 4),
  country = rep(c("Mexico", "Canada", "Spain", "France"), each = 2),
  sex = rep(c("male", "female"), 4),
  n = c(
    63459580, 67401427, 18000000, 19000000,
    23000000, 24000000, 32000000, 34000000
  ),
  stringsAsFactors = FALSE
)

df_no_sum_var <- data.frame(
  category = c("A", "A", "B", "B", "C"),
  type = c("X", "Y", "X", "Y", "X"),
  stringsAsFactors = FALSE
)

df_single_group <- data.frame(
  sex = c("female"),
  n = c(100000),
  stringsAsFactors = FALSE
)

df_many_groups <- data.frame(
  category = rep(LETTERS[1:10], each = 10),
  n = rep(100, 100),
  stringsAsFactors = FALSE
)

df_pop_mx <- data.frame(
  sex = c("male", "female"),
  n = c(63459580, 67401427),
  country = "Mexico",
  continent = "America",
  stringsAsFactors = FALSE
)

# ******************************************************************************
# 02 Basic functionality -------------------------------------------------------
# ******************************************************************************

### 02.01 Minimal valid usage --------------------------------------------------

testthat::test_that("simple two-group data", {
  testthat::expect_no_error({
    result <- process_data(
      data = df_simple,
      group_var = sex,
      sum_var = n,
      sample_size = 100
    )
  })
})

testthat::test_that("returns tibble/data.frame", {
  result <- process_data(
    data = df_simple,
    group_var = sex,
    sum_var = n,
    sample_size = 50
  )
  
  testthat::expect_true(is.data.frame(result))
})

testthat::test_that("contains expected columns", {
  result <- process_data(
    data = df_simple,
    group_var = sex,
    sum_var = n,
    sample_size = 50
  )
  
  testthat::expect_true(all(c("type", "n", "prop") %in% names(result)))
})

testthat::test_that("sample size matches request", {
  result <- process_data(
    data = df_simple,
    group_var = sex,
    sum_var = n,
    sample_size = 75
  )
  
  testthat::expect_equal(nrow(result), 75)
})

### 02.02 With sum_var ---------------------------------------------------------

testthat::test_that("sum_var aggregates correctly", {
  testthat::expect_no_error({
    result <- process_data(
      data = df_simple,
      group_var = sex,
      sum_var = n,
      sample_size = 100
    )
  })
})

testthat::test_that("proportions sum to 1 (no high_group_var)", {
  result <- process_data(
    data = df_simple,
    group_var = sex,
    sum_var = n,
    sample_size = 100
  )
  
  unique_props <- unique(result[, c("type", "prop")])
  total_prop <- sum(unique_props$prop)
  
  testthat::expect_equal(total_prop, 1, tolerance = 1e-6)
})

### 02.03 Without sum_var (count rows) -----------------------------------------

testthat::test_that("count mode (sum_var = NULL)", {
  testthat::expect_no_error({
    result <- process_data(
      data = df_no_sum_var,
      group_var = category,
      sum_var = NULL,
      sample_size = 50
    )
  })
})

testthat::test_that("count mode counts rows correctly", {
  result <- process_data(
    data = df_no_sum_var,
    group_var = category,
    sample_size = 100
  )
  
  unique_counts <- unique(result[, c("type", "n")])
  
  testthat::expect_equal(unique_counts$n[unique_counts$type == "A"], 2)
  testthat::expect_equal(unique_counts$n[unique_counts$type == "B"], 2)
  testthat::expect_equal(unique_counts$n[unique_counts$type == "C"], 1)
})

# ******************************************************************************
# 03 Hierarchical grouping -----------------------------------------------------
# ******************************************************************************

### 03.01 Single high_group_var ------------------------------------------------

testthat::test_that("single high_group_var", {
  testthat::expect_no_error({
    result <- process_data(
      data = df_hierarchical,
      high_group_var = "country",
      group_var = sex,
      sum_var = n,
      sample_size = 50
    )
  })
})

testthat::test_that("creates group column", {
  result <- process_data(
    data = df_hierarchical,
    high_group_var = "country",
    group_var = sex,
    sum_var = n,
    sample_size = 50
  )
  
  testthat::expect_true("group" %in% names(result))
})

testthat::test_that("correct number of samples per high group", {
  result <- process_data(
    data = df_hierarchical,
    high_group_var = "country",
    group_var = sex,
    sum_var = n,
    sample_size = 50
  )
  
  group_counts <- table(result$group)
  testthat::expect_true(all(group_counts == 50))
})

testthat::test_that("proportions sum to 1 within each high group", {
  result <- process_data(
    data = df_hierarchical,
    high_group_var = "country",
    group_var = sex,
    sum_var = n,
    sample_size = 100
  )
  
  unique_props <- result %>%
    dplyr::select(group, type, prop) %>%
    dplyr::distinct() %>%
    dplyr::group_by(group) %>%
    dplyr::summarise(total_prop = sum(prop), .groups = "drop")
  
  testthat::expect_true(all(abs(unique_props$total_prop - 1) < 1e-6))
})

### 03.02 Multiple Hierarchical high_group_var --------------------------------

testthat::test_that("high_group_var with 2 levels", {
  testthat::expect_no_error({
    result <- process_data(
      data = df_multi_hierarchy,
      high_group_var = c("continent", "country"),
      group_var = sex,
      sum_var = n,
      sample_size = 50
    )
  })
})

testthat::test_that("group column concatenates correctly", {
  result <- process_data(
    data = df_multi_hierarchy,
    high_group_var = c("continent", "country"),
    group_var = sex,
    sum_var = n,
    sample_size = 50
  )
  
  testthat::expect_true(any(grepl("_", result$group)))
})

testthat::test_that("correct number of hierarchical groups with 2 levels", {
  result <- process_data(
    data = df_multi_hierarchy,
    high_group_var = c("continent", "country"),
    group_var = sex,
    sum_var = n,
    sample_size = 50
  )
  
  testthat::expect_equal(length(unique(result$group)), 4)
})

testthat::test_that("multiple high_group_var with 3 levels", {
  df_three_level <- data.frame(
    continent = rep(c("America", "Europe"), each = 8),
    region = rep(c("North", "South"), each = 4, times = 2),
    country = rep(c("USA", "Canada", "Spain", "France"), each = 2),
    sex = rep(c("male", "female"), 4),
    n = c(
      165, 170, 18, 19, 23, 24, 32, 34,
      40, 41, 29, 30, 50, 52, 35, 36
    )
  )
  
  testthat::expect_no_error({
    result <- process_data(
      data = df_three_level,
      high_group_var = c("continent", "region", "country"),
      group_var = sex,
      sum_var = n,
      sample_size = 50
    )
  })
})

testthat::test_that("correct groups with 3 levels", {
  df_three_level <- data.frame(
    continent = rep(c("America", "Europe"), each = 4),
    region = rep(c("North", "South"), each = 2, times = 2),
    country = rep(c("USA", "Canada", "Spain", "France"), each = 2),
    sex = rep(c("male", "female"), 4),
    n = c(165, 170, 18, 19, 23, 24, 32, 34)
  )
  
  result <- process_data(
    data = df_three_level,
    high_group_var = c("continent", "region", "country"),
    group_var = sex,
    sum_var = n,
    sample_size = 50
  )
  
  testthat::expect_equal(length(unique(result$group)), 4)
  testthat::expect_true(all(stringr::str_count(unique(result$group), "_") == 2))
})

testthat::test_that("multiple high_group_var with 4 levels", {
  df_four_level <- data.frame(
    continent = rep(c("America", "Europe"), each = 16),
    region = rep(c("North", "South"), each = 8, times = 2),
    country = rep(c("USA", "Canada", "Mexico", "Brazil"), each = 4, times = 2),
    city = rep(c("CityA", "CityB"), each = 2, times = 8),
    sex = rep(c("male", "female"), 16),
    n = rep(c(80, 85, 90, 95), each = 2, times = 4)
  )
  
  testthat::expect_no_error({
    result <- process_data(
      data = df_four_level,
      high_group_var = c("continent", "region", "country", "city"),
      group_var = sex,
      sum_var = n,
      sample_size = 50
    )
  })
})

testthat::test_that("correct groups with 4 levels", {
  df_four_level <- data.frame(
    continent = rep(c("America", "Europe"), each = 16),
    region = rep(c("North", "South"), each = 8, times = 2),
    country = rep(c("USA", "Canada", "Mexico", "Brazil"), each = 4, times = 2),
    city = rep(c("CityA", "CityB"), each = 2, times = 8),
    sex = rep(c("male", "female"), 16),
    n = rep(c(80, 85, 90, 95), each = 2, times = 4)
  )
  
  result <- process_data(
    data = df_four_level,
    high_group_var = c("continent", "region", "country", "city"),
    group_var = sex,
    sum_var = n,
    sample_size = 50
  )
  
  testthat::expect_equal(length(unique(result$group)), 16)
  testthat::expect_true(all(stringr::str_count(unique(result$group), "_") == 3))
})

testthat::test_that("multiple high_group_var with 5 levels", {
  df_five_level <- data.frame(
    continent = rep(c("America", "Europe"), each = 32),
    region = rep(c("North", "South"), each = 16, times = 2),
    country = rep(c("USA", "Canada", "Mexico", "Brazil"), each = 8, times = 2),
    city = rep(c("CityA", "CityB"), each = 4, times = 8),
    district = rep(c("DistrictX", "DistrictY"), each = 2, times = 16),
    sex = rep(c("male", "female"), 32),
    n = rep(c(40, 45, 50, 55), each = 2, times = 8)
  )
  
  testthat::expect_no_error({
    result <- process_data(
      data = df_five_level,
      high_group_var = c("continent", "region", "country", "city", "district"),
      group_var = sex,
      sum_var = n,
      sample_size = 50
    )
  })
})

testthat::test_that("correct groups with 5 levels", {
  df_five_level <- data.frame(
    continent = rep(c("America", "Europe"), each = 32),
    region = rep(c("North", "South"), each = 16, times = 2),
    country = rep(c("USA", "Canada", "Mexico", "Brazil"), each = 8, times = 2),
    city = rep(c("CityA", "CityB"), each = 4, times = 8),
    district = rep(c("DistrictX", "DistrictY"), each = 2, times = 16),
    sex = rep(c("male", "female"), 32),
    n = rep(c(40, 45, 50, 55), each = 2, times = 8)
  )
  
  result <- process_data(
    data = df_five_level,
    high_group_var = c("continent", "region", "country", "city", "district"),
    group_var = sex,
    sum_var = n,
    sample_size = 50
  )
  
  testthat::expect_equal(length(unique(result$group)), 32)
  testthat::expect_true(all(stringr::str_count(unique(result$group), "_") == 4))
})

testthat::test_that("sample_size consistent across all levels", {
  df_five_level <- data.frame(
    continent = rep(c("America", "Europe"), each = 32),
    region = rep(c("North", "South"), each = 16, times = 2),
    country = rep(c("USA", "Canada", "Mexico", "Brazil"), each = 8, times = 2),
    city = rep(c("CityA", "CityB"), each = 4, times = 8),
    district = rep(c("DistrictX", "DistrictY"), each = 2, times = 16),
    sex = rep(c("male", "female"), 32),
    n = rep(c(40, 45, 50, 55), each = 2, times = 8)
  )
  
  result <- process_data(
    data = df_five_level,
    high_group_var = c("continent", "region", "country", "city", "district"),
    group_var = sex,
    sum_var = n,
    sample_size = 75
  )
  
  group_counts <- table(result$group)
  testthat::expect_true(all(group_counts == 75))
})

# ******************************************************************************
# 04 Sample size variations ----------------------------------------------------
# ******************************************************************************

testthat::test_that("minimum valid (1)", {
  testthat::expect_no_error({
    result <- process_data(
      data = df_simple,
      group_var = sex,
      sum_var = n,
      sample_size = 1
    )
  })
})

testthat::test_that("small (10)", {
  result <- process_data(
    data = df_simple,
    group_var = sex,
    sum_var = n,
    sample_size = 10
  )
  
  testthat::expect_equal(nrow(result), 10)
})

testthat::test_that("medium (100)", {
  result <- process_data(
    data = df_simple,
    group_var = sex,
    sum_var = n,
    sample_size = 100
  )
  
  testthat::expect_equal(nrow(result), 100)
})

testthat::test_that("large (500)", {
  result <- process_data(
    data = df_simple,
    group_var = sex,
    sum_var = n,
    sample_size = 500
  )
  
  testthat::expect_equal(nrow(result), 500)
})

testthat::test_that("maximum valid (1000)", {
  testthat::expect_no_error({
    result <- process_data(
      data = df_simple,
      group_var = sex,
      sum_var = n,
      sample_size = 1000
    )
  })
  
  testthat::expect_equal(nrow(result), 1000)
})

# ******************************************************************************
# 05 Edge cases ----------------------------------------------------------------
# ******************************************************************************

testthat::test_that("single group", {
  testthat::expect_no_error({
    result <- process_data(
      data = df_single_group,
      group_var = sex,
      sum_var = n,
      sample_size = 100
    )
  })
})

testthat::test_that("single group has proportion 1", {
  result <- process_data(
    data = df_single_group,
    group_var = sex,
    sum_var = n,
    sample_size = 50
  )
  
  testthat::expect_equal(unique(result$prop), 1)
})

testthat::test_that("single group all same type", {
  result <- process_data(
    data = df_single_group,
    group_var = sex,
    sum_var = n,
    sample_size = 50
  )
  
  testthat::expect_equal(length(unique(result$type)), 1)
  testthat::expect_true(all(result$type == "female"))
})

testthat::test_that("many groups (10)", {
  testthat::expect_no_error({
    result <- process_data(
      data = df_many_groups,
      group_var = category,
      sum_var = n,
      sample_size = 100
    )
  })
})

testthat::test_that("many groups proportions sum to 1", {
  result <- process_data(
    data = df_many_groups,
    group_var = category,
    sum_var = n,
    sample_size = 100
  )
  
  unique_props <- unique(result[, c("type", "prop")])
  total_prop <- sum(unique_props$prop)
  
  testthat::expect_equal(total_prop, 1, tolerance = 1e-6)
})

testthat::test_that("highly unbalanced groups", {
  df_unbalanced <- data.frame(
    category = c("rare", "common"),
    n = c(1, 999),
    stringsAsFactors = FALSE
  )
  
  testthat::expect_no_error({
    result <- process_data(
      data = df_unbalanced,
      group_var = category,
      sum_var = n,
      sample_size = 100
    )
  })
})

testthat::test_that("sampling reflects proportions approximately", {
  result <- process_data(
    data = df_simple,
    group_var = sex,
    sum_var = n,
    sample_size = 1000
  )
  
  observed_props <- table(result$type) / 1000
  
  testthat::expect_equal(
    as.numeric(observed_props["female"]),
    2 / 3,
    tolerance = 0.08
  )
  testthat::expect_equal(
    as.numeric(observed_props["male"]),
    1 / 3,
    tolerance = 0.08
  )
})

testthat::test_that("factor group_var converted to character", {
  df_factor <- df_simple
  df_factor$sex <- factor(df_factor$sex)
  
  result <- process_data(
    data = df_factor,
    group_var = sex,
    sum_var = n,
    sample_size = 50
  )
  
  testthat::expect_true(is.character(result$type))
})

# ******************************************************************************
# 06 Error handling: sample_size -----------------------------------------------
# ******************************************************************************

testthat::test_that("sample_size = 0", {
  testthat::expect_error(
    process_data(
      data = df_simple,
      group_var = sex,
      sum_var = n,
      sample_size = 0
    ),
    regexp = "must be a single integer between 1 and 1000"
  )
})

testthat::test_that("negative sample_size", {
  testthat::expect_error(
    process_data(
      data = df_simple,
      group_var = sex,
      sum_var = n,
      sample_size = -10
    ),
    regexp = "must be a single integer between 1 and 1000"
  )
})

testthat::test_that("sample_size > 1000", {
  testthat::expect_error(
    process_data(
      data = df_simple,
      group_var = sex,
      sum_var = n,
      sample_size = 1001
    ),
    regexp = "must be a single integer between 1 and 1000"
  )
})

testthat::test_that("sample_size is decimal", {
  testthat::expect_error(
    process_data(
      data = df_simple,
      group_var = sex,
      sum_var = n,
      sample_size = 50.5
    ),
    regexp = "must be a single integer between 1 and 1000"
  )
})

testthat::test_that("sample_size is NA", {
  testthat::expect_error(
    process_data(
      data = df_simple,
      group_var = sex,
      sum_var = n,
      sample_size = NA
    ),
    regexp = "must be a single integer between 1 and 1000"
  )
})

testthat::test_that("sample_size is NULL", {
  testthat::expect_error(
    process_data(
      data = df_simple,
      group_var = sex,
      sum_var = n,
      sample_size = NULL
    ),
    regexp = "must be a single integer between 1 and 1000"
  )
})

testthat::test_that("sample_size is character", {
  testthat::expect_error(
    process_data(
      data = df_simple,
      group_var = sex,
      sum_var = n,
      sample_size = "100"
    ),
    regexp = "must be a single integer between 1 and 1000"
  )
})

testthat::test_that("sample_size is vector", {
  testthat::expect_error(
    process_data(
      data = df_simple,
      group_var = sex,
      sum_var = n,
      sample_size = c(50, 100)
    ),
    regexp = "must be a single integer between 1 and 1000"
  )
})

testthat::test_that("sample_size is Inf", {
  testthat::expect_error(
    process_data(
      data = df_simple,
      group_var = sex,
      sum_var = n,
      sample_size = Inf
    ),
    regexp = "must be a single integer between 1 and 1000"
  )
})

# ******************************************************************************
# 07 Error handling: group_var -------------------------------------------------
# ******************************************************************************

testthat::test_that("missing group_var", {
  testthat::expect_error(
    process_data(
      data = df_simple,
      sum_var = n,
      sample_size = 50
    )
  )
})

testthat::test_that("group_var = NULL", {
  testthat::expect_error(
    process_data(
      data = df_simple,
      group_var = NULL,
      sum_var = n,
      sample_size = 50
    )
  )
})

testthat::test_that("group_var not in data", {
  testthat::expect_error(
    process_data(
      data = df_simple,
      group_var = nonexistent_column,
      sum_var = n,
      sample_size = 50
    )
  )
})

# ******************************************************************************
# 08 Error handling: sum_var ---------------------------------------------------
# ******************************************************************************

testthat::test_that("sum_var not in data", {
  testthat::expect_error(
    process_data(
      data = df_simple,
      group_var = sex,
      sum_var = nonexistent_column,
      sample_size = 50
    )
  )
})

testthat::test_that("sum_var is character column", {
  df_bad_sum <- data.frame(
    category = c("A", "B"),
    value = c("100", "200"),
    stringsAsFactors = FALSE
  )
  
  testthat::expect_error(
    process_data(
      data = df_bad_sum,
      group_var = category,
      sum_var = value,
      sample_size = 50
    )
  )
})

# ******************************************************************************
# 09 Error handling: high_group_var --------------------------------------------
# ******************************************************************************

testthat::test_that("high_group_var not in data", {
  testthat::expect_error(
    process_data(
      data = df_hierarchical,
      high_group_var = "nonexistent",
      group_var = sex,
      sum_var = n,
      sample_size = 50
    )
  )
})

testthat::test_that("one of multiple high_group_var not in data", {
  testthat::expect_error(
    process_data(
      data = df_hierarchical,
      high_group_var = c("country", "nonexistent"),
      group_var = sex,
      sum_var = n,
      sample_size = 50
    )
  )
})

# ******************************************************************************
# 10 Error handling: data ------------------------------------------------------
# ******************************************************************************

testthat::test_that("data is NULL", {
  testthat::expect_error(
    process_data(
      data = NULL,
      group_var = sex,
      sum_var = n,
      sample_size = 50
    )
  )
})

testthat::test_that("data is not a data frame", {
  testthat::expect_error(
    process_data(
      data = list(sex = c("male", "female"), n = c(100, 200)),
      group_var = sex,
      sum_var = n,
      sample_size = 50
    )
  )
})

testthat::test_that("empty data frame", {
  testthat::expect_error(
    process_data(
      data = data.frame(),
      group_var = sex,
      sum_var = n,
      sample_size = 50
    )
  )
})

# ******************************************************************************
# 11 Warnings ------------------------------------------------------------------
# ******************************************************************************

testthat::test_that("proportions don't sum to 1 (data issue)", {
  testthat::expect_no_warning({
    result <- process_data(
      data = df_simple,
      group_var = sex,
      sum_var = n,
      sample_size = 100
    )
  })
})

testthat::test_that("proportions within groups don't sum to 1", {
  testthat::expect_no_warning({
    result <- process_data(
      data = df_hierarchical,
      high_group_var = "country",
      group_var = sex,
      sum_var = n,
      sample_size = 50
    )
  })
})

# ******************************************************************************
# 12 Real-world usage patterns -------------------------------------------------
# ******************************************************************************

testthat::test_that("simcrc example", {
  df_pop_simcrc_1 <- data.frame(
    sex = c("female"),
    value = c(100000)
  )
  
  testthat::expect_no_error({
    df_pop_simcrc_1_prop <- process_data(
      data = df_pop_simcrc_1,
      group_var = sex,
      sum_var = value,
      sample_size = 1000
    )
  })
})

testthat::test_that("Mexico example", {
  df_pop_mx <- data.frame(
    sex = c("male", "female"),
    n = c(63459580, 67401427),
    country = "Mexico",
    continent = "America"
  )
  
  testthat::expect_no_error({
    df_pop_mx_prop <- process_data(
      data = df_pop_mx,
      group_var = sex,
      sum_var = n,
      sample_size = 50
    )
  })
})

testthat::test_that("multi-country multi-continent", {
  df_world <- data.frame(
    continent = rep(c("Asia", "Europe", "America"), each = 4),
    country = rep(c(
      "China", "India", "Germany", "France",
      "USA", "Brazil"
    ), each = 2),
    sex = rep(c("male", "female"), 6),
    population = c(
      720000000, 690000000,
      680000000, 650000000,
      41000000, 42000000,
      32000000, 34000000,
      165000000, 170000000,
      105000000, 108000000
    ),
    stringsAsFactors = FALSE
  )
  
  testthat::expect_no_error({
    result <- process_data(
      data = df_world,
      high_group_var = c("continent", "country"),
      group_var = sex,
      sum_var = population,
      sample_size = 100
    )
  })
})

testthat::test_that("survey responses (count mode)", {
  df_survey <- data.frame(
    response = sample(c("Agree", "Neutral", "Disagree"), 500, replace = TRUE),
    stringsAsFactors = FALSE
  )
  
  testthat::expect_no_error({
    result <- process_data(
      data = df_survey,
      group_var = response,
      sample_size = 100
    )
  })
})

testthat::test_that("maximum sample size", {
  testthat::expect_no_error({
    result <- process_data(
      data = df_simple,
      group_var = sex,
      sum_var = n,
      sample_size = 1000
    )
  })
  
  testthat::expect_equal(nrow(result), 1000)
})

# ******************************************************************************
# 13 Output validation ---------------------------------------------------------
# ******************************************************************************

testthat::test_that("has correct column types", {
  result <- process_data(
    data = df_simple,
    group_var = sex,
    sum_var = n,
    sample_size = 50
  )
  
  testthat::expect_type(result$type, "character")
  testthat::expect_type(result$n, "double")
  testthat::expect_type(result$prop, "double")
})

testthat::test_that("proportions are valid probabilities", {
  result <- process_data(
    data = df_simple,
    group_var = sex,
    sum_var = n,
    sample_size = 100
  )
  
  unique_props <- unique(result$prop)
  
  testthat::expect_true(all(unique_props >= 0))
  testthat::expect_true(all(unique_props <= 1))
})

testthat::test_that("n values are non-negative", {
  result <- process_data(
    data = df_simple,
    group_var = sex,
    sum_var = n,
    sample_size = 100
  )
  
  testthat::expect_true(all(result$n >= 0))
})

testthat::test_that("type values match input groups", {
  result <- process_data(
    data = df_simple,
    group_var = sex,
    sum_var = n,
    sample_size = 100
  )
  
  testthat::expect_true(all(result$type %in% df_simple$sex))
})

testthat::test_that("hierarchical sampling preserves group sizes", {
  result <- process_data(
    data = df_hierarchical,
    high_group_var = "country",
    group_var = sex,
    sum_var = n,
    sample_size = 100
  )
  
  group_sizes <- table(result$group)
  testthat::expect_true(all(group_sizes == 100))
})

# ******************************************************************************
# 14 Reproducibility -----------------------------------------------------------
# ******************************************************************************

testthat::test_that("different results on repeated calls", {
  result1 <- process_data(
    data = df_simple,
    group_var = sex,
    sum_var = n,
    sample_size = 50
  )
  
  result2 <- process_data(
    data = df_simple,
    group_var = sex,
    sum_var = n,
    sample_size = 50
  )
  
  testthat::expect_false(identical(result1$type, result2$type))
})

testthat::test_that("deterministic proportions", {
  result1 <- process_data(
    data = df_simple,
    group_var = sex,
    sum_var = n,
    sample_size = 50
  )
  
  result2 <- process_data(
    data = df_simple,
    group_var = sex,
    sum_var = n,
    sample_size = 50
  )
  
  props1 <- unique(result1[, c("type", "prop")])
  props2 <- unique(result2[, c("type", "prop")])
  
  props1 <- props1[order(props1$type), ]
  props2 <- props2[order(props2$type), ]
  
  testthat::expect_equal(props1$prop, props2$prop)
})

# ******************************************************************************
# 15 Advanced scenarios -----------------
# ******************************************************************************

### 15.01 Hierarchical grouping (high_group_var) -------------------------------

testthat::test_that("handles hierarchical grouping with high_group_var", {
  df_hier <- data.frame(
    country = rep(c("USA", "Canada"), each = 10),
    state = c(rep(c("CA", "NY"), each = 5), rep(c("ON", "BC"), each = 5)),
    stringsAsFactors = FALSE
  )
  
  result <- process_data(
    data = df_hier,
    group_var = state,
    high_group_var = "country",
    sample_size = 20
  )
  
  testthat::expect_s3_class(result, "data.frame")
  testthat::expect_true("type" %in% names(result))
  testthat::expect_equal(nrow(result), 40)
})

testthat::test_that("hierarchical with different sample sizes", {
  df_hier <- data.frame(
    region = rep(c("North", "South"), each = 50),
    city = c(rep(c("A", "B"), each = 25), rep(c("C", "D"), each = 25)),
    stringsAsFactors = FALSE
  )
  
  result <- process_data(
    data = df_hier,
    group_var = city,
    high_group_var = "region",
    sample_size = 100
  )
  
  testthat::expect_equal(nrow(result), 200)
  testthat::expect_true(all(result$type %in% c("A", "B", "C", "D")))
})

testthat::test_that("hierarchical with unequal group sizes", {
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
    group_var = team,
    high_group_var = "dept",
    sample_size = 50
  )
  
  testthat::expect_equal(nrow(result), 150)
  type_counts <- table(result$type)
  testthat::expect_true(all(names(type_counts) %in% c("S1", "S2", "I1", "I2", "H1")))
})

### 15.02 Edge cases: zero rows and ties --------------------------------------

testthat::test_that("handles groups with zero counts gracefully", {
  df_with_zero <- data.frame(
    category = character(0),
    stringsAsFactors = FALSE
  )
  
  testthat::expect_error(
    process_data(
      data = df_with_zero,
      group_var = category,
      sample_size = 10
    ),
    regexp = "empty"
  )
})

testthat::test_that("handles ties in proportions", {
  df_ties <- data.frame(
    group = rep(c("A", "B", "C", "D"), each = 25),
    stringsAsFactors = FALSE
  )
  
  result <- process_data(
    data = df_ties,
    group_var = group,
    sample_size = 100
  )
  
  type_counts <- table(result$type)
  testthat::expect_equal(sum(type_counts), 100)
  testthat::expect_true(all(names(type_counts) %in% c("A", "B", "C", "D")))
  testthat::expect_true(all(type_counts > 0))
})

testthat::test_that("handles rounding with small sample_size", {
  df_small <- data.frame(
    group = c(rep("A", 67), rep("B", 33)),
    stringsAsFactors = FALSE
  )
  
  result <- process_data(
    data = df_small,
    group_var = group,
    sample_size = 10
  )
  
  testthat::expect_equal(nrow(result), 10)
  type_counts <- table(result$type)
  testthat::expect_equal(sum(type_counts), 10)
  testthat::expect_true(all(names(type_counts) %in% c("A", "B")))
})

### 15.03 sum_var behaviors ----------------------------------------------------

testthat::test_that("uses sum_var instead of count", {
  df_sum <- data.frame(
    category = c("A", "A", "B", "B", "B"),
    value = c(100, 200, 50, 50, 100),
    stringsAsFactors = FALSE
  )
  
  result <- process_data(
    data = df_sum,
    group_var = category,
    sum_var = value,
    sample_size = 100
  )
  
  testthat::expect_equal(nrow(result), 100)
  type_counts <- table(result$type)
  testthat::expect_true(type_counts["A"] > type_counts["B"])
  testthat::expect_true(type_counts["A"] >= 50)
})

testthat::test_that("sum_var with zeros", {
  df_zero_sum <- data.frame(
    category = c("A", "B", "C"),
    value = c(100, 0, 50),
    stringsAsFactors = FALSE
  )
  
  result <- process_data(
    data = df_zero_sum,
    group_var = category,
    sum_var = value,
    sample_size = 30
  )
  
  testthat::expect_equal(nrow(result), 30)
  type_counts <- table(result$type)
  testthat::expect_true(!"B" %in% names(type_counts) || type_counts["B"] == 0)
})

testthat::test_that("sum_var with negative values warns", {
  df_negative <- data.frame(
    category = c("A", "B"),
    value = c(100, -50),
    stringsAsFactors = FALSE
  )
  
  result <- NULL
  
  testthat::expect_warning(
    {
      result <- withCallingHandlers(
        process_data(
          data = df_negative,
          group_var = category,
          sum_var = value,
          sample_size = 30
        ),
        warning = function(w) {
          if (grepl("Proportions do not sum to 1", conditionMessage(w))) {
            invokeRestart("muffleWarning")
          }
        }
      )
    },
    regexp = "negative values"
  )
  
  testthat::expect_equal(nrow(result), 30)
})

### 15.04 Large data behavior --------------------------------------------------

testthat::test_that("handles large datasets efficiently", {
  df_large <- data.frame(
    group = sample(LETTERS[1:10], 10000, replace = TRUE),
    stringsAsFactors = FALSE
  )
  
  result <- process_data(
    data = df_large,
    group_var = group,
    sample_size = 1000
  )
  
  testthat::expect_equal(nrow(result), 1000)
  testthat::expect_s3_class(result, "data.frame")
})

testthat::test_that("maintains proportions in large dataset", {
  df_large <- data.frame(
    group = c(rep("A", 7000), rep("B", 3000)),
    stringsAsFactors = FALSE
  )
  
  result <- process_data(
    data = df_large,
    group_var = group,
    sample_size = 1000
  )
  
  type_counts <- table(result$type)
  testthat::expect_true(type_counts["A"] >= 650)
  testthat::expect_true(type_counts["A"] <= 750)
  testthat::expect_true(type_counts["B"] >= 250)
  testthat::expect_true(type_counts["B"] <= 350)
})

### 15.05 Special characters + factor handling --------------------------------

testthat::test_that("handles special characters in group names", {
  df_special <- data.frame(
    group = c("Group A", "Group-B", "Group_C", "Group.D"),
    stringsAsFactors = FALSE
  )
  df_special <- df_special[rep(1:4, each = 25), , drop = FALSE]
  
  result <- process_data(
    data = df_special,
    group_var = group,
    sample_size = 100
  )
  
  testthat::expect_equal(nrow(result), 100)
  testthat::expect_true(all(result$type %in% df_special$group))
})

testthat::test_that("handles factor grouping variables", {
  df_factor <- data.frame(
    group = factor(c("Low", "Medium", "High", "Low", "Medium", "High")),
    stringsAsFactors = TRUE
  )
  df_factor <- df_factor[rep(1:6, each = 10), , drop = FALSE]
  
  result <- process_data(
    data = df_factor,
    group_var = group,
    sample_size = 60
  )
  
  testthat::expect_equal(nrow(result), 60)
  testthat::expect_true(all(result$type %in% as.character(df_factor$group)))
})

testthat::test_that("handles ordered factors", {
  df_ordered <- data.frame(
    priority = ordered(c("Low", "Medium", "High"), levels = c("Low", "Medium", "High")),
    stringsAsFactors = TRUE
  )
  df_ordered <- df_ordered[rep(1:3, times = c(10, 20, 30)), , drop = FALSE]
  
  result <- process_data(
    data = df_ordered,
    group_var = priority,
    sample_size = 60
  )
  
  testthat::expect_equal(nrow(result), 60)
  type_counts <- table(result$type)
  testthat::expect_true(type_counts["High"] > type_counts["Medium"])
  testthat::expect_true(type_counts["Medium"] > type_counts["Low"])
})

### 15.06 Output structure + numeric group vars --------------------------------

testthat::test_that("respects faceting in output", {
  df_faceted <- data.frame(
    facet = rep(c("F1", "F2"), each = 50),
    group = rep(c("A", "B"), times = 50),
    stringsAsFactors = FALSE
  )
  
  result <- process_data(
    data = df_faceted,
    group_var = group,
    sample_size = 100
  )
  
  testthat::expect_equal(nrow(result), 100)
  testthat::expect_true("type" %in% names(result))
})

testthat::test_that("returns required columns", {
  df_simple_extra <- data.frame(
    group = c("A", "B"),
    stringsAsFactors = FALSE
  )
  df_simple_extra <- df_simple_extra[rep(1:2, each = 50), , drop = FALSE]
  
  result <- process_data(
    data = df_simple_extra,
    group_var = group,
    sample_size = 100
  )
  
  required_cols <- c("type", "n", "prop")
  testthat::expect_true(all(required_cols %in% names(result)))
})

testthat::test_that("prop column sums to 1", {
  df_simple_extra <- data.frame(
    group = c("A", "B", "C"),
    stringsAsFactors = FALSE
  )
  df_simple_extra <- df_simple_extra[rep(1:3, times = c(30, 40, 30)), , drop = FALSE]
  
  result <- process_data(
    data = df_simple_extra,
    group_var = group,
    sample_size = 100
  )
  
  prop_by_type <- result %>%
    dplyr::group_by(type) %>%
    dplyr::summarise(prop = dplyr::first(prop), .groups = "drop")
  
  testthat::expect_equal(sum(prop_by_type$prop), 1, tolerance = 0.01)
})

testthat::test_that("n column reflects sample counts", {
  df_simple_extra <- data.frame(
    group = c("A", "B"),
    stringsAsFactors = FALSE
  )
  df_simple_extra <- df_simple_extra[rep(1:2, each = 50), , drop = FALSE]
  
  result <- process_data(
    data = df_simple_extra,
    group_var = group,
    sample_size = 100
  )
  
  n_by_type <- result %>%
    dplyr::group_by(type) %>%
    dplyr::summarise(n = dplyr::first(n), .groups = "drop")
  
  testthat::expect_equal(sum(n_by_type$n), 100)
})

testthat::test_that("handles numeric grouping variables", {
  df_numeric <- data.frame(
    age_group = c(1, 2, 3, 1, 2, 3),
    stringsAsFactors = FALSE
  )
  df_numeric <- df_numeric[rep(1:6, each = 10), , drop = FALSE]
  
  result <- process_data(
    data = df_numeric,
    group_var = age_group,
    sample_size = 60
  )
  
  testthat::expect_equal(nrow(result), 60)
  testthat::expect_true(all(result$type %in% c("1", "2", "3")))
})