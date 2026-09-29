# Add a typed symbol row to a composite legend specification

The new row is appended to the symbol section without changing `spec`.
Render the returned specification to measure its border after the new
row.

## Usage

``` r
legend_add_key(
  spec,
  label,
  type = "line",
  colour = "black",
  linetype = "solid",
  linewidth = 0.8,
  pch = NA
)
```

## Arguments

- spec:

  A
  [`legend_spec()`](https://jurjoroa.github.io/ggpop/reference/legend_spec.md)
  object.

- label:

  Text beside the symbol.

- type:

  One of `"line"`, `"point"`, `"swatch"`, or `"text"`.

- colour:

  Colour of the symbol.

- linetype, linewidth:

  Line style and width for a line row.

- pch:

  Character or numeric point glyph for a point row.

## Value

A new `ggpop_legend_spec` object.

## See also

[`legend_spec()`](https://jurjoroa.github.io/ggpop/reference/legend_spec.md),
[`legend_subset()`](https://jurjoroa.github.io/ggpop/reference/legend_subset.md),
[`legend_render()`](https://jurjoroa.github.io/ggpop/reference/legend_render.md)

## Examples

``` r
grid <- data.frame(row = 1, col = 1, icon = "square-inset", label = "A")
spec <- legend_spec(grid, symbols = c(Frontier = "line"))
legend_add_key(spec, "Capacity", type = "line", linetype = "dashed")
#> $grid
#>   row col         icon label section
#> 1   1   1 square-inset     A    grid
#> 
#> $keys
#> NULL
#> 
#> $symbols
#>   type    label color linetype linewidth pch
#> 1 line Frontier black    solid       0.8  NA
#> 2 line Capacity black   dashed       0.8  NA
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
#> $xlim
#> NULL
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
