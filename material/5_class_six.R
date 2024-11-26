#' class: "Computational Social Science and Digital Behavioral Data, University of Mannheim"
#' title: "Automated text analysis"
#' author: "Sebastian Stier"
#' lesson: 6
#' institute: University of Mannheim & GESIS
#' date: "2024-10-23"

library(tidyverse)
library(quanteda)

# Exercise 1: Scrape and parse web data ----
library(rvest)

# Load the web tracking data
load("data/toy_browsing.rda") 

# Subset the web tracking data to visits of the politics section of Fox News
df_fox <- toy_browsing %>% 
  filter(str_detect(url, "foxnews.com/politics")) %>%
  as_tibble()
nrow(df_fox)

# Create a vector of unique Fox News political URLs
n_distinct(df_fox$url)
urls <- unique(df_fox$url)

# Read the HTML from a Fox News URL
webpage <- read_html(urls[1])

# Extract the headline (<h1> tag)
headline <- webpage %>%
  html_node("h1") %>%  # Modify the tag based on the website
  html_text()

# Extract the body text (<p> tag for paragraphs)
body <- webpage %>%
  html_nodes("p") %>%  # Modify the tag based on the website structure
  html_text() %>%
  paste(collapse = " ")  # Combine paragraphs into a single text

# Show the results
headline
body

# Inspect the output
cat(body)

# Use a for loop to create a data frame with the scraped results from all Fox News URLs

# create an empty data frame
df_text <- data.frame()
for (i in 1:5) {
  
  # Read the HTML from the page
  webpage = read_html(urls[i])
  
  # Extract the headline (<h1> tag)
  headline = webpage %>%
    html_node("h1") %>%  # Modify the tag based on the website
    html_text()
  
  # Extract the body text (<p> tag for paragraphs)
  body = webpage %>%
    html_nodes("p") %>%  # Modify the tag based on the website structure
    html_text() %>%
    paste(collapse = " ")  # Combine paragraphs into a single text
  
  # Save in data frame
  df_text = df_text %>% 
    bind_rows(
      data.frame(url = urls[i],
                 headline = headline,
                 body = body)
    )
  
}

# Join the htmls with the web tracking data
df_fox <- df_fox %>% 
  left_join(df_text, by = "url")

# Clean the text a little bit
df_fox <- df_text %>% 
  mutate(body_clean = str_remove(body, "This material may not be published, broadcast, rewritten,\n      or redistributed. ©2024 FOX News Network, LLC. All rights reserved.\n      Quotes displayed in real-time or delayed by at least 15 minutes. Market data provided by\n      Factset. Powered and implemented by\n      FactSet Digital Solutions.\n      Legal Statement. Mutual Fund and ETF data provided by\n      Refinitiv Lipper.")
  )
df_fox$body[5]
df_fox$body_clean[5]


# Group exercise: Create a document-feature-matrix from the Trump tweet corpus ----
# First load and preprocess the Trump corpus again
df_trump <- read_csv("data/tweets_01-08-2021.csv", col_types = "ccllcddTl")

# Do all steps in one tidyverse pipe 
# and remove the token "amp"
dfm_nostop <- df_trump %>% 
  corpus(text_field = "text", docid_field = "id") %>% 
  tokens(remove_punct = TRUE, 
         remove_numbers = TRUE) %>% 
  tokens_select(pattern = c("amp", stopwords("en"), "RT"), selection = "remove") %>% 
  dfm()
  
# Inspect
topfeatures(dfm_nostop)

# trim the dfm to only words that appear at least 10 times to make modeling more efficient
dfm_nostop
dfm_trimmed <- dfm_nostop %>% 
  dfm_trim(min_termfreq = 100) 
dfm_trimmed


# Exercise 2: Further text analysis methods ----
library(quanteda.textmodels)
library(quanteda.textstats)
library(quanteda.textplots)

#* Frequency counts ----
# inspect all of the features via a data frame
feature_table <- textstat_frequency(dfm_trimmed) %>% as_tibble()
feature_table
nrow(feature_table)
table(feature_table$feature == "nancy")

# inspect all of the features via a grouped data frame
feature_table_grouped <- textstat_frequency(dfm_trimmed, groups = device)
nrow(feature_table_grouped)
table(feature_table_grouped$feature == "nancy")


#* Dictionary analysis ----
?dictionary
dict <- dictionary(list(fake = c("fake", "fake news"),
                        democrats = c("democr*", "nancy"),
                        republicans = c("repub*", "gop"))
                   )
dfm_dict <- dfm_lookup(dfm_nostop, dictionary = dict)
textstat_frequency(dfm_dict)

# Add a grouping variable and info on the total number of documents
dfm_dict <- dfm_lookup(dfm_nostop, dictionary = dict, 
                       nomatch = "n_unmatched") %>% 
    dfm_group(device) 

#* Keyness analysis ----
# We can easily plot differences in word use by group (e.g., parties, gender, etc.)
dfm_trimmed %>% 
    dfm_group(groups = isRetweet) %>% 
    textstat_keyness() %>% 
    textplot_keyness()


# Exercise 3: Run an LDA Topic Model ----
library(seededlda)

# Restrict the number of features further, otherwise running the LDA will take long
dfm_trimmed <- dfm_nostop %>% 
  dfm_trim(min_termfreq = 50) # only features that appear at least 50 times
dfm_trimmed

# set a seed in order to keep the output consistent
set.seed(111)

# run the LDA Topic Model
tmod_lda <- textmodel_lda(dfm_trimmed, k = 10)
terms(tmod_lda, 10)
df_terms <- terms(tmod_lda, 15)
View(df_terms)

# Assign topic as a new variable
dfm_trimmed$topic <- topics(tmod_lda)

# Cross-table the topic frequency
table(dfm_trimmed$topic)

# Visualize topic model on the web
library(LDAvis)
phi <- tmod_lda$phi  # topic-term distribution
theta <- tmod_lda$theta  # document-topic distribution
vocab <- featnames(dfm_trimmed) # vocabulary
doc_length <- rowSums(dfm_trimmed)  # length of each document
term_frequency <- colSums(dfm_trimmed)  # term frequency

# Create the JSON object for visualization
json <- LDAvis::createJSON(phi = phi, theta = theta, vocab = vocab, 
                           doc.length = doc_length, term.frequency = term_frequency)

# Visualize
LDAvis::serVis(json)


