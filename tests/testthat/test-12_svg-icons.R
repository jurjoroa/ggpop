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
  svg <- system.file("icons", "circle-cross.svg", package = "ggpop")
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

# ******************************************************************************
# 03 icon_path, Font Awesome validation, ggpop_markers ------------------------
# ******************************************************************************

testthat::test_that("resolve_icon_source finds a user SVG via icon_path", {
  udir <- tempfile()
  dir.create(udir)
  writeLines(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><rect width="100" height="100" fill="#000000"/></svg>',
    file.path(udir, "mymark.svg")
  )
  res <- resolve_icon_source("mymark", icon_path = udir)
  testthat::expect_equal(res$type, "svg")
  testthat::expect_equal(
    normalizePath(res$path),
    normalizePath(file.path(udir, "mymark.svg"))
  )
})

testthat::test_that("icon_path also reads from the ggpop.icon_path option", {
  udir <- tempfile()
  dir.create(udir)
  writeLines(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><circle cx="50" cy="50" r="40" fill="#000000"/></svg>',
    file.path(udir, "optmark.svg")
  )
  old <- getOption("ggpop.icon_path")
  options(ggpop.icon_path = udir)
  on.exit(options(ggpop.icon_path = old), add = TRUE)
  testthat::expect_equal(resolve_icon_source("optmark")$type, "svg")
})

testthat::test_that("resolve_icon_source recognises a valid Font Awesome name", {
  testthat::expect_equal(resolve_icon_source("star")$type, "fa")
})

testthat::test_that("resolve_icon_source errors clearly on an unknown name", {
  testthat::expect_error(
    resolve_icon_source("definitely-not-an-icon-xyz"),
    "not found"
  )
})

testthat::test_that("ggpop_markers lists bundled and user markers", {
  m <- ggpop_markers()
  testthat::expect_type(m, "list")
  testthat::expect_true("square-inset" %in% m$bundled)
  testthat::expect_true("circle-cross" %in% m$bundled)

  udir <- tempfile()
  dir.create(udir)
  writeLines("<svg/>", file.path(udir, "userico.svg"))
  testthat::expect_true("userico" %in% ggpop_markers(udir)$user)
})

# ******************************************************************************
# 04 visual snapshot of every bundled marker ----------------------------------
# ******************************************************************************

testthat::test_that("all bundled SVG markers render (snapshot)", {
  testthat::skip_on_cran()
  testthat::skip_if_not_installed("ggplot2")

  markers <- ggpop_markers()$bundled
  n <- length(markers)
  ncol <- 4L

  df <- data.frame(
    icon = markers,
    x = ((seq_len(n) - 1L) %% ncol) + 1L,
    y = -((seq_len(n) - 1L) %/% ncol) * 2.0,
    stringsAsFactors = FALSE
  )

  p <- ggplot2::ggplot(df, ggplot2::aes(x = x, y = y, icon = icon, colour = icon)) +
    geom_icon_point(
      size = 5, dpi = 120, legend_icons = FALSE, show.legend = FALSE
    ) +
    ggplot2::geom_text(
      ggplot2::aes(label = icon), nudge_y = -0.95, size = 2.6, colour = "grey20"
    ) +
    ggplot2::scale_colour_viridis_d() +
    ggplot2::scale_x_continuous(expand = ggplot2::expansion(add = 0.8)) +
    ggplot2::scale_y_continuous(expand = ggplot2::expansion(add = 1)) +
    ggplot2::coord_cartesian(clip = "off") +
    ggplot2::theme_void() +
    ggplot2::theme(legend.position = "none")

  # Save a PNG snapshot so the gallery of every bundled marker can be opened
  # and eyeballed directly (under tests/testthat/_snaps/12_svg-icons/).
  path <- tempfile(fileext = ".png")
  ggplot2::ggsave(path, p, width = 8, height = 9, dpi = 120, bg = "white")
  testthat::expect_snapshot_file(path, "all-bundled-markers.png")
})
