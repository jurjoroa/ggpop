#' Create a circular representative population chart
#'
#' Draws a circular representative population chart based on group proportions,
#' where each point (person) represents a fixed number of individuals.
#' Each person is rendered as a Font Awesome icon.
#'
#' @section Aesthetics:
#' geom_pop understands the following aesthetics:
#' \itemize{
#'   \item \strong{icon}: Font Awesome icon name (mapped column)
#'   \item \strong{group}: grouping variable for raw data mode
#'   \item \strong{color/colour}: icon color
#'   \item \strong{alpha}: transparency (must be mapped)
#'   \item \strong{size}: icon size (mapped or fixed)
#' }
#'
#' @inheritParams ggplot2::layer
#' @inheritParams ggimage::geom_image
#' @inheritParams fontawesome::fa
#' @param size Icon size. If mapped in \code{aes(size = ...)} the parameter is ignored.
#' @param icon Default icon to use when no icon column is mapped.
#' @param dpi Height (in \strong{pixels}) of the rendered PNG when using
#'   \code{fontawesome::fa_png()}. Higher values produce sharper icons.
#' @param group_var (Deprecated) Use \code{aes(group = ...)} instead.
#' @param sample_size The total number of individuals (points) to draw.
#' @param arrange Logical; if TRUE, output data is arranged by group.
#' @param seed Optional numeric seed used only when \code{arrange = FALSE}.
#' @param sum_var Optional variable to sum over instead of counting.
#' @param facet Optional faceting variable. If provided, final plot must be faceted
#'   with ggplot2 (use \code{validate_geom_pop_faceting(p)}).
#' @param legend_icons Logical; if TRUE, legend displays the selected icons.
#' @param stroke_width Numeric. Width of the icon outline in pixels (single value).
#'
#' @return A ggplot layer that renders a circular population chart with icons.
#'
#' @seealso
#'   \code{\link{geom_icon_point}}, \code{\link{process_data}},
#'   \code{\link[ggimage]{geom_image}}
#'
#' @examples
#' \dontrun{
#' library(ggplot2)
#'
#' df <- data.frame(
#'   sex  = rep(c("F", "M"), each = 10),
#'   icon = rep(c("female", "male"), each = 10)
#' )
#'
#' ggplot() +
#'   geom_pop(
#'     data = df,
#'     aes(icon = icon, group = sex, color = sex),
#'     size = 3,
#'     dpi = 80
#'   )
#' }
#'
#' @import dplyr
#' @importFrom ggplot2 aes ggplot_build last_plot draw_key_point
#' @importFrom rlang enexpr is_missing is_null is_symbol is_string as_name get_expr
#' @export
geom_pop <- function(mapping = NULL, data = NULL, stat = "identity",
                     position = "identity", na.rm = FALSE, show.legend = NA,
                     inherit.aes = TRUE, icon = "ggmale",
                     group_var = NULL, sample_size = NULL, arrange = FALSE,
                     seed = NULL,
                     sum_var = NULL,
                     facet = NULL,
                     size = 1,
                     dpi = 50,
                     legend_icons = TRUE,
                     stroke_width = NULL,
                     ...) {
  
  # 01 Setup: plot context + inherited mappings ----
  
  context <- extract_plot_context()
  plot_obj <- context$plot_obj
  inherited_mapping_list <- context$inherited_mappings
  
  .missing_size <- missing(size)
  
  if (is.null(data)) {
    data <- ggplot2::ggplot_build(ggplot2::last_plot())$plot$data
  }
  
  # 02 Validation: layer + data ----
  
  validate_single_geom_pop(plot_obj)
  validate_data_is_dataframe(data)
  validate_data_not_empty(data)
  validate_no_reserved_columns(data)
  
  # 03 Validation: parameters ----
  
  dots <- list(...)
  
  if ("alpha" %in% names(dots)) {
    validate_alpha_parameter(dots$alpha)
  }
  
  validate_all_parameters(
    stroke_width = stroke_width,
    dpi = dpi,
    size = size,
    missing_size = .missing_size,
    arrange = arrange,
    legend_icons = legend_icons,
    seed = seed,
    dots = dots
  )
  
  # 04 Faceting: infer + validate ----
  
  facet_expr <- rlang::enexpr(facet)
  facet_info <- resolve_facet_info(plot_obj, facet_expr)
  has_facet <- facet_info$has_facet
  facet_col <- facet_info$facet_col
  .facet_explicit <- facet_info$facet_explicit
  inferred_plot_facet <- facet_info$inferred_plot_facet
  
  validate_facet_column(data, facet_col)
  validate_facet_consistency(facet_col, inferred_plot_facet, .facet_explicit)
  
  # 05 Validation: aesthetics (shared with geom_icon_point) ----
  
  mapping_list <- if (!is.null(mapping)) as.list(mapping) else list()
  combined_mapping <- c(inherited_mapping_list, mapping_list)
  
  validate_no_fill_aesthetic(combined_mapping)
  validate_no_image_aesthetic(mapping_list)
  validate_stroke_width_not_aesthetic(combined_mapping)
  
  icon_info <- resolve_icon_variable(mapping_list, inherited_mapping_list,
                                     combined_mapping, icon, data)
  icon_var <- icon_info$icon_var
  data <- icon_info$data
  has_icon_param <- icon_info$has_icon_param
  
  mapping_list <- add_icon_to_mapping(mapping_list, inherited_mapping_list, icon_var)
  data <- normalize_icon_column(data, icon_var)
  
  # 06 Data preparation: detect mode + assign type ----
  
  processed_mode <- "type" %in% names(data)
  
  if (!processed_mode) {
    validate_raw_data_grouping(data, mapping_list, inherited_mapping_list)
    
    .get_mapped_var <- function(aes_name) {
      if (aes_name %in% names(combined_mapping)) {
        tryCatch(rlang::as_name(combined_mapping[[aes_name]]), error = function(e) NULL)
      } else {
        NULL
      }
    }

    group_var_m <- .get_mapped_var("group")
    col_var_m <- .get_mapped_var("colour")
    if (is.null(col_var_m)) col_var_m <- .get_mapped_var("color")
    
    src_var <- group_var_m %||% col_var_m
    
    data$type <- as.character(data[[src_var]])
  }
  
  # 07 Warnings (shared) ----
  
  warn_all_geom_pop(
    combined_mapping = combined_mapping,
    missing_size = .missing_size,
    size = size,
    data = data,
    facet_explicit = .facet_explicit,
    facet_col = facet_col,
    dots = dots 
  )
  
  # 08 Size handling ----
  
  size_result <- handle_size_aesthetic_pop(
    data, combined_mapping, mapping_list, inherited_mapping_list, size
  )
  data <- size_result$data
  mapping_list <- size_result$mapping_list
  
  # 09 Faceting finalization ----
  
  if (!has_facet && "group" %in% names(data) && dplyr::n_distinct(data$group) > 1) {
    has_facet <- TRUE
    facet_col <- "group"
  }
  
  # 10 Data arrangement + positioning ----
  
  data <- maybe_shuffle_pop_data(data, has_facet, facet_col, arrange, seed)
  data <- assign_pop_positions(data, has_facet, facet_col)
  
  # 11 Validation: max icons ----
  
  validate_max_icons(data, has_facet, facet_col, max_icons = 1000L)
  
  # 12 Coordinate system: fetch + merge (modular) ----
  
  coord_result <- merge_pop_coordinates(data, has_facet, facet_col, arrange)
  data <- coord_result$data
  df_merged <- coord_result$df_merged
  
  # 13 Final data preparation ----
  
  df_final <- df_merged %>% dplyr::filter(!is.na(.data$type))
  
  if (!"x1" %in% names(df_final) || !"y1" %in% names(df_final)) {
    cli::cli_abort(
      c(
        "x1 or y1 columns are missing after merging.",
        "i" = "Check that pos matches between data and df_coordinates_final."
      )
    )
  }
  
  # 14 Icon rendering: PNG generation + caching (shared) ----
  
  df_final <- add_icon_images(df_final, dpi, stroke_width)
  
  # 15 Legend setup (shared) ----
  
  legend_var <- detect_legend_variable(combined_mapping, df_final)
  icon_by_legend <- create_icon_by_legend(df_final, legend_var, icon, has_icon_param)
  
  warn_multiple_icons_per_group(df_final, legend_var, "icon")
  
  # 16 Legend key glyph: custom icon rendering ----
  
  key_glyph_pop <- make_pop_key_glyph(icon_by_legend, plot_obj, stroke_width)
  
  # 17 Final mapping + layer construction ----
  
  mapping_list[["image"]] <- as.name("image")
  mapping_list[["x"]]     <- as.name("x1")
  mapping_list[["y"]]     <- as.name("y1")
  mapping_list[["icon"]]  <- NULL
  
  final_mapping <- do.call(ggplot2::aes, mapping_list)
  
  size_internal <- df_final$icon_size
  
  key_fn <- function(data, params, size = 5) {
    data$size <- 5
    ggplot2::draw_key_point(data, params, size)
  }
  
  layer_out <- ggimage::geom_image(
    mapping      = final_mapping,
    data         = df_final,
    size         = size_internal,
    stat         = stat,
    position     = position,
    na.rm        = na.rm,
    inherit.aes  = inherit.aes,
    by           = "width",
    asp          = 1,
    key_glyph    = if (legend_icons) key_glyph_pop else key_fn,
    ...
  )
  
  # 18 Return layer + facet metadata ----
  
  layer_out$params$.ggpop_facet <- if (.facet_explicit) facet_col else NULL
  
  structure(
    list(layer = layer_out, facet_col = if (.facet_explicit) facet_col else NULL),
    class = "ggpop_geom_pop"
  )
}
