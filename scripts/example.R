# *****************************************************************************
#
# Script: example.R
#
# Purpose: Example to show how to use the geom_pop function
#
# Author: Jorge Roa
#
# Email: jorgeroa@stanford.edu
#
#
# *****************************************************************************
#
# Notes:
#   
#
# *****************************************************************************

# *****************************************************************************
# *****************************************************************************

remove(list = ls())

path <- "figs/"

#* Refresh environment memory
gc()

# *****************************************************************************
#### Load packages ####
# *****************************************************************************

# Load Libraries -------------------------------------------------------

library(ggplot2) # load the library 
library(ggimage)
library(ggforce)
library(dplyr)


source("R/geom_pop.R")
source("R/arrange_data.R")

# *****************************************************************************
#### Load data ####

load("data/df_coordinates_final.RData")

df_crc <- read.csv2("data-raw/2024_09_06_COL_458510_CaDxAndDeathData.csv", sep = ",")


df_order <- df_crc_prop %>% select(group, n , prop)


df_crc_2 <- df_crc_prop %>%
  mutate(original_order = row_number()) %>%
  arrange(type, original_order) %>%
  mutate(pos = row_number()) %>%
  select(-original_order, -group, -n , -prop)


df_crc_2 <- bind_cols(df_crc_2, df_order)

df_proportion_crc_2 <- df_crc %>%
  mutate(CauseOfDeath := as.character(CauseOfDeath)) %>%
  group_by(CauseOfDeath) %>%
  summarise(
    n = n())%>%
  mutate(prop = n / sum(n))

#get proportion of crc_cases CauseOfDeath from the data (N)

#group by CauseOfDeath and get the count of each group

df_prop <- df_crc %>% 
  group_by(CauseOfDeath) %>% 
  summarise(n = n()) %>% 
  mutate(prop = n / sum(n))


df_iris <- iris

df_iris_prop <- process_data(data = df_iris, group_var = Species, sample_size = 1000)

df_proportion <- df_iris %>%
  group_by(Species) %>%
  summarise(
    n = n() ) %>%
  mutate(prop = n / sum(n))

df_crc_prop <- process_data(data = df_crc, group_var = CauseOfDeath, sample_size = 1000)


df_crc_prop <- df_crc_prop %>% 
  mutate(icon = ifelse(type =="CRC", "male", "bike"))

df_crc_prop$icon <- "male"

df_iris_prop <- df_iris_prop %>% 
  mutate(icon = case_when(
    type == "setosa" ~ "tree",
    type == "versicolor" ~ "bike",
    type == "virginica" ~ "money"
  ))


# Example usage:
ggplot() +
  geom_pop(data = df_crc_prop, aes(icon = icon, group=type, color=type),
           size = 1.3, arrange = F)
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

#idea: # Example usage:
ggplot() +
  geom_pop(data = df_iris_prop, aes(icon = icon, group=type, color=type),
           size = 1.3, arrange = T) +
  theme_void() +
  caption_pop(size_caption = 10, size_image = 15) +
  theme(legend.position = "none")

ggsave("example_plot6.png", width = 5, height = 5)



df_crc_prop <- process_data(data = df_crc, group_var = CauseOfDeath, sample_size = 100)

df_crc_prop <- df_crc_prop %>% 
  mutate(icon = ifelse(type =="CRC", "male", "bike"))


df_crc_prop$icon <- "male"



#idea: # Example usage:
  ggplot() +
  geom_pop(data = df_iris_prop, aes(icon = icon, group=type, color=type),
           size = 1, arrange = T) + 
  #facet_wrap(~type) +
  #erase the legend
  theme_void() +
  theme(legend.position = "none") +
  caption_pop(caption_size = 1, icon_size = 1, hjust = .5, text=c("tree"="Cada representa personas discapacitada",
                                                         "money"="Syringe represents medical personnel",
                                                         "bike"="Build represents construction workers")) +
  theme(legend.position = "none")

ggsave("example_plot10.png", width = 5, height = 5)



df_arrests <- USArrests

#move states to column

df_arrests$state <- rownames(df_arrests)

#keep California, Arizona, Nevada, Oregon

df_arrests <- df_arrests %>% 
  filter(state %in% c("California", "Arizona", "Nevada", "Oregon"))

df_arrests_prop <- process_data(data = df_arrests, group_var = state, sum_var = Assault, sample_size = 1000)

df_arrests_prop <- df_arrests_prop %>% 
  mutate(icon = case_when(
    type == "California" ~ "tree",
    type == "Arizona" ~ "bike",
    type == "Nevada" ~ "money",
    type == "Oregon" ~ "male"))

# Example usage:

ggplot() +
  geom_pop(data = df_arrests_prop, aes(icon = icon, group=type, color=type),
           size = 1, arrange = F) +
  theme_void() +
  caption_pop(caption_size = 1, icon_size = 1, text=c("tree"="Every represents persons",
                                                      "money"="Every represents persons",
                                                      "bike"="Every represents persons",
                                                      "male"="Every represents persons")) +
  theme(legend.position = "none")

ggsave("example_plot11.png", width = 5, height = 5)
