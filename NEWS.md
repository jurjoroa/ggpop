
# ggpop

ggpop is an R package that extends the capabilities of ggplot2 to create visually engaging and informative population charts. Leveraging the power of ggplot2 and ggimage, ggpop allows users to represent population data proportionally using customizable icons, enabling the creation of circular representative population charts with ease. Additionally, the package offers tools for adding descriptive captions adorned with icons, enhancing the interpretability and aesthetic appeal of visualizations. ggpop is intended for visualization purposes and provides an alternative way to present information effectively, making complex population data accessible and visually appealing.

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

