# ggpop 1.8.0

## New features

- `geom_pop()` and `geom_icon_point()` now accept custom SVG icons in addition to Font Awesome names. The `icon` aesthetic (or the `icon` parameter) resolves, in priority order, to: a local `.svg` path; a file in your own icon folder (via the new `icon_path` argument or `options(ggpop.icon_path = "<dir>")`), referenced by name just like a Font Awesome icon; a bundled ggpop marker (e.g. `"square-inset"`, `"circle-cross"`, `"diamond-hollow"`); or a Font Awesome name. Monochrome SVGs are recoloured by the mapped colour aesthetic, content-hash cached, and rendered crisply at any `dpi` in both the plot body and the legend keys. An unrecognised name now raises a clear error instead of a cryptic Font Awesome failure (#383).
- `ggpop_markers()` lists the bundled marker names (and the names found in an `icon_path` folder) - the companion to `fa_icons()` (#383).
- `marker_legend()` builds a standalone composite legend of icon markers - multiple columns, mixed icon sources (Font Awesome, bundled markers, or your own SVGs), and room for extra annotations - for cases that ggplot2's built-in guides cannot express. For an ordinary data-driven legend, keep using `legend_icons = TRUE` with `scale_legend_icon()` (#385).

# ggpop 1.7.2

## Bug Fixes

- `geom_pop()` and `geom_icon_point()` now bake the mapped colour directly into each icon at draw time instead of relying on `ggimage`'s tinting. The previous approach depended on the installed `magick`/ImageMagick build producing an RGBA bitmap; when it did not, icons rendered black even though the legend showed the correct colours. Colours (including custom `scale_colour_*()` scales) and per-group transparency are now applied deterministically (#380).

# ggpop 1.7.1

## Bug Fixes

- Fixed a CRAN NOTE caused by `fetch_df_coordinates()` writing a cache file to `~/.cache/R/ggpop/` during package checks. The function now uses `tempdir()` when running on CRAN and the persistent user cache only when `NOT_CRAN=true`.

# ggpop 1.7.0

This release of `ggpop` delivers new theming support, expanded icon customization, critical bug fixes, and significant internal refactoring toward a fully ggplot-native architecture. Deprecated functionality has been removed and the package has been finalized.

## Bug Fixes

- Fixed `stroke_width` having no effect in `geom_icon_point()` when placed inside `aes()`. The validator `validate_stroke_width_not_aesthetic()` was already used in `geom_pop()` but missing from `geom_icon_point()`, causing the parameter to be silently bypassed. Both geoms now warn users to move `stroke_width` outside `aes()` (#353).
- Fixed literal and expression alpha values in `aes()` (e.g. `aes(alpha = 0.5)` or `aes(alpha = col / 10)`) not applying to legend icons. Only column-mapped alpha previously affected the legend; fixed constants and computed expressions are now correctly resolved and applied to both plot icons and legend keys in `geom_pop()` and `geom_icon_point()` (#353).

- Fixed false "Facet / grouping caution" warning and incorrect per-group icon positioning triggered when a user-provided data frame happened to contain a column named `group`. Both the warning and the auto-facet detection are now gated on whether the data was produced by `process_data()`, so raw data frames work correctly regardless of column names (#346).
- Fixed icon size inconsistency across different ggplot2 themes and corrected `scale_legend_icon()` to properly reflect theme settings (#287).
- Fixed legend icon ordering for factor variables mapped to `colour`, ensuring legend icons follow factor level order rather than data row order (#294).
- Fixed icon bleed into unrelated legends in `geom_icon_point()`. Icons were rendered behind fill legend keys because `geom_image` lists `fill` in its default aesthetics, causing ggplot2 to invoke `key_glyph_icon_point` for fill guide keys. Fixed by setting `show.legend = c(colour = ..., fill = FALSE)` to exclude the layer from fill guides, with a fallback guard in `key_glyph_icon_point` returning a blank grob when no icon label matches (#371).
- Fixed icon-label mismatch in `geom_icon_point()` when using a dummy data frame with `inherit.aes = FALSE`. Inherited plot-level mappings were overriding the layer's own mappings in `combined_mapping`, causing icons to resolve alphabetically by icon name instead of by group label. Fixed by giving layer mappings priority over inherited ones (#371).

## Improvements

- Refactored internal geom functions to be fully ggplot-native, using plot-scoped layer computation and removing reliance on `last_plot()` during layer construction (#266).
- Added `validate_alpha_column()` to check all values in a column mapped to alpha at construction time. Values `> 1` or `<= 0` abort with a descriptive message and a rescaling hint; values in `(0, 0.1)` trigger a low-alpha warning (#353).
- Added `validate_literal_alpha_in_aes()` to validate literal and expression alpha values inside `aes()`, applying the same range rules as the fixed `alpha` parameter (#353).
- Added robustness unit tests for the `stroke_width` parameter to validate behavior across edge cases (#269).
- Expanded unit tests for internal helper functions and incorporated code improvements for reliability and maintainability (#275).
- Cleaned up error and warning messages by removing file-level path details, replacing them with concise, user-facing descriptions (#277).
- Normalized icon size calculation to ensure consistent rendering between `geom_pop` and `geom_icon_point` (#282).
- Added unit tests and visual snapshot tests for `scale_legend_icon` to validate legend sizing and rendering behavior (#289).

## New Features

- Added `stroke_width` parameter to `geom_icon_point`, allowing users to control icon outline thickness for improved visual contrast (#268).
- Introduced personalized ggpop themes (e.g., `theme_pop`) for consistent, opinionated plot styling out of the box (#291).
- Added `show.legend` support to `geom_icon_point()` and `geom_pop()`. Passing `show.legend = FALSE` now correctly suppresses the layer's legend entries, matching standard ggplot2 behaviour. The fix sets the argument directly on the layer object after construction, bypassing `ggimage::geom_image()` which does not honour this parameter (#337).
- Added `fa_icons()` to allow users to search and list available Font Awesome icons by name, category, or regex pattern. Results can be returned as a classified tibble or a plain character vector. Icon names are cached session-wide to avoid repeated metadata calls (#340).
- `geom_pop()` now exposes its internally computed coordinates to downstream layers. Geoms such as `geom_text()` and `geom_label()` can be added after `geom_pop()` without specifying `x` and `y` explicitly — they are inherited automatically from the icon grid (#341).

## Breaking Changes

- Removed the deprecated `caption_pop` function. Users should migrate to standard ggplot2 annotation approaches (#279).
- Finalized public function names and key glyph implementations for `geom_pop` and `geom_icon_point`, standardizing the package. Existing code relying on previous internal names may require updates (#281).

## Issues Resolved in v1.7.0

Issues are listed in chronological merge order.

- #266
- #268
- #269
- #275
- #277
- #279
- #281
- #282
- #287
- #289
- #291
- #294
- #337
- #340
- #341
- #346
- #353
- #371

## Version

- #265


**Full Changelog**: https://github.com/jurjoroa/ggpop/compare/v1.6.1...v1.7.0


# ggpop 1.6.1

This release of `ggpop` introduces a set of targeted updates addressing multiple reported issues related to icon rendering, size handling, validation logic, and internal refactoring. The changes improve robustness, consistency, and maintainability while preserving expected user-facing behavior.

## Bug Fixes

- Fixed icon column mapping in `geom_pop` and `geom_icon_point`, ensuring users can map icons from any custom column name without rendering errors or unexpected behavior (#255).
- Fixed aspect ratio preservation in legend icon rendering, ensuring icons scale intelligently within the legend box while maintaining their proportions (#254).

## Improvements

- Refactored `process_data` function with comprehensive input validation, enhanced error handling, and improved calculation of proportions, including proper handling of `NA` values and filtering of invalid data (#243).
- Enhanced legend icon sizing logic to automatically scale icons within the legend box while preserving aspect ratio, with wide icons filling horizontally and tall icons filling vertically (#253).
- Improved error and warning message formatting throughout the package for better readability and consistency, including multi-line formatting and actionable guidance (#253).
- Added comprehensive unit tests for `process_data` function covering various scenarios including hierarchical grouping, input validation, edge cases, and reproducibility (#242).
- Improved code clarity and structure across multiple functions by refactoring argument formatting, removing unnecessary whitespace, and adding thematic sections with comments (#253).
- Enhanced cross-layer validation by moving legend icon consistency checks to the plot-add hook, ensuring all layers are considered when detecting mixed `legend_icons` settings (#258).

## New Features

- Added new `ggplot_add.ggpop_icon_point_layer` method to handle addition of icon point layers with consistency checks for legend icon settings and clear error messages (#258).

## Breaking Changes

- Changed default `size` parameter from `3` to `1` in `geom_icon_point` and `geom_pop` to align with new icon scaling logic. This may affect existing plots relying on the previous default value (#254).

## Issues Resolved in v1.6.1

Issues are listed in chronological merge order.

- #243
- #242
- #254
- #255
- #258
- #253

## Version

- #236


**Full Changelog**: https://github.com/jurjoroa/ggpop/compare/v1.6.0...v1.6.1

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

# ggpop 1.5.0

This release of `ggpop` introduces a set of targeted updates to the `geom_pop` function in `R/geom_pop.R`, addressing multiple reported issues related to icon rendering, size handling, validation logic, and internal refactoring. The changes improve robustness, consistency, and maintainability while preserving expected user-facing behavior unless explicitly noted.

## Bug Fixes

- Fixed legend icon assignment in faceted plots, ensuring correct icon mapping under faceting conditions by introducing dynamic legend icon assignment (#168).

## Improvements

- Refactored input validation and user guidance infrastructure by introducing validation and warning functions, improving error messages with actionable fixes (#162).
- Enhanced icon rendering compatibility by adding `rsvg` dependency and improving legend customization support (#164).
- Refactored facet argument processing to accept both symbol and string inputs (e.g., `facet = sex` or `facet = "sex"`), improving flexibility (#166).
- Renamed `quality` parameter to `dpi` for clarity, indicating it refers to image pixel height rather than subjective quality (#161).
- Enhanced input validation by enforcing maximum of 1000 icons per plot or facet group, changing default `sample_size` from 1000 to 100, and renaming internal size variables to avoid collisions (#152).
- Improved facet handling with auto-inferred facet variables from `facet_wrap` or `facet_grid`, treating multiple groups as internal facets when no explicit facet is provided (#173).
- Enforced mandatory icon specification with clear error messages, added hard stop for `dpi` values below 30 to prevent blurry icons, and enhanced warnings for ambiguous input scenarios (#175).
- Improved error messages throughout with actionable fixes and examples, changed icon PNG file writing to use temporary cache directory instead of package directory, and standardized internal column naming conventions (#179).

## New Features

- Added support for raw dataframes without requiring `process_data()`, with automatic mode detection and type inference for user convenience (#177).

## Breaking Changes

- Changed default `icon` from `"default"` to `"ggmale"` and default `size` from `1` to `3` in `geom_pop`. This may affect existing code relying on previous default values (#162).

## Issues Resolved in v1.5.0

Issues are listed in chronological merge order.

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

**Full Changelog**: https://github.com/jurjoroa/ggpop/compare/v1.4.1...v1.5.0

# ggpop 1.4.1

This `ggpop` version introduces a small bug fix that made the package not install correctly. 

## Bug Fixes  

- Erased a small bug in DESCRIPTION file that made the package not install correctly.

## Issues Resolved in v1.4.1

-   #155

## Version

-   #154

**Full Changelog**: https://github.com/jurjoroa/ggpop/compare/v1.4.0...v1.4.1


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

**Full Changelog**: https://github.com/jurjoroa/ggpop/compare/v1.3.1...v1.4.0



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


**Full Changelog**: https://github.com/jurjoroa/ggpop/compare/v1.3.0...v1.3.1


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




**Full Changelog**: https://github.com/jurjoroa/ggpop/compare/v1.2.1...v1.3.0


# ggpop 1.2.1

This version brings an update to the documentation. We included Ralitza Soultanova, Fernanado Alarid-Escudero and Carlos Pineda-Antunez as new authors. Finally, we fix some documentation issues related to the `ggpop` package.

## Bug fixes

-   We added `fontawesome` as a dependency in the `DESCRIPTION` file. This ensures that the package will work correctly when installed from CRAN or GitHub.
-   `man/draw_key_pop_image.Rd`Added a description and details for the key drawing function for population-based image keys.
-   `man/ggpop-package.Rd`: Added new authors to the documentation.

## Improvements

-   We added Ralitza Soultanova, Fernando Alarid-Escudero and Carlos Pineda-Antunez as new authors in the `DESCRIPTION` file.

## New features

-   There are no new features in this version of `ggpop`.

## Breaking changes

-   There are not any breaking changes in this version of `ggpop`.

## Issues Resolved in v1.2.1

-   #119
-   #120

## Version

-   #118

**Full Changelog**: https://github.com/jurjoroa/ggpop/compare/v1.2.0...v1.2.1

# ggpop 1.2.0

This version brings significant improvements to the `ggpop` function. We are excited to announce that now we can use icons from `fontawesome` in the `ggpop` package. This enhancement allows users to create visually appealing population charts with a wider range of icon options. The "native" icons will stay since they are optimized due to the size of the images.
Also, we modified the key_fn function to improve the legend icon display. Finally, we added cancer native icons due to the focus of our research. These changes aim to streamline icon management and functionality in the codebase.


## Bug fixes

- There are not any bug fixes in this version of `ggpop`.


## Improvements

- **Legend Key Function Updates**:
  - The legend key function in `geom_pop.R` has been updated to increase the dot size for cases when `legend_icons = FALSE`, ensuring better visibility of the icons in the legend.
  
- **SimCRC icons** 
  - Added native icons for cancer types in the SimCRC dataset to enhance the representation of cancer-related data.

## New features

- **Integration with `fontawesome`**:
  - Icons are now generated using the **fontawesome** package if their respective files do not exist locally. This ensures that missing icons are replaced reliably and provides access to a broader set of icons.
  - `geom_pop.R`, the icon assignment has been vectorized to check for SVG file existence and to automatically use `fontawesome::fa` if needed, improving efficiency and robustness.
  - `draw_key.R`, checks verify whether the icon file exists and, if not, generate a replacement icon via `fontawesome::fa_png`.


## Breaking changes

- There are not any breaking changes in this version of `ggpop`.


## Issues Resolved in v1.2.0

- #108
- #109
- #110

## Version 

- #107
**Full Changelog**: https://github.com/jurjoroa/ggpop/compare/v1.1.1...v1.2.0


# ggpop 1.1.1

This version brings significant improvements to the `geom_pop` function and introduces `scale_legend_icon` for enhanced legend customization in ggplot2. By default, legend icons are now enabled (`legend_icons = TRUE`), and a new `key_fn` function allows custom icons when legends are activated. The newly added `scale_legend_icon` function lets you tailor legend icons to specific grouping variables and employ custom icons as legend keys. Documentation has also been refined with updates to `NAMESPACE` and the removal of redundant `@importFrom` statements in `draw_key.R`.


## Bug fixes

We fix the bug `scale_legend_icon` function in the `R/scale_legend_icon.R` file to improve data retrieval and processing.

* Changed the method of retrieving the plot data by storing the last plot object in `gg_obj` and then accessing its data through `gg_obj$layers[[1]]$data`. This improves clarity and ensures the correct data layer is accessed.
* Added a new line at the end of the function to follow best practices for code formatting.


## Improvements


We improved **dependency management, import statements, function readability, and documentation** in the package.


## **1. Dependency Management**
- Updated the `DESCRIPTION` file:
  - Moved some packages from `Depends` to `Imports` for better efficiency.
  - Added new dependencies: `magick`, `rlang`, and `ggtext`.
  - Enabled byte compilation with `ByteCompile: true`.

## **2. Import Statements**
- Refactored the `NAMESPACE` file:
  - Used `importFrom` to import specific functions from `ggplot2`, `ggtext`, and `magick`, instead of loading entire packages.
  - Removed unnecessary imports.
- Updated specific R scripts:
  - **`caption_pop.R`**: Replaced `@import ggplot2` with `@importFrom ggtext element_textbox`.
  - **`draw_key.R`**: Added imports from `magick` and clarified internal function usage from `ggimage` and `ggplot2`.

## **3. Function Refinements**
- **`process_data.R`**:
  - Replaced base R functions with `rlang` equivalents for handling symbols and quosures.
  - Used `::` notation for `tidyr` and `stats` functions for clarity.

## **4. Documentation Enhancements**
- **`draw_key_pop_image.Rd`**: Added details on internal function dependencies (`ggimage`, `ggplot2`).
- **`geom_pop.Rd`**: Included a return value description for the `geom_pop` function.


## New features

- There are not any new features in this version of `ggpop`.

## Breaking changes

- There are not any breaking changes in this version of `ggpop`.


## Issues Resolved in v1.1.1

- #99
- #102
- #104

## Version 

- #100


**Full Changelog**: https://github.com/jurjoroa/ggpop/compare/v1.1.0...v1.1.1


# ggpop 1.1.0

This version brings significant improvements to the `geom_pop` function and introduces `scale_legend_icon` for enhanced legend customization in ggplot2. By default, legend icons are now enabled (`legend_icons = TRUE`), and a new `key_fn` function allows custom icons when legends are activated. The newly added `scale_legend_icon` function lets you tailor legend icons to specific grouping variables and employ custom icons as legend keys. Documentation has also been refined with updates to `NAMESPACE` and the removal of redundant `@importFrom` statements in `draw_key.R`.


## Bug fixes

- Updated `NAMESPACE` to export the new `scale_legend_icon` function.
- Removed unnecessary `@importFrom` statements in `draw_key.R` to clean up the code.


## Improvements


- Enabled legend icons by default in `geom_pop` by setting `legend_icons = TRUE`.
- Added a key function (`key_fn`) to use custom legend icons when `legend_icons` is enabled.


## New features

- Introduced `scale_legend_icon` to adjust legend icons based on a grouping variable and apply custom icons as legend keys.


```r
ggplot(data = df_population) +
  geom_pop(aes(icon = icon, group = type, color = type)) +
  scale_legend_icon(size = 2)
```

## Breaking changes

- `scale_legend_icon` replaces the use of `guides` and acts as a wrapper to simplify legend customization. Users may need to update existing code to accommodate this change.


## Issues Resolved in v1.1.0

- #96

## Version 

- #90

**Full Changelog**: https://github.com/jurjoroa/ggpop/compare/v1.0.1...v1.1.0

# ggpop 1.0.1

This version includes several changes to improve data consistency and update file references in the `geom_pop` function and related files. The most important changes include updating file paths, ensuring consistent data types, and filtering out rows with missing values. 

## Bug fixes

- **Typo Correction**: Fixed a typo for sample sizes of 300 and 301. (#94)

- **File Path Updates**: Updated the file path and URL for `df_coordinates_final.rda` to `df_coordinates_final_10_1000.rda` in `fetch_df_coordinates.R`.

- **Data Consistency Enhancements**: - Ensured consistent data types by converting the `size` column to character in `geom_pop`. 

- Added a filter to remove rows with `NA` values in the `type` column.


## Improvements


- Added a cancer icon to `figs`


## New features

- There are not any new features in this version of the package.

## Breaking changes

- There are not any breaking changes in this version of the package.

## Issues Resolved in v1.0.1

- #89
- #94

## Version

- #93 

**Full Changelog**: https://github.com/jurjoroa/ggpop/compare/v1.0.0...v1.0.1

# ggpop 1.0.0

This is a major release of **ggpop** introduces breaking enhancements and bug fixes aimed at improving the handling of faceted and arranged population charts.

## Bug fixes

- Fixed a bug that prevented proper arrangement of plots when `facet_wrap` or `facet_grid` was used.
- Addressed issues in the merging process where `x1` and `y1` columns could be missing after merging `data` with `df_coordinates_final`, ensuring consistent behavior.
- Resolved a problem where grouping variables in faceted plots could lead to mismatches during the data merge step.
- - **Fixed the `fetch_df_coordinates` function:** Corrected the cache directory assignment by removing the erroneous reference to `"yourpackage"` and ensuring it correctly points to `"ggpop"`. This ensures that coordinate data is properly cached and retrieved, preventing potential errors related to missing or incorrect coordinate mappings.


## Improvements

- Improved handling of `facet` variables by dynamically calculating `sample_size` for each group and ensuring consistent data types during merging.
- Reduced redundancy in code by streamlining the recalculation of coordinates (`df_coordinates_final`) and filtering (`df_coordinates_filtered`).
- Added robust handling for grouped `facet` data, with support for `facet_wrap` or `facet_grid`.
- **Introduced the `legend_icons` parameter in `geom_pop` to allow users to include custom icons within the legend without hiding the entire legend.** This enhancement provides greater flexibility in customizing legends, enabling the display of representative images alongside group labels for more informative and visually appealing plots.

```r
ggplot(data = df_example) +
  geom_pop(
    aes(icon = icon, group = variable1, color = variable1),
    size = 1.3,
    arrange = FALSE,
    legend_icons = TRUE # Enable icons in the legend
  )
```


## New features

- Added support for joining `data` with `sample_size` dynamically to ensure proper alignment of grouped variables in faceted visualizations.
- Enhanced compatibility for plots with `arrange = TRUE` and non-NULL `facet` parameters.

## Breaking changes

- **Modified the `process_data` function:** The `process_data` function no longer generates a `pos` variable, which was previously used by `geom_pop` to map coordinates. Users will need to adjust their data processing pipelines accordingly to accommodate this change.

- **Moved figures to the `inst` folder:** Icon images have been relocated to the `inst` directory to comply with ggplot2's guidelines and best practices. Users should update file paths accordingly in their projects to ensure proper access to the icon images used by `geom_pop`.

**Full Changelog**: https://github.com/jurjoroa/ggpop/compare/v0.3.1...v1.0.0


# ggpop 0.3.1

This release of **ggpop** rectifies a bug identified in `process_data`. The bug prevented the addition of a variable with a name different from `n`. Furthermore, this issue restricted the grouping variable from being utilized without a string.


## Bug fixes

- Fixed a bug that prevented the plot from arranging properly when using `facet_wrap` or `facet_grid`.

## Improvements

No improvements have been introduced in this version of ggpop.

## New features

- No new features have been introduced in this version of ggpop.

## Breaking changes

No breaking changes have been introduced in this version of ggpop.

## What's Changed
* 73 fix issue in process data function by @jurjoroa in https://github.com/jurjoroa/ggpop/pull/74
* Add fix of bugs for the new version by @jurjoroa in https://github.com/jurjoroa/ggpop/pull/75
* Change version by @jurjoroa in https://github.com/jurjoroa/ggpop/pull/76


**Full Changelog**: https://github.com/jurjoroa/ggpop/compare/v0.3.0...v0.3.1

# ggpop 0.3.0

This release of **ggpop** introduces new features and improvements, including a correction of the icon library. A new `facet` argument allows users to specify the name of the variable to facet as a string, ensuring proper grouping and plotting. The `caption_pop()` function has been enhanced to provide greater flexibility for crafting captions with seamlessly integrated icons. Additionally, the README has been improved with detailed examples to help users better leverage the new features and enhancements.


## Bug fixes

- Fixed a bug that prevented the plot from arranging properly when using `facet_wrap` or `facet_grid`.


## Improvements

This release of ggpop introduces exciting new features and improvements:

- Improved the README with detailed examples to help users better leverage the new features and enhancements.


## New features

- Added a new `facet` argument that allows users to specify the name of the variable to facet as a string, ensuring proper grouping and plotting.

## Breaking changes

No breaking changes have been introduced in this version of ggpop.


**Full Changelog**: https://github.com/jurjoroa/ggpop/compare/v0.2.0...v0.3.0

# ggpop 0.2.0

This release of **ggpop** introduces exciting new features and improvements. The expanded icon library offers a broader range of options for meaningful and context-specific visualizations. The new `process_data()` function enables grouping variables under higher-level categories, simplifying hierarchical data representation. Enhancements to `caption_pop()` provide greater flexibility for crafting captions with seamlessly integrated icons. Additionally, improved support for `facet_grid()` allows for clearer, more cohesive multi-group plots. These updates make **ggpop** an even more powerful tool for creating impactful population visualizations.


## Bug fixes

- Fixed an issue where the `icon_size` argument in `caption_pop()` was not working as expected. The argument now correctly adjusts the size of the icons in the caption.

## Improvements

This release of ggpop introduces exciting new features and improvements:

- Expanded Icon Library: ggpop now includes a variety of new icons, giving users more options to visually represent their data in a meaningful way.

- Group Variables by Higher Categories: The new process_data() function allows users to group variables under a higher-level variable, making it easier to explore and present data hierarchies effectively.

- Enhanced caption_pop() Function: The caption_pop() function has been improved for greater flexibility and customization, enabling users to craft descriptive captions that integrate icons seamlessly.

- Improved facet_grid() Support: ggpop now provides better support for multi-group plots, allowing users to create facet grids that display multiple groups clearly and cohesively.

## New features

Customizable Icon Simulation: This version of the package introduces the ability to simulate population groups originating from different categories using customizable icons. Users can select from a variety of icons or import their own, tailoring the visualization to their specific needs.

Descriptive Icon-Adorned Captions: ggpop now includes tools for adding descriptive captions adorned with icons. These captions not only provide textual information but also incorporate icons to visually represent different population groups, enhancing the overall narrative of the visualization.

## Breaking changes

No breaking changes have been introduced in this version of ggpop.


**Full Changelog**: https://github.com/jurjoroa/ggpop/compare/v0.1.1...v0.2.0

# ggpop 0.1.1

This is the initial release of the `ggpop` package, which includes functions for generating circular population charts, customizing icon representations, and adding icon-adorned captions. Additionally, `ggpop` offers tools to assess and implement various visualization strategies, providing users with alternative methods to display and interpret population data.

## Bug fixes

Initial Release: This is the first version of `ggpop`, so there are no bug fixes yet.

## Improvements

Initial Release: This is the first version of `ggpop`, so there are no improvements yet.


## New features

Customizable Icon Simulation: This version of the package introduces the ability to simulate population groups originating from different categories using customizable icons. Users can select from a variety of icons or import their own, tailoring the visualization to their specific needs.

Descriptive Icon-Adorned Captions: `ggpop` now includes tools for adding descriptive captions adorned with icons. These captions not only provide textual information but also incorporate icons to visually represent different population groups, enhancing the overall narrative of the visualization.

## Breaking changes

Initial Release: This is the first version of `ggpop`, so there are no breaking changes yet.