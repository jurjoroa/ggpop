testthat::test_that("legend subset selects rows and keys without mutation", {
  grid <- data.frame(
    row = c(1, 2, 3, 4), col = c(1, 1, 1, 1),
    icon = c("square-inset", "circle-inset", "diamond-inset", "plus-bold"),
    label = c("45", "50", "55", "60")
  )
  spec <- legend_spec(
    grid, keys = c(A = "#08B8A2", B = "#1090F3",
                   C = "#C99D0F", D = "#DF4601"),
    symbols = c(Frontier = "line", Once = "text"), key_columns = 2
  )
  original <- spec
  selected <- legend_subset(
    spec, grid_rows = 1:3, keys = c("C", "D"), symbols = "Frontier",
    group_gap = 0.8, xlim = c(-4, 6)
  )

  testthat::expect_identical(spec, original)
  testthat::expect_identical(unique(selected$grid$row), 1:3)
  testthat::expect_identical(names(selected$keys), c("C", "D"))
  testthat::expect_identical(selected$symbols$label, "Frontier")
  testthat::expect_identical(selected$key_columns, 1L)
  testthat::expect_equal(selected$group_gap, 0.8)
  testthat::expect_s3_class(legend_render(selected, 8, 1.3), "ggplot")
})

testthat::test_that("legend add key appends a styled line before rendering", {
  grid <- data.frame(row = 1, col = 1, icon = "square-inset", label = "A")
  spec <- legend_spec(grid, symbols = c(Frontier = "line", Note = "text"))
  original <- spec
  capacity <- legend_add_key(
    spec, "National capacity", type = "line", linetype = "dashed",
    colour = "grey30", linewidth = 0.6
  )

  testthat::expect_identical(spec, original)
  testthat::expect_equal(nrow(capacity$symbols), 3L)
  testthat::expect_identical(tail(capacity$symbols$label, 1),
                             "National capacity")
  testthat::expect_identical(tail(capacity$symbols$linetype, 1), "dashed")
  testthat::expect_equal(tail(capacity$symbols$linewidth, 1), 0.6)
  plot <- legend_render(capacity, width = 8, height = 1.5)
  built <- suppressWarnings(ggplot2::ggplot_build(plot))
  testthat::expect_true(any(vapply(built$data, function(data) {
    "linetype" %in% names(data) && "dashed" %in% data$linetype
  }, logical(1))))
})

testthat::test_that("legend variants reject missing content and duplicate labels", {
  grid <- data.frame(row = 1, col = 1, icon = "square-inset", label = "A")
  spec <- legend_spec(grid, keys = c(One = "#08B8A2"),
                      symbols = c(Frontier = "line"))
  testthat::expect_error(legend_subset(spec, grid_rows = 2), "grid_rows")
  testthat::expect_error(legend_subset(spec, keys = "Other"), "keys")
  testthat::expect_error(legend_subset(spec, symbols = "Other"), "symbols")
  testthat::expect_error(legend_subset(spec, key_columns = 2), "key_columns")
  testthat::expect_null(legend_subset(legend_spec(grid), symbols = character())$symbols)
  testthat::expect_error(legend_add_key(spec, "Frontier"), "label")
  testthat::expect_error(legend_add_key(spec, "Capacity", type = "other"),
                         "invalid value")
})
