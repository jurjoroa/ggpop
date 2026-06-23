# Animated Markov Cohort (Sick-Sicker)

This example shows how to combine a cohort Markov model with `ggpop` and
`gganimate`.

The Sick-Sicker model is a common health economics model structure that
simulates disease progression across multiple health states. In this
example, we simulate a cohort of individuals starting at age 40 and
track their transitions through the states of `Healthy`, `Sick`,
`Sicker`, and `Death` until age 100. We then visualize the changing
distribution of the cohort across these states over time using an
animated population plot.

We simulate a **Sick-Sicker** model from age **40** to **100** across
four states: `Healthy`, `Sick`, `Sicker`, and `Death`.

Show the code

``` r

# #* Load package functions
devtools::load_all(".")
library(ggpop)
library(ggplot2)
library(dplyr)
library(tidyr)
library(gganimate)

# -------------------------------
# 1) Cohort Markov model inputs
# -------------------------------
states <- c("Healthy", "Sick", "Sicker", "Death")
age_start <- 40
age_end <- 100
n_cycles <- age_end - age_start

# Transition probability matrix (rows = current state, cols = next state)
# Healthy -> Healthy/Sick/Sicker/Death
# Sick    -> Healthy/Sick/Sicker/Death
# Sicker  -> Healthy/Sick/Sicker/Death
# Death   -> Death (absorbing)
m_P <- matrix(
  c(
    0.85, 0.12, 0.02, 0.01,
    0.08, 0.85, 0.05, 0.02,
    0.00, 0.00, 0.95, 0.05,
    0.00, 0.00, 0.00, 1.00
  ),
  nrow = length(states),
  byrow = TRUE,
  dimnames = list(states, states)
)

stopifnot(all(abs(rowSums(m_P) - 1) < 1e-10))

# ---------------------------------
# 2) Cohort trace from age 40 to 100
# ---------------------------------
m_trace <- matrix(
  0,
  nrow = n_cycles + 1,
  ncol = length(states),
  dimnames = list(cycle = 0:n_cycles, state = states)
)

# Initial cohort distribution at age 40
m_trace[1, ] <- c(1, 0, 0, 0)

for (t in seq_len(n_cycles)) {
  m_trace[t + 1, ] <- m_trace[t, ] %*% m_P
}

# Long-format cohort proportions by age
cohort_long <- as.data.frame(m_trace) %>%
  mutate(cycle = 0:n_cycles,
         age = age_start + cycle) %>%
  pivot_longer(
    cols = all_of(states),
    names_to = "state",
    values_to = "prop"
  )

# ------------------------------------------------------
# 3) Convert each cycle's proportions to icon-level data
# ------------------------------------------------------
# process_data() samples icons within each age (high_group_var = "age")
# sample_size = 400 means each icon is ~0.25% of the cohort in each frame
set.seed(2026)
df_icons <- process_data(
  data = cohort_long,
  high_group_var = "age",
  group_var = state,
  sum_var = prop,
  sample_size = 400
) %>%
  mutate(
    age = as.integer(group),
    state = factor(type, levels = states),
    icon = case_when(
      state == "Healthy" ~ "person-walking",
      state == "Sick" ~ "person-cane",
      state == "Sicker" ~ "wheelchair",
      state == "Death" ~ "skull-crossbones"
    )
  )

# --------------------
# 4) Animated ggpop plot
# --------------------
p_anim <- ggplot(df_icons, aes(icon = icon, color = state)) +
  geom_pop(
    size = 1.1,
    arrange = TRUE,
    legend_icons = TRUE,
    seed = 2026,
    dpi = 100
  ) +
  scale_color_manual(
    values = c(
      "Healthy" = "#2E7D32",
      "Sick" = "#F9A825",
      "Sicker" = "#E64A19",
      "Death" = "#6D4C41"
    )
  ) +
  scale_legend_icon(size = 8) +
  theme_pop(base_size = 16) +
  theme(
    legend.position = "bottom",
    legend.title = element_blank(),
    plot.title = element_text(color = "black", face = "bold", hjust = 0.5),
    plot.subtitle = element_text(color = "black", hjust = 0.5),
    plot.caption = element_text(color = "black")
  ) +
  labs(
    title = "Sick-Sicker Cohort Markov Model \u00b7 Age: {closest_state} years",
    subtitle = "Cohort simulated from age 40 to 100",
    caption = "Cohort starts Healthy at age 40. Each icon is ~0.25% of the cohort."
  ) +
  transition_states(
    states = age,
    transition_length = 1,
    state_length = 1,
    wrap = FALSE
  ) +
  ease_aes("linear")

anim <- animate(
  p_anim,
  nframes = length(unique(df_icons$age)) * 1,
  fps = 2,
  width = 900,
  height = 900
)

anim

# Optional: save the animation
#anim_save("sick_sicker_animation.gif", anim)
```
