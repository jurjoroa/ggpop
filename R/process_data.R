#' Process Population Data for Visualization
#'
#' The `process_data` function processes a dataset to calculate group proportions and generates a sampled dataset based on specified parameters. This processed data is suitable for creating visual representations, such as population charts, where each sample represents a group with associated counts and proportions.
#'
#' @param data A data frame containing the population data to be processed.
#' @param group_var Quosure. The variable used to group individuals in the dataset. This should be a categorical variable.
#' @param sum_var Quosure, optional. The variable to sum over within each group. If `NULL`, the function counts the number of individuals per group.
#' @param sample_size Integer. The total number of individuals to sample based on group proportions. Must be a positive integer.
#'
#' @return A tibble (data frame) with the following columns:
#' \describe{
#'   \item{type}{The sampled group type.}
#'   \item{pos}{The position index of the sampled individual.}
#'   \item{group}{The group identifier.}
#'   \item{n}{The count of individuals in the group.}
#'   \item{prop}{The proportion of the group relative to the total population.}
#' }
#' 
#' @import dplyr
#' @import tibble
#'
#' @export
process_data <- function(data, group_var= NULL, sum_var = NULL, sample_size = NULL) {
  
  #if group_var is a factor, turn it into a character
  
  df_proportion <- data %>%
    mutate({{ group_var }} == as.character({{ group_var }})) %>%
    group_by({{ group_var }}) %>%
    summarise(
      n = if (is.null({{ sum_var}}))
        n() else sum({{ sum_var }})
    ) %>%
    mutate(prop = n / sum(n))
  
  vector_sample <- sample(c(df_proportion %>% pull({{ group_var }})), sample_size, replace = TRUE,  prob=df_proportion$prop)
  
  df_sample <- tibble(type = vector_sample)
  
  df_sample$pos <- seq(1, nrow(df_sample))
  
  sample_group <- unique(df_sample$type)
  
  n_proportion <- df_proportion$n
  
  prop <- df_proportion$prop
  
  # Match length of df_sample
  df_extra <- tibble(
    group = c(sample_group, rep(NA, max(0, nrow(df_sample) - length(sample_group)))),
    n     = c(n_proportion, rep(NA, max(0, nrow(df_sample) - length(n_proportion)))),
    prop  = c(prop, rep(NA, max(0, nrow(df_sample) - length(prop))))
  )[seq_len(nrow(df_sample)), ]    # truncate if needed
  
  # Combine
  df_sample <- bind_cols(df_sample, df_extra)
  
  return(df_sample)
}