# Render a composite legend specification

Render a composite legend specification

## Usage

``` r
legend_render(spec, width, height)
```

## Arguments

- spec:

  A
  [`legend_spec()`](https://jurjoroa.github.io/ggpop/reference/legend_spec.md)
  object.

- width, height:

  Physical legend size in inches.

## Value

A ggplot with a border fitted to the final content.

## See also

[`legend_spec()`](https://jurjoroa.github.io/ggpop/reference/legend_spec.md)

## Examples

``` r
grid <- data.frame(row = 1, col = 1, icon = "square-inset", label = "A")
spec <- legend_spec(grid, keys = c(Group = "#1090F3"))
legend_render(spec, width = 7, height = 1.5)
```
