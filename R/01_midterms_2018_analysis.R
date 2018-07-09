# 01 -------------------- Load packages
library(tidyverse)
library(googlesheets)
library(purrrlyr)
library(voteogram)

# 02 -------------------- Load data from google sheet

# list all googlesheets in my drive
mysheets <- googlesheets::gs_ls()

# register the 2018 elections predictions google sheet
mt18 <- gs_title("2018 Election Predictions")

us_senate <- mt18 %>%
  gs_read(ws = "us senate")

us_house <- mt18 %>%
  gs_read(ws = "us house")

governor <- mt18 %>%
  gs_read(ws = "gubernatorial")

state_leg <- mt18 %>%
  gs_read(ws = "state legislative chambers")

# 03 -------------------- create new columns for each sheet to help with analysis

### US Senate
us_senate_party_map <- data.frame(
  incumbent = us_senate$Incumbent,
  incumbent_party = c("r", "d", "d", "d", "d", 
                      "d", "d", "d", "d", "d", 
                      "d", "d", "d", "r", "r", 
                      "d", "d", "r", "r", "d", 
                      "d", "d", "d", "d", "d", 
                      "d", "r", "r", "r", "d", 
                      "d", "d", "d", "d", "r"),
  stringsAsFactors = FALSE
)

us_senate_new <- us_senate %>%
  dplyr::rename(state = State,
                polls_close_pst = `Polls Close (PST)`,
                incumbent = Incumbent,
                primary = Primary,
                dem_cand = `Democratic Candidate`,
                repub_cand = `Republican Candidate`,
                tyler_pred = `Tyler's Predictions`,
                david_pred = `David's Predictions`) %>%
  dplyr::mutate(result = NA) %>%
  dplyr::left_join(us_senate_party_map, by = c("incumbent")) %>%
  dplyr::mutate(tyler_pred_party_switch = ifelse(tyler_pred == incumbent_party, 0, 1),
                david_pred_party_switch = ifelse(david_pred == incumbent_party, 0, 1),
                tyler_pred_r_to_d = ifelse(tyler_pred == 'd' & incumbent_party == 'r', 1, 0),
                david_pred_r_to_d = ifelse(david_pred == 'd' & incumbent_party ==  'r', 1, 0),
                tyler_pred_d_to_r = ifelse(tyler_pred == 'r' & incumbent_party == 'd', 1, 0),
                david_pred_d_to_r = ifelse(david_pred == 'r' & incumbent_party == 'd', 1, 0))

table(us_senate_new$tyler_pred_r_to_d)
table(us_senate_new$david_pred_r_to_d)
table(us_senate_new$tyler_pred_d_to_r)
table(us_senate_new$david_pred_d_to_r)

### US House
current_house <- voteogram::roll_call("house", 115, 2, 313)$votes

current_congress_party_map <- data.frame(
  congressperson = current_house$member_name,
  house_district = current_house$pp_id,
  current_party = tolower(current_house$party)
)

us_house_new <- us_house %>% 
  dplyr::rename(seat = Seat,
                polls_close_pst = `Polls Close (PST)`,
                incumbent = Incumbent,
                primary = Primary,
                pvi_2017 = `2017 PVI`,
                dem_cand = `Democratic Candidate`,
                repub_cand = `Republican Candidate`,
                tyler_pred = `Tyler's Prediction`,
                david_pred = `David's Prediction`,
                result = Result) %>%
  dplyr::mutate(party_lean = tolower(sapply(strsplit(pvi_2017, '+'), '[', 1)),
                party_lean_magnitute = gsub("(D|R)\\+", "", pvi_2017)) %>%
  dplyr::mutate(seat = gsub("at Large", 1, seat),
                state = trimws(sapply(strsplit(seat, "[0-9]"), '[', 1)),
                district = as.numeric(gsub("[a-z]", "", tolower(seat)))) %>%
  dplyr::mutate(house_district = paste(state.abb[match(state, state.name)], district, sep = "_")) %>%
  dplyr::left_join(dplyr::select(current_congress_party_map, house_district, current_party), by = c("house_district"))


  tidyr::gather(key = "predictor",
                value = "prediction",
                tyler_pred:david_pred)





