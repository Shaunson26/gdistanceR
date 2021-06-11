#' Convert returned Google Distance Matrix results into a data.frame
#' 
#' @param got_distances object from get_distances()
#' 
#' @export
wrangle_distances <- function(got_distances){
  
  if(base::class(got_distances)[1] != 'gDist'){
    stop('got_distances must be of class gDist')
  }
  
  origin_inds <- base::seq_along(got_distances$origin_addresses)
  
  row_data_list <-
    base::lapply(origin_inds, function(origin_ind){
      # rows length = origins
      element_data_df <- extract_elements(got_distances$rows[[origin_ind]])
      tibble::tibble(
        origin = got_distances$origin_addresses[origin_ind],
        destination = got_distances$destination_addresses,
        depature_time = got_distances$departure_time,
        element_data_df
      )
    })
  
  base::do.call(base::rbind.data.frame, row_data_list)
  
}
