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

The dataset is downloaded from the following URL:
<https://raw.githubusercontent.com/jurjoroa/ggpopdata/main/data/df_coordinates_final.rda>.
The file is cached in a directory specific to the package, which is
determined using [`R_user_dir`](https://rdrr.io/r/tools/userdir.html).
If the dataset is already cached, it will be loaded directly from the
cache instead of downloading again.

## Examples

``` r
if (FALSE) { # \dontrun{
df <- fetch_df_coordinates()
head(df)
} # }
```
