#' Convert returned Google Distance Matrix results into a data.frame
#' 
#' @param got_distances object from get_distances()
#' 
#' @export
wrangle_distances <- function(got_distances){
  
  results_list <-
    lapply(seq_along(got_distances$origin_addresses), function(origin_ind){
      
      row_data <- 
        lapply(got_distances$rows[[origin_ind]][[1]], function(row_list){
          sapply(row_list, function(row_item_list) {
            # 'text' .. status
            row_item_list[[1]][1]
          })
        })
      
      row_data <- do.call(rbind, row_data)
      row_data <- as.data.frame(row_data)
      
      tibble::tibble(
        origin = got_distances$origin_addresses[origin_ind],
        destinastion = got_distances$destination_addresses,
        depature_time = got_distances$departure_time,
        row_data
      )
      
    })
  
  out <- do.call(rbind.data.frame, results_list)
  num_vars <- c('distance', 'duration', 'duration_in_traffic')
  
  for(var in num_vars){
    out[, var] <- as.numeric(sub(' .*', '',   out[, var]))
  }
  
  out
  
}
