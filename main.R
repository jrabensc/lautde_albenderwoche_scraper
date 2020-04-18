
# load libraries ----------------------------------------------------------

library(tidyverse)
library(here)

# load functions ----------------------------------------------------------

source("r/fun.R")

# load settings -----------------------------------------------------------

source("r/settings.R")


# create df containing review urls ----------------------------------------

# initialize df

df_url <- tibble(url = character())

# save urls to df

for (i in 1:number_pagination) {
  url <- str_c(base_url, i, sep = "")
  df_url[i,] <- url
}

# scrape alben der woche page ---------------------------------------------

# initialize list

page_list = list()

# call scrape_site function

for (i in 1:number_pagination) {
  data <- scrape_site(i)
  page_list[[i]] <- data
}

# list to df

complete_data <- do.call(rbind, page_list)


# scape review page -------------------------------------------------------

# initialize list

review_list = list()

# call scrape review function

for (i in 1:nrow(complete_data)) {
  data <- scrape_review_site(complete_data$review_url[i])
  review_list[[i]] <- data
}

# list to df

review_data <- do.call(rbind, review_list)

# merge -------------------------------------------------------------------

complete_data_raw <- complete_data %>% 
  left_join(review_data, by = "album_title")

# checks ------------------------------------------------------------------

# get all lines containing >= 1 NA

missings <- complete_data_raw %>% filter_all(any_vars(is.na(.)))

# get all lines containing empty strings

empty <- complete_data_raw %>% filter_all(any_vars(. == ""))

# cleaning ----------------------------------------------------------------

# set empty strings to NA

complete_data <- complete_data_raw %>% na_if("")

# save and export ---------------------------------------------------------

write.csv(complete_data, "data/alben_der_woche.csv", row.names = FALSE)
