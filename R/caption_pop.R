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

caption_pop <- function(size_caption = 3, size_image = 20, hjust = 0.6, text = NULL) {
  
  #--- Ensure `data` exists ---
  if (is.null(data)) {
    stop("Data must be provided to generate captions.")
  }
  
  #--- Get the last plot and its data ---
  last_plot <- ggplot2::last_plot()
  data <- last_plot$layers[[1]]$data
  
  #--- Compute counts (ceiling of sum / number of rows) ---
  first_group <- ceiling(sum(data$n[1], na.rm = TRUE) / nrow(data))
  second_group <- ceiling(sum(data$n[2], na.rm = TRUE) / nrow(data))
  third_group <- ceiling(sum(data$n[3], na.rm = TRUE) / nrow(data))
  
  # Helper function to get text description for an image
  get_text <- function(image) {
    if (!is.null(text) && image %in% names(text)) {
      return(text[[image]])
    }
    return("persons") # Default fallback
  }
  
  # Helper function to split and process text
  process_text <- function(image) {
    words <- unlist(strsplit(get_text(image), " "))
    if (length(words) > 2) {
      c(words[1], words[2], paste(words[3:length(words)], collapse = " "))
    } else {
      c(words, "")
    }
  }
  
  # Generate caption based on available images
  if (!is.na(data$image[1]) && !is.na(data$image[2]) && !is.na(data$image[3])) {
    caption_text <- paste(
      process_text(data$image[1])[1],
      paste0("<img src='man/figures/", data$image[1], ".png' width='", size_image, "'/>"),
      process_text(data$image[1])[2],
      first_group,
      process_text(data$image[1])[3],
      "<br>",
      process_text(data$image[2])[1],
      paste0("<img src='man/figures/", data$image[2], ".png' width='", size_image, "'/>"),
      process_text(data$image[2])[2],
      second_group,
      process_text(data$image[2])[3],
      "<br>",
      process_text(data$image[3])[1],
      paste0("<img src='man/figures/", data$image[3], ".png' width='", size_image, "'/>"),
      process_text(data$image[3])[2],
      third_group,
      process_text(data$image[3])[3]
    )
  } else if (!is.na(data$image[1]) && !is.na(data$image[2])) {
    caption_text <- paste(
      process_text(data$image[1])[1],
      paste0("<img src='man/figures/", data$image[1], ".png' width='", size_image, "'/>"),
      process_text(data$image[1])[2],
      first_group,
      process_text(data$image[1])[3],
      "<br>",
      process_text(data$image[2])[1],
      paste0("<img src='man/figures/", data$image[2], ".png' width='", size_image, "'/>"),
      process_text(data$image[2])[2],
      second_group,
      process_text(data$image[2])[3]
    )
  } else if (!is.na(data$image[1])) {
    caption_text <- paste(
      process_text(data$image[1])[1],
      paste0("<img src='man/figures/", data$image[1], ".png' width='", size_image, "'/>"),
      process_text(data$image[1])[2],
      first_group + second_group,
      process_text(data$image[1])[3]
    )
  } else if (!is.na(data$image[2])) {
    caption_text <- paste(
      process_text(data$image[2])[1],
      paste0("<img src='man/figures/", data$image[2], ".png' width='", size_image, "'/>"),
      process_text(data$image[2])[2],
      second_group,
      process_text(data$image[2])[3]
    )
  } else {
    stop("No valid images found.")
  }
  
  #--- Return a list of ggplot2 commands to modify your plot ---
  list(
    labs(caption = caption_text),
    theme(plot.caption = ggtext::element_markdown(size = size_caption, hjust = hjust))
  )
}




df_iris <- iris

df_iris_prop <- process_data(data = df_iris, group_var = Species, sample_size = 500)

df_proportion <- df_iris %>%
  group_by(Species) %>%
  summarise(
    n = n() ) %>%
  mutate(prop = n / sum(n))


df_crc_prop <- df_crc_prop %>% 
  mutate(icon = ifelse(type =="CRC", "handicap", "male"))

df_crc_prop$icon <- "male"

df_iris_prop <- df_iris_prop %>% 
  mutate(icon = case_when(
    type == "setosa" ~ "handicap",
    type == "versicolor" ~ "syringe",
    type == "virginica" ~ "build"
  ))

#idea: # Example usage:
ggplot() +
  geom_pop(data = df_iris_prop, aes(icon = icon, group=type, color=type),
           size = 1.3, arrange = F) +
  theme_void() +
  caption_pop(size_caption = 10, size_image = 15) +
  theme(legend.position = "none")

ggsave("example_plot5.png", width = 5, height = 5)


#idea: # Example usage:
ggplot() +
  geom_pop(data = df_iris_prop, aes(icon = icon, group=type, color=type),
           size = 1.3, arrange = F) +
  theme_void() +
  caption_pop(size_caption = 10, size_image = 15, text=c("handicap"="Cada representa personas discapacitadas",
                                                         "syringe"="Syringe represents medical personnel",
                                                         "build"="Build represents construction workers")) +
  theme(legend.position = "none")
