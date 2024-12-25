# *****************************************************************************
#
# Script: order_images.R
#
# Purpose: Example for ordering images in a ggplot2 plot
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

# *****************************************************************************
#### Load data ####

df_crc <- read.csv2("2024_09_06_COL_458510_CaDxAndDeathData.csv", sep = ",")

#get proportion of crc_cases CauseOfDeath from the data (N)

#group by CauseOfDeath and get the count of each group

df_prop <- df_crc %>% 
  group_by(CauseOfDeath) %>% 
  summarise(n = n()) %>% 
  mutate(prop = n / sum(n))


# Create proportion of CRC cases
df_crc_cases <- sample(c("CRC", "OTHER"), 1000, replace = TRUE, prob=c(df_prop$prop[1], 1-df_prop$prop[1]))

# load coordinates. df_coordinates_final

load("df_coordinates_final.Rdata")



df_coor_1000 <- df_coordinates_final %>% 
  filter(size == 1000)


#merge the migrants and coordinates data frames 

df_coor_dots <- df_coor_1000 %>% 
  mutate(type = df_crc_cases) %>% 
  #order by type
  arrange(type)

vector_order <- df_coor_dots$type

#order vector

df_coor_dots <- df_coor_dots[order(df_coor_dots$pos), ]

df_coor_dots$type <- vector_order

"~/Downloads/syringe.svg"

ggplot(df_coor_dots, aes(x=x1, y=y1,  color=type)) +
  geom_image(aes(image = ifelse(type == "OTHER", "person_f.svg", "female.svg")), 
             size = 0.03) + 
  #facet_wrap(~icon) +
  theme_void()+
  theme(legend.position = "none")


ggsave("example_plot", width = 5, height = 5)



