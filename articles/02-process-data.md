# process_data()

[`process_data()`](https://jurjoroa.github.io/ggpop/reference/process_data.md)
converts a count-based data frame to one row per icon. `group_var` and
`sum_var` are unquoted (tidy eval); `high_group_var` takes a character
string.

``` r

df_raw <- data.frame(
  sex = c("Female", "Male"),
  n   = c(55, 45)
)

df_plot <- process_data(
  data        = df_raw,
  group_var   = sex,
  sum_var     = n,
  sample_size = 20
)

head(df_plot, 4)
#>     type  n prop
#> 1 Female 55 0.55
#> 2   Male 45 0.45
#> 3 Female 55 0.55
#> 4 Female 55 0.55
```

The result has one row per icon. The `type` column carries the original
group label and is what you map to `color` and `icon` in
[`geom_pop()`](https://jurjoroa.github.io/ggpop/reference/geom_pop.md).

## With `high_group_var`

Use `high_group_var` when your data has a faceting variable. It samples
independently within each panel so proportions are correct per group.

``` r

df_region_raw <- data.frame(
  region = c("North", "North", "South", "South"),
  sex    = c("Female", "Male", "Female", "Male"),
  n      = c(30, 20, 25, 25)
)

df_region <- process_data(
  data           = df_region_raw,
  group_var      = sex,
  sum_var        = n,
  sample_size    = 20,
  high_group_var = "region"
)

head(df_region, 4)
#>   group   type  n prop
#> 1 North Female 30  0.6
#> 2 North Female 30  0.6
#> 3 North Female 30  0.6
#> 4 North Female 30  0.6
```

The `group` column in the output contains the panel label — pass it to
`facet_wrap(~group)` and `geom_pop(facet = group)`.
