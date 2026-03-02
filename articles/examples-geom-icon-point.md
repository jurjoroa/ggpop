# geom_icon_point() Examples

## Example 1: Single Icon Scatter Plot

  

The simplest use: a fixed icon for all points, color encodes the
grouping variable.

Show the code

``` r
fa_icons(query = "seedling")

ggplot(iris, aes(x = Sepal.Length, y = Petal.Length, color = Species)) +
  geom_icon_point(icon = "seedling", size = 1.5, dpi = 100) +
  scale_color_manual(values = c(
    "setosa"     = "#43A047",
    "versicolor" = "#1E88E5",
    "virginica"  = "#E53935"
  )) +
  theme(plot.title = element_text(size = 16, face = "bold")) +
  labs(
    title    = "Iris: Sepal vs. Petal Length",
    subtitle = "Fixed icon — color encodes species",
    x        = "Sepal Length (cm)",
    y        = "Petal Length (cm)",
    color    = "Species"
  )
```

![](examples-geom-icon-point_files/figure-html/single-icon-1.png)

  

------------------------------------------------------------------------

## Example 2: Different Icon per Category

  

Each food item gets its own icon. The icon is the identity — no legend
needed to understand what each point represents.

Show the code

``` r
library(ggpop)
library(ggplot2)
library(dplyr)

# Search the icons you want to use with fa_icons() and note their names:
fa_icons(query = "apple")
fa_icons(query = "drumstick")

df_food <- data.frame(
  food     = c("Apple", "Carrot", "Orange", "Chicken", "Beef", "Salmon",
               "Milk", "Cheese", "Yogurt"),
  calories = c(52, 41, 47, 165, 250, 208, 61, 402, 59),
  protein  = c(0.3, 1.1, 0.9, 31, 26, 20, 3.2, 25, 10),
  group    = c(rep("Fruit & Veg", 3), rep("Meat & Fish", 3), rep("Dairy", 3)),
  icon     = c("apple-whole", "carrot", "lemon",
               "drumstick-bite", "bacon", "fish",
               "bottle-water", "cheese", "jar")
)

df_food$group <- factor(df_food$group,
  levels = c("Fruit & Veg", "Dairy", "Meat & Fish"))

ggplot(df_food, aes(x = calories, y = protein, icon = icon, color = food)) +
  geom_icon_point(size = 2, dpi = 100) +
  scale_color_manual(values = c(
    "Apple" = "#43A047", "Carrot" = "#43A047", "Orange" = "#43A047",
    "Dairy"        = "#1E88E5",
    "Milk" = "#1E88E5", "Cheese" = "#1E88E5", "Yogurt" = "#1E88E5",
    "Meat & Fish"  = "#E53935",
    "Chicken" = "#E53935", "Beef" = "#E53935", "Salmon" = "#E53935"
  )) +
  theme(plot.title = element_text(size = 16, face = "bold")) +
  labs(
    title    = "Calories vs. Protein by Food",
    subtitle = "Each icon represents a specific food; color reflects the group",
    x        = "Calories (per 100g)",
    y        = "Protein (g per 100g)",
    color    = "Group"
  )
```

![](examples-geom-icon-point_files/figure-html/mapped-icons-1.png)

  

------------------------------------------------------------------------

## Example 3: Size Mapping

  

