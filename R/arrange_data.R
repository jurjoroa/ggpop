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
arrange_data <- function(data, group_var, sum_var = NULL, sample_size = NULL, arrange = NULL) {
  df_proportion <- data %>%
    group_by({{ group_var }}) %>%
    summarise(
      n = if (is.null({{ sum_var}}))
        n() else sum({{ sum_var }})
    ) %>%
    mutate(prop = n / sum(n))
  
  df_coordinates <- df_coordinates_final %>% 
    filter(size == sample_size)
  
  df_sample <- sample(c(df_proportion %>% pull({{ group_var }})), sample_size, replace = TRUE,  prob=c(df_prop$prop[1], 1-df_prop$prop[1]))
  
  df_coor_dots <- bind_cols(df_coordinates, tibble(type = df_sample))
  
  return(df_coor_dots)
}

df_crc_prop <- arrange_data(data = df_crc, group_var = CauseOfDeath, sample_size = 1000)


ggplot(df_crc_prop, aes(x=x1, y=y1,  color=type)) +
  geom_image(aes(image = ifelse(type == "OTHER", "man/figures/male.svg", "man/figures/female.svg")),
             size = 0.03) +
  theme_void()





