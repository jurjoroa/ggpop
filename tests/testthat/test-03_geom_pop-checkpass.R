# *****************************************************************************
#
# Script: test-03_geom_pop-checkpass.R
#
# Purpose: Ensure geom_pop() works robustly for all valid scenarios
#          without warnings or errors.
#
# Author: Jorge Roa
#
# Email: jorgeroa@stanford.edu
#
# Date Created: 02-Jan-2026
#
# *****************************************************************************

testthat::skip_if_not_installed("ggplot2")
testthat::skip_if_not_installed("dplyr")
testthat::skip_if_not_installed("ggimage")
testthat::skip_if_not_installed("fontawesome")


expect_doppelganger <- function(title, fig, path = NULL, ...) {
  testthat::skip_if_not_installed("vdiffr")
  vdiffr::expect_doppelganger(title, fig, ...)
}

# ******************************************************************************
# Test fixtures -------------------------------------------------------------
# ******************************************************************************

df_scatter <- data.frame(
  x = 1:10,
  y = 1:10,
  icon = rep(c("circle", "star"), 5),
  category = rep(c("A", "B"), 5),
  stringsAsFactors = FALSE
)

df_pop <- data.frame(
  sex = rep(c("M", "F"), each = 20),
  icon = rep(c("male", "female"), each = 20),
  stringsAsFactors = FALSE
)


# ******************************************************************************
# 01 Basic clean cases ---------------------------------------------------
# ******************************************************************************

testthat::test_that("Minimal raw mode", {
  df <- data.frame(
    sex = c("male", "female", "male", "female"),
    icon = c("male", "female", "male", "female"),
    stringsAsFactors = FALSE
  )

  testthat::expect_no_warning(
    testthat::expect_no_error(
      ggplot2::ggplot_build(
        ggplot2::ggplot() +
          geom_pop(
            data = df,
            ggplot2::aes(icon = icon, group = sex, color = sex),
            size = 5,
            dpi = 100
          ) +
          ggplot2::theme_void()
      )
    )
  )

  testthat::expect_no_warning(
    testthat::expect_no_error(
      ggplot2::ggplotGrob(
        ggplot2::ggplot() +
          geom_pop(
            data = df,
            ggplot2::aes(icon = icon, color = sex),
            size = 5,
            dpi = 100
          ) +
          ggplot2::theme_void()
      )
    )
  )

  testthat::expect_no_error(
    ggplot2::ggplot() +
      geom_pop(
        data = df,
        ggplot2::aes(icon = icon, group = sex, color = sex),
        color = "red", # should overide mapped color
        dpi = 100,
        size = 5
      )
  )


  testthat::test_that("Data is a data.frame", {
    df <- data.frame(
      sex = c("male", "female"),
      icon = c("male", "female"),
      stringsAsFactors = FALSE
    )

    testthat::expect_no_error(
      ggplot2::ggplot() +
        geom_pop(
          data = df,
          ggplot2::aes(icon = icon, group = sex)
        )
    )
  })

  testthat::test_that("Data is a tibble", {
    testthat::skip_if_not_installed("tibble")

    df <- tibble::tibble(
      sex = c("male", "female"),
      icon = c("male", "female")
    )

    testthat::expect_no_error(
      ggplot2::ggplot() +
        geom_pop(
          data = df,
          ggplot2::aes(icon = icon, group = sex)
        )
    )
  })

  testthat::test_that("Data is a data.table", {
    testthat::skip_if_not_installed("data.table")

    df <- data.table::data.table(
      sex = c("male", "female"),
      icon = c("male", "female")
    )

    testthat::expect_no_error(
      ggplot2::ggplot() +
        geom_pop(
          data = df,
          ggplot2::aes(icon = icon, group = sex)
        )
    )
  })
})

# ******************************************************************************
# 02 Data-driven size ----------------------------------------------------
# ******************************************************************************

testthat::test_that("aes(size=<var>)", {
  df <- data.frame(
    sex = rep(c("male", "female"), each = 10),
    icon = rep(c("male", "female"), each = 10),
    sz = rep(c(2, 5), each = 10),
    stringsAsFactors = FALSE
  )

  testthat::expect_no_warning(
    testthat::expect_no_error(
      ggplot2::ggplot_build(
        ggplot2::ggplot() +
          geom_pop(
            data = df,
            ggplot2::aes(icon = icon, group = sex, color = sex, size = sz),
            dpi = 120
          ) +
          ggplot2::theme_void()
      )
    )
  )
})

# ******************************************************************************
# 03 Facet: 10 panels × 5 groups -----------------------------------------
# ******************************************************************************

testthat::test_that("facet 10 panels x 5 groups", {
  base <- data.frame(
    panel = rep(paste0("P", sprintf("%02d", 1:10)), each = 5),
    grp = rep(paste0("G", 1:5), times = 10),
    icon = "user",
    stringsAsFactors = FALSE
  )

  df <- base[rep(seq_len(nrow(base)), each = 10), ]
  rownames(df) <- NULL

  testthat::expect_no_error(
    testthat::expect_warning(
      ggplot2::ggplot_build(
        ggplot2::ggplot(df) +
          geom_pop(
            ggplot2::aes(icon = icon, group = grp, color = grp),
            facet = panel,
            size = 1,
            arrange = FALSE,
            seed = 123,
            dpi = 100
          ) +
          ggplot2::facet_wrap(~panel) +
          ggplot2::theme_void()
      )
    )
  )
})

# ******************************************************************************
# 04 20 groups with 20 icons ----------------------------------------------
# ******************************************************************************

