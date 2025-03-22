
# ggpop

ggpop is an R package that extends the capabilities of ggplot2 to create visually engaging and informative population charts. Leveraging the power of ggplot2 and ggimage, ggpop allows users to represent population data proportionally using customizable icons, enabling the creation of circular representative population charts with ease. Additionally, the package offers tools for adding descriptive captions adorned with icons, enhancing the interpretability and aesthetic appeal of visualizations. ggpop is intended for visualization purposes and provides an alternative way to present information effectively, making complex population data accessible and visually appealing.

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
