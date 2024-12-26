install.packages("hexSticker")


library(hexSticker)

library(wesanderson)

d <- wes_palette("Zissou1", 7, type = "continuous")


d

#create a dataframe with 11 groups. bike, build, car, dollar, female, graduation_cap, handicap, male, money, syringe, tree

df_hexastickers <- data.frame(
  icon = c("bike",
            "female", "graduation_cap", "male",
            "money", "syringe",
            "tree"),
  number = c(1, 4,1, 5, 1, 1, 1))

df_hexa <- process_data(data = df_hexastickers, group_var = icon, sum_var=number, sample_size = 100)

df_hexa <- df_hexa %>% mutate(icon = type)


df_hexa_pos <- full_join(df_hexa, df_coordinates_final %>% filter(size==100), by = "pos")

df_colors <- data.frame(
  pos = 1:14, 
first_color = c(58,70,81,87,93,96,97,100,71,78,86,91,43,51),
second_color= c(59,66,74,82,89,94,99,98,92,85,79,72,63,55),
third_color = c(47,39,31,19,28,35,44,52,60,67,75,83,90,95),
fourth_color= c(88,80,73,64,56,48,40,32,24,11,6,14,21,29),
fifth_color = c(36,45,54,62,69,77,84,76,68,61,50,42,33,25),
sixth_color = c(17,10,6,3,9,16,22,30,38,49,57,65,53,46,37),
seventh_color = c(27,20,13,7,2,1,4,12,18,26,34,41,23,15,8,5,4))


# Create the data with consistent lengths by padding shorter columns with NA
df_colors <- data.frame(
  pos = 1:18,  # Length of the longest column
  first_color = c(58, 70, 81, 87, 93, 96, 97, 100, 71, 78, 86, 91, 43, 51, NA, NA, NA, NA),
  second_color = c(59, 66, 74, 82, 89, 94, 99, 98, 92, 85, 79, 72, 63, 55, NA, NA, NA, NA),
  third_color = c(47, 39, 31, 19, 28, 35, 44, 52, 60, 67, 75, 83, 90, 95, NA, NA, NA, NA),
  fourth_color = c(88, 80, 73, 64, 56, 48, 40, 32, 24, 11, 14, 21, 29, 36, NA, NA, NA, NA),
  fifth_color = c(45, 54, 62, 69, 77, 84, 76, 68, 61, 50, 42, 33, NA, NA, NA, NA, NA, NA),
  sixth_color = c(25, 17, 10, 6, 3, 9, 16, 22, 30, 38, 49, 57, 65, 53, 46, 37, NA, NA),
  seventh_color = c(27, 20, 13, 7, 2, 1, 4, 12, 18, 26, 34, 41, 23, 15, 8, 5, NA, NA)
)

# Convert to long format
df_colors_long <- df_colors %>%
  tidyr::pivot_longer(
    cols = starts_with("first_color"):starts_with("seventh_color"),
    names_to = "color_type",
    values_to = "posi"
  ) %>% select(-pos)

df_colors_long <- df_colors_long %>% 
  rename(pos = posi) %>%
  mutate(color_f=case_when(
    color_type == "first_color" ~ "#3A9AB2",
    color_type == "second_color" ~ "#85B7B9",
    color_type == "third_color" ~ "#ADC397",
    color_type == "fourth_color" ~ "#DCCB4E",
    color_type == "fifth_color" ~ "#E5A208",
    color_type == "sixth_color" ~ "#ED6E04",
    color_type == "seventh_color" ~ "#f12f00"
  )) %>%
  filter(!is.na(pos)) %>% 
 #drop repeated values
  distinct(pos, color_f)


#ggplot(data = df_hexa_pos) +
#  geom_text(aes(x = x1, y = y1, label = pos), size = 10)

df_hexa_final <- full_join(df_hexa, df_colors_long, by = "pos")

#change icon syringe for handicap

df_hexa_final$icon <- case_when(
  df_hexa_final$icon == "syringe" ~ "handicap",
  TRUE ~ df_hexa_final$icon
)

#idea: # Example usage:
p <- ggplot() +
  geom_pop(data = df_hexa_final, aes(icon = icon, group=type, color=color_f),
           size = 3, arrange = F) + 
  scale_color_identity() + 
  #facet_wrap(~type) +
  #erase the legend
  theme_void() +
  theme(legend.position = "none")

library(showtext)
## Loading Google fonts (http://www.google.com/fonts)
font_add_google("Anton", "anton")
font_add_google("Playwright MX Guides", "playwright_mx_guides")
font_add_google("Archivo Black", "archivo_black")
font_add_google("Montserrat", "montserrat")
#Lato
font_add_google("Lato", "lato")
#Oswald
font_add_google("Oswald", "oswald")
#Raleway
font_add_google("Raleway", "raleway")

## Automatically use showtext to render text for future devices
showtext_auto()

s <- sticker(p,package="ggpop", p_size=25, s_x=1, s_y=.78, s_width=1.3, s_height=1.3, p_x=1, p_y=1.64,
             h_fill="#025373", h_color="#038abe", p_color="white", h_size=.5, 
             p_family = "raleway",
             filename="inst/figures/baseplot.png")

s

?sticker()

