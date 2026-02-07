# Create a circular representative population chart

Draws a circular representative population chart based on the proportion
of the groups, where each point (person) represents a determined number
of individuals. Every person is represented by an image with a given
icon.

## Usage

``` r
geom_pop(
  mapping = NULL,
  data = NULL,
  stat = "identity",
  position = "identity",
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE,
  icon = "ggmale",
  group_var = NULL,
  sample_size = NULL,
  arrange = FALSE,
  seed = NULL,
  sum_var = NULL,
  facet = NULL,
  size = 1,
  dpi = 50,
  legend_icons = TRUE,
  stroke_width = NULL,
  ...
)
```

## Arguments

- mapping:

  Set of aesthetic mappings created by
  [`aes()`](https://ggplot2.tidyverse.org/reference/aes.html). If
  specified and `inherit.aes = TRUE` (the default), it is combined with
  the default mapping at the top level of the plot. You must supply
  `mapping` if there is no plot mapping.

- data:

  The data to be displayed in this layer. There are three options:

  If `NULL`, the default, the data is inherited from the plot data as
  specified in the call to
  [`ggplot()`](https://ggplot2.tidyverse.org/reference/ggplot.html).

  A `data.frame`, or other object, will override the plot data. All
  objects will be fortified to produce a data frame. See
  [`fortify()`](https://ggplot2.tidyverse.org/reference/fortify.html)
  for which variables will be created.

  A `function` will be called with a single argument, the plot data. The
  return value must be a `data.frame`, and will be used as the layer
  data. A `function` can be created from a `formula` (e.g.
  `~ head(.x, 10)`).

- stat:

  The statistical transformation to use on the data for this layer. When
  using a `geom_*()` function to construct a layer, the `stat` argument
  can be used to override the default coupling between geoms and stats.
  The `stat` argument accepts the following:

  - A `Stat` ggproto subclass, for example `StatCount`.

  - A string naming the stat. To give the stat as a string, strip the
    function name of the `stat_` prefix. For example, to use
    [`stat_count()`](https://ggplot2.tidyverse.org/reference/geom_bar.html),
    give the stat as `"count"`.

  - For more information and other ways to specify the stat, see the
    [layer
    stat](https://ggplot2.tidyverse.org/reference/layer_stats.html)
    documentation.

- position:

  A position adjustment to use on the data for this layer. This can be
  used in various ways, including to prevent overplotting and improving
  the display. The `position` argument accepts the following:

  - The result of calling a position function, such as
    [`position_jitter()`](https://ggplot2.tidyverse.org/reference/position_jitter.html).
    This method allows for passing extra arguments to the position.

  - A string naming the position adjustment. To give the position as a
    string, strip the function name of the `position_` prefix. For
    example, to use
    [`position_jitter()`](https://ggplot2.tidyverse.org/reference/position_jitter.html),
    give the position as `"jitter"`.

  - For more information and other ways to specify the position, see the
    [layer
    position](https://ggplot2.tidyverse.org/reference/layer_positions.html)
    documentation.

- na.rm:

  logical, whether remove NA values

- show.legend:

  logical. Should this layer be included in the legends? `NA`, the
  default, includes if any aesthetics are mapped. `FALSE` never
  includes, and `TRUE` always includes. It can also be a named logical
  vector to finely select the aesthetics to display. To include legend
  keys for all levels, even when no data exists, use `TRUE`. If `NA`,
  all levels are shown in legend, but unobserved levels are omitted.

- inherit.aes:

  If `FALSE`, overrides the default aesthetics, rather than combining
  with them. This is most useful for helper functions that define both
  data and aesthetics and shouldn't inherit behaviour from the default
  plot specification, e.g.
  [`annotation_borders()`](https://ggplot2.tidyverse.org/reference/annotation_borders.html).

- icon:

  The icon to be used in the chart.

- group_var:

  The variable used to group individuals.

- sample_size:

  The total number of individuals (points) to be drawn.

- arrange:

  Logical; if TRUE, the output data is arranged by group.

- seed:

  Optional numeric seed used only when `arrange = FALSE` (randomized
  layouts).

- sum_var:

  Optional variable to sum over instead of counting.

- facet:

  Optional facetting variable. NOTE: final plot must be faceted; enforce
  with `validate_geom_pop_faceting(p)` after building the ggplot object.

- size:

  The size of the points.

- dpi:

  Height (in **pixels**) of the PNG icon when rendered with
  [`fontawesome::fa_png()`](https://rstudio.github.io/fontawesome/reference/fa_png.html).
  Higher values produce sharper icons. Defaults to 50. This affects
  **image dpi**, not icon size in the plot.

- legend_icons:

  Logical; if TRUE, the legend will display the selected icons by the
  user.

- stroke_width:

  Numeric. Width of the black outline/border around icons in pixels.

- ...:

  additional parameters

## Value

A ggplot layer with a circular representative population chart.

## Aesthetics

geom_pop employs the following aesthetics:

- **sample_size** - The number of individuals to be represented in the
  chart.

- **alpha** - The transparency of the points.

- **color** - The color of the points.

- **size** - The size of the points.
