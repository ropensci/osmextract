#' Read a `.pbf` or `.gpkg` object from file or URL
#'
#' This function is used to read a `.pbf` or `.gpkg` object from file or URL. It
#' is a wrapper around [oe_download()], [oe_vectortranslate()] and
#' [sf::st_read()], creating an easy way to download, convert, and read a `.pbf`
#' or `.gpkg` file. Check the introductory vignette and the help pages of the
#' wrapped function for more details.
#'
#'
#' @details The arguments `provider`, `download_directory`, `file_size`,
#'   `force_download`, and `max_file_size` are ignored if `file_path` points to
#'   an existing `.pbf` or `.gpkg` file.
#'
#'   You cannot add any layer to an existing `.gpkg` file but you can extract
#'   some of the tags in `other_tags` field. Check [oe_get_keys()] for more
#'   details.
#'
#' @inheritParams oe_get
#' @param file_path A url or the path of a `.pbf` or `.gpkg` file. If it is a
#'   URL it must be specified using HTTP/HTTPS protocol.
#' @param file_size How big is the file? Optional. `NA` by default. If it's
#'   bigger than `max_file_size` and the function is run in interactive mode,
#'   then an interactive menu is displayed, asking for permission for
#'   downloading the file.
#'
#' @return An `sf` object.
#' @export
#'
#' @examples
#' # Read an existing .pbf file
#' my_pbf = system.file("its-example.osm.pbf", package = "osmextract")
#' oe_read(my_pbf, quiet = FALSE)
#' oe_read(my_pbf, layer = "points", quiet = FALSE) # Read a new layer
#' # The following example shows how to add new tags
#' oe_read(my_pbf, extra_tags = c("oneway", "ref"), quiet = FALSE)
#'
#' # Read an existing .gpkg file. This file was created by oe_read
#' my_gpkg = system.file("its-example.gpkg", package = "osmextract")
#' oe_read(my_gpkg, quiet = FALSE)
#' # You cannot add any layer to an existing .gpkg file but you can extract some
#' # of the tags in other_tags. Check oe_get_keys() for more details.
#' names(oe_read(my_gpkg, extra_tags = c("maxspeed")))
#' # Delete the .gpkg file not to mess with other examples
#' file.remove(my_gpkg)
#'
#' # Read from a URL
#' my_url = "https://github.com/ITSLeeds/osmextract/raw/master/inst/its-example.osm.pbf"
#' # Please note that if you read from a URL which is not linked to one of the
#' # supported providers, you need to specify the provider parameter:
#' \dontrun{
#' oe_read(my_url, provider = "test", quiet = FALSE)
#' }
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
  quiet = TRUE
) {

  # See https://github.com/ITSLeeds/osmextract/issues/114
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
      names(formals("st_read.character", envir = getNamespace("sf")))
    )
  ) {
    warning(
      "The following arguments are probably misspelled: ",
      setdiff(
        names(list(...)),
        names(formals("st_read.character", envir = getNamespace("sf")))
      ),
      call. = FALSE,
      immediate. = TRUE
    )
  }


  # If the input file_path is an existing .gpkg file is the easiest case since
  # we only need to read it:
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
    # See https://github.com/ITSLeeds/osmextract/issues/134 and
    # https://stackoverflow.com/questions/3809401/what-is-a-good-regular-expression-to-match-a-url
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
    quiet = quiet
  )

  # This is just for returning the .gpkg file path in case I need it for
  # something
  if (isTRUE(download_only)) {
    return(gpkg_file_path)
  }


  # Read the translated file with sf::st_read
  sf::st_read(
    dsn = gpkg_file_path,
    layer = layer,
    quiet = quiet,
    ...
  )
}
