
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ggpop <img src="inst/figures/logo.png" align="right" width= 170px />
<!-- badges: start -->

[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/dmi3kno/polite?branch=master&svg=true)](https://ci.appveyor.com/project/dmi3kno/polite)
[![Codecov test
coverage](https://codecov.io/gh/dmi3kno/polite/branch/master/graph/badge.svg)](https://app.codecov.io/gh/dmi3kno/polite?branch=master)
[![CRAN
status](https://www.r-pkg.org/badges/version/polite)](https://CRAN.R-project.org/package=polite)
[![Lifecycle:
maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://lifecycle.r-lib.org/articles/stages.html#maturing)
[![R-CMD-check](https://github.com/dmi3kno/polite/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/dmi3kno/polite/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

`ggpop` is an R package built on top of ggplot2 that simplifies the creation of engaging, icon-based population charts. By combining features from `ggplot2` and `ggimage`, `ggpop` lets users easily visualize population data using proportional, customizable icons arranged in intuitive, circular layouts. The package also includes functionality for adding clear, icon-enhanced captions, which makes charts easier to understand and visually attractive. Designed primarily for visual storytelling, ggpop helps users communicate complex population statistics in a straightforward and appealing manner.

## An Alternative Approach to Visualization

`ggpop` offers a fresh alternative to traditional data visualizations by using icons and proportional symbols in population charts. This approach not only improves the aesthetics of your plots but also helps your audience better engage with and understand the data. By converting numerical values into intuitive visual representations, `ggpop` makes complex population data clearer and easier to remember, allowing users to tell more compelling and accessible stories.


## Why ggpop?

Traditional charts can feel abstract. **ggpop** makes data human by:

- **Visual Impact**: Icons create immediate connection
- **Intuitive Understanding**: Proportional representation simplifies complex data
- **Flexible**: Support for 2,000+ Font Awesome icons + native optimized icons
- **Fast**: Optimized rendering handles up to 1,000 icons smoothly
- **ggplot2 Native**: Integrates seamlessly with your existing workflow




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

## Quick Start

### 1.- Create a Small Dataset or Use a Built-in Dataset

The dataset **`df_pop_mx`** is a **minimal example** illustrating population counts by sex in Mexico in 2024. It has the following structure:

- **sex**:  
  A categorical variable indicating the sex, with two entries:
  - `"male"`
  - `"female"`

- **n**:  
  A numeric variable representing the population size for each sex category.

- **country**:  
  A constant value `"Mexico"`, indicating the country these observations belong to.

- **continent**:  
  A constant value `"America"`, indicating the continent these observations belong to.



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

Here, we create a new column called `icon` in the `df_pop_mx_prop` dataset. The `case_when()` function checks each row’s **type** (either "male" or "female") and assigns a matching value ("ggmale" or "ggfemale") to the `icon` column.


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

- **Font Awesome icons** offer greater flexibility and a broader icon set (2,000+ free icons). However, rendering these icons can be slower if the sample size is large (e.g., 1,000+ observations) or if plot is faceted.

- The icons are stored in the `fontawesome` package. The only thing you need to specify is the icon's name.

For example, this is just a few sample of more than 2,000 free icons available in the `fontawesome` package:

| List of Font Awesome icons                                                                                                                     | Preview                                                                                                       |
|:-----------------------------------------------------------------------------------------------------------------------------------------------:|:--------------------------------------------------------------------------------------------------------------:|
| **Sample icons:** <br>- home <br>- user <br>- envelope <br>- bell <br>- camera <br>- cog <br>- heart <br>- calendar <br>- cart-plus <br>- check <br>- cloud <br>- comment <br>- comments <br>- download <br>- edit <br>- file <br>- filter <br>- flag <br>- folder <br>- phone | <img src="https://raw.githubusercontent.com/jurjoroa/ggpopdata/main/inst/figures/fontawesome_icons.png" width="900px" alt="fontawesome table preview" /> |

You can check the full list of icons in the [Font Awesome website](https://fontawesome.com/icons?d=gallery&p=2&m=free).

### 5.- Plot population chart

Now we can proceed to plot the population chart using the assigned icons.


``` r

library(ggplot2)
ggplot() +
  geom_pop(data = df_pop_mx_prop, aes(icon = icon, group=type, color=type),
           size = 1, arrange=F, legend_icons=F) +
  theme_void() +
  theme(legend.position = "bottom")

```

![Example Plot](https://raw.githubusercontent.com/jurjoroa/ggpopdata/main/inst/figures/example_plot1.png)


The `geom_pop()` function creates a population chart using the `df_prop_mx_f` dataset. The object work as a `geom_point()` figure plotted by determined x and y coordinates. We can also group and color the icons by the **type** variable or the variable that we are grouping for.

#### 5.1 Improve plot 

Like a ggplot object, we can improve it to have a more presentable plot. We can arrange our icons, add them as part of the legend, give color to the background, and add a title and caption to the plot.

``` r

ggplot(data = df_pop_mx_prop, aes(icon = icon, group=type, color=type)) +
  geom_pop(size = 1, arrange=T) +
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


We can also include more than two icons in the same plot. In this example, we will identify the people that is disabled, and we will change some parameters.


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
                                              face = "bold", size = 90, hjust = 0.5),  # CENTER
                    plot.subtitle = element_text(color = "#D4AF37", family = "quicksand", 
                                                 size = 70, hjust = 0.5),  # CENTER
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


### 6.- More examples employing facets and other packages

#### Facet wrap/grid


![Example Plot 3](https://raw.githubusercontent.com/jurjoroa/ggpopdata/main/inst/figures/transportation_methods_countries.png)

#### Geofacet


![Example Plot 4](https://raw.githubusercontent.com/jurjoroa/ggpopdata/main/inst/figures/gun_death_rates_us_states_hexgrid.png)


### Citation

```bibtex
@Manual{ggpop2024,
  title   = {ggpop: Visualizing Population Data},
  author  = {Roa-Contreras, Jorge A. and Soultanova, Ralitza and Alarid-Escudero, Fernando and Pineda-Antunez, Carlos},
  year    = {2024},
  note    = {R package version 1.5.0},
  url     = {https://github.com/jurjoroa/ggpop},
  license = {CC BY-NC-SA 4.0}
}
