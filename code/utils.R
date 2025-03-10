library("tidyverse")
get_actor_region <- function(data) {
  data <- data |>
    mutate(
      actor_region = str_extract(actor1, "\\(.*?\\)"),  
      actor_region = gsub("\\(|\\)", "", actor_region), 
      actor_region = str_squish(actor_region),         
      actor_region = if_else(str_detect(actor_region, "\\d"), NA_character_, actor_region),  
      actor1 = gsub("\\(.*?\\)", "", actor1)  
    )
  
  return(data)
}


widened_actor1 <- function(data) {
  data <- data |>
    mutate(civilian_targeting = !is.na(civilian_targeting)) |>
    group_by(event_id_cnty) |>
    mutate(actor = paste0("actor", seq_len(length(event_id_cnty)))) |>
    ungroup() |>
    pivot_wider(names_from = actor, values_from = actor1)
  
  return(data)
}


del_actor_regi <- function(data) {
  
  data <- data |>
    mutate(
      actor1 = gsub("\\(.*?\\)", "", actor1)
    )
  
  return(data)
}



get_actor_cate <- function(data) {
  
  data <- data |>
    mutate(
      actor1 = gsub("\\(.*?\\)", "", actor1),
      
      actor_category = case_when(
        # State forces: include "Military Forces" / "Police Forces"
        str_detect(actor1, regex("Military Forces|Police Forces", ignore_case = TRUE)) ~ "State forces",
        # Rebel groups: include "Rebel"
        str_detect(actor1, regex("Rebel", ignore_case = TRUE)) ~ "Rebel group",
        # Identity militias: contains "militia" + identity-related keywords
        str_detect(actor1, regex("militia", ignore_case = TRUE)) &
          str_detect(actor1, regex("tribal|communal|ethnic|clan|religious|caste", ignore_case = TRUE)) ~ "Identity militia",
        # Political militias: contains "militia" (but not flagged as identity militias)
        str_detect(actor1, regex("militia", ignore_case = TRUE)) ~ "Political militia",
        # Rioters
        str_detect(actor1, regex("Rioters", ignore_case = TRUE)) ~ "Rioters",
        # Protesters
        str_detect(actor1, regex("Protesters", ignore_case = TRUE)) ~ "Protesters",
        # Civilians
        str_detect(actor1, regex("Civilians", ignore_case = TRUE)) ~ "Civilians",
        # External/Other forces
        str_detect(actor1, regex("External|Other forces", ignore_case = TRUE)) ~ "External/Other forces",
        
        
        # Otherwise, NA
        TRUE ~ NA_character_
      ),
      actor_category = gsub(":.*","",actor_category)
    )
  
  return(data)
}


get_actor_cate2 <- function(data) {
  
  data <- data |>
    mutate(
      actor2 = gsub("\\(.*?\\)", "", actor2),
      
      actor_category2 = case_when(
        # State forces: include "Military Forces" / "Police Forces"
        str_detect(actor2, regex("Military Forces|Police Forces", ignore_case = TRUE)) ~ "State forces",
        # Rebel groups: include "Rebel"
        str_detect(actor2, regex("Rebel", ignore_case = TRUE)) ~ "Rebel group",
        # Identity militias: contains "militia" + identity-related keywords
        str_detect(actor2, regex("militia", ignore_case = TRUE)) &
          str_detect(actor2, regex("tribal|communal|ethnic|clan|religious|caste", ignore_case = TRUE)) ~ "Identity militia",
        # Political militias: contains "militia" (but not flagged as identity militias)
        str_detect(actor2, regex("militia", ignore_case = TRUE)) ~ "Political militia",
        # Rioters
        str_detect(actor2, regex("Rioters", ignore_case = TRUE)) ~ "Rioters",
        # Protesters
        str_detect(actor2, regex("Protesters", ignore_case = TRUE)) ~ "Protesters",
        # Civilians
        str_detect(actor2, regex("Civilians", ignore_case = TRUE)) ~ "Civilians",
        # External/Other forces
        str_detect(actor2, regex("External|Other forces", ignore_case = TRUE)) ~ "External/Other forces",
        
        # Otherwise, NA
        TRUE ~ NA_character_
      ),
      actor_category2 = gsub(":.*","",actor_category2),
    )
  
  return(data)
}



# 
# str_detect(actor1, regex("Islamic State West Africa Province|Boko Haram", ignore_case = TRUE)) ~ "ISWAP and/or Boko Haram",
# 
# str_detect(actor1, regex("Islamic State West Africa Province", ignore_case = TRUE)) ~ "ISWAP",
# 
# str_detect(actor1, regex("Unidentified Armed Group", ignore_case = TRUE)) ~ "Unidentified",
# 






longer_source_scale <- function(data) {
  data <- data |>
    
    
    separate(source_scale, into = c("source_scale1", "source_scale2"), sep = "-", fill = "right") |>
    pivot_longer(cols = c("source_scale1","source_scale2"), 
                 names_to = "source_scale_type", 
                 values_to = "source_scale") |>
    drop_na(source_scale) |>
    select(-source_scale_type)
  
  return(data)
}
