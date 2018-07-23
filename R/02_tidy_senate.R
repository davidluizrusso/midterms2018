# 01 -------------------- Load packages
library(tidyverse)
library(data.table)
library(purrrlyr)
library(voteogram)

### 02 -------------------- Set directories
raw_data <- "input/raw"
processed_data <- "input/processed"

### 03 -------------------- Read raw senate data
raw_senate <- data.table::fread(paste(raw_data, "us_senate_raw.csv", sep = "/")) %>%
  dplyr::mutate(sort_name = sapply(strsplit(Incumbent, " "), '[', 1))

### 04 -------------------- Get current party for each senator
senate <- voteogram::roll_call("senate", 115, 2, 162)$votes %>%
  dplyr::select(member_name, sort_name, party, state_abbrev)

### 05 -------------------- Feature engineering
processed_senate <- raw_senate %>%
  dplyr::left_join(dplyr::select(senate, sort_name, party), by = "sort_name") %>%
  dplyr::mutate(party = ifelse(grepl("Cochran", Incumbent), "R", party))

### 06 -------------------- Write processed data to disk
data.table::fwrite(processed_senate, paste(processed_data, "senate.csv", sep = '/'))


