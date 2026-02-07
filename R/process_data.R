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
#' @importFrom tidyr nest unnest unite
#' @importFrom purrr map
#' @importFrom stats setNames
#' @importFrom rlang enquo quo_is_null as_label syms ensym
#'
#' @export

process_data <- function(data,
                         high_group_var = NULL,
                         group_var,
                         sum_var = NULL,
                         sample_size = 100) {
  # ---- VALIDATE data ----
  if (is.null(data)) {
    stop("Argument 'data' is required and cannot be NULL.", call. = FALSE)
  }

  if (!inherits(data, c("data.frame", "data.table", "tbl_df", "tbl"))) {
    stop("Argument 'data' must be a data.frame, data.table, or tibble.", call. = FALSE)
  }

  if (nrow(data) == 0) {
    stop("Argument 'data' cannot be empty (0 rows).", call. = FALSE)
  }

  # Check if data has at least one column
  if (ncol(data) == 0) {
    stop("Argument 'data' must have at least one column.", call. = FALSE)
  }

  # ---- VALIDATE sample_size ----
  if (!is.numeric(sample_size) || length(sample_size) != 1L || is.na(sample_size) ||
    sample_size <= 0 || sample_size > 1000 || sample_size %% 1 != 0) {
    stop("`sample_size` must be a single integer between 1 and 1000.")
  }
  sample_size <- as.integer(sample_size)

  # ---- VALIDATE group_var ----
  group_var_sym <- tryCatch(
    rlang::enquo(group_var),
    error = function(e) {
      if (grepl("missing", e$message)) {
        stop("Please provide a 'group_var'.", call. = FALSE)
      } else {
        stop(e$message, call. = FALSE)
      }
    }
  )

  if (rlang::quo_is_null(group_var_sym) ||
    rlang::quo_is_missing(group_var_sym) ||
    rlang::as_label(group_var_sym) == "" ||
    rlang::as_label(group_var_sym) == "NULL") {
    stop("Please provide a valid 'group_var'.", call. = FALSE)
  }

  # Check if group_var exists in data
  group_var_name <- rlang::as_label(group_var_sym)
  if (!group_var_name %in% names(data)) {
    stop("`group_var` '", group_var_name, "' not found in data.", call. = FALSE)
  }

  # Check if group_var has at least one non-NA value
  if (all(is.na(data[[group_var_name]]))) {
    stop("`group_var` '", group_var_name, "' contains only NA values.", call. = FALSE)
  }

  # Check if group_var has at least 2 unique values
  unique_groups <- length(unique(data[[group_var_name]][!is.na(data[[group_var_name]])]))
  if (unique_groups < 1) {
    stop("`group_var` '", group_var_name, "' must have at least one unique value.", call. = FALSE)
  }

  # ---- VALIDATE high_group_var ----
  if (!is.null(high_group_var)) {
    # NEW: Check if high_group_var is character vector
    if (!is.character(high_group_var)) {
      stop("`high_group_var` must be a character vector.", call. = FALSE)
    }

    # Check if all high_group_var columns exist in data
    missing_cols <- high_group_var[!high_group_var %in% names(data)]
    if (length(missing_cols) > 0) {
      stop("`high_group_var` column(s) not found in data: ",
        paste(missing_cols, collapse = ", "),
        call. = FALSE
      )
    }

    # Check if high_group_var contains group_var
    if (group_var_name %in% high_group_var) {
      stop("`high_group_var` cannot contain the same variable as `group_var` ('",
        group_var_name, "').",
        call. = FALSE
      )
    }

    # Check for duplicates in high_group_var
    if (any(duplicated(high_group_var))) {
      stop("`high_group_var` contains duplicate column names.", call. = FALSE)
    }

    # Warn if high_group_var has all NA values in any column
    for (col in high_group_var) {
      if (all(is.na(data[[col]]))) {
        warning("`high_group_var` column '", col, "' contains only NA values.",
          call. = FALSE
        )
      }
    }
  }

  # ---- VALIDATE sum_var ----
  sum_var_sym <- rlang::enquo(sum_var)

  if (!rlang::quo_is_null(sum_var_sym)) {
    sum_var_name <- rlang::as_label(sum_var_sym)

    if (!sum_var_name %in% names(data)) {
      stop("`sum_var` '", sum_var_name, "' not found in data.", call. = FALSE)
    }

    if (!is.numeric(data[[sum_var_name]])) {
      stop("`sum_var` must be a numeric column. Column '",
        sum_var_name, "' is of type '",
        class(data[[sum_var_name]])[1], "'.",
        call. = FALSE
      )
    }

    # Check for NAs and warn
    if (any(is.na(data[[sum_var_name]]))) {
      warning("`sum_var` '", sum_var_name, "' contains NA values. These will be excluded from calculations.",
        call. = FALSE
      )
    }

    # Check for all zeros or all NAs
    sum_values <- sum(data[[sum_var_name]], na.rm = TRUE)
    if (sum_values == 0 || is.na(sum_values)) {
      stop("`sum_var` cannot be all zeros or all NAs. Cannot compute proportions.",
        call. = FALSE
      )
    }

    # Check for negative values
    if (any(data[[sum_var_name]] < 0, na.rm = TRUE)) {
      warning("`sum_var` '", sum_var_name, "' contains negative values.",
        call. = FALSE
      )
    }

    # Check if sum_var is the same as group_var
    if (sum_var_name == group_var_name) {
      stop("`sum_var` cannot be the same as `group_var`.", call. = FALSE)
    }
  }

  # Generate a random seed
  seed <- sample(1:10000, 1)
  set.seed(seed)

  # Convert high_group_var to list of symbols if provided
  higher_group_syms <- if (!is.null(high_group_var) && length(high_group_var) > 0) {
    rlang::syms(high_group_var)
  } else {
    NULL
  }

  # Convert group_var to string for later usage
  group_var_name <- rlang::as_label(group_var_sym)

  # Step 1: Compute Proportions
  df_proportion <- data %>%
    # Convert group_var to character
    mutate(
      !!group_var_sym := as.character(!!group_var_sym)
    ) %>%
    # Group by high_group_var + group_var
    {
      if (!is.null(higher_group_syms)) {
        group_by(
          .,
          !!!higher_group_syms,
          !!group_var_sym
        )
      } else {
        group_by(
          .,
          !!group_var_sym
        )
      }
    } %>%
    summarise(
      n = if (rlang::quo_is_null(sum_var_sym)) {
        n()
      } else {
        sum(!!sum_var_sym, na.rm = TRUE)
      },
      .groups = "drop"
    ) %>%
    # Regroup by high_group_var to compute proportions
    {
      if (!is.null(higher_group_syms)) {
        group_by(
          .,
          !!!higher_group_syms
        )
      } else {
        .
      }
    } %>%
    mutate(prop = n / sum(n)) %>%
    ungroup() %>%
    # Filter out invalid proportions
    filter(!is.na(prop), prop > 0, is.finite(prop))

  # Optional: Validate that proportions sum to 1
  # REPLACE THIS ENTIRE SECTION:
  if (!is.null(higher_group_syms)) {
    validation <- df_proportion %>%
      group_by(across(all_of(high_group_var))) %>%
      summarise(total_prop = sum(prop, na.rm = TRUE), .groups = "drop") # <-- CHANGED

    # Check if any proportions don't sum to 1 (excluding NAs)
    invalid_props <- validation$total_prop[!is.na(validation$total_prop)] # <-- CHANGED
    if (length(invalid_props) > 0 && any(abs(invalid_props - 1) > 1e-6)) { # <-- CHANGED
      warning("Proportions within some groups do not sum to 1.", call. = FALSE)
    }
  } else {
    total_prop <- sum(df_proportion$prop, na.rm = TRUE) # <-- CHANGED

    # Only check if total_prop is not NA
    if (!is.na(total_prop) && abs(total_prop - 1) > 1e-6) { # <-- CHANGED
      warning("Proportions do not sum to 1.", call. = FALSE)
    }
  }

  # Step 2: Sampling
  # If we have high_group_var
  if (!is.null(higher_group_syms)) {
    vector_sample <- df_proportion %>%
      group_by(across(all_of(high_group_var))) %>%
      tidyr::nest() %>%
      mutate(
        sample = map(data, ~ sample(
          x = .x[[group_var_name]],
          size = sample_size,
          replace = TRUE,
          prob = .x$prop
        ))
      ) %>%
      select(-data) %>%
      tidyr::unnest(cols = c(sample)) %>%
      rename(type = sample) %>%
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
        replace = TRUE,
        prob = df_proportion$prop
      ),
      pos = 1:sample_size
    )
  }

  # Left join
  if (!is.null(higher_group_syms)) {
    # Construct a named vector for joining
    join_by <- c("type" = group_var_name, stats::setNames(high_group_var, high_group_var))

    df_final <- left_join(df_sample, df_proportion, by = join_by) %>%
      tidyr::unite("group", all_of(high_group_var), sep = "_", remove = TRUE)
  } else {
    # Handle case without high_group_var
    join_by <- c("type" = group_var_name)
    df_final <- left_join(df_sample, df_proportion, by = join_by)
    df_final <- df_final %>% select(-pos)
  }

  return(df_final)
}
