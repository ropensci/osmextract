#' Title
#'
#' @param file_url A
#' @param file_basename B
#' @param provider C
#' @param download_directory D
#' @param file_size E
#' @param force_download F
#' @param max_file_size G
#' @param verbose H
#'
#' @return ch
#' @export
#'
#' @examples
#' 1 + 1
osmext_download <- function(
  file_url,
  file_basename = basename(file_url),
  provider = "geofabrik",
  download_directory = osmext_download_directory(),
  file_size = NA,
  force_download = FALSE,
  max_file_size = 5e+8, # 5e+8 = 500MB in bytes
  verbose = FALSE
  ) {
  # First we need to build the file_path combining the download_directory,
  # the provider and the file_basename
  file_path <- file.path(download_directory, paste(provider, file_basename, sep = "_"))

  # If the file exists and force_download == FALSE, then raise a message and
  # return the file_path. Otherwise we download it after checking for the
  # file_size.
  if (file.exists(file_path) && !force_download) {
    if (verbose) {
      message(
      "The chosen file is already detected in the download_directory. ",
      "Skip downloading."
      )
    }
    return(file_path)
  }

  if (!file.exists(file_path) || force_download) {
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

    if (verbose) {
      message("Just finished downloading the pbf file!")
    }
  }

  file_path
}


# The following function is used to extract the OSMEXT_DOWNLOAD_DIRECTORY
# environment variable.
osmext_download_directory <- function() {
  download_directory <- Sys.getenv("OSMEXT_DOWNLOAD_DIRECTORY", "")
  if (download_directory == "") {
    download_directory <- tempdir()
  }
  if (!dir.exists(download_directory)) {
    dir.create(download_directory)
  }
  download_directory
}
