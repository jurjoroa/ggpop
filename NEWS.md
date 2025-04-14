# ggpop

`ggpop` is an R package built on top of `ggplot2` that simplifies the creation of engaging, icon-based population charts. By combining features from `ggplot2` and `ggimage`, `ggpop` lets users easily visualize population data using proportional, customizable icons arranged in intuitive, circular layouts. The package also includes functionality for adding clear, icon-enhanced captions, which makes charts easier to understand and visually attractive. Designed primarily for visual storytelling, `ggpop` helps users communicate complex population statistics in a straightforward and appealing manner.

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
