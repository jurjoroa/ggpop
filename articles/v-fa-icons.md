# fa_icons()

[`fa_icons()`](https://jurjoroa.github.io/ggpop/reference/fa_icons.md)
searches the bundled Font Awesome icon list by keyword. Use it to find
valid icon names before building your `icon` column.

## Search by keyword

``` r

fa_icons(query = "person")
fa_icons(query = "car")
fa_icons(query = "heart")
```

``` r

head(fa_icons(query = "person"), 8)
#> # A tibble: 8 × 2
#>   icon                      primary_class
#>   <chr>                     <chr>        
#> 1 hot-tub-person            people_social
#> 2 person                    people_users 
#> 3 person-arrow-down-to-line people_users 
#> 4 person-arrow-up-from-line people_users 
#> 5 person-biking             people_users 
#> 6 person-booth              people_users 
#> 7 person-breastfeeding      people_users 
#> 8 person-burst              people_users
```

## Common icon categories

Some frequently used categories and example names:

| Category    | Example names                             |
|:------------|:------------------------------------------|
| People      | `person`, `person-dress`, `user`, `child` |
| Health      | `heart`, `stethoscope`, `syringe`, `pill` |
| Transport   | `car`, `bicycle`, `plane`, `bus`          |
| Nature      | `tree`, `leaf`, `seedling`, `sun`         |
| UI / shapes | `circle`, `square`, `star`, `check`       |

Use `fa_icons(query = "...")` to explore any category. The `name` column
in the result is what goes in your `icon` column or the `icon`
parameter.
