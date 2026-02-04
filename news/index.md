# Changelog

## ggpop 1.6.0

This release of `ggpop` introduces significant enhancements including a
new geom function for flexible data plotting, improved DPI handling, new
customization options for Font Awesome icons, and multiple bug fixes to
enhance stability and user experience.

### Bug Fixes

- Fixed draw_key function to prefer packaged PNG icons when available
  and cache icons in temp directory, ensuring CI environment
  compatibility and avoiding unnecessary regeneration
  ([\#189](https://github.com/jurjoroa/ggpop/issues/189)).
- Fixed arrange argument functionality in `geom_pop`, ensuring proper
  icon arrangement behavior
  ([\#191](https://github.com/jurjoroa/ggpop/issues/191)).
- Fixed legend icon size rendering to ensure consistent display across
  different scenarios
  ([\#199](https://github.com/jurjoroa/ggpop/issues/199)).
- Fixed `facet_wrap` bug to ensure proper faceting behavior in plots
  ([\#201](https://github.com/jurjoroa/ggpop/issues/201)).
- Fixed `geom_pop` to work properly when aesthetics are specified in the
  main [`aes()`](https://ggplot2.tidyverse.org/reference/aes.html) call
  ([\#214](https://github.com/jurjoroa/ggpop/issues/214)).
- Fixed DPI parameter to properly control icon rendering quality
  ([\#220](https://github.com/jurjoroa/ggpop/issues/220)).
- Fixed `geom_icon_point` DPI parameter which wasn’t updating quality as
  expected ([\#224](https://github.com/jurjoroa/ggpop/issues/224)).
- Fixed `scale_legend_icon` margin clipping issue to prevent legend
  icons from being cut off
  ([\#205](https://github.com/jurjoroa/ggpop/issues/205)).
- Fixed aspect ratio preservation in icon rendering for both `geom_pop`
  and `draw_key_image` functions
  ([\#230](https://github.com/jurjoroa/ggpop/issues/230)).

### Improvements

- Improved internal implementation by removing reliance on
  [`last_plot()`](https://ggplot2.tidyverse.org/reference/get_last_plot.html)
  from pipeline and `geom_pop`, enhancing code reliability and avoiding
  potential side effects
  ([\#195](https://github.com/jurjoroa/ggpop/issues/195)).
- Enhanced unit tests to improve code coverage and reliability
  ([\#187](https://github.com/jurjoroa/ggpop/issues/187)).
- Improved README with additional examples demonstrating package
  capabilities and use cases, including faceting and geofacet scenarios
  ([\#204](https://github.com/jurjoroa/ggpop/issues/204)).
- Updated unit tests with robustness checks to ensure stable behavior
  across different use cases
  ([\#216](https://github.com/jurjoroa/ggpop/issues/216)).
- Added comprehensive unit tests for `geom_icon_point` to ensure proper
  functionality ([\#223](https://github.com/jurjoroa/ggpop/issues/223)).

### New Features

- Added new `geom_icon_point` function to allow users to plot any data
  freely with icons, providing greater flexibility beyond
  population-specific visualizations
  ([\#212](https://github.com/jurjoroa/ggpop/issues/212)).
- Added `stroke_width` parameter to control the thickness of Font
  Awesome icons, enabling more customization options
  ([\#217](https://github.com/jurjoroa/ggpop/issues/217)).

### Issues Resolved in v1.6.0

Issues are listed in chronological merge order.

- \#189
- \#191
- \#195
- \#199
- \#201
- \#187
- \#204
- \#212
- \#214
- \#217
- \#220
- \#216
- \#224
- \#223
- \#205
- \#230

### Version

- \#211

## ggpop 1.5.1

This release of `ggpop` includes critical bug fixes and improvements to
enhance stability, usability, and documentation.

### Bug Fixes

- Fixed draw_key function to prefer packaged PNG icons when available
  and cache icons in temp directory, ensuring CI environment
  compatibility and avoiding unnecessary regeneration
  ([\#189](https://github.com/jurjoroa/ggpop/issues/189)).
- Fixed arrange argument functionality in `geom_pop`, ensuring proper
  icon arrangement behavior
  ([\#191](https://github.com/jurjoroa/ggpop/issues/191)).
- Fixed legend icon size rendering to ensure consistent display across
  different scenarios
  ([\#199](https://github.com/jurjoroa/ggpop/issues/199)).
- Fixed `facet_wrap` bug to ensure proper faceting behavior in plots
  ([\#201](https://github.com/jurjoroa/ggpop/issues/201)).

### Improvements

- Improved internal implementation by removing reliance on
  [`last_plot()`](https://ggplot2.tidyverse.org/reference/get_last_plot.html)
  from pipeline and `geom_pop`, enhancing code reliability and avoiding
  potential side effects
  ([\#195](https://github.com/jurjoroa/ggpop/issues/195)).
- Enhanced `scale_legend_icon` documentation to clarify that it serves
  as a wrapper for `guides`, allowing users to specify all options
  directly ([\#115](https://github.com/jurjoroa/ggpop/issues/115)).
- Added comprehensive unit tests to improve code coverage and
  reliability ([\#187](https://github.com/jurjoroa/ggpop/issues/187)).
- Improved README with additional examples demonstrating package
  capabilities and use cases
  ([\#204](https://github.com/jurjoroa/ggpop/issues/204)).

### Issues Resolved in v1.5.1

Issues are listed in chronological merge order. Issues related to
“Upload final set of parameters” or “Prerelease version vX.X.X” are
intentionally excluded.

- \#189
- \#191
- \#195
- \#199
- \#201
- \#187
- \#115
- \#204

### Version

- \#186
