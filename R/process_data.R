#' Process Population Data for Visualization
#'
#' The `process_data` function processes a dataset to calculate group proportions and generates a sampled dataset based on specified parameters. This processed data is suitable for creating visual representations, such as population charts, where each sample represents a group with associated counts and proportions.
#'
#' @param data A data frame containing the population data to be processed.
#' @param high_group_var Character vector, optional. The variables used to group individuals hierarchically. This should be a categorical variable. If provided, the function samples individuals within each group defined by these variables.
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
#' @import utils
#' @importFrom tidyr nest unnest unite
#' @importFrom purrr map
#' @importFrom stats setNames
#' @importFrom rlang enquo quo_is_null as_label syms ensym
#'
#' @export
process_data <- function(data, 
                         high_group_var = NULL, 
                         group_var = NULL, 
                         sum_var = NULL, 
                         sample_size = 1000) {
  
  # Check if group_var is provided
  if (rlang::quo_is_null(enquo(group_var))) {
    stop("Please provide a 'group_var'.")
  }
  
  seed <- sample(1:10000, 1)  # Generate a random seed
  
  set.seed(seed)
  
  # Capture the name of group_var as a string
  group_var_name <- rlang::as_label(enquo(group_var))
  
  # Capture high_group_var as symbols if provided
  higher_group_syms <- rlang::syms(high_group_var)
  
  # Dynamically resolve the column for sum_var
  sum_var_sym <- if (!is.null(sum_var)) rlang::ensym(sum_var) else NULL
  
  # Step 1: Compute Proportions
  df_proportion <- data %>%
    # Convert group_var to character
    mutate({{ group_var }} == as.character({{ group_var }})) %>%
    
    # Group by high_group_var and group_var
    { 
      if (!is.null(high_group_var) && length(high_group_var) > 0) {
        group_by(., !!!higher_group_syms, {{ group_var }})
      } else {
        group_by(., {{ group_var }})
      }
    } %>%
    
    # Summarize counts
    summarise(
      n = if (is.null(sum_var_sym))
        n() 
      else 
        sum(!!sum_var_sym),
      .groups = 'drop'
    ) %>%
    
    # Regroup by high_group_var to calculate proportions within each group
    { 
      if (!is.null(high_group_var) && length(high_group_var) > 0) {
        group_by(., !!!higher_group_syms)
      } else {
        group_by(., NULL)  # No grouping
      }
    } %>%
    
    # Calculate proportions
    mutate(prop = n / sum(n)) %>%
    
    # Ungroup the data frame
    ungroup()
  
  # Optional: Validate that proportions sum to 1 within each higher_group_var
  if (!is.null(high_group_var) && length(high_group_var) > 0) {
    validation <- df_proportion %>%
      group_by(across(all_of(high_group_var))) %>%
      summarise(total_prop = sum(prop)) %>%
      ungroup()
    
    if (any(abs(validation$total_prop - 1) > 1e-6)) {
      warning("Proportions within some groups do not sum to 1.")
    }
  } else {
    total_prop <- sum(df_proportion$prop)
    if (abs(total_prop - 1) > 1e-6) {
      warning("Proportions do not sum to 1.")
    }
  }
  
  # Step 2: Perform Sampling Based on Computed Proportions
  if (!is.null(high_group_var) && length(high_group_var) > 0) {
    vector_sample <- df_proportion %>%
      group_by(across(all_of(high_group_var))) %>%
      nest() %>%
      mutate(
        sample = map(data, ~ sample(
          x = .x[[group_var_name]],  # Correctly access group_var using the captured name
          size = sample_size,
          replace = replace,
          prob = .x$prop
        ))
      ) %>%
      select(-data) %>%
      unnest(cols = c(sample)) %>%
      rename(type = sample)  %>% 
      group_by(across(all_of(high_group_var))) %>%
      mutate(pos = row_number()) %>%
      ungroup()
    
    df_sample <- as.data.frame(vector_sample)
    
  } else {
    # If no high_group_var, perform global sampling
    df_sample <- data.frame(
      type = sample(
        x = df_proportion[[group_var_name]],
        size = sample_size,
        replace = replace,
        prob = df_proportion$prop
      ),
      pos = 1:sample_size
    )
    
  }
  
  # Now perform the left join
  if (!is.null(high_group_var) && length(high_group_var) > 0) {
    join_by <- c("type" = group_var_name, setNames(high_group_var, high_group_var))
    df_final <- left_join(df_sample, df_proportion, by = join_by) %>%
      unite(group, all_of(high_group_var), sep = "_", remove = TRUE) # Combine into one column named "group"
  }else {
    # Handle case without high_group_var
    join_by <- c("type" = group_var_name)
    df_final <- left_join(df_sample, df_proportion, by = join_by)
  }
  
  
  return(df_final)
}