## 1.Individual risk ----
#' Individual risk function
#'
#' \code{arrange_data} is a function that takes a data frame, a group variable, a sum variable, a sample size, and an arrange variable. 
#' 
#' @param data A data frame.
#' @param group_var A group variable.
#' @param sum_var A sum variable.
#' @param sample_size A sample size.
#' @param arrange An arrange variable.
#' 
#' @examples
#' df_crc_prop <- arrange_data(data = df_crc, group_var = CauseOfDeath, sample_size = 1000)
#' 
#' @return
#' It returns a data frame with the coordinates of the dots.
#' @export
#' 
process_data <- function(data, group_var, sum_var = NULL, sample_size = NULL) {
  df_proportion <- data %>%
    group_by({{ group_var }}) %>%
    summarise(
      n = if (is.null({{ sum_var}}))
        n() else sum({{ sum_var }})
    ) %>%
    mutate(prop = n / sum(n))
  
  vector_sample <- sample(c(df_proportion %>% pull({{ group_var }})), sample_size, replace = TRUE,  prob=c(df_prop$prop[1], 1-df_prop$prop[1]))
  
  df_sample <- tibble(type = vector_sample)
  
  df_sample$pos <- seq(1, nrow(df_sample))
  

  
  return(df_sample)
}

df_crc_prop <- process_data(data = df_crc, group_var = CauseOfDeath, sample_size = 1000)

df_crc_prop <- df_crc_prop %>% 
  mutate(icon = ifelse(type == "OTHER", "male", "female"))


library(dplyr)

arrange_data <- function(data, arrange = FALSE) {
  if (arrange) {
    data <- data %>%
      mutate(first_order = row_number()) %>%
      arrange(type, first_order) %>%
      mutate(pos = row_number()) %>%
      select(-first_order)
  }
  
  return(data)
}

merge_points <- function(data, arrange=FALSE){

df_prop_sample <- arrange_data(data = data, arrange = T)

sample_size <- nrow(data)


df_coordinates <- df_coordinates_final %>% 
  filter(size == sample_size)

df_coor_dots <- full_join(df_coordinates, df_sample, by = "pos")

}

arrange_data <- function(data, group_var, sum_var = NULL, sample_size = NULL, arrange = FALSE) {
  df_proportion <- data %>%
    group_by({{ group_var }}) %>%
    summarise(
      n = if (is.null({{ sum_var}}))
        n() else sum({{ sum_var }})
    ) %>%
    mutate(prop = n / sum(n))
  
  vector_sample <- sample(c(df_proportion %>% pull({{ group_var }})), sample_size, replace = TRUE,  prob=c(df_prop$prop[1], 1-df_prop$prop[1]))
  
  df_sample <- tibble(type = vector_sample)
  
  df_sample$pos <- seq(1, nrow(df_sample))
  
  if (arrange == TRUE) {
    df_sample <- df_sample[order(df_sample$type), ]
    
    vector_order <- df_sample$type
    
    # Step 3: Order by pos
    #df <- df[order(df$pos), ]
    
    df_sample$type <- vector_order
    
    df_sample$pos <- seq(1, nrow(df_sample))
    
    #df$type <- vector_order
  }
  
  df_coordinates <- df_coordinates_final %>% 
    filter(size == sample_size)
  
  df_coor_dots <- full_join(df_coordinates, df_sample, by = "pos")
  
  
  return(df_coor_dots)
}







df_coordinates <- df_coordinates_final %>% 
  filter(size == sample_size)

df_coor_dots <- bind_cols(df_coordinates, tibble(type = df_sample))


df_crc_prop <- arrange_data(data = df_crc, group_var = CauseOfDeath, sample_size = 1000, arrange = FALSE)


ggplot(df_crc_prop, aes(x=x1, y=y1,  color=type)) +
  geom_image(aes(image = ifelse(type == "OTHER", "man/figures/male.svg", "man/figures/female.svg")),
             size = 0.03) +
  theme_void()


library(dplyr)

arrange_and_merge <- function(data, arrange = FALSE) {
  # Step 1: Arrange the data if requested
  if (arrange) {
    data <- data %>%
      # Add a temporary column to store the original row order
      mutate(original_order = row_number()) %>%
      # Arrange by 'type' and then by the original order to preserve 'icon' sequence within each 'type'
      arrange(type, original_order) %>%
      # Update the 'pos' column to reflect the new row positions
      mutate(pos = row_number()) %>%
      # Remove the temporary 'original_order' column as it's no longer needed
      select(-original_order)
  }
  
  sample_size <- nrow(data)
  
  # Step 2: Filter the coordinates data based on the specified size
  filtered_coordinates <- df_coordinates_final %>%
    filter(size == sample_size)
  
  # Step 3: Merge the (arranged or original) data with the filtered coordinates data
  merged_data <- full_join(filtered_coordinates, data, by = "pos")
  
  # Step 4: Return the merged dataframe
  return(merged_data)
}


df_crc_prop_44 <- arrange_and_merge(df_crc_prop, arrange = T)

ggplot


