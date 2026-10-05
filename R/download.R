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
#'   Two further checks guard against working with unusable data. When a file is
#'   already present, its age is reported and `force_download = TRUE` is
#'   suggested once it is older than `options("osmextract.stale_days")` days
#'   (30 by default), since providers do refresh their extracts. When a file is
#'   downloaded, its contents are checked before the function reports success.
#'   Some providers answer a request for a path that does not exist with an HTTP
#'   200 status and a small HTML page, so a success status alone does not mean
#'   the payload is an extract. A file that fails the check is deleted and an
#'   error is raised, rather than being cached and silently reused.
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

    # The following if-clause shouldn't run if we are downloading from an
    # historical fixed extract (such as those available in Geofabrik) which
    # could have been selected using the 'version' argument.
    if (!(provider == "geofabrik" && looks_like_version_url(file_url))) {
      # Test whether the saved file is too old (#329)
      age_days = difftime(Sys.time(), file.mtime(file_path), units = "days")
      stale_days = getOption("osmextract.stale_days", 30)
      if (age_days >= stale_days) {
        warning(
          "Cached file is ", round(age_days), " days old. ",
          "Set force_download = TRUE to refresh it."
        )
      }
    }

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

  # A successful HTML status does not always mean that we downloaded an OSM
  # extract. In some weird cases and server bugs, providers may return invalid
  # data as well as successfully HTML status, possibly after a redirection. See
  # #330 and private email to Geofabrik team.
  if (!is_valid_resp(resp)) {
    file.remove(file_path)
    oe_stop(
      .subclass = "oe_download_InvalidFile",
      message = paste0(
        "The downloaded file is not a valid OSM PBF extract, so it has been ",
        "removed. The provider probably returned a web page or an error ",
        "message instead of data. Check that this URL points to an extract: ",
        file_url
      )
    )
  }

  oe_message(
    "File downloaded!",
    quiet = quiet,
    .subclass = "oe_download_FileDownloaded"
  )

  file_path
}

# Infer the chosen provider from the file_url
infer_provider_from_url = function(file_url) {
  available_providers <- oe_available_providers()

  # The openstreetmap.fr provider is saved as "openstreetmap_fr" but in the URL
  # is specified as openstreetmap.fr. So I need to replace it if relevant.
  if ("openstreetmap_fr" %in% available_providers) {
    available_providers[available_providers == "openstreetmap_fr"] <- "openstreetmap.fr"
  }

  providers_regex = paste(
    setdiff(available_providers, "test"),
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

  # Now replace it back
  if (matching_provider == "openstreetmap.fr") {
    return("openstreetmap_fr")
  }

  matching_provider
}

# Check that the URL of the request (after redirects) corresponds to a
# ".osm.pbf" file. This might be relevant in case the servers silently redirects
# to an "home" page and returns an HTML page. This is especially relevant for
# Geofabrik since, at the moment (Oct 2026) it's the only provider that performs
# a redirection (e.g., "xyz-latest.osm.pbf" --> "xyz-20261005.osm.pbf"). See
# also #330.
is_valid_resp = function(resp) {
  # According to httr docs, the url field of the response includes the url the
  # request was actually sent to (after redirects). We need to check whether
  # such URL points to a .osm.pbf file.
  url <- resp[["url"]]

  # Something weird happened, so better safe than sorry
  if (is.null(url)) {
    return(FALSE)
  }

  grepl("\\.osm\\.pbf$", url, perl = TRUE)
}

# Historical .osm.pbf files specified on geofabrik servers are something like
# "https://download.geofabrik.de/antarctica-140101-free.shp.zip"
looks_like_version_url <- function(x) {
  grepl("-\\d{6}\\.osm\\.pbf$", x, perl = TRUE)
}
