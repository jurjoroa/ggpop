# ggpop

`ggpop` is an R package built on top of `ggplot2` that simplifies the creation of engaging, icon-based population charts. By combining features from `ggplot2` and `ggimage`, `ggpop` lets users easily visualize population data using proportional, customizable icons arranged in intuitive, circular layouts. The package also includes functionality for adding clear, icon-enhanced captions, which makes charts easier to understand and visually attractive. Designed primarily for visual storytelling, `ggpop` helps users communicate complex population statistics in a straightforward and appealing manner.

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
Issues related to "Upload final set of parameters" or "Prerelease version vX.X.X"
are intentionally excluded.

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

# ggpop 1.5.0

This release of `ggpop` introduces a set of targeted updates to the `geom_pop`
function in `R/geom_pop.R`, addressing multiple reported issues related to icon
rendering, size handling, validation logic, and internal refactoring. The changes
improve robustness, consistency, and maintainability while preserving expected
user-facing behavior unless explicitly noted.

## Bug Fixes

- Fixed legend icon assignment in faceted plots, ensuring correct icon mapping
  under faceting conditions by introducing dynamic legend icon assignment (#168).

## Improvements

- Refactored input validation and user guidance infrastructure by introducing
  validation and warning functions, improving error messages with actionable
  fixes (#162).
- Enhanced icon rendering compatibility by adding `rsvg` dependency and improving
  legend customization support (#164).
- Refactored facet argument processing to accept both symbol and string inputs
  (e.g., `facet = sex` or `facet = "sex"`), improving flexibility (#166).
- Renamed `quality` parameter to `dpi` for clarity, indicating it refers to
  image pixel height rather than subjective quality (#161).
- Enhanced input validation by enforcing maximum of 1000 icons per plot or facet
  group, changing default `sample_size` from 1000 to 100, and renaming internal
  size variables to avoid collisions (#152).
- Improved facet handling with auto-inferred facet variables from `facet_wrap`
  or `facet_grid`, treating multiple groups as internal facets when no explicit
  facet is provided (#173).
- Enforced mandatory icon specification with clear error messages, added hard
  stop for `dpi` values below 30 to prevent blurry icons, and enhanced warnings
  for ambiguous input scenarios (#175).
- Improved error messages throughout with actionable fixes and examples, changed
  icon PNG file writing to use temporary cache directory instead of package
  directory, and standardized internal column naming conventions (#179).

## New Features

- Added support for raw dataframes without requiring `process_data()`, with
  automatic mode detection and type inference for user convenience (#177).

## Breaking Changes

- Changed default `icon` from `"default"` to `"ggmale"` and default `size` from
  `1` to `3` in `geom_pop`. This may affect existing code relying on previous
  default values (#162).

## Issues Resolved in v1.5.0

Issues are listed in chronological merge order.
Issues related to "Upload final set of parameters" or "Prerelease version vX.X.X"
are intentionally excluded.

- #162
- #164
- #166
- #168
- #161
- #152
- #173
- #175
- #177
- #179

## Version

- #151
