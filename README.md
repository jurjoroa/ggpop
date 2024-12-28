
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

You can install `polite` from [CRAN](https://cran.r-project.org/) with:

``` r
install.packages("polite")
```

Development version of the package can be installed from
[Github](https://github.com/dmi3kno/polite) with:

``` r
install.packages("remotes")
remotes::install_github("dmi3kno/polite")
```

## Basic Example
``` r
library(polite)
library(rvest)

session <- bow("https://www.cheese.com/by_type", force = TRUE)
result <- scrape(session, query=list(t="semi-soft", per_page=100)) %>%
  html_node("#main-body") %>% 
  html_nodes("h3") %>% 
  html_text()
head(result)
#> [1] "3-Cheese Italian Blend"  "Abbaye de Citeaux"      
#> [3] "Abbaye du Mont des Cats" "Adelost"                
#> [5] "ADL Brick Cheese"        "Ailsa Craig"
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

