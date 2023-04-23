library(tidyverse)

dat <- read_tsv("speed_dating_speed_analysis (2).tsv")

# 1. How many dates were there?
dat


#2.

dat %>% 
  filter(race_female == race_male)


# 3. 
dat %>% 
  pull(age_female) %>% 
  median()

# 4. 
data.frame(race = c(dat$race_female, dat$race_male)) %>% 
  transmute(race = strsplit(race, '/')) %>% 
  unnest(race) %>% 
  count(race, sort = T)


data.frame(race = c(dat$race_female, dat$race_male)) 

# 5. 
dat %>% 
  mutate(rowid = 1:nrow(.),
         race = strsplit(race_male, '/')) %>% 
  unnest(race) %>% 
  filter(race == "asian american")

# 6.
dat %>% 
  filter(decision_female == 1, decision_male == decision_female)


# 7. 
dat %>% 
  filter(age_female == age_male, field_female == field_male, decision_female == decision_male, decision_female == 1, race_female == race_male)

dat %>% 
  transmute(diff = abs(age_female - age_male)) %>% 
  arrange(-diff)

dat %>% 
  filter(funny_female %in% c(2, 3,5,7,11), funny_male %in% c(2, 3,5,7,11))


dat %>% 
  filter(age_female / age_male < 0.5 | age_female / age_male > 2)



dat %>% 
  count(field_female, field_male, sort = T)



dat %>% 
  mutate(
    prof1 = ifelse(field_male < field_female, field_male, field_female),
    prof2 = ifelse(field_male > field_female, field_female, field_male)) %>% 
  count(prof1, prof2, sort = T)
  

data.frame(race = c(dat$race_female, dat$race_male)) %>% 
  distinct(race) %>% 
  mutate(firstletter = str_sub(race, 1, 1)) %>% 
  count(firstletter, sort = T)
