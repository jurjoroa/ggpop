library(ggplot2) # load the library 
library(ggimage)
library(ggforce)


df_crc <- read.csv2("2024_09_06_COL_458510_CaDxAndDeathData.csv", sep = ",")

#get proportion of crc_cases CauseOfDeath from the data (N)

#group by CauseOfDeath and get the count of each group

library(dplyr)
df_prop <- df_crc %>% 
  group_by(CauseOfDeath) %>% 
  summarise(n = n()) %>% 
  mutate(prop = n / sum(n))

library(mtcars)

data(mtcars)

data("mtcars")


# createcar# create migrants sample
migrant <- sample(c("CRC", "OTHER"), 1000, replace = TRUE, prob=c(df_prop$prop[1], 1-df_prop$prop[1]))


# Define total number of migrants
total_migrants <- 1000

# Calculate the number of "CRC" and "OTHER" based on the proportion
n_crc <- round(df_prop$prop[1] * total_migrants)
n_other <- total_migrants - n_crc

# Create a vector with the appropriate number of "CRC" and "OTHER"
migrant <- c(rep("CRC", n_crc), rep("OTHER", n_other))


# load coordinates  
coor <- read.table("cci2647.txt")

coor2 <- read.table("cci2647.txt")

coor3 <- read.table("cci1000.txt")

#add +1 to the coordinates to avoid log(0)

coor2$V2 <- coor2$V2 + .00001

coor2$V3 <- coor2$V3 + .00001


#merge the migrants and coordinates data frames 
df <- cbind(coor, migrant)

df_2 <- cbind(coor3, migrant)

df_final <- cbind(coor2, migrant)

df_2$icon <- "1"

df_3 <- df_2

df_3$icon <- "2"

df_2_3 <- rbind(df_2, df_3)

df_final_final <- rbind(df, df_final)
#basic plot #basicrbind() plot 
ggplot(df_2, aes(y=V2, x=V3, color=migrant))+
  geom_point()


ggplot(df_2_3, aes(x=V2, y=V3,  color=migrant)) +
  geom_image(aes(image = ifelse(migrant == "OTHER", "person_f.svg", "person_f.svg")), 
             size = 0.03) + 
  #facet_wrap(~icon) +
  theme_void()+
  theme(legend.position = "none")


ggsave("plot4.png", width = 5, height = 5)


df_movies <- read.csv2("movies.csv", sep = ",")



#group by genres and get the count of each group

library(dplyr)

df_movies_pop <- df_movies %>% 
  group_by(genres) %>% 
  summarise(n = n()) %>% 
  mutate(prop = n / sum(n))

library(dplyr)

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



migrant <- sample(c(df_movies_pop$grouped_genres), 1000, replace = TRUE, prob=c(df_movies_pop$prop))


coor35 <- read.table("cci1000.txt")

df_22 <- cbind(coor35, migrant)


ggplot(df_22, aes(x=V2, y=V3,  color=migrant)) +
  geom_image(aes(image = ifelse(migrant == "Action", "person_f.svg", "person_f.svg")), 
             size = 0.03)


# Calculate the number of migrants per genre based on the proportion
df_movies_pop2 <- df_movies_pop %>%
  mutate(count = round(prop * total_migrants))  # Calculate exact count for each genre

# Create a migrant column with a non-randomized sample, replicating based on counts
migrant <- rep(df_movies_pop$grouped_genres, df_movies_pop$count)

