#' class: "Computational Social Science and Digital Behavioral Data, University of Mannheim"
#' title: "Research ethics and web data"
#' author: "Sebastian Stier"
#' lesson: 2
#' institute: University of Mannheim & GESIS
#' date: "2024-02-14"


# Exercise 1: Gapminder explorations ----

library(gapminder)
gapminder <- gapminder # pull the gapminder data to the R environment


# Produce a data frame with the data for Germany and France
gapminder %>% 
    filter(country == "Germany" | country == "France")
    
# How many countries do we have in the data? List them
unique(gapminder$country)


# Arrange the data according to population size, in decreasing order
gapminder %>% 
    arrange(desc(pop))


# Create a dataset with the variables country, year and lifeExp 
gapminder[1:22, 1:4]
gapminder %>% 
    select(country, year, lifeExp) %>% 
    slice(20:30)

# Rename all variables to variable names of your choice
colnames(gapminder)
names(gapminder)
rownames(gapminder)
gapminder %>% 
    rename(gdp_cap = gdpPercap) %>% 
    names()

# Use mutate() to create a new variable where the population size is divided by 1 mil.
range(gapminder$pop)
gapminder %>% 
    mutate(pop_mil = pop/1000000) %>% 
    select(pop_mil, pop)

# group_by() and summarize()

# These two commands are mostly used in combination:
# "group_by" groups columns by a grouping variable
# "summarize" consolidates the mentioned column based on the grouping variable
# into a single row

# Calculate the mean GPD/Capita and population size by continent
gapminder %>% 
    group_by(continent) %>% 
    summarise(mean_gdp_cap = mean(gdpPercap, na.rm = TRUE),
              mean_pop = mean(pop, na.rm = TRUE))


table(gapminder$continent, gapminder$year, useNA = "a")

# Exercise 2: Data visualization in ggplot2 ----
library(ggplot2) # ggplot2 is part of the tidyverse and should already be loaded

# Initializing a plot
ggplot(data = gapminder, aes(x = lifeExp, y = gdpPercap)) +
    geom_point() + 
    geom_smooth(method = "loess")

# Add a fit line (smoothed or linear fit)
ggplot(data = gapminder, aes(x = lifeExp, y = gdpPercap)) +
    geom_point() + 
    geom_smooth(method = "loess")

# Add self-explanatory labs() and show GDP/Capita as logged x axis
gapminder %>% 
    ggplot(aes(x = lifeExp, y = gdpPercap)) +
    geom_point() +
    geom_smooth() +
    scale_y_log10() +
    labs(y = "Life expectancy", x = "GDP per Capita", 
         title = "Relationship between life expectancy and GDP per Capita",
         subtitle = "interesting plot",
         caption = "Data was taken from the gapminder dataset")

plot1 <- gapminder %>% 
    ggplot(aes(x = lifeExp, y = gdpPercap)) +
    geom_point(aes(color = continent)) +
    #ggplot2::scale_y_continuous(limits = c(0, 50)) +
    geom_smooth() + #data = gapminder, aes(x = lifeExp, y = gdpPercap)
    labs(x = "asdf", y = "GDP per Capita", 
         title = "Relationship between life expectancy and GDP per Capita",
         subtitle = "interesting plot",
         caption = "Data was taken from the gapminder dataset") + 
    theme_minimal() +
    theme(legend.position = "bottom", axis.title.x = element_blank(),
          plot.title = element_text(size = 10, hjust = 0.5),
          panel.grid.minor = element_blank()) # the last command overwrite
                                              # the previous specification
    
plot1
?theme

# Save the plot
## hint: ?ggsave
ggsave(plot = plot1, "plots/gdp_lifeExp.png", height = 6, width = 7, bg = "white",
       dpi = 1200)


# Create a bar chart showing the GDP/Capita of European countries in the year 2007
gapminder %>% 
    filter(continent == "Europe" & year == 2007) %>% 
    ggplot(aes(y = gdpPercap, x = reorder(country, gdpPercap,
                                          decreasing = TRUE))) + #?fct_reorder
    geom_col() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))


# Exercise 3: Gapminder and ggplot tasks ----

# 1) Calculate the (worldwide) average GDP per capita per year 
#    and plot this as a bar chart

# 2) Calculate the average life expectancy and the population size 
#    for the year 2007

# 3) Sum the total world population per year. 
#    Plot the results in a bar chart for the years 1992-2007