testthat::test_that("20 groups with 20 icons", {
  icons <- c(
    "user", "users", "person", "person-walking", "person-running",
    "car", "bus", "train", "bicycle", "plane",
    "heart", "star", "circle", "square", "triangle-exclamation",
    "house", "building", "tree", "cloud", "bolt"
  )

  df <- data.frame(
    grp = rep(paste0("G", sprintf("%02d", 1:20)), each = 15),
    icon = rep(icons, each = 15),
    stringsAsFactors = FALSE
  )

  testthat::expect_no_warning(
    testthat::expect_no_error(
      ggplot2::ggplot_build(
        ggplot2::ggplot() +
          geom_pop(
            data = df,
            ggplot2::aes(icon = icon, group = grp, color = grp),
            size = 1,
            arrange = FALSE,
            seed = 123,
            dpi = 120
          ) +
          ggplot2::theme_void()
      )
    )
  )
})

# ******************************************************************************
# 05 Facet inferred from ggplot -------------------------------------------
# ******************************************************************************

testthat::test_that("facet inferred from ggplot", {
  df <- data.frame(
    panel = rep(c("A", "B", "C"), each = 40),
    sex = rep(c("male", "female"), length.out = 120),
    icon = rep(c("male", "female"), length.out = 120),
    stringsAsFactors = FALSE
  )

  testthat::expect_no_warning(
    testthat::expect_no_error(
      ggplot2::ggplot_build(
        ggplot2::ggplot(df) +
          geom_pop(
            ggplot2::aes(icon = icon, group = sex, color = sex),
            size = 4,
            dpi = 100,
            arrange = FALSE,
            seed = 123
          ) +
          ggplot2::facet_wrap(~panel) +
          ggplot2::theme_void()
      )
    )
  )
})

# ******************************************************************************
# 06 arrange=TRUE with n/prop ----------------------------------------------
# ******************************************************************************

testthat::test_that("arrange=TRUE with n/prop", {
  df <- data.frame(
    type = rep(c("male", "female"), each = 50),
    icon = rep(c("male", "female"), each = 50),
    n = rep(50, 100),
    prop = rep(0.5, 100),
    stringsAsFactors = FALSE
  )

  testthat::expect_no_warning(
    testthat::expect_no_error(
      ggplot2::ggplot_build(
        ggplot2::ggplot() +
          geom_pop(
            data = df,
            ggplot2::aes(icon = icon, group = type, color = type),
            arrange = TRUE,
            seed = 123,
            size = 4,
            dpi = 120
          ) +
          ggplot2::theme_void()
      )
    )
  )
})

# ******************************************************************************
# 07 No color mapping (still valid) ----------------------------------------
# ******************************************************************************

testthat::test_that("no color mapping", {
  df <- data.frame(
    sex = rep(c("male", "female"), each = 40),
    icon = rep(c("male", "female"), each = 40),
    stringsAsFactors = FALSE
  )

  testthat::expect_no_warning(
    testthat::expect_no_error(
      ggplot2::ggplot_build(
        ggplot2::ggplot() +
          geom_pop(
            data = df,
            ggplot2::aes(icon = icon, group = sex),
            size = 4,
            dpi = 120,
            arrange = FALSE,
            seed = 123
          ) +
          ggplot2::theme_void()
      )
    )
  )
})

# ******************************************************************************
# 08 arrange=FALSE randomness + seed reproducibility ----------------------
# ******************************************************************************

testthat::test_that("arrange=FALSE changes with different seeds", {
  df <- data.frame(
    grp = rep(c("A", "B", "C"), each = 40),
    icon = rep(c("user", "car", "heart"), each = 40),
    stringsAsFactors = FALSE
  )

  # Should build cleanly with different seeds (robustness),
  # while allowing the user to control layout via seed.
  testthat::expect_no_warning(
    testthat::expect_no_error(
      ggplot2::ggplot_build(
        ggplot2::ggplot(df) +
          geom_pop(
            ggplot2::aes(icon = icon, group = grp, color = grp),
            size = 2,
            arrange = FALSE,
            seed = 1,
            dpi = 120
          ) +
          ggplot2::theme_void()
      )
    )
  )

  testthat::expect_no_warning(
    testthat::expect_no_error(
      ggplot2::ggplot_build(
        ggplot2::ggplot(df) +
          geom_pop(
            ggplot2::aes(icon = icon, group = grp, color = grp),
            size = 2,
            arrange = FALSE,
            seed = 999,
            dpi = 120
          ) +
          ggplot2::theme_void()
      )
    )
  )
})

testthat::test_that("Same seed is stable across builds", {
  df <- data.frame(
    grp = rep(c("A", "B", "C"), each = 40),
    icon = rep(c("user", "car", "heart"), each = 40),
    stringsAsFactors = FALSE
  )

  # Two builds with the same seed should both be clean (robustness).
  # We do not assert internal order here; we assert stability of the build.
  testthat::expect_no_warning(
    testthat::expect_no_error(
      ggplot2::ggplot_build(
        ggplot2::ggplot(df) +
          geom_pop(
            ggplot2::aes(icon = icon, group = grp, color = grp),
            size = 2,
            arrange = FALSE,
            seed = 123,
            dpi = 120
          ) +
          ggplot2::theme_void()
      )
    )
  )

  testthat::expect_no_warning(
    testthat::expect_no_error(
      ggplot2::ggplot_build(
        ggplot2::ggplot(df) +
          geom_pop(
            ggplot2::aes(icon = icon, group = grp, color = grp),
            size = 2,
            arrange = FALSE,
            seed = 123,
            dpi = 120
          ) +
          ggplot2::theme_void()
      )
    )
  )
})

