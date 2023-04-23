library(dplyr)
library(rtweet)
library(readr)
library(tidyverse)
# Reading files for review ------------------------------------------------
Sys.setlocale("LC_ALL", "Hebrew")

timelines <- read_csv("mk_twitter_timeline_short.csv") %>% 
  filter(created_at > '2021-04-01')

writexl::write_xlsx(timelines, 'timelines.xlsx')



timelines %>% 
  select(user_id, status_id, created_at, screen_name, text, reply_to_user_id, reply_to_screen_name, is_quote:reply_count, lang) %>% 
  write_csv("mk_twitter_timeline_short.csv")

mk_information <- read_tsv('mk_twitter_information.tsv')


# Collecting data and saving it -------------------------------------------

dat <- read.csv('mk_twitter.csv')
users_information <- dat %>% 
  filter(handle != "") %>% 
  mutate(handle = gsub("@",replacement = '', handle)) %>% 
  pull(handle) %>% 
  rtweet::lookup_users() # Not all users are returned for some reason

writexl::write_xlsx(users_information, 'users.xlsx')
readxl::read_xlsx('users.xlsx') %>% View()

# Remove list columns
users_information[!sapply(users_information, FUN = is.list)] %>% 
select(c(user_id, screen_name ,name, description:verified)) %>% 
# writexl::write_xlsx('mk_twitter_information.xlsx')
write_tsv('mk_twitter_information.tsv')

?get_timeline
library(writexl)

mk_twitter_timeline <- dat %>% 
  filter(handle != "") %>% 
  mutate(handle = gsub("@",replacement = '', handle)) %>% 
  pull(handle) %>% 
  get_timelines(n = 3200)

saveRDS(mk_twitter_timeline, 'twittertimeline.rds')




mk_twitter_timeline[!sapply(mk_twitter_timeline, FUN = is.list)] %>%
# write.csv( 'mk_twitter_timeline.csv')
  select(user_id, status_id, created_at, screen_name, text, reply_to_user_id, reply_to_screen_name, is_quote:reply_count, lang) %>% 
# writexl::write_xlsx( 'mk_twitter_timeline.xlsx')
write_csv('mk_twitter.csv')



mk_twitter_timeline_small <- mk_twitter_timeline %>%
  filter(as.Date(created_at) >= as.Date('2022-01-01')) %>% 
  select(user_id, status_id, created_at, screen_name, text, reply_to_user_id, reply_to_screen_name, is_quote:reply_count, lang) 

top10 = mk_twitter_timeline %>% 
  filter(created_at >= '2022-01-01') %>% 
  count(screen_name, sort = T) %>% 
  slice(1:10) %>% 
  pull(screen_name)

mk_twitter_timeline %>% 
  filter(screen_name %in% top10, created_at >= '2022-01-01') %>% 
  # group_by(user_id) %>% 
  count(screen_name, date = as.Date(created_at) ) %>% 
  ggplot(aes(x = date, y= n, group = screen_name)) +
  geom_line()+
  facet_wrap(~ screen_name)


