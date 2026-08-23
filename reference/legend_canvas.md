# Build a composite legend from a plain data frame

Renders a legend from a data frame that combines icon grid rows (built
with
[`icon_grid`](https://jurjoroa.github.io/ggpop/reference/icon_grid.md)),
colour tile rows, and typed-symbol rows via
[`rbind()`](https://rdrr.io/r/base/cbind.html). Layout parameters
determine where each section is positioned. The `scale` parameter
multiplies all size and spacing values so the data frame can be written
in round numbers.

## Usage

``` r
legend_canvas(
  df_legend,
  grid_section = "grid",
  grid_title = NULL,
  group_section = NULL,
  group_title = NULL,
  group_width = NULL,
  group_gap = 0.08,
  group_label_size = NA_real_,
  group_label_color = "white",
  group_swatch_height = 0.44,
  symbol_section = NULL,
  symbol_right_gap = 0.3,
  symbol_key_width = 0.2,
  symbol_label_gap = NULL,
  col_spacing,
  row_spacing,
  label_gap,
  marker_size,
  label_size,
  label_fontface = "plain",
  scale = 1,
  label_scale = 1,
  dpi = 300,
  xlim = NULL,
  ylim = NULL,
  x_margin = c(1, 1),
  align = NULL,
  y_margin = c(1.1, 1.1),
  valign = NULL,
  clip = "off"
)
```

## Arguments

- df_legend:

  Data frame with columns `section`, `type`, `label`, `color`, `icon`,
  `row`, `col`. Optional columns: `label_size`, `lineheight`. `type`
  selects how a row renders and which columns it needs:

  icon

  :   An icon marker (via
      [`geom_icon_point`](https://jurjoroa.github.io/ggpop/reference/geom_icon_point.md))
      placed at `row`/`col`. Only meaningful inside `grid_section`;
      requires `icon`, `row`, `col`.

  swatch

  :   A filled rectangle - colour tiles, frontier bands. Requires
      `color`.

  line

  :   A horizontal line segment - e.g. an efficient-frontier sample.
      Requires `color`.

  point

  :   A bold `"*"` glyph (or a custom character via an optional `pch`
      column). Requires `color`.

  `swatch`/`line`/`point` rows are rendered by
  [`key_legend`](https://jurjoroa.github.io/ggpop/reference/key_legend.md) -
  add a new type there, not here. `icon` rows go through
  [`marker_legend`](https://jurjoroa.github.io/ggpop/reference/marker_legend.md)
  instead, a separate path.

- grid_section:

  Value of `section` identifying icon grid rows (default `"grid"`).

- grid_title:

  Title drawn above the icon grid (`NULL` = none).

- group_section:

  Value of `section` identifying colour tile rows. `NULL` skips the
  group section.

- group_title:

  Title drawn above the colour tiles. Inherits `group_section` when
  `NULL`.

- group_width:

  Width of the colour tile section (scaled by `scale`).

- group_gap:

  Gap between the tile right edge and `x = 0` (scaled by `scale`).

- group_label_size:

  Label size inside tiles; inherits `label_size` (after scaling) when
  `NA`.

- group_label_color:

  Label colour inside tiles (default `"white"`).

- group_swatch_height:

  Tile height as fraction of `row_spacing` (default `0.44`).

- symbol_section:

  Value of `section` identifying typed-symbol rows. `NULL` skips the
  symbol section.

- symbol_right_gap:

  Gap between icon grid right edge and symbol section (default `0.30`;
  scaled by `scale`).

- symbol_key_width:

  Width of the key symbol area (default `0.20`; scaled by `scale`).

- symbol_label_gap:

  Gap between key symbol and label; inherits `label_gap` (after scaling)
  when `NULL`.

- col_spacing:

  Horizontal distance between icon grid columns.

- row_spacing:

  Vertical distance between rows.

- label_gap:

  Default gap between key symbol and label.

- marker_size:

  Icon size for the grid.

- label_size:

  Default label text size.

- label_fontface:

  Font face for every title and label in the legend (grid title, group
  title/tile labels, symbol title/labels) - default `"plain"`. Common
  values: `"plain"`, `"bold"`, `"italic"`. Does not affect the
  `"point"`-type `"*"` glyph, which is always bold.

- scale:

  Multiplier applied to every length and size: `col_spacing`,
  `row_spacing`, `label_gap`, `marker_size`, `label_size` (and its
  `df_legend` column), `group_width`, `group_gap`, `group_label_size`,
  `symbol_right_gap`, `symbol_key_width`, and `symbol_label_gap`.
  Because it scales the whole legend uniformly, every length can be
  written as a plain multiple of one base module and `scale` sizes the
  result (default `1`).

- label_scale:

  Extra multiplier applied on top of `scale` to the text sizes only -
  `label_size`, `group_label_size`, and the `label_size` column in
  `df_legend` - leaving marker and spacing sizes untouched. Use to
  enlarge/shrink every label relative to the markers from one place
  (default `1`).

- dpi:

  Icon render resolution (default `300`).

- xlim:

  Length-2 numeric; x limits of the canvas. Auto-computed when `NULL`.

- ylim:

  Length-2 numeric; y limits of the canvas. Auto-computed when `NULL` to
  enclose whichever section reaches deepest - the grid rows, the group
  tiles, or the symbol keys - so a group/symbol block with more entries
  than the grid has rows is not clipped.

- x_margin:

  Length-2 numeric: left/right padding added to auto x range (default
  `c(1.00, 1.00)`, i.e. centred). Ignored when `xlim` is supplied
  directly; overridden when `align` is set. A `symbol_section`'s labels
  extend right of `x_right` with no accounting for label width, so the
  default is sized generously enough to hold typical labels without
  clipping - not the smallest margin that centres the nominal content
  bounds.

- align:

  Optional convenience for biasing `x_margin`: one of `"center"` (equal
  left/right padding), `"left"` (small left / large right padding), or
  `"right"` (large left / small right padding). Redistributes
  `sum(x_margin)` between the two sides - the total padding is
  unchanged, only its left/right split. `NULL` (default) leaves
  `x_margin` untouched.

- y_margin:

  Length-2 numeric: top/bottom padding as multiples of (scaled)
  `row_spacing` (default `c(1.1, 1.1)`, i.e. centred). Ignored when
  `ylim` is supplied directly; overridden when `valign` is set.

- valign:

  Optional convenience for biasing `y_margin`: one of `"center"` (equal
  top/bottom padding), `"top"` (small top / large bottom padding), or
  `"bottom"` (large top / small bottom padding). Redistributes
  `sum(y_margin)` between the two sides, the same way `align`
  redistributes `x_margin`. `NULL` (default) leaves `y_margin`
  untouched.

- clip:

  Passed to `coord_cartesian` (default `"off"`).

## Value

A `ggplot` ready to save or pass to
[`legend_strip`](https://jurjoroa.github.io/ggpop/reference/legend_strip.md).

## See also

[`icon_grid`](https://jurjoroa.github.io/ggpop/reference/icon_grid.md),
[`key_legend`](https://jurjoroa.github.io/ggpop/reference/key_legend.md),
[`legend_strip`](https://jurjoroa.github.io/ggpop/reference/legend_strip.md)
