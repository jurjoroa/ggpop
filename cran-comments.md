## R CMD check results

0 errors | 0 warnings | 0 notes

## Release notes (1.8.0)

This is a minor feature release adding custom SVG icon support and a new
composite legend function.

### New features

- `geom_pop()` and `geom_icon_point()` now accept custom SVG files via the
  new `icon_path` argument (or `options(ggpop.icon_path)`). Icons resolve in
  priority order: local `.svg` path → `icon_path` folder → bundled ggpop
  marker → Font Awesome name.
- 14 bundled solid/outline markers (`square-*`, `circle-*`, `diamond-*`,
  `plus-bold`, `triangle-down`) are available by name with no folder needed.
- `ggpop_markers()` lists bundled and user-provided marker names.
- `marker_legend()` builds standalone composite legends for cases that
  ggplot2's built-in guides cannot express.

## Test environments

- macOS ARM64, R release (local)
- GitHub Actions: macOS-latest, windows-latest, ubuntu-latest (R devel, release, oldrel-1)
- CRAN win-builder (devel and release)