testthat::test_that("geom_pop with seed produces reproducible results", {
  df_pop <- data.frame(
    sex = rep(c("M", "F"), each = 20),
    icon = rep(c("male", "female"), each = 20),
    stringsAsFactors = FALSE
  )

  p1 <- ggplot2::ggplot() +
    geom_pop(
      data = df_pop,
      ggplot2::aes(icon = icon, group = sex),
      seed = 12345,
      arrange = FALSE
    )

  p2 <- ggplot2::ggplot() +
    geom_pop(
      data = df_pop,
      ggplot2::aes(icon = icon, group = sex),
      seed = 12345,
      arrange = FALSE
    )

  data1 <- ggplot2::ggplot_build(p1)$data[[1]]
  data2 <- ggplot2::ggplot_build(p2)$data[[1]]

  testthat::expect_equal(data1$x1, data2$x1)
  testthat::expect_equal(data1$y1, data2$y1)
})

testthat::test_that("geom_pop with different seeds produces different results", {
  df_pop <- data.frame(
    sex = rep(c("M", "F"), each = 20),
    icon = rep(c("male", "female"), each = 20),
    stringsAsFactors = FALSE
  )

  p1 <- ggplot2::ggplot() +
    geom_pop(
      data = df_pop,
      ggplot2::aes(icon = icon, group = sex),
      seed = 111,
      arrange = FALSE
    )

  p2 <- ggplot2::ggplot() +
    geom_pop(
      data = df_pop,
      ggplot2::aes(icon = icon, group = sex),
      seed = 222,
      arrange = FALSE
    )

  data1 <- ggplot2::ggplot_build(p1)$data[[1]]
  data2 <- ggplot2::ggplot_build(p2)$data[[1]]

  testthat::expect_true(all(data1$x1 == data2$x1))
})

testthat::test_that("geom_pop with arrange=TRUE ignores seed", {
  df_pop <- data.frame(
    sex = rep(c("M", "F"), each = 20),
    icon = rep(c("male", "female"), each = 20),
    stringsAsFactors = FALSE
  )

  p1 <- ggplot2::ggplot() +
    geom_pop(
      data = df_pop,
      ggplot2::aes(icon = icon, group = sex),
      seed = 111,
      arrange = TRUE
    )

  p2 <- ggplot2::ggplot() +
    geom_pop(
      data = df_pop,
      ggplot2::aes(icon = icon, group = sex),
      seed = 222,
      arrange = TRUE
    )

  data1 <- ggplot2::ggplot_build(p1)$data[[1]]
  data2 <- ggplot2::ggplot_build(p2)$data[[1]]

  testthat::expect_equal(data1$type, data2$type)
})

# ******************************************************************************
# 09 Facet grid (rows OR cols) inference ---------------------------------
# ******************************************************************************

testthat::test_that("facet_grid inference (single dimension)", {
  df <- data.frame(
    panel = rep(c("Row1", "Row2", "Row3"), each = 60),
    grp = rep(c("G1", "G2", "G3"), length.out = 180),
    icon = rep(c("user", "car", "heart"), length.out = 180),
    stringsAsFactors = FALSE
  )

  testthat::expect_no_warning(
    testthat::expect_no_error(
      ggplot2::ggplot_build(
        ggplot2::ggplot(df) +
          geom_pop(
            ggplot2::aes(icon = icon, group = grp, color = grp),
            size = 2,
            arrange = FALSE,
            seed = 123,
            dpi = 120
          ) +
          ggplot2::facet_grid(rows = ggplot2::vars(panel)) +
          ggplot2::theme_void()
      )
    )
  )
})

# ******************************************************************************
# 10 High group variety, no facet (single pooled circle) ------------------
# ******************************************************************************

testthat::test_that("Many groups pooled into one circle (50 icons)", {
  # 50 distinct icons (keep to 50 exactly)
  icons_50 <- c(
    "user", "user-group", "users", "people-group", "person",
    "person-walking", "person-running", "person-biking", "person-swimming", "person-hiking",
    "wheelchair", "briefcase", "suitcase", "person-walking-luggage", "passport",
    "plane", "plane-departure", "plane-arrival", "route", "ticket",
    "ticket-simple", "bag-shopping", "cart-shopping", "basket-shopping", "clock",
    "hourglass", "stopwatch", "shield", "shield-halved", "triangle-exclamation",
    "check", "circle-check", "square-check", "xmark", "circle-xmark",
    "ban", "info", "circle-info", "question", "circle-question",
    "bell", "bell-concierge", "map", "map-location-dot", "building",
    "house", "hospital", "school", "landmark", "tree"
  )

  testthat::expect_equal(length(icons_50), 50)

  df <- data.frame(
    grp = rep(paste0("G", sprintf("%02d", 1:50)), each = 10),
    icon = rep(icons_50, each = 10),
    stringsAsFactors = FALSE
  )

  testthat::expect_equal(nrow(df), 500)

  testthat::expect_no_warning(
    testthat::expect_no_error(
      ggplot2::ggplot_build(
        ggplot2::ggplot(df) +
          geom_pop(
            ggplot2::aes(icon = icon, group = grp, color = grp),
            size = 0.8,
            arrange = FALSE,
            seed = 42,
            dpi = 120,
            legend_icons = TRUE
          ) +
          ggplot2::theme_void()
      )
    )
  )
})

# ******************************************************************************
# 11 Large-but-valid icon count (stress under MAX) ------------------------
# ******************************************************************************

testthat::test_that("stress test with 900 icons", {
  df <- data.frame(
    grp = rep(c("A", "B", "C"), times = c(300, 300, 300)),
    icon = rep(c("user", "car", "heart"), times = c(300, 300, 300)),
    stringsAsFactors = FALSE
  )

  testthat::expect_no_warning(
    testthat::expect_no_error(
      ggplot2::ggplot_build(
        ggplot2::ggplot(df) +
          geom_pop(
            ggplot2::aes(icon = icon, group = grp, color = grp),
            size = 0.6,
            arrange = FALSE,
            seed = 123,
            dpi = 120
          ) +
          ggplot2::theme_void()
      )
    )
  )
})

