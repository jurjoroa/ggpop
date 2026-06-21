#' Create a scatter plot with Font Awesome icons instead of points
#'
#' Works exactly like geom_point(), but renders Font Awesome icons instead of dots.
#' Pass any data with x and y variables - no special formatting required.
#'
#' @section Aesthetics:
#' geom_icon_point uses standard ggplot2 scatter plot aesthetics:
#' - **x** - Numeric variable for x-axis
#' - **y** - Numeric variable for y-axis
#' - **icon** - Font Awesome icon name (optional, column or mapped)
#' - **color/colour** - Color grouping
#' - **alpha** - Transparency
#' - **size** - Icon size
#'
#' @inheritParams ggplot2::layer
#' @inheritParams ggimage::geom_image
#' @param icon Default icon (default: NULL). Accepts a Font Awesome name, a
#'   bundled ggpop marker name (e.g. \code{"square-inset"}, \code{"circle-plus"},
#'   \code{"diamond-hollow"}), or a path to a local \code{.svg} file. The same
#'   sources are valid in \code{aes(icon = ...)}; SVG markers are recoloured by
#'   the mapped colour aesthetic.
#' @param size Default icon size (default: 1).
#' @param dpi Icon resolution (default: 50).
#' @param show.legend Logical. Should this layer be included in the legends?
#'   `NA` (default) includes the layer if any aesthetics are mapped.
#'   `FALSE` suppresses the layer's legend entries entirely.
#' @param legend_icons Show icons in legend (default: TRUE).
#' @param stroke_width Numeric. Width of the icon outline/stroke.
#' @param icon_path Optional path to a folder of your own SVG icons, referenced
#'   by file name (without \code{.svg}) through the \code{icon} aesthetic - just
#'   like a Font Awesome name. Defaults to \code{getOption("ggpop.icon_path")}.
#'   Monochrome SVGs (\code{fill="#000000"} or \code{currentColor}) are recoloured
#'   by the mapped colour. See \code{\link{ggpop_markers}}.
#'
#' @return A ggplot layer.
#'
#' @examples
#' \donttest{
#' library(ggplot2)
#' data <- data.frame(
#'   x = rnorm(20),
#'   y = rnorm(20),
#'   category = sample(c("A", "B", "C"), 20, replace = TRUE),
#'   icon = sample(c("heart", "star", "circle"), 20, replace = TRUE)
#' )
#'
#' # Map icon to a column
#' ggplot(data, aes(x = x, y = y, icon = icon, color = category)) +
#'   geom_icon_point()
#'
#' # Use a fixed icon
#' ggplot(data, aes(x = x, y = y, color = category)) +
#'   geom_icon_point(icon = "star")
#' }
#'
#' @import dplyr
#' @export
geom_icon_point <- function(mapping = NULL, data = NULL, stat = "identity",
                            position = "identity", na.rm = FALSE,
                            show.legend = NA, inherit.aes = TRUE, icon = NULL,
                            size = 1, dpi = 50, legend_icons = TRUE,
                            stroke_width = NULL,
                            icon_path = NULL,
                            ...) {
  # 01 Capture extra args + handle swapped inputs ----

  extra_args <- list(...)

  swapped <- handle_argument_swap(mapping, data)
  mapping <- swapped$mapping
  data <- swapped$data

  # 02 Extract plot context + inherited mappings ----

  context <- extract_plot_context()
  plot_obj <- context$plot_obj
  inherited_mapping_list <- context$inherited_mappings

  # 03 Track user-provided size + inherit data if missing ----

  .missing_size <- missing(size)

  if (is.null(data)) {
    data <- ggplot2::ggplot_build(ggplot2::last_plot())$plot$data
  }

  # 04 Prepare mappings + validate inputs ----

  mapping_list <- if (!is.null(mapping)) as.list(mapping) else list()
  # Layer mapping takes priority: drop inherited keys already set by the layer
  # so that e.g. color = group_label overrides inherited color = Status.
  unique_inherited <- inherited_mapping_list[
    !names(inherited_mapping_list) %in% names(mapping_list)
  ]
  combined_mapping <- c(mapping_list, unique_inherited)

  validate_geom_icon_point(
    data, dpi, size, .missing_size, legend_icons, extra_args, mapping_list,
    stroke_width
  )


  # 05 Warnings for potential conflicts ----

  validate_stroke_width_not_aesthetic(combined_mapping)
  validate_literal_alpha_in_aes(combined_mapping, data = data)
  warn_size_conflict(combined_mapping, .missing_size, size)
  warn_alpha_conflict(combined_mapping, extra_args)

  # 06 Resolve icon source + normalize icon column ----

  icon_info <- resolve_icon_variable(
    mapping_list, inherited_mapping_list,
    combined_mapping, icon, data
  )
  icon_var <- icon_info$icon_var
  data <- icon_info$data
  has_icon_param <- icon_info$has_icon_param

  mapping_list <- add_icon_to_mapping(mapping_list, inherited_mapping_list, icon_var)
  data <- normalize_icon_column(data, icon_var)


  # 07 Handle size aesthetics  ----

  size_result <- handle_size_aesthetic(
    data, combined_mapping, mapping_list,
    inherited_mapping_list, size
  )
  data <- size_result$data
  mapping_list <- size_result$mapping_list


  # 08 Generate icon images  ----

  data <- add_icon_images(data, dpi, stroke_width, icon_path = icon_path)


  # 09 Legend setup + warnings ----

  legend_var <- detect_legend_variable(combined_mapping, data)
  icon_by_legend <- create_icon_by_legend(data, legend_var, icon, has_icon_param)

  if (legend_icons && !is.null(legend_var) && legend_var %in% names(data)) {
    if (!is.numeric(data[[legend_var]])) {
      warn_multiple_icons_per_group(data, legend_var, "icon")
    }
  }

  alpha_var_name <- tryCatch(
    rlang::as_name(combined_mapping[["alpha"]]),
    error = function(e) NULL
  )

  alpha_by_legend <- NULL
  if (!is.null(alpha_var_name) && alpha_var_name %in% names(data) &&
      !is.null(legend_var) && legend_var %in% names(data)) {
    validate_alpha_column(data[[alpha_var_name]], alpha_var_name)
    df_alpha_summary <- data %>%
      dplyr::group_by(.data[[legend_var]]) %>%
      dplyr::summarise(av = dplyr::first(.data[[alpha_var_name]]), .groups = "drop")
    alpha_by_legend <- setNames(
      as.numeric(df_alpha_summary$av),
      as.character(df_alpha_summary[[legend_var]])
    )
  } else if ("alpha" %in% names(combined_mapping) && !is.null(legend_var) &&
             legend_var %in% names(data)) {
    alpha_literal <- tryCatch(
      as.numeric(rlang::eval_tidy(combined_mapping[["alpha"]])),
      error = function(e) NULL
    )
    if (!is.null(alpha_literal) && length(alpha_literal) == 1 && is.finite(alpha_literal)) {
      legend_groups <- as.character(unique(data[[legend_var]]))
      alpha_by_legend <- setNames(rep(alpha_literal, length(legend_groups)), legend_groups)
    }
  }


  # 10 Final mapping + layer creation  ----

  mapping_list[["image"]] <- as.name("image")
  # Keep `icon` mapped (to the normalized icon column) so the draw-time geom can
  # re-bake each PNG with the resolved colour - see make_geom_pop_image().
  mapping_list[["icon"]] <- as.name("icon")
  final_mapping <- do.call(ggplot2::aes, mapping_list)

  ggpop_layer <- ggimage::geom_image(
    mapping      = final_mapping,
    data         = data,
    size         = data$icon_size,
    stat         = stat,
    position     = position,
    na.rm        = na.rm,
    inherit.aes  = inherit.aes,
    by           = "width",
    asp          = 1,
    key_glyph    = if (legend_icons) key_glyph_icon_point else ggplot2::draw_key_point,
    ...
  )


  # 11 Attach metadata + return layer  ----

  # Recolor icons at draw time from the scale-trained colour instead of relying
  # on ggimage's tinting, which renders black on some magick builds (#380).
  ggpop_layer$geom <- make_geom_pop_image(ggpop_layer$geom, dpi, stroke_width, icon_path = icon_path)

  # ggimage::geom_image() does not honour show.legend, so we set it directly
  # on the layer object — ggplot2 reads this field during legend construction.
  #
  # Use a named logical vector (ggplot2 >= 3.3.0) to restrict participation to
  # the colour guide only.  geom_image lists fill in its default_aes, which
  # causes ggplot2 to route it through the fill guide and call key_glyph_icon_point
  # for fill legend keys — producing icon bleed.  Explicitly setting fill = FALSE
  # prevents this regardless of what ggplot2 version infers from Geom$aesthetics().
  if (isFALSE(show.legend)) {
    ggpop_layer$show.legend <- FALSE
  } else {
    ggpop_layer$show.legend <- c(
      colour = if (is.na(show.legend)) NA else isTRUE(show.legend),
      fill   = FALSE
    )
  }

  ggpop_layer$geom_params$icon_by_legend <- icon_by_legend
  ggpop_layer$geom_params$plot_obj <- plot_obj
  ggpop_layer$geom_params$dpi <- dpi
  ggpop_layer$geom_params$stroke_width <- stroke_width
  ggpop_layer$geom_params$alpha_by_legend <- alpha_by_legend
  ggpop_layer$geom_params$icon_path <- icon_path

  ggpop_layer$ggpop_layer_type <- "icon_point"
  ggpop_layer$ggpop_legend_icons <- isTRUE(legend_icons)
  ggpop_layer$ggpop_has_alpha_mapping <- !is.null(alpha_by_legend)
  class(ggpop_layer) <- c("ggpop_icon_point_layer", class(ggpop_layer))

  ggpop_layer
}
