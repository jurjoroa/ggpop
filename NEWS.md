# ggpop

`ggpop` is an R package built on top of `ggplot2` that simplifies the creation of engaging, icon-based population charts. By combining features from `ggplot2` and `ggimage`, `ggpop` lets users easily visualize population data using proportional, customizable icons arranged in intuitive, circular layouts. The package also includes functionality for adding clear, icon-enhanced captions, which makes charts easier to understand and visually attractive. Designed primarily for visual storytelling, `ggpop` helps users communicate complex population statistics in a straightforward and appealing manner.

# ggpop 1.3.1

This version corrects typo sizes regarding how the icons are displayed in the plot, how the paths are define and the margin of the plots when the legend is render. 

## Bug Fixes

-   Corrected a typo in the `draw_key_pop_image` function name in `R/draw_key.R`.
-   Fixed paths in `geom_pop` that made the icons not plot from native icons or from `fontawesome` package.

## Improvements

-  Added a `margin` parameter to the `scale_legend_icon` function to allow customization of plot margins.
- * Simplified the `grid::rasterGrob` call within the `draw_key_pop_image` function by removing redundant width specification.

## New Features

-   No new features were introduced in this version.

## Breaking Changes

-   No breaking changes in this version.

## Issues Resolved in v1.3.1

-   #137
-   #139

## Version

-   #136