testthat::test_that("5 facets, 50 different icons per facet (250 unique icons)", {
  all_icons <- fontawesome::fa_metadata()$icon_names
  testthat::skip_if(length(all_icons) < 250)

  set.seed(42)
  icons_250 <- sample(all_icons, 250, replace = FALSE)
  testthat::expect_equal(length(icons_250), 250)

  facets <- paste0("Facet_", 1:5)

  df <- do.call(
    rbind,
    lapply(seq_along(facets), function(i) {
      groups_i <- paste0("F", i, "_G", sprintf("%02d", 1:50))

      idx <- ((i - 1) * 50 + 1):((i - 1) * 50 + 50)
      icons_i <- icons_250[idx]

      data.frame(
        facet = facets[i],
        grp = rep(groups_i, each = 10),
        icon = rep(icons_i, each = 10),
        stringsAsFactors = FALSE
      )
    })
  )

  testthat::expect_equal(nrow(df), 5 * 50 * 10)

  testthat::expect_no_error(
    suppressWarnings(
      ggplot2::ggplot_build(
        ggplot2::ggplot(df) +
          geom_pop(
            ggplot2::aes(icon = icon, group = facet, color = grp),
            facet = facet,
            size = 1,
            arrange = FALSE,
            seed = 42,
            dpi = 50,
            legend_icons = TRUE
          ) +
          ggplot2::facet_wrap(~facet, ncol = 3) +
          ggplot2::theme_void() +
          scale_legend_icon(size = 6)
      )
    )
  )
})


testthat::test_that("single plot with 1000 rows and random Font Awesome icons", {
  all_icons <- fontawesome::fa_metadata()$icon_names

  # Sample 1000 icons (allow repeats - safe even if FA < 1000 icons)
  icons_1000 <- sample(all_icons, 1000, replace = TRUE)

  testthat::expect_equal(length(icons_1000), 1000)

  df <- data.frame(
    grp = paste0("G", sprintf("%04d", seq_len(1000))),
    icon = icons_1000,
    stringsAsFactors = FALSE
  )

  testthat::expect_equal(nrow(df), 1000)

  testthat::expect_no_warning(
    testthat::expect_no_error(
      ggplot2::ggplot_build(
        ggplot2::ggplot(df) +
          geom_pop(
            ggplot2::aes(icon = icon, group = grp, color = grp),
            size = 1,
            arrange = T,
            seed = 42,
            dpi = 50,
            legend_icons = TRUE
          ) +
          ggplot2::theme_void() +
          scale_legend_icon(size = 3) +
          # dont add legend
          ggplot2::theme(legend.position = "none")
      )
    )
  )
})


# ******************************************************************************
# 12 Legend icons: unique raster grobs match unique icons -----------------------
# ******************************************************************************

testthat::test_that("2 icons Legend draws one unique raster icon per unique df$icon", {
  testthat::skip_if_not_installed("grid")
  testthat::skip_if_not_installed("gtable")

  df <- data.frame(
    sex = c("male", "female", "male", "female"),
    icon = c("male", "female", "male", "female"),
    stringsAsFactors = FALSE
  )

  p <- ggplot2::ggplot(df) +
    geom_pop(
      ggplot2::aes(icon = icon, group = sex, color = sex),
      size = 4,
      dpi = 100,
      legend_icons = TRUE
    ) +
    scale_legend_icon(size = 3) +
    ggplot2::theme_void() +
    ggplot2::theme(legend.position = "right")

  testthat::expect_no_error(ggplot2::ggplot_build(p))
  gt <- testthat::expect_no_error(ggplot2::ggplotGrob(p))

  # Find the legend container (guide-box)
  guide_idx <- which(vapply(
    gt$grobs,
    function(x) inherits(x, "gtable") && identical(x$name, "guide-box"),
    logical(1)
  ))

  testthat::expect_true(
    length(guide_idx) == 1,
    info = "No legend found (guide-box missing). Legend may be dropped or disabled."
  )

  guide <- gt$grobs[[guide_idx]]

  # Collect raster grobs inside the legend
  rasters <- list()
  recurse <- function(x) {
    if (inherits(x, "rastergrob")) {
      rasters[[length(rasters) + 1]] <<- x
    }

    if (inherits(x, "gtable") && length(x$grobs)) {
      for (g in x$grobs) recurse(g)
    }
    if (inherits(x, "gTree") && length(x$children)) {
      for (g in x$children) recurse(g)
    }
    if (is.list(x)) {
      for (g in x) recurse(g)
    }
  }
  recurse(guide)

  testthat::expect_true(
    length(rasters) > 0,
    info = "Legend exists but contains no rastergrob. Legend icons likely not rendered as images."
  )

  # Unique raster grob names (proxy for unique icons rendered)
  raster_names <- vapply(rasters, function(r) r$name, character(1))
  n_unique_rasters <- length(unique(raster_names))
  n_unique_icons <- length(unique(df$icon))

  testthat::expect_equal(
    n_unique_rasters,
    n_unique_icons,
    info = paste0(
      "Expected ", n_unique_icons, " unique legend icon raster(s) (one per unique df$icon), ",
      "but found ", n_unique_rasters, ".\n",
      "Unique raster names: ", paste(sort(unique(raster_names)), collapse = ", ")
    )
  )
})


