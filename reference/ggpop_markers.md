# List the icon markers ggpop can render by name

Returns the bundled ggpop marker names and, if an icon directory is
given, the names of the user SVGs found there. These names (plus any
Font Awesome name) are valid values for the `icon` aesthetic of
[`geom_pop()`](https://jurjoroa.github.io/ggpop/reference/geom_pop.md)
and
[`geom_icon_point()`](https://jurjoroa.github.io/ggpop/reference/geom_icon_point.md).

## Usage

``` r
ggpop_markers(icon_path = getOption("ggpop.icon_path"))
```

## Arguments

- icon_path:

  Optional path to a folder of user SVG icons. Defaults to
  `getOption("ggpop.icon_path")`.

## Value

A list with element `bundled` (character vector of marker names) and,
when `icon_path` resolves to a directory, `user`.

## Examples

``` r
ggpop_markers()
#> $bundled
#>  [1] "circle-cross"        "circle-hollow"       "circle-inset"       
#>  [4] "circle-solid"        "diamond-cross"       "diamond-hollow"     
#>  [7] "diamond-inset"       "diamond-solid"       "plus-bold"          
#> [10] "plus-hollow"         "square-cross"        "square-hollow"      
#> [13] "square-inset"        "square-solid"        "triangle-down"      
#> [16] "triangle-down-inset"
#> 
```
