#' class: "Computational Social Science and Digital Behavioral Data, University of Mannheim"
#' title: "Validation of text analysis"
#' author: "Sebastian Stier"
#' lesson: 8
#' institute: University of Mannheim & GESIS
#' date: "2024-11-06"

library(quanteda)
library(caret)

# Validation of text classification ----

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

# Rooduijn populism dictionary
dict_rooduijn <- c("elit*",
  "konsens*",
  "undemokratisch*",
  "referend*",
  "korrupt*",
  "propagand*",
  "politiker*",
  "täusch*",
  "betrüg*",
  "betrug*",
  "*verrat*",
  "scham*",
  "schäm*",
  "skandal*",
  "wahrheit*",
  "unfair*",
  "unehrlich*",
  "establishm*",
  "*herrsch*",
  "lüge*")

# Build dictionary using quanteda
pop_dict <- dictionary(list(rooduijn = dict_rooduijn,
                            populism_own = c("elite*", "volk*", "korrupt*", "*deutsch*", "migrat*",
                                             "ausländ*", "flüchtl*", "umwelt")))

# Build dfm and apply dictionary
toks <- corp_ger %>% 
  tokens(remove_punct = TRUE, 
         remove_numbers = TRUE) %>% 
  tokens_select(pattern = c(stopwords("de")), selection = "remove") 
toks %>% 
  dfm() %>% 
  dfm_lookup(pop_dict) %>% 
  convert(to = "data.frame")

# Refine keyword lists
head(kwic(pattern = "*deutsch*", toks, window = 5), 5)
kwic(pattern = "*volk*", toks, window = 5)

# And finally, hand code a paragraph or sentence sample for validation
df_manifesto_paragraphs <- corp_ger %>% 
  corpus_reshape(to = "paragraphs") %>% #sentences
  convert(to = "data.frame")

# Check frequencies
table(df_manifesto_paragraphs$party, df_manifesto_paragraphs$year)

# Assign predictions
corp_parag <- corp_ger %>% 
  corpus_reshape(to = "paragraphs") 
df_manifesto_paragraphs <- corp_parag %>% 
  tokens(remove_punct = TRUE, 
         remove_numbers = TRUE) %>% 
  tokens_select(pattern = c(stopwords("de")), selection = "remove") %>% 
  dfm() %>% 
  dfm_lookup(pop_dict) %>% 
  convert(to = "data.frame")

# Recover the text
df_manifesto_paragraphs$text <- as.character(corp_parag)

# Binary cross-tab of the two dictionaries
tab_class <- table(df_manifesto_paragraphs$rooduijn >= 1, df_manifesto_paragraphs$populism_own >= 1)

# Confusion matrix and F1 scores
confusionMatrix(tab_class, mode = "everything") #bad precision, high recall, not a good F1 score
