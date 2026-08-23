## R CMD check results

<!-- REGENERATE BEFORE SUBMITTING: the previous 0/0/0 line was measured on the
     pre-#393 tree (14 icons, 11 exports, no R/legend-canvas.R) and is no longer
     valid. Run R CMD check --as-cran on the actual submission tarball and paste
     the real counts here. -->

0 errors | 0 warnings | 0 notes

## Release notes (1.8.0)

This is a minor feature release adding custom SVG icon support, a composite
legend system for legends that ggplot2's own guides cannot express, and a
draw-time recolouring fix for icon colours.

### Bug fixes

- `geom_pop()` and `geom_icon_point()` now bake the mapped colour into each
  icon at draw time rather than relying on `ggimage`'s tinting, which depended
  on the installed `magick`/ImageMagick build producing an RGBA bitmap. Icons
  previously rendered black on some builds even though the legend was correct.

### New features

- `geom_pop()` and `geom_icon_point()` now accept custom SVG files via the
  new `icon_path` argument (or `options(ggpop.icon_path)`). Icons resolve in
  priority order: local `.svg` path -> `icon_path` folder -> bundled ggpop
  marker -> Font Awesome name. An unrecognised name raises a clear error.
- 16 bundled solid/outline markers (`square-*`, `circle-*`, `diamond-*`,
  `plus-bold`, `plus-hollow`, `triangle-down`, `triangle-down-inset`) are
  available by name with no folder needed.
- `ggpop_markers()` lists bundled and user-provided marker names.
- `marker_legend()` builds standalone composite legends for cases that
  ggplot2's built-in guides cannot express.
- A composite legend system built from plain data frames: `icon_grid()` derives
  icon row/column positions, `legend_canvas()` renders grid, colour-tile and
  typed-symbol sections from one data frame, `key_legend()` adds symbol +
  label entries, `legend_box()` fits a border to the rendered content,
  `legend_composite()` wraps the three-section case in one call, and
  `legend_ratios()` exposes the default proportion ladder.
- `legend_strip()` attaches a composite legend below a plot, working with
  `ggplot2::ggsave()` and `print()`.

### Dependency changes

- `patchwork` added to `Suggests`. It is used only by `legend_strip()` when the
  main plot is itself a `patchwork` object, and is guarded by
  `requireNamespace("patchwork", quietly = TRUE)`.

## Test environments

- macOS ARM64, R release (local)
- GitHub Actions: macOS-latest, windows-latest, ubuntu-latest (R devel, release, oldrel-1)
- CRAN win-builder (devel and release)
