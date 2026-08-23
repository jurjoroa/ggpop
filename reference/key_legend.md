# Add typed symbol entries to a legend canvas

Adds a column of symbol + label entries to an existing `ggplot` canvas
(typically the output of
[`marker_legend`](https://jurjoroa.github.io/ggpop/reference/marker_legend.md))
using the same
[`ggplot2::annotate()`](https://ggplot2.tidyverse.org/reference/annotate.html)
approach. The coordinate system is shared with the base plot, so
positions integrate seamlessly with the rest of the legend.

Three entry types are supported:

- swatch:

  A filled rectangle (colour bands, modality tiles).

- line:

  A horizontal segment (frontier or trend lines).

- point:

  A bold `"*"` glyph rendered as text.

A fourth entry kind, `icon`, exists in
[`legend_canvas`](https://jurjoroa.github.io/ggpop/reference/legend_canvas.md)'s
`df_legend` vocabulary but is not a `key_legend()` type - icon rows are
rendered separately via
[`marker_legend`](https://jurjoroa.github.io/ggpop/reference/marker_legend.md).

**Two y-placement modes:**

- `y_start = NULL` (default) - first entry is placed at the
  section-title row (`row_spacing * title_frac`), matching the position
  where
  [`marker_legend()`](https://jurjoroa.github.io/ggpop/reference/marker_legend.md)
  puts section headers. Use this when entry\\1 is both the title and its
  own symbol (e.g. the "Efficient frontier" line entry).

- `y_start = 0` - first entry at row\\1, second at `-row_spacing`, etc.
  Use this with a text-only `title`.

## Usage

``` r
key_legend(
  entries,
  x = 0,
  y_start = NULL,
  title = NULL,
  title_frac = 0.85,
  row_spacing = 1,
  key_width = 1.2,
  label_gap = 0.3,
  label_size = 2.8,
  label_color = "black",
  label_inside = FALSE,
  label_fontface = "plain",
  title_color = NULL,
  swatch_height = 0.45,
  point_size = 1.6
)
```

## Arguments

- entries:

  A data frame with columns `type` (`"swatch"`, `"line"`, or `"point"`),
  `label`, and `color` (or `colour`). Optional columns: `linetype`
  (default `"solid"`), `linewidth` (default `0.8`), `pch` (default `NA`
  -\> draws `"*"` for `type = "point"`).

- x:

  Left edge of the key-symbol column in plot coordinates.

- y_start:

  Y coordinate of the first entry. `NULL` (default) places entry\\1 at
  `row_spacing * title_frac`.

- title:

  Optional text-only section title drawn at `row_spacing * title_frac`,
  centred over the key column.

- title_frac:

  Y-fraction used for the section-title row (default `0.85`, matching
  [`marker_legend()`](https://jurjoroa.github.io/ggpop/reference/marker_legend.md)).

- row_spacing:

  Vertical distance between rows. Match the `row_spacing` passed to
  [`marker_legend`](https://jurjoroa.github.io/ggpop/reference/marker_legend.md).

- key_width:

  Horizontal width of the key symbol area.

- label_gap:

  Gap between the key symbol and the label text.

- label_size:

  Text size (passed to
  [`ggplot2::annotate()`](https://ggplot2.tidyverse.org/reference/annotate.html)).

- label_color:

  Colour of label text.

- label_inside:

  When `TRUE`, centres the label inside the key symbol instead of beside
  it. Only takes effect for `swatch` rows (default `FALSE`).

- label_fontface:

  Font face for the title and entry labels (default `"plain"`). Common
  values: `"plain"`, `"bold"`, `"italic"`. Does not affect the
  `"point"`-type `"*"` glyph, which is always bold.

- title_color:

  Colour of the section title. Inherits `label_color` when `NULL` (the
  default).

- swatch_height:

  Height of swatch rectangles as a fraction of `row_spacing` (default
  `0.45`).

- point_size:

  Size multiplier for point glyphs relative to `label_size` (default
  `1.6`).

## Value

A `ggpop_key_legend` object. Add it to any `ggplot` with `+` to inject
the annotate layers onto that canvas. Print it (or use it standalone) to
render a self-contained legend panel.

## See also

[`marker_legend`](https://jurjoroa.github.io/ggpop/reference/marker_legend.md)

## Examples

``` r
# \donttest{
library(ggplot2)
s  <- 0.78
rs <- 0.34 * s

ef <- data.frame(
  type  = c("line",               "swatch",    "point"),
  label = c("Efficient frontier", "Grey zone",  "Near efficient"),
  color = c("black",              "grey50",     "black"),
  stringsAsFactors = FALSE
)

# Standalone panel:
print(key_legend(ef, row_spacing = rs, key_width = 0.22))


# Added to a marker_legend canvas:
# p <- marker_legend(age_entries, ...) +
#        key_legend(ef, x = 1.10, row_spacing = rs, key_width = 0.22)
# }
```
