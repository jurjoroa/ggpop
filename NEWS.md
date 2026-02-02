# ggpop

`ggpop` is an R package built on top of `ggplot2` that simplifies the creation of engaging, icon-based population charts. By combining features from `ggplot2` and `ggimage`, `ggpop` lets users easily visualize population data using proportional, customizable icons arranged in intuitive, circular layouts. The package also includes functionality for adding clear, icon-enhanced captions, which makes charts easier to understand and visually attractive. Designed primarily for visual storytelling, `ggpop` helps users communicate complex population statistics in a straightforward and appealing manner.

# ggpop 1.6.0

This release of `ggpop` introduces significant enhancements including a new geom function for flexible data plotting, improved DPI handling, new customization options for Font Awesome icons, and multiple bug fixes to enhance stability and user experience.

## Bug Fixes

- Fixed draw_key function to prefer packaged PNG icons when available and cache icons in temp directory, ensuring CI environment compatibility and avoiding unnecessary regeneration (#189).
- Fixed arrange argument functionality in `geom_pop`, ensuring proper icon arrangement behavior (#191).
- Fixed legend icon size rendering to ensure consistent display across different scenarios (#199).
- Fixed `facet_wrap` bug to ensure proper faceting behavior in plots (#201).
- Fixed `geom_pop` to work properly when aesthetics are specified in the main `aes()` call (#214).
- Fixed DPI parameter to properly control icon rendering quality (#220).
- Fixed `geom_icon_point` DPI parameter which wasn't updating quality as expected (#224).
- Fixed `scale_legend_icon` margin clipping issue to prevent legend icons from being cut off (#205).
- Fixed aspect ratio preservation in icon rendering for both `geom_pop` and `draw_key_image` functions (#230).

## Improvements

- Improved internal implementation by removing reliance on `last_plot()` from pipeline and `geom_pop`, enhancing code reliability and avoiding potential side effects (#195).
- Enhanced unit tests to improve code coverage and reliability (#187).
- Improved README with additional examples demonstrating package capabilities and use cases, including faceting and geofacet scenarios (#204).
- Updated unit tests with robustness checks to ensure stable behavior across different use cases (#216).
- Added comprehensive unit tests for `geom_icon_point` to ensure proper functionality (#223).

## New Features

- Added new `geom_icon_point` function to allow users to plot any data freely with icons, providing greater flexibility beyond population-specific visualizations (#212).
- Added `stroke_width` parameter to control the thickness of Font Awesome icons, enabling more customization options (#217).

## Issues Resolved in v1.6.0

Issues are listed in chronological merge order.

- #189
- #191
- #195
- #199
- #201
- #187
- #204
- #212
- #214
- #217
- #220
- #216
- #224
- #223
- #205
- #230

## Version

- #211

# ggpop 1.5.1

This release of `ggpop` includes critical bug fixes and improvements to enhance stability, usability, and documentation.

## Bug Fixes

- Fixed draw_key function to prefer packaged PNG icons when available and cache icons in temp directory, ensuring CI environment compatibility and avoiding unnecessary regeneration (#189).
- Fixed arrange argument functionality in `geom_pop`, ensuring proper icon arrangement behavior (#191).
- Fixed legend icon size rendering to ensure consistent display across different scenarios (#199).
- Fixed `facet_wrap` bug to ensure proper faceting behavior in plots (#201).

## Improvements

- Improved internal implementation by removing reliance on `last_plot()` from pipeline and `geom_pop`, enhancing code reliability and avoiding potential side effects (#195).
- Enhanced `scale_legend_icon` documentation to clarify that it serves as a wrapper for `guides`, allowing users to specify all options directly (#115).
- Added comprehensive unit tests to improve code coverage and reliability (#187).
- Improved README with additional examples demonstrating package capabilities and use cases (#204).

## Issues Resolved in v1.5.1

Issues are listed in chronological merge order.

- #189
- #191
- #195
- #199
- #201
- #187
- #115
- #204

## Version

- #186