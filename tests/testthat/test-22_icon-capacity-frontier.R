testthat::test_that("capacity frontier keeps layer order and separate labels", {
  df_data <- data.frame(
    x = 1:4, y = c(100, 200, 300, 400),
    icon = c("square-inset", "circle-hollow", "diamond-solid", "plus-bold"),
    group = c("A", "B", "C", "D"),
    frontier = c(TRUE, TRUE, TRUE, FALSE),
    label = c("one", "two", "three", "four"),
    bold = c(FALSE, TRUE, FALSE, FALSE)
  )
  plot <- icon_capacity_frontier(
    df_data, x = x, y = y, icon = icon, colour = group,
    frontier = frontier, label = label, bold = bold,
    palette = c(A = "#1090F3", B = "#DF4601",
                C = "#574280", D = "#08B8A2"),
    capacity = 250,
    label_sets = list(
      list(rows = c(TRUE, FALSE, TRUE, FALSE), nudge_y = -20),
      list(rows = c(FALSE, TRUE, FALSE, FALSE), nudge_x = 0.2)
    ),
    capacity_label = "Capacity", deliverable_label = "Deliverable",
    dpi = 120
  )

  testthat::expect_s3_class(plot, "ggplot")
  testthat::expect_length(plot$layers, 8L)
  testthat::expect_equal(nrow(plot$layers[[3L]]$data), 3L)
  testthat::expect_identical(plot$layers[[5L]]$data$label,
                             c("one", "three"))
  testthat::expect_identical(plot$layers[[6L]]$data$label, "two")
  testthat::expect_identical(plot$layers[[7L]]$aes_params$label, "Capacity")
  testthat::expect_identical(plot$layers[[8L]]$aes_params$label, "Deliverable")
  testthat::expect_true(inherits(plot$layers[[1L]]$geom, "GeomRect"))
  testthat::expect_true(inherits(plot$layers[[2L]]$geom, "GeomHline"))
})

testthat::test_that("capacity frontier validates threshold and label sets", {
  df_data <- data.frame(x = 1:2, y = c(100, 200),
                        icon = c("square-inset", "circle-solid"),
                        group = c("A", "B"), frontier = c(TRUE, TRUE),
                        label = c("A", "B"), bold = c(FALSE, TRUE))
  make_plot <- function(capacity = 150, label_sets = list(list(rows = c(TRUE, FALSE))),
                        data = df_data) {
    icon_capacity_frontier(
      data, x = x, y = y, icon = icon, colour = group,
      frontier = frontier, label = label, bold = bold,
      palette = c(A = "#1090F3", B = "#DF4601"),
      capacity = capacity, label_sets = label_sets, dpi = 120
    )
  }
  testthat::expect_error(make_plot(capacity = -1), "capacity")
  testthat::expect_error(make_plot(label_sets = list()), "label_sets")
  testthat::expect_error(make_plot(label_sets = list(list(rows = TRUE))),
                         "rows")
  testthat::expect_error(make_plot(label_sets = list(list(rows = c(NA, TRUE)))),
                         "rows")
  testthat::expect_error(make_plot(label_sets = list(list(
    rows = c(TRUE, FALSE), data = df_data))), "cannot replace")
  testthat::expect_error(make_plot(data = transform(df_data, frontier = NA)),
                         "frontier")
})
