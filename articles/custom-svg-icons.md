# Custom SVG Icons

ggpop resolves every icon name through a four-step priority chain:

1.  **Local `.svg` path** — a bare file path ending in `.svg`
2.  **`icon_path` folder** — bare name looked up inside a user-supplied
    directory
3.  **Bundled ggpop marker** — one of the 16 solid/outline markers
    shipped with the package
4.  **Font Awesome** — any valid FA name (the default for most icons)

The chain stops at the first match, so your files always take priority
over Font Awesome names.

## Bundled markers

ggpop ships 16 geometric markers you can use by name with no folder
needed. List them with
[`ggpop_markers()`](https://jurjoroa.github.io/ggpop/reference/ggpop_markers.md):

``` r

ggpop_markers()$bundled
```

     [1] "circle-cross"        "circle-hollow"       "circle-inset"
     [4] "circle-solid"        "diamond-cross"       "diamond-hollow"
     [7] "diamond-inset"       "diamond-solid"       "plus-bold"
    [10] "plus-hollow"         "square-cross"        "square-hollow"
    [13] "square-inset"        "square-solid"        "triangle-down"
    [16] "triangle-down-inset"

They work anywhere an icon name is expected — in
[`geom_icon_point()`](https://jurjoroa.github.io/ggpop/reference/geom_icon_point.md),
[`geom_pop()`](https://jurjoroa.github.io/ggpop/reference/geom_pop.md),
and
[`marker_legend()`](https://jurjoroa.github.io/ggpop/reference/marker_legend.md).

Show the code

``` r

families <- c("square", "circle", "diamond")
variants <- c("inset", "hollow", "cross", "solid")
pal <- c(square = "#1E88E5", circle = "#2A9D8F", diamond = "#E76F51")

icons <- paste(rep(families, each = 4), variants, sep = "-")
df_markers <- data.frame(
  icon   = c(icons, "plus-bold", "plus-hollow", "triangle-down", "triangle-down-inset"),
  x      = seq_len(16),
  y      = 1,
  colour = c(
    rep(pal["square"],  4),
    rep(pal["circle"],  4),
    rep(pal["diamond"], 4),
    "#6D6875", "#6D6875", "#6D6875", "#6D6875"
  ),
  stringsAsFactors = FALSE
)

ggplot(df_markers, aes(x = x, y = y, icon = icon, colour = colour)) +
  geom_icon_point(size = 8, dpi = 150, legend_icons = FALSE) +
  geom_text(aes(label = icon), y = 0.72, angle = 50,
            hjust = 1, size = 3, colour = "grey30") +
  scale_colour_identity() +
  scale_x_continuous(expand = expansion(add = c(0.8, 0.5))) +
  scale_y_continuous(limits = c(0.2, 1.4)) +
  theme_void()
```

![](custom-svg-icons_files/figure-html/fig-bundled-1.png)

Figure 1: All 16 bundled markers rendered with
[`geom_icon_point()`](https://jurjoroa.github.io/ggpop/reference/geom_icon_point.md).

## Mapping values to markers

[`marker_encode()`](https://jurjoroa.github.io/ggpop/reference/marker_encode.md)
turns data values into the marker names that the geoms already render.
The built-in `"sda2028"` scheme maps screening start and stop ages to
the bundled shape families and variants. One-time and no-screening rows
use their own markers:

``` r

df_screening <- data.frame(
  start = c(45, 50, 60, NA), stop = c(70, 85, NA, NA),
  once = c(FALSE, FALSE, TRUE, FALSE),
  none = c(FALSE, FALSE, FALSE, TRUE)
)
df_screening$icon <- marker_encode(
  df_screening$start, df_screening$stop,
  once = df_screening$once, none = df_screening$none
)
df_screening$icon
```

    [1] "square-inset" "circle-solid" "plus-bold"    "circle-solid"

For another encoding, pass a list of named `start`, `stop`, and `once`
vectors plus one `none` marker. Regular rows combine `start` and `stop`
values with a hyphen; one-time rows use the direct `once` lookup.

### Plotting encoded markers

The result is an ordinary `icon` column, so it goes straight into
[`geom_icon_point()`](https://jurjoroa.github.io/ggpop/reference/geom_icon_point.md).
Here every start age (rows) and stop age (columns) of the `"sda2028"`
scheme gets its own marker, and colour repeats the start age so the
shape family and the colour agree:

Show the code

``` r

df_schedule <- expand.grid(start = c(45, 50, 55), stop = c(70, 75, 80, 85))
df_schedule$icon <- marker_encode(df_schedule$start, df_schedule$stop)

pal_start <- c("45" = "#1E88E5", "50" = "#2A9D8F", "55" = "#E76F51")

ggplot(df_schedule, aes(x = stop, y = start, icon = icon,
                        colour = factor(start))) +
  geom_icon_point(size = 8, dpi = 150, legend_icons = FALSE) +
  scale_colour_manual(values = pal_start, guide = "none") +
  scale_x_continuous(breaks = c(70, 75, 80, 85), expand = expansion(add = 3)) +
  scale_y_continuous(breaks = c(45, 50, 55), expand = expansion(add = 3)) +
  labs(x = "Stop age", y = "Start age") +
  theme_minimal()
```

![](custom-svg-icons_files/figure-html/fig-marker-encode-grid-1.png)

Figure 2: Every start and stop age of the sda2028 scheme, encoded with
[`marker_encode()`](https://jurjoroa.github.io/ggpop/reference/marker_encode.md).

Rows flagged `once` or `none` skip the start/stop lookup, so their
`start` and `stop` may be missing. One-time screening uses solid markers
at ages 45, 50 and 55, `"plus-bold"` at 60 and `"triangle-down"` at 65.
`none = TRUE` returns the scheme’s fallback marker, which is the same
`"circle-solid"` as a one-time screen at 50, so colour is what tells
those two apart:

Show the code

``` r

df_special <- data.frame(
  label  = c("Once at 45", "Once at 50", "Once at 55",
             "Once at 60", "Once at 65", "No screening"),
  start  = c(45, 50, 55, 60, 65, NA),
  stop   = NA,
  once   = c(TRUE, TRUE, TRUE, TRUE, TRUE, FALSE),
  none   = c(FALSE, FALSE, FALSE, FALSE, FALSE, TRUE),
  colour = c(rep("#6D6875", 5), "#B8B4BE")
)
df_special$icon <- marker_encode(
  df_special$start, df_special$stop,
  once = df_special$once, none = df_special$none
)
df_special$x <- seq_len(nrow(df_special))

ggplot(df_special, aes(x = x, y = 1, icon = icon, colour = colour)) +
  geom_icon_point(size = 8, dpi = 150, legend_icons = FALSE) +
  geom_text(aes(label = label), y = 0.7, size = 3, colour = "grey30") +
  scale_colour_identity() +
  scale_x_continuous(expand = expansion(add = 0.6)) +
  scale_y_continuous(limits = c(0.5, 1.3)) +
  theme_void()
```

![](custom-svg-icons_files/figure-html/fig-marker-encode-special-1.png)

Figure 3: One-time and no-screening rows, encoded with `once` and
`none`.

## Using your own SVG files

Place your `.svg` files in a folder and pass the path via `icon_path`.
Reference each file by its bare name (no `.svg` extension):

``` r

# Folder layout:
#   my-icons/
#     hospital.svg
#     clinic.svg
#     pharmacy.svg

ggplot(df, aes(x = x, y = y, icon = facility_type, colour = region)) +
  geom_icon_point(size = 5, icon_path = "my-icons/") +
  scale_colour_manual(values = pal)
```

Set `options(ggpop.icon_path = "my-icons/")` once per session to avoid
repeating `icon_path` in every call:

``` r

options(ggpop.icon_path = "~/my-icons/")

# All three calls now resolve from ~/my-icons/ automatically
ggplot(df1, aes(x, y, icon = type)) + geom_icon_point()
ggplot(df2, aes(x, y, icon = type)) + geom_icon_point()
```

## Mixing icon sources

Sources can be mixed in a single plot — each `icon` value resolves
independently through the chain:

``` r

df_mixed <- data.frame(
  x    = 1:3,
  y    = 1,
  icon = c("hospital.svg",   # local absolute path  → resolves at step 1
            "square-solid",  # bundled marker       → resolves at step 3
            "stethoscope"),  # Font Awesome name     → resolves at step 4
  stringsAsFactors = FALSE
)

ggplot(df_mixed, aes(x = x, y = y, icon = icon)) +
  geom_icon_point(size = 6, icon_path = "my-icons/")
```

## Name shadowing

If a file in your `icon_path` folder shares a name with a Font Awesome
icon (e.g. `car.svg`), ggpop warns you at construction time:

``` r

# ~/my-icons/ contains car.svg and bus.svg — both are FA names
geom_icon_point(icon_path = "~/my-icons/")
#> Warning: 2 icon names in `icon_path` shadow Font Awesome names.
#> x Shadowed: "car", "bus".
#> i These will resolve to your SVG files, not Font Awesome icons.
#> i Rename the files (e.g. `my-car.svg`) to avoid the conflict.
```

The warning fires once at layer construction and is silent when there
are no conflicts.

## SVG tips

- **Single colour** — ggpop recolours icons by replacing the fill.
  Multi-colour SVGs will have all fills replaced by the mapped colour.
- **No embedded raster** — keep SVGs as pure vector paths; embedded PNGs
  inside SVGs are not recoloured.
- **`viewBox` required** — make sure your SVG has a `viewBox` attribute
  so ggpop can scale it correctly.
- **Naming** — avoid naming files the same as Font Awesome icons unless
  you intentionally want to override them.
