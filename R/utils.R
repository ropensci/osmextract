# Auxiliary functions (not exported)
'%!in%' = Negate('%in%')

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

check_version <- function(version, provider) {
  # Currently, the only provider that includes historic data for the OSM
  # extracts is geofabrik.
  if (version != "latest" && provider != "geofabrik") {
    warning(
      "version != 'latest' is only supported for 'geofabrik' provider. ",
      "Overriding it to 'latest'.",
      call. = FALSE
    )
    return("latest")
  }
  version
}
adjust_version_in_url <- function(version, url) {
  if (version == "latest") {
    return(url)
  }
  gsub("latest(?=\\.osm\\.pbf$)", version, url, perl = TRUE)
}


# Starting from sf 1.0.2, sf::st_read raises a warning message when both layer
# and query arguments are set, while it raises a warning in sf < 1.0.2 when
# there are multiple layers and the layer argument is not set. See also
# https://github.com/r-spatial/sf/issues/1444. The following function is used
# to circumvent this problem and set the appropriate arguments.
my_st_read <- function(dsn, layer, quiet, ...) {
  # See below and read.R for more details on extract_dots_names_safely()
  dots_names = extract_dots_names_safely(...)
  if (utils::packageVersion("sf") <= "1.0.1") { # nocov start
    sf::st_read(
      dsn = dsn,
      layer = layer,
      quiet = quiet,
      ...
    )
  } else { # nocov end
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
#' By default, the download directory is equal to `tools::R_user_dir("osmextract", "data")`.
#' You can set a different persistent or temporary download directory by adding
#' the following command to your `.Renviron` file (e.g. with `edit_r_environ`
#' function in `usethis` package): `OSMEXT_DOWNLOAD_DIRECTORY=/path/where/to/save/osm/data`.
#'
#' @return A character vector representing the path for the download directory
#'   used by the package.
#' @export
#'
#' @examples
#' oe_download_directory()
oe_download_directory = function() {
  default_dir = tools::R_user_dir("osmextract", "data")
  download_directory = Sys.getenv("OSMEXT_DOWNLOAD_DIRECTORY", default_dir)
  if (!dir.exists(download_directory)) {
    # recursive = TRUE is required since the output of tools::R_user_dir maybe a
    # directory which is nested inside another missing directory that also must
    # be created.
    dir.create(download_directory, recursive = TRUE) # nocov
  }
  normalizePath(download_directory)
}

# Print a message if quiet argument is FALSE. I defined this function since the
# same pattern is repeated several times in the package.
oe_message <- function(..., quiet, .subclass) {
  if (isFALSE(quiet)) {
    msg <- structure(
      list(message = .makeMessage(..., appendLF = TRUE)),
      class = c(.subclass, "message", "condition")
    )
    message(msg)
  }
  invisible(0)
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
      oe_stop(
        .subclass = "oe_read-namesDotsError",
        message = "All arguments in oe_get() and oe_read() beside 'place' and 'layer' must be named. Please check also that you didn't add an extra comma at the end of your call.",
      )
    }
  )
}

# See https://adv-r.hadley.nz/conditions.html#signalling. Code taken from that
# book (and I think that's possible since the code is released with MIT
# license). The main benefit of this approach is that I can test the class of
# the error instead of the message.
oe_stop <- function(.subclass, message, call = NULL, ...) {
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

#' Clean download directory
#'
#' This functions is a wrapper around `unlink()` that can be used to delete all
#' `.osm.pbf` and `.gpkg` files in a given directory.
#'
#' @param download_directory The directory where the `.osm.pbf` and `.gpkg`
#'   files are saved. Default value is `oe_download_directory()`.
#' @param force Internal option. It can be used to skip the checks run at the
#'   beginning of the function and force the removal of all `pbf`/`gpkg` files.
#'
#' @return The same as `unlink()`.
#' @export
#'
#' @examples
#' # Warning: the following removes all files in oe_download_directory()
#' \dontrun{
#' oe_clean()}
oe_clean <- function(download_directory = oe_download_directory(), force = FALSE) {
  continue = 1L
  if ( # nocov start
    interactive() &&
    !identical(Sys.getenv("TESTTHAT"), "true") &&
    !isTRUE(getOption("knitr.in.progress")) &&
    !force
  ) {
    message(
      "You are going to delete all pbf and gpkg files in ",
      download_directory
    )
    continue = utils::menu(
      choices = c("Yes", "No"),
      title = "Are you sure that you want to proceed?"
    )
  }

  if (continue != 1L) {
    oe_stop(
      .subclass = "oe_clean-aborted",
      message = "Aborted by user"
    )
  } # nocov end

  my_files = list.files(
    path = download_directory,
    pattern = "\\.(osm|osm\\.pbf|gpkg)$",
    full.names = TRUE
  )
  unlink(my_files)
}
