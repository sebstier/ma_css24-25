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
df_wt %>% 
  group_by(panelist_id, wave, device) %>% 
  summarise(n_visits = n()) %>% 
  ungroup() %>% 
  count(panelist_id)
  
# Investigate a person with less than 8 rows
df_wt %>% 
  filter(panelist_id == "1amvqVlZOT") %>% 
  count(wave, device)

# TO BE CONTINUED HERE

# Calculate the mean and median number of website visits per wave and device

# How many of the visits happened on mobile vs. desktop for each wave? 
# What is the share of mobile vs. desktop?

# Plot a time series of the number of visits per day


# Exercise 2: Domain augmentation of the web tracking data ----

# What are the top ten visited domains in the data?
## Install the R package adaR: https://gesistsa.github.io/adaR/
## Apply the relevant function from the package to extract domains from URLs
library(adaR)


# Inspect whether there are NAs in domain; what can explain the NAs?

# Summarize the number of total visits, Google and Facebook visits per person
#df_panelist <- 
  
# Merge the survey data with the number of total visits, Google visits and Facebook visits

# Plot the relation of Facebook visits and age with a point diagram


# Exercise 3: Analysis of news website visits ----

# Merge the news domain information with the web browsing data
## Load U.S. news domain list
news_list <- read.csv("https://raw.githubusercontent.com/ercexpo/us-news-domains/main/us-news-domains-v2.0.0.csv")

# First, check whether there are duplicates in the news data 

# What are the duplicated domain entries?

# Remove the duplicates

# Finally, join the web tracking data with the news lists

# Let's create a dummy for news websites

# Identify the web tracking visits whose URL contains "trump"
## hint: ?str_detect

# Some more explorations of our new variables: where outside of news websites does trump occur?


