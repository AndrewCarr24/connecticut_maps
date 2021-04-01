#### Plotting function ####

# Helper function to make plot labels
labelling_helper <- function(lab_values){
  map(lab_values, ~switch(.x, "med_inc" = "Median Income", "ba_prop" = "Proportion College Degree", 
                          "pov_prop" = "Proportion Below Poverty Line")) %>% unlist
}



# Main function - get_ct_map 
# Arguments:
# mapping_var - variable name for shading map subregions
# mapping_level - level of analysis (tract,county,place)
# higher_level_filter (optional) - limit map to higher level region (county)
# interactive (optional) - render an interactive plotly plot 
get_ct_map <- function(mapping_var, mapping_level, higher_level_filter = NA, interactive = FALSE){
  
  geos_tbl <- ct_geos %>% filter(level == mapping_level)
  
  if(mapping_var != "all"){
    census_tbl <- conn_tbl_full
  }else{
    census_tbl <- conn_tbl_full %>% 
      mutate(across(c(-"GISJOIN", -"higher_level"), ~(.x - mean(.x, na.rm=T))/sd(.x, na.rm=T))) %>% 
      pivot_longer(cols = c(-"GISJOIN", -"higher_level"), names_to = "col")
    mapping_var <- "value"
  }
  
  if(!is.na(higher_level_filter)){
    census_tbl <- census_tbl %>% filter(stringr::str_detect(tolower(higher_level), tolower(higher_level_filter)))
  }
  
  core_plt <- geos_tbl %>%
    inner_join(census_tbl, "GISJOIN") %>%
    ggplot()
  
  if(is.na(higher_level_filter)){
    core_plt <- core_plt + geom_sf(data = conn_map)
  }
  
  core_plt <- core_plt + geom_sf(aes(fill = !!rlang::sym(mapping_var), 
                                     text = paste0(name, ": ", round(!!rlang::sym(mapping_var), 2))))
  
  # Labels 
  legend_lab <- labelling_helper(mapping_var)
  
  final_plt <- core_plt + scale_fill_continuous(name = legend_lab, labels = scales::comma)
  
  if(mapping_var == "value"){
    final_plt <- final_plt + facet_wrap(~col, labeller = as_labeller(labelling_helper)) + guides(fill=FALSE)
  }
  
  if(interactive){
    final_plt <- ggplotly(final_plt, tooltip = "text")
    
    # Tooltip Fix for county level
    if(mapping_level == "county"){ final_plt <- final_plt %>% style(hoveron = "fills") }
    
  }
  
  return( final_plt )
  
} %>% suppressWarnings()