# ggpop <img src="inst/figures/logo.png" align="right" width= 170px />

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/ggpop)](https://CRAN.R-project.org/package=ggpop)
[![R-CMD-check](https://github.com/jurjoroa/ggpop/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/jurjoroa/ggpop/actions/workflows/R-CMD-check.yaml)
[![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
<!-- badges: end -->

> **Turn numbers into people. Turn data into stories.**

`ggpop` is an R package built on top of ggplot2 that simplifies the creation of engaging, icon-based population charts. By combining features from `ggplot2` and `ggimage`, `ggpop` lets users easily visualize population data using proportional, customizable icons arranged in intuitive, circular layouts. The package also includes functionality for adding clear, icon-enhanced captions, which makes charts easier to understand and visually attractive. Designed primarily for visual storytelling, ggpop helps users communicate complex population statistics in a straightforward and appealing manner.

## An Alternative Approach to Visualization

`ggpop` offers a fresh alternative to traditional data visualizations by using icons and proportional symbols in population charts. This approach not only improves the aesthetics of your plots but also helps your audience better engage with and understand the data. By converting numerical values into intuitive visual representations, `ggpop` makes complex population data clearer and easier to remember, allowing users to tell more compelling and accessible stories.

## Why ggpop?

Traditional charts can feel abstract. **ggpop** makes data human by:

- **Visual Impact**: Icons create an immediate emotional connection with your audience
- **Intuitive Understanding**: Proportional representation simplifies complex data at a glance
- **Flexible**: Support for 2,000+ Font Awesome icons
- **Fast**: Optimized rendering handles up to 1,000 icons smoothly
- **ggplot2 Native**: Integrates seamlessly with your existing workflow — themes, facets, scales and all

---

## Two Powerful Geoms

ggpop ships with two complementary geoms. Each solves a different visualization problem:

|  | `geom_pop()` | `geom_icon_point()` |
|:---|:---|:---|
| **Best for** | Population & proportion data | Any x / y scatter data |
| **Layout** | Circular proportional grid | Free x / y positioning |
| **What one icon means** | A fixed share of the total population | A single observation |
| **Data prep needed** | Yes — run `process_data()` first | No — plug in any data directly |
| **Think of it as** | A pictogram / isotype chart | `geom_point()` with icons |

---

## Installation

You can install `ggpop` from [CRAN](https://cran.r-project.org/) with:

``` r
install.packages("ggpop")
```

Development version of the package can be installed from
[GitHub](https://github.com/jurjoroa/ggpop) with:

``` r
install.packages("remotes")
remotes::install_github("jurjoroa/ggpop")
```

---

## `geom_pop()` — Population Charts

`geom_pop()` creates proportional icon grids where each icon represents a share of the total population. Perfect for making demographic, health, or social statistics feel tangible and human.

### 1.- Create a Small Dataset or Use a Built-in Dataset

The dataset **`df_pop_mx`** is a **minimal example** illustrating population counts by sex in Mexico in 2024. It has the following structure:

- **sex**: A categorical variable indicating the sex (`"male"` / `"female"`)
- **n**: A numeric variable representing the population size for each sex category
- **country**: A constant value `"Mexico"`
- **continent**: A constant value `"America"`

``` r
library(dplyr)
library(ggpop)

df_pop_mx <- data.frame(sex = c("male", "female"),
                        n = c(63459580, 67401427),
                        country = "Mexico",
                        continent = "America")
```

| **Sex**  | **Population (n)** | **Country** | **Continent** |
|----------|---------------------|-------------|---------------|
| Male     | 63,459,580          | Mexico      | America       |
| Female   | 67,401,427          | Mexico      | America       |

### 2.- Process data

``` r
df_pop_mx_prop <- process_data(data = df_pop_mx, group_var = sex, sum_var = n, sample_size = 1000)

head(df_pop_mx_prop)
```

We apply the `process_data()` function to the population data `df_pop_mx` with the following parameters:

- **group_var = sex**: groups the data by sex (male/female). This is our grouping variable
- **sum_var = n**: uses the column `n` (population counts) for group totals. This is the variable that will be summed up to calculate proportions.
- **sample_size = 1000**: generates 1,000 sampled records, proportionally allocated to each group. The package allows up to a sample size of 1000.

The function calculates group proportions, then performs sampling to create a new data frame (`df_pop_mx_prop`). Each row represents one draw from the 1,000 samples. Notable columns:

- **type**: which group (male or female) was sampled.
- **n**: total population count of the corresponding group.
- **prop**: proportion of that group in the overall dataset.

### 3.- Assign icons to groups

Here, we create a new column called `icon` in the `df_pop_mx_prop` dataset. The `case_when()` function checks each row's **type** (either "male" or "female") and assigns a matching value to the `icon` column.

``` r
df_pop_mx_prop <- df_pop_mx_prop %>%
  mutate(icon = case_when(
    type == "male" ~ "male",
    type == "female" ~ "female"))
```

### 4.- Icons

<p style="display: flex; align-items: center;">
  <img src="inst/figures/logo.png" width="115px" alt="Logo" />
  <img src="inst/figures/fontawesome.png" width="125px" alt="Fontawesome" />
</p>

This package supports **Font Awesome icons**.

- **Font Awesome icons** offer greater flexibility and a broader icon set (2,000+ free icons). However, rendering these icons can be slower if the sample size is large (e.g., 1,000+ observations) or if the plot is faceted.

- The icons are stored in the `fontawesome` package. The only thing you need to specify is the icon's name.

For example, this is just a few sample of more than 2,000 free icons available in the `fontawesome` package:

| List of Font Awesome icons                                                                                                                     | Preview                                                                                                       |
|:-----------------------------------------------------------------------------------------------------------------------------------------------:|:--------------------------------------------------------------------------------------------------------------:|
| **Sample icons:** <br>- home <br>- user <br>- envelope <br>- bell <br>- camera <br>- cog <br>- heart <br>- calendar <br>- cart-plus <br>- check <br>- cloud <br>- comment <br>- comments <br>- download <br>- edit <br>- file <br>- filter <br>- flag <br>- folder <br>- phone | <img src="https://raw.githubusercontent.com/jurjoroa/ggpopdata/main/inst/figures/fontawesome_icons.png" width="900px" alt="fontawesome table preview" /> |

You can check the full list of icons at the [Font Awesome website](https://fontawesome.com/icons?d=gallery&p=2&m=free).

### 5.- Plot population chart

Now we can proceed to plot the population chart using the assigned icons.

``` r
library(ggplot2)

ggplot() +
  geom_pop(data = df_pop_mx_prop, aes(icon = icon, group = type, color = type),
           size = 1, arrange = F, legend_icons = F) +
  theme_void() +
  theme(legend.position = "bottom")
```

![Example Plot](https://raw.githubusercontent.com/jurjoroa/ggpopdata/main/inst/figures/example_plot1.png)

The `geom_pop()` function creates a population chart using the `df_pop_mx_prop` dataset. The object works as a `geom_point()` figure plotted at determined x and y coordinates. We can also group and color the icons by the **type** variable or the variable we are grouping for.

#### 5.1 Improve the plot

Like any ggplot object, we can layer on themes, colors, titles, and a legend to make the chart presentation-ready.

``` r
ggplot(data = df_pop_mx_prop, aes(icon = icon, group = type, color = type)) +
  geom_pop(size = 1, arrange = T) +
  theme_void(base_size = 40) +
  theme(legend.position = "bottom") +
  labs(title = "Population in Mexico by Sex",
       subtitle = "2024",
       caption = "Source: demogmx") +
  theme(legend.title = element_blank(),
        plot.background = element_blank(),
        panel.background = element_blank(),
        legend.background = element_blank(),
        legend.text = element_text(color = "#D4AF37"),
        plot.title = element_text(color = "#D4AF37"),
        plot.subtitle = element_text(color = "#D4AF37"),
        plot.caption = element_text(color = "#D4AF37")) +
  scale_legend_icon(size = 10) +
  scale_color_manual(values = c("male" = "#1E88E5", "female" = "#D81B60"),
                     labels = c("female" = "Females: 51%", "male" = "Males: 49%"))
```

![Example Plot](https://raw.githubusercontent.com/jurjoroa/ggpopdata/main/inst/figures/example_plot2.png)

We can also include more than two icons in the same plot. In this example, we will identify the people that are disabled, and we will change some parameters.

``` r
#1.- We load or create the data
df_pop_dis_mx <- data.frame(sex = c("male", "female", "disabled males", "disabled females"),
                            value = c(53726732, 54978806, 9731396, 11106712),
                            country = "Mexico",
                            continent = "America")

#2.- We process the data
df_pop_dis_mx_prop <- process_data(data = df_pop_dis_mx, group_var = sex,
                                   sum_var = value, sample_size = 500)

#3.- Assign icons to groups
df_pop_dis_mx_prop <- df_pop_dis_mx_prop %>%
  mutate(icon = case_when(
    type == "male" ~ "male",
    type == "female" ~ "female",
    type == "disabled males" ~ "wheelchair",
    type == "disabled females" ~ "wheelchair"))

#4.- Plot

library(showtext)
font_add_google("Quicksand", "quicksand")
showtext_auto()

ggplot(data = df_pop_dis_mx_prop, aes(icon = icon, group = type, color = type)) +
  geom_pop(size = 1.1, arrange = F) +
  theme_pop(base_size = 100, base_family = "quicksand") +
  scale_legend_icon(size = 10,
                    legend.text = element_text(color = "#D4AF37", family = "quicksand"),
                    plot.title = element_text(color = "#D4AF37", family = "quicksand",
                                              face = "bold", size = 90, hjust = 0.5),
                    plot.subtitle = element_text(color = "#D4AF37", family = "quicksand",
                                                 size = 70, hjust = 0.5),
                    plot.caption = element_text(color = "#D4AF37", family = "quicksand",
                                                size = 70, hjust = 0)) +
  labs(title = "Population in Mexico by Sex and disability status",
       subtitle = "2023",
       caption = "As of 2023, 16% of the population in Mexico has some form of disability.") +
  theme(legend.position = "bottom", legend.title = element_blank(),
        legend.box.spacing = unit(-.4, "cm"),
        legend.margin = margin(t = 0, b = 0),
        legend.box.margin = margin(t = 0, b = 0)) +
  scale_color_manual(values = c("male" = "#1E88E5", "female" = "#D81B60",
                                "disabled males" = "#90CAF9",
                                "disabled females" = "#F48FB1"),
                     labels = c("male" = "Males", "female" = "Females",
                                "disabled females" = "Disabled Females",
                                "disabled males" = "Disabled Males"))
```

![Example Plot 3](https://raw.githubusercontent.com/jurjoroa/ggpopdata/main/inst/figures/example_plot3.png)

---

## `geom_icon_point()` — Icon Scatter Plots

`geom_icon_point()` is the scatter plot cousin of `geom_pop()`. It works exactly like `geom_point()` — but swaps dots for Font Awesome icons. No preprocessing required: just pass any data with `x` and `y` variables and let the icons do the talking.

This is ideal when you want to add visual identity to individual observations — making your audience immediately recognize *what* they are looking at, not just *where* a point sits on a chart.

### Key differences from `geom_pop()`

- No `process_data()` step needed — works with raw data
- Icons are placed freely at x / y coordinates, not arranged in a grid
- Each icon = one row in your dataset (not a population share)
- Supports mapped icons: different categories can show different icons

### Example 1: Fuel Efficiency by Transmission Type

Use the built-in `mtcars` dataset to compare car weight vs. fuel efficiency, with each data point rendered as a car icon colored by transmission type.

``` r
library(ggplot2)
library(ggpop)
library(dplyr)

car_data <- mtcars %>%
  tibble::rownames_to_column("car") %>%
  mutate(
    transmission = ifelse(am == 0, "Automatic", "Manual"),
    icon = ifelse(am == 0, "car-side", "truck")
  )

ggplot(car_data, aes(x = wt, y = mpg, icon = icon, color = transmission)) +
  geom_icon_point(size = 1.5) +
  theme_pop() +
  labs(
    title = "Fuel Efficiency by Weight & Transmission Type",
    subtitle = "Each icon represents one car model from the mtcars dataset",
    x = "Weight (1000 lbs)",
    y = "Miles per Gallon"
  ) +
  scale_color_manual(values = c("Automatic" = "#1E88E5", "Manual" = "#D81B60"))
```

### Example 2: Mapping Different Icons to Different Categories

`geom_icon_point()` shines when you want each category to carry its own visual identity. Here, cities are represented by their primary mode of transit — and the icon *is* the legend.

``` r
library(ggplot2)
library(ggpop)

transport_data <- data.frame(
  city      = c("New York", "London", "Paris", "Tokyo", "Sydney"),
  cost      = c(2.75, 3.20, 2.10, 2.30, 3.50),
  rating    = c(72, 85, 90, 95, 78),
  icon      = c("subway", "train", "bicycle", "train", "bus"),
  continent = c("Americas", "Europe", "Europe", "Asia", "Oceania")
)

ggplot(transport_data, aes(x = cost, y = rating, icon = icon, color = continent)) +
  geom_icon_point(size = 2.5) +
  theme_pop() +
  labs(
    title = "Urban Transit: Cost vs. Rider Satisfaction",
    subtitle = "Icon = primary transit mode in each city",
    x = "Ticket Cost (USD)",
    y = "Satisfaction Score"
  )
```

### Example 3: A Single Icon Across All Points

You can also fix the same icon for every observation and let color carry the grouping — the simplest way to add character to a scatter plot.

``` r
library(ggplot2)
library(ggpop)

ggplot(iris, aes(x = Sepal.Length, y = Petal.Length, color = Species)) +
  geom_icon_point(icon = "seedling", size = 1.2) +
  theme_pop() +
  labs(
    title = "Iris: Sepal vs. Petal Length",
    subtitle = "geom_icon_point() with a fixed icon and color grouping",
    x = "Sepal Length",
    y = "Petal Length"
  )
```

---

## More Examples: Facets & Other Packages

### Facet wrap / grid

![Example Plot facet](https://raw.githubusercontent.com/jurjoroa/ggpopdata/main/inst/figures/transportation_methods_countries.png)

### Geofacet

![Example Plot geofacet](https://raw.githubusercontent.com/jurjoroa/ggpopdata/main/inst/figures/gun_death_rates_us_states_hexgrid.png)

---

## Citation

```bibtex
@Manual{ggpop2024,
  title   = {ggpop: Visualizing Population Data},
  author  = {Roa-Contreras, Jorge A. and Soultanova, Ralitza and Alarid-Escudero, Fernando and Pineda-Antunez, Carlos},
  year    = {2024},
  note    = {R package version 1.7.0},
  url     = {https://github.com/jurjoroa/ggpop},
  license = {MIT}
}
```
