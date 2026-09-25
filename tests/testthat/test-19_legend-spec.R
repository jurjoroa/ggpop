testthat::test_that("legend spec renders external keys in column order", {
  grid <- data.frame(
    row = c(1, 2), col = c(1, 1),
    icon = c("square-inset", "circle-solid"),
    label = c("A", "B")
  )
  keys <- c(One = "#08B8A2", Two = "#1090F3", Three = "#2D3CF0",
            Four = "#C99D0F", Five = "#DF4601")
  spec <- legend_spec(
    grid, keys = keys, key_columns = 2,
    symbols = c(Frontier = "line", Note = "text"),
    grid_title = "Age", group_title = "Group"
  )
  plot <- legend_render(spec, width = 8, height = 1.5)

  testthat::expect_s3_class(spec, "ggpop_legend_spec")
  testthat::expect_s3_class(plot, "ggplot")
  testthat::expect_identical(spec$keys, keys)
  testthat::expect_false(is.null(plot$coordinates$limits$x))
  testthat::expect_false(is.null(plot$coordinates$limits$y))

  built <- suppressWarnings(ggplot2::ggplot_build(plot))
  rectangles <- Filter(function(data) {
    all(c("xmin", "xmax", "ymin", "ymax", "fill") %in% names(data)) &&
      any(data$fill %in% unname(keys))
  }, built$data)
  key_rectangles <- do.call(rbind, rectangles)
  key_rectangles <- key_rectangles[key_rectangles$fill %in% unname(keys), ]
  testthat::expect_equal(nrow(key_rectangles), 5L)
  testthat::expect_equal(as.integer(table(key_rectangles$xmin)), c(3L, 2L))
  testthat::expect_true(any(vapply(built$data, function(data) {
    "label" %in% names(data) && "Note" %in% data$label
  }, logical(1))))
})

testthat::test_that("rendering does not change a legend spec", {
  grid <- data.frame(row = 1, col = 1, icon = "square-inset", label = "A")
  spec <- legend_spec(grid, keys = c(One = "#08B8A2"), border = NA)
  original <- spec
  plot <- legend_render(spec, width = 7, height = 1.5)
  testthat::expect_identical(spec, original)
  testthat::expect_s3_class(plot, "ggplot")
})

testthat::test_that("legend spec validates its content and dimensions", {
  grid <- data.frame(row = 1, col = 1, icon = "square-inset", label = "A")
  testthat::expect_error(legend_spec(data.frame()), "grid")
  testthat::expect_error(legend_spec(transform(grid, row = "one")), "grid")
  testthat::expect_error(legend_spec(grid, keys = "#08B8A2"), "keys")
  testthat::expect_error(legend_spec(grid, keys = c(One = "red"),
                                     key_columns = 2), "key_columns")
  testthat::expect_error(legend_spec(grid, xlim = c(1, 0)), "xlim")
  testthat::expect_error(legend_spec(grid, border_padding = -1), "border")
  testthat::expect_error(legend_spec(grid, symbols = c(Note = "other")),
                         "invalid value")
  testthat::expect_error(legend_render(grid, 7, 1.5), "spec")
  testthat::expect_error(legend_render(legend_spec(grid), -1, 1.5),
                         "width")
})
