# Select content from a composite legend specification

Creates a new specification without changing `spec`. Grid rows are
renumbered from one so the selected grid stays compact. Render the
result with
[`legend_render()`](https://jurjoroa.github.io/ggpop/reference/legend_render.md)
after selecting its final content.

## Usage

``` r
legend_subset(
  spec,
  grid_rows = NULL,
  keys = NULL,
  symbols = NULL,
  key_columns = NULL,
  group_gap = spec$group_gap,
  group_title_nudge = spec$group_title_nudge,
  xlim = spec$xlim
)
```

## Arguments

- spec:

  A
  [`legend_spec()`](https://jurjoroa.github.io/ggpop/reference/legend_spec.md)
  object.

- grid_rows:

  Grid row positions to keep, in display order. `NULL` keeps every row.

- keys:

  Names of colour keys to keep, in display order. `NULL` keeps all.

- symbols:

  Symbol labels to keep, in display order. `NULL` keeps all.

- key_columns:

  Number of colour-key columns in the result. When `keys` is supplied,
  the default is one; otherwise the original count is kept.

- group_gap, group_title_nudge, xlim:

  Optional layout overrides. Each inherits from `spec` when omitted. Set
  `xlim = NULL` to recompute the horizontal limits for the selected
  content.

## Value

A new `ggpop_legend_spec` object.

## See also

[`legend_spec()`](https://jurjoroa.github.io/ggpop/reference/legend_spec.md),
[`legend_add_key()`](https://jurjoroa.github.io/ggpop/reference/legend_add_key.md),
[`legend_render()`](https://jurjoroa.github.io/ggpop/reference/legend_render.md)

## Examples

``` r
grid <- data.frame(row = c(1, 2), col = c(1, 1),
                   icon = c("square-inset", "circle-solid"),
                   label = c("A", "B"))
spec <- legend_spec(grid, keys = c(One = "#1090F3", Two = "#DF4601"))
legend_subset(spec, grid_rows = 1, keys = "One")
#> $grid
#>   row col         icon label section
#> 1   1   1 square-inset     A    grid
#> 
#> $keys
#>       One 
#> "#1090F3" 
#> 
#> $symbols
#> NULL
#> 
#> $key_columns
#> [1] 1
#> 
#> $grid_title
#> NULL
#> 
#> $group_title
#> NULL
#> 
#> $symbol_title
#> NULL
#> 
#> $group_key_width
#> [1] 0.2375
#> 
#> $group_label_gap
#> [1] 0.1187
#> 
#> $group_gap
#> [1] 0.591
#> 
#> $key_column_gap
#> [1] 0.317
#> 
#> $group_title_nudge
#> [1] 0
#> 
#> $swatch_height
#> [1] 0.56
#> 
#> $label_size
#> [1] 3.634
#> 
#> $label_fontface
#> [1] "plain"
#> 
#> $marker_size
#> [1] 3.717
#> 
#> $dpi
#> [1] 120
#> 
#> $ratios
#> $ratios$col_spacing
#> [1] 0.986
#> 
#> $ratios$row_spacing
#> [1] 1
#> 
#> $ratios$label_gap
#> [1] 0.167
#> 
#> $ratios$group_width
#> [1] 1.065
#> 
#> $ratios$group_gap
#> [1] 0.365
#> 
#> $ratios$symbol_right_gap
#> [1] 0.875
#> 
#> $ratios$symbol_key_width
#> [1] 0.567
#> 
#> $ratios$symbol_label_gap
#> [1] 0.06
#> 
#> $ratios$group_label
#> [1] 0.933
#> 
#> $ratios$label
#> [1] 1
#> 
#> 
#> $border
#> [1] "#231F20"
#> 
#> $border_padding
#> [1] 0.018 0.090
#> 
#> attr(,"class")
#> [1] "ggpop_legend_spec"
```
