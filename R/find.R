#' Get the path of .pbf and .gpkg files associated with an input OSM extract
#'
#' This function takes a `place` name and returns the path of `.pbf`/`.gpkg`
#' files associated with it.
#'
#' @details The matching between the existing files (saved in the directory
#'   specified by `download_directory` parameter) and the input `place` is
#'   performed using `list.files()`, setting the `pattern` equal to the basename
#'   of the URL associated to the input `place`. For example, if you specify
#'   `place = "Isle of Wight"`, then the input is matched (via [`oe_match()`])
#'   with the URL of Isle of Wight's `.osm.pbf` file, and the files are selected
#'   using a pattern equal to the basename of that URL.
#'
#'   If there is no file in the `download_directory` that can be matched with the
#'   basename of the URL and `download_if_missing` parameter is equal to `TRUE`, then the
#'   function tries to download and read a new file from the chosen
#'   provider (`geofabrik` is the default provider). If `download_if_missing`
#'   parameter is equal to `FALSE` (default value), then the function stops with
#'   an error.
#'
#'   By default, this function returns the path of `.pbf` and `.gpkg` files
#'   associated with the input place (if any). You can exclude one of the two
#'   formats setting the arguments `return_pbf` or `return_gpkg` to `FALSE`.
#'
#' @param download_directory Directory where the files downloaded by osmextract
#'   are stored. By default it is equal to [`oe_download_directory()`].
#' @param download_if_missing Attempt to download the file if it cannot be
#'   found? `FALSE` by default.
#' @param return_pbf Logical of length 1. If `TRUE`, the function returns the
#'   path of the pbf file that matches the input `place`.
#' @param return_gpkg Logical of length 1. If `TRUE`, the function returns the
#'   path of the gpkg file that matches the input `place`.
#' @param ... Extra arguments that are passed to [`oe_match()`] and [`oe_get()`].
#'   Please note that you cannot modify the argument `download_only`.
#' @inheritParams oe_get
#'
#' @return A character vector of length one (or two) representing the path(s) of the
#'   `.pbf`/`.gpkg` files associated with the input `place`.
#'
#' @export
#' @examples
#' # Copy the ITS file to tempdir() to make sure that the examples do not
#' # require internet connection. You can skip the next 4 lines (and start
#' # directly with oe_get_keys) when running the examples locally.
#'
#' res = file.copy(
#'   from = system.file("its-example.osm.pbf", package = "osmextract"),
#'   to = file.path(tempdir(), "test_its-example.osm.pbf"),
#'   overwrite = TRUE
#' )
#' res = oe_get("ITS Leeds", quiet = TRUE, download_directory = tempdir())
#' oe_find("ITS Leeds", provider = "test", download_directory = tempdir())
#' oe_find(
#'   "ITS Leeds", provider = "test",
#'   download_directory = tempdir(), return_gpkg = FALSE
#' )
#'
#' \dontrun{
#' oe_find("Isle of Wight", download_directory = tempdir())
#' oe_find("Malta", download_if_missing = TRUE, download_directory = tempdir())
#' oe_find(
#'   "Leeds",
#'   provider = "bbbike",
#'   download_if_missing = TRUE,
#'   download_directory = tempdir()
#' )}
#'
#' # Remove .pbf and .gpkg files in tempdir
#' oe_clean(tempdir())
oe_find = function(
  place,
  provider = "geofabrik",
  download_directory = oe_download_directory(),
  download_if_missing = FALSE,
  return_pbf = TRUE,
  return_gpkg = TRUE,
  quiet = FALSE,
  ...
  ) {
  if (!return_gpkg && !return_pbf) {
    stop(
      "At least one of 'return_pbf' and 'return_gpkg' arguments must be ",
      "equal to TRUE.",
      call. = FALSE
    )
  }

  # I decided the approach described in @details since I cannot simply use
  # list.files(pattern = place) because the names of the files could be
  # different from the input place. Check
  # https://github.com/ropensci/osmextract/pull/123 to see the approach
  # originally adopted.

  # First I need to match the input place with a URL
  matched_place = oe_match(place, provider = provider, quiet = quiet, ...)
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

  pattern <- if (return_pbf && return_gpkg) {
    paste0(pattern, "\\.(osm\\.pbf|gpkg)$")
  } else if (return_pbf) {
    paste0(pattern, "\\.osm\\.pbf$")
  } else {
    paste0(pattern, "\\.gpkg$")
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
    oe_message(
      "No file associated with that place name could be found.\n",
      "Trying to download osm data with oe_get().",
      quiet = quiet
    )
    oe_get(
      place,
      download_directory = download_directory,
      provider = provider,
      download_only = TRUE,
      quiet = quiet,
      ...
    )
    return(
      oe_find(
        place,
        provider = provider,
        download_directory = download_directory,
        download_if_missing = FALSE,
        quiet = quiet,
        ...
      )
    )
  }

  stop(
    "No file associated with that place name could be found.",
    call. = FALSE
  )
}