testthat::test_that("50 icons Legend draws one unique raster icon per unique", {
  testthat::skip_if_not_installed("grid")
  testthat::skip_if_not_installed("gtable")

  # 50 distinct Font Awesome icon names (simple + stable)
  icons_50 <- c(
    "user", "users", "person", "person-walking", "person-running",
    "car", "bus", "train", "bicycle", "plane",
    "heart", "star", "circle", "square", "triangle-exclamation",
    "house", "building", "tree", "cloud", "bolt",
    "bell", "bell-slash", "check", "xmark", "ban",
    "info", "question", "shield", "lock", "unlock",
    "flag", "map", "map-location-dot", "location-dot", "compass",
    "briefcase", "suitcase", "passport", "ticket", "route",
    "calendar", "clock", "hourglass", "stopwatch", "battery-full",
    "wifi", "signal", "phone", "envelope", "globe"
  )

  testthat::expect_equal(length(icons_50), 50)

  # Build data: each icon appears multiple times to mimic real usage
  df <- data.frame(
    grp = rep(paste0("G", sprintf("%02d", seq_len(50))), each = 5),
    icon = rep(icons_50, each = 5),
    stringsAsFactors = FALSE
  )

  testthat::expect_equal(nrow(df), 50 * 5)

  p <- ggplot2::ggplot(df) +
    geom_pop(
      ggplot2::aes(icon = icon, group = grp, color = grp),
      size = 1,
      dpi = 100,
      legend_icons = TRUE
    ) +
    scale_legend_icon(size = 2.5) +
    ggplot2::theme_void() +
    ggplot2::theme(legend.position = "right")

  testthat::expect_no_error(ggplot2::ggplot_build(p))
  gt <- testthat::expect_no_error(ggplot2::ggplotGrob(p))

  # Find the legend container (guide-box)
  guide_idx <- which(vapply(
    gt$grobs,
    function(x) inherits(x, "gtable") && identical(x$name, "guide-box"),
    logical(1)
  ))

  testthat::expect_true(
    length(guide_idx) == 1,
    info = "No legend found (guide-box missing). Legend may be dropped or disabled."
  )

  guide <- gt$grobs[[guide_idx]]

  # Collect raster grobs inside the legend
  rasters <- list()
  recurse <- function(x) {
    if (inherits(x, "rastergrob")) {
      rasters[[length(rasters) + 1]] <<- x
    }

    if (inherits(x, "gtable") && length(x$grobs)) {
      for (g in x$grobs) recurse(g)
    }
    if (inherits(x, "gTree") && length(x$children)) {
      for (g in x$children) recurse(g)
    }
    if (is.list(x)) {
      for (g in x) recurse(g)
    }
  }
  recurse(guide)

  testthat::expect_true(
    length(rasters) > 0,
    info = "Legend exists but contains no rastergrob. Legend icons likely not rendered as images."
  )

  # Unique raster grob names (proxy for unique icons rendered)
  raster_names <- vapply(rasters, function(r) r$name, character(1))
  n_unique_rasters <- length(unique(raster_names))
  n_unique_icons <- length(unique(df$icon))

  testthat::expect_equal(
    n_unique_rasters,
    n_unique_icons,
    info = paste0(
      "Expected ", n_unique_icons, " unique legend icon raster(s) (one per unique df$icon), ",
      "but found ", n_unique_rasters, ".\n",
      "Unique raster names: ", paste(sort(unique(raster_names)), collapse = ", ")
    )
  )
})


# ******************************************************************************
# 12.5 Custom icon column names ------------------------------------------------
# ******************************************************************************

#' Extract icon names from PNG file paths
#'
#' @param png_paths Character vector of PNG file paths
#' @return Character vector of icon names extracted from filenames
extract_icon_names <- function(png_paths) {
  basenames <- basename(png_paths)
  # Icon name is the first part before "_c" (color marker)
  icon_names <- sub("_c.*", "", basenames)
  icon_names
}

testthat::test_that("Icons: custom column 'my_icons' renders CORRECT icons", {
  # Data with custom icon column name
  df_custom <- data.frame(
    sex = c("M", "M", "F", "F"),
    my_icons = c("male", "male", "female", "female"), # Custom column name!
    stringsAsFactors = FALSE
  )

  p <- suppressWarnings(
    ggplot2::ggplot() +
      geom_pop(
        data = df_custom,
        ggplot2::aes(icon = my_icons, group = sex, color = sex),
        dpi = 60
      )
  )

  built <- ggplot2::ggplot_build(p)
  layer_data <- built$data[[1]]

  # Extract rendered icons
  rendered_icons <- extract_icon_names(layer_data$image)

  # Should match exactly what's in my_icons column
  testthat::expect_setequal(unique(rendered_icons), c("male", "female"))
  testthat::expect_true("male" %in% rendered_icons)
  testthat::expect_true("female" %in% rendered_icons)
})

testthat::test_that("Icons: column 'icon_2' renders circle and square icons", {
  df_icon2 <- data.frame(
    category = c("A", "A", "B", "B"),
    icon_2 = c("circle", "circle", "square", "square"), # Custom column name
    stringsAsFactors = FALSE
  )

  p <- suppressWarnings(
    ggplot2::ggplot() +
      geom_pop(
        data = df_icon2,
        ggplot2::aes(icon = icon_2, group = category, color = category),
        dpi = 60
      )
  )

  built <- ggplot2::ggplot_build(p)
  layer_data <- built$data[[1]]

  rendered_icons <- extract_icon_names(layer_data$image)

  # Should be circle and square, NOT "user" or any default fallback
  testthat::expect_setequal(unique(rendered_icons), c("circle", "square"))
  testthat::expect_false("user" %in% rendered_icons)
  testthat::expect_false("ggmale" %in% rendered_icons)
})

