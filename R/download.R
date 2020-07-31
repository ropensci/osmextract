#' Download a .osm.pbf file given a url
#'
#' This function is used to download a .osm.pbf file from one of the providers.
#' The url of the file is specified through the parameter `file_url`.
#'
#' @details Firstly, the function generates the path of the file associated to the
#'   input `file_url` using the following convention. The path is created by
#'   pasting the download_directory, the chosen provider and the basename of the
#'   url. So, for example, if `provider = "geofabrik"`, `file_url =
#'   "https://download.geofabrik.de/.../italy-latest.osm.pbf"`, and
#'   `download_directory = "/tmp/`, then the file path is built as
#'   `/tmp/geofabrik_italy-latest.osm.pbf`. Then the function checks that the
#'   file is not already present in the `download_directory`.
#'
#' @inheritParams oe_get
#' @param file_url A URL containing OSM data (e.g. as a .pbf file)
#' @param file_basename The base name of the file. Default behaviour:
#' auto generated from the URL.
#' @param file_size How big is the file? Optional. `NA` by default. If it's
#'   bigger than `max_file_size` and the function is run in interactive mode,
#'   then an interactive menu is displayed, asking for permission for
#'   downloading the file.
#'
#' @return A character string representing the full path of the downloaded file
#' @export
#'
#' @examples
#' its_match = oe_match("ITS Leeds", provider = "test")
#' oe_download(
#'   file_url = its_match$url,
#'   file_size = its_match$file_size,
#'   # for the moment we always need to specify the provider for files
#'   # matched with test provider
#'   provider = "test"
#' )
#' \dontrun{
#' iow_details = oe_match("Isle of Wight")
#' oe_download(
#'   file_url = iow_details$url,
#'   file_size = iow_details$file_size
#' )
#' Sucre_details = oe_match("Sucre", provider = "bbbike")
#' oe_download(
#'   file_url = Sucre_details$url,
#'   file_size = Sucre_details$file_size,
#'   download_directory = tempdir()
#' )
#' }
oe_download = function(
  file_url,
  file_basename = basename(file_url),
  provider = infer_provider_from_url(file_url),
  download_directory = oe_download_directory(),
  file_size = NA,
  force_download = FALSE,
  max_file_size = 5e+8, # 5e+8 = 500MB in bytes
  quiet = TRUE
  ) {
  # First we need to build the file_path combining the download_directory,
  # the provider and the file_basename
  file_path = file.path(download_directory, paste(provider, file_basename, sep = "_"))

  # If the file exists and force_download is FALSE, then raise a message and
  # return the file_path. Otherwise we download it after checking for the
  # file_size.
  if (file.exists(file_path) && !isTRUE(force_download)) {
    if (isFALSE(quiet)) {
      message(
      "The chosen file was already detected in the download directory. ",
      "Skip downloading."
      )
    }
    return(file_path)
  }

  if (!file.exists(file_path) || isTRUE(force_download)) {

    # If working in interactive session and file_size > max_file_size, then we
    # double check if we really want to download the file.
    continue = 1L
    if (interactive() && !is.null(file_size) && !is.na(file_size) && file_size >= max_file_size ) {
      message("This is a large file (", round(file_size / 1e+6), " MB)!")
      continue = utils::menu(
        choices = c("Yes", "No"),
        title = "Are you sure that you want to download it?"
      )
    }
    if (continue != 1L) {
      stop("Aborted by user.")
    }

    utils::download.file(
      url = file_url,
      destfile = file_path,
      mode = "wb",
      quiet = quiet
    )

    if (isFALSE(quiet)) {
      message("File downloaded!")
    }
  }

  file_path
}

# Infer the chosen provider from the file_url
infer_provider_from_url = function(file_url) {
  providers_regex = paste(oe_available_providers(), collapse = "|")
  m = regexpr(pattern = providers_regex, file_url)
  matching_provider = regmatches(x = file_url, m = m)
  if (matching_provider %in% oe_available_providers()) {
    return(matching_provider)
  }
  stop("Cannot infer the provider from the url, please specify it")
}

# :)
