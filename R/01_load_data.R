### 01 -------------------- Load packages
library(tidyverse)
library(googlesheets)
library(data.table)

### 02 -------------------- Set directories
raw_data <- "input/raw"

### 03 -------------------- Load data from google sheet

# list all googlesheets in my drive
mysheets <- googlesheets::gs_ls()

# register the 2018 elections predictions google sheet
mt18 <- gs_title("2018 Election Predictions")

us_senate <- mt18 %>%
  gs_read(ws = "U.S. Senate Races")

us_house <- mt18 %>%
  gs_read(ws = "U.S. House Races")

governor <- mt18 %>%
  gs_read(ws = "Gubernatorial Races")

state_leg <- mt18 %>%
  gs_read(ws = "State Legislative Chambers")

### 04 -------------------- Write data to disk
data.table::fwrite(us_senate, paste(raw_data, 'us_senate_raw.csv', sep = "/"))
data.table::fwrite(us_house, paste(raw_data, 'us_house_raw.csv', sep = "/"))
data.table::fwrite(governor, paste(raw_data, 'governor_raw.csv', sep = "/"))
data.table::fwrite(state_leg, paste(raw_data, 'state_legislative_chambers_raw.csv', sep = "/"))

