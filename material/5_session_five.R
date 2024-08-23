#' class: "Computational Social Science and Digital Behavioral Data, University of Mannheim"
#' title: "Automated text analysis"
#' author: "Sebastian Stier"
#' lesson: 5
#' institute: University of Mannheim & GESIS
#' date: "2024-04-10"

library(tidyverse)

# Set the WD to the folder where the script is located
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Exercise 1: Preprocessing and preparing text for analysis ----

# Download the Trump Twitter Archive

# Download all tweets from the Trump Twitter archive and save the file
# in the folder "data"
# https://drive.google.com/file/d/1xRKHaP-QwACMydlDnyFPEaFdtskJuBa6/view
list.files("data")

# Read in the file, specifying that "id" is a string, because as numbers 
                                                 #the IDs were corrupted
glimpse(df_trump)
df_trump <- read_csv("data/tweets_01-08-2021.csv", col_types = "ccllcddTl")
nrow(df_trump)
n_distinct(df_trump$id)
df_trump <- df_trump %>% 
    mutate(day = as.Date(date))

# Explore New Year's Eve 2019/2020
df_time <- df_trump %>% 
    filter(day == "2019-12-31" | day == "2020-01-01")

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

# Subset corpus to tweets in the year 2020 and that have more than 200.000 retweets
ndoc(corp_trump)
ndoc(corp_trump_subset)
    
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
ndoc(corp_sentences)
corp_trump_subset <- corpus_subset(corp_sentences, word_count >= 5)
ndoc(corp_trump_subset)

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
own_stopwords <- c("der", "die", "das")
toks_nostop <- tokens_select(toks, pattern = c(stopwords("en"), "rt"), selection = "remove")
#toks_nostop <- tokens_select(toks, pattern = own_stopwords, selection = "remove")

#tokens_remove() different ways to achieve the same goal
toks[6]
toks_nostop[6]

# Create our first document feature matrix (dfm)
dfm <- dfm(toks_nostop)

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
dfm_trimmed <- dfm_trim(dfm, min_termfreq = 10)
ncol(dfm_trimmed)
ndoc(dfm_trimmed)

