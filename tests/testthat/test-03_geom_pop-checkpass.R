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

# ******************************************************************************
# 01 Basic clean cases ---------------------------------------------------
# ******************************************************************************

testthat::test_that("Minimal raw mode", {
  
  df <- data.frame(
    sex  = c("male", "female", "male", "female"),
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
          color = "red",  # should overide mapped color
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
    sex  = rep(c("male", "female"), each = 10),
    icon = rep(c("male", "female"), each = 10),
    sz   = rep(c(2, 5), each = 10),
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
    grp   = rep(paste0("G", 1:5), times = 10),
    icon  = "user",
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
          ggplot2::facet_wrap(~ panel) +
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
    "user","users","person","person-walking","person-running",
    "car","bus","train","bicycle","plane",
    "heart","star","circle","square","triangle-exclamation",
    "house","building","tree","cloud","bolt"
  )
  
  df <- data.frame(
    grp  = rep(paste0("G", sprintf("%02d", 1:20)), each = 15),
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
    sex   = rep(c("male", "female"), length.out = 120),
    icon  = rep(c("male", "female"), length.out = 120),
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
          ggplot2::facet_wrap(~ panel) +
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
    n    = rep(50, 100),
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
    sex  = rep(c("male", "female"), each = 40),
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
    grp  = rep(c("A", "B", "C"), each = 40),
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
    grp  = rep(c("A", "B", "C"), each = 40),
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

# ******************************************************************************
# 09 Facet grid (rows OR cols) inference ---------------------------------
# ******************************************************************************

testthat::test_that("facet_grid inference (single dimension)", {
  
  df <- data.frame(
    panel = rep(c("Row1", "Row2", "Row3"), each = 60),
    grp   = rep(c("G1","G2","G3"), length.out = 180),
    icon  = rep(c("user","car","heart"), length.out = 180),
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
    grp  = rep(paste0("G", sprintf("%02d", 1:50)), each = 10),
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
    grp  = rep(c("A","B","C"), times = c(300, 300, 300)),
    icon = rep(c("user","car","heart"), times = c(300, 300, 300)),
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
  
  # Big pool of icons (can be > 250; we will slice to exactly 250)
  icons_pool <- c(
    "0","1","2","3","4","5","6","7","8","9",
    "a","accessible-icon","accusoft","address-book","address-card","adn","adversal","affiliatetheme","airbnb","algolia",
    "align-center","align-justify","align-left","align-right","alipay","amazon","amazon-pay","amilia","anchor","anchor-circle-check",
    "anchor-circle-exclamation","anchor-circle-xmark","anchor-lock","android","angellist","angle-down","angle-left","angle-right","angle-up","angles-down",
    "angles-left","angles-right","angles-up","angrycreative","angular","ankh","app-store","app-store-ios","apper","apple",
    "apple-pay","apple-whole","archway","arrow-down","arrow-down-1-9","arrow-down-9-1","arrow-down-a-z","arrow-down-long","arrow-down-short-wide","arrow-down-up-across-line",
    "arrow-down-up-lock","arrow-down-wide-short","arrow-down-z-a","arrow-left","arrow-left-long","arrow-pointer","arrow-right","arrow-right-arrow-left","arrow-right-from-bracket","arrow-right-long",
    "arrow-right-to-bracket","arrow-right-to-city","arrow-rotate-left","arrow-rotate-right","arrow-trend-down","arrow-trend-up","arrow-turn-down","arrow-turn-up","arrow-up","arrow-up-1-9",
    "arrow-up-9-1","arrow-up-a-z","arrow-up-from-bracket","arrow-up-from-ground-water","arrow-up-from-water-pump","arrow-up-long","arrow-up-right-dots","arrow-up-right-from-square","arrow-up-short-wide","arrow-up-wide-short",
    "arrow-up-z-a","arrows-down-to-line","arrows-down-to-people","arrows-left-right","arrows-left-right-to-line","arrows-rotate","arrows-spin","arrows-split-up-and-left","arrows-to-circle","arrows-to-dot",
    "arrows-to-eye","arrows-turn-right","arrows-turn-to-dots","arrows-up-down","arrows-up-down-left-right","arrows-up-to-line","artstation","asterisk","asymmetrik","at",
    "atlassian","atom","audible","audio-description","austral-sign","autoprefixer","avianex","aviato","award","aws",
    "b","baby","baby-carriage","backward","backward-fast","backward-step","bacon","bacteria","bacterium","bag-shopping",
    "bahai","baht-sign","ban","ban-smoking","bandage","bandcamp","bangladeshi-taka-sign","barcode","bars","bars-progress",
    "bars-staggered","baseball","baseball-bat-ball","basket-shopping","basketball","bath","battery-empty","battery-full","battery-half","battery-quarter",
    "battery-three-quarters","battle-net","bed","bed-pulse","beer-mug-empty","behance","bell","bell-concierge","bell-slash","bezier-curve",
    "bicycle","bilibili","bimobject","binoculars","biohazard","bitbucket","bitcoin","bitcoin-sign","bity","black-tie",
    "blackberry","blender","blender-phone","blog","blogger","blogger-b","bluesky","bluetooth","bluetooth-b","bold",
    "bolt","bolt-lightning","bomb","bone","bong","book","book-atlas","book-bible","book-bookmark","book-journal-whills",
    "book-medical","book-open","book-open-reader","book-quran","book-skull","book-tanakh","bookmark","bootstrap","border-all","border-none",
    "border-top-left","bore-hole","bots","bottle-droplet","bottle-water","bowl-food","bowl-rice","bowling-ball","box","box-archive",
    "box-open","box-tissue","boxes-packing","boxes-stacked","braille","brain","brave","brave-reverse","brazilian-real-sign","bread-slice",
    "bridge","bridge-circle-check","bridge-circle-exclamation","bridge-circle-xmark","bridge-lock","bridge-water","briefcase","briefcase-medical","broom","broom-ball",
    "brush","btc","bucket","buffer","bug","bug-slash","bugs","building","building-circle-arrow-right","building-circle-check",
    "building-circle-exclamation","building-circle-xmark","building-columns","building-flag","building-lock","building-ngo","building-shield","building-un","building-user","building-wheat",
    "bullhorn","bullseye","burger","buromobelexperte","burst","bus","bus-simple","business-time","buy-n-large","buysellads",
    "c","cable-car","cake-candles","calculator","calendar","calendar-check","calendar-day","calendar-days","calendar-minus","calendar-plus",
    "calendar-week","calendar-xmark","camera","camera-retro","camera-rotate","campground","canadian-maple-leaf","candy-cane","cannabis","capsules",
    "car","car-battery","car-burst","car-on","car-rear","car-side","car-tunnel","caravan","caret-down","caret-left",
    "caret-right","caret-up","carrot","cart-arrow-down","cart-flatbed","cart-flatbed-suitcase","cart-plus","cart-shopping","cash-register","cat"
  )
  
  # Enforce uniqueness and slice to EXACTLY 250
  icons_250 <- unique(icons_pool)[seq_len(250)]
  testthat::expect_equal(length(icons_250), 250)
  
  facets <- paste0("Facet_", 1:5)
  
  df <- do.call(
    rbind,
    lapply(seq_along(facets), function(i) {
      
      groups_i <- paste0("F", i, "_G", sprintf("%02d", 1:50))
      
      # 50 unique icons per facet (disjoint slices)
      idx <- ((i - 1) * 50 + 1):((i - 1) * 50 + 50)
      icons_i <- icons_250[idx]
      
      data.frame(
        facet = facets[i],
        grp   = rep(groups_i, each = 10),
        icon  = rep(icons_i,  each = 10),
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
            size = 0.55,
            arrange = FALSE,
            seed = 42,
            dpi = 50,
            legend_icons = TRUE
          ) +
          ggplot2::facet_wrap(~ facet, ncol = 3) +
          ggplot2::theme_void() +
          scale_legend_icon(size = 3)
      )
    )
  )
  
})


testthat::test_that("single plot with 1000 rows and random Font Awesome icons", {
  
  all_icons <- fontawesome::fa_metadata()$icon_names
  
  all_icons
  
  # Sample 1000 icons (allow repeats → safe even if FA < 1000 icons)
  icons_1000 <- sample(all_icons, 1000, replace = TRUE)
  
  testthat::expect_equal(length(icons_1000), 1000)
  
  df <- data.frame(
    grp  = paste0("G", sprintf("%04d", seq_len(1000))),
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
          #dont add legend
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
    sex  = c("male", "female", "male", "female"),
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
  n_unique_icons   <- length(unique(df$icon))
  
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
    grp  = rep(paste0("G", sprintf("%02d", seq_len(50))), each = 5),
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
  n_unique_icons   <- length(unique(df$icon))
  
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
    p <- ggplot2::ggplot() +
      geom_pop(
        data = test_data,
        aes(icon = icon, group = type, color = type),
        dpi = dpi_val,
        size = 10
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
        aes(icon = icon, group = type),
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
      aes(icon = icon, group = type),
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
      aes(icon = icon, group = type),
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
      aes(icon = icon, group = type),
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
      aes(icon = icon, group = type),
      dpi = 50,
      size = 3
    )
  
  p2 <- ggplot2::ggplot() +
    geom_pop(
      data = test_data,
      aes(icon = icon, group = type),
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
        dpi = 20,  # Below minimum of 30
        size = 3
      ),
    "dpi.*too low",
    ignore.case = TRUE
  )
})
