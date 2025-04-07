# ggpop

`ggpop` is an R package built on top of `ggplot2` that simplifies the creation of engaging, icon-based population charts. By combining features from `ggplot2` and `ggimage`, `ggpop` lets users easily visualize population data using proportional, customizable icons arranged in intuitive, circular layouts. The package also includes functionality for adding clear, icon-enhanced captions, which makes charts easier to understand and visually attractive. Designed primarily for visual storytelling, `ggpop` helps users communicate complex population statistics in a straightforward and appealing manner.

# ggpop 1.3.0

This version delivers major enhancements to icon handling and documentation clarity. Most notably, it improves the efficiency of Font Awesome icon rendering—reducing plot rendering time by up to 90%. A dedicated `key/` directory has been introduced to organize legend icons, and the README has been significantly refined to guide users more effectively.

## Bug Fixes

-   Fixed inconsistencies in icon file paths used for legend generation.
-   Resolved rendering issues caused by SVG icons by switching to PNG format.

## Improvements

-   Updated icon handling in `draw_key_pop_image()` to use a centralized `key/` directory for consistency.
-   Changed icon format from SVG to PNG in `geom_pop()` to enhance compatibility and performance:
    -   Improved rendering speed by up to 90% for Font Awesome icons.
-   Improved README.md:
    -   Revised package description to better emphasize visual storytelling and usability.
    -   Added detailed explanation of icon handling.
    -   Included performance benchmarks comparing Font Awesome icons and native icons.
    -   Enhanced example code to include the `legend_icons` parameter for a more complete demo.

## New Features

-   No new features were introduced in this version.

## Breaking Changes

-   No breaking changes in this version.

## Issues Resolved in v1.3.0

-   #127
-   #129
-   #131

## Version

-   #26
