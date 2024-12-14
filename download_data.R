



#download 1000 files from here: http://hydra.nat.uni-magdeburg.de/packing/cci/txt/cci1000.txt


for (file in 1:1000) {
  download.file(paste0("http://hydra.nat.uni-magdeburg.de/packing/cci/txt/cci", file, ".txt"), paste0("cci", file, ".txt"))
}



#load from data-raw folder this files and merge them into one file. add a new var where ypu put the name file.

# Required libraries
library(data.table)

# Define the folder where the files are stored
folder_path <- "data-raw/"

# List all files in the folder
file_list <- list.files(path = folder_path, pattern = "cci\\d+\\.txt", full.names = TRUE)

# Initialize an empty list to store data
data_list <- list()

# Loop through each file
for (file in file_list) {
  # Read the file
  data <- fread(file, header = TRUE, sep = "\t", fill = TRUE) # Adjust the separator if needed
  
  # Extract the file name without the path
  file_name <- basename(file)
  
  # Add a new column with the file name
  data[, file_name := file_name]
  
  # Append the data to the list
  data_list[[file_name]] <- data
}

# Combine all data into one data table
merged_data <- rbindlist(data_list, use.names = TRUE, fill = TRUE)

# View the first few rows of the merged data
head(merged_data)

# Optionally, save the merged data into a new file
fwrite(merged_data, "merged_cci_files.csv")

