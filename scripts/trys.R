

arrange_data <- function(data, group_var, sum_var = NULL, sample_size = NULL, arrange = NULL) {
  df_proportion <- data %>%
    group_by({{ group_var }}) %>%
    summarise(
      n = if (is.null({{ sum_var}}))
        n() else sum({{ sum_var }})
    ) %>%
    mutate(prop = n / sum(n))
  
  df_coordinates <- df_coordinates_final %>% 
    filter(size == sample_size)
  
  df_sample <- sample(c(df_proportion %>% pull({{ group_var }})), sample_size, replace = TRUE,  prob=c(df_prop$prop[1], 1-df_prop$prop[1]))
  
  df_coor_dots <- bind_cols(df_coordinates, tibble(type = df_sample))
  
  return(df_coor_dots)
}

df_crc_prop <- arrange_data(data = df_crc, group_var = CauseOfDeath, sample_size = 1000)

df_crc_prop_f <- df_crc_prop %>% 
  mutate(icon = ifelse(type == "OTHER", "male", "female"))

# Step 2: Dynamically append the folder path and file extension inside ggplot
ggplot(df_crc_prop_f) +
  geom_image(aes(x = x1, y = y1, image = paste0("man/figures/", icon, ".svg"), color = type), 
             size = 0.03, alpha = 0.5) +
  theme_void()


ggplot(df_crc_prop) +
  geom_image(aes(x=x1, y=y1, fill = type, color=type,  image = ifelse(type == "OTHER", "man/figures/male.svg", "man/figures/female.svg")),
             size = 0.03, alpha=.5) +
  theme_void() +
  #legen to the bottom
  theme(legend.position = "bottom")