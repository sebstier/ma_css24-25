#' class: "Computational Social Science and Digital Behavioral Data, University of Mannheim"
#' title: "Research ethics in CSS and web data collection"
#' author: "Sebastian Stier"
#' lesson: 3
#' institute: University of Mannheim & GESIS
#' date: "2024-09-18"


# Trump Twitter Archive ----

# Download the Trump Twitter archive and save the file in the folder "data"
# https://drive.google.com/file/d/1xRKHaP-QwACMydlDnyFPEaFdtskJuBa6/view
library(tidyverse)
list.files("data")
df_trump <- read_csv("data/tweets_01-08-2021.csv",
                     col_types = "ccllcddTl")
# df_trump <- read.csv("data/tweets_01-08-2021.csv", 
#                      colClasses = c("id" = "character")) 
summary(df_trump)
glimpse(df_trump)

# Check if the tweet IDs are unique
n_distinct(df_trump$id)
nrow(df_trump)


# Use group_by() and summarize() to summarize the number of tweets per day
# These two commands are mostly used in combination:
# "group_by" groups columns by a grouping variable
# "summarize" consolidates the mentioned column based on the grouping variable
# into a single row
df_trump %>% 
  mutate(day = as.Date(date)) %>% 
  group_by(day) %>% 
  summarise(n_tweets = n()) %>% 
  arrange(desc(day))

df_trump %>% 
  group_by(as.Date(date)) %>% 
  summarise(n_tweets = n())


# Some basic text operations ----

# Calculate the occurance of the words "crazy" or "fake" across devices
# hint: use ?str_detect
df_trump %>% 
  mutate(crazy = str_detect(text, fixed("crazy", ignore_case = TRUE)),
         fake = str_detect(text, fixed("fake", ignore_case = TRUE))) %>% 
  summarise(sum_crazy = sum(crazy),
            sum_fake = sum(fake))

# Some tests
test_vec <- c("fakenews", "fake", "FAKE", "FakE", "FAKENEWS", "gesetz", "wahl", "bundestagswahl")
tolower(test_vec)
toupper(test_vec)
str_detect(test_vec, "fake")

#TODO HOMEWORK
fruit <- c("apple", "banana", "pear", "pineapple")
str_detect(fruit, "a")
str_detect(fruit, "^a")
str_detect(fruit, "a$")
str_detect(fruit, "b")
str_detect(fruit, "[aeiou]")

# Data visualization using gapminder data ----
library(ggplot2) # ggplot2 is part of the tidyverse and should already be loaded
library(gapminder)

# Create a scatter plot of lifeExp and gdpPercap
plot1 <- gapminder %>% 
  ggplot(aes(x = lifeExp, y = gdpPercap)) +
  geom_point() +
  ggplot2::scale_y_log10() +
# Add a fit line (smoothed or linear fit)
  geom_smooth(method = "lm") +
# Add self-explanatory labs() and show GDP/Capita as logged y axis
  labs(x = "Life expectancy", y = "GDP/Capita", 
       title = "A nice correlation",
       subtitle = "Data based on gapminder"
       )

# Save the plot
ggsave(plot1, filename = "plots/test_plot1.pdf")
ggsave(plot1, filename = "plots/test_plot1.png", dpi = 1000,
       width = 11, height = 6)

# Create a bar chart showing the GDP/Capita of European countries in the year 2007
gapminder %>% 
  filter(year == 2007 & continent == "Europe") %>% # either use & or | 
  mutate(country_rec = fct_reorder(country, gdpPercap)) %>% 
  ggplot(aes(x = country_rec, y = gdpPercap)) +
  geom_col() +
  ggplot2::coord_flip()

# TODO HOMEWORK  
# Calculate the (worldwide) average GDP per capita per year and plot this as a bar chart
# Sum the total world population per year. Plot the results in a bar chart for the years 1992-2007


# Visualizing the Trump tweets dataset ----

# Use mutate() to create a variable indicating that the tweet was sent via 
#iPhone or Android or another device
table(df_trump$device)
df_trump %>% 
  count(device)

# Calculate the share of tweets per device that contain either "crazy" or "fake"
df_trump %>% 
  mutate(crazy = str_detect(text, fixed("crazy", ignore_case = TRUE)),
         fake = str_detect(text, fixed("fake", ignore_case = TRUE))
         ) %>% 
  group_by(device) %>% 
  summarise(n_tweets = n(),
            sum_crazy = sum(crazy),
            sum_fake = sum(fake),
            share_crazy = sum_crazy / n_tweets,
            share_fake = sum_fake / n_tweets)


# Create a subset of the data that contains the tweets with either "crazy" or "fake"
df_trump_subset <- df_trump %>% 
  filter(str_detect(tolower(text), "crazy|fake|nancy")) #str_detect(text, fixed("crazy", ignore_case = TRUE))
nrow(df_trump_subset)

# Add the variables to the data frame
df_trump <- df_trump %>% 
  mutate(crazy = str_detect(text, fixed("crazy", ignore_case = TRUE)),
         fake = str_detect(text, fixed("fake", ignore_case = TRUE)))

# Create a time series plot of the daily share of "crazy" and "fake" over time
df_trump %>% 
  mutate(day = as.Date(date)) %>% 
  group_by(day) %>% 
  summarise(n_tweets = n(),
            sum_crazy = sum(crazy),
            sum_fake = sum(fake),
            share_crazy = sum_crazy / n_tweets,
            share_fake = sum_fake / n_tweets) %>% 
  select(-sum_crazy, -sum_fake, -n_tweets) %>% 
  pivot_longer(-day) %>% 
  ggplot(aes(x = day, y = value, color = name)) +
  geom_point() +
  geom_smooth() 


# YouTube API ----
library(tuber)
# If you want to use this, do your API verification here: 
#https://developers.google.com/youtube/v3/getting-started

#client_id <- "YOUR-CLIENT-ID"
#client_secret <- "YOUR-CLIENT-SECRET"

yt_oauth(
  app_id = client_id,
  app_secret = client_secret
)

#check out the functions in 
#tuber::
get_stats(video_id = "IXDR2-WWY5Y")

get_video_details(video_id = "IXDR2-WWY5Y")

df_yt <- get_comment_threads(c(video_id = "IXDR2-WWY5Y"), max_results = 20)
