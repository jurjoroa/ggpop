# Dark Population Plot Theme

A dark variant of theme_pop() with white text on black background.
Perfect for presentations or dark-mode visualizations.

## Usage

``` r
theme_pop_dark(
  base_size = 11,
  base_family = "",
  base_line_size = base_size/22,
  base_rect_size = base_size/22,
  legend_icon_size = NULL,
  legend_spacing = NULL,
  plot_margin = NULL,
  legend_position = "right",
  bg_color = "black",
  text_color = "white"
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

- bg_color:

  Background color (default: "black").

- text_color:

  Text color (default: "white").

## Value

A ggplot2 theme object.

## Examples

``` r
if (FALSE) { # \dontrun{
ggplot(data = df, aes(icon = icon, color = type)) +
  geom_pop(size = 1) +
  theme_pop_dark(base_size = 40)
} # }
```
