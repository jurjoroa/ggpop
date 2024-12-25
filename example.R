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
  mutate(icon = ifelse(type =="CRC", "bike", "male"))

df_crc_prop$icon <- "male"

df_iris_prop <- df_iris_prop %>% 
  mutate(icon = case_when(
    type == "setosa" ~ "handicap",
    type == "versicolor" ~ "syringe",
    type == "virginica" ~ "build"
  ))


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

#idea: # Example usage:
ggplot() +
  geom_pop(data = df_iris_prop, aes(icon = icon, group=type, color=type),
           size = 1.3, arrange = F) +
  theme_void() +
  caption_pop(size_caption = 10, size_image = 15) +
  theme(legend.position = "none")

ggsave("example_plot6.png", width = 5, height = 5)

df_crc_prop$icon <- "tree"

#idea: # Example usage:
ggplot() +
  geom_pop(data = df_crc_prop, aes(icon = icon, group=type, color=type),
           size = .9, arrange = F) +
  theme_void()
  caption_pop(size_caption = 10, size_image = 15, text=c("male"="Cada representa personas discapacitada",
                                                         "bike"="Syringe represents medical personnel",
                                                         "build"="Build represents construction workers")) +
  theme(legend.position = "none")

ggsave("example_plot7.png", width = 5, height = 5)

