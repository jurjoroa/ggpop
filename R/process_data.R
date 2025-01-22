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
  
  # --- Capture arguments properly ---
  group_var_sym <- enquo(group_var)     # Capture unquoted
  sum_var_sym   <- enquo(sum_var)       # Capture unquoted
  
  # Error if no group_var is provided
  if (rlang::quo_is_missing(group_var_sym) || rlang::as_label(group_var_sym) == "") {
    stop("Please provide a 'group_var'.")
  }
  
  # Generate a random seed
  seed <- sample(1:10000, 1)
  set.seed(seed)
  
  # Convert high_group_var to list of symbols if provided
  higher_group_syms <- if (!is.null(high_group_var) && length(high_group_var) > 0) {
    syms(high_group_var)
  } else {
    NULL
  }
  
  # Convert group_var to string for later usage
  group_var_name <- as_label(group_var_sym)
  
  # Step 1: Compute Proportions
  df_proportion <- data %>%
    # Convert group_var to character
    mutate(
      !!group_var_sym == as.character(!!group_var_sym)
    ) %>%
    # Group by high_group_var + group_var
    {
      if (!is.null(higher_group_syms)) {
        group_by(.,
                 !!!higher_group_syms,
                 !!group_var_sym)
      } else {
        group_by(.,
                 !!group_var_sym)
      }
    } %>%
    summarise(
      n = if (quo_is_null(sum_var_sym)) {
        n() 
      } else {
        sum(!!sum_var_sym)
      },
      .groups = 'drop'
    ) %>%
    # Regroup by high_group_var to compute proportions
    {
      if (!is.null(higher_group_syms)) {
        group_by(.,
                 !!!higher_group_syms)
      } else {
        .
      }
    } %>%
    mutate(prop = n / sum(n)) %>%
    ungroup()
  
  # Optional: Validate that proportions sum to 1
  if (!is.null(higher_group_syms)) {
    validation <- df_proportion %>%
      group_by(across(all_of(high_group_var))) %>%
      summarise(total_prop = sum(prop), .groups = "drop")
    
    if (any(abs(validation$total_prop - 1) > 1e-6)) {
      warning("Proportions within some groups do not sum to 1.")
    }
  } else {
    total_prop <- sum(df_proportion$prop)
    if (abs(total_prop - 1) > 1e-6) {
      warning("Proportions do not sum to 1.")
    }
  }
  
  # Step 2: Sampling
  # If we have high_group_var
  if (!is.null(higher_group_syms)) {
    
    vector_sample <- df_proportion %>%
      group_by(across(all_of(high_group_var))) %>%
      nest() %>%
      mutate(
        sample = map(data, ~ sample(
          x      = .x[[group_var_name]],
          size   = sample_size,
          replace = TRUE,
          prob   = .x$prop
        ))
      ) %>%
      select(-data) %>%
      unnest(cols = c(sample)) %>%
      rename(type = sample) %>% 
      group_by(across(all_of(high_group_var))) %>%
      mutate(pos = row_number()) %>%
      ungroup()
    
    df_sample <- as.data.frame(vector_sample)
    
  } else {
    # If no high_group_var, perform global sampling
    df_sample <- data.frame(
      type = sample(
        x      = df_proportion[[group_var_name]],
        size   = sample_size,
        replace = TRUE,
        prob   = df_proportion$prop
      ),
      pos = 1:sample_size
    )
  }
  
  # Left join
  if (!is.null(higher_group_syms)) {
    # Construct a named vector for joining
    join_by <- c("type" = group_var_name, setNames(high_group_var, high_group_var))
    
    df_final <- left_join(df_sample, df_proportion, by = join_by) %>%
      unite("group", all_of(high_group_var), sep = "_", remove = TRUE)
    
  } else {
    # Handle case without high_group_var
    join_by <- c("type" = group_var_name)
    df_final <- left_join(df_sample, df_proportion, by = join_by)
    df_final <- df_final %>% select(-pos)
  }
  
  return(df_final)
}
