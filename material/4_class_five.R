#' class: "Computational Social Science and Digital Behavioral Data, University of Mannheim"
#' title: "Automated text analysis"
#' author: "Sebastian Stier"
#' lesson: 5
#' institute: University of Mannheim & GESIS
#' date: "2024-10-16"

library(tidyverse)

# Preprocess and prepare text for analysis ----

# Load the tweets from the Trump Twitter Archive
df_trump <- read_csv("data/tweets_01-08-2021.csv", col_types = "ccllcddTl")

# Create a variable "day"
df_trump <- df_trump %>% 
  mutate(day = as.Date(date))

# For more advanced text analysis, install the package quanteda
library(quanteda)

# Create a corpus of Trump tweets 
corp_trump <- corpus(df_trump, text_field = "text", docid_field = "id")
corp_trump
nrow(df_trump)
ncol(df_trump)
docvars(corp_trump)
summary(corp_trump, 5)

# Subset corpus to tweets in the years 2019 and 2020
range(corp_trump$day)

# Identify a specific (but next time we will look at the quanteda way to subset by id)
df_trump %>% 
  filter(id == "1304875170860015617") %>% 
  select(text) %>% 
  as.data.frame()

# Subset a corpus
corp_trump_subset <- corpus_subset(corp_trump, date >= "2019-03-01" & date < "2019-03-30")
range(corp_trump_subset$date)
ndoc(corp_trump_subset)
ndoc(corp_trump)

# Subset corpus to tweets in the year 2020 and that have more than 200.000 retweets
corp_trump_subset <- corpus_subset(corp_trump, day >= "2019-03-01" & retweets > 200000)
ndoc(corp_trump_subset)
    
# Reshape the corpus from document-level to sentence-level
ndoc(corp_trump_subset)
corp_sentences <- corpus_reshape(corp_trump_subset, to = "sentences")
ndoc(corp_sentences)
head(corp_trump_subset)
head(corp_sentences)

# Count the number of tokens / words for each document
ntoken(corp_sentences)[1:5]
ntoken(corp_trump_subset)[1:5]
corp_sentences$word_count <- ntoken(corp_sentences)
summary(corp_sentences, 5)

# Next, we need to tokenize a corpus
toks <- tokens(corp_trump_subset)
toks
toks <- tokens(toks, remove_punct = TRUE, remove_numbers = TRUE)
toks
toks_bigrams <- tokens_ngrams(toks, n = 2, concatenator = "_")
toks_bigrams

# Keywords in context
kw_fake <- kwic(toks, pattern =  "*democra*", window = 4)
kw_fake
head(kw_fake, 15)

# What does the star do?
test_vec <- c("straße", "straßenverkehrsordnung", "holperstraße", "street", "straßeholper", "straßen", 
              "regelverfahrenstraßenbauen")
test_toks <- tokens(test_vec)
kwic(test_toks, pattern = "straße") # only perfect matches
kwic(test_toks, pattern = "straße*") # word ends with straße
kwic(test_toks, pattern = "*straße*") # any match where straße is included
kwic(test_toks, pattern = "*straße") # word starts with straße

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

# Also remove urls
toks_nostop <- tokens(toks_nostop, remove_url = TRUE)

# Create our first document feature matrix (dfm)
dfm_nostop <- dfm(toks_nostop)
print(dfm_nostop, 500)

# Which are the most frequent words?
dfm_nostop <- dfm(toks_nostop)

# Remove stop words and again show the top features
topfeatures(dfm_nostop, 10, decreasing = TRUE)
topfeatures(dfm_nostop, 10, decreasing = FALSE)
