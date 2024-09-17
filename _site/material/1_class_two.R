#' class: "Computational Social Science and Digital Behavioral Data, University of Mannheim"
#' title: "Introduction"
#' author: "Sebastian Stier"
#' lesson: 2
#' institute: University of Mannheim & GESIS
#' date: "2024-09-11"


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

## d. Check the version of the *tidyverse* package
packageVersion()

## e. List all your files in the working directory (folder) and the environment (top right)



# Exercise 2: Transform a data frame into a tibble and name the differences between the two formats. ----
# let's first install and load the gapminder dataset

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
    

# Produce a data frame with the data for Germany and France

    
# Subset the data to the year 2007


# How many countries do we have in the data? List them


# Arrange the data according to population size, in decreasing order

# Pipe-Operation with filter(), arrange() and head()
# Select all country-years with a population size < 100 Mio., arrange by GDP/capita, show the top 5 country-years



