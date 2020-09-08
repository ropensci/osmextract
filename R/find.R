#' Get the location of files downloaded by osmextractr
#'
#' This function takes a `place` name and it returns the path of `.pbf` and
#' `.gpkg` files associated with it
#'
#' @details The matching operation between the existing files (downloaded by
#'   osmextract and stored in `oe_download_directory()`) and the input `place`
#'   is performed using a regular expression with a pattern equal to the input
#'   `place`. If the function finds no file associated with the input `place`
#'   and `download` parameter is equal to `TRUE`, then it tries to download and
#'   translate a new file from the chosen provider
#'
#' @param place Description of the geographical area that should be matched with
#'   an existing `.pbf` and `.gpkg` file. Must be a character vector of length
#'   one.
#' @param download Attempt to download the file if it cannot be found?
#' `FALSE` by default.
#' @param download_directory Directory where the files downloaded by osmextract
#'   are stored. By default it is equal to `oe_download_directory()`.
#' @param ... Extra arguments that are passed to `oe_get()` in case `download`
#'   is `TRUE` and the input `place` is matched with no existing file. Please
#'   note that you cannot modify the argument `download_only`.
#' @export
#' @examples
#' res = oe_get("ITS Leeds", provider = "test")
#' oe_find("ITS")
#' oe_find("Isle of Wight")
#' \dontrun{
#' oe_find("Isle of Wight", download = TRUE)}
#' oe_find("Non-existant-place")
oe_find = function(
  place,
  download = FALSE,
  download_directory = oe_download_directory(),
  ...
  ) {

  if (!is.character(place) || length(place) > 1) {
    stop(
      "The input place parameter must be a character vector of length one.",
      call. = FALSE
    )
  }

  downloads = list.files(
    download_directory,
    full.names = TRUE,
    pattern = gsub(" ", "-", place),
    ignore.case = TRUE
  )

  if (length(downloads) > 0) {
    if (length(downloads <= 10)) {
      return(downloads)
    } else {
      message("More than 10 files found. Returning the first 10")
      return(download[1:10])
    }
  }

  message("No file associated with that place name could be found.")
  if (download) {
    message("Trying to download osm data for the place with oe_get()")
    oe_get(place, ..., download_only = TRUE)
  }
}


