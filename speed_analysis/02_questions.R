library(tidyverse)

dat <- read_tsv("speed_dating_speed_analysis.tsv")

# How many dates happened?
dat



# A match is when both sides have a decision of 1, how many matches are there?
dat %>% 
  filter(decision_female == 1, decision_male == 1)

# How many couples (dates) were the same race?* ---- Change
dat %>% 
  filter(race_female == race_male)

# what is the females' median age?
dat %>%
  pull(age_female) %>% 
  median()




# what is the 2nd most common profession across all participants
data.frame(test = c(dat$field_female, dat$field_male)) %>% 
  count(test, sort = T)


# 5 What is the most common single race (for example - latino)
data.frame(test = c(dat$race_female, dat$race_male)) %>% 
  mutate(test = strsplit(test, '/')) %>% 
  unnest() %>% 
  count(test, sort = T)


# 6. How many Male Asian American practice law (and went on the speed dating)?*
dat %>% 
  mutate(rowid = 1:nrow(.)) %>% 
  mutate(race_male = strsplit(race_male, '/')) %>% 
  unnest(race_male) %>% 
  filter(race_male == 'asian-american', field_male == "law") %>% 
  select(race_male, field_male)


# Q7. How many same age same sex same race dates decided to match?
dat %>% 
  filter(race_male == race_female, age_female == age_male, decision_male == 1 & decision_male == decision_female)

# Q8. what is the biggest age difference in years
dat %>% 
  transmute(diff = abs(age_female - age_male)) %>% 
  # count(diff) %>% 
  arrange(-diff)

# What's the first common letter across all distinct professions?
data.frame(prof = c(dat$field_female, dat$field_male)) %>% 
  distinct(prof) %>% View()
transmute(first_letter = substr(prof, 1, 1)) %>% 
  count(first_letter,sort = T)


# How many dates occurred where the ratio between the participants is greater than times 2
dat %>% filter(age_female / age_male <0.5 | age_female / age_male > 2)



# Difficulty medium: What's the most frequent combination of fields? (requires sorting)
dat %>% 
  mutate(prof1 = ifelse(field_male < field_female, field_female, field_male),
         prof2 = ifelse(field_male > field_female, field_female, field_male)
  ) %>% 
  count(prof1, prof2, sort = T)

# What's the occurence of the most different scores for funniness a pair wrote?
dat %>% 
  transmute(dif = funny_female - funny_male) %>% 
  arrange(-dif)


# To Fix: -----------------------------------------------------------------

# 2. How many couples (dates) were the same race?
# Original: 3
# My answer: 3101

# Q5: # What is the most common single race (for example - latino)
# Original European,
# Mine, also caucasian-american? Did you split it?

# Q6: How many Male Asian American practice law (and went on the speed dating)?
# ORiginal: 143
# Mine: A little tricky in the question that we need to split, anyway i got 128 if we split it?


# Q7. How many same age same sex same race dates decided to match?
# Original: 1
# What does same sex mean? Anyway, same race and sace da

dat %>% 
  filter(race_male == race_female)

# If the decision column represents the decision that gender wrote, what gender gave more 'Yes' (1 = yes)?
dat %>% 
  summarise(
    sum(decision_male),
    sum(decision_female))

# How many couples' funny score are both prime numbers?
dat %>% 
  filter(funny_female %in% c(1,3,5,7,11), funny_male %in% c(1,3,5,7,11))