# Fetches the `df_coordinates_final` Dataset

Downloads and caches the `df_coordinates_final` dataset if it is not
already cached locally. This function ensures that the dataset is
downloaded only once and loaded into memory without cluttering the
global environment. The dataset is stored in a package-specific cache
directory and retrieved efficiently for subsequent uses.

## Usage

``` r
fetch_df_coordinates()
```

## Value

A data frame containing the `df_coordinates_final` dataset.

## Details

The dataset is downloaded from GitHub The file is cached in a directory
specific to the package, which is determined using
[`R_user_dir`](https://rdrr.io/r/tools/userdir.html). If the dataset is
already cached, it will be loaded directly from the cache instead of
downloading again.

## Examples

``` r
# \donttest{
df <- fetch_df_coordinates()
#> ggpop: downloading coordinate data from GitHub (~2 MB) and caching it locally.
#> This happens once. Future calls will load from cache.
head(df)
#>   X pos         x1         y1 size
#> 1 1   1  0.0000000  0.0000000    1
#> 2 2   1 -0.2622589 -0.6895521   10
#> 3 3   2  0.2622589 -0.6895521   10
#> 4 4   3 -0.6542075 -0.3409904   10
#> 5 5   4  0.6542075 -0.3409904   10
#> 6 6   5  0.0000000 -0.2353064   10
# }
```
