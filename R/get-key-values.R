#' Return all keys stored in "other_tags" column
#'
#' This function returns the names of all keys that are stored in `other_tags`
#' column. See Details.
#'
#' @details OSM data are typically documented using several
#'   [`tags`](https://wiki.openstreetmap.org/wiki/Tags), i.e. pairs of two
#'   items, namely a `key` and a `value`. As documented in
#'   [`oe_vectortranslate()`], the conversion between `.osm.pbf` and `.gpkg`
#'   formats is governed by a `CONFIG` file that lists which tags must be
#'   explicitly added to the `.gpkg` file, while all the other keys are
#'   automatically stored using an `other_tags` field with a syntax compatible
#'   with the PostgreSQL HSTORE type. This function can be used to display the
#'   names of all keys stored in the `other_tags` field.
#'
#'   The `hstore_get_value()` function can be used inside the `query` argument
#'   to extract one particular tag from an existing file. Check the introductory
#'   vignette and see examples.
#'
#'   The definition of a generic S3 implementation started in
#'   [osmextract/issues/138](https://github.com/ropensci/osmextract/issues/138).
#'
#' @seealso `oe_vectortranslate()` and
#'   [osmextract/issues/107](https://github.com/ropensci/osmextract/issues/107).
#'
#' @inheritParams oe_get
#' @param zone An `sf` object with an `other_tags` field, or a character vector
#'   (of length 1) that points to a `.osm.pbf` or `.gpkg` file with an
#'   `other_tags` field.
#'
#' @return A character vector indicating the name of all keys stored in
#'   "other_tags" field.
#' @export
#'
#' @examples
#' # Get keys from pbf file
#' itsleeds_pbf_path = oe_download(
#'   oe_match("ITS Leeds")$url,
#'   download_directory = tempdir(),
#'   provider = "test"
#' )
#' oe_get_keys(itsleeds_pbf_path)
#' itsleeds_gpkg_path = oe_get(
#'   "ITS Leeds",
#'   download_only = TRUE,
#'   download_directory = tempdir(),
#'   quiet = TRUE
#' )
#' itsleeds_gpkg_path
#' oe_get_keys(itsleeds_gpkg_path)
#'
#' itsleeds = oe_get("ITS Leeds", quiet = TRUE, download_directory = tempdir())
#' oe_get_keys(itsleeds)
#'
#' # Add an extra key to an existing .gpkg file without vectortranslate
#' names(oe_read(
#'   itsleeds_gpkg_path,
#'   query = "SELECT *,  hstore_get_value(other_tags, 'oneway')  AS oneway FROM lines"
#' ))
#'
#' # Remove .pbf and .gpkg files in tempdir
#' # (since they may interact with other examples)
#' file.remove(list.files(path = tempdir(), pattern = "(pbf|gpkg)", full.names = TRUE))
oe_get_keys = function(zone, layer = "lines") {
  UseMethod("oe_get_keys")
}

#' @name oe_get_keys
#' @export
oe_get_keys.default = function(zone, layer = "lines") {
  stop(
    "At the moment there is no support for objects of class ",
    class(zone)[1], ".",
    " Feel free to open a new issue at github.com/ropensci/osmextract",
    call. = FALSE
  )
}

#' @name oe_get_keys
#' @export
oe_get_keys.character = function(zone, layer = "lines") {
  if (length(zone) != 1L) {
    stop("The input file must have length 1", call. = FALSE)
  }

  if (!file.exists(zone)) {
    stop(
      "The input file does not exist.",
      "You can download it using oe_get(zone, download_only = TRUE).",
      call. = FALSE
    )
  }

  # Check that the input file contains the other_tags field
  # See also https://github.com/ropensci/osmextract/issues/158
  existing_fields = colnames(
    sf::st_read(
      dsn = zone,
      layer = layer,
      query = paste0("SELECT * FROM ", layer, " LIMIT 0"),
      quiet = TRUE
    )
  )

  if ("other_tags" %!in% existing_fields) {
    stop(
      "The input file must have an other_tags field.",
      " You may need to rerun the vectortranslate process.",
      call. = FALSE
    )
  }

  # Read the gpkg file selecting only the other_tags column.
  # The query is different between .pbf and .gpkg objects. See also
  # https://github.com/ropensci/osmextract/discussions/188
  if (tools::file_ext(zone) == "pbf") {
    query_for_other_tags = paste0("select other_tags from ", layer)
  } else if (tools::file_ext(zone) == "gpkg") {
    query_for_other_tags = paste0("select other_tags, geometry from ", layer)
  } else {
    stop("The input file must have .pbf or .gpkg extension", call. = FALSE)
  }

  obj = sf::st_read(
    dsn = zone,
    layer = layer,
    query = query_for_other_tags,
    quiet = TRUE
  )

  get_keys(obj[["other_tags"]])
}

#' @name oe_get_keys
#' @export
oe_get_keys.sf = function(zone, layer = "lines") {
  if ("other_tags" %!in% names(zone)) {
    stop("The input object must have an other_tags field.", call. = FALSE)
  }

  get_keys(zone[["other_tags"]])
}

# The following is an internal function used to extract the keys
get_keys = function(text) {
  # 1. Search for matches
  regexp_matches <- gregexpr(
    # The other_tags field uses the following structure:
    # "KEY1"=>"VALUE1","KEY2"=>"VALUE2" and so on
    # The following regex should match all characters that:
    # 1. Follow ^" or ," (where ^ denotes the start of a line)
    # and
    # 2. Precede the character "=>" (i.e. the delimiter)
    pattern = '(?<=^\\"|,\\").+?(?=\\"=>\\")',
    text = text,
    perl = TRUE
  )

  # 2. Extract those matches
  unique(unlist(regmatches(text, regexp_matches)))
}
