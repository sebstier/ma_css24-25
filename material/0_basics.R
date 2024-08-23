#' class: "Computational Social Science and Digital Behavioral Data, University of Mannheim"
#' title: "Introduction"
#' author: "Sebastian Stier"
#' lesson: 1
#' institute: University of Mannheim & GESIS
#' date: "2023-02-14"


# Base R code snippets ----

#Open a new R script in the top left corner under
#"File -> New File -> R Script"

#This is a comment. It is not executed in the code, but
#serves for documentation purposes

#You can execute code by:
#(a) Copying code into the console below (not recommended!)
#(b) Highlighting code in the script and executing with CTRL/apple-CMD + ENTER
#(c) CTRL/apple-CMD + ENTER executes the line in the script where the
#mouse cursor is located

#The result of the executed script is displayed in the console

#In the top right panel of this window, you can view the structure of the script
#and use it for direct navigation

#The structure was defined by the headings with "#" on the left and "----" on the right


# Mathematical operations ----

# We start with some mathematical operations. R can also be used as a calculator
2 + 2
2 * 2
2 / 2
2 ^ 2
log(2)
2 - 1

# Logical operator, relevant in some applications
1 == 1
1 == 2
1 > 2
1 < 2


# Defining objects ----

# Objects: we work with objects, which are displayed in the top right in the Environment
# Objects can be defined using the arrow "<-"
a <- 1:10
a <- 3 #existing object is overwritten

# Variations in notation
A <-             4 +
          5 

# Spaces are irrelevant --> but consistent use of a single space
# improves readability and minimizes errors

# With "c()" we can assign multiple values to objects
B <- c(1, 2)
B


# Vectors ----

# String/character/text vectors. Important: text must be entered in quotation marks
names_vec1 <- c("michi", "michaela", "peter")
names_vec2 <- c("albert", "fred", "jonny")

# Numeric vectors
numeric_vec <- c(2, 3, 4)
numeric_vec2 <- c(5, 6, 7)

# Vectors of equal length can be added.
numeric_vec + numeric_vec2
names_combined <- c(names_vec1, names_vec2)
names_combined 
numeric_vec_combined <- c(numeric_vec, numeric_vec2)
numeric_vec_combined

# Which class does an object have?
class(names_combined)
class(numeric_vec_combined)
typeof(names_combined)


# Use of first functions ----

# Average of numeric values
numeric_vec_combined
mean(numeric_vec_combined)

# Sum of numeric values
sum(numeric_vec_combined)

# What happens when a function includes an empty value (NA)?
numeric_vec_NA <- c(2, 3, 4, NA)
sum(numeric_vec_NA) # we need to tell the function to ignore NA values
sum(numeric_vec_NA, na.rm = TRUE)
sum(numeric_vec_NA, na.rm = FALSE)
mean(numeric_vec_NA, na.rm = TRUE)

# Get help from within R
?mean # most helpful are "Usage" & "Arguments" at the top and "Examples" at the bottom
?sum


# Data Frames ----

# Vectors of the same length can be combined into a data frame.
df1 <- data.frame(names_vec1, numeric_vec)
df1 <- data.frame(x = names_vec1, y = numeric_vec) # assign names to variables
View(df) # You can inspect data frames in RStudio with View()

# Data Frames can also be inspected in the console below.
# head() only displays the first 6 rows, this function is HIGHLY
# recommended for larger data frames. R can be overwhelmed by printing an entire
# data frame and R might crash.
head(df1, 2) # show first two rows
df1
summary(df1) # statistical summary of the variables


# Inspection of the default data frame "mtcars" ----

# Select the first column and first row (with numeric_vector selection of the column)
mtcars[1, 1]

# Select the first column (dollar operator)
mtcars$mpg

# Select the first two columns
mtcars[ ,1:2]

# Select the first three rows
mtcars[1:3, ]

# Select the first three rows and first three columns
mtcars[1:3, 1:3]


