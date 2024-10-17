#' class: "Computational Social Science and Digital Behavioral Data, University of Mannheim"
#' title: "Designed Digital Data"
#' author: "Sebastian Stier"
#' lesson: 4
#' institute: University of Mannheim & GESIS
#' date: "2024-10-02"

library(tidyverse)

# Exercise 1: Explore a toy web tracking and survey dataset ----

# Load the browsing data
filename <- "data/toy_browsing.rda"
download.file(url = "https://osf.io/download/52pqe/", destfile = filename)
load(filename)

# Load the survey data
filename <- "data/toy_survey.rda"
download.file(url = "https://osf.io/download/jyfru/", destfile = filename)
load(filename)
rm(filename)

# Save and load the data in csv, rds, Rda
load("data/toy_survey.rda")
load("data/toy_browsing.rda") 
#save()
write_rds(toy_browsing, "data/toy_browsing.rds")
df_wt <- read_rds("data/toy_browsing.rds") %>% 
  as_tibble()
#saveRDS()
#write_csv()
#read_csv()
#read.csv()

# Create object df_wt for further analysis
df_wt <- toy_browsing

# Explore the dataset: number of rows, columns, unique persons, what date range
glimpse(df_wt)
nrow(df_wt)
ncol(df_wt)
length(unique(df_wt$panelist_id))
n_distinct(df_wt$panelist_id)
#table(df_wt$timestamp) #don't run, many singular time stamps
summary(df_wt)
range(df_wt$timestamp)

# Count the number of wave+device combinations for each person (important to know your data)
table(df_wt$wave)
df_wt %>% 
  group_by(panelist_id, wave, device) %>% 
  summarise(n_visits = n()) %>% 
  ungroup() %>% 
  count(panelist_id)
  
# Investigate a person with less than 8 rows
df_wt %>% 
  filter(panelist_id == "5ptK95BQBY") %>% 
  count(wave, device)

# TO BE CONTINUED HERE

# Calculate the mean and median number of website visits per wave and device
df_wt %>% 
  group_by(panelist_id, device, wave) %>% 
  summarise(n_visits = n()) %>% 
  group_by(device, wave) %>% 
  summarise(mean_visits = mean(n_visits),
            median_visits = median(n_visits))

# How many of the visits happened on mobile vs. desktop for each wave? 
# What is the share of mobile vs. desktop per wave?
df_wt %>% 
  group_by(device, wave) %>% 
  summarise(n_visits = n()) %>% 
  group_by(wave) %>% 
  mutate(total_visits = sum(n_visits),
         share = n_visits/total_visits)

# Plot a time series of the number of visits per day
df_wt %>% 
  as_tibble() %>% 
  mutate(date = as.Date(timestamp)) %>% 
  group_by(date) %>% 
  #count() %>% equivalent
  summarise(n_visits = n()) %>% 
  ggplot(aes(x = date, y = n_visits)) +
  geom_line() +
  geom_point() +
  theme_minimal()


# Exercise 2: Domain augmentation of the web tracking data ----

# What are the top ten visited domains in the data?
## Install the R package adaR: https://gesistsa.github.io/adaR/
## Apply the relevant function from the package to extract domains from URLs
library(adaR)
df_wt <- as_tibble(df_wt)
df_wt <- df_wt %>% 
  mutate(domain = ada_get_domain(url))

# Inspect whether there are NAs in domain; what can explain the NAs?
table(df_wt$domain, useNA = "a")
table(is.na(df_wt$domain))
df_wt %>% 
  filter(is.na(domain))

# Summarize the number of total visits, Google and Facebook visits per person
df_panelist <- df_wt %>% 
  mutate(facebook = case_when(domain == "facebook.com" ~ 1,
                              .default = 0),
         google = case_when(domain == "google.com" ~ 1,
                            .default = 0)
         ) %>%
  # mutate(facebook = ifelse(domain == "facebook.com", 1, 0),
  #         google = ifelse(domain == "google.com", 1, 0)) %>%
  # mutate(facebook = domain == "facebook.com",
  #        google = domain == "google.com" | domain == "google.de") %>%
  group_by(panelist_id) %>% 
  summarise(total_visits = n(),
            sum_facebook = sum(facebook, na.rm = T),
            sum_google = sum(google, na.rm = T)
  )
  
# Merge the survey data with the number of total visits, Google visits and Facebook visits
table(df_panelist$panelist_id %in% toy_survey$panelist_id)
table(df_wt$panelist_id %in% toy_survey$panelist_id)
df_merged <- df_panelist %>% 
  left_join(toy_survey, by = "panelist_id")
summary(df_merged)
df_test <- df_wt %>% 
  left_join(toy_survey, by = "panelist_id")

# Plot the relation of Facebook visits and age with a point diagram


# Exercise 3: Analysis of news website visits ----

# Merge the news domain information with the web browsing data
## Load U.S. news domain list
news_list <- read.csv("https://raw.githubusercontent.com/ercexpo/us-news-domains/main/us-news-domains-v2.0.0.csv")

# First, check whether there are duplicates in the news data 
nrow(news_list)
n_distinct(news_list$domain)
news_list %>% 
  filter(duplicated(domain))
length(unique(news_list$domain))

# de-duplicate a vector
unique(c("sebastian", "sebastian", "felix"))

# remove the duplicates
news_list <- news_list %>% 
  filter(!duplicated(domain))
nrow(news_list)

# let's explore the !
df_wt %>% 
  mutate(date = as.Date(timestamp)) %>% 
  filter(!date == "2019-04-01")

# Finally, join the web tracking data with the news lists
news_list$news <- 1
df_wt <- df_wt %>% 
  left_join(news_list, by = "domain")
df_wt <- df_wt %>% 
  mutate(news = domain %in% news_list$domain)
table(df_wt$news, useNA = "a")

# Let's create a dummy for news websites
#tolower() sometimes needed

# Identify the web tracking visits whose URL contains "trump"
## hint: ?str_detect
df_wt <- df_wt %>% 
  mutate(trump = str_detect(url, "trump"))
table(df_wt$trump)

# Some more explorations of our new variables: where outside of news websites does trump occur?
df_wt %>% 
  count(news, trump)
table(df_wt$news, df_wt$trump)

# most popular trump domains
df_wt %>% 
  filter(trump == TRUE) %>% 
  count(domain) %>% 
  arrange(desc(n))

df_wt %>% 
  filter(domain == "yahoo.com" & trump == TRUE) %>% 
  select(url)

