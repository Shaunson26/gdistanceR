#' Extract elements from row slot of gDist object
#' 
#' @param row gDist$rows[[ind]]
#' 
#' @return data.frame
extract_elements <- function(row){
  # Row has 1:n elements
  # row$elements[1:n]
  # check for elements?
  element_list <-
    lapply(row$elements, function(element){
      element_unlisted <- unlist(element)
      what = grepl('value|status', names(element_unlisted))
      element_out <- element_unlisted[what]
      names(element_out) <- sub('\\.value', '', names(element_out))
      element_out_df <- as.data.frame(as.list(element_out))
      num_vars <- c("distance","duration", "duration_in_traffic")
      element_out_df$distance = as.numeric(element_out_df$distance) / 1000
      element_out_df$duration = as.numeric(element_out_df$duration) / 60
      element_out_df$duration_in_traffic = as.numeric(element_out_df$duration_in_traffic) / 60
      element_out_df
    })
  do.call(rbind.data.frame, element_list)
}