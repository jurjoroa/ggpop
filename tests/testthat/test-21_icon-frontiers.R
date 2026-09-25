testthat::test_that("icon frontiers evaluate each named dataset separately", {
  df_all <- data.frame(
    x = 1:3, y = c(1, 2, 4),
    icon = c("square-inset", "circle-solid", "diamond-cross"),
    group = c("A", "B", "C"), selected = c(TRUE, TRUE, FALSE),
    label = c("one", "two", "three"), bold = c(FALSE, TRUE, FALSE)
  )
  df_fit <- transform(df_all, y = y * 2,
                      selected = c(TRUE, FALSE, TRUE))
  plots <- icon_frontiers(
    list(all = df_all, fit = df_fit),
    x = x, y = y, icon = icon, colour = group,
    frontier = selected, label = label, bold = bold,
    palette = c(A = "#1090F3", B = "#DF4601", C = "#574280"),
    dpi = 120
  )

  testthat::expect_identical(names(plots), c("all", "fit"))
  testthat::expect_true(all(vapply(plots, inherits, logical(1), "ggplot")))
  testthat::expect_equal(vapply(plots, function(plot) {
    nrow(plot$layers[[1L]]$data)
  }, integer(1)), c(all = 2L, fit = 2L))
  testthat::expect_identical(plots$all$layers[[1L]]$data$label,
                             c("one", "two"))
  testthat::expect_identical(plots$fit$layers[[1L]]$data$label,
                             c("one", "three"))

  built_all <- suppressWarnings(ggplot2::ggplot_build(plots$all))
  built_fit <- suppressWarnings(ggplot2::ggplot_build(plots$fit))
  testthat::expect_equal(built_all$data[[3L]]$x, c(1.024, 2.024))
  testthat::expect_equal(built_all$data[[3L]]$y, c(0.946, 1.946))
  testthat::expect_identical(built_all$data[[3L]]$fontface,
                             c("plain", "bold"))
  testthat::expect_equal(built_fit$data[[3L]]$y, c(1.892, 7.892))
})

testthat::test_that("icon frontiers validate data and style inputs", {
  df_data <- data.frame(x = 1, y = 2, icon = "square-inset",
                        group = "A", selected = TRUE, label = "A", bold = FALSE)
  make_plot <- function(data = list(a = df_data),
                        palette = c(A = "#1090F3"),
                        label_nudge = c(0.012, -0.018)) {
    icon_frontiers(data, x = x, y = y, icon = icon, colour = group,
                   frontier = selected, label = label, bold = bold,
                   palette = palette, label_nudge = label_nudge, dpi = 120)
  }
  testthat::expect_error(make_plot(list(df_data)), "named")
  testthat::expect_error(make_plot(list(a = df_data[0, ])), "must have rows")
  testthat::expect_error(make_plot(palette = "#1090F3"), "palette")
  testthat::expect_error(make_plot(label_nudge = 0.1), "label_nudge")
  testthat::expect_error(make_plot(list(a = transform(df_data,
                                                      selected = NA))),
                         "frontier")
  testthat::expect_error(make_plot(list(a = transform(df_data, x = "one"))),
                         "numeric")
})
