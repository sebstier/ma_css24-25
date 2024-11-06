#' class: "Computational Social Science and Digital Behavioral Data, University of Mannheim"
#' title: "Text Analysis, Continued and Validation"
#' author: "Sebastian Stier"
#' lesson: 7
#' institute: University of Mannheim & GESIS
#' date: "2024-10-30"

# Load the required packages
library(tidyverse)
library(quanteda)
library(quanteda.textmodels)
library(quanteda.textstats)
library(quanteda.textplots)


# Wordfish ----
# read in party manifestos of German parties in 2013 and 2017
corp_ger <- read_rds("https://www.dropbox.com/s/uysdoep4unfz3zp/data_corpus_germanifestos.rds?dl=1")
summary(corp_ger)
docvars(corp_ger)

# Remove German stopwords, use only features that occur at least 50 times and create a dfm
dfm_ger <- corp_ger %>% 
  tokens(remove_punct = TRUE, remove_numbers = TRUE, remove_url = TRUE) %>% 
  tokens_select(pattern = stopwords("de"), selection = "remove") %>%
  dfm() %>%
  dfm_trim(min_termfreq = 30)
  
# Run a wordfish
model_wf <- textmodel_wordfish(dfm_ger)
textplot_scale1d(model_wf)


# Wordscores ----
#textmodel_wordscores


# Supervised machine learning ----

# GOAL: we train and evaluate a Naive Bayes classifier

# Download the nytimes dataset from http://www.amber-boydstun.com/supplementary-information-for-making-the-news.html

# Load the dataset into R
df_nyt <- read_csv("data/boydstun_nyt_frontpage_dataset_1996-2006_0_pap2014_recoding_updated2018.csv")

# Let's look up the categories in the codebook -> topics on p. 10
#http://www.amber-boydstun.com/uploads/1/0/6/5/106535199/nyt_front_page_policy_agendas_codebook.pdf

# Inspect the distribution of topics
table(df_nyt$majortopic)

# Create a corpus and an ID
corp_nyt <- df_nyt %>% 
  mutate(text_full = paste(title, summary, sep = " ")) %>% 
  corpus(text_field = "text_full")
corp_nyt$id <- 1:ndoc(corp_nyt)

# Group work: Turn the NY Times dataframe into a dfm and trim the number of features to a manageable size
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

# Create a training-test split
nrow(df_nyt)

# generate the ids for an 80% training sample
set.seed(300)
id_train <- sample(1:nrow(df_nyt), size = nrow(df_nyt)*0.8, replace = FALSE)
length(id_train)

# get training set
dfmat_training <- dfm_subset(dfm, id %in% id_train)

# get test set (documents not in id_train)
dfmat_test <- dfm_subset(dfm, !id %in% id_train)

# Train a Naive Bayes model and evaluate performance
model_nb <- textmodel_nb(dfmat_training, dfmat_training$majortopic)

# Naive Bayes can only take features into consideration that occur both in the training set 
# and the test set
dfmat_matched <- dfm_match(dfmat_test, features = featnames(dfmat_training)) 
# not needed because we did the proprocessing at the top
head(docvars(dfmat_matched))
head(dfmat_matched)

# Check the output
actual_class <- dfmat_matched$majortopic
dfmat_matched$predictions <- predict(model_nb, newdata = dfmat_matched)
tab_class <- table(dfmat_matched$majortopic, dfmat_matched$predictions)
tab_class

# Precision and recall
library(caret)
confusionMatrix(tab_class, mode = "everything")