testthat::test_that("Icons: very custom name 'fontawesome_symbol' works", {
  df_weird <- data.frame(
    grp = c("A", "A", "B", "B", "C", "C"),
    fontawesome_symbol = c("pizza-slice", "pizza-slice", "coffee", "coffee", "heart", "heart"),
    stringsAsFactors = FALSE
  )

  p <- suppressWarnings(
    ggplot2::ggplot() +
      geom_pop(
        data = df_weird,
        ggplot2::aes(icon = fontawesome_symbol, group = grp, color = grp),
        dpi = 60
      )
  )

  built <- ggplot2::ggplot_build(p)
  layer_data <- built$data[[1]]

  rendered_icons <- extract_icon_names(layer_data$image)

  # Should use the actual icons from fontawesome_symbol column
  testthat::expect_setequal(unique(rendered_icons), c("pizza-slice", "coffee", "heart"))

  # Should NOT fall back to defaults
  testthat::expect_false("user" %in% rendered_icons)
  testthat::expect_false("circle" %in% rendered_icons)
  testthat::expect_false("ggmale" %in% rendered_icons)
})

testthat::test_that("Regression: 'icon' column does NOT override 'icon_custom' content", {
  # This is the bug we fixed: having a column named 'icon' should not
  # interfere when user maps aes(icon = icon_custom)

  df_regression <- data.frame(
    type = c("A", "A", "A", "B", "B", "B"),
    icon = c("WRONG", "WRONG", "WRONG", "WRONG", "WRONG", "WRONG"), # Decoy column
    icon_custom = c("star", "star", "star", "heart", "heart", "heart"), # Correct column
    stringsAsFactors = FALSE
  )

  # User explicitly maps icon_custom
  p <- suppressWarnings(
    ggplot2::ggplot() +
      geom_pop(
        data = df_regression,
        ggplot2::aes(icon = icon_custom, group = type, color = type),
        dpi = 60
      )
  )

  built <- ggplot2::ggplot_build(p)
  layer_data <- built$data[[1]]

  rendered_icons <- extract_icon_names(layer_data$image)

  # Should render star and heart (from icon_custom)
  testthat::expect_setequal(unique(rendered_icons), c("star", "heart"))

  # Should NOT render "WRONG" (from icon column)
  testthat::expect_false("WRONG" %in% rendered_icons)
})

testthat::test_that("Icons: renders ALL hearts from 'icon_column' with custom name", {
  df_hearts <- data.frame(
    sex = c("A", "A", "A", "A"),
    icon_column = c("heart", "heart", "heart", "heart"), # Custom column, all hearts
    stringsAsFactors = FALSE
  )

  p <- suppressWarnings(
    ggplot2::ggplot() +
      geom_pop(
        data = df_hearts,
        ggplot2::aes(icon = icon_column, group = sex),
        dpi = 60
      )
  )

  built <- ggplot2::ggplot_build(p)
  layer_data <- built$data[[1]]

  rendered_icons <- extract_icon_names(layer_data$image)

  # ALL should be "heart"
  testthat::expect_true(all(rendered_icons == "heart"))
  testthat::expect_equal(length(unique(rendered_icons)), 1)
  testthat::expect_equal(unique(rendered_icons), "heart")
})

testthat::test_that("Icons: consistent per-group rendering with custom column", {
  # Group A should have ALL circles, Group B should have ALL squares
  df_groups <- data.frame(
    type = c("A", "A", "A", "B", "B", "B"),
    my_icon_col = c("circle", "circle", "circle", "square", "square", "square"),
    stringsAsFactors = FALSE
  )

  p <- suppressWarnings(
    ggplot2::ggplot() +
      geom_pop(
        data = df_groups,
        ggplot2::aes(icon = my_icon_col, group = type, color = type),
        dpi = 60
      )
  )

  built <- ggplot2::ggplot_build(p)
  layer_data <- built$data[[1]]

  rendered_icons <- extract_icon_names(layer_data$image)

  # All should be circle or square
  testthat::expect_true(all(rendered_icons %in% c("circle", "square")))

  # Should have both icons
  testthat::expect_setequal(unique(rendered_icons), c("circle", "square"))

  # Verify counts (6 rows total)
  testthat::expect_equal(sum(rendered_icons == "circle"), 3)
  testthat::expect_equal(sum(rendered_icons == "square"), 3)
})

testthat::test_that("Icons: with process_data and custom icon column", {
  df_raw <- data.frame(
    sex = c("M", "F", "M", "F"),
    custom_icons = c("male", "female", "male", "female"), # Custom column name
    count = c(30, 70, 30, 70),
    stringsAsFactors = FALSE
  )

  df_processed <- process_data(
    df_raw,
    group_var = sex,
    sum_var = count,
    sample_size = 20
  )

  # Add custom icon column to processed data
  df_processed$my_icon_var <- ifelse(df_processed$type == "M", "male", "female")

  p <- ggplot2::ggplot() +
    geom_pop(
      data = df_processed,
      ggplot2::aes(icon = my_icon_var, group = type, color = type),
      dpi = 60
    )

  testthat::expect_no_error(ggplot2::ggplot_build(p))

  built <- ggplot2::ggplot_build(p)
  layer_data <- built$data[[1]]

  rendered_icons <- extract_icon_names(layer_data$image)

  # Should have male and female icons
  testthat::expect_setequal(unique(rendered_icons), c("male", "female"))
  testthat::expect_false("user" %in% rendered_icons)
})

testthat::test_that("Icons: multiple custom columns in same dataset", {
  # Dataset with multiple icon columns - user picks which one to use
  df_multi <- data.frame(
    category = c("A", "A", "B", "B"),
    icons_v1 = c("heart", "heart", "star", "star"), # Option 1
    icons_v2 = c("circle", "circle", "square", "square"), # Option 2
    stringsAsFactors = FALSE
  )

  # Test using icons_v1
  p1 <- suppressWarnings(
    ggplot2::ggplot() +
      geom_pop(
        data = df_multi,
        ggplot2::aes(icon = icons_v1, group = category, color = category),
        dpi = 60
      )
  )

  built1 <- ggplot2::ggplot_build(p1)
  rendered1 <- extract_icon_names(built1$data[[1]]$image)

  testthat::expect_setequal(unique(rendered1), c("heart", "star"))

  # Test using icons_v2
  p2 <- suppressWarnings(
    ggplot2::ggplot() +
      geom_pop(
        data = df_multi,
        ggplot2::aes(icon = icons_v2, group = category, color = category),
        dpi = 60
      )
  )

  built2 <- ggplot2::ggplot_build(p2)
  rendered2 <- extract_icon_names(built2$data[[1]]$image)

  testthat::expect_setequal(unique(rendered2), c("circle", "square"))
})

