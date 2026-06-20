# *****************************************************************************
#
# Script: test-12_svg-icons.R
#
# Purpose: Test custom SVG icon support (resolver, renderer, validation)
#
# Author: Jorge Roa
#
# Date Created: 20-Jun-2026
#
# *****************************************************************************
#
# Notes:
#   - Covers the internal helpers behind issue #383 in icon-utils.R:
#     resolve_icon_source() and render_svg_icon_png()
#   - Exercised by both geom_pop() and geom_icon_point()
#
# *****************************************************************************

testthat::skip_if_not_installed("rsvg")
testthat::skip_if_not_installed("magick")

# ******************************************************************************
# 01 resolve_icon_source() -----------------------------------------------------
# ******************************************************************************

testthat::test_that("resolve_icon_source classifies FA names, markers, and empty", {
  testthat::expect_equal(resolve_icon_source("male")$type, "fa")
  testthat::expect_equal(resolve_icon_source("circle")$type, "fa")

  bundled <- resolve_icon_source("square-inset")
  testthat::expect_equal(bundled$type, "svg")
  testthat::expect_true(file.exists(bundled$path))

  testthat::expect_equal(resolve_icon_source(NA)$type, "none")
  testthat::expect_equal(resolve_icon_source("")$type, "none")
})

testthat::test_that("resolve_icon_source accepts a user-supplied .svg path", {
  f <- tempfile(fileext = ".svg")
  writeLines(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><rect width="100" height="100" fill="#000000"/></svg>',
    f
  )
  res <- resolve_icon_source(f)
  testthat::expect_equal(res$type, "svg")
  testthat::expect_equal(res$path, f)
})

testthat::test_that("resolve_icon_source errors on a missing .svg path", {
  testthat::expect_error(
    resolve_icon_source("/no/such/marker.svg"),
    "not found"
  )
})

# ******************************************************************************
# 02 render_svg_icon_png() -----------------------------------------------------
# ******************************************************************************

testthat::test_that("render_svg_icon_png writes a PNG and recolours the marker", {
  svg <- system.file("icons", "circle-plus.svg", package = "ggpop")
  testthat::expect_true(nzchar(svg) && file.exists(svg))

  out <- tempfile(fileext = ".png")
  render_svg_icon_png(svg, out, "#1b9e77", 1, 120) # green

  testthat::expect_true(file.exists(out))

  a <- magick::image_data(magick::image_read(out), "rgba")
  alpha <- as.integer(a[4, , ])
  r <- as.integer(a[1, , ])
  g <- as.integer(a[2, , ])
  b <- as.integer(a[3, , ])
  opaque <- alpha > 200

  testthat::expect_true(any(opaque))
  # the marker carries the requested green, not the source black
  testthat::expect_gt(mean(g[opaque]), mean(r[opaque]))
  testthat::expect_gt(mean(g[opaque]), mean(b[opaque]))
})
