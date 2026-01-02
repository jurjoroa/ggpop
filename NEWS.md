# ggpop

`ggpop` is an R package built on top of `ggplot2` that simplifies the creation of engaging, icon-based population charts. By combining features from `ggplot2` and `ggimage`, `ggpop` lets users easily visualize population data using proportional, customizable icons arranged in intuitive, circular layouts. The package also includes functionality for adding clear, icon-enhanced captions, which makes charts easier to understand and visually attractive. Designed primarily for visual storytelling, `ggpop` helps users communicate complex population statistics in a straightforward and appealing manner.

# ggpop 1.5.0

This version of `ggpop` introduces comprehensive improvements to input validation, error handling, and user guidance. Major changes include enhanced warnings and error messages, improved facet handling, better legend icon management, and more flexible data input options. The package now provides clearer feedback to users and is more robust in handling various edge cases.

---

## #162 - Update changes and parsimony files

**Description:**  
Introduced improved input validation and user guidance for the `geom_pop` function, making it more robust and user-friendly by adding internal validation and warning functions, better handling of dataset and aesthetic arguments, and enhanced default behaviors for icons and sizes.

**Files Changed:**  
- `R/errors.R`  
  - Added new file with `validate_geom_pop_inputs()` function to enforce correct usage of aesthetics, validate the `quality` argument, and prevent conflicting dataset specifications.
- `R/warnings.R`  
  - Added new file with `warn_geom_pop_inputs()` function to provide user warnings for common pitfalls (missing icon specifications, conflicting size arguments, ignored aesthetics).
- `R/geom_pop.R`  
  - Changed default `icon` from `"default"` to `"ggmale"` and default `size` from `1` to `3`.
  - Added calls to new validation and warning functions.
  - Updated key drawing function to use fixed size for legend icons.
- `R/scale_legend_icon.R`  
  - Modified to allow `margin` parameter to be `NULL` with default margin set if not specified.

---

## #164 - Fix dependencies

**Description:**  
Updated the package to version 1.5.0 with improvements focused on legend customization, icon rendering, documentation, and package dependencies. Added `rsvg` package for icon rendering and removed restrictions on dataset specification.

**Files Changed:**  
- `DESCRIPTION`  
  - Updated version to 1.5.0.
  - Added `rsvg` to Imports.
  - Updated author information and corrected ordering.
  - Fixed RoxygenNote version.
- `R/draw_key.R`  
  - Renamed function from `ddraw_key_pop_image` to `draw_key_pop_image`.
  - Integrated `rsvg::librsvg_version()` for improved compatibility.
- `R/errors.R`  
  - Removed restriction preventing users from specifying different datasets in `ggplot(data=...)` and `geom_pop(data=...)`.
- `R/scale_legend_icon.R`  
  - Added support for `margin` parameter in documentation.
