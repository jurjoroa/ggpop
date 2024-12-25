example_plot.R
@@ -1,285 +0,0 @@
  # *****************************************************************************
  #
  # Script: example_plot.R
  #
  # Purpose: Example plot
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

df_crc <- read.csv2("data-raw/2024_09_06_COL_458510_CaDxAndDeathData.csv", sep = ",")

#get proportion of crc_cases CauseOfDeath from the data (N)

#group by CauseOfDeath and get the count of each group

df_prop_2 <- df_crc %>% 
  group_by(CauseOfDeath) %>% 
  summarise(n = n()) %>% 
  mutate(prop = n / sum(n))


# Create proportion of CRC cases
df_crc_cases <- sample(c("CRC", "OTHER"), 1000, replace = TRUE, prob=c(df_prop$prop[1], 1-df_prop$prop[1]))

#Define the total number of dots for the plot
total_dots <- 1000

# Calculate the number of "CRC" and "OTHER" based on the proportion
n_crc <- round(df_prop$prop[1] * total_dots)
n_other <- total_dots - n_crc

# Create a vector with the appropriate number of "CRC" and "OTHER"
df_dots <- c(rep("CRC", n_crc), rep("OTHER", n_other))


# load coordinates  


df_coor_1000 <- read.table("data-raw/cci1000.txt")


#merge the migrants and coordinates data frames 

df_coor_dots <- cbind(df_coor_1000, df_dots)


df_coor_dots$icon <- "1"

df_coor_dots_2 <- df_coor_dots

df_coor_dots_2$icon <- "2"

df_coor_dots_f <- rbind(df_coor_dots, df_coor_dots_2)




ggplot(df_coor_dots, aes(x=V2, y=V3,  color=df_dots)) +
  geom_image(aes(image = ifelse(df_dots == "OTHER", "person_f.svg", "female.svg")), 
             size = 0.03) + 
  #facet_wrap(~icon) +
  theme_void()+
  theme(legend.position = "none")


ggsave("example_plot", width = 5, height = 5)


# *****************************************************************************
#Money data example
# *****************************************************************************


remotes::install_github("npaterno/data_hunter")



# *****************************************************************************
# Movie data example
# *****************************************************************************


df_movies <- read.csv2("movies.csv", sep = ",")



#group by genres and get the count of each group


df_movies_pop <- df_movies %>% 
  group_by(genres) %>% 
  summarise(n = n()) %>% 
  mutate(prop = n / sum(n))

# Define the function to group genres into 20 unique categories
group_genres <- function(genre) {
  if (grepl("Action", genre)) {
    return("Action")
  } else if (grepl("Adventure", genre)) {
    return("Adventure")
  } else if (grepl("Animation", genre)) {
    return("Animation")
  } else if (grepl("Children", genre)) {
    return("Children")
  } else if (grepl("Comedy", genre)) {
    return("Comedy")
  } else if (grepl("Crime", genre)) {
    return("Crime")
  } else if (grepl("Documentary", genre)) {
    return("Documentary")
  } else if (grepl("Drama", genre)) {
    return("Drama")
  } else if (grepl("Fantasy", genre)) {
    return("Fantasy")
  } else if (grepl("Film-Noir", genre)) {
    return("Film-Noir")
  } else if (grepl("Horror", genre)) {
    return("Horror")
  } else if (grepl("IMAX", genre)) {
    return("IMAX")
  } else if (grepl("Musical", genre)) {
    return("Musical")
  } else if (grepl("Mystery", genre)) {
    return("Mystery")
  } else if (grepl("Romance", genre)) {
    return("Romance")
  } else if (grepl("Sci-Fi", genre)) {
    return("Sci-Fi")
  } else if (grepl("Thriller", genre)) {
    return("Thriller")
  } else if (grepl("War", genre)) {
    return("War")
  } else if (grepl("Western", genre)) {
    return("Western")
  } else if (length(strsplit(genre, "\\|")[[1]]) > 4) {
    return("Hybrid")
  } else {
    return("Other")
  }
}

# Apply the function to group genres in your dataframe and calculate proportions
df_movies_pop <- df_movies %>%
  mutate(grouped_genres = sapply(genres, group_genres)) %>%  # Group genres
  group_by(grouped_genres) %>%                               # Group by the new category
  summarise(n = n()) %>%                                     # Count the number of occurrences
  mutate(prop = n / sum(n))                                  # Calculate proportions



migrant <- sample(c(df_movies_pop$grouped_genres), 500, replace = TRUE, prob=c(df_movies_pop$prop))


coor35 <- read.table("data-raw/cci500.txt")

coor35 <- coor35[order(coor35$V1), ]  # Ensure coordinates are sorted by V1


df_22 <- cbind(coor35, migrant)

#sort by V1 and add the migrant column

# 2. Now reorder the data frame by V1 and then by migrant:
df_22 <- df_22[order(df_22$V1), ]

vector_order <- df_22$migrant

df_22$migrant <- vector_order


#order the data frame by migrant
# Define your custom 20-color palette
my_colors <- c('#e6194b', '#3cb44b', '#ffe119', '#0082c8', '#f58231', 
               '#911eb4', '#46f0f0', '#f032e6', '#d2f53c', '#fabebe', 
               '#008080', '#e6beff', '#aa6e28', '#fffac8', '#800000', 
               '#aaffc3', '#808000', '#ffd8b1', '#000080', '#808080')

ggplot(df_22, aes(x=V2, y=V3,  color=migrant)) +
  geom_image(aes(image = ifelse(migrant == "Action", "person_f.svg", "person_f.svg")), 
             size = 0.03) +
  #change palette
  scale_color_manual(values = my_colors)


# Calculate the number of migrants per genre based on the proportion
df_movies_pop2 <- df_movies_pop %>%
  mutate(count = round(prop * total_migrants))  # Calculate exact count for each genre

# Create a migrant column with a non-randomized sample, replicating based on counts
migrant <- rep(df_movies_pop$grouped_genres, df_movies_pop$count)


# *****************************************************************************
#Money data example
# *****************************************************************************

# Load the data

df_money <- read.csv2("data-raw/gdp-world-regions-stacked-area.csv", sep = ",")

#Keep in entity the countries that have ()

df_money_w <- df_money %>% 
  filter(grepl("\\(", Entity)) %>% 
  filter(Year == 2022)

#group by entity and get the count of each group


df_money_pop <- df_money_w %>% 
  group_by(Entity) %>% 
  summarise(GDP = sum(Gross.domestic.product..GDP.)) %>%
  mutate(prop = GDP / sum(GDP))

#sample

total_dots_v2 <- 1000

money <- sample(c(df_money_pop$Entity), total_dots_v2, replace = TRUE, prob=c(df_money_pop$prop))

#load coordinates

df_coor_100 <- read.table("data-raw/cci1000.txt")

#merge the migrants and coordinates data frames

df_coor_dots_money <- cbind(df_coor_100, money)

#order the data frame by money

vector_money <- df_coor_dots_money[order(df_coor_dots_money$money), ]

vector_order <- vector_money$money

#order the data frame by V1

df_coor_dots_money <- df_coor_dots_money[order(df_coor_dots_money$V1), ]

df_coor_dots_money$money <- vector_order


#plot

ggplot(df_coor_dots_money, aes(x=V2, y=V3,  color=money)) +
  geom_image(aes(image = ifelse(money == "United States (USA)", "dollar.svg", "dollar.svg")), 
             size = 0.02)+ 
  scale_color_brewer( palette = "Set1")



# Define the function to group entities into 20 unique categories