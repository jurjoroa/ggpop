# Default proportion ladder for [`legend_composite`](https://jurjoroa.github.io/ggpop/reference/legend_composite.md)

Returns the fixed layout proportions used by
[`legend_composite`](https://jurjoroa.github.io/ggpop/reference/legend_composite.md)
as a named list. Lengths are multiples of the layout module (see the
`module` argument there); the two `*_label` entries are multiples of the
text base (`text` there). Override individual entries and pass the
result back via `legend_composite(ratios = ...)`.

## Usage

``` r
legend_ratios()
```

## Value

A named list of proportions.

## See also

[`legend_composite`](https://jurjoroa.github.io/ggpop/reference/legend_composite.md)
