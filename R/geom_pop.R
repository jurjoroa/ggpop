#' Create a circular representative population chart
#' #' 
#' Draws a circular representative population chart based on the proportion of the groups,
#' where each point (person) represents a determined number of individuals.
#' Every person is represented by an image with a given icon. 
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
#' 
#' 
#' @importFrom ggplot2 layer
#' @importFrom ggpopdata load_data
#' @import ggimage
#' 
#' 
#' @export
geom_pop <- function(mapping = NULL, data = NULL, stat = "identity",
                     position = "identity", na.rm = FALSE, show.legend = NA,
                     inherit.aes = TRUE, icon = "default",
                     group_var = NULL, sample_size = NULL, arrange = FALSE, sum_var = NULL,
                     size = 1, # default size as 1 externally
                     ...) {
  
  # Transform the user-specified size to the desired internal scale
  # If user specifies 1, internally we use 0.03
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
    df_order <- data %>% select(group, n , prop)
    
    data <- data %>%
      mutate(original_order = row_number()) %>%
      arrange(type, original_order) %>%
      mutate(pos = row_number()) %>%
      select(-original_order, -group, -n , -prop)

    data <- bind_cols(data, df_order)
    
  }
  sample_size <- nrow(data)
  
  df_coordinates_final <- fetch_df_coordinates()
  
  df_coordinates_filtered <- df_coordinates_final %>%
    filter(size == sample_size)
  
  if (nrow(df_coordinates_filtered) == 0 || !"x1" %in% colnames(df_coordinates_filtered) || !"y1" %in% colnames(df_coordinates_filtered)) {
    stop("No matching coordinates found for this sample size or x1/y1 columns missing in df_coordinates_final.")
  }
  
  df_merged <- full_join(df_coordinates_filtered, data, by = "pos")
  
  # Get the row count of the merged table
  N <- nrow(df_merged)
  
  # Prepare the vector to fill in your new column
  v_name_icon <- unique(data$icon)
  
  #Format to merge with the data
  df_icon <- tibble(
    image = c(v_name_icon, rep(NA, max(0, N - length(v_name_icon))))
  )[seq_len(N), ]
  
  #Final data
  df_final <- bind_cols(df_merged, df_icon)
  
  if (!"x1" %in% colnames(df_final) || !"y1" %in% colnames(df_final)) {
    stop("x1 or y1 columns are missing after merging. Check that pos matches between data and df_coordinates_final.")
  }
  
  icon_expr <- mapping_list[["icon"]]
  mapping_list[["image"]] <- bquote(paste0("man/figures/", .(icon_expr), ".svg"))
  
  final_mapping <- do.call(aes_, mapping_list)
  final_mapping$x <- as.name("x1")
  final_mapping$y <- as.name("y1")
  
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
