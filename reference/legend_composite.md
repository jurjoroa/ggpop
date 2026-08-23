# Build a bordered composite legend in one call

Opinionated wrapper over
[`legend_canvas`](https://jurjoroa.github.io/ggpop/reference/legend_canvas.md) +
[`legend_box`](https://jurjoroa.github.io/ggpop/reference/legend_box.md)
for the recurring three-section legend (an icon grid, a block of colour
tiles, and a small typed-symbol key). You supply the *content*
(`df_legend`) and the strip size; the wrapper applies a fixed proportion
ladder
([`legend_ratios`](https://jurjoroa.github.io/ggpop/reference/legend_ratios.md))
driven by three base sizes, centres the content in the strip, and fits a
border to the rendered result.

Every layout length is a multiple of one `module`; every text size is a
multiple of one `text` base; icons use one `marker` size. A `label_size`
column on the symbol-section rows is read as multiples of `text`.

The base sizes are calibrated for a `base_width`-inch strip and are
scaled by `width / base_width`, so a legend keeps identical proportions
at any output `width` - pass your width and the text, markers, and
layout all follow. The group and symbol blocks may hold more entries
than the grid has rows; the border grows to enclose whichever section
runs deepest.

The group colour swatches are rectangles in data coordinates, so
shrinking `content_range` to make sparse content fill a wide strip
stretches them into banners while the fixed-size icons stay put.
`legend_composite()` warns (class `"ggpop_swatch_aspect_warning"`) when
the rendered swatch aspect ratio gets banner-like, pointing you to raise
`content_range` or reduce `width` - keep sparse legends compact rather
than stretched.

## Usage

``` r
legend_composite(
  df_legend,
  width,
  height,
  grid_title = NULL,
  group_title = NULL,
  grid_section = "grid",
  group_section = "group",
  symbol_section = "symbol",
  module = 0.44294,
  text = 7.756,
  marker = 4.562,
  content_range = 7.21636,
  base_width = 27,
  swatch_height = 0.8,
  fontface = "plain",
  border = "#231F20",
  border_padding = c(0.018, 0.09),
  ratios = legend_ratios(),
  dpi = 300
)
```

## Arguments

- df_legend:

  Legend content, as for
  [`legend_canvas`](https://jurjoroa.github.io/ggpop/reference/legend_canvas.md) -
  grid rows plus optional group/symbol rows, identified by `section`.

- width, height:

  Physical size (inches) of the strip the legend will fill (passed to
  [`legend_box`](https://jurjoroa.github.io/ggpop/reference/legend_box.md)
  and used to size/centre the content).

- grid_title, group_title:

  Section titles (`NULL` = none / inherit).

- grid_section, group_section, symbol_section:

  `section` values that identify each block (defaults `"grid"`,
  `"group"`, `"symbol"`). A missing group/symbol section is skipped.

- module:

  Layout module: one row / one column pitch, in legend units.

- text:

  Base text size (ggplot mm) - the primary label size.

- marker:

  Icon marker size
  ([`geom_icon_point`](https://jurjoroa.github.io/ggpop/reference/geom_icon_point.md)
  units).

- content_range:

  Total data-x range the strip maps to; larger renders a smaller legend.
  The content is centred within it.

- base_width:

  Output width (inches) at which the base sizes (`module`, `text`,
  `marker`, `content_range`) are calibrated. Every size is multiplied by
  `width / base_width` so the legend keeps identical proportions at any
  `width` (default `27`). Set `base_width = width` to disable scaling
  and size in absolute units.

- swatch_height:

  Colour-tile height as a fraction of a row.

- fontface:

  Font face for all titles and labels.

- border:

  Border colour (`NA` to skip the border).

- border_padding:

  Length-2 `padding` passed to
  [`legend_box`](https://jurjoroa.github.io/ggpop/reference/legend_box.md).

- ratios:

  Proportion ladder; defaults to
  [`legend_ratios()`](https://jurjoroa.github.io/ggpop/reference/legend_ratios.md).

- dpi:

  Icon render resolution.

## Value

A `ggplot` with a fitted border, ready for
[`legend_strip`](https://jurjoroa.github.io/ggpop/reference/legend_strip.md).

## See also

[`legend_canvas`](https://jurjoroa.github.io/ggpop/reference/legend_canvas.md),
[`legend_box`](https://jurjoroa.github.io/ggpop/reference/legend_box.md),
[`legend_ratios`](https://jurjoroa.github.io/ggpop/reference/legend_ratios.md),
[`legend_strip`](https://jurjoroa.github.io/ggpop/reference/legend_strip.md)
