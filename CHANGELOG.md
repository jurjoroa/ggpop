# Changelog

## 2026-06-22 — v1.8.0: Custom icons, marker legend, and draw-time colour fix (ISS: #381)

### Fixed

**Icons now render with the correct mapped colour** (ISS: #380)

Both `geom_pop()` and `geom_icon_point()` previously rendered all icons in
solid black when a `colour` aesthetic was mapped, even though the legend keys
showed the correct colours. The root cause was that `ggimage::geom_image()`
applies a tint via `colour_image()` only when `data$colour` is non-`NULL`,
which clashes with Font Awesome's opaque SVG fills. The fix bakes the mapped
colour directly into each PNG at draw time via a new `GeomPopImage` proto
(`R/geom-pop-image.R`) that renders a fresh recoloured PNG per row, then sets
`data$colour <- NULL` so `ggimage` skips its tint step. This approach is
independent of the `magick` build and works for both Font Awesome icons and
custom SVG markers.

Files: `R/geom_pop.R`, `R/geom_icon_point.R`, `R/geom-pop-image.R`,
`R/icon-utils.R`

---

### Added

**Custom SVG icons via `icon` argument and `icon_path`** (ISS: #383)

Both geoms now accept three icon sources in order of resolution: a local
`.svg` file path, a file from a user-specified `icon_path` directory, a
bundled geometric marker (14 SVGs shipped in `inst/icons/`), or a Font Awesome
name. The 14 bundled markers follow a deliberate naming scheme
(`circle-inset`, `diamond-hollow`, `square-cross`, `plus-bold`, etc.) chosen
to avoid shadowing Font Awesome names; if an `icon_path` SVG filename
duplicates an FA name, a one-time warning fires. The new `ggpop_markers()`
function lists all bundled marker names. A companion `vignettes/articles/custom-svg-icons.qmd`
tutorial documents the full resolution order with a rendered gallery.

Files: `R/icon-utils.R`, `R/geom_pop.R`, `R/geom_icon_point.R`,
`inst/icons/` (14 SVGs), `vignettes/articles/custom-svg-icons.qmd`

---

**`marker_legend()` for standalone composite icon legends** (ISS: #385)

A new exported function that builds a standalone `ggplot` object displaying a
multi-column legend of labelled icons — covering cases where `ggplot2`'s native
guide system cannot express the desired symbology (e.g. SDA-style grouped
legends mixing custom SVGs and Font Awesome icons). Accepts the same icon
sources as the geoms, supports a `label_colour` argument (default `"black"`),
and can be composited with `cowplot::plot_grid()` or `patchwork`. A dedicated
vignette (`vignettes/articles/marker-legend.qmd`) demonstrates the full
layout workflow including the SDA 2028 map legend reproduction.

Files: `R/marker_legend.R`, `man/marker_legend.Rd`,
`vignettes/articles/marker-legend.qmd`

---

**pkgdown reference index and site improvements** (ISS: #381)

Added a structured `reference:` section to `_pkgdown.yml` grouping all 11
exports into four named categories (Core geoms, Data preparation, Legends &
icons, Themes), with `ggpop-package` filed under `internal`. The custom SVG
icons article was added to the Legends & Custom Icons navbar section. The
pkgdown site now renders a fully organised Functions page rather than an
unsorted auto-list.

Files: `_pkgdown.yml`

---

**README and docs polish** (ISS: #387)

Updated the README feature list and badges for 1.8.0, listing `marker_legend()`
and `ggpop_markers()` in the function reference. Added a one-time warning when
an `icon_path` SVG filename shadows a Font Awesome name. Documentation and
vignette examples were revised throughout to reflect the new icon resolution
order.

Files: `README.md`, `NEWS.md`
