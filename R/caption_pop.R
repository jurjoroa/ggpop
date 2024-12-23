df_crc_prop <- process_data(data = df_crc, group_var = CauseOfDeath, sample_size = 500)

df_crc_prop <- df_crc_prop %>% 
  mutate(icon = ifelse(type == "OTHER", "male", "female"))

df_crc_prop$icon2 <- "dollar"


library(dplyr)
library(ggplot2)
options(ggimage.keytype = "image")


syringe.svg

df_crc_prop$icon2 <- "male"

df_crc_prop <- process_data(data = df_crc, group_var = CauseOfDeath, sample_size = 1000)


library(ggtext)
lib

df_crc_prop$icon2 <- "male"

# Example usage:
ggplot() +
  geom_pop(data = df_crc_prop, aes(icon = icon2, group=type, color=type),
           size = 1.3, arrange = F) +
  theme(legend.position = "bottom") +
  theme_void() +
  labs(
    caption = paste(
      "Every",
      "<img src='man/figures/male.png' width='20'/>",
      "represents", 
      ceiling(sum(df_crc_prop$n[1],  na.rm = T)/nrow(df_crc_prop)),
      "persons",
      "<br>",
      "Every",
      "<img src='man/figures/female.png' width='20'/>",
      "represents", 
      ceiling(sum(df_crc_prop$n[2],  na.rm = T)/nrow(df_crc_prop)),
      "persons"
    )
  ) +  theme(plot.caption = element_markdown(hjust = .6))

ggsave("example_plot3.png", width = 5, height = 5)

sum(, na.rm = T)
#idea: # Example usage:
ggplot() +
  geom_pop(data = df_crc_prop, aes(icon = icon2, group=type, color=type),
           size = 1.3, arrange = F) +
  theme(legend.position = "bottom") +
  theme_void() +
  labs(
    caption = paste(
      "Every",
      paste0("<img src='", icon2[first_entry], ".png' width='20'/>"),
      "represents", 
      ceiling(sum(df_prop$n[first_entry])/sample_size),
      "persons"
      #If there is a third entry, add it and so on
    )
  ) +  theme(plot.caption = element_markdown(hjust = .6))


caption_pop <- function(data, size_caption = 3) {
  if (is.null(data)) {
    stop("Data must be provided to generate captions.")
  }
  
  # Use the first and second rows' values for the caption, assuming the structure
  male_count <- ceiling(sum(data$n[1], na.rm = TRUE) / nrow(data))
  female_count <- ceiling(sum(data$n[2], na.rm = TRUE) / nrow(data))
  
  caption_text <- paste(
    "Every",
    "<img src='man/figures/male.png' width='20'/>",
    "represents", 
    male_count, 
    "persons",
    "<br>",
    "Every",
    "<img src='man/figures/female.png' width='20'/>",
    "represents", 
    female_count,
    "persons"
  )
  
  # Return labs with the dynamically created caption
  labs(caption = caption_text) +
    theme(
      plot.caption = ggtext::element_markdown(size = size_caption, hjust = 0.6)
    )
}

caption_pop <- function(size_caption = 3) {
  if (is.null(data)) {
    stop("Data must be provided to generate captions.")
  }
  
  last_plot <- ggplot2::last_plot()
  
  # Extract data from the ggplot layers
  data <- last_plot$layers[[1]]$data
  
  
  male_count <- ceiling(sum(data$n[1], na.rm = TRUE) / nrow(data))
  female_count <- ceiling(sum(data$n[2], na.rm = TRUE) / nrow(data))
  
  caption_text <- paste(
    "Every",
    "<img src='man/figures/male.png' width='20'/>",
    "represents", 
    male_count, 
    "persons",
    "<br>",
    "Every",
    "<img src='man/figures/female.png' width='20'/>",
    "represents", 
    female_count,
    "persons"
  )
  
  list(
    labs(caption = caption_text),
    theme(plot.caption = ggtext::element_markdown(size = size_caption, hjust = 0.6))
  )
}







#idea: # Example usage:
ggplot() +
  geom_pop(data = df_crc_prop, aes(icon = icon2, group=type, color=type),
           size = 1.3, arrange = F) +
  theme_void() +
  caption_pop(size_caption = 10)
