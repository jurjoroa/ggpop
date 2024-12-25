#' Create a circular representative population chart
#' 
#' Draws a circular representative population chart based on the proportion of the groups,
#' where each point (person) represents a determined number of individuals.
#' Every person is represented by an image.
#' 
#' @section Aesthetics:
#' geom_pop employs the following aesthetics:
#' 
#' - **sample_size** - The number of individuals to be represented in the chart.
#' - **alpha** - The transparency of the points.
#' - **color** - The color of the points.
#' - **size** - The size of the points.
#' 
#' @inheritParams ggplot2::layer
#' @inheritParams ggimage::geom_image
#' @param size The size of the points.
#' @param icon The icon to be used in the chart.
#' @param group_var The variable used to group individuals.
#' @param sample_size The total number of individuals (points) to be drawn.
#' @param arrange Logical; if TRUE, the output data is arranged by group.
#' @param sum_var Optional variable to sum over instead of counting.
#' @importFrom ggplot2 layer
#' @export
geom_pop <- function(mapping = NULL, data = NULL, stat = "identity",
                     position = "identity", na.rm = FALSE, show.legend = NA,
                     inherit.aes = TRUE, icon = "default",
                     group_var = NULL, sample_size = NULL, arrange = FALSE, sum_var = NULL,
                     size = 1, # default size as 1 externally
                     ...) {
  
  # Transform the user-specified size to the desired internal scale
  # If user specifies 1, internally we use 0.03
  # This will scale any size value passed from outside by 0.03.
  size_internal <- size * 0.03
  
  # Convert mapping to a list
  mapping_list <- if (!is.null(mapping)) as.list(mapping) else list()
  
  if ("image" %in% names(mapping_list)) {
    stop("Please do not specify the 'image' aesthetic directly. Use 'icon' instead.")
  }
  
  if (!"icon" %in% names(mapping_list)) {
    mapping_list[["icon"]] <- icon
  }
  
  # If arrange = TRUE, reorder by 'type' and then assign pos:
  if (!is.null(data) && arrange) {
    data <- data %>%
      mutate(original_order = row_number()) %>%
      arrange(type, original_order) %>%
      mutate(pos = row_number()) %>%
      select(-original_order)
  }
  
  sample_size <- nrow(data)
  
  filtered_coordinates <- df_coordinates_final %>%
    filter(size == sample_size)
  
  if (nrow(filtered_coordinates) == 0 || !"x1" %in% colnames(filtered_coordinates) || !"y1" %in% colnames(filtered_coordinates)) {
    stop("No matching coordinates found for this sample size or x1/y1 columns missing in df_coordinates_final.")
  }
  
  data_merged <- full_join(filtered_coordinates, data, by = "pos")
  
  # Get the row count of the merged table
  N <- nrow(data_merged)
  
  # Prepare the vector to fill in your new column
  vector_name_icon <- unique(data$icon)
  
  # Create a tibble with exactly N rows by:
  #  - adding enough NAs to match N
  #  - using [seq_len(N)] to truncate if the vector is too long
  df_icon <- tibble(
    image = c(vector_name_icon, rep(NA, max(0, N - length(vector_name_icon))))
  )[seq_len(N), ]
  
  df_final <- bind_cols(data_merged, df_icon)
  
  if (!"x1" %in% colnames(df_final) || !"y1" %in% colnames(df_final)) {
    stop("x1 or y1 columns are missing after merging. Check that pos matches between data and df_coordinates_final.")
  }
  
  # Create image aesthetic from icon
  icon_expr <- mapping_list[["icon"]]
  mapping_list[["image"]] <- bquote(paste0("man/figures/", .(icon_expr), ".svg"))
  
  # Build final mapping
  final_mapping <- do.call(aes_, mapping_list)
  final_mapping$x <- as.name("x1")
  final_mapping$y <- as.name("y1")
  
  # Now call geom_image with the internally scaled size
  ggimage::geom_image(
    mapping = final_mapping,
    data = df_final,
    stat = stat,
    position = position,
    na.rm = na.rm,
    inherit.aes = inherit.aes,
    size = size_internal,
    ...
  )
}
