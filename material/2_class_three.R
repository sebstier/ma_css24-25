#' class: "Computational Social Science and Digital Behavioral Data, University of Mannheim"
#' title: "Research ethics in CSS and web data collection"
#' author: "Sebastian Stier"
#' lesson: 3
#' institute: University of Mannheim & GESIS
#' date: "2024-09-18"


# Trump Twitter Archive ----

# Download the Trump Twitter archive and save the file in the folder "data"
# https://drive.google.com/file/d/1xRKHaP-QwACMydlDnyFPEaFdtskJuBa6/view
list.files("data")

# Check if the tweet IDs are unique


# Read in the file once more, specifying that "id" is a string

# Use group_by() and summarize() to summarize the number of tweets per day
# These two commands are mostly used in combination:
# "group_by" groups columns by a grouping variable
# "summarize" consolidates the mentioned column based on the grouping variable
# into a single row


# Some basic text operations ----

# Calculate the occurance of the words "crazy" or "fake" across devices
# hint: use ?str_detect

# Use mutate() to create a variable indicating that the tweet was sent via 
#iPhone or Android or another device


# Calculate the share of tweets per device that contain either "crazy" or "fake"


# Create a subset of the data that contains the tweets with either "crazy" or "fake"


# Data visualization using gapminder data ----
library(ggplot2) # ggplot2 is part of the tidyverse and should already be loaded
library(gapminder)


# Create a scatter plot of lifeExp and gdpPercap


# Add a fit line (smoothed or linear fit)


# Add self-explanatory labs() and show GDP/Capita as logged x axis


# Save the plot


# Create a bar chart showing the GDP/Capita of European countries in the year 2007


# Calculate the (worldwide) average GDP per capita per year and plot this as a bar chart

# Sum the total world population per year. Plot the results in a bar chart for the years 1992-2007


# Visualizing the Trump tweets dataset ----

# Create a time series plot of the daily share of "crazy" and "fake" over time


# YouTube API ----
library(tuber)
# If you want to use this, get your API verification here: 
#https://developers.google.com/youtube/v3/getting-started

yt_oauth(
  app_id = client_id,
  app_secret = client_secret
)

#tuber::
get_stats(video_id = "IXDR2-WWY5Y")

get_video_details(video_id = "IXDR2-WWY5Y")

df_yt <- get_comment_threads(c(video_id = "IXDR2-WWY5Y"), max_results = 20)
