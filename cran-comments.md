## R CMD check results

0 errors | 0 warnings | 0 notes

## Patch notes (1.7.1)

This is a patch release addressing a NOTE raised by CRAN after the 1.7.0 submission.

### NOTE fixed

`fetch_df_coordinates()` was writing a cache file to `~/.cache/R/ggpop/` during
package checks, triggering:

```
* checking for new files in some other directories ... NOTE
Found the following files/directories:
  '~/.cache/R/ggpop'
  '~/.cache/R/ggpop/df_coordinates_final_10_1000.rda'
```

The function now uses `tempdir()` when running on CRAN (`NOT_CRAN != "true"`) and
the persistent user cache only in interactive/local sessions.

## Test environments

- macOS ARM64, R release (local)
- GitHub Actions: macOS-latest, windows-latest, ubuntu-latest (R devel, release, oldrel-1)
- CRAN win-builder (devel and release)
