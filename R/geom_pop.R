#' Create a circular representative population chart
#' 
#' Draws a circular representative population chart based on the proportion of the groups,
#' where each point (person) represents a determined number of individuals.
#' Every person is represented by an image.
#' 
#' @section Aesthetics:
#' 
#' geom_pop employs the following aesthetics:
#' 
#' - **sample_size** - The number of individuals to be represented in the chart.
#' - alpha - The transparency of the points.
#' - color - The color of the points.
#' - size - The size of the points.
#' 
#' @inheritParams ggplot2::layer
#' @inheritParams ggimage::geom_image
#' @param size The size of the points.
#' @param icon The icon to be used in the chart.
#' @importFrom ggplot2 layer
#' 
#' @export
#' 
library(ggplot2)
library(dplyr)
library(ggimage)
library(rlang)

# Example coordinate data frame
# You must have this data frame defined in your environment or pass it as a parameter.
# This is just a placeholder example:


# Helper function for arranging data

arrange_data <- function(data, group_var, sum_var = NULL, sample_size = NULL, arrange = FALSE) {
  group_var_expr <- enquo(group_var)
  sum_var_expr <- enquo(sum_var)

  df_proportion <- data %>%
    group_by(!!group_var_expr) %>%
    summarise(
      n = if (quo_is_null(sum_var_expr)) {
        n()
      } else {
        sum(!!sum_var_expr)
      },
      .groups = "drop"
    ) %>%
    mutate(prop = n / sum(n))

  if (nrow(df_proportion) > 2) {
    stop("The current sample code supports only two groups. For multiple groups, adjust the sampling logic.")
  }

  df_prop <- df_proportion

  vector_sample <- sample(
    df_prop %>% pull(!!group_var_expr),
    sample_size,
    replace = TRUE,
    prob = c(df_prop$prop[1], 1 - df_prop$prop[1])
  )

  df_sample <- tibble(type = vector_sample)
  df_sample$pos <- seq(1, nrow(df_sample))

  if (arrange == TRUE) {
    df_sample <- df_sample[order(df_sample$type), ]
    df_sample$pos <- seq(1, nrow(df_sample))
  }

  # Get coordinates for the given sample_size
  df_coordinates <- df_coordinates_final %>%
    filter(size == sample_size)

  df_coor_dots <- full_join(df_coordinates, df_sample, by = "pos")

  return(df_coor_dots)
}

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
                     ...) {
  
  group_var_expr <- enquo(group_var)
  sum_var_expr <- enquo(sum_var)
  
  # If mapping is provided, convert it to a list for manipulation
  mapping_list <- if (!is.null(mapping)) as.list(mapping) else list()
  
  # If the user tries to specify 'image' directly, raise an error
  if ("image" %in% names(mapping_list)) {
    stop("Please do not specify the 'image' aesthetic directly. Use only 'icon'.")
  }
  
  # If 'icon' is not specified, use the provided default icon
  if (!"icon" %in% names(mapping_list)) {
    mapping_list[["icon"]] <- icon
  }
  
  # If group_var and sample_size are provided, arrange the data using arrange_data
  if (!is.null(data) && !quo_is_null(group_var_expr) && !is.null(sample_size)) {
    data <- arrange_data(
      data = data,
      group_var = !!group_var_expr,
      sum_var = !!sum_var_expr,
      sample_size = sample_size,
      arrange = arrange
    )
  }
  
  # Create the image aesthetic from icon
  icon_expr <- mapping_list[["icon"]]
  mapping_list[["image"]] <- bquote(paste0("man/figures/", .(icon_expr), ".svg"))
  
  # Build the base aes (without x and y)
  final_mapping <- do.call(aes_, mapping_list)
  
  # Now, internally set x and y so that the user does not need to specify them.
  # We assume `data` returned by arrange_data() has x and y columns.
  final_mapping$x <- as.name("x1")
  final_mapping$y <- as.name("y1")
  
  ggimage::geom_image(mapping = final_mapping, data = data, stat = stat,
                      position = position, na.rm = na.rm, inherit.aes = inherit.aes, ...)
}

# Example usage (assuming df is your data frame containing a grouping variable 'group_col'):
# p <- ggplot(df, aes(x, y)) +
#   geom_pop(group_var = group_col, sample_size = 200, arrange = TRUE, icon = "person")
# print(p)
