# Add Custom Captions with Icons to a geom_pop object

The `caption_pop` function allows you to add custom captions to a
`geom_pop` object. The function generates a caption based on the images
used in the plot. The caption includes the number of individuals
represented by each image. The function also allows you to specify the
size of the caption text and the icons used in the caption.

## Usage

``` r
caption_pop(caption_size = 1, icon_size = 1, hjust = 0.5, text = NULL)
```

## Arguments

- caption_size:

  Numeric. The font size of the caption text. Default is `3`.

- icon_size:

  Numeric. The width of the images (icons) in pixels within the caption.
  Default is `20`.

- hjust:

  Numeric. The horizontal justification of the caption. Values range
  from `0` (left) to `1` (right). Default is `0.5`.

- text:

  Named list or named vector. Custom text descriptions for each icon.
  The names should correspond to the `image` identifiers in the plot
  data. If `NULL`, defaults to `"persons"`.
