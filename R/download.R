#' Download a file given a url
#'
#' This function is used to download a file given a URL. It focuses on OSM
#' extracts with `.osm.pbf` format stored by one of the providers implemented in
#' the package. The URL is specified through the parameter `file_url`.
#'
#' @details This function runs several checks before actually downloading a new
#'   file to avoid overloading the OSM providers. The first step is the
#'   definition of the file path associated to the input `file_url`. The path is
#'   created by pasting together the `download_directory`, the name of chosen
#'   provider (which may be inferred from the URL), and the `basename` of the
#'   URL. For example, if `file_url` is equal to
#'   `"https://download.geofabrik.de/europe/italy-latest.osm.pbf"`, and
#'   `download_directory = "/tmp"`, then the path is built as
#'   `"/tmp/geofabrik_italy-latest.osm.pbf"`. If this file already exists, the
#'   function just returns its path. The parameter `force_download` can be used
#'   to modify this behaviour. If there is no file associated with the new path,
#'   the function downloads it using [httr::GET()]. The timeout for the download
#'   can be modified using `options("timeout")`. The default value is 300s.
#'
#' @inheritParams oe_get
#' @param file_url A URL pointing to a (typically `.osm.pbf`) file.
#' @param provider Which provider stores the file? If `NULL` (the default), the
#'   function tries to infer it. It must be specified for non-standard cases.
#'   See details and examples.
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
#' (its_match = oe_match("ITS Leeds", quiet = TRUE))
#'
#' \dontrun{
#' oe_download(
#'   file_url = its_match$url,
#'   file_size = its_match$file_size,
#'   provider = "test",
#'   download_directory = tempdir()
#' )
#' iow_url = oe_match("Isle of Wight")
#' oe_download(
#'   file_url = iow_url$url,
#'   file_size = iow_url$file_size,
#'   download_directory = tempdir()
#' )
#' Sucre_url = oe_match("Sucre", provider = "bbbike")
#' oe_download(
#'   file_url = Sucre_url$url,
#'   file_size = Sucre_url$file_size,
#'   download_directory = tempdir()
#' )}
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

  if (length(file_url) != 1L) {
    oe_stop(
      .subclass = "oe_download_LengthFileUrlGt2",
      message = paste0(
        "The parameter file_url must have length 1 but you specified ",
        length(file_url),
        " elements."
      ),
    )
  }

  if (is.null(provider)) {
    provider = infer_provider_from_url(file_url)
  }

  file_path = file.path(
    download_directory,
    paste(provider, file_basename, sep = "_")
  )

  # I set winslash = "/" because it helps the printing of the file_path in case
  # there is any error in the next code lines. In fact, "\\" is escaped to "\"
  # when printing and the problem is that I cannot run
  # file.remove("C:/something/..../whatever.osm.pbf") which is exactly the
  # suggestion that may be returned by the tryCatch below
  file_path = normalizePath(file_path, winslash = "/", mustWork = FALSE)

  if (file.exists(file_path) && !isTRUE(force_download)) {
    oe_message(
      "The chosen file was already detected in the download directory. ",
      "Skip downloading.",
      quiet = quiet,
      .subclass = "oe_download_skipDownloading"
    )
    return(file_path)
  }

  continue = 1L
  if (
    interactive() &&
    !is.null(file_size) &&
    !is.na(file_size) &&
    file_size >= max_file_size
  ) { # nocov start
    oe_message(
      "You are trying to download a file from ", file_url, ". ",
      "This is a large file (", round(file_size / 1048576), " MB)!",
      quiet = FALSE,
      .subclass = "oe_download_LargeFile"
    )
    continue = utils::menu(
      choices = c("Yes", "No"),
      title = "Are you sure that you want to download it?"
    )

    # It think it's always useful to see the progress bar for large files
    quiet = FALSE
  } # nocov end

  if (continue != 1L) {
    oe_stop(
      .subclass = "oe_download_AbortedByUser",
      message = "Aborted by user"
    )
  }

  oe_message(
    "Downloading the OSM extract:",
    quiet = quiet,
    .subclass = "oe_download_StartDownloading"
  )

  resp = tryCatch(
    expr = {
      httr::GET(
        url = file_url,
        if (isFALSE(quiet)) httr::progress(),
        # TODO: Add the possibility of using httr::verbose?
        # if (isFALSE(quiet)) httr::verbose(),
        httr::write_disk(file_path, overwrite = TRUE),
        httr::timeout(max(300L, getOption("timeout")))
      )
    },
    error = function(e) {
      oe_stop(
        .subclass = "oe_download_DownloadAborted",
        message = paste0(
          "The download operation was aborted. ",
          "If this was not intentional, you may want to increase the timeout for internet operations ",
          "to a value >= 300 by using options(timeout = ...) before re-running this function. ",
          "We also suggest you to remove the partially downloaded file by running the ",
          "following code (possibly in a new R session): ",
          # NB: Don't add a full stop since that makes copying code really annoying
          "file.remove(", dQuote(file_path, q = FALSE), ")"
        )
      )
    }
  )

  httr::stop_for_status(resp, "download data from the provider")

  oe_message(
    "File downloaded!",
    quiet = quiet,
    .subclass = "oe_download_FileDownloaded"
  )

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
    oe_stop(
      .subclass = "oe_download_CannotInferProviderFromUrl",
      message = "Cannot infer the provider from the url, please specify it."
    )
  }
  matching_provider = regmatches(x = file_url, m = m)
  matching_provider
}
