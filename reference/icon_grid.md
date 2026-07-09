# Build icon grid rows from plot data

Derives the icon row/column positions from the unique combinations in
`df`, returning a plain data frame ready to
[`rbind()`](https://rdrr.io/r/base/cbind.html) with group and symbol
rows before passing to
[`legend_canvas`](https://jurjoroa.github.io/ggpop/reference/legend_canvas.md).

## Usage

``` r
icon_grid(df, icon, label, row, col, label_fn = NULL, section = "grid")
```

## Arguments

- df:

  Data frame used in the ggplot call.

- icon:

  Column name holding icon names.

- label:

  Column name holding cell labels.

- row:

  Column whose unique values define grid rows.

- col:

  Column whose unique values define grid columns.

- label_fn:

  Optional function applied to label values before display.

- section:

  Value for the `section` column (default `"grid"`).

## Value

A data frame with columns `section`, `type`, `label`, `color`, `icon`,
`row`, `col`. Rows are sorted by row then column (factor level order
respected).

## See also

[`legend_canvas`](https://jurjoroa.github.io/ggpop/reference/legend_canvas.md)

## Examples

``` r
# \donttest{
# df_icons <- icon_grid(
#   df, icon = "icon", label = "AgeLabel",
#   row = "StartAge", col = "StopAge",
#   label_fn = function(x) gsub(" ", "", x)
# )
# }
```
