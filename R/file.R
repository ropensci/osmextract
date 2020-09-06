#' Get the location of files downloaded by osmextractr
#'
#' This function takes a place name and
#'
#' @param download Attempt to download the file if it cannot be found?
#' `FALSE` by default.
#' @inheritParams oe_get
#' @export
#' @examples
#' res = oe_get("ITS", provider = "test", max_string_dist = 9)
#' oe_file("its")
#' oe_file("Isle of Wight")
#' oe_file("Non-existant-place")
oe_file = function(
  place,
  download = FALSE,
  download_directory = oe_download_directory(),
  ...
  ) {
  downloads = list.files(
    download_directory,
    full.names = TRUE,
    pattern = place,
    ignore.case = TRUE
  )
  if(length(downloads) > 0) {
    if(length(downloads <= 10)) {
      return(downloads)
    } else {
      message("More than 10 files found. Returning the first 10")
      return(download[1:10])
    }
  } else {
    message("No file associated with that place name could be found.")
    if(download) {
      message("Trying to download osm data for the place with oe_get()")
      oe_get(place, ..., download_only = TRUE)
    }
  }
}
