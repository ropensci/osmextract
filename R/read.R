#' Read a .pbf or .gpkg object from file or url
#'
#' This function is used to read a `.pbf` or `.gpkg` object from file or URL. It
#' is a wrapper around [oe_download()], [oe_vectortranslate()], and
#' [sf::st_read()], creating an easy way to download, convert, and read a `.pbf`
#' or `.gpkg` file. Check the introductory vignette and the help pages of the
#' wrapped function for more details.
#'
#' @details The arguments `provider`, `download_directory`, `file_size`,
#'   `force_download`, and `max_file_size` are ignored if `file_path` points to
#'   an existing `.pbf` or `.gpkg` file.
#'
#'   Please note that you cannot add any field to an existing `.gpkg` file using
#'   the argument `extra_tags` without rerunning the vectortranslate process on
#'   the corresponding `.pbf` file. On the other hand, you can extract some of
#'   the tags in `other_tags` field as new columns. See examples and
#'   [oe_get_keys()] for more details.
#'
#' @inheritParams oe_get
#' @param file_path A URL or the path to a `.pbf` or `.gpkg` file. If a URL,
#'   then it must be specified using HTTP/HTTPS protocol.
#' @param file_size How big is the file? Optional. `NA` by default. If it's
#'   bigger than `max_file_size` and the function is run in interactive mode,
#'   then an interactive menu is displayed, asking for permission to download
#'   the file.
#'
#' @return An `sf` object or, when `download_only` argument equals `TRUE`, a
#'   character vector.
#' @export
#'
#' @examples
#' # Read an existing .pbf file. First we need to copy a .pbf file into a
#' # temporary directory
#'
#' file.copy(
#'   from = system.file("its-example.osm.pbf", package = "osmextract"),
#'   to = file.path(tempdir(), "its-example.osm.pbf")
#' )
#' my_pbf = file.path(tempdir(), "its-example.osm.pbf")
#' oe_read(my_pbf)
#'
#' # Read a new layer
#' oe_read(my_pbf, layer = "points")
#'
#' # The following example shows how to add new tags
#' names(oe_read(my_pbf, extra_tags = c("oneway", "ref"), quiet = TRUE))
#'
#' # Read an existing .gpkg file. This file was created by oe_read
#' my_gpkg = file.path(tempdir(), "its-example.gpkg")
#' oe_read(my_gpkg)
#'
#' # You cannot add any new layer to an existing .gpkg file but you can extract
#' # some of the tags in other_tags. Check oe_get_keys() for more details.
#' names(oe_read(my_gpkg, extra_tags = c("maxspeed"))) # doesn't work
#' # Instead, use the query argument
#' names(oe_read(
#'   my_gpkg,
#'   quiet = TRUE,
#'   query =
#'   "SELECT *,
#'   hstore_get_value(other_tags, 'maxspeed') AS maxspeed
#'   FROM lines
#'   "
#' ))
#'
#' # Read from a URL
#' my_url = "https://github.com/ropensci/osmextract/raw/master/inst/its-example.osm.pbf"
#' # Please note that if you read from a URL which is not linked to one of the
#' # supported providers, you need to specify the provider parameter:
#' \dontrun{
#' oe_read(my_url, provider = "test", quiet = FALSE)}
#'
#' # Remove .pbf and .gpkg files in tempdir
#' oe_clean(tempdir())
oe_read = function(
  file_path,
  layer = "lines",
  ...,
  provider = NULL,
  download_directory = oe_download_directory(),
  file_size = NULL,
  force_download = FALSE,
  max_file_size = 5e+8,
  download_only = FALSE,
  skip_vectortranslate = FALSE,
  vectortranslate_options = NULL,
  osmconf_ini = NULL,
  extra_tags = NULL,
  force_vectortranslate = FALSE,
  never_skip_vectortranslate = FALSE,
  boundary = NULL,
  boundary_type = c("spat", "clipsrc"),
  quiet = FALSE
) {

  # Test misspelt arguments
  check_layer_provider(layer, provider)

  # Check that all arguments inside ... are named arguments. See also
  # https://github.com/ropensci/osmextract/issues/234. I extract the names in
  # ... and save the result in dots_names since names(list(...)) returns an
  # error when there is a missing element in ... See the examples in utils.R. I
  # need to check null and "" values. See utils.R for examples. See
  # https://github.com/ropensci/osmextract/issues/241 and corresponding PR for a
  # discussion.
  dots_names = extract_dots_names_safely(...)
  if (...length() && (any(is.null(dots_names)) | any(dots_names == ""))) {
    stop_custom(
      .subclass = "osmext-names-dots-error",
      message = "All arguments in oe_get() and oe_read() beside 'place' and 'layer' must be named. Please check also that you didn't add an extra comma at the end of your call.",
    )
  }

  # Test if there is a misalignment between query and layer argument. See also
  # https://github.com/ropensci/osmextract/issues/122. Moreover, I had to use
  # ...names() instead of names(list(...)) because of
  # https://github.com/ropensci/osmextract/issues/234
  if ("query" %in% dots_names) {
    # Check if the query argument (which is passed to sf::st_read) was defined using a
    # layer different than layer argument. Indeed:
    # Extracted from sf::st_read docs: For query with a character dsn the query
    # text is handed to 'ExecuteSQL' on the GDAL/OGR data set and will result in
    # the creation of a new layer (and layer is ignored).
    # See also https://github.com/ropensci/osmextract/issues/122
    query = list(...)[["query"]]

    # Extract everything that is specified after FROM or from
    query_pattern = "(?<=(FROM|from))\\s*\\S+"
    layer_raw = regmatches(query, regexpr(query_pattern, query, perl = TRUE))

    if (length(layer_raw) != 1L) {
      stop(
        "There is an error in the query or in oe_read. Please open a new issue at ",
        "https://github.com/ropensci/osmextract/issues",
        call. = FALSE
      )
    }

    # Clean all extra text (such as ' or ")
    layer_clean = regmatches(
      layer_raw[[1]],
      gregexpr("\\w+", layer_raw[[1]], perl = TRUE)
    )

    if (length(layer_clean) != 1L) {
      stop(
        "There is an error in the query or in oe_read. Please open a new issue at ",
        "https://github.com/ropensci/osmextract/issues",
        call. = FALSE
      )
    }

    if (layer_clean[[1]] != layer) {
      layer = layer_clean[[1]]
    }
  }

  # See https://github.com/ropensci/osmextract/issues/114
  if (
    # The following condition checks if the user passed down one or more
    # arguments using ...
    ...length() > 0L &&
    # At the moment, the only function that uses ... is sf::st_read, so I can
    # simply check which arguments in ... are not included in the formals of
    # sf::st_read. Moreover, st_read should always use sf:::st_read.character,
    # so I need to check the formals of that method.

    # The classical way should be names(formals(sf:::st_read.character)), but it
    # returns a notes in the R CMD checks related to :::. Hence, I decided to
    # use names(formals("st_read.character", envir = getNamespace("sf")))
    any(
      dots_names %!in%
      # The ... arguments in st_read are passed to st_as_sf so I need to add the
      # formals of st_as_sf.
      # See https://github.com/ropensci/osmextract/issues/152
      unique(c(
        names(formals(get("st_read.character", envir = getNamespace("sf")))),
        names(formals(get("st_as_sf.data.frame", envir = getNamespace("sf")))),
        names(formals(get("read_sf", envir = getNamespace("sf"))))
      ))
    )
  ) {
    warning(
      "The following arguments were probably misspelled: ",
      paste(
        setdiff(
          dots_names,
          union(
            names(formals(get("st_read.character", envir = getNamespace("sf")))),
            names(formals(get("st_as_sf.data.frame", envir = getNamespace("sf"))))
          )
        ),
        collapse = " - "
      ),
      call. = FALSE
    )
  }


  # If the input file_path points to an existing .gpkg file, then this is the
  # easiest case since we only need to read it:
  if (file.exists(file_path) && tools::file_ext(file_path) == "gpkg") {
    if (isTRUE(download_only)) {
      return(file_path)
    }

    return(my_st_read(dsn = file_path, layer = layer, quiet = quiet, ...))
  }

  # Now I think I can assume that file_path represents a URL or points to a .pbf
  # file. I assume that if file.exists(file_path) is FALSE then file_path is a
  # URL and I need to download the file
  if (!file.exists(file_path)) {
    # Add an if clause to check if file_path "looks like" a URL
    # See https://github.com/ropensci/osmextract/issues/134 and
    # https://stackoverflow.com/questions/3809401/what-is-a-good-regular-expression-to-match-a-url.
    # First I need to remove the whitespace at the end of the URL
    # See https://github.com/ropensci/osmextract/issues/163
    file_path = trimws(file_path)
    like_url = is_like_url(file_path)

    if (!like_url) {
      stop(
        "The input file_path does not correspond to any existing file ",
        "and it doesn't look like a URL.",
        call. = FALSE
      )
    }

    file_path = oe_download(
      file_url = file_path,
      provider = provider,
      download_directory = download_directory,
      file_size = file_size,
      force_download = force_download,
      max_file_size = max_file_size,
      quiet = quiet
    )
  }

  if (!file.exists(file_path)) {
    stop("An error occurred during the download process", call. = FALSE)
  }

  # Now file_path should always point to an existing .pbf or .gpkg file Again,
  # if file_path points to an existing .gpkg file:
  if (tools::file_ext(file_path) == "gpkg") {
    if (isTRUE(download_only)) {
      return(file_path)
    }

    return(my_st_read(dsn = file_path, layer = layer, quiet = quiet, ...))
  }

  # Now file_path should always point to an existing .pbf file. If the user set
  # skip_vectortranslate = TRUE, then we just need to return the pbf path or
  # read it.
  if (
    tools::file_ext(file_path) == "pbf" &&
    isTRUE(skip_vectortranslate)
  ) {
    if (isTRUE(download_only)) {
      return(file_path)
    }

    return(my_st_read(dsn = file_path, layer = layer, quiet = quiet, ...))
  }

  # The vectortranslate operation should never be skipped if the user forced the
  # download of a new .osm.pbf file. See
  # https://github.com/ropensci/osmextract/issues/144.
  if (isTRUE(force_download)) {
    never_skip_vectortranslate = TRUE
    force_vectortranslate = TRUE
  }

  # Now I think we can assume that file_path points to an existing .pbf file and
  # skip_vectortranslate is equal to FALSE so we need to use
  # oe_vectortranslate():
  gpkg_file_path = oe_vectortranslate(
    file_path = file_path,
    vectortranslate_options = vectortranslate_options,
    layer = layer,
    osmconf_ini = osmconf_ini,
    extra_tags = extra_tags,
    force_vectortranslate = force_vectortranslate,
    never_skip_vectortranslate = never_skip_vectortranslate,
    boundary = boundary,
    boundary_type = boundary_type,
    quiet = quiet
  )

  # Return the .gpkg file path
  if (isTRUE(download_only)) {
    return(gpkg_file_path)
  }

  # Add another test since maybe there was an error during the vectortranslate process:
  if (!file.exists(gpkg_file_path)) {
    stop("An error occurred during the vectortranslate process", call. = FALSE)
  }

  # Read the file
  my_st_read(gpkg_file_path, layer = layer, quiet = quiet, ...)
}
