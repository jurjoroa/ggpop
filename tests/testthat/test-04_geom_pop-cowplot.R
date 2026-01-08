# *****************************************************************************
#
# Script: test-geom_pop-cowplot-airports.R
#
# Purpose: Ensure geom_pop() works robustly inside cowplot-driven narratives,
#          assembling multi-group "airport story" panels into a single figure
#          without warnings or errors.
#
# Author: Jorge Roa
#
# Email: jorgeroa@stanford.edu
#
# Date Created: 04-Jan-2026
#
# *****************************************************************************

testthat::skip_if_not_installed("ggplot2")
testthat::skip_if_not_installed("dplyr")
testthat::skip_if_not_installed("ggimage")
testthat::skip_if_not_installed("fontawesome")
testthat::skip_if_not_installed("cowplot")

# ******************************************************************************
# 01 Cowplot narrative: Airports story (multi-group panels) --------------------
# ******************************************************************************

testthat::test_that("geom_pop clean: cowplot airports narrative (multi-group panels)", {
  
  # Panel 1: Arrivals hall (mix of passengers, crew, families)
  df_arrivals <- data.frame(
    stage = "1.- Arrivals Hall",
    type  = c("Passengers", "Crew", "Families"),
    n     = c(70, 10, 20),
    icon  = c("person-walking-luggage", "user-tie", "people-group"),
    stringsAsFactors = FALSE
  )
  
  # Panel 2: Check-in (economy vs business vs special assistance)
  df_checkin <- data.frame(
    stage = "2.- Check-in",
    type  = c("Economy", "Business", "Assistance"),
    n     = c(75, 15, 10),
    icon  = c("ticket", "briefcase", "wheelchair"),
    stringsAsFactors = FALSE
  )
  
  # Panel 3: Security (clear vs standard vs secondary screening)
  df_security <- data.frame(
    stage = "3.- Security",
    type  = c("Standard", "PreCheck", "Secondary"),
    n     = c(65, 25, 10),
    icon  = c("shield", "shield-halved", "triangle-exclamation"),
    stringsAsFactors = FALSE
  )
  
  # Panel 4: Gates (waiting vs shopping vs lounge)
  df_gates <- data.frame(
    stage = "4.- Gates",
    type  = c("Waiting", "Shopping", "Lounge"),
    n     = c(60, 25, 15),
    icon  = c("clock", "bag-shopping", "couch"),
    stringsAsFactors = FALSE
  )
  
  # Panel 5: Boarding (zone groups)
  df_boarding <- data.frame(
    stage = "5.- Boarding",
    type  = c("Zone 1", "Zone 2", "Zone 3", "Zone 4"),
    n     = c(10, 25, 35, 30),
    # NOTE: use known FA icons for digits to avoid fontawesome lookup edge-cases
    icon = c(
      "user",
      "user-group",
      "users",
      "people-group"
    ),
    stringsAsFactors = FALSE
  )
  
  # Panel 6: Flight outcome (on-time vs delayed vs diverted)
  df_outcome <- data.frame(
    stage = "6.- Flight Outcome",
    type  = c("On-time", "Delayed", "Diverted"),
    n     = c(70, 25, 5),
    icon  = c("plane", "clock-rotate-left", "route"),
    stringsAsFactors = FALSE
  )
  
  df_story <- dplyr::bind_rows(
    df_arrivals, df_checkin, df_security, df_gates, df_boarding, df_outcome
  )
  
  # Expand counts into "people" rows (raw mode)
  df_story <- df_story[rep(seq_len(nrow(df_story)), df_story$n), ]
  rownames(df_story) <- NULL
  
  df_story$stage <- factor(
    df_story$stage,
    levels = c(
      "1.- Arrivals Hall", "2.- Check-in", "3.- Security",
      "4.- Gates", "5.- Boarding", "6.- Flight Outcome"
    )
  )
  
  # Consistent color mapping across panels (overall palette by type label)
  all_types <- unique(as.character(df_story$type))
  pal <- setNames(grDevices::hcl.colors(length(all_types), "Dark 3"), all_types)
  
  # ---------------------------------------------------------------------------
  # Build panels (NO helper function): each panel is an explicit ggplot object
  # ---------------------------------------------------------------------------
  
  df_s1 <- df_story[df_story$stage == "1.- Arrivals Hall", , drop = FALSE]
  p1 <- ggplot2::ggplot(df_s1) +
    geom_pop(
      ggplot2::aes(icon = icon, group = type, color = type),
      size = 1.15,
      arrange = FALSE,
      seed = 101,
      dpi = 120,
      legend_icons = TRUE
    ) +
    ggplot2::theme_void() +
    ggplot2::labs(
      title   = "Arrivals Hall",
      caption = "Passengers reunite with families while crew transitions."
    ) +
    ggplot2::scale_color_manual(values = pal) +
    scale_legend_icon(size = 7, nrow = 2, byrow = TRUE) +
    ggplot2::theme(
      legend.position = "bottom",
      legend.title = ggplot2::element_blank(),
      plot.title = ggplot2::element_text(hjust = 0.5),
      plot.caption = ggplot2::element_text(hjust = 0.5),
      plot.margin = ggplot2::margin(5, 5, 5, 5)
    )
  
  df_s2 <- df_story[df_story$stage == "2.- Check-in", , drop = FALSE]
  p2 <- ggplot2::ggplot(df_s2) +
    geom_pop(
      ggplot2::aes(icon = icon, group = type, color = type),
      size = 1.15,
      arrange = T,
      seed = 102,
      dpi = 120,
      legend_icons = TRUE
    ) +
    ggplot2::theme_void() +
    ggplot2::labs(
      title   = "Check-in",
      caption = "Most travelers queue in Economy; Business and Assistance lanes move faster."
    ) +
    ggplot2::scale_color_manual(values = pal) +
    scale_legend_icon(size = 7, nrow = 2, byrow = TRUE) +
    ggplot2::theme(
      legend.position = "bottom",
      legend.title = ggplot2::element_blank(),
      plot.title = ggplot2::element_text(hjust = 0.5),
      plot.caption = ggplot2::element_text(hjust = 0.5),
      plot.margin = ggplot2::margin(5, 5, 5, 5)
    )
  
  df_s3 <- df_story[df_story$stage == "3.- Security", , drop = FALSE]
  p3 <- ggplot2::ggplot(df_s3) +
    geom_pop(
      ggplot2::aes(icon = icon, group = type, color = type),
      size = 1.15,
      arrange = FALSE,
      seed = 103,
      dpi = 120,
      legend_icons = TRUE
    ) +
    ggplot2::theme_void() +
    ggplot2::labs(
      title   = "Security",
      caption = "Standard dominates; PreCheck speeds up; Secondary screening stays small but important."
    ) +
    ggplot2::scale_color_manual(values = pal) +
    scale_legend_icon(size = 7, nrow = 2, byrow = TRUE) +
    ggplot2::theme(
      legend.position = "bottom",
      legend.title = ggplot2::element_blank(),
      plot.title = ggplot2::element_text(hjust = 0.5),
      plot.caption = ggplot2::element_text(hjust = 0.5),
      plot.margin = ggplot2::margin(5, 5, 5, 5)
    )
  
  df_s4 <- df_story[df_story$stage == "4.- Gates", , drop = FALSE]
  p4 <- ggplot2::ggplot(df_s4) +
    geom_pop(
      ggplot2::aes(icon = icon, group = type, color = type),
      size = 1.15,
      arrange = FALSE,
      seed = 104,
      dpi = 120,
      legend_icons = TRUE
    ) +
    ggplot2::theme_void() +
    ggplot2::labs(
      title   = "At the Gate",
      caption = "Waiting is the norm, with some shopping and lounge time."
    ) +
    ggplot2::scale_color_manual(values = pal) +
    scale_legend_icon(size = 7, nrow = 2, byrow = TRUE) +
    ggplot2::theme(
      legend.position = "bottom",
      legend.title = ggplot2::element_blank(),
      plot.title = ggplot2::element_text(hjust = 0.5),
      plot.caption = ggplot2::element_text(hjust = 0.5),
      plot.margin = ggplot2::margin(5, 5, 5, 5)
    )
  
  df_s5 <- df_story[df_story$stage == "5.- Boarding", , drop = FALSE]
  p5 <- ggplot2::ggplot(df_s5) +
    geom_pop(
      ggplot2::aes(icon = icon, group = type, color = type),
      size = 1.15,
      arrange = FALSE,
      seed = 105,
      dpi = 120,
      legend_icons = TRUE
    ) +
    ggplot2::theme_void() +
    ggplot2::labs(
      title   = "Boarding by Zone",
      caption = "Zones roll in sequence; late zones still make up a big share."
    ) +
    ggplot2::scale_color_manual(values = pal) +
    scale_legend_icon(size = 7, nrow = 2, byrow = TRUE) +
    ggplot2::theme(
      legend.position = "bottom",
      legend.title = ggplot2::element_blank(),
      plot.title = ggplot2::element_text(hjust = 0.5),
      plot.caption = ggplot2::element_text(hjust = 0.5),
      plot.margin = ggplot2::margin(5, 5, 5, 5)
    )
  
  df_s6 <- df_story[df_story$stage == "6.- Flight Outcome", , drop = FALSE]
  p6 <- ggplot2::ggplot(df_s6) +
    geom_pop(
      ggplot2::aes(icon = icon, group = type, color = type),
      size = 1.15,
      arrange = FALSE,
      seed = 106,
      dpi = 120,
      legend_icons = TRUE
    ) +
    ggplot2::theme_void() +
    ggplot2::labs(
      title   = "Flight Outcome",
      caption = "Most flights are on-time, some delayed, a few diverted."
    ) +
    ggplot2::scale_color_manual(values = pal) +
    scale_legend_icon(size = 7, nrow = 2, byrow = TRUE) +
    ggplot2::theme(
      legend.position = "bottom",
      legend.title = ggplot2::element_blank(),
      plot.title = ggplot2::element_text(hjust = 0.5),
      plot.caption = ggplot2::element_text(hjust = 0.5),
      plot.margin = ggplot2::margin(5, 5, 5, 5)
    )
  
  # ---------------------------------------------------------------------------
  # Compose story with cowplot and ensure it builds cleanly
  # ---------------------------------------------------------------------------

    testthat::expect_no_error(
      suppressWarnings(
      {
        g <- cowplot::plot_grid(
          p1, p2, p3,
          p4, p5, p6,
          ncol  = 3,
          align = "hv"
        )
        
        g2 <- cowplot::ggdraw(g) +
          cowplot::draw_label(
            "Airport Journey: a Multi-Group Population Story (geom_pop + cowplot)",
            x = 0.5, y = 0.99,
            hjust = 0.5, vjust = 1,
            fontface = "bold",
            size = 16
          )
      }
    )
  )
  
})


