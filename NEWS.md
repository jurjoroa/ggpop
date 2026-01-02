# ggpop

`ggpop` is an R package built on top of `ggplot2` that simplifies the creation of engaging, icon-based population charts. By combining features from `ggplot2` and `ggimage`, `ggpop` lets users easily visualize population data using proportional, customizable icons arranged in intuitive, circular layouts. The package also includes functionality for adding clear, icon-enhanced captions, which makes charts easier to understand and visually attractive. Designed primarily for visual storytelling, `ggpop` helps users communicate complex population statistics in a straightforward and appealing manner.

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

# ggpop 1.4.0

This `ggpop` version introduces significant enhancements to the `geom_pop` function in `R/geom_pop.R`, featuring improvements in icon quality and dynamic size mapping. Key updates include refining the code by eliminating redundant statements, allowing for a new `quality` parameter to control PNG icon height, and managing dynamic size mapping without requiring `I()`. Additional modifications involve relocating icon downloads for overwriting flexibility, streamlining the code for better readability, ensuring the proper functioning of the `size` parameter, and improving directory handling for PNG file generation. Overall, these changes aim to enhance the robustness and usability of the function while ensuring accurate file management.

## Bug Fixes  

- Removed unnecessary lines and ensured proper handling of the `size` parameter within the function.  
- Added logic to create directories if needed when generating PNG files, ensuring that the directory structure is in place before attempting to write the files.  

## Improvements  

- Erased the double and if-else statements to make it more compact.  
- Removed the multiplication by 100 if the user doesn't specify a scale icon legend.  
- Cleaned up extra lines to improve readability.  

## New Features  

- Added a new parameter `quality` to allow users to change the height of the icon for improved quality or display fewer icons.  
- Introduced logic to handle dynamic size mapping without requiring the use of `I()`, leveraging variable extraction from the quosure and applying scaling to the size column.  

## Breaking Changes  

- Relocated the download of the icon outside of the if statement, allowing for overwriting if the user changes the quality.

## Issues Resolved in v1.4.0

-   #141
-   #142

## Version

-   #140
