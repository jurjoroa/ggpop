testthat::test_that("sda2028 scheme matches all screening markers", {
  start <- rep(c(45, 50, 55), each = 4)
  stop <- rep(c(70, 75, 80, 85), times = 3)
  expected <- c(
    "square-inset", "square-hollow", "square-cross", "square-solid",
    "circle-inset", "circle-hollow", "circle-cross", "circle-solid",
    "diamond-inset", "diamond-hollow", "diamond-cross", "diamond-solid"
  )
  testthat::expect_identical(marker_encode(start, stop), expected)
  testthat::expect_true(all(c(expected, "plus-bold", "triangle-down") %in%
                            ggpop_markers()$bundled))

  testthat::expect_identical(
    marker_encode(c(45, 50, 55, 60, 65), rep(NA, 5), once = TRUE),
    c("square-solid", "circle-solid", "diamond-solid", "plus-bold",
      "triangle-down")
  )
  testthat::expect_identical(
    marker_encode(c(45, 50, NA), c(70, 85, NA),
                  none = c(FALSE, FALSE, TRUE)),
    c("square-inset", "circle-solid", "circle-solid")
  )
})

testthat::test_that("custom schemes and scalar inputs work", {
  scheme <- list(
    start = c(A = "square", B = "circle"),
    stop = c(X = "cross"),
    once = c(A = "plus-bold"),
    none = "diamond-solid"
  )
  testthat::expect_identical(
    marker_encode(factor(c("A", "B")), "X", scheme = scheme),
    c("square-cross", "circle-cross")
  )
  testthat::expect_identical(
    marker_encode(c("A", NA), c(NA, NA), once = c(TRUE, FALSE),
                  none = c(FALSE, TRUE), scheme = scheme),
    c("plus-bold", "diamond-solid")
  )
  testthat::expect_identical(
    marker_encode("A", "X", none = c(FALSE, TRUE), scheme = scheme),
    c("square-cross", "diamond-solid")
  )
  testthat::expect_identical(marker_encode(character(), character()), character())
})

testthat::test_that("marker_encode rejects invalid input and schemes", {
  testthat::expect_error(marker_encode(40, 70), "Unsupported.*start")
  testthat::expect_error(marker_encode(45, 90), "Unsupported.*stop")
  testthat::expect_error(marker_encode(70, NA, once = TRUE), "one-time")
  testthat::expect_error(marker_encode(45:46, 70:72), "length 1 or 3")
  testthat::expect_error(marker_encode(45, 70, once = NA), "logical")
  testthat::expect_error(marker_encode(45, 70, once = TRUE, none = TRUE),
                         "cannot both be TRUE")
  testthat::expect_error(marker_encode(45, 70, scheme = "unknown"),
                         "scheme")
  testthat::expect_error(
    marker_encode(45, 70, scheme = list(start = c(`45` = "square"))),
    "scheme"
  )
})
