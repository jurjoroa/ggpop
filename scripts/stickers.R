install.packages("hexSticker")


library(hexSticker)

#create a dataframe with 11 groups. bike, build, car, dollar, female, graduation_cap, handicap, male, money, syringe, tree

df_hexastickers <- data.frame(
  icon = c("bike",
            "female", "graduation_cap", "male",
            "money", "syringe",
            "tree"),
  number = c(1, 4,1, 5, 1, 1, 1))

df_hexa <- process_data(data = df_hexastickers, group_var = icon, sum_var=number, sample_size = 100)

df_hexa <- df_hexa %>% mutate(icon = type)

#idea: # Example usage:
p <- ggplot() +
  geom_pop(data = df_hexa, aes(icon = icon, group=type, color=type),
           size = 3, arrange = F) + 
  #facet_wrap(~type) +
  #erase the legend
  theme_void() +
  theme(legend.position = "none") +
  scale_color_manual(values = palette)


                       
c( "#003f5c", "#d9042b",  "#730220",  "#03658c",  "#f29f05",  "#f27b50", "#007f4e")

# Define the muted contrasting color palette with diverse hues
# Example of slight adjustments
# Example of named palette
palette <- c(
  "#FF7F50", # Coral
  "#FFDAB9", # Peach Puff
  "#98FB98", # Pale Green
  "#4682B4", # Steel Blue
  "#6A5ACD", # Slate Blue
  "#FF4500", # Orange Red
  "#FFB6C1"  # Light Pink
)








# Accessing a specific color
earthy_contrast_palette_named["Olive_Green"]


# Print the palette
print(muted_contrast_palette_diverse)

# Print the palette
print(muted_contrast_palette)


# Print the alternative palette
print(alternative_contrast_palette2)


# Print the alternative palette
print(alternative_contrast_palette)

s <- sticker(p,package="ggpop", p_size=25, s_x=1, s_y=.78, s_width=1.3, s_height=1.3, p_x=1, p_y=1.68,
             h_fill="#03658c", h_color="#059bd7", p_color="white", h_size=.8, 
             
             filename="inst/figures/baseplot.png")

s

?sticker()

