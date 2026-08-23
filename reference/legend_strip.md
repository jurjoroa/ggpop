# Attach a legend strip below a ggplot

Returns a `ggpop_legend_strip` object. When added to a `ggplot` with
`+`, produces a `ggpop_composite` that stacks the main plot above the
strip at the specified physical height. The composite works with
[`ggplot2::ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html)
and [`print()`](https://rdrr.io/r/base/print.html). The main plot (the
object `legend_strip()` is added to) may itself be a `patchwork` object
(e.g. several panels combined with
`+`/[`plot_layout`](https://patchwork.data-imaginist.com/reference/plot_layout.html))

- this requires the patchwork package to be installed.

## Usage

``` r
legend_strip(strip_plot, height)
```

## Arguments

- strip_plot:

  A `ggplot` to render as the bottom strip (e.g. the output of
  [`marker_legend`](https://jurjoroa.github.io/ggpop/reference/marker_legend.md)).

- height:

  Height of the strip in inches.

## Value

A `ggpop_legend_strip` object; add it to a `ggplot` with `+`.

## See also

[`marker_legend`](https://jurjoroa.github.io/ggpop/reference/marker_legend.md),
[`key_legend`](https://jurjoroa.github.io/ggpop/reference/key_legend.md)

## Examples

``` r
# \donttest{
# p_legend <- marker_legend(entries, ...) + key_legend(...)
# p_full   <- p_scatter + legend_strip(p_legend, height = 1.326)
# ggplot2::ggsave("out.png", p_full, width = 10.5, height = 8.826, dpi = 150)
# }
```
