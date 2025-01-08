
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


`ggpop` is an R package that extends the capabilities of ggplot2 to create visually engaging and informative population charts.`ggpop` allows users to represent population data proportionally using customizable icons, enabling the creation of circular representative population charts with ease. Additionally, the package offers tools for adding descriptive captions adorned with icons, enhancing visualizations' interpretability and aesthetic appeal.

## Alternative Way to Show Information

`ggpop` is an alternative to conventional visualization techniques by incorporating icons and proportional representation into population charts. This method enhances the aesthetic quality of the plots and facilitates better audience engagement and understanding. By transforming numerical data into meaningful visual symbols, `ggpop` enables users to tell a more compelling story with their data, making complex information accessible and memorable.




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

| type   | pos |        n |      prop   |
|:-------|----:|---------:|------------:|
| male   |   1 | 63459580 | 0.4849388    |
| female |   2 | 67401427 | 0.5150612    |
| female |   3 | 67401427 | 0.5150612    |
| male   |   4 | 63459580 | 0.4849388    |
| male   |   5 | 63459580 | 0.4849388    |
| female |   6 | 67401427 | 0.5150612    |
| female |   7 | 67401427 | 0.5150612    |
| male   |   8 | 63459580 | 0.4849388    |
| female |   9 | 67401427 | 0.5150612    |
| male   |  10 | 63459580 | 0.4849388    |
| female |  11 | 67401427 | 0.5150612    |
| ...    | ... | ...      | ...         |

We apply the `process_data()` function to the population data `df_pop_mx` with the following parameters:

- **group_var = sex**: groups the data by sex (male/female). This is our grouping variable
- **sum_var = n**: uses the column `n` (population counts) for group totals. This is the variable that will be summed up to calculate proportions.
- **sample_size = 1000**: generates 1,000 sampled records, proportionally allocated to each group. The package allows up to a sample size of 1000. 

The function calculates group proportions, then performs sampling to create a new data frame (`df_pop_mx_prop`). Each row represents one draw from the 1,000 samples. Notable columns:

- **type**: which group (male or female) was sampled.
- **pos**: the position/index in the sample (from 1 to 1,000).
- **n**: total population count of the corresponding group.
- **prop**: proportion of that group in the overall dataset.


```r
df_pop_mx_prop <- process_data(data = df_pop_mx, group_var = sex, 
                               sum_var = n, sample_size = 1000)
```

### 3.- Assign icons to groups

Here, we create a new column called `icon` in the `df_pop_mx_prop` dataset. The `case_when()` function checks each row’s **type** (either "male" or "female") and assigns a matching value ("male" or "female") to the `icon` column.

``` r
df_pop_mx_prop <- df_pop_mx_prop %>% 
  mutate(icon = case_when(
    type == "male" ~ "male",
    type == "female" ~ "female"))
```


## Extended Example

``` r
library(polite)
library(rvest)
library(purrr)
library(dplyr)

session <- bow("https://www.cheese.com/alphabetical")

# this is only to illustrate the example.
letters <- letters[1:3] # delete this line to scrape all letters

responses <- map(letters, ~scrape(session, query = list(per_page=100,i=.x)) )
results <- map(responses, ~html_nodes(.x, "#id_page li") %>% 
                           html_text(trim = TRUE) %>% 
                           as.numeric() %>%
                           tail(1) ) %>% 
           map(~pluck(.x, 1, .default=1))
pages_df <- tibble(letter = rep.int(letters, times=unlist(results)),
                   pages = unlist(map(results, ~seq.int(from=1, to=.x))))
pages_df
#> # A tibble: 6 × 2
#>   letter pages
#>   <chr>  <int>
#> 1 a          1
#> 2 b          1
#> 3 b          2
#> 4 c          1
#> 5 c          2
#> 6 c          3
```

``` r
get_cheese_page <- function(letter, pages){
 lnks <- scrape(session, query=list(per_page=100,i=letter,page=pages)) %>% 
    html_nodes("h3 a")
tibble(name=lnks %>% html_text(),
       link=lnks %>% html_attr("href"))
}

df <- pages_df %>% pmap_df(get_cheese_page)
df
#> # A tibble: 518 × 2
#>    name                    link                     
#>    <chr>                   <chr>                    
#>  1 Abbaye de Belloc        /abbaye-de-belloc/       
#>  2 Abbaye de Belval        /abbaye-de-belval/       
#>  3 Abbaye de Citeaux       /abbaye-de-citeaux/      
#>  4 Abbaye de Tamié         /tamie/                  
#>  5 Abbaye de Timadeuc      /abbaye-de-timadeuc/     
#>  6 Abbaye du Mont des Cats /abbaye-du-mont-des-cats/
#>  7 Abbot’s Gold            /abbots-gold/            
#>  8 Abertam                 /abertam/                
#>  9 Abondance               /abondance/              
#> 10 Acapella                /acapella/               
#> # … with 508 more rows
```

## Another example

``` r
    library(polite)
    library(rvest)
    
    hrbrmstr_posts <- data.frame()
    url <- "https://rud.is/b/"
    session <- bow(url)
    
    while(!is.na(url)){
      # make it verbose
      message("Scraping ", url)
      # nod and scrape
      current_page <- nod(session, url) %>% 
        scrape(verbose=TRUE)
      # extract post titles
      hrbrmstr_posts <- current_page %>% 
        html_nodes(".entry-title a") %>% 
        polite::html_attrs_dfr() %>% 
        rbind(hrbrmstr_posts)
      # see if there's "Older posts" button
      url <- current_page %>% 
        html_node(".nav-previous a") %>% 
        html_attr("href")
    } # end while loop
    
    tibble::as_tibble(hrbrmstr_posts)
    #> # A tibble: 578 x3
```

