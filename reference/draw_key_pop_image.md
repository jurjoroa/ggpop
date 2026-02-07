# Key drawing function for population-based image keys

Key drawing function for population-based image keys

## Usage

``` r
draw_key_pop_image(data, params, size, stroke_width = NULL)
```

## Arguments

- data:

  A data frame containing the scaled aesthetics for the key. It must
  include a `colour` column for color, an `alpha` column for
  transparency, and an `icon` column with the names of the icon files
  (without extension) to be used.

- params:

  A list of additional parameters supplied to the geom.

- size:

  The width and height of the key in mm. This value is not used directly
  in this function.

- stroke_width:

  Numeric. Width of the black outline/border around icons in pixels. If
  NULL or 0, no outline is drawn. Default is NULL.

## Value

A grid grob containing the image icons with the specified colors and
transparency.

## Details

This function creates a custom key for displaying population-based image
icons in the legend of a ggplot2 plot. Each group can be assigned a
different icon based on the information in the `data$icon` column, and
the icons can be colorized according to the specified `colour` and
`alpha` aesthetics. Optionally supports black outlines via the
`stroke_width` parameter.

Icons are automatically scaled to fill the available legend box space
while preserving their aspect ratio. Wide icons fill horizontally, tall
icons fill vertically.

If `stroke_width` is provided, icons are rendered directly with
FontAwesome's stroke parameter for consistent appearance between plot
and legend.
