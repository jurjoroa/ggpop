
# ggpop

ggpop is an R package that extends the capabilities of ggplot2 to create visually engaging and informative population charts. Leveraging the power of ggplot2 and ggimage, ggpop allows users to represent population data proportionally using customizable icons, enabling the creation of circular representative population charts with ease. Additionally, the package offers tools for adding descriptive captions adorned with icons, enhancing the interpretability and aesthetic appeal of visualizations. ggpop is intended for visualization purposes and provides an alternative way to present information effectively, making complex population data accessible and visually appealing.


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

