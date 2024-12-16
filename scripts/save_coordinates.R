#load all .txt files from data-raw folder


setwd("data-raw")

# List all .txt files
files <- list.files(path = "data-raw", pattern = "\\.txt$", full.names = TRUE)

# load it in a list

df_coor <- lapply(files, read.table)

# combine all dataframes in the list. add the name of the file as a column

df_coor_1 <- do.call(rbind, Map(cbind, df_coor, file = basename(files)))

df_coor_1 <- df_coor_1 %>% rename(x1 = V2, y1 = V3, pos = V1)

df_coordinates_final <- df_coor_1 %>% 
  #get number from file name
  mutate(file = stringr::str_extract(file, "\\d+")) %>% 
  rename(size = file)


df_coor_100_v2 <- df_coor %>% 
  filter(file == "cci1000.txt") 

#save as Rdata

save(df_coordinates_final, file = "df_coordinates_final.Rdata")
