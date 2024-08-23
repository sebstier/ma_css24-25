#' class: "Computational Social Science and Digital Behavioral Data, University of Mannheim"
#' title: "Automated text analysis"
#' author: "Sebastian Stier"
#' lesson: 4
#' institute: University of Mannheim & GESIS
#' date: "2024-03-20"

library(tidyverse)

# Set the working directory to the folder where the script is located
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Exercise 1: Analysis of the web tracking data ----

# Load the data
list.files("data")
load("data/toy_browsing.rda")
load("data/toy_survey.rda")

# What are the top ten visited domains in the data?
## Install the R package adaR: https://cran.r-project.org/web/packages/adaR/adaR.pdf
## Apply the relevant function from the package to extract domains from URLs
library(adaR)
df_webtrack <- toy_browsing %>% 
    #sample_n(100) %>% 
    mutate(domain = adaR::ada_get_domain(url))
n_distinct(df_webtrack$url)
nrow(df_webtrack)
n_distinct(df_webtrack$domain)

# look at domain NAs (produced by ada_get_domain since the URLs were not in a valid format)
df_webtrack %>% 
    filter(is.na(domain))

# Summarize the number of Facebook visits per person: approach 1
df_webtrack %>% 
    as_tibble() %>% 
    group_by(panelist_id) %>% 
    summarise(fb_visits = sum(domain == "facebook.com"))

# Summarize the number of Facebook visits per person: approach 2
df_fb <- df_webtrack %>% 
    mutate(facebook = ifelse(domain == "facebook.com", 1, 0)) %>% # 2mil rows
    filter(!is.na(domain)) %>% 
    group_by(panelist_id) %>% # 100 persons
    summarise(fb_visits = sum(facebook)) 

# Plausibility checks of one panelist_id  
df_webtrack %>% 
    filter(panelist_id == "4HVpSqa344" & domain == "facebook.com")

# Merge the (aggregated results) from the web tracking data with the survey data
# Doe the IDs overlap?
table(toy_browsing$panelist_id %in% toy_survey$panelist_id, useNA = "a")
# Merge
df_merged <- left_join(toy_survey, df_fb, by = "panelist_id")

# Plot the relation of Facebook visits and age
df_merged %>% 
    filter(fb_visits < 50000) %>% 
    ggplot(aes(x = edu, y = fb_visits)) +
    geom_point()


# Exercise 2: Analysis of news website visits ----

# Merge the news domain information with the web browsing data
## Load U.S. news domain list
news_list <- read.csv("https://raw.githubusercontent.com/ercexpo/us-news-domains/main/us-news-domains-v2.0.0.csv")

# First, check whether there are duplicates in the data frame that we want to merge
nrow(news_list)
n_distinct(news_list$domain)

# What are the duplicated domain entries?
news_list %>% 
    group_by(domain) %>% 
    count %>% 
    arrange(desc(n))
duplicates <- as.data.frame(table(news_list$domain))

# Remove the duplicates (several approaches)
news_list <- news_list %>% 
    filter(domain %in% c("fox29.com", "nj.com"))
news_list <- news_list %>% 
    filter(!duplicated(domain))
nrow(news_list)

# Finally, join the web tracking data with the news lists
nrow(df_webtrack)
df_webtrack <- df_webtrack %>% 
    left_join(news_list, by = "domain")
nrow(df_webtrack)


# Exercise 3: Preprocessing and preparing text for analysis ----

# Identify the web tracking visits whose URL contains "trump"
## hint: ?str_detect
df_webtrack <- df_webtrack %>% 
    #sample_n(10) %>% 
    mutate(trump = str_detect(url, "trump"))

# Let's create a dummy for news websites
df_webtrack <- df_webtrack %>% 
    mutate(news = ifelse(!is.na(ideology) | !is.na(type), 1, 0) #based on the info from the news_list
           )
table(df_webtrack$trump)
table(df_webtrack$trump, df_webtrack$news)

# How does str_detect deal with lower/upper case words?
text_vector <- c("Trump", "trump", "trumpasdffasdasf", "  Trump", "test")
text_vector_lowered <- tolower(c("Trump", "trump", "trumpasdffasdasf", "  Trump", "test"))
str_detect(text_vector, "trump")
str_detect(text_vector_lowered, "trump")

# Some more explorations of our new variables: where outside of news do the trump URLs reside?
df_webtrack %>% 
    filter(news == 0 & trump == 1) %>% 
    count(domain) %>% 
    arrange(desc(n))

# Let's inspect some URLs on trump
df_webtrack %>% 
    filter(news == 0 & trump == 1) %>% 
    select(url)

    

# Download the Trump Twitter Archive

# Download all tweets from the Trump Twitter archive and save the file
# in the folder "data"
# https://drive.google.com/file/d/1xRKHaP-QwACMydlDnyFPEaFdtskJuBa6/view
list.files("data")
df_trump <- read_csv("data/tweets_01-08-2021.csv")

# Check if the tweet IDs are unique
nrow(df_trump)
n_distinct(df_trump$id)

# Read in the file once more, specifying that "id" is a string
glimpse(df_trump)
df_trump <- read_csv("data/tweets_01-08-2021.csv", col_types = "ccllcddTl")
nrow(df_trump)
n_distinct(df_trump$id)

