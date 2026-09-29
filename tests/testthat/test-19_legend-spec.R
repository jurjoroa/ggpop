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

testthat::test_that("legend spec applies label_fontface to every text layer", {
  grid <- data.frame(row = 1, col = 1, icon = "square-inset", label = "A")
  spec <- legend_spec(
    grid, keys = c(One = "#08B8A2"), group_title = "Group",
    label_fontface = "bold"
  )
  plot <- legend_render(spec, width = 7, height = 1.5)
  built <- suppressWarnings(ggplot2::ggplot_build(plot))

  testthat::expect_identical(spec$label_fontface, "bold")
  testthat::expect_identical(legend_subset(spec, keys = "One")$label_fontface,
                             "bold")
  faces <- unlist(lapply(built$data, function(data) {
    if ("label" %in% names(data) && "fontface" %in% names(data)) {
      as.character(data$fontface)
    }
  }))
  testthat::expect_true(length(faces) > 0L)
  testthat::expect_true(all(faces == "bold"))
})

testthat::test_that("legend border encloses light-coloured keys", {
  grid <- data.frame(row = 1, col = 1, icon = "square-inset", label = "A")
  yellow <- "#F4C542"
  spec <- legend_spec(grid, keys = c(Advisory = yellow))
  plot <- legend_render(spec, width = 7, height = 1.5)
  built <- suppressWarnings(ggplot2::ggplot_build(plot))

  rectangles <- do.call(rbind, Filter(function(data) {
    all(c("xmin", "xmax", "fill") %in% names(data))
  }, lapply(built$data, function(data) {
    data[, intersect(c("xmin", "xmax", "fill"), names(data)), drop = FALSE]
  })))
  swatch <- rectangles[rectangles$fill %in% yellow, ]
  border <- rectangles[is.na(rectangles$fill), ]

  testthat::expect_equal(nrow(swatch), 1L)
  testthat::expect_equal(nrow(border), 1L)
  testthat::expect_lt(border$xmin, swatch$xmin)
})

testthat::test_that("symbol_title puts symbol rows on the grid rows", {
  grid <- data.frame(row = 1, col = 1, icon = "square-inset", label = "A")
  symbol_y <- function(spec) {
    built <- suppressWarnings(ggplot2::ggplot_build(
      legend_render(spec, width = 7, height = 1.5)
    ))
    data <- do.call(rbind, lapply(built$data, function(data) {
      if (all(c("label", "y") %in% names(data))) data[, c("label", "y")]
    }))
    data$y[data$label == "Frontier"]
  }
  without <- legend_spec(grid, symbols = c(Frontier = "line"))
  with_title <- legend_spec(grid, symbols = c(Frontier = "line"),
                            symbol_title = "Marks")

  testthat::expect_identical(with_title$symbol_title, "Marks")
  testthat::expect_lt(symbol_y(with_title), symbol_y(without))
  testthat::expect_error(legend_spec(grid, symbol_title = ""), "symbol_title")
  testthat::expect_identical(
    legend_subset(with_title, symbols = "Frontier")$symbol_title, "Marks"
  )
})

testthat::test_that("legend spec validates its content and dimensions", {
  grid <- data.frame(row = 1, col = 1, icon = "square-inset", label = "A")
  testthat::expect_error(legend_spec(data.frame()), "grid")
  testthat::expect_error(legend_spec(transform(grid, row = "one")), "grid")
  testthat::expect_error(legend_spec(grid, keys = "#08B8A2"), "keys")
  testthat::expect_error(legend_spec(grid, keys = c(One = "red"),
                                     key_columns = 2), "key_columns")
  testthat::expect_error(legend_spec(grid, xlim = c(1, 0)), "xlim")
  testthat::expect_error(legend_spec(grid, label_fontface = "heavy"),
                         "label_fontface")
  testthat::expect_error(legend_spec(grid, border_padding = -1), "border")
  testthat::expect_error(legend_spec(grid, symbols = c(Note = "other")),
                         "invalid value")
  testthat::expect_error(legend_render(grid, 7, 1.5), "spec")
  testthat::expect_error(legend_render(legend_spec(grid), -1, 1.5),
                         "width")
})
