
library(tidyverse)
library(sf)
library(plotly)

# Loading functions 
source("ct_maps_functions.R")

# Loading data 
ct_geos <- st_read("ct_geos.shp")
conn_map <- st_read("conn_map.shp")
conn_tbl_full <- read_csv("conn_tbl_full.csv")

# mapping_vars: med_inc, ba_prop, pov_prop
# mapping_levels: county, tract, place


get_ct_map(mapping_var = "all", mapping_level = "tract", higher_level_filter = "fairfield",
           interactive = FALSE) 