- `man/geom_pop.Rd`  
  - Updated documentation for default icon, size, and quality parameters (quality was later renamed to dpi in issue #161).
- `man/ggpop-package.Rd`  
  - Updated author information.
- `man/scale_legend_icon.Rd`  
  - Enhanced documentation for legend parameters.

---

## #166 - Refactor facet handling in geom_pop function

**Description:**  
Improved facet argument processing to support both symbol and string inputs, validate facet column existence, and update data manipulation logic to use the resolved facet column, enhancing flexibility and robustness when faceting plots.

**Files Changed:**  
- `R/geom_pop.R`  
  - Added facet handling logic to accept either symbols or strings (e.g., `facet = sex` or `facet = "sex"`).
  - Improved error messages for missing facet columns.
  - Updated data join logic for faceted data using `.data[[facet_col]]`.
  - Refactored size variable handling and coordinate size naming.

---

## #168 - Fix legend issue in facet

**Description:**  
Refactored the `geom_pop` function to improve code clarity, consistency, and legend handling for icon-based plots by standardizing data manipulation, simplifying facet logic, and introducing robust legend icon assignment.

**Files Changed:**  
- `R/geom_pop.R`  
  - Replaced base R operations with explicit `dplyr` functions throughout (mutate, arrange, select, group_by, etc.).
  - Simplified facet and size logic with cleaner error messages.
  - Introduced `key_glyph_pop()` function for dynamic legend icon assignment based on scale breaks and order.
  - Added final checks for required columns (`x1`, `y1`) after merging.
  - Refactored mapping construction for `ggimage::geom_image`.
- `R/draw_key.R`  
  - Added newline at end of file for consistency.

---

## #161 - Change dpi instead of quality argument in geom_pop

**Description:**  
Renamed the `quality` parameter to `dpi` throughout the function and documentation for clarity, indicating it refers to image pixel height rather than subjective quality.

**Files Changed:**  
- `R/geom_pop.R`  
  - Renamed `quality` parameter to `dpi` in function signature and usage.
  - Modified icon rendering to always regenerate PNG with specified `dpi`, deleting existing files.
  - Updated validation calls to use `dpi`.
- `man/geom_pop.Rd`  
  - Updated documentation to use `dpi` instead of `quality`.

---

## #152 - Add errors and warnings file

**Description:**  
Introduced stricter input validation, enhanced warning messages, collision avoidance between icon and coordinate size variables, and enforcement of maximum icon limits per plot or facet group.

**Files Changed:**  
- `R/process_data.R`  
  - Changed default `sample_size` from 1000 to 100.
  - Added strict validation for `sample_size` argument (must be integer between 1-1000).
- `R/geom_pop.R`  
  - Renamed size mapping to `icon_size` and coordinate size to `coord_size` to avoid collisions.
  - Enforced maximum of 1000 icons per plot or per facet group with clear error messages.
  - Updated internal logic to use new variable names.
- `R/warnings.R`  
  - Refactored `warn_geom_pop_inputs()` with more detailed warnings about icon mapping, DPI settings, size validity, and legend ambiguity.
  - Added ASCII-safe warning format.

---

## #173 - Stop using facet in argument aes(), move to a unique facet

**Description:**  
Introduced significant improvements to facet handling, clearer warnings, and improved internal logic for icon positioning and legend generation, making it easier to work with faceted plots and grouped data.

**Files Changed:**  
- `R/geom_pop.R`  
  - Added logic to auto-infer facet variable from `facet_wrap` or `facet_grid`.
  - Updated icon position assignment to treat `group` as facet internally when no facet provided but multiple groups exist.
  - Introduced comprehensive ASCII-safe warning system about icon overlap and facet usage.
  - Improved variable naming to avoid collisions (icon_size vs coord_size).
  - Refined legend handling to respect scale breaks and grouping.
- `R/warnings.R`  
  - Standardized warning messages with ASCII-safe formatting.
- `man/process_data.Rd`  
  - Updated default `sample_size` documentation to 100.

---

## #175 - Finish first version of warnings and errors

**Description:**  
Introduced stricter error handling and more informative user guidance by enforcing mandatory icon specification, preventing low-quality DPI rendering, and enhancing warnings for ambiguous input scenarios.

**Files Changed:**  
- `R/geom_pop.R`  
  - Added hard stop for `dpi` values below 30 (blurry icons).
  - Enforced that every row must have valid `icon` value with clear error message and example.
  - Added warning when `size` specified both in `aes()` and as direct argument.
- `R/warnings.R`  
  - Enhanced `warn_geom_pop_inputs()` to warn about low/high DPI values, invalid size, and legend ambiguity.
  - Added checks for multiple icons per color group.
  - Removed previous warning allowing missing icons.

---

## #177 - Allow user to use their own dataframes without using process_data()

**Description:**  
Refactored to provide more flexible handling of input data, improved error messages, and safer data manipulation, especially regarding grouping and icon assignment. Users can now use raw dataframes without `process_data()`.

**Files Changed:**  
- `R/errors.R`  
  - Updated `validate_geom_pop_inputs` to check for `dpi` parameter instead of `quality`.
- `R/geom_pop.R`  
  - Added mode detection to identify "processed" vs "raw" data.
  - For raw data, infers grouping from mapped aesthetics and adds `type` column if needed.
  - Data arrangement checks for presence of `n` and `prop` columns before selecting/binding.
  - Used `.data[[var]]` throughout for safer non-standard evaluation.
  - Improved error messages with clear fixes and examples.
- `R/warnings.R`  
  - Improved legend ambiguity warning with safer grouping and summarization.

---

## #179 - Finish first version of errors file

**Description:**  
Improved usability and robustness by enhancing user warnings, clarifying error messages, updating temporary file handling, and standardizing column naming conventions.

**Files Changed:**  
- `R/geom_pop.R`  
  - Added warning when `size` specified both in `aes()` and as argument, explaining usage.
  - Improved error message for missing grouping information with actionable fixes and examples.
  - Changed icon PNG file writing to use temporary cache directory (`tempdir()`) instead of package directory.
  - Standardized column names from `.group`/`.icon` to `group`/`icon` for consistency.
- `R/warnings.R`  
  - Updated warning helper to use standardized column names (`group`/`icon`).

---

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
