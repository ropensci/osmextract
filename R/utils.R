# Auxiliary functions (not exported)
'%!in%' = function(x, y) !('%in%'(x, y))

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
      call. = FALSE
    )
  }
  invisible(0)
}

# Starting from sf 1.0.2, sf::st_read raises a warning message when both layer
# and query arguments are set, while it raises a warning in sf < 1.0.2 when
# there are multiple layers and the layer argument is not set. See also
# https://github.com/r-spatial/sf/issues/1444. The following function is used
# to circumvent this problem and set the appropriate arguments.
my_st_read <- function(dsn, layer, quiet, ...) {
  # See below and read.R for more details on extract_dots_names_safely()
  dots_names = extract_dots_names_safely(...)
  if (utils::packageVersion("sf") <= "1.0.1") {
    sf::st_read(
      dsn = dsn,
      layer = layer,
      quiet = quiet,
      ...
    )
  } else {
    if ("query" %in% dots_names) {
      sf::st_read(
        dsn = dsn,
        quiet = quiet,
        ...
      )
    } else {
      sf::st_read(
        dsn = dsn,
        layer = layer,
        quiet = quiet,
        ...
      )
    }
  }
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
  download_directory = Sys.getenv("OSMEXT_DOWNLOAD_DIRECTORY", tempdir())
  if (!dir.exists(download_directory)) {
    dir.create(download_directory)
  }
  normalizePath(download_directory)
}

# Print a message if quiet argument is FALSE. I defined this function since the
# same pattern is repeated several times in the package.
oe_message <- function(..., quiet) {
  if (isFALSE(quiet)) {
    message(...)
  }
  invisible(0)
}

# Adds additional question to devtools::release(). See Details section in
# ?devtools::release()
release_questions = function() {
  c("Did you check that the original osmconf.ini file was not updated?")
}

# Extract the names in ... safely. I cannot use ...names() since that was
# introduced in R 4.1. I also cannot freely use names(list(...)) since that
# returns an error when there is a missing element in the dotdotdot. For
# example:
# f = function(...) names(list(...))
# f(, )
#
# The function extract_dots_names_safely() returns
# NULL when I run something like
# extract_dots_names_safely("ABC")
# error with
# extract_dots_names_safely(, )
# or
# extract_dots_names_safely("ABC", )
# or
# extract_dots_names_safely(a = "ABC", )
# and "" with
# extract_dots_names_safely(a = "ABC", "DEF")
extract_dots_names_safely <- function(...) {
  if (!...length()) {
    return(NULL)
  }
  tryCatch(
    names(list(...)),
    error = function(cnd) {
      stop_custom(
        .subclass = "osmext-names-dots-error",
        message = "All arguments in oe_get() and oe_read() beside 'place' and 'layer' must be named. Please check that you didn't add an extra comma at the end of your call.",
      )
    }
  )
}

# See https://adv-r.hadley.nz/conditions.html#signalling. Code taken from that
# book (and I think that's possible since the code is released with MIT
# license). The main benefit of this approach is that I can test the class of
# the error instead of the message.
stop_custom <- function(.subclass, message, call = NULL, ...) {
  err <- structure(
    list(
      message = message,
      call = call,
      ...
    ),
    class = c(.subclass, "error", "condition")
  )
  stop(err)
}
