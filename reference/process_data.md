# Process Population Data for Visualization

The `process_data` function processes a dataset to calculate group
proportions and generates a sampled dataset based on specified
parameters. This processed data is suitable for creating visual
representations, such as population charts, where each sample represents
a group with associated counts and proportions.

## Usage

``` r
process_data(
  data,
  high_group_var = NULL,
  group_var = NULL,
  sum_var = NULL,
  sample_size = 100
)
```

## Arguments

- data:

  A data frame containing the population data to be processed.

- high_group_var:

  Character vector, optional. The variables used to group individuals
  hierarchically. This should be a categorical variable. If provided,
  the function samples individuals within each group defined by these
  variables.

- group_var:

  Quosure. The variable used to group individuals in the dataset. This
  should be a categorical variable.

- sum_var:

  Quosure, optional. The variable to sum over within each group. If
  `NULL`, the function counts the number of individuals per group.

- sample_size:

  Integer. The total number of individuals to sample based on group
  proportions. Must be a positive integer.

## Value

A tibble (data frame) with the following columns:

- type:

  The sampled group type.

- group:

  The group identifier.

- n:

  The count of individuals in the group.

- prop:

  The proportion of the group relative to the total population.
