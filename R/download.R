#' Download a file given a url
#'
#' This function is used to download a file given a URL. It focuses on OSM
#' extracts with `.osm.pbf` format stored by one of the providers implemented in
#' the package. The URL is specified through the parameter `file_url`.
#'
#' @details This function runs several checks before actually downloading a new
#'   file to avoid overloading the OSM providers. The first step is the
#'   definition of the file's path associated to the input `file_url`. The path
#'   is created by pasting together the `download_directory`, the name of chosen
#'   provider (which may be inferred from the URL) and the `basename()` of the
#'   URL. For example, if `file_url` is equal to
#'   `"https://download.geofabrik.de/europe/italy-latest.osm.pbf"`, and
#'   `download_directory = "/tmp"`, then the path is built as
#'   `"/tmp/geofabrik_italy-latest.osm.pbf"`. Thereafter, the function checks
#'   the existence of that file and, if it founds it, then it returns the path.
#'   The parameter `force_download` is used to modify this behaviour. If there
#'   is no file associated with the new path, then the function downloads a new
#'   file using [download.file()] with `mode = "wb"`, and, again, it returns the
#'   path.
#'
#' @inheritParams oe_get
#' @param file_url A URL pointing to a `.osm.pbf` file that should be
#'   downloaded.
#' @param provider Which provider stores the file? If `NULL` (the default), it
#'   may be inferred from the URL, but it must be specified for non-standard
#'   cases. See details and examples.
#' @param file_basename The basename of the file. The default behaviour is to
#'   auto-generate it from the URL using `basename()`.
#' @param file_size How big is the file? Optional. `NA` by default. If it's
#'   bigger than `max_file_size` and the function is run in interactive mode,
#'   then an interactive menu is displayed, asking for permission for
#'   downloading the file.
#'
#' @return A character string representing the file's path.
#' @export
#'
#' @examples
#' its_match = oe_match("ITS Leeds", quiet = TRUE)
#' oe_download(
#'   file_url = its_match$url,
#'   file_size = its_match$file_size,
#'   provider = "test",
#'   download_directory = tempdir()
#' )
#' \dontrun{
#'   iow_url = oe_match("Isle of Wight")
#'   oe_download(
#'     file_url = iow_url$url,
#'     file_size = iow_url$file_size,
#'     download_directory = tempdir()
#'   )
#'   Sucre_url = oe_match("Sucre", provider = "bbbike")
#'   oe_download(
#'     file_url = Sucre_url$url,
#'     file_size = Sucre_url$file_size,
#'     download_directory = tempdir()
#'   )}
#' # Remove .pbf and .gpkg files in tempdir
#' # (since they may interact with other examples)
#' file.remove(list.files(path = tempdir(), pattern = "(pbf|gpkg)", full.names = TRUE))
oe_download = function(
  file_url,
  provider = NULL,
  file_basename = basename(file_url),
  download_directory = oe_download_directory(),
  file_size = NA,
  force_download = FALSE,
  max_file_size = 5e+8, # 5e+8 = 500MB in bytes
  quiet = FALSE
  ) {

  ## At the moment the function works only with a single URL
  if (length(file_url) != 1L) {
    stop(
      "The parameter file_url must have length 1 but you specified ",
      length(file_url),
      " elements."
    )
  }

  ## Try to infer the provider from URL
  if (is.null(provider)) {
    provider = infer_provider_from_url(file_url)
  }

  # We need to build the file_path combining the download_directory,
  # the provider and the file_basename
  file_path = file.path(
    download_directory,
    paste(provider, file_basename, sep = "_")
  )

  # Normalise the file_path
  file_path = normalizePath(file_path, mustWork = FALSE)

  # If the file exists and force_download is FALSE, then raise a message and
  # return the file_path. Otherwise we download it after checking for the
  # file_size.
  if (file.exists(file_path) && !isTRUE(force_download)) {
    oe_message(
      "The chosen file was already detected in the download directory. ",
      "Skip downloading.",
      quiet = quiet
    )
    return(file_path)
  }

  if (!file.exists(file_path) || isTRUE(force_download)) {
    # If working in interactive session and file_size > max_file_size, then we
    # double check if we really want to download the file.
    continue = 1L
    if (
      interactive() &&
      !is.null(file_size) &&
      !is.na(file_size) &&
      file_size >= max_file_size
    ) {
      message("You are trying to download a file from ", file_url)
      message("This is a large file (", round(file_size / 1048576), " MB)!")
      continue = utils::menu(
        choices = c("Yes", "No"),
        title = "Are you sure that you want to download it?"
      )

      # It think it's always useful to see the progress bar for large files
      quiet = FALSE
    }

    if (continue != 1L) {
      stop("Aborted by user.")
    }

    resp = httr::GET(
      url = file_url,
      if (isFALSE(quiet)) httr::progress(),
      # if (isFALSE(quiet)) httr::verbose(),
      httr::write_disk(file_path, overwrite = TRUE),
      httr::timeout(300L)
    )

    httr::stop_for_status(resp, "download data from the provider")

    oe_message("File downloaded!", quiet = quiet)
  }

  file_path
}

# Infer the chosen provider from the file_url
infer_provider_from_url = function(file_url) {
  providers_regex = paste(
    setdiff(oe_available_providers(), "test"),
    collapse = "|"
  )
  m = regexpr(pattern = providers_regex, file_url)
  if (m == -1L) {
    stop("Cannot infer the provider from the url, please specify it.")
  }
  matching_provider = regmatches(x = file_url, m = m)
  matching_provider
}