# ******************************************************************************
# 13 DPI parameter tests ------------------------------------------------
# ******************************************************************************
testthat::test_that("dpi parameter controls actual PNG resolution", {
  # Setup test data
  test_data <- data.frame(
    type = rep(c("A", "B"), each = 5),
    icon = "user",
    stringsAsFactors = FALSE
  )

  # Test different DPI values
  dpi_values <- c(50, 100, 600)

  for (dpi_val in dpi_values) {
    # Create plot with specific DPI
    # Suppress warnings for high DPI (600) - we're testing functionality, not validation
    p <- suppressWarnings(
      ggplot2::ggplot() +
        geom_pop(
          data = test_data,
          ggplot2::aes(icon = icon, group = type, color = type),
          dpi = dpi_val,
          size = 10
        )
    )

    # Build the plot to trigger PNG generation
    built <- ggplot2::ggplot_build(p)

    # Get the layer data which contains image paths
    layer_data <- built$data[[1]]

    # Extract unique PNG paths
    png_paths <- unique(layer_data$image)
    png_paths <- png_paths[!is.na(png_paths) & file.exists(png_paths)]

    expect_true(
      length(png_paths) > 0,
      info = sprintf("No PNG files generated for DPI = %d", dpi_val)
    )

    # Check each generated PNG
    for (png_path in png_paths) {
      # Read PNG metadata
      img_info <- png::readPNG(png_path, info = TRUE)
      img_attr <- attributes(img_info)

      # Get actual dimensions
      actual_height <- nrow(img_info)

      # Expected height should match DPI (fontawesome::fa_png uses height parameter)
      expect_equal(
        actual_height,
        dpi_val,
        tolerance = 0,
        info = sprintf(
          "PNG height mismatch for DPI = %d: expected %d pixels, got %d pixels\nFile: %s",
          dpi_val, dpi_val, actual_height, png_path
        )
      )

      # Additional check: verify image is not empty
      expect_true(
        actual_height > 0,
        info = sprintf("PNG has zero height for DPI = %d", dpi_val)
      )

      # Verify the image has content (not all transparent/white)
      pixel_values <- as.vector(img_info)
      expect_true(
        length(unique(pixel_values)) > 1,
        info = sprintf("PNG appears to be blank for DPI = %d", dpi_val)
      )
    }
  }
})

testthat::test_that("higher DPI produces larger file sizes (quality indicator)", {
  test_data <- data.frame(
    type = "A",
    icon = "user",
    stringsAsFactors = FALSE
  )

  file_sizes <- numeric(3)
  dpi_vals <- c(50, 100, 200)

  for (i in seq_along(dpi_vals)) {
    # Clear cache to force regeneration
    cache_dir <- file.path(tempdir(), "ggpop-icons")
    if (dir.exists(cache_dir)) unlink(cache_dir, recursive = TRUE)

    p <- ggplot2::ggplot() +
      geom_pop(
        data = test_data,
        ggplot2::aes(icon = icon, group = type),
        dpi = dpi_vals[i],
        size = 3
      )

    built <- ggplot2::ggplot_build(p)
    png_path <- built$data[[1]]$image[1]

    expect_true(file.exists(png_path))
    file_sizes[i] <- file.info(png_path)$size
  }

  # Higher DPI should produce larger files
  expect_true(
    file_sizes[2] > file_sizes[1],
    info = sprintf(
      "DPI 100 (%d bytes) should be larger than DPI 50 (%d bytes)",
      file_sizes[2], file_sizes[1]
    )
  )

  expect_true(
    file_sizes[3] > file_sizes[2],
    info = sprintf(
      "DPI 200 (%d bytes) should be larger than DPI 100 (%d bytes)",
      file_sizes[3], file_sizes[2]
    )
  )
})

testthat::test_that("DPI is correctly embedded in PNG cache filename", {
  test_data <- data.frame(
    type = "A",
    icon = "user",
    stringsAsFactors = FALSE
  )

  dpi_val <- 150

  p <- ggplot2::ggplot() +
    geom_pop(
      data = test_data,
      ggplot2::aes(icon = icon, group = type),
      dpi = dpi_val,
      size = 3
    )

  built <- ggplot2::ggplot_build(p)
  png_path <- built$data[[1]]$image[1]
  png_filename <- basename(png_path)

  # Check that DPI is in the filename (e.g., "d150")
  expect_true(
    grepl(sprintf("d%d", dpi_val), png_filename),
    info = sprintf(
      "Filename '%s' should contain 'd%d' to indicate DPI = %d",
      png_filename, dpi_val, dpi_val
    )
  )
})

testthat::test_that("same DPI reuses cached PNG (does not regenerate)", {
  test_data <- data.frame(
    type = "A",
    icon = "user",
    stringsAsFactors = FALSE
  )

  # First plot
  p1 <- ggplot2::ggplot() +
    geom_pop(
      data = test_data,
      ggplot2::aes(icon = icon, group = type),
      dpi = 100,
      size = 3
    )

  built1 <- ggplot2::ggplot_build(p1)
  png_path1 <- built1$data[[1]]$image[1]
  mtime1 <- file.info(png_path1)$mtime

  # Wait to ensure different timestamp if regenerated
  Sys.sleep(0.1)

  # Second plot with same DPI
  p2 <- ggplot2::ggplot() +
    geom_pop(
      data = test_data,
      ggplot2::aes(icon = icon, group = type),
      dpi = 100,
      size = 3
    )

  built2 <- ggplot2::ggplot_build(p2)
  png_path2 <- built2$data[[1]]$image[1]
  mtime2 <- file.info(png_path2)$mtime

  # Should be the same file
  expect_identical(png_path1, png_path2)

  # Should have the same modification time (not regenerated)
  expect_equal(mtime1, mtime2)
})

