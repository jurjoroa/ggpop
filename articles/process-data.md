# Preparing Data with process_data()

## What is `process_data()`?

[`process_data()`](https://jurjoroa.github.io/ggpop/reference/process_data.md)
is a helper function that converts raw population counts into a sampled
data frame ready for
[`geom_pop()`](https://jurjoroa.github.io/ggpop/reference/geom_pop.md).
Each row in the output represents one icon in the final chart.

It handles:

- Calculating group proportions from raw counts
- Proportionally allocating a fixed sample size across groups
- Supporting hierarchical grouping via `high_group_var`

Show the code

``` r
library(ggpop)
library(ggplot2)
library(dplyr)
```

------------------------------------------------------------------------

## Basic Usage

The minimum inputs are `data`, `group_var` (the grouping column), and
`sum_var` (the count column). `sample_size` controls how many icons
appear in the final chart (max 1,000).

Show the code

``` r
df_sex <- data.frame(
  sex = c("male", "female"),
  n   = c(63459580, 67401427)
)

df_sex_proc <- process_data(
  data        = df_sex,
  group_var   = sex,
  sum_var     = n,
  sample_size = 100
)

head(df_sex_proc)
```

        type        n      prop
    1 female 67401427 0.5150612
    2 female 67401427 0.5150612
    3 female 67401427 0.5150612
    4   male 63459580 0.4849388
    5 female 67401427 0.5150612
    6   male 63459580 0.4849388

The output contains:

- **type**: group label (from `group_var`)
- **n**: total count for that group
- **prop**: proportion of the total
- One row per sampled icon

------------------------------------------------------------------------

## Understanding Proportions

[`process_data()`](https://jurjoroa.github.io/ggpop/reference/process_data.md)
calculates each group’s share of the total and allocates icons
proportionally. With `sample_size = 100`, a group with 48% of the
population gets ~48 icons.

Show the code

``` r
df_sex_proc %>%
  group_by(type) %>%
  summarise(
    icons      = n(),
    proportion = round(mean(prop) * 100, 1)
  )
```

    # A tibble: 2 × 3
      type   icons proportion
      <chr>  <int>      <dbl>
    1 female    56       51.5
    2 male      44       48.5

------------------------------------------------------------------------

## Multiple Groups

Works with any number of groups — not just two.

Show the code

``` r
df_regions <- data.frame(
  region = c("North", "South", "East", "West"),
  n      = c(12000, 8000, 15000, 5000)
)

df_regions_processed <- process_data(
  data        = df_regions,
  group_var   = region,
  sum_var     = n,
  sample_size = 100
)

df_regions_processed %>%
  group_by(type) %>%
  summarise(icons = n())
```

    # A tibble: 4 × 2
      type  icons
      <chr> <int>
    1 East     33
    2 North    30
    3 South    22
    4 West     15

------------------------------------------------------------------------

## Hierarchical Grouping with `high_group_var`

Use `high_group_var` to nest groups under a higher-level category. This
is useful when you want to facet by a parent group while preserving
sub-group icon assignments.

Show the code

``` r
df_health <- data.frame(
  region    = c("North", "South", "East", "West",
                "North", "South", "East", "West"),
  status    = c(rep("Healthy", 4), rep("At Risk", 4)),
  n         = c(8000, 6000, 9000, 4000,
                4000, 2000, 6000, 1000)
)

df_health_processed <- process_data(
  data           = df_health,
  group_var      = status,
  sum_var        = n,
  high_group_var = "region",
  sample_size    = 100
)

df_health_processed %>%
  group_by(group, type) %>%
  summarise(icons = n(), .groups = "drop")
```

    # A tibble: 8 × 3
      group type    icons
      <chr> <chr>   <int>
    1 East  At Risk    48
    2 East  Healthy    52
    3 North At Risk    25
    4 North Healthy    75
    5 South At Risk    25
    6 South Healthy    75
    7 West  At Risk    21
    8 West  Healthy    79

------------------------------------------------------------------------

## Skipping `process_data()`

[`process_data()`](https://jurjoroa.github.io/ggpop/reference/process_data.md)
is optional. If your data already has one row per icon, pass it directly
to
[`geom_pop()`](https://jurjoroa.github.io/ggpop/reference/geom_pop.md).
The only requirement is a maximum of 1,000 rows per plot (or per facet
group).

Show the code

``` r
df_direct <- data.frame(
  status = c(rep("Healthy", 70), rep("At Risk", 20), rep("Ill", 10)),
  icon   = c(rep("person", 70), rep("person-half-dress", 20), rep("bed-pulse", 10))
)

# Pass directly — no process_data() needed
ggplot() +
  geom_pop(
    data = df_direct,
    aes(icon = icon, color = status),
    size = 2, dpi = 100, legend_icons = TRUE
  ) +
  scale_color_manual(values = c(
    "Healthy"  = "#43A047",
    "At Risk"  = "#FFB300",
    "Ill"      = "#E53935"
  )) +
  scale_legend_icon(size = 5) +
  theme_pop() +
  labs(
    title    = "Simulated Patient Population (n = 100)",
    subtitle = "Each icon represents one patient",
    color    = "Status"
  )
```

![](process-data_files/figure-html/skip-1.png)

------------------------------------------------------------------------

## Summary

| Parameter        | Description                             |
|:-----------------|:----------------------------------------|
| `data`           | Input data frame with group counts      |
| `group_var`      | Column to group by (unquoted)           |
| `sum_var`        | Column with population counts           |
| `sample_size`    | Number of icons to generate (max 1,000) |
| `high_group_var` | Optional parent grouping for faceting   |

Visit the [ggpop website](https://jurjoroa.github.io/ggpop/) for the
full function reference.
