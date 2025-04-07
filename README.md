
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




## Installation

You can install `ggpop` from [CRAN](https://cran.r-project.org/) with:

``` r
install.packages("ggpop")
```

Development version of the package can be installed from
[Github](https://github.com/jurjoroa/ggpop) with:

``` r
install.packages("remotes")
remotes::install_github("jurjoroa/ggpop")
```

## Basic Example


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

| type   |        n |      prop   |
|:-------|---------:|------------:|
| male   | 63459580 | 0.4849388    |
| female | 67401427 | 0.5150612    |
| female | 67401427 | 0.5150612    |
| male   | 63459580 | 0.4849388    |
| male   | 63459580 | 0.4849388    |
| female | 67401427 | 0.5150612    |
| female | 67401427 | 0.5150612    |
| male   | 63459580 | 0.4849388    |
| female | 67401427 | 0.5150612    |
| male   | 63459580 | 0.4849388    |
| female | 67401427 | 0.5150612    |
| ...    | ...      | ...         |

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
    type == "male" ~ "ggmale",
    type == "female" ~ "ggfemale"))
```


### 4.- Icons

This package supports two types of icons for plotting: **native SVG icons** and **Font Awesome icons**.

- **Native icons** are optimized for fast rendering and are ideal for large sample sizes. They are in SVG format, meaning they scale cleanly without loss of quality.
- **Font Awesome icons** offer greater flexibility and a broader icon set (2,000+ free icons), and in the latest version of the package, their performance is nearly equivalent to that of the native icons. However, when plotting very large datasets, native icons may still be slightly faster.

To illustrate the improvement, here's a benchmark comparison between **v1.2.1** and the **latest version** using 1,000 observations:

```
Render Time (Font Awesome icons, 1,000 observations)

Version 1.2.1      ██████████████████████████████  ~1 minute  
Latest Version     █                               ~2 seconds

```
### 4.1.- Native Icons

The following native icons are included in the package:


| Icon         | Preview                                                                 | Icon         | Preview                                                                 | Icon         | Preview                                                                 | Icon         | Preview                                                                 |
|--------------|--------------------------------------------------------------------------|--------------|--------------------------------------------------------------------------|--------------|--------------------------------------------------------------------------|--------------|--------------------------------------------------------------------------|
| `ggbike`     | <img src="inst/figures/ggbike.svg" width="37" height="37">              | `ggbuild`    | <img src="inst/figures/ggbuild.svg" width="25" height="25">             | `ggcar`      | <img src="inst/figures/ggcar.svg" width="25" height="25">               | `ggcancer`   | <img src="inst/figures/ggcancer.svg" width="37" height="37">            |
| `ggdollar`   | <img src="inst/figures/ggdollar.svg" width="32" height="32">            | `ggfemale`   | <img src="inst/figures/ggfemale.svg" width="32" height="32">            | `gggraduation_cap` | <img src="inst/figures/gggraduation_cap.svg" width="32" height="32"> | `ggdisability` | <img src="inst/figures/ggdisability.svg" width="32" height="32">        |
| `ggmale`     | <img src="inst/figures/ggmale.svg" width="32" height="32">              | `ggmoney`    | <img src="inst/figures/ggmoney.svg" width="32" height="32">             | `gggsyringe` | <img src="inst/figures/ggsyringe.svg" width="32" height="32">           | `ggtree`     | <img src="inst/figures/ggtree.svg" width="32" height="32">              |
| `ggadenoma`  | <img src="inst/figures/ggadenoma.svg" width="32" height="32">           | `ggdistal`   | <img src="inst/figures/ggdistal.svg" width="32" height="32">            | `ggproximal` | <img src="inst/figures/ggproximal.svg" width="32" height="32">          | `ggrectum`   | <img src="inst/figures/ggrectum.svg" width="32" height="32">            |
| `ggone`      | <img src="inst/figures/ggone.svg" width="32" height="32">               | `ggtwo`      | <img src="inst/figures/ggtwo.svg" width="32" height="32">               | `ggthree`    | <img src="inst/figures/ggthree.svg" width="32" height="32">             | `ggfour`     | <img src="inst/figures/ggfour.svg" width="32" height="32">              |



##### 4.2.- Fontawesome Icons

<p style="display: flex; align-items: center;">
  <img src="inst/figures/logo.png" width="115px" alt="Logo" />
  <img src="inst/figures/fontawesome.png" width="125px" alt="Fontawesome" />
</p>

The package also allows the use of `fontawesome` icons. The icons are stored in the `fontawesome` package. The only thing that you need to specify is the name of the icon.

For example, this is just a few sample of more than 2,000 free icons available in the `fontawesome` package:


| List of Font Awesome icons                                                                                                                     | Preview                                                                                                       |
|:-----------------------------------------------------------------------------------------------------------------------------------------------:|:--------------------------------------------------------------------------------------------------------------:|
| **Sample icons:** <br>- home <br>- user <br>- envelope <br>- bell <br>- camera <br>- cog <br>- heart <br>- calendar <br>- cart-plus <br>- check <br>- cloud <br>- comment <br>- comments <br>- download <br>- edit <br>- file <br>- filter <br>- flag <br>- folder <br>- phone | <img src="inst/figures/fontawesome_table.jpg" width="900px" alt="fontawesome table preview" /> |

You can check the full list of icons in the [Font Awesome website](https://fontawesome.com/icons?d=gallery&p=2&m=free).

### 4.- Plot population chart

``` r
ggplot() +
  geom_pop(data = df_pop_mx_prop, aes(icon = icon, group=type, color=type),
           size = 1, arrange=F, legend_icons=F) +
  theme_void() +
  theme(legend.position = "bottom")
