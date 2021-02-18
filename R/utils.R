# Auxiliary functions (not exported)
'%!in%' = function(x, y) !('%in%'(x,y))

# See https://github.com/ropensci/osmextract/issues/134
is_like_url = function(URL) {
  grepl(
    pattern = "https?:\\/\\/(www\\.)?[-a-zA-Z0-9@:%._\\+~#=]{1,256}\\.[a-zA-Z0-9()]{1,6}\\b([-a-zA-Z0-9()@:%_\\+.~#?&//=]*)",
    x = URL,
    perl = TRUE
  )
}

# Check if the provider argument was passed to the layer argument
check_layer_provider = function(layer, provider) {
  if (layer %in% oe_available_providers()) {
    warning(
      "You set layer = ",
      layer,
      " so you probably passed the provider to the layer argument!",
      call. = FALSE,
      immediate. = TRUE
    )
  }
  invisible(0)
}

#' Return the download directory used by the package
#'
#' By default, the download directory is equal to `tempdir()`. You can set a
#' persistent download directory by adding the following command to your
#' `.Renviron` file (e.g. with `edit_r_environ` function in `usethis` package):
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
  normalizePath(download_directory)
}
