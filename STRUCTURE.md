# STRUCTURE.md — ggpop

## Links

- pkgdown: <https://jurjoroa.github.io/ggpop/>
- GitHub: <https://github.com/jurjoroa/ggpop>

## R/

| File | Purpose |
|:---|:---|
| `geom_pop.R` | Main [`geom_pop()`](https://jurjoroa.github.io/ggpop/reference/geom_pop.md) — delegates to helpers |
| `geom_pop-helpers.R` | All helpers for [`geom_pop()`](https://jurjoroa.github.io/ggpop/reference/geom_pop.md) |
| `geom_icon_point.R` | Main [`geom_icon_point()`](https://jurjoroa.github.io/ggpop/reference/geom_icon_point.md) |
| `geom-icon-point-helpers.R` | All helpers for [`geom_icon_point()`](https://jurjoroa.github.io/ggpop/reference/geom_icon_point.md) |
| `geom-pop-image.R` | Draw-time recoloring geom (`GeomPopImage`) shared by both geoms |
| `validators.R` | Shared validation functions |
| `process_data.R` | [`process_data()`](https://jurjoroa.github.io/ggpop/reference/process_data.md) standalone helper |
| `scale_legend_icon.R` | [`scale_legend_icon()`](https://jurjoroa.github.io/ggpop/reference/scale_legend_icon.md) |
| `theme-pop.R` | All `theme_pop*()` functions |
| `fa-icons.R` | [`fa_icons()`](https://jurjoroa.github.io/ggpop/reference/fa_icons.md) — search and list Font Awesome icons |
| `icon-utils.R` | Icon rendering — PNG generation, caching |
| `fetch_df_coordinates.R` | Coordinate system for `geom_pop` grid |
| `draw_key.R` | Custom legend key drawing |
| `globals.R` | [`utils::globalVariables`](https://rdrr.io/r/utils/globalVariables.html) declarations |
| `ggpop-package.R` | Package-level documentation |
| `zzz.R` | `.onLoad` / `.onAttach` hooks |

## Key Functions

| Function | File | Exported |
|:---|:---|:---|
| [`geom_pop()`](https://jurjoroa.github.io/ggpop/reference/geom_pop.md) | `geom_pop.R` | yes |
| [`geom_icon_point()`](https://jurjoroa.github.io/ggpop/reference/geom_icon_point.md) | `geom_icon_point.R` | yes |
| [`fa_icons()`](https://jurjoroa.github.io/ggpop/reference/fa_icons.md) | `fa-icons.R` | yes |
| [`scale_legend_icon()`](https://jurjoroa.github.io/ggpop/reference/scale_legend_icon.md) | `scale_legend_icon.R` | yes |
| `theme_pop*()` | `theme-pop.R` | yes |
| [`process_data()`](https://jurjoroa.github.io/ggpop/reference/process_data.md) | `process_data.R` | yes |
| `validate_geom_pop_*()` | `validators.R` | no |
| `validate_geom_icon_point_*()` | `validators.R` | no |

## Vignettes

| File | Purpose |
|:---|:---|
| `fa-icons.qmd` | [`fa_icons()`](https://jurjoroa.github.io/ggpop/reference/fa_icons.md) discovery guide |
| `getting-started.Rmd` | Getting started guide |
| `geom-icon-point.Rmd` | [`geom_icon_point()`](https://jurjoroa.github.io/ggpop/reference/geom_icon_point.md) main guide |
| `examples-geom-pop.Rmd` | [`geom_pop()`](https://jurjoroa.github.io/ggpop/reference/geom_pop.md) examples |
| `examples-geom-icon-point.Rmd` | [`geom_icon_point()`](https://jurjoroa.github.io/ggpop/reference/geom_icon_point.md) examples |
| `process-data.Rmd` | [`process_data()`](https://jurjoroa.github.io/ggpop/reference/process_data.md) guide |
| `themes-customization.Rmd` | Themes and customization |

## tests/testthat/

| File | Purpose |
|:---|:---|
| `test-01_geom_pop-warnings.R` | [`geom_pop()`](https://jurjoroa.github.io/ggpop/reference/geom_pop.md) warning tests |
| `test-02_geom_pop-errors.R` | [`geom_pop()`](https://jurjoroa.github.io/ggpop/reference/geom_pop.md) error tests |
| `test-03_geom_pop-checkpass.R` | [`geom_pop()`](https://jurjoroa.github.io/ggpop/reference/geom_pop.md) snapshot tests |
| `test-04_geom_pop-cowplot.R` | [`geom_pop()`](https://jurjoroa.github.io/ggpop/reference/geom_pop.md) cowplot integration |
| `test-05_geom_icon_point-warnings.R` | [`geom_icon_point()`](https://jurjoroa.github.io/ggpop/reference/geom_icon_point.md) warning tests |
| `test-06_geom_icon_point-errors.R` | [`geom_icon_point()`](https://jurjoroa.github.io/ggpop/reference/geom_icon_point.md) error tests |
| `test-07_geom_icon_point-checkpass.R` | [`geom_icon_point()`](https://jurjoroa.github.io/ggpop/reference/geom_icon_point.md) snapshot tests |
| `test-08_process_data.R` | [`process_data()`](https://jurjoroa.github.io/ggpop/reference/process_data.md) tests |
| `test-09_helper-functions.R` | Helper function tests |
| `test-10_scale_legend_icon.R` | [`scale_legend_icon()`](https://jurjoroa.github.io/ggpop/reference/scale_legend_icon.md) tests |
| `test-11_fa_icons.R` | [`fa_icons()`](https://jurjoroa.github.io/ggpop/reference/fa_icons.md) tests |

## memory/

| File                | Purpose                                        |
|:--------------------|:-----------------------------------------------|
| `memory/RELEASE.md` | NEWS.md template + release rules + gh commands |
