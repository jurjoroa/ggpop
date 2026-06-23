# CLAUDE.md — ggpop R package

## ALWAYS

- `<-` for assignment; `%>%` not `|>`; `TRUE`/`FALSE` not `T`/`F`
- `%||%` (rlang) for null coalescing
- Section banners between exported and internal functions in same file
- [`set.seed()`](https://rdrr.io/r/base/Random.html) whenever randomness
  is introduced

## NEVER

- Create new files unless a new logical component is added
- Commit, install, or run `R CMD INSTALL` /
  [`devtools::install()`](https://devtools.r-lib.org/reference/install.html)
- Use bundled datasets in vignettes — define data inline
- Abbreviate short words (`icon` not `ic`)
- Use `T` / `F`; native pipe `|>`; `=` for assignment

## 1. Naming Conventions

| Thing | Convention | Example |
|:---|:---|:---|
| Variables & functions | `snake_case` | `icon_var`, `validate_stroke_width()` |
| Data frames | `df_` prefix | `df_final`, `df_proportion` |
| Logical flags | `has_` / `is_` prefix | `has_facet`, `is_missing` |
| rlang symbols / quosures | `_sym` / `_quo` suffix | `group_var_sym` |
| Validation helpers | `validate_geom_<geom>_*` | `validate_geom_pop_*` |

### Prefixes

| Prefix   | Data type  | Prefix | Variable type  |
|:---------|:-----------|:-------|:---------------|
| *(none)* | scalar     | `n`    | number         |
| `v`      | vector     | `p`    | probability    |
| `m`      | matrix     | `r`    | rate           |
| `a`      | array      | `u`    | utility        |
| `df`     | data frame | `c`    | cost           |
| `dtb`    | data table | `hr`   | hazard ratio   |
| `l`      | list       | `rr`   | relative risk  |
|          |            | `ly`   | life years     |
|          |            | `q`    | QALYs          |
|          |            | `se`   | standard error |

## 2. Code Style

Multi-step pipelines — each verb on its own line:

``` r

df_result <- df_input %>%
  filter(!is.na(prop), prop > 0) %>%
  mutate(prop = n / sum(n)) %>%
  ungroup()
```

Break pipelines longer than ~10 steps into named intermediate objects.

## 3. Core Files

See `STRUCTURE.md`. Do not create new files unless a new logical
component is added. Do not mix exported and internal functions without a
section banner.

## 4. Vignettes

- Separate examples with `---` and `##` headings
- Define all data inline — no bundled datasets
- `high_group_var` takes a character string: `high_group_var = "region"`

## 5. Git & Releases

- Release runbook: `memory/RELEASE.md`
- Do not commit unless explicitly asked
