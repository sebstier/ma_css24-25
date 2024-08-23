#' class: "Computational Social Science and Digital Behavioral Data, University of Mannheim"
#' title: "Automated text analysis"
#' author: "Sebastian Stier"
#' lesson: 6
#' institute: University of Mannheim & GESIS
#' date: "2024-04-17"

library(tidyverse)
library(quanteda)

# Set the WD to the folder where the script is located
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Load the Trump tweets
# Read in the file, specifying that "id" is a string, because as numbers 
#the IDs were corrupted
df_trump <- read_csv("data/tweets_01-08-2021.csv", col_types = "ccllcddTl")

# Create a dfm
corp_trump <- corpus(df_trump, text_field = "text", docid_field = "id")

# Subset trump corpus to year 2019
corp_trump_subset <- corpus_subset(corp_trump, date >= "2019-01-01" & date < "2020-01-01")

# Check the date range
range(corp_trump_subset$date)
ndoc(corp_trump_subset)

# Tokenize and create a dfm
toks <- tokens(corp_trump)
toks <- tokens(toks, remove_punct = TRUE, remove_numbers = TRUE)
toks_nostop <- tokens_select(toks, pattern = c(stopwords("en"), "rt"), selection = "remove")
dfm <- dfm(toks_nostop)


# Exercise 1: Text analysis ----
library(quanteda.textmodels)
library(quanteda.textstats)
library(quanteda.textplots)
library(seededlda)

# trim the dfm to make modeling more efficient
dfm
dfm_trimmed <- dfm %>% 
    dfm_trim(min_termfreq = 20)

# inspect all of the features via a helper data frame
feature_table <- as.data.frame(topfeatures(dfm_trimmed, n = 10000))
feature_table$feature <- row.names(feature_table)

#* Frequency counts ----
names(docvars(dfm_trimmed))
feature_table <- textstat_frequency(dfm_trimmed)
nrow(feature_table)
table(feature_table$feature == "nancy")
feature_table_grouped <- textstat_frequency(dfm_trimmed, groups = device)
nrow(feature_table_grouped)
table(feature_table_grouped$feature == "nancy")


#* Dictionary analysis ----
?dictionary
dict <- dictionary(list(fake = c("fake", "fake news"),
                        democrats = c("democr*", "nancy"),
                        republicans = c("repub*", "gop"))
                   )
dfm_dict <- dfm_lookup(dfm, dictionary = dict)
textstat_frequency(dfm_dict)
dfm_dict <- dfm_lookup(dfm, dictionary = dict, nomatch = "n_unmatched") %>% 
    dfm_group(device) 

# Plot on which device Trump talks about democrats and "fakes" 
dfm_dict %>% 
    convert("data.frame") %>%
    dplyr::rename(device = doc_id) %>%
    filter(n_unmatched > 1000) %>% 
    pivot_longer(-c(device, n_unmatched), names_to = "Topic") %>%
    mutate(Share = value / n_unmatched) %>% 
    ggplot(aes(x = device, y = Share, color = Topic, fill = Topic)) +
    geom_bar(stat = "identity") +
    xlab("") +
    ylab("Share of words (%)")

# Let's say we want to construct a dictionary; let's look at kwic
head(kwic(toks, pattern = "nancy"), 10)


#* Keyness analysis ----
dfm_trimmed %>% 
    dfm_group(groups = device) %>% 
    textstat_keyness() %>% 
    textplot_keyness()

# Let's look up the differences between normal tweets and RTs
df_rts <- dfm_trimmed %>% 
    dfm_group(groups = isRetweet) %>% 
    textstat_keyness()


#* LDA topic model (Latent Dirichlet Allocation) ----
tmod_lda <- textmodel_lda(dfm_trimmed, k = 10)
terms(tmod_lda, 10)
df_terms <- terms(tmod_lda, 15)
View(df_terms)

# Assign topic as a new variable
dfm_trimmed$topic <- topics(tmod_lda)

# Cross-table the topic frequency
table(dfm_trimmed$topic)

# Turn dfm into data frame
names(docvars(dfm_trimmed))
test_df <- dfm_trimmed %>% convert("data.frame")


#* Supervised machine learning ----

# GOAL: we train and evaluate a Naive Bayes classifier

# Download the nytimes dataset from http://www.amber-boydstun.com/supplementary-information-for-making-the-news.html

# Load the dataset into R
df_nyt <- read_csv("data/boydstun_nyt_frontpage_dataset_1996-2006_0_pap2014_recoding_updated2018.csv")

# Let's look up the categories in the codebook
#http://www.amber-boydstun.com/uploads/1/0/6/5/106535199/nyt_front_page_policy_agendas_codebook.pdf

# Inspect the distribution of topics
table(df_nyt$majortopic)

# Turn the NY Times dataframe into a dfm and trim the number of features to a manageable size
dfm <- df_nyt %>% 
    mutate(title_summary = paste0(title, " ", summary)) %>% 
    # create a corpus
    corpus(text_field = "title_summary") %>% 
    # create tokens
    tokens(remove_punct = TRUE, remove_numbers = TRUE) %>% 
    tokens_select(pattern = stopwords("en"), selection = "remove") %>% 
    # create a dfm
    dfm() %>% 
    # trim the dfm
    dfm_trim(min_termfreq = 20)
dfm

# Train the model and evaluate performance
table(df_nyt$majortopic)
nrow(df_nyt)
modell.NB <- textmodel_nb(dfm, df_nyt$majortopic, prior = "docfreq")

# Check the output
df_nyt$predictions <- predict(modell.NB)

# Check the distribution of topics in original and predictions
table(df_nyt$majortopic)
table(df_nyt$predictions)
prop.table(table(df_nyt$predictions == df_nyt$majortopic))


