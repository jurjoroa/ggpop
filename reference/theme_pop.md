# Population Plot Theme

A minimal theme optimized for icon-based population plots. Similar to
[`theme_void()`](https://ggplot2.tidyverse.org/reference/ggtheme.html)
but with automatic legend key sizing, appropriate margins, and sensible
defaults for population visualizations.

## Usage

``` r
theme_pop(
  base_size = 11,
  base_family = "",
  base_line_size = base_size/22,
  base_rect_size = base_size/22,
  legend_icon_size = NULL,
  legend_spacing = NULL,
  plot_margin = NULL,
  legend_position = "right"
)
```

## Arguments

- base_size:

  Base font size in points (default: 11).

- base_family:

  Base font family (default: "").

- base_line_size:

  Base size for line elements (default: base_size/22).

- base_rect_size:

  Base size for rect elements (default: base_size/22).

- legend_icon_size:

  Size of legend icons in cm. If NULL (default), automatically
  calculated as base_size/20 for proportional sizing.

- legend_spacing:

  Spacing between legend items in cm (default: 0.3 \* legend_icon_size).

- plot_margin:

  Plot margins. Default: margin(5.5, 5.5, 5.5, 5.5, "pt"). Can be a
  single numeric (applied to all sides) or margin() object.

- legend_position:

  Position of legend: "none", "left", "right", "bottom", "top" (default:
  "right").

## Value

A ggplot2 theme object.

## Examples

``` r
if (FALSE) { # \dontrun{
# Basic usage
ggplot(data = df, aes(icon = icon, color = type)) +
  geom_pop(size = 1) +
  theme_pop()

# Large text with bottom legend
ggplot(data = df, aes(icon = icon, color = type)) +
  geom_pop(size = 1) +
  theme_pop(base_size = 40, legend_position = "bottom")
} # }
```
