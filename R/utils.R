# Auxiliary functions (not exported)
'%!in%' = function(x, y) !('%in%'(x,y))

# See https://github.com/ITSLeeds/osmextract/issues/134
is_like_url <- function(URL) {
  grepl(
    pattern = "https?:\\/\\/(www\\.)?[-a-zA-Z0-9@:%._\\+~#=]{1,256}\\.[a-zA-Z0-9()]{1,6}\\b([-a-zA-Z0-9()@:%_\\+.~#?&//=]*)",
    x = URL,
    perl = TRUE
  )
}


#' Return the download directory used by the package
#'
#' By default, the download directory is equal to `tempdir()`. You can set a
#' persistent download directory by adding the following command to your
#' `.Renviron` file (e.g. with [usethis::edit_r_environ()]):
#' `OSMEXT_DOWNLOAD_DIRECTORY=/path/to/osm/data`.
#'
#' @return A character vector representing the path for the download directory
#'   used by the package.
#' @export
#'
#' @examples
#' oe_download_directory()
oe_download_directory = function() {
  download_directory = Sys.getenv("OSMEXT_DOWNLOAD_DIRECTORY", "")
  if (download_directory == "") {
    download_directory = tempdir()
  }
  if (!dir.exists(download_directory)) {
    dir.create(download_directory)
  }
  download_directory
}
