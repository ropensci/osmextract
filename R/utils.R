# Auxiliary functions (not exported)
'%!in%' = function(x, y) !('%in%'(x,y))

#' Return the download directory used by the package
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
