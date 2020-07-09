#' Download the input file
#'
#' Download the input file if it's not already present in the specified download_directory.
#'
#' @inheritParams oe_get
#' @param file_url A
#' @param file_basename B
#' @param file_size E
#' @param verbose TODO
#'
#' @return path
#' @export
#'
#' @examples
#' 1 + 1
oe_download <- function(
  file_url,
  file_basename = basename(file_url),
  provider = infer_provider_from_url(file_url),
  download_directory = oe_download_directory(),
  file_size = NA,
  force_download = FALSE,
  max_file_size = 5e+8, # 5e+8 = 500MB in bytes
  verbose = FALSE
  ) {
  # First we need to build the file_path combining the download_directory,
  # the provider and the file_basename
  file_path <- file.path(download_directory, paste(provider, file_basename, sep = "_"))

  # If the file exists and force_download is FALSE, then raise a message and
  # return the file_path. Otherwise we download it after checking for the
  # file_size.
  if (file.exists(file_path) && !isTRUE(force_download)) {
    if (isTRUE(verbose)) {
      message(
      "The chosen file was already detected in the download directory. ",
      "Skip downloading."
      )
    }
    return(file_path)
  }

  if (!file.exists(file_path) || isTRUE(force_download)) {
    if (interactive() && !is.na(file_size) && file_size >= max_file_size) {
      message("This is a large file (", round(file_size / 1e+6), " MB)!")
      continue <- utils::menu(
        choices = c("Yes", "No"),
        title = "Are you sure that you want to download it?"
      )

      if (continue != 1L) {
        stop("Aborted by user.")
      }
    }

    utils::download.file(
      url = file_url,
      destfile = file_path,
      mode = "wb",
      quiet = !verbose
    )

    if (isTRUE(verbose)) {
      message("File downloaded!")
    }
  }

  file_path
}


# The following function is used to extract the OSMEXT_DOWNLOAD_DIRECTORY
# environment variable.
oe_download_directory <- function() {
  download_directory <- Sys.getenv("OSMEXT_DOWNLOAD_DIRECTORY", "")
  if (download_directory == "") {
    download_directory <- tempdir()
  }
  if (!dir.exists(download_directory)) {
    dir.create(download_directory)
  }
  download_directory
}

# Infer the chosen provider from the file_url
infer_provider_from_url = function(file_url) {
  if (grepl("geofabrik", file_url)) {
    return("geofabrik")
  }
  stop("Cannot infer the provider from the url, please specify it")
}
