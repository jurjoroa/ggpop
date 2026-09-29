## R CMD check results

0 errors | 0 warnings | 0 notes

<!-- Measured 2026-09-28: R CMD check --as-cran --no-tests --no-manual on the
     1.9.0 tarball, local macOS ARM64. Tests were NOT part of that run. Re-run
     the full check (with tests) on the actual submission tarball before
     submitting and update this line if the counts change. -->

## Release notes (1.9.0)

This is a minor feature release adding a data-to-marker encoder and a reusable
specification for composite legends with external colour keys, plus two bug
fixes.

### New features

- `marker_encode()` turns data values into the icon names the geoms already
  render, using a marker scheme that maps one value to a shape family and
  another to a variant. A built-in `"sda2028"` scheme is included; a custom
  scheme is a plain list.
- `legend_spec()` stores the content of a composite legend and
  `legend_render()` lays it out and fits its border at a physical size.
  `legend_subset()` and `legend_add_key()` derive related legends from one
  specification without changing it.
- `legend_spec()` takes `label_fontface` and `symbol_title` arguments.

### Bug fixes

- `legend_box()` located content by gray level, so light saturated colours
  such as yellow counted as background and could sit outside the fitted
  border. It now tests each pixel's darkest colour channel.
- The bundled `"circle-cross"`, `"circle-hollow"` and `"circle-solid"` markers
  now share one visible diameter with `"circle-inset"`.

### Dependency changes

None relative to 1.8.0.

## Test environments

<!-- Fill in before submitting. Verified so far: local macOS ARM64, R release
     (R CMD check --as-cran, no tests). Not yet verified: GitHub Actions
     (macos-latest fails on a gdtools/XQuartz runner issue, fix pending),
     CRAN win-builder (devel and release), R-hub. -->

- macOS ARM64, R release (local)
- GitHub Actions: macOS-latest, windows-latest, ubuntu-latest (R devel, release, oldrel-1)
- CRAN win-builder (devel and release)
