
# ggpop

ggpop is an R package that extends the capabilities of ggplot2 to create visually engaging and informative population charts. Leveraging the power of ggplot2 and ggimage, ggpop allows users to represent population data proportionally using customizable icons, enabling the creation of circular representative population charts with ease. Additionally, the package offers tools for adding descriptive captions adorned with icons, enhancing the interpretability and aesthetic appeal of visualizations. ggpop is intended for visualization purposes and provides an alternative way to present information effectively, making complex population data accessible and visually appealing.

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