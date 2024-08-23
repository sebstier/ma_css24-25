#' class: "Computational Social Science and Digital Behavioral Data, University of Mannheim"
#' title: "Some leftover scripts, especially network analysis"
#' author: "Sebastian Stier"
#' lesson: 7
#' institute: University of Mannheim & GESIS
#' date: "2024-05-22"

# Load the package tidyverse
library(tidyverse)

# Set the WD to the folder where the script is located
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Show all used R packages and R version
getS3method("print","sessionInfo")(sessionInfo()[-8])

# Exercise 1: Brief introduction to network analysis ----

# If you're interested in network analysis, please consult David Schoch's materials:
# https://schochastics.github.io/netAnaR2023
# https://github.com/schochastics

# install.packages("remotes")
# library(remotes)
# remotes::install_github("schochastics/networkdata")
library(networkdata)
library(igraph)
library(ggraph)
library(graphlayouts)

# Create our own network / graph
# Adjacency matrix
A <- matrix(c(0, 1, 1, 3, 0, 2, 1, 4, 0),
            nrow = 3, ncol = 3, byrow = TRUE)
rownames(A) <- colnames(A) <- c("Bob", "Ann", "Steve")
A

# Create an igraph object and plot for first inspection
g1 <- graph_from_adjacency_matrix(A, mode = "directed")
g1
plot(g1)

# Load example datasets 
data(package = "networkdata") # check out example network datasets 
data("flo_marriage")
data("got") # Game of Thrones dataset

#* Network visualization ----
# Choose one of the networks (Game of Thrones season 1)
gotS1 <- got[[1]]

# Compute a clustering for node colors
V(gotS1)$clu <- as.character(membership(cluster_louvain(gotS1)))

# Compute degree as node size
V(gotS1)$size <- degree(gotS1)

# Define colors
# define a custom color palette
got_palette <- c("#1A5878", "#C44237", "#AD8941", "#E99093",
                 "#50594B", "#8968CD", "#9ACD32")

# Plot
ggraph(gotS1, layout = "stress") +
    geom_edge_link0(aes(edge_linewidth = weight), edge_colour = "grey66") +
    geom_node_point(aes(fill = clu, size = size), shape = 21) +
    geom_node_text(aes(filter = size >= 26, label = name), family = "serif") +
    scale_fill_manual(values = got_palette) +
    scale_edge_width(range = c(0.2, 3)) +
    scale_size(range = c(1, 6)) +
    theme_graph() +
    theme(legend.position = "none")


# Exercise 2: Text analysis ----

# Load packages
library(quanteda)
library(quanteda.textstats)
library(quanteda.textmodels)
library(quanteda.textplots)

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

# trim the dfm to make modeling more efficient
dfm
dfm_trimmed <- dfm %>% 
    dfm_trim(min_termfreq = 20)

# inspect all of the features via a helper data frame
feature_table <- as.data.frame(topfeatures(dfm_trimmed, n = 10000))
feature_table$feature <- row.names(feature_table)

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
dfm_trimmed %>% 
    dfm_group(groups = isRetweet) %>% 
    textstat_keyness()


# Exercise 3: Recap of data wrangling with some web tracking data ----
list.files("data")
load("data/toy_browsing.rda")
load("data/toy_survey.rda")


# Let's mark the most popular social network sites and search engines

# Count the share of social network sites and search engines among all visits

# Plot a time series of the daily number of visits over time

# Plot a time series of the daily number of visits and unique users over time
# in one plot with two facets/panels

# Calculate for each user the average ideology of her/his website visit


