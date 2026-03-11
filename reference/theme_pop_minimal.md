# Minimal Population Plot Theme

An ultra-minimal variant with no margins or legend, perfect for icon
arrays without annotations.

## Usage

``` r
theme_pop_minimal(base_size = 11, base_family = "")
```

## Arguments

- base_size:

  Base font size in points (default: 11).

- base_family:

  Base font family (default: "").

## Value

A ggplot2 theme object.

## Examples

``` r
# \donttest{
library(ggplot2)
df <- data.frame(
  type = rep(c("A", "B"), each = 10),
  icon = rep(c("circle", "square"), each = 10)
)
ggplot(data = df, aes(icon = icon, color = type)) +
  geom_pop(size = 1) +
  theme_pop_minimal()

# }
```
