# Description - The initial stage of this app is to display a reactive version of some of the work done previously surrounding unscheduled care data.
# this section includes the non-reactive elements and everything used by both the
# UI and Server sides: functions, packages, data, etc.


## Test commentary


############################.
##Packages ----
############################.
library(shiny)
library(shinydashboard)
library(plotly)
library(tidyverse)
library(reshape2)
library(janitor)
library(webshot) 
library(htmlwidgets)
library(htmltools)
library(lubridate)
library(readxl)
library(writexl)
#library(xlsx)
library(DT)
library(viridis)
library(leaflet)
library(shinyBS)
###############################################.
## Functions ----
###############################################.  

###############################################.
## Palettes ----
###############################################.   

###############################################.
## Data ----

setwd("/conf/LIST_analytics/West Hub/02 - Scaled Up Work/COVID-19/HSCP Portal_Dashboard/UC_HSCP app/HSCP_Portal/")
source_list <- list("A&E Cases" = "A&E", 
                    "Emergency Admissions" = "EA",
                              "NHS24 Records" = "NHS24",
                              "GP OOH Cases" = "OOH",
                              "Scottish Ambulance Service Records" = "SAS")

measure_list <- list("Total cases" = "cases",
                     "Rate (per 1,000 population)" = "rate",
                     "Annual change (%)" = "change")

##########    Generic data files which include app date limits, location lookups and population lookups ##########

##### Date limits #####
start_date <- as.Date("01-03-2020", format = "%d-%m-%Y")
end_date <- as.Date("28-06-2020", format = "%d-%m-%Y")


## IZ Boundaries
iz_bounds <- readRDS("data/IZ_boundary.rds")


## IZ Populations
int_pops <- read.csv("data/IntermediateZonePopulations_2019.csv")

## Data
#iz <- read.csv("data/2020_data/UCdata-week-iz.csv")
iz <- readRDS("data/extract.UC.IZ.rds")

#hscp <- read.csv("data/2020_data/UCdata-week-hscp.csv")
hscp <- readRDS("data/extract.UC.HSCP.rds")
hscp$year <- as.factor(hscp$year)

###########  Monthly data sets ##########################
iz.m <- readRDS("data/extract.UC.IZ.M.rds")
hscp.m <- readRDS("data/extract.UC.HSCP.M.rds")
hscp.m$year <- as.factor(hscp.m$year)

####################### load in data set with possion exact intervals ###########################################
pois_dt <- readRDS("data/pois_dt.rds")

r.m = 1000
alpha = 0.002




##### Location lookup #####
# read in postcode directory file to establish lat & long of patients 
# postcode_lookup <- read.csv('/conf/linkage/output/lookups/Unicode/Geography/Scottish Postcode Directory/Scottish_Postcode_Directory_2020_1.csv',
#                             stringsAsFactors=F) %>%
#   clean_names() %>%
#   select(pc8, hb2019, latitude, longitude, hscp2019) %>%
#   rename(pat_postcode = "pc8") %>%
#   rename(hb_res = "hb2019")
# postcode_lookup$pat_postcode <- gsub(" ", "", postcode_lookup$pat_postcode)

##### END OF LOCATION LOOKUP #####

##### NHS24 data extract 1 #####
# d1 <- read_xlsx('//conf/LIST_analytics/Glasgow City/COVID19/UC/02-data/extracts/NHS24extract.xlsx',
#                 sheet = "NHS24extract") %>%
#   clean_names() %>%
#   rename(hb = "reporting_health_board_name_current") %>%
#   rename(date = "nhs_24_call_rcvd_date") %>%
#   rename(total_cases = "number_of_nhs_24_records_4") %>%
#   rename(covid_cases = "number_of_nhs_24_records_5") %>%
#   mutate(date = as.Date(date))
# 
# 
# d1$hb[d1$hb == "NHS AYRSHIRE & ARRAN"] = "AA"
# d1$hb[d1$hb == "NHS BORDERS"] = "BORDERS"
# d1$hb[d1$hb == "NHS DUMFRIES & GALLOWAY"] = "D.G"
# d1$hb[d1$hb == "NHS FIFE" ] = "FIFE"
# d1$hb[d1$hb == "NHS FORTH VALLEY"  ] = "FV"
# d1$hb[d1$hb == "NHS GRAMPIAN"] = "GRAMPIAN"
# d1$hb[d1$hb == "NHS GREATER GLASGOW & CLYDE"] = "GG.C"
# d1$hb[d1$hb == "NHS HIGHLAND" ] = "HIGHLAND"
# d1$hb[d1$hb == "NHS LANARKSHIRE"  ] = "LANARKSHIRE"
# d1$hb[d1$hb == "NHS LOTHIAN"] = "LOTHIAN"
# d1$hb[d1$hb == "NHS ORKNEY"  ] = "ORKNEY"
# d1$hb[d1$hb == "NHS SHETLAND" ] = "SHETLAND"
# d1$hb[d1$hb == "NHS TAYSIDE"] = "TAYSIDE"
# d1$hb[d1$hb == "NHS WESTERN ISLES"] = "WI"
# 
# nhs24 <- d1 %>%
#   group_by(hb, date) %>%
#   summarise(total_cases = sum(total_cases),
#             covid_cases = sum(covid_cases)) %>%
#   ungroup() %>%
#   filter(date %within% interval(start_date, end_date)) %>%
#   pivot_longer(cols = 3:4, names_to = "case_type", values_to = "count") %>%
#   pivot_wider(names_from = hb, values_from =count) %>%
#   mutate(date = as.Date(as.character(date), format = "%Y-%m-%d")) %>%
#   data.frame()
# #nhs24$count[is.na(nhs24$count)] = 0
# #nhs24$date <- as_date(nhs24$date) 
# 
# write.csv(nhs24, file=gzfile("data/nhs24.csv.gz", compression = 9), row.names = FALSE)

##### end of nhs 24 extract #####

##### Data build - daily data used ofr UC Impact Dashboard - includes Nnhs24, ecoss, gp ooh, sas, ae, ea data #####

#d1 <- read.csv('data/UCdata-day.csv') %>%
#  clean_names() #%>%
  # rename(hb = "reporting_health_board_name_current") %>%
  # rename(date = "nhs_24_call_rcvd_date") %>%
  # rename(total_cases = "number_of_nhs_24_records_4") %>%
  # rename(covid_cases = "number_of_nhs_24_records_5") %>%
  # mutate(date = as.Date(date))

# Tooltip text

# Summary

measure_tooltip_s <- bsTooltip("select_indsummary", "Total cases: Number of cases per month<br/>
                               Rate: Rate of cases per 1,000 population<br/>Annual change (%): % change from the previous year",
                             "right", options = list(container = "body"))
time_tooltip_s <- bsTooltip("timeframesummary", "March to July", options = list(container = "body"))

loc_tooltip_s <- bsTooltip("selectHSCPsummary", "Select Health and Social Care Partnership", options = list(container = "body"))

# Data explorer

measure_tooltip_d <- bsTooltip("select_ind", "Total cases: Number of cases per month<br/> Rate: Rate of cases per 1,000 population<br/>Annual change (%): % change from the previous year",
                             "right", options = list(container = "body"))
time_tooltip_d <- bsTooltip("timeframe", "Months March to July.<br/> To see monthly transitions, move slider to one month period.", options = list(container = "body"))

loc_tooltip_d <- bsTooltip("selectHSCP", "Select Health and Social Care Partnership", options = list(container = "body"))

service_tooltip_d <- bsTooltip("select_service", "Select unscheduled care service from drop down", options = list(container = "body"))


## END
