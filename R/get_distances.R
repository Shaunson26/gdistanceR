#' Use the Google Distance Matrix API
#' 
#' The Distance Matrix API is a service that provides travel distance and time 
#' for a matrix of origins and destinations. The API returns information based 
#' on the recommended route between start and end points, as calculated by the 
#' Google Maps API, and consists of rows containing duration and distance values 
#' for each pair.
#' 
#' https://maps.googleapis.com/maps/api/distancematrix/outputFormat?parameters
#' 
#' @param origins character vector. Origin addresses. These are compared to every value in
#' destinations.
#' @param destinations character vector. Destination addresses. These are compared to 
#' every value in origins
#' @param departure_time a datetime (POSIXct) or 'now'. The desired time of departure.
#' @param .api_key google cloud API key. This must be setup and enabled to use the Google distance
#' matrix API.
#' @param .output_format character. The return format from the API call. Either 'json' or 'xml'
#' 
#' @export
get_distances <- function(origins, destinations, departure_time = 'now', .api_key, .output_format = 'json') {
  
  # Check input ----
  
  stopifnot(
    "No API key exists in the environmental variable 'google_api' and none was specified for the .api_key parameter" = Sys.getenv('google_api') != '' & missing(.api_key),
    '.outputFormat can be one of only "json" or "xml"' = .output_format %in% c('json', 'xml'),
    # "departure_time can only be of now or future" = departure_time < Sys.time() & departure_time != 'now',
    'need origins and destinations' = !missing(origins) & !missing(destinations))
  
  # Build query ----
  
  # * Re-parameter departure time to seconds from origin UTC
  if (class(departure_time)[1] == 'POSIXct') {
    
    departure_time_reparm <- 
      difftime(as.POSIXct(format(Sys.time(), tz = 'UTC')), 
               as.POSIXct('1970-01-01 00:00:00 UTC'),
               units = 'secs')
    departure_time_reparm <- as.integer(departure_time_reparm)
    
  } else {
    departure_time_reparm = departure_time
  }
  
  # * Add + to spaces and pipe delimit origins and destinations
  origins <-  paste(gsub(' ', '\\+', origins), collapse = '|')
  destinations <-  paste(gsub(' ', '\\+', destinations), collapse = '|')
  
  
  api_key <- ifelse(missing(.api_key), Sys.getenv('google_api'), .api_key)
  
  root_url <- 
    paste0('https://maps.googleapis.com/maps/api/distancematrix/',
           .output_format, 
           '?')
  
  param_list <-
    list(
      units = 'metric',
      key = api_key,
      mode = 'driving',
      departure_time = departure_time_reparm,
      origins = origins,
      destinations = destinations
    )
  
  param_key_value <-
    sapply(names(param_list), function(name){
      paste0(name, '=', param_list[[name]])
    })
  
  api_url_call <-
    paste0(root_url,
           paste(param_key_value, collapse = '&'))
  
  # Query API ----
  curl_rs <-  url(api_url_call)
  curl_text <- readLines(curl_rs, warn = F)
  close(curl_rs)
  
  curl_list <- jsonlite::fromJSON(curl_text, simplifyVector = T, simplifyDataFrame = F)
  
  # Return results ----
  # * Include departure time
  if (departure_time == 'now') {
    curl_list$departure_time = Sys.time()
  } else {
    curl_list$departure_time = departure_time
  }
  
  class(curl_list) <- c('gDist', class(curl_list))
   
  curl_list
}