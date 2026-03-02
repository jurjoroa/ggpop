# Search and list Font Awesome icons

Retrieves Font Awesome icon names, optionally filtered by a search query
or category. Results can be returned as a plain character vector or as a
tibble with category classification.

## Usage

``` r
fa_icons(
  query = NULL,
  category = NULL,
  regex = FALSE,
  classify = TRUE,
  include_unclassified = TRUE,
  class_map = NULL,
  primary_only = TRUE,
  as_vector = FALSE
)
```

## Arguments

- query:

  Character string. Filter icons whose names contain `query`. Set to
  `NULL` (default) to return all icons. If `regex = TRUE`, `query` is
  treated as a Perl-compatible regular expression.

- category:

  Character vector. One or more category names to filter by. Run
  `fa_categories()` to see valid options. Setting `category` implies
  `classify = TRUE`.

- regex:

  Logical. When `TRUE`, `query` is interpreted as a Perl-compatible
  regular expression. Default `FALSE` (fixed-string match).

- classify:

  Logical. When `TRUE` (default), each icon is classified into
  categories using `class_map` and a `primary_class` column is included
  in the returned tibble. Ignored when `as_vector = TRUE` and
  `category = NULL`.

- include_unclassified:

  Logical. When `FALSE`, icons that do not match any category pattern
  are dropped. Default `TRUE`.

- class_map:

  A named list mapping category names to regex patterns. Defaults to the
  internal `.fa_default_class_map()`.

- primary_only:

  Logical. When `TRUE` (default), the tibble contains only the
  `primary_class` column and omits `all_classes`.

- as_vector:

  Logical. When `TRUE`, return a plain sorted character vector of icon
  names instead of a tibble. If `category = NULL`, classification is
  skipped entirely. Default `FALSE`.

## Value

When `as_vector = TRUE`, a sorted character vector of icon names.
Otherwise a
[`tibble`](https://tibble.tidyverse.org/reference/tibble.html) with
columns:

- icon:

  Icon name (character).

- primary_class:

  Primary category the icon belongs to, or `NA` when unclassified
  (character).

- all_classes:

  All matching categories (list-column of character vectors). Only
  present when `primary_only = FALSE`.

## Examples

``` r
# All icons as a classified tibble
fa_icons()
#> # A tibble: 1,881 × 2
#>    icon  primary_class
#>    <chr> <chr>        
#>  1 0     alphanumeric 
#>  2 1     alphanumeric 
#>  3 2     alphanumeric 
#>  4 3     alphanumeric 
#>  5 4     alphanumeric 
#>  6 5     alphanumeric 
#>  7 6     alphanumeric 
#>  8 7     alphanumeric 
#>  9 8     alphanumeric 
#> 10 9     alphanumeric 
#> # ℹ 1,871 more rows

# Quick lookup — plain sorted vector
head(fa_icons(as_vector = TRUE), 10)
#>  [1] "0"        "1"        "2"        "3"        "4"        "42-group"
#>  [7] "5"        "500px"    "6"        "7"       

# Search for icons whose name contains "heart"
fa_icons(query = "heart")
#> # A tibble: 13 × 2
#>    icon                     primary_class   
#>    <chr>                    <chr>           
#>  1 face-grin-hearts         faces_emotions  
#>  2 face-kiss-wink-heart     faces_emotions  
#>  3 hand-holding-heart       hands_arms      
#>  4 heart                    medical_health  
#>  5 heart-circle-bolt        medical_health  
#>  6 heart-circle-check       medical_health  
#>  7 heart-circle-exclamation medical_health  
#>  8 heart-circle-minus       medical_health  
#>  9 heart-circle-plus        medical_health  
#> 10 heart-circle-xmark       medical_health  
#> 11 heart-crack              medical_health  
#> 12 heart-pulse              medical_health  
#> 13 shield-heart             security_privacy

# Filter by category
fa_icons(category = "animals")
#> # A tibble: 17 × 2
#>    icon         primary_class
#>    <chr>        <chr>        
#>  1 cat          animals      
#>  2 cow          animals      
#>  3 crow         animals      
#>  4 dog          animals      
#>  5 dove         animals      
#>  6 dragon       animals      
#>  7 fish         food_drink   
#>  8 fish-fins    food_drink   
#>  9 frog         animals      
#> 10 hippo        animals      
#> 11 horse        animals      
#> 12 horse-head   animals      
#> 13 kiwi-bird    animals      
#> 14 mosquito     animals      
#> 15 mosquito-net animals      
#> 16 otter        animals      
#> 17 spider       animals      

# Regex search — all icons starting with "arrow"
fa_icons(query = "^arrow", regex = TRUE)
#> # A tibble: 53 × 2
#>    icon                      primary_class     
#>    <chr>                     <chr>             
#>  1 arrow-down                arrows_directional
#>  2 arrow-down-1-9            arrows_directional
#>  3 arrow-down-9-1            arrows_directional
#>  4 arrow-down-a-z            arrows_directional
#>  5 arrow-down-long           arrows_directional
#>  6 arrow-down-short-wide     arrows_directional
#>  7 arrow-down-up-across-line arrows_directional
#>  8 arrow-down-up-lock        arrows_directional
#>  9 arrow-down-wide-short     arrows_directional
#> 10 arrow-down-z-a            arrows_directional
#> # ℹ 43 more rows
```
