# Cleaning the data before the live

library(dplyr)
library(readr)
library(purrr)

# Read data and clean names
raw <- read_csv("20170308hundehalter.csv") %>% 
  janitor::clean_names() %>% 
  set_names(nm = c("owner_id", "age", "gender", "city_district", "quarter", "primary_breed", "is_hybrid", "secondary_breed", "is_secondary_hybrid", "breed_type", "dog_yob", "dog_gender", "dog_color"))  %>% 
  # generate random names
  mutate(dog_dob = as.Date(paste0(dog_yob, "-", sample(c(1:12, 1)), "-", sample(c(1:28),  1))))

# Split DF for writing them
dflist <- dat %>% split(.$dog_yob)

walk(names(dflist), function (x) readr::write_csv(dflist[[x]], file = paste0("split_data/yob_", x, ".csv")))

# Check reading of data
files <- paste0("split_data/", list.files("split_data"))
dat <- map_dfr(files, read_csv)

# Save processed data
write_csv(raw, "raw_data/raw_clean_processed.csv")
