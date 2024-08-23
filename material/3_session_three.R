#' class: "Computational Social Science and Digital Behavioral Data, University of Mannheim"
#' title: "Web data and designed digital data"
#' author: "Sebastian Stier"
#' lesson: 3
#' institute: University of Mannheim & GESIS
#' date: "2024-03-13"


# Exercise 1: Gapminder and ggplot tasks ----
library(gapminder)
library(tidyverse)
gapminder <- gapminder
# 1) Calculate the (worldwide) average GDP per capita per year 
#    and plot this as a bar chart
gapminder %>% 
    group_by(year, continent) %>% 
    summarise(mean_gdp = mean(gdpPercap)) %>% 
    ggplot(aes(x = year, y = mean_gdp, fill = continent)) +
    geom_col()

# 2) Calculate the average life expectancy and the population size 
#    for the year 2007
gapminder %>% 
    group_by(year) %>% 
    summarise(mean_lifeExp = mean(lifeExp, na.rm = T),
              mean_pop = mean(pop, na.rm = T))
glimpse(gapminder)

# 3) Sum the total world population per year. 
#    Plot the results in a bar chart for the years 1992-2007
library(scales) # we use this library to get comma-separation onto the y axis
gapminder %>% 
    group_by(year) %>% 
    summarise(tot_pop = sum(pop)) %>% 
    filter(year >= 1992) %>% 
    #filter(year > 1991) %>% 
    ggplot(aes(x = year, tot_pop)) +
    geom_col() +
    scale_y_continuous(labels = scales::comma_format()) 


# Exercise 2: Explore a toy web tracking dataset ----

# Load the test browsing data
filename <- "data/toy_browsing.rda"
download.file(url = "https://osf.io/download/52pqe/", destfile = "data/toy_browsing.rda")
load(filename)

# Load the test survey data
filename <- "data/toy_survey.rda"
download.file(url = "https://osf.io/download/jyfru/", destfile = filename)
load(filename)
rm(filename) 

# Saving files and file formats
getwd()
list.files()
# Native R format rda
load("/Users/sebstier/Downloads/toy_browsing-2.rda")
list.files("data")
load("data/toy_browsing.rda")
df <- toy_browsing
save(toy_browsing, file = "data/toy_browsing.rda")
# Tidyverse format rds
write_rds(toy_browsing, "data/toy_browsing.rds")
df <- read_rds("data/toy_browsing.rds")
# csv
write_csv(toy_browsing, file = "data/toy_browsing.csv")
ls()

# Some explorations
nrow(toy_browsing)
glimpse(toy_browsing)
ls()

# First, let's get a feeling for the data: How many participants are in the browsing dataset?
length(unique(toy_browsing$panelist_id))
n_distinct(toy_browsing$panelist_id)

# Aggregate the number of website visits per participant
df = toy_browsing
df_aggregations <- df %>% 
    group_by(panelist_id) %>% 
    summarise(n_distinct_waves = n_distinct(wave),
              n_distinct_device = n_distinct(device),
              n_visits = n()) 
df_aggregations %>% 
    count(n_distinct_waves)
df_aggregations %>% 
    arrange(desc(n_visits))
    
# How many of the visits happened on mobile and on desktop for each wave?
df %>% 
    group_by(device, wave) %>% 
    summarise(n_visits = n())
    
# What is the time range of the data?
range(df$timestamp)
df %>% 
    mutate(day = as.Date(timestamp))



