# Legend helper for geom_pop/geom_icon_point legends

A convenience function to set appropriate legend key sizes for
icon-based legends. This is equivalent to using theme(legend.key.size =
...) but provides sensible defaults for population icon plots.

## Usage

``` r
scale_legend_icon(
  size = 10,
  unit = "mm",
  spacing = 0.2,
  size_multiplier = 2,
  ...
)
```

## Arguments

- size:

  Numeric. Legend key size in specified units (default 10).

- unit:

  Character. Unit for legend key sizing (default "mm").

- spacing:

  Numeric. Spacing between legend items as fraction of size (default
  0.2).

- size_multiplier:

  Numeric. Multiplier to apply to the size for spacing calculations
  (default 2).

- ...:

  Additional theme arguments.

## Value

A ggplot2 theme object that can be added to a plot.

## Examples

``` r
# \donttest{
library(ggplot2)
df <- data.frame(
  type = rep(c("A", "B"), each = 10),
  icon = rep(c("circle", "square"), each = 10)
)
ggplot(df, aes(icon = icon, color = type)) +
  geom_pop() +
  scale_legend_icon(size = 20)

# }
```