Map a continuous variable to icon size. Use
[`scales::rescale()`](https://scales.r-lib.org/reference/rescale.html)
to keep sizes readable.

Show the code

``` r
library(ggpop)
library(ggrepel)
library(ggtext)

# Search the icons you want to use with fa_icons() and note their names:
fa_icons(query = "apple")
fa_icons(query = "microchip")


df_brand <- data.frame(
  brand      = c("Apple", "Google", "Microsoft", "Meta", "Amazon",
                 "Netflix", "Spotify", "Uber", "Airbnb",
                 "Nvidia", "Tesla", "TSMC", "Samsung", "AMD",
                 "Broadcom", "ASML", "Oracle", "Salesforce", "Adobe",
                 "IBM", "Cisco", "Tencent", "Alibaba", "Visa", "Mastercard"),
  revenue    = c(394, 283, 212, 117, 514,
                 32, 13, 37, 9,
                 61, 96, 69, 200, 23,
                 36, 28, 53, 35, 19,
                 62, 57, 87, 126, 33, 25),
  market_cap = c(2950, 1750, 2800, 1200, 1750,
                 190, 55, 140, 75,
                 2200, 600, 600, 400, 250,
                 900, 350, 320, 280, 260,
                 170, 220, 400, 200, 520, 430),
  employees  = c(160, 180, 220, 86, 1540,
                 13, 9, 32, 6,
                 26, 140, 73, 270, 26,
                 34, 42, 164, 80, 29,
                 288, 85, 105, 235, 28, 30),
  icon       = c("apple", "google", "windows", "meta", "amazon",
                 "tv", "spotify", "uber", "airbnb",
                 "microchip", "car", "memory", "mobile", "spinner",
                 "server", "cogs", "database", "cloud", "pen",
                 "terminal", "wifi", "message", "sim-card", "credit-card", "wallet")
)

pal <- c(
  "Apple"      = "#F2F2F2",
  "Google"     = "#7BA7FF",  # soft blue
  "Microsoft"  = "#6FD3FF",  # airy cyan
  "Meta"       = "#6FAEFF",  # cornflower-ish
  "Amazon"     = "#FFB86B",  # softer orange
  "Netflix"    = "#FF5A6A",  # softer red
  "Spotify"    = "#4FE38A",  # softer green
  "Uber"       = "#A9F2EE",  # pale aqua
  "Airbnb"     = "#FF7D86",  # soft coral-pink
  "Nvidia"     = "#9BE56D",  # softer lime
  "Tesla"      = "#FF6B6B",  # soft red
  "TSMC"       = "#FF8A80",  # soft salmon
  "Samsung"    = "#8FB3FF",  # soft periwinkle (no dark blue)
  "AMD"        = "#FF7A7A",  # soft red
  "Broadcom"   = "#FF8FB1",  # soft rose
  "ASML"       = "#93C9FF",  # soft sky blue
  "Oracle"     = "#FF7C7C",  # soft red
  "Salesforce" = "#79D7FF",  # light azure
  "Adobe"      = "#FF6F6F",  # soft red
  "IBM"        = "#8EC5FF",  # soft blue
  "Cisco"      = "#73E3FF",  # light cyan-blue
  "Tencent"    = "#86D0FF",  # soft blue
  "Alibaba"    = "#FFC07A",  # soft orange
  "Visa"       = "#9AB6FF",  # soft blue (replaces dark navy)
  "Mastercard" = "#FF8A5C"   # soft orange-red
)

bg          <- "#080C18"
col_title   <- "white"
col_accent  <- "#FF7F6E"
col_axis    <- "#C17B6F"
col_grid    <- "white"
col_caption <- "#6B3F38"
col_segment <- "#3D2420"

df_brand$size_scaled <- scales::rescale(df_brand$employees, to = c(1.2, 3.2))

ggplot(df_brand, aes(x = revenue, y = market_cap,
                     icon = icon, color = brand, size = size_scaled)) +
  geom_abline(slope = 1, intercept = log10(5),  linetype = "dashed",
              color = alpha("white", 0.25), linewidth = 0.5) +
  geom_abline(slope = 1, intercept = log10(10), linetype = "dashed",
              color = alpha("white", 0.25), linewidth = 0.5) +
  annotate("text", x = 500, y = 3200, label = "P/S ratio = 10×",
           color = col_accent, size = 2.8, hjust = 1,
           fontface = "italic", alpha = 0.6) +
  annotate("text", x = 500, y = 1600, label = "P/S ratio = 5×",
           color = col_accent, size = 2.8, hjust = 1,
           fontface = "italic", alpha = 0.6) +
  geom_icon_point(dpi = 150) +
  ggrepel::geom_label_repel(
    aes(label = paste0(brand, "\n$", market_cap, "B"), color = brand),
    fill          = alpha(bg, 0.88),
    label.size    = 0,
    size          = 2.6,
    fontface      = "bold",
    lineheight    = 1.2,
    label.padding = unit(0.25, "lines"),
    box.padding   = unit(0.5,  "lines"),
    point.padding = unit(0.4,  "lines"),
    max.overlaps  = Inf,
    segment.color = col_segment,
    segment.size  = 0.35,
    segment.alpha = 0.9,
    seed          = 42,
    show.legend   = FALSE
  ) +
  scale_x_log10(
    labels = scales::dollar_format(suffix = "B"),
    breaks = c(10, 50, 100, 500),
    expand = expansion(mult = c(0.05, 0.1))
  ) +
  scale_y_log10(
    labels = scales::dollar_format(suffix = "B"),
    breaks = c(50, 100, 500, 1000, 3000),
    expand = expansion(mult = c(0.05, 0.1))
  ) +
  scale_color_manual(values = pal, guide = "none") +
  scale_size_continuous(
    range  = c(1.2, 3.2),
    labels = function(x) paste0(
      round(scales::rescale(x, from = c(1.2, 3.2),
                            to = range(df_brand$employees))), "K"),
    breaks = scales::rescale(c(50, 100, 250, 500, 1000, 1540),
                             from = range(df_brand$employees), to = c(1.2, 3.2))
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.background   = element_blank(),
    panel.background  = element_blank(),
    panel.grid.major  = element_line(color = alpha(col_grid, 0.22), linewidth = 0.5),
    panel.grid.minor  = element_blank(),
    legend.background = element_blank(),
    legend.key        = element_blank(),
    axis.text         = element_text(color = col_axis,   size = 10),
    axis.title        = element_text(color = col_accent, size = 11),
    plot.title        = ggtext::element_markdown(
      size = 22, face = "bold", hjust = 0.5,
      color = col_title, margin = margin(b = 6)
    ),
    plot.subtitle     = ggtext::element_markdown(
      size = 11, hjust = 0.5,
      color = col_accent, lineheight = 1.5,
      margin = margin(b = 16)
    ),
    plot.caption      = element_text(
      size = 8.5, hjust = 0.5, color = col_caption,
      lineheight = 1.4, margin = margin(t = 14)
    ),
    legend.position   = "bottom",
    legend.title      = element_text(color = col_accent, size = 10, face = "bold"),
    legend.text       = element_text(color = col_axis,   size = 9),
    legend.margin     = margin(t = 8),
    plot.margin       = margin(24, 28, 18, 24)
  ) +
  labs(
    title    = "Tech Giants: Revenue vs. Market Cap",
    subtitle = "Each icon = brand &nbsp;\u00b7&nbsp; Size = employee count &nbsp;\u00b7&nbsp; Both axes log-scaled &nbsp;\u00b7&nbsp; Dashed lines = P/S ratio",
    caption  = "Source: Public filings & estimates (2023)  \u00b7  Visualization: ggpop",
    x        = "Annual Revenue (USD, log scale)",
    y        = "Market Capitalisation (USD, log scale)",
    size     = "Employees"
  )
```

![](examples-geom-icon-point_files/figure-html/size-mapping-1.png)

  

------------------------------------------------------------------------

## Example 4: Paris 2024 Olympics — New Sports

  

[`geom_icon_point()`](https://jurjoroa.github.io/ggpop/reference/geom_icon_point.md)
in a fixed-position grid with no traditional axes. All 45 Olympic
disciplines at Paris 2024 are arranged in a 9×5 layout, each with its
own icon. The 4 sports making their Olympic debut are highlighted in
cyan; all existing disciplines are in gold. Annotations use `ggtext` for
inline HTML styling.

Show the code

``` r
library(ggpop)
library(ggplot2)
library(dplyr)
library(ggtext)

# Search the icons you want to use with fa_icons() and note their names:
fa_icons(query = "person-swimming")
fa_icons(query = "volleyball")

df_paris_disciplines <- data.frame(
  sport = c(
    "Swimming", "Diving", "Water Polo", "Artistic Swim", "Open Water",
    "Badminton", "Tennis", "Table Tennis",
    "Volleyball", "Beach Volley", "Basketball", "3x3 Basketball",
    "Handball", "Hockey",
    "Boxing", "Judo", "Taekwondo", "Wrestling", "Fencing",
    "Athletics", "Triathlon", "Pentathlon", "Rowing", "Sailing",
    "Football", "Rugby", "Golf",
    "Archery", "Shooting",
    "Road Cycling", "Track Cycling", "MTB", "BMX Racing", "BMX Freestyle",
    "Equestrian", "Gymnastics", "Rhythmic Gym", "Trampoline", "Weightlifting",
    "Canoe Sprint", "Canoe Slalom",
    "Breaking", "Skateboarding", "Sport Climbing", "Surfing"
  ),
  icon = c(
    "person-swimming", "water", "droplet", "star", "wave-square",
    "table-tennis-paddle-ball", "baseball-bat-ball", "circle",
    "volleyball", "umbrella-beach", "basketball", "people-group",
    "hand-holding", "hockey-puck",
    "hand-fist", "hands", "shoe-prints", "person", "shield",
    "person-running", "person-biking", "list-check", "anchor", "sailboat",
    "futbol", "football", "golf-ball-tee",
    "bullseye", "gun",
    "road", "bicycle", "tree", "flag-checkered", "infinity",
    "horse", "child", "ribbon", "arrows-up-to-line", "dumbbell",
    "water-ladder", "person-falling-burst",
    "music", "person-skating", "mountain", "compass"
  ),
  is_new = c(rep(FALSE, 41), TRUE, TRUE, TRUE, TRUE)
)

stopifnot(nrow(df_paris_disciplines) == 45)
stopifnot(!anyDuplicated(df_paris_disciplines$sport))
stopifnot(!anyDuplicated(df_paris_disciplines$icon))

bg <- "#01394f"

df_grid <- expand.grid(x = 1:9, y = 5:1) %>%
  arrange(y, x) %>%
  mutate(
    sport  = df_paris_disciplines$sport,
    icon   = df_paris_disciplines$icon,
    is_new = df_paris_disciplines$is_new,
    color  = ifelse(is_new, "#4DEEEA", "#E8C84A")
  )

ggplot(df_grid, aes(x = x, y = y)) +
  geom_icon_point(
    aes(icon = icon, color = I(color)),
    size = 1.55, dpi = 100
  ) +
  geom_text(
    aes(y = y - 0.38, label = sport, color = I(color)),
    size = 1.5, lineheight = 0.85, fontface = "bold"
  ) +
  annotate(
    "richtext",
    x = 5, y = 7.8,
    label = "<span style='color:#4DEEEA; font-size:28pt'><b>4 NEW SPORTS</b></span><br>
             <span style='color:#E8C84A; font-size:18pt'>JOIN THE PARIS 2024 OLYMPICS</span>",
    fill = NA, label.size = 0, lineheight = 1.2
  ) +
  annotate(
    "richtext",
    x = 5, y = 6.75,
    label = "<span style='color:#4DEEEA; font-size:9pt'><b>BREAKING &nbsp;\u00b7&nbsp;
             SKATEBOARDING &nbsp;\u00b7&nbsp; SPORT CLIMBING &nbsp;\u00b7&nbsp; SURFING</b></span>",
    fill = NA, label.size = 0
  ) +
  annotate("point", x = 2.6, y = -0.55, color = "#E8C84A", size = 3.5) +
  annotate("text",  x = 3.0, y = -0.55,
           label = "Existing discipline (41)", color = "#E8C84A",
           size = 3.0, hjust = 0, fontface = "bold") +
  annotate("point", x = 6.2, y = -0.55, color = "#4DEEEA", size = 3.5) +
  annotate("text",  x = 6.6, y = -0.55,
           label = "New sport (4)", color = "#4DEEEA",
           size = 3.0, hjust = 0, fontface = "bold") +
  annotate(
    "richtext",
    x = 5, y = -1.15,
    label = "<span style='color:#E8C84A'>Source: IOC / Paris 2024 &nbsp;\u00b7&nbsp;
             Original concept: <span style='color:#4DEEEA'>G. Karamanis</span>
             &nbsp; github.com/gkaramanis/30DayChartChallenge &nbsp;\u00b7&nbsp;
             Remake: ggpop</span>",
    fill = NA, label.size = 0, size = 2.5, lineheight = 1.2
  ) +
  coord_fixed(clip = "off", xlim = c(0.5, 9.5), ylim = c(-1.6, 9.2)) +
  theme_void() +
  theme(
    plot.background = element_rect(fill = bg, color = NA),
    plot.margin     = margin(30, 40, 60, 40)
  )
```

![](examples-geom-icon-point_files/figure-html/paris-display-1.png)

  

------------------------------------------------------------------------

## Example 5: Combined Geoms

  

[`geom_icon_point()`](https://jurjoroa.github.io/ggpop/reference/geom_icon_point.md)
works alongside any ggplot2 geom. Here combined with
[`geom_smooth()`](https://ggplot2.tidyverse.org/reference/geom_smooth.html),
reference lines, labels, and quadrant annotations.

Show the code

``` r
# Search the icons you want to use with fa_icons() and note their names:
fa_icons(query = "pills")
fa_icons(query = "stethoscope")
fa_icons(query = "hospital")

df_health <- data.frame(
  country  = c("Chad", "Mali", "Niger", "Bolivia", "Egypt",
               "Morocco", "Germany", "France", "Japan"),
  spend    = c(27, 30, 22, 215, 185, 190, 5986, 4902, 4717),
  life_exp = c(54, 58, 62, 71, 72, 74, 81, 83, 84),
  income   = c(rep("Low", 3), rep("Middle", 3), rep("High", 3)),
  icon     = c(rep("pills", 3), rep("stethoscope", 3), rep("hospital", 3))
)

df_health$income <- factor(df_health$income,
  levels = c("Low", "Middle", "High"))

ggplot(df_health, aes(x = spend, y = life_exp,
                        icon = icon, color = income)) +
  geom_vline(xintercept = 500, linetype = "dashed",
             color = "#546E7A", linewidth = 0.5) +
  geom_hline(yintercept = 72, linetype = "dashed",
             color = "#546E7A", linewidth = 0.5) +
  geom_smooth(aes(group = 1), method = "lm", se = TRUE,
              color = "#78909C", fill = "#ECEFF1",
              linewidth = 0.7, linetype = "dotted", alpha = 0.4) +
  geom_icon_point(size = 2, dpi = 100) +
  geom_label(aes(label = country), color = "white",
             fill = "#1E3A5F", label.size = 0,
             label.padding = unit(0.15, "lines"),
             vjust = -1.3, size = 3) +
  annotate("text", x = 20, y = 84, label = "EFFICIENT",
           color = "#546E7A", size = 2.5, hjust = 0, fontface = "bold") +
  annotate("text", x = 1500, y = 56, label = "COSTLY &\nINEFFICIENT",
           color = "#546E7A", size = 2.5, hjust = 0,
           fontface = "bold", lineheight = 0.9) +
  scale_x_log10(labels = scales::dollar_format()) +
  scale_color_manual(values = c(
    "Low"    = "#E53935",
    "Middle" = "#FFB300",
    "High"   = "#43A047"
  )) +
  theme_pop() +
  theme(
    plot.background   = element_blank(),
    panel.background  = element_blank(),
    legend.background = element_blank(),
    legend.key        = element_blank(),
    legend.text = element_text(color = "white", size = 9),
    axis.text         = element_text(color = "white", size = 9),
    axis.title        = element_text(color = "white", size = 10),
    plot.title = element_text(color = "white", size = 14, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(color = "white", size = 10)
  ) +
  scale_legend_icon(size = 6) +
  labs(
    title    = "More Spending \u2260 Longer Lives",
    subtitle = "Health expenditure per capita vs. life expectancy  \u00b7  X-axis is log-scaled",
    x        = "Health Spending per Capita (log scale)",
    y        = "Life Expectancy (years)",
    color    = "Income Group"
  )
```

![](examples-geom-icon-point_files/figure-html/combined-1.png)

  

------------------------------------------------------------------------

## Example 6: Dark Theme Scatter

  

[`geom_icon_point()`](https://jurjoroa.github.io/ggpop/reference/geom_icon_point.md)
with
[`theme_pop_dark()`](https://jurjoroa.github.io/ggpop/reference/theme_pop_dark.md)
for a presentation-ready chart.

Show the code

``` r
library(ggpop)
library(ggplot2)
library(dplyr)

# Search the icons you want to use with fa_icons() and note their names:
fa_icons(query = "graduate")
fa_icons(query = "chalkboard")
fa_icons(query = "flask")

df_academic <- data.frame(
  name        = c("Alice", "Bob", "Carol", "Dan", "Eve",
                  "Prof. A", "Prof. B", "Prof. C",
                  "Dr. X", "Dr. Y", "Dr. Z"),
  study_hours = c(6, 4, 7, 3, 5, 8, 9, 7, 10, 12, 11),
  score       = c(78, 65, 88, 55, 72, 91, 95, 87, 98, 99, 96),
  role        = c(rep("Student", 5), rep("Teacher", 3), rep("Researcher", 3)),
  icon        = c(rep("user-graduate", 5), rep("chalkboard-user", 3), rep("flask", 3))
)

df_academic$role <- factor(df_academic$role,
  levels = c("Student", "Teacher", "Researcher"))

ggplot(df_academic, aes(x = study_hours, y = score,
                          icon = icon, color = role)) +
  geom_icon_point(size = 2, dpi = 100) +
  scale_color_manual(values = c(
    "Student"    = "#CE93D8",
    "Teacher"    = "#80DEEA",
    "Researcher" = "#FFCC80"
  )) +
  theme_pop_dark(bg_color = "#0D1B2A", text_color = "white") +
  theme(
    axis.text  = element_text(color = "#90A4AE"),
    axis.title = element_text(color = "#B0BEC5"),
    legend.title = element_text(color = "white", size = 10, face = "bold"),
  ) +
  scale_legend_icon(size = 6) +
  labs(
    title    = "Study Hours vs. Performance Score",
    subtitle = "Icon reflects academic role",
    x        = "Weekly Study Hours",
    y        = "Performance Score",
    color    = "Role"
  )
```

![](examples-geom-icon-point_files/figure-html/dark-theme-1.png)

  

------------------------------------------------------------------------

## `ggrepel` — The Green Energy Divide

  

[`geom_label_repel()`](https://ggrepel.slowkow.com/reference/geom_text_repel.html)
prevents country labels from overlapping, letting every data point speak
for itself even in dense clusters. Here 22 countries are plotted by
electricity consumption per capita versus renewable share. Without label
repulsion the European cluster — high renewables, moderate consumption —
would be illegible. Icon encodes the dominant energy source; color
encodes the continent.

Show the code

``` r
library(ggrepel)
library(ggtext)

# Search the icons you want to use with fa_icons() and note their names:
fa_icons(query = "droplet")
fa_icons(query = "wind")
fa_icons(query = "sun")

df_energy <- data.frame(
  country     = c("Iceland", "Norway", "Costa Rica", "New Zealand", "Brazil",
                  "Sweden", "Denmark", "Austria", "Canada", "Switzerland",
                  "Germany", "United Kingdom", "Spain", "France", "Australia",
                  "Japan", "United States", "Mexico", "China", "India",
                  "South Africa", "Egypt"),
  mwh_per_cap = c(52, 23,  2,  9,  3, 13,  6,  8, 15,  7,
                  6,  5,  6,  7, 10,  7, 13,  2,  5,  1,
                  4,  2),
  renewable   = c(99, 98, 99, 84, 83, 67, 80, 75, 67, 62,
                  46, 42, 54, 24, 29, 22, 20, 25, 28, 20,
                  8, 12),
  continent   = c("Europe", "Europe", "Americas", "Oceania", "Americas",
                  "Europe", "Europe", "Europe", "Americas", "Europe",
                  "Europe", "Europe", "Europe", "Europe", "Oceania",
                  "Asia", "Americas", "Americas", "Asia", "Asia",
                  "Africa", "Africa"),
  icon        = c("droplet", "droplet", "droplet", "droplet", "droplet",
                  "droplet", "wind", "droplet", "droplet", "droplet",
                  "wind", "wind", "wind", "atom", "sun",
                  "atom", "bolt", "bolt", "bolt", "sun",
                  "smog", "sun"),
  source_label = c("Hydro", "Hydro", "Hydro", "Hydro", "Hydro",
                   "Hydro", "Wind", "Hydro", "Hydro", "Hydro",
                   "Wind", "Wind", "Wind", "Nuclear", "Solar",
                   "Nuclear", "Mixed", "Mixed", "Mixed", "Solar",
                   "Coal", "Solar")
)

df_energy$continent    <- factor(df_energy$continent,
                                 levels = c("Europe", "Americas", "Asia", "Oceania", "Africa"))
df_energy$source_label <- factor(df_energy$source_label,
                                 levels = c("Hydro", "Wind", "Solar", "Nuclear", "Mixed", "Coal"))

pal_continent <- c(
  "Europe"   = "#5E8BFF",
  "Americas" = "#3ECF8E",
  "Asia"     = "#FF9F43",
  "Oceania"  = "#00D4C8",
  "Africa"   = "#FF6B9D"
)

pal_source <- c(
  "Hydro"   = "#5E8BFF",
  "Wind"    = "#00D4C8",
  "Solar"   = "#FFD93D",
  "Nuclear" = "#A78BFA",
  "Mixed"   = "#FF9F43",
  "Coal"    = "#FF6B6B"
)

bg <- "#0A0F1E"

set.seed(42)
ggplot(df_energy, aes(x = mwh_per_cap, y = renewable)) +
  # ── Quadrant shading ─────────────────────────────────────────────────────
  annotate("rect", xmin = -Inf, xmax = 13, ymin = 50,   ymax = Inf,
           fill = "#1A2F1A", alpha = 0.4) +
  annotate("rect", xmin = 13,  xmax = Inf, ymin = 50,   ymax = Inf,
           fill = "#2F2A10", alpha = 0.4) +
  annotate("rect", xmin = -Inf, xmax = 13, ymin = -Inf, ymax = 50,
           fill = "#1A1A2F", alpha = 0.3) +
  annotate("rect", xmin = 13,  xmax = Inf, ymin = -Inf, ymax = 50,
           fill = "#2F1010", alpha = 0.3) +
  # ── Quadrant labels ───────────────────────────────────────────────────────
  annotate("text", x = 0.5, y = 103, hjust = 0, size = 3, fontface = "bold",
           color = "#3ECF8E", label = "\u2600 GREEN & EFFICIENT") +
  annotate("text", x = 55,  y = 103, hjust = 1, size = 3, fontface = "bold",
           color = "#FF9F43", label = "HIGH USE, CLEAN \u26a1") +
  annotate("text", x = 0.5, y = 2,   hjust = 0, size = 3, fontface = "bold",
           color = "#78909C", label = "LOW USE, FOSSIL-HEAVY") +
  annotate("text", x = 55,  y = 2,   hjust = 1, size = 3, fontface = "bold",
           color = "#FF6B6B", label = "HIGH USE, FOSSIL-HEAVY \u26a0") +
  # ── Reference lines ───────────────────────────────────────────────────────
  geom_hline(yintercept = 50, linetype = "dashed", color = "#37474F", linewidth = 0.5) +
  geom_vline(xintercept = 13, linetype = "dashed", color = "#37474F", linewidth = 0.5) +
  # ── Continent fill circle (background) ───────────────────────────────────
  # ── Energy source icon (foreground) ──────────────────────────────────────
  geom_icon_point(aes(icon = icon, color = source_label), size = 1.8, dpi = 100) +
  # ── Country labels ────────────────────────────────────────────────────────
  geom_label_repel(
    aes(label = country, color = source_label),
    fill          = alpha(bg, 0.85),
    label.size    = 0,
    size          = 2.8,
    fontface      = "bold",
    label.padding = unit(0.22, "lines"),
    box.padding   = unit(0.5,  "lines"),
    point.padding = unit(0.4,  "lines"),
    max.overlaps  = Inf,
    segment.color = "#546E7A",
    segment.size  = 0.3,
    segment.alpha = 0.7,
    seed          = 42,
    show.legend   = FALSE
  ) +
  # ── Scales ────────────────────────────────────────────────────────────────
  scale_color_manual(
    name   = "Energy Source",
    values = pal_source
  ) +
  scale_fill_manual(
    name   = "Continent",
    values = pal_continent
  ) +
  scale_x_continuous(
    labels = function(x) paste0(x, " MWh"),
    expand = expansion(mult = c(0.02, 0.04))
  ) +
  scale_y_continuous(
    labels = function(y) paste0(y, "%"),
    limits = c(0, 106),
    expand = expansion(mult = c(0.01, 0))
  ) +
  scale_legend_icon(size = 6) +
  guides(
    color = guide_legend(
      nrow = 1, title.position = "top", title.hjust = 0.5,
      override.aes = list(size = 4)
    ),
    fill = guide_legend(
      nrow = 1, title.position = "top", title.hjust = 0.5,
      override.aes = list(alpha = 0.6, size = 5, color = NA)
    )
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.background   = element_rect(fill = bg, color = NA),
    panel.background  = element_rect(fill = bg, color = NA),
    panel.grid.major  = element_line(color = "#1C2A3A", linewidth = 0.4),
    panel.grid.minor  = element_blank(),
    legend.background = element_blank(),
    legend.key        = element_blank(),
    axis.text         = element_text(color = "#78909C", size = 10),
    axis.title        = element_text(color = "#90A4AE", size = 11),
    plot.title        = element_markdown(size = 22, face = "bold", hjust = 0.5,
                                         color = "white", margin = margin(b = 6)),
    plot.subtitle     = element_markdown(size = 11, hjust = 0.5, color = "#78909C",
                                         lineheight = 1.5, margin = margin(b = 16)),
    plot.caption      = element_text(size = 8.5, hjust = 0.5, color = "#546E7A",
                                     lineheight = 1.4, margin = margin(t = 14)),
    legend.position   = "bottom",
    legend.box        = "vertical",
    legend.title      = element_text(color = "#90A4AE", size = 10, face = "bold"),
    legend.text       = element_text(color = "#B0BEC5", size = 10),
    legend.margin     = margin(t = 4),
    legend.spacing.y  = unit(4, "pt"),
    plot.margin       = margin(20, 24, 16, 20)
  ) +
  labs(
    title    = "The Green Energy Divide",
    subtitle = "Renewable share (%) vs. electricity use per capita &nbsp;\u00b7&nbsp; <b style='color:#B0BEC5'>Icon = energy source</b> &nbsp;\u00b7&nbsp; <b style='color:#B0BEC5'>Glow = continent</b>",
    caption  = "Source: IEA / Our World in Data (2022)  \u00b7  Visualization: ggpop",
    x        = "Electricity Consumption per Capita (MWh)",
    y        = "Share of Renewables (%)"
  )
```

![](examples-geom-icon-point_files/figure-html/ggrepel-1.png)

  

------------------------------------------------------------------------

## `ggforce` — The Power Trade-Off

  

[`geom_mark_ellipse()`](https://ggforce.data-imaginist.com/reference/geom_mark_ellipse.html)
draws annotated convex-hull ellipses around groups of points, making
cluster structure immediately legible. Here 17 consumer electronics
devices are compared on battery life (log scale) versus performance
score. The ellipses label each category’s cluster with a short
description, while
[`geom_icon_point()`](https://jurjoroa.github.io/ggpop/reference/geom_icon_point.md)
encodes device type through icons — revealing how wearables dominate the
far right (days of uptime) at the cost of raw performance.

Show the code

``` r
library(ggforce)
library(ggtext)

# Search the icons you want to use with fa_icons() and note their names:
fa_icons(query = "mobile")
fa_icons(query = "laptop")
fa_icons(query = "clock")

set.seed(42)

v_bg <- "#0A0E1A"
v_colors <- c(
  "Smartphone" = "#4FC3F7",
  "Laptop"     = "#69F0AE",
  "Tablet"     = "#FFD740",
  "Wearable"   = "#FF80AB"
)

df_devices <- data.frame(
  device   = c(
    "iPhone 15 Pro", "Galaxy S24", "Pixel 8", "OnePlus 12", "Xiaomi 14",
    "MacBook Pro M3", "Dell XPS 15", "ThinkPad X1", "Surface Pro 9",
    "iPad Pro M4", "Samsung Tab S9", "Surface Go", "Amazon Fire",
    "Apple Watch Ultra", "Garmin Fenix 7", "Galaxy Watch 6", "Fitbit Sense 2"
  ),
  category = c(
    rep("Smartphone", 5),
    rep("Laptop", 4),
    rep("Tablet", 4),
    rep("Wearable", 4)
  ),
  battery  = c(
    28, 30, 26, 32, 35,
    18, 8, 14, 12,
    20, 18, 12, 14,
    60, 336, 48, 144
  ),
  perf     = c(
    92, 88, 82, 85, 80,
    95, 88, 80, 72,
    85, 78, 65, 52,
    68, 50, 62, 42
  ),
  icon     = c(
    rep("mobile", 5),
    rep("laptop", 4),
    rep("tablet", 4),
    rep("clock", 4)
  )
)

df_devices$category <- factor(
  df_devices$category,
  levels = c("Smartphone", "Laptop", "Tablet", "Wearable")
)

ggplot(df_devices, aes(x = battery, y = perf, color = category, icon = icon)) +
  geom_mark_ellipse(
    aes(
      label       = category,
      description = dplyr::case_when(
        category == "Smartphone" ~ "High power, moderate stamina",
        category == "Laptop"     ~ "Peak performance, short runtime",
        category == "Tablet"     ~ "Balanced versatility",
        TRUE                     ~ "Efficiency first — days of uptime"
      ),
      fill = category
    ),
    color          = NA,
    alpha          = 0.08,
    label.fill     = alpha(v_bg, 0.85),
    label.colour   = "#B0BEC5",
    label.fontsize = 9,
    con.colour     = "#546E7A",
    con.type       = "elbow",
    expand         = unit(6, "mm"),
    show.legend    = FALSE
  ) +
  geom_icon_point(size = 3, dpi = 100) +
  scale_x_log10(
    breaks = c(8, 12, 24, 48, 96, 168, 336),
    labels = c("8 h", "12 h", "1 day", "2 days", "4 days", "1 week", "2 weeks")
  ) +
  scale_color_manual(values = v_colors) +
  scale_fill_manual(values  = v_colors) +
  scale_legend_icon(size = 6) +
  coord_cartesian(clip = "off") +
  labs(
    title    = "The Power Trade-Off",
    subtitle = "Battery life vs. performance across consumer electronics categories",
    caption  = "Battery: manufacturer-rated hours \u00b7 Performance: composite benchmark score (0\u2013100)",
    x        = "Battery Life (hours, log scale)",
    y        = "Performance Score",
    color    = "Category"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.background   = element_rect(fill = v_bg, color = NA),
    panel.background  = element_rect(fill = v_bg, color = NA),
    panel.grid.major  = element_line(color = "#1C2A3A", linewidth = 0.4),
    panel.grid.minor  = element_blank(),
    legend.background = element_blank(),
    legend.key        = element_blank(),
    axis.text         = element_text(color = "#78909C", size = 10),
    axis.title        = element_text(color = "#90A4AE", size = 11),
    plot.title        = element_markdown(size = 22, face = "bold", hjust = 0.5,
                                         color = "white", margin = margin(b = 6)),
    plot.subtitle     = element_text(size = 11, hjust = 0.5, color = "#78909C",
                                     margin = margin(b = 16)),
    plot.caption      = element_text(size = 8.5, hjust = 0.5, color = "#546E7A",
                                     lineheight = 1.4, margin = margin(t = 14)),
    legend.position   = "bottom",
    legend.title      = element_text(color = "#90A4AE", size = 10, face = "bold"),
    legend.text       = element_text(color = "#B0BEC5", size = 10),
    plot.margin       = margin(20, 90, 20, 20)
  )
```

![](examples-geom-icon-point_files/figure-html/ggforce-1.png)

  

------------------------------------------------------------------------

## `gganimate` — A World Transformed

  

`transition_time()` animates the Gapminder classic — life expectancy
versus GDP per capita — across five decades.
[`geom_icon_point()`](https://jurjoroa.github.io/ggpop/reference/geom_icon_point.md)
encodes each region with a matching earth icon, so the continent story
is legible at a glance even as points race across the frame.

Show the code

``` r
library(ggrepel)
library(gganimate)
library(ggtext)

# Search the icons you want to use with fa_icons() and note their names:
fa_icons(query = "earth")

set.seed(42)

# ── Expand to yearly frames via interpolation ─────────────────────────────
v_years_key <- c(1970, 1980, 1990, 2000, 2010, 2020)
v_years_fine <- seq(1970, 2020, by = 1)

v_countries <- c(
  "Nigeria", "Ethiopia", "South Africa", "Kenya",
  "USA", "Brazil", "Mexico", "Chile",
  "Germany", "Spain", "Poland", "UK",
  "Japan", "China", "India", "South Korea"
)
v_continents <- c(
  rep("Africa",   4),
  rep("Americas", 4),
  rep("Europe",   4),
  rep("Asia",     4)
)
v_icons <- c(
  rep("earth-africa",   4),
  rep("earth-americas", 4),
  rep("earth-europe",   4),
  rep("earth-asia",     4)
)

v_life_exp <- c(
  45, 46, 45, 46, 52, 55,
  42, 43, 45, 50, 62, 67,
  53, 58, 61, 55, 56, 64,
  50, 56, 58, 52, 60, 66,
  71, 74, 75, 77, 79, 79,
  59, 63, 66, 70, 73, 76,
  62, 67, 70, 74, 75, 76,
  63, 68, 73, 77, 79, 80,
  71, 73, 75, 78, 80, 81,
  72, 76, 77, 79, 82, 83,
  70, 71, 71, 74, 76, 78,
  72, 74, 76, 78, 81, 81,
  72, 76, 79, 81, 83, 84,
  61, 67, 69, 71, 75, 77,
  49, 54, 59, 63, 67, 70,
  62, 66, 71, 76, 80, 83
)

v_gdp <- c(
  1100, 1500, 1300, 1100,  2100,  2000,
  200,  150,  180,  600,  1400,  2200,
  3500, 5000, 5200, 5000,  8000,  6000,
  1000, 1400, 1600, 1500,  1800,  4500,
  23000, 28000, 36000, 45000, 48000, 55000,
  4000,  8000,  8000,  9000, 14000, 14000,
  6000,  9000,  9000, 10000, 13000, 10000,
  4000,  5000,  8000, 12000, 15000, 13000,
  18000, 24000, 30000, 36000, 40000, 45000,
  9000, 15000, 20000, 26000, 30000, 28000,
  5000,  7000,  6000, 11000, 20000, 32000,
  15000, 19000, 24000, 32000, 36000, 40000,
  10000, 18000, 28000, 35000, 38000, 40000,
  400,   700,  1000,  3000,  9000, 17000,
  600,   800,  1200,  1700,  3500,  6000,
  2000,  5000, 10000, 17000, 24000, 31000
)

# ── Build keyframe df ─────────────────────────────────────────────────────
df_key <- data.frame(
  country   = rep(v_countries, each = length(v_years_key)),
  year      = rep(v_years_key, times = length(v_countries)),
  continent = rep(v_continents, each = length(v_years_key)),
  icon      = rep(v_icons, each = length(v_years_key)),
  life_exp  = v_life_exp,
  gdp_pc    = v_gdp
)

# ── Interpolate each country to yearly resolution ─────────────────────────
df_world <- df_key %>%
  group_by(country, continent, icon) %>%
  reframe(
    year     = v_years_fine,
    life_exp = approx(v_years_key, life_exp, xout = v_years_fine)$y,
    gdp_pc   = approx(v_years_key, gdp_pc,   xout = v_years_fine)$y
  )

v_bg <- "#0A0E1A"
v_colors <- c(
  "Africa"   = "#FF80AB",
  "Americas" = "#69F0AE",
  "Europe"   = "#4FC3F7",
  "Asia"     = "#FFD740"
)

p_anim <- ggplot(df_world,
                 aes(x = gdp_pc, y = life_exp,
                     color = continent, icon = icon)) +
  geom_icon_point(size = 2.5, dpi = 100) +
  geom_text_repel(
    aes(label = country, color = continent),
    size          = 2.8,
    fontface      = "bold",
    box.padding   = unit(0.4, "lines"),
    point.padding = unit(0.3, "lines"),
    max.overlaps  = Inf,
    segment.color = "#546E7A",
    segment.size  = 0.3,
    segment.alpha = 0.6,
    seed          = 42,
    show.legend   = FALSE
  ) +
  scale_x_log10(
    breaks = c(500, 1000, 5000, 10000, 50000),
    labels = c("$500", "$1K", "$5K", "$10K", "$50K")
  ) +
  scale_color_manual(values = v_colors) +
  scale_legend_icon(size = 6) +
  labs(
    title    = "A World Transformed",
    subtitle = "Life expectancy vs. GDP per capita  \u00b7  Year: {round(frame_time)}",
    caption  = "Source: World Bank / Gapminder  \u00b7  Visualization: ggpop",
    x        = "GDP per Capita (USD, log scale)",
    y        = "Life Expectancy (years)",
    color    = "Region"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.background   = element_rect(fill = v_bg, color = NA),
    panel.background  = element_rect(fill = v_bg, color = NA),
    panel.grid.major  = element_line(color = "#1C2A3A", linewidth = 0.4),
    panel.grid.minor  = element_blank(),
    legend.background = element_blank(),
    legend.key        = element_blank(),
    axis.text         = element_text(color = "#78909C", size = 10),
    axis.title        = element_text(color = "#90A4AE", size = 11),
    plot.title        = element_markdown(size = 22, face = "bold", hjust = 0.5,
                                         color = "white", margin = margin(b = 6)),
    plot.subtitle     = element_text(size = 11, hjust = 0.5, color = "#78909C",
                                     margin = margin(b = 16)),
    plot.caption      = element_text(size = 8.5, hjust = 0.5, color = "#546E7A",
                                     lineheight = 1.4, margin = margin(t = 14)),
    legend.position   = "bottom",
    legend.title      = element_text(color = "#90A4AE", size = 10, face = "bold"),
    legend.text       = element_text(color = "#B0BEC5", size = 10),
    plot.margin       = margin(20, 24, 16, 20)
  ) +
  transition_time(year) +
  ease_aes("cubic-in-out")

animate(
  p_anim,
  nframes   = 150,   # ~3 frames per year across 51 years
  fps       = 12,
  width     = 1000,
  height    = 650,
  res       = 120,
  renderer  = gifski_renderer("world_transformed.gif")
)
```

![](https://raw.githubusercontent.com/jurjoroa/ggpopdata/main/inst/figures/world_transformed.gif)

Example gganimate animation
