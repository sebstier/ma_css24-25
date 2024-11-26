#' class: "Computational Social Science and Digital Behavioral Data, University of Mannheim"
#' title: "Network analysis"
#' author: "Sebastian Stier"
#' lesson: 9
#' institute: University of Mannheim & GESIS
#' date: "2024-11-13"


# How to run a script from R
source("1_data_collection.R") # read_rds("data/youtube_data.rds")
source("2_preprocessing.R")

# Exercise 1: Brief introduction to network analysis ----

# If you're interested in network analysis, please consult David Schoch's materials:
# https://schochastics.github.io/netAnaR2023
# https://github.com/schochastics

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

# Check out the attributes of the nodes/vertices
V(g1)

# Check out the attributes of the edges
E(g1)

# Load example datasets 
data(package = "networkdata") # check out example network datasets 
data("flo_marriage")
data("got") # Game of Thrones dataset

#* Network visualization ----
# Select one of the networks (Game of Thrones season 1)
gotS1 <- got[[1]]

# Compute a clustering for node colors
V(gotS1)$clu <- as.character(membership(cluster_louvain(gotS1)))

# Compute degree as node size
V(gotS1)$size <- degree(gotS1)

# Define a custom color palette
got_palette <- c("#1A5878", "#C44237", "#AD8941", "#E99093",
                 "#50594B", "#8968CD", "#9ACD32")

# Plot
ggraph(gotS1, layout = "stress") +
  geom_edge_link0(aes(edge_linewidth = weight), edge_colour = "grey66") +
  geom_node_point(aes(fill = clu, size = size), shape = 21) +
  geom_node_text(aes(filter = size >= 10, label = name), family = "serif") +
  scale_fill_manual(values = got_palette) +
  scale_edge_width(range = c(0.2, 3)) +
  scale_size(range = c(1, 6)) +
  theme_graph() +
  theme(legend.position = "none")
