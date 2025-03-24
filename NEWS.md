
# ggpop

ggpop is an R package that extends the capabilities of ggplot2 to create visually engaging and informative population charts. Leveraging the power of `ggplot2` and `ggimage`, `ggpop` allows users to represent population data proportionally using customizable icons, enabling the creation of circular representative population charts with ease. Additionally, the package offers tools for adding descriptive captions adorned with icons, enhancing the interpretability and aesthetic appeal of visualizations. ggpop is intended for visualization purposes and provides an alternative way to present information effectively, making complex population data accessible and visually appealing.

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
