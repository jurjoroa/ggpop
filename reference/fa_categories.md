# List available Font Awesome icon categories

Returns the names of all built-in category groups used by
[`fa_icons`](https://jurjoroa.github.io/ggpop/reference/fa_icons.md).

## Usage

``` r
fa_categories(class_map = NULL)
```

## Arguments

- class_map:

  A named list mapping category names to regex patterns. Defaults to the
  internal `.fa_default_class_map()`.

## Value

A sorted character vector of category names.

## Examples

``` r
fa_categories()
#>  [1] "accessibility"       "alphanumeric"        "animals"            
#>  [4] "arrows_directional"  "arrows_extra"        "brands_commerce"    
#>  [7] "brands_dev_cloud"    "brands_misc"         "brands_social"      
#> [10] "buildings_extra"     "buildings_places"    "charts_analytics"   
#> [13] "clothing"            "communication"       "devices_hardware"   
#> [16] "emergency_hazards"   "entertainment"       "faces_emotions"     
#> [19] "files_folders"       "food_drink"          "food_extra"         
#> [22] "games_hobbies"       "gender_identity"     "government_law"     
#> [25] "hands_arms"          "household"           "industry_energy"    
#> [28] "location_navigation" "media_controls"      "media_filetypes"    
#> [31] "medical_extra"       "medical_health"      "money_currency"     
#> [34] "nature"              "nature_extra"        "objects_misc"       
#> [37] "office_docs"         "packaging"           "people_social"      
#> [40] "people_users"        "religion_extra"      "religion_symbols"   
#> [43] "security_privacy"    "shapes_symbols"      "shopping_commerce"  
#> [46] "sports"              "tech_science"        "text_formatting"    
#> [49] "time"                "tools_construction"  "transport_air_sea"  
#> [52] "transport_extra"     "transport_ground"    "travel_places"      
#> [55] "ui_actions"          "ui_controls"         "ui_navigation"      
#> [58] "weather"            
```
