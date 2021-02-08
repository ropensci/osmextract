#' Get the location of files
#'
#' This function takes a `place` name and it returns the path of `.pbf` and
#' `.gpkg` files associated with it.
#'
#' @details The matching between the existing files (saved in a directory
#'   specified by `download_directory` parameter) and the input `place` is
#'   performed using `list.files`, setting a pattern equal to the basename of
#'   the URL associated to the input `place`. For example, if you specify
#'   `place = "Isle of Wight"`, then the input `place` is matched with a URL of
#'   a `.osm.pbf` file (via [`oe_match()`]) and the matching is performed setting a
#'   pattern equal to the basename of that URL.
#'
#'   If there is no file in `download_directory` that can be matched with the
#'   basename and `download_if_missing` parameter is equal to `TRUE`, then the
#'   function tries to download and translate a new file from the chosen
#'   provider (`geofabrik` is the default provider). If `download_if_missing`
#'   parameter is equal to `FALSE` (default value), then the function stops with
#'   an error.
#'
#' @param download_directory Directory where the files downloaded by osmextract
#'   are stored. By default it is equal to [`oe_download_directory()`].
#' @param download_if_missing Attempt to download the file if it cannot be
#'   found? `FALSE` by default.
#' @param ... Extra arguments that are passed to [`oe_match()`] and [`oe_get()`].
#'   Please note that you cannot modify the argument `download_only`.
#' @inheritParams oe_get
#'
#' @return A character vector of length one (or two) representing the path(s) of the
#'   corresponding `.pbf` (and `.gpkg`) files.
#' @export
#' @examples
#' res = oe_get("ITS Leeds", provider = "test")
#' oe_find("ITS Leeds", provider = "test")
#' \dontrun{
#' oe_find("Isle of Wight")
#' oe_find("Isle of Wight", download_if_missing = TRUE)
#' oe_find("Leeds", provider = "bbbike", download_if_missing = TRUE)}
oe_find = function(
  place,
  provider = "geofabrik",
  download_directory = oe_download_directory(),
  download_if_missing = FALSE,
  ...
  ) {
  # I decided the approach described in @details since I cannot simply use
  # list.files(pattern = place) because the names of the files could be
  # different from the input place.
  # See https://github.com/ropensci/osmextract/pull/123 to check the original
  # approach adopted with the code.

  # First I need to match the input place with a URL
  matched_place = oe_match(place, provider = provider, ...)
  matched_URL = matched_place[["url"]]

  # Then I extract from the URL the file name
  if (tools::file_ext(tools::file_path_sans_ext(matched_URL)) == "osm") {
  # I need the double file_path_san_ext to cancel the .osm and the .pbf
    pattern = tools::file_path_sans_ext(
      tools::file_path_sans_ext(basename(matched_URL))
    )
  } else {
    pattern = tools::file_path_sans_ext(basename(matched_URL))
  }

  # Extract the files that match the pattern
  downloads = list.files(
    download_directory,
    full.names = TRUE,
    pattern = pattern,
    ignore.case = TRUE
  )

  # Return the matched paths (if any)
  if (length(downloads) > 0) {
    return(downloads)
  }

  if (download_if_missing) {
    message(
      "No file associated with that place name could be found.\n",
      "Trying to download osm data with oe_get()."
      )
    oe_get(
      place,
      download_directory = download_directory,
      provider = provider,
      download_only = TRUE,
      ...
    )
    return(
      oe_find(
        place,
        provider = provider,
        download_directory = download_directory,
        download_if_missing = FALSE,
        ...
      )
    )
  }

  stop(
    "No file associated with that place name could be found.",
    call. = FALSE
  )
}