```

![Example Plot](https://raw.githubusercontent.com/jurjoroa/ggpopdata/main/inst/figures/example_plot1.png)


The `geom_pop()` function creates a population chart using the `df_prop_mx_f` dataset. The object work as a gem_point figure plotted by determined x and y coordinates. We can also group and color the icons by the **type** variable since the icon it's a svg file. 

#### 4.1 Improve plot 

Like a ggplot object, we can improve it to have a more presentable plot. We can arrange our icons, add them as part of the legend, give color to the background, and add a title and caption to the plot.

``` r
ggplot() +
    geom_pop(data = df_pop_mx_prop, aes(icon = icon, group=type, color=type),
    size = 1, arrange=T) +
    scale_legend_icon() + #add icon to the legend
    theme_void(base_size = 40) +
    theme(legend.position = "bottom") + 
labs(title = "Population in Mexico by Sex",
     subtitle = "2024",
     caption = "Source: demogmx") +
  theme(legend.title = element_blank(),
        plot.background = element_rect(fill = "black"),
        panel.background = element_rect(fill = "black"),
        legend.background = element_rect(fill = "black"),
        legend.text = element_text(color = "white"),
        plot.title = element_text(color = "white"),
        plot.subtitle = element_text(color = "white"),
        plot.caption = element_text(color = "white")) +
  scale_color_manual(values = c("male" = "#1E88E5", "female" = "#D81B60"),
                     labels = c("female" = "Females: 51%", "male" = "Males: 49%"))
```

![Example Plot](https://raw.githubusercontent.com/jurjoroa/ggpopdata/main/inst/figures/example_plot2.png)



### 5.- More examples

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
    type == "male" ~ "ggmale",
    type == "female" ~ "ggfemale",
    type == "disabled males" ~ "ggdisability",
    type == "disabled females" ~ "ggdisability"))

#4.- Plot 

ggplot() +
  geom_pop(data = df_pop_dis_mx_prop, aes(icon = icon, group=type, color=type),
           size = 1.3, arrange=F) +
  scale_legend_icon(size=10) +
  theme_void(base_size = 36) +
  labs(title = "Population in Mexico by Sex and condition",
       subtitle = "2022",
       caption = "As of 2023, 16% of the population in Mexico has some form of disability.") +
  theme(legend.position = "bottom",legend.title = element_blank()) +
  scale_color_manual(values = c("male" = "#1E88E5", "female" = "#D81B60",
                                "disabled males" = "#90CAF9", 
                                "disabled females" = "#F48FB1"),
                     labels = c("male" = "Males", "female" = "Females", 
                                "disabled females" = "Disabled Females",
                                "disabled males" = "Disabled Males"))
```


![Example Plot 3](https://raw.githubusercontent.com/jurjoroa/ggpopdata/main/inst/figures/example_plot3.png)


### 6.- Simulation of natural history of colorectal cancer example

As an applied example, we plotted the simulation of the natural history of colorectal cancer employing `ggpop` package. As it can be appreciated, the plot is a circular representative population chart, where the population is represented by icons. The icons are arranged in a circular manner, and the size of the icons is proportional to the population size. The icons are colored according to the type of cancer, and the legend is displayed at the bottom of the plot. The plot is visually appealing and informative, making it easy to understand the distribution of the population by cancer type.
This type of plots can be used to present complex population data in a more accessible and visually appealing way, specially if we want to transmit a message to a non-technical audience or decision makers. 

![SimCRC Natural History](https://raw.githubusercontent.com/jurjoroa/ggpopdata/main/inst/figures/simcrc_natural_history.png)

