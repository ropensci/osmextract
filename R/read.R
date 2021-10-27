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
#'   You cannot add any field or layer to an existing `.gpkg` file (unless you
#'   have the `.pbf` file and you convert it again with a different
#'   configuration), but you can extract some of the tags in `other_tags` field.
#'   Check examples and [oe_get_keys()] for more details.
#'
#' @inheritParams oe_get
#' @param file_path A URL or the path of a `.pbf` or `.gpkg` file. If a URL,
#'   then it must be specified using HTTP/HTTPS protocol.
#' @param file_size How big is the file? Optional. `NA` by default. If it's
#'   bigger than `max_file_size` and the function is run in interactive mode,
#'   then an interactive menu is displayed, asking for permission to download
#'   the file.
#'
#' @return An `sf` object.
#' @export
#'
#' @examples
#' # Read an existing .pbf file. First we need to copy a .pbf file into a
#' # temporary directory
#' file.copy(
#'   from = system.file("its-example.osm.pbf", package = "osmextract"),
#'   to = file.path(tempdir(), "its-example.osm.pbf")
#' )
#'
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
#' # You cannot add any layer to an existing .gpkg file but you can extract some
#' # of the tags in other_tags. Check oe_get_keys() for more details.
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
#' # (since they may interact with other examples)
#' file.remove(list.files(path = tempdir(), pattern = "(pbf|gpkg)", full.names = TRUE))
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

  # Test if there is misalignment between query and layer. See also
  # See https://github.com/ropensci/osmextract/issues/122
  if ("query" %in% names(list(...))) {
    # Check if the query argument defined in sf::st_read was defined using a
    # layer different than layer argument.
    # Extracted from sf::st_read docs: For query with a character dsn the query
    # text is handed to 'ExecuteSQL' on the GDAL/OGR data set and will result in
    # the creation of a new layer (and layer is ignored) See also
    # https://github.com/ropensci/osmextract/issues/122
    query = list(...)[["query"]]

    # Extract everything that is specified after FROM or from
    query_pattern = "(?<=(FROM|from))\\s*\\S+"
    layer_raw = regmatches(query, regexpr(query_pattern, query, perl = TRUE))

    if (length(layer_raw) != 1L) {
      stop(
        "There is an error in the query. Please open a new issue at ",
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
        "There is an error in the query. Please open a new issue at ",
        "https://github.com/ropensci/osmextract/issues",
        call. = FALSE
      )
    }

    if (layer_clean[[1]] != layer) {
      warning(
        "The query selected a layer which is different from layer argument. ",
        "We will replace the layer argument.",
        call. = FALSE
      )
      layer = layer_clean[[1]]
    }
  }

  # See https://github.com/ropensci/osmextract/issues/114
  if (
    # The following condition checks if the user passed down one or more
    # arguments using ...
    ...length() > 0L &&
    # At the moment, the only function that uses ... is sf::st_read, so I can
    # simply check which arguments in ... are not inlucded in the formals of
    # sf::st_read. Moreover, st_read should always use sf:::st_read.character,
    # so I need to check the formals of that method.
    #
    # The classical way should be names(formals(sf:::st_read.character)), but it
    # returns a notes in the R CMD checks related to :::. Hence, I decided to
    # use names(formals("st_read.character", envir = getNamespace("sf")))
    any(
      names(list(...)) %!in%
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
      "The following arguments are probably misspelled: ",
      paste(
        setdiff(
          names(list(...)),
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


  # If the input file_path is an existing .gpkg file, then this is the easiest
  # case since we only need to read it:
  if (file.exists(file_path) && tools::file_ext(file_path) == "gpkg") {
    # I need the following if to return the .gpkg file path in oe_get
    if (isTRUE(download_only)) {
      return(file_path)
    }

    return(sf::st_read(file_path, layer, quiet = quiet, ...))
  }

  # Now I think I can assume that file_path is a URL or points to a .pbf file. I
  # assume that if file.exists(file_path) is FALSE then file_path is a URL and I
  # need to download the file
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

  # Now file_path should always be the path to an existing .pbf or .gpkg file
  # Again, if file_path points to an existing .gpkg file:
  if (file.exists(file_path) && tools::file_ext(file_path) == "gpkg") {
    if (isTRUE(download_only)) {
      return(file_path)
    }

    return(sf::st_read(file_path, layer, quiet = quiet, ...))
  }

  # Now file_path should always point to an existing .pbf file. If the user set
  # skip_vectortranslate = TRUE, then we just need to return the pbf path or
  # read it.
  if (
    file.exists(file_path) &&
    tools::file_ext(file_path) == "pbf" &&
    isTRUE(skip_vectortranslate)
  ) {
    if (isTRUE(download_only)) {
      return(file_path)
    }

    return(sf::st_read(file_path, layer, quiet = quiet, ...))
  }

  # See https://github.com/ropensci/osmextract/issues/144. The vectortranslate
  # operation should never be skipped if the user forced the download of a new
  # .osm.pbf file.
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

  # This is just for returning the .gpkg file path in case I need it for
  # something
  if (isTRUE(download_only)) {
    return(gpkg_file_path)
  }

  # Add another test since maybe there was an error during the vectortranslate process:
  if (!file.exists(gpkg_file_path)) {
    stop("An error occurred during the vectortranslate process", call. = FALSE)
  }

  # Read the translated file with sf::st_read. Moreover, starting from sf 1.0.2,
  # sf::st_read raises a warning message when both layer and query arguments are
  # set (while it raises a warning in sf < 1.0.2 when there are multiple layers
  # and the layer argument is not set). See also
  # https://github.com/r-spatial/sf/issues/1444

  if (utils::packageVersion("sf") <= "1.0.1") {
    sf::st_read(
      dsn = gpkg_file_path,
      layer = layer,
      quiet = quiet,
      ...
    )
  } else {
    if ("query" %in% names(list(...))) {
      sf::st_read(
        dsn = gpkg_file_path,
        quiet = quiet,
        ...
      )
    } else {
      sf::st_read(
        dsn = gpkg_file_path,
        layer = layer,
        quiet = quiet,
        ...
      )
    }
  }
}
