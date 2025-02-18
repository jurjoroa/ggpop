
# ggpop

ggpop is an R package that extends the capabilities of ggplot2 to create visually engaging and informative population charts. Leveraging the power of ggplot2 and ggimage, ggpop allows users to represent population data proportionally using customizable icons, enabling the creation of circular representative population charts with ease. Additionally, the package offers tools for adding descriptive captions adorned with icons, enhancing the interpretability and aesthetic appeal of visualizations. ggpop is intended for visualization purposes and provides an alternative way to present information effectively, making complex population data accessible and visually appealing.

# ggpop 1.1.0

This version brings significant improvements to the `geom_pop` function and introduces `scale_legend_icon` for enhanced legend customization in ggplot2. By default, legend icons are now enabled (`legend_icons = TRUE`), and a new `key_fn` function allows custom icons when legends are activated. The newly added `scale_legend_icon` function lets you tailor legend icons to specific grouping variables and employ custom icons as legend keys. Documentation has also been refined with updates to `NAMESPACE` and the removal of redundant `@importFrom` statements in `draw_key.R`.


## Bug fixes

- There are not any bug fixes in this version of the package.


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

