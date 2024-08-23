#' class: "Computational Social Science and Digital Behavioral Data, University of Mannheim"
#' title: "Introduction"
#' author: "Sebastian Stier"
#' lesson: 1
#' institute: University of Mannheim & GESIS
#' date: "2024-02-14"


# Exercise 0: Install [R](https://cran.rstudio.com) and [RStudio Desktop](https://posit.co/downloads/) ----

# Exercise 1: Setup and R packages ----
## a. Create a folder for the R scripts and materials of this class and 
      # set the R working directory to this folder.
getwd()
setwd(dirname(rstudioapi::getActiveDocumentContext()$path)) # not needed if you have a 
# project that will set the wd for you

# New project top left File -> New Project

## b. Create subfolders "data" and "plots"


## c. Install the R package *tidyverse*. 
#install.packages("tidyverse")
library(tidyverse)

## d. Check the version of the *tidyverse* package
packageVersion("tidyverse")

## e. List all your files in the working directory (folder) and the environment (top right)
list.files()
ls()


# Exercise 2: Transform a data frame into a tibble and name the differences between the two formats. ----
# let's first install and load the gapminder dataset
#install.packages("gapminder")
library(gapminder)
gapminder <- gapminder # pull the gapminder data to the R environment
df <- as.data.frame(gapminder)

# How do R packages work?
# The tidyverse contains all the packages we will use today
# Hence ggplot2 and dplyr are ready to go after installing tidyverse

names(gapminder)
gapminder[, 1]
gapminder %>% select(country)
gapminder %>% 
    select(year, country) 
select(gapminder, c(year, country))

?mean
?glimpse
?select
dplyr::glimpse()
dplyr::select()


# Exercise 3: Gapminder explorations ----

# Explore the dataset
head(gapminder)
glimpse(gapminder)
View(gapminder)
summary(gapminder)
typeof(gapminder$pop)

# Produce a data frame with the data for Germany and some additional countries
gapminder_ger <- gapminder %>% 
    filter(country == "Germany" | country == "France" | 
           country == "Italy" | country == "Spain") %>% 
    count(country)

gapminder %>% 
    filter(country %in% c("Germany", "France", "Italy", "Spain")) %>% 
    count(country)

gapminder %>% 
    count(country)

gapminder %>% 
    filter(country == "Germany" & year > 1990 & pop < 82000000) 
    
# Produce a data frame with the data for Germany and France
gapminder_ger_fra <- gapminder %>% 
    filter(country == "Germany" | country == "France") 
    
# Subset the data to the year 2007
gapminder %>% 
    filter(year == 2007)

# How many countries do we have in the data? List them
gapminder %>% 
    count(country) %>% 
    View()
country_list <- unique(gapminder$country)
length(country_list)
length(unique(gapminder$country))
n_distinct(gapminder$country)


# Arrange the data according to population size, in decreasing order

# Pipe-Operation with filter(), arrange() and head()
# Select all country-years with a population size < 100 Mio., arrange by GDP/capita, show the top 5 country-years
range(gapminder$pop)
     
gapminder %>% 
    #filter(pop < 100000000) %>% 
    arrange(desc(gdpPercap)) %>% 
    head(10)


#TODO Continue here in the next session ----


# Create a dataset with the variables country, year and lifeExp 

# Rename all variables to variable names of your choice
names(gapminder)

# Use mutate() to create a new variable where the population size is divided by 1 mil.


# group_by() and summarize()

# These two commands are mostly used in combination:
# "group_by" groups columns by a grouping variable
# "summarize" consolidates the mentioned column based on the grouping variable
# into a single row

# Calculate the mean GPD/Capita and population size by content
# continent_summary <- 

# create the pipe: COMMAND + SHIFT + M


# Data visualization in ggplot2 ----
library(ggplot2) # ggplot2 is part of the tidyverse and should already be loaded

# Initializing a plot
ggplot(gapminder, aes(x = lifeExp, y = gdpPercap))
gapminder %>% 
    filter() %>% 
    arrange()

# Create a scatter plot of lifeExp and gdpPercap

# Add a fit line (smoothed or linear fit)

# Add self-explanatory labs() and show GDP/Capita as logged x axis

# Save the plot
ggsave(file = "plots/gdp_lifeExp.pdf") # width = 7, height = 5

# Create a bar chart showing the GDP/Capita of European countries in the year 2007



# Exercise 4: Gapminder tasks ----

# 1) Identify the country-years with the highest GDP per capita.
#    Do you discover a rather unusual pattern?

# 2) Calculate the (worldwide) average GDP per capita per year 
#    and plot this as a bar chart

# 3) Calculate the average life expectancy and the population size 
#    for the year 2007

# 4) Sum the total world population per year. 
#    Plot the results in a bar chart for the years 1992-2007



# Exercise 5: Explore a toy web tracking dataset ----

# Load the test browsing data
filename <- "data/toydt_browsing.rda"
download.file(url = "https://osf.io/download/wjd7g/", destfile = filename)
load(filename)

# Load the test survey data
filename <- "data/toydt_survey.rda"
download.file(url = "https://osf.io/download/jyfru/", destfile = filename)
load(filename)
rm(filename) #remove the helper object


# First, let's get a feeling for the data: How many participants are in the data?

# What is the number of website visits per participant?
    
# How many of the visits happened on mobile and on desktop?  
    
# What is the time range of the data?

# What are the top ten visited domains in the data?
## Install the R package adaR: https://cran.r-project.org/web/packages/adaR/adaR.pdf
## Apply the function to extract domains from URLs

# Summarize the number of Facebook visits per person

# Merge the web tracking data with the survey data

# Plot the relation of Facebook visits and age


