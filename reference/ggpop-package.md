# ggpop: Icon-Based Population Charts for R

`ggpop` is a `ggplot2` extension for creating icon-based population
charts and pictogram plots. Use
[`geom_pop()`](https://jurjoroa.github.io/ggpop/reference/geom_pop.md)
and
[`geom_icon_point()`](https://jurjoroa.github.io/ggpop/reference/geom_icon_point.md)
to visualize proportion and population data with 2,000+ Font Awesome
icons.

## Main functions

- [`geom_pop()`](https://jurjoroa.github.io/ggpop/reference/geom_pop.md)
  – proportional icon grids

- [`geom_icon_point()`](https://jurjoroa.github.io/ggpop/reference/geom_icon_point.md)
  – icon scatter plots

- [`process_data()`](https://jurjoroa.github.io/ggpop/reference/process_data.md)
  – prepare count data for plotting

- [`fa_icons()`](https://jurjoroa.github.io/ggpop/reference/fa_icons.md)
  – search Font Awesome icon names

- [`theme_pop()`](https://jurjoroa.github.io/ggpop/reference/theme_pop.md),
  [`theme_pop_dark()`](https://jurjoroa.github.io/ggpop/reference/theme_pop_dark.md),
  [`theme_pop_minimal()`](https://jurjoroa.github.io/ggpop/reference/theme_pop_minimal.md)
  – built-in themes

## process_data()

Converts count data to one row per icon. `group_var` and `sum_var` are
unquoted; `high_group_var` takes a character string for faceted charts.

    df_plot <- process_data(
      data        = data.frame(sex = c("Female", "Male"), n = c(55, 45)),
      group_var   = sex,
      sum_var     = n,
      sample_size = 20
    )

## geom_pop()

Draws icon grids. Add an `icon` column, map `icon` and `color` in
[`aes()`](https://ggplot2.tidyverse.org/reference/aes.html). Do not map
`x` or `y`.

    ggplot() +
      geom_pop(data = df_plot, aes(icon = icon, color = type), size = 2) +
      scale_color_manual(values = c(Female = "#C0392B", Male = "#2980B9")) +
      theme_pop()

## geom_icon_point()

Drop-in replacement for
[`geom_point()`](https://ggplot2.tidyverse.org/reference/geom_point.html)
using Font Awesome icons.

    ggplot(iris, aes(x = Sepal.Length, y = Petal.Length, color = Species)) +
      geom_icon_point(icon = "seedling", size = 1)

## fa_icons()

Search the bundled Font Awesome icon list by keyword.

    fa_icons(query = "person")

## Themes

Three built-in themes optimized for icon charts:
[`theme_pop()`](https://jurjoroa.github.io/ggpop/reference/theme_pop.md),
[`theme_pop_dark()`](https://jurjoroa.github.io/ggpop/reference/theme_pop_dark.md),
[`theme_pop_minimal()`](https://jurjoroa.github.io/ggpop/reference/theme_pop_minimal.md).

## See also

Useful links:

- <https://jurjoroa.github.io/ggpop/>

- Report bugs at <https://github.com/jurjoroa/ggpop/issues>

## Author

**Maintainer**: Jorge A. Roa-Contreras <jorgeroa@stanford.edu>
([ORCID](https://orcid.org/0000-0002-3972-9793))

Authors:

- Ralitza Soultanova <Ralitza.soultanova@gmail.com>
  ([ORCID](https://orcid.org/0009-0000-9324-5653))

- Fernando Alarid-Escudero <falarid@stanford.edu>
  ([ORCID](https://orcid.org/0000-0001-5076-1172))

- Carlos Pineda-Antunez <cpinedaa@uw.edu>
  ([ORCID](https://orcid.org/0000-0002-8352-7080))

## Examples

``` r
library(ggplot2)
library(dplyr)
#> 
#> Attaching package: ‘dplyr’
#> The following objects are masked from ‘package:stats’:
#> 
#>     filter, lag
#> The following objects are masked from ‘package:base’:
#> 
#>     intersect, setdiff, setequal, union

## -------------------------------------------------------
## geom_pop(): population icon grid
## -------------------------------------------------------
df_plot <- process_data(
  data        = data.frame(sex = c("Female", "Male"), n = c(55, 45)),
  group_var   = sex,
  sum_var     = n,
  sample_size = 20
) %>%
  mutate(icon = ifelse(type == "Female", "person-dress", "person"))

ggplot() +
  geom_pop(data = df_plot, aes(icon = icon, color = type), size = 2) +
  scale_color_manual(values = c(Female = "#C0392B", Male = "#2980B9")) +
  theme_pop() +
  labs(title = "Population by sex", color = NULL)


## -------------------------------------------------------
## geom_icon_point(): icon scatter plot
## -------------------------------------------------------
ggplot(iris, aes(x = Sepal.Length, y = Petal.Length, color = Species)) +
  geom_icon_point(icon = "seedling", size = 1) +
  scale_color_manual(values = c(
    setosa     = "#43A047",
    versicolor = "#1E88E5",
    virginica  = "#E53935"
  )) +
  labs(title = "Iris dataset", x = "Sepal Length", y = "Petal Length")

```
