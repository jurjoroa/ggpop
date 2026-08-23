# Draw a border tightly around a composite legend's rendered content

[`legend_canvas`](https://jurjoroa.github.io/ggpop/reference/legend_canvas.md)
positions its sections from nominal geometry, but text labels overflow
their anchor points by an amount that depends on the font, the label
strings, and the final output size - none of which are known when the
layers are built. A border drawn from that nominal geometry therefore
clips the labels. `legend_box()` sidesteps this by rendering the legend
once at the intended output size, measuring the true pixel extent of the
drawn content, mapping it back to data coordinates, and adding a border
rectangle around it.

Because it renders once to measure, the border reflects exactly what
will be drawn - long labels, mixed fonts, any content - with no
per-figure hand tuning.

## Usage

``` r
legend_box(
  plot,
  width,
  height,
  padding = c(0.02, 0.12),
  colour = "black",
  linewidth = 0.7,
  fill = NA,
  threshold = 150,
  dpi = 150
)
```

## Arguments

- plot:

  A `ggplot` (typically
  [`legend_canvas`](https://jurjoroa.github.io/ggpop/reference/legend_canvas.md)
  output) whose coordinate system supplies fixed `xlim`/`ylim`
  ([`legend_canvas()`](https://jurjoroa.github.io/ggpop/reference/legend_canvas.md)
  always does). Add `legend_box()` last, after any other layers, so it
  encloses everything.

- width, height:

  Physical size in inches of the region the legend will be drawn in for
  the final export - pass the same values used there so the measured
  text width matches. For a
  [`legend_strip`](https://jurjoroa.github.io/ggpop/reference/legend_strip.md)
  legend this is the full figure width and the strip `height`.

- padding:

  Length-2 numeric: gap between content and border, as fractions of the
  measured content width and height (default `c(0.02, 0.12)`).

- colour:

  Border colour (default `"black"`).

- linewidth:

  Border line width (default `0.7`).

- fill:

  Border fill (default `NA`, i.e. transparent).

- threshold:

  Grayscale ink cutoff (0-255) for detecting content; pixels darker than
  this count as content (default `150`).

- dpi:

  Resolution of the internal measurement render (default `150`); higher
  is more precise but slower.

## Value

`plot` with a border `ggplot2::annotate("rect", ...)` layer added.

## See also

[`legend_canvas`](https://jurjoroa.github.io/ggpop/reference/legend_canvas.md),
[`legend_strip`](https://jurjoroa.github.io/ggpop/reference/legend_strip.md)
