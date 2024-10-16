#' class: "Computational Social Science and Digital Behavioral Data, University of Mannheim"
#' title: "Automated text analysis"
#' author: "Sebastian Stier"
#' lesson: 5
#' institute: University of Mannheim & GESIS
#' date: "2024-10-16"

library(tidyverse)
library(rvest)

# Exercise 1: Scrape and parse web data ----
# Subset the web tracking data to visits of the politics section of Fox News

# Read the HTML from a Fox News URL
webpage <- read_html(urls)

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

# Use a for loop to create a data frame with the scraped results from all Fox News URLs
# first de-duplicate urls



# Join the htmls with the web tracking data

# Clean the text a little bit
df_fox <- df_fox %>% 
  mutate(body_clean = str_remove(body, "This material may not be published, broadcast, rewritten,\n      or redistributed. ©2024 FOX News Network, LLC. All rights reserved.\n      Quotes displayed in real-time or delayed by at least 15 minutes. Market data provided by\n      Factset. Powered and implemented by\n      FactSet Digital Solutions.\n      Legal Statement. Mutual Fund and ETF data provided by\n      Refinitiv Lipper.")
  )
df_fox$body[5]
df_fox$body_clean[5]


# Exercise 2: Preprocess and prepare text for analysis ----

# Load the tweets from the Trump Twitter Archive
df_trump <- read_csv("data/tweets_01-08-2021.csv", col_types = "ccllcddTl")

# Create a variable "day"

# For more advanced text analysis, install the package quanteda
library(quanteda)

# Create a corpus of Trump tweets 
corp_trump <- corpus(df_trump, text_field = "text", docid_field = "id")
print(corp_trump)
docvars(corp_trump)
summary(corp_trump, 5)

# Subset corpus to tweets in the years 2019 and 2020
range(corp_trump$date)
corp_trump_subset <- corpus_subset(corp_trump, day >= "2019-01-01" & day < "2021-01-01")
range(corp_trump_subset$date)
ndoc(corp_trump_subset)

# Subset corpus to tweets in the year 2020 and that have more than 200.000 retweets

    
# Reshape the corpus from document-level to sentence-level
ndoc(corp_trump_subset)
corp_sentences <- corpus_reshape(corp_trump_subset, to = "sentences")
ndoc(corp_sentences)

head(corp_trump_subset)
head(corp_sentences)

# Count the number of tokens / words for each document
summary(corp_sentences, 5)
summary(corp_trump, 5)
ntoken(corp_sentences)[1:5]
ntoken(corp_trump_subset)[1:5]
corp_sentences$word_count <- ntoken(corp_sentences)
summary(corp_sentences, 5)

# Keep only sentences with at least 5 words


# Next, we need to tokenize a corpus
toks <- tokens(corp_trump_subset)
toks
toks <- tokens(toks, remove_punct = TRUE, remove_numbers = TRUE)
toks
toks_bigrams <- tokens_ngrams(toks, n = 3, concatenator = "_")
toks_bigrams


# Keywords in context
kw_fake <- kwic(toks, pattern =  "democra*", window = 3)
kw_fake
head(kw_fake, 15)

# What does the star do?
test_vec <- c("straße", "straßenverkehrsordnung", "holperstraße", "street", "straßeholper", "straßen")
test_toks <- tokens(test_vec)
kwic(test_toks, pattern = "straße*")
kwic(test_toks, pattern = "*straße*")
kwic(test_toks, pattern = "straße*")

# Even more context
kw_fake2 <- kwic(toks, pattern = c("fake", "democr*"), window = 5)
head(kw_fake2, 15)

# Sometimes we are looking for more than one word 
kw_multiword <- kwic(toks, pattern = phrase(c("fake news", "crazy nancy")))
head(kw_multiword, 15)

# Remove stopwords
stopwords("en")
stopwords("de")
stopwords("it")
stopwords("fr")
stopwords("es")
toks_nostop <- tokens_select(toks, pattern = c(stopwords("en"), "rt"), selection = "remove")

#tokens_remove() different ways to achieve the same goal
toks[6]
toks_nostop[6]

# Create our first document feature matrix (dfm)
dfm_nostop <- dfm(toks_nostop)

# Create a dfm of the full corpus
dfm <- dfm(toks)

# Which are the most frequent words?
dfm_nostop <- dfm(toks_nostop)

# remove stop words and again show the top features
topfeatures(dfm_nostop, 10, decreasing = TRUE)
topfeatures(dfm_nostop, 10, decreasing = FALSE)

head(kwic(toks_nostop, "amp"), 15)

# Use only words that appear at least 10 times
ncol(dfm)
dfm_trimmed <- dfm_trim(dfm_nostop, min_termfreq = 10)
ncol(dfm_trimmed)
ndoc(dfm_trimmed)


# Exercise 3: Run topic models ----
library(quanteda.textmodels)
library(quanteda.textstats)
library(quanteda.textplots)
library(seededlda)

# trim the dfm to make modeling more efficient
dfm_nostop
dfm_trimmed <- dfm_nostop %>% 
  dfm_trim(min_termfreq = 100) # WARNING: this takes at least a few minutes

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