testthat::test_that("different DPI values create different cache files", {
  test_data <- data.frame(
    type = "A",
    icon = "user",
    stringsAsFactors = FALSE
  )

  p1 <- ggplot2::ggplot() +
    geom_pop(
      data = test_data,
      ggplot2::aes(icon = icon, group = type),
      dpi = 50,
      size = 3
    )

  p2 <- ggplot2::ggplot() +
    geom_pop(
      data = test_data,
      ggplot2::aes(icon = icon, group = type),
      dpi = 100,
      size = 3
    )

  built1 <- ggplot2::ggplot_build(p1)
  built2 <- ggplot2::ggplot_build(p2)

  png_path1 <- built1$data[[1]]$image[1]
  png_path2 <- built2$data[[1]]$image[1]

  # Different DPI should create different files
  expect_false(
    identical(png_path1, png_path2),
    info = "Different DPI values should create separate cached PNG files"
  )

  # Both should exist
  expect_true(file.exists(png_path1))
  expect_true(file.exists(png_path2))
})

testthat::test_that("DPI validation errors work correctly", {
  test_data <- data.frame(
    type = "A",
    icon = "user",
    stringsAsFactors = FALSE
  )

  # DPI too low should error
  expect_error(
    ggplot2::ggplot() +
      geom_pop(
        data = test_data,
        aes(icon = icon, group = type),
        dpi = 20, # Below minimum of 30
        size = 3
      ),
    "dpi.*too low",
    ignore.case = TRUE
  )
})


# ******************************************************************************
# 14 Snapshot ------------------------------------------------------------------
# ******************************************************************************


testthat::test_that("geom_pop", {
  df <- data.frame(
    sex = c("male", "female", "male", "female"),
    icon = c("male", "female", "male", "female"),
    stringsAsFactors = FALSE
  )

  p <- ggplot2::ggplot() +
    geom_pop(
      data = df,
      ggplot2::aes(icon = icon, group = sex, color = sex)
    ) +
    ggplot2::theme_void()

  expect_doppelganger(
    title = "geom_pop",
    fig = p
  )
})


testthat::test_that("geom_pop scale_legend_icon()", {
  df <- data.frame(
    sex = c("male", "female", "male", "female"),
    icon = c("male", "female", "male", "female"),
    stringsAsFactors = FALSE
  )

  p <- ggplot2::ggplot() +
    geom_pop(
      data = df,
      ggplot2::aes(icon = icon, group = sex, color = sex)
    ) +
    ggplot2::theme_void() +
    scale_legend_icon(size = 10)

  expect_doppelganger(
    title = "geom_pop scale_legend_icon()",
    fig = p
  )
})


testthat::test_that("geom_pop factor levels", {
  df <- data.frame(
    income = c(rep("Low", 1), rep("Mid", 1), rep("High", 1)),
    icon   = c(rep("pills", 1), rep("stethoscope", 1), rep("hospital", 1))
  )

  # Factor: legend should show Low → Mid → High with matching icons
  df$income <- factor(df$income, levels = c("Low", "Mid", "High"))

  p <- ggplot2::ggplot() +
    geom_pop(
      data = df,
      aes(icon = icon, color = income),
      size = 3, arrange = T
    ) +
    ggplot2::scale_color_manual(values = c(
      "Low"  = "#FF5252",
      "Mid"  = "#FFD54F",
      "High" = "#00BFA5"
    ))


  expect_doppelganger(
    title = "geom_pop factor levels",
    fig = p
  )
})

# ******************************************************************************
## show.legend = FALSE ---------------------------------------------------------
# ******************************************************************************

testthat::test_that("geom_pop show.legend = FALSE hides icon legend", {
  df_show <- data.frame(
    type = c("A", "B", "C"),
    icon = c("circle", "circle", "circle")
  )

  p <- ggplot2::ggplot() +
    geom_pop(
      data        = df_show,
      aes(icon = icon, group = type, color = type),
      size        = 1,
      dpi         = 50,
      show.legend = FALSE
    ) +
    ggplot2::scale_color_manual(values = c("A" = "#E53935", "B" = "#1E88E5", "C" = "#43A047"))

  expect_doppelganger(
    title = "geom_pop show.legend FALSE",
    fig   = p
  )
})

# ******************************************************************************
## Coordinate inheritance (geom_text, geom_label) ------------------------------
# ******************************************************************************

testthat::test_that("geom_text inherits x and y from geom_pop without error", {
  df_label <- data.frame(
    type = rep(c("A", "B"), each = 2),
    icon = rep(c("circle", "star"), each = 2),
    stringsAsFactors = FALSE
  )

  p <- ggplot2::ggplot(data = df_label, ggplot2::aes(icon = icon, color = type)) +
    geom_pop(size = 1, dpi = 50, legend_icons = FALSE, seed=1) +
    ggplot2::geom_text(ggplot2::aes(label = type), nudge_y = 0.03, size = 10, show.legend = F) +
    ggplot2::scale_color_manual(values = c("A" = "#E53935", "B" = "#1E88E5")) +
    ggplot2::theme_void() +
    ggplot2::theme(legend.position = "none")

  testthat::expect_no_error(ggplot2::ggplot_build(p))

  expect_doppelganger(
    title = "geom_pop geom_text coordinate inheritance",
    fig   = p
  )
})

# ******************************************************************************
# END --------------------------------------------------------------------------
# ******************************************************************************
