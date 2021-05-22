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
#' @param values TODO
#' @param which_keys TODO
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
oe_get_keys = function(zone, layer = "lines", values = FALSE, which_keys = NULL) {
  UseMethod("oe_get_keys")
}

#' @name oe_get_keys
#' @export
oe_get_keys.default = function(zone, layer = "lines", values = FALSE, which_keys = NULL) {
  stop(
    "At the moment there is no support for objects of class ",
    class(zone)[1], ".",
    " Feel free to open a new issue at github.com/ropensci/osmextract",
    call. = FALSE
  )
}

#' @name oe_get_keys
#' @export
oe_get_keys.character = function(zone, layer = "lines", values = FALSE, which_keys = NULL) {
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

  get_keys(obj[["other_tags"]], values = values, which_keys = which_keys)
}

#' @name oe_get_keys
#' @export
oe_get_keys.sf = function(zone, layer = "lines", values = FALSE, which_keys = NULL) {
  if ("other_tags" %!in% names(zone)) {
    stop("The input object must have an other_tags field.", call. = FALSE)
  }

  get_keys(zone[["other_tags"]], values = values, which_keys = which_keys)
}

# The following is an internal function used to extract the keys
get_keys = function(text, values = FALSE, which_keys = NULL) {
  # 0. Preprocess the text and remove all "\n". See
  # https://github.com/ropensci/osmextract/pull/202#issuecomment-846077516
  text <- gsub("\n", "", text)

  # 1. Define regexp for keys and search for matches
  regexp_keys <- gregexpr(
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

  # 2. Extract the keys
  keys <- regmatches(text, regexp_keys)

  # 3. If values is FALSE, then just return the (unique) keys
  if (isFALSE(values)) {
    return(unique(unlist(keys)))
  }

  # 4. Otherwise, we need to extract also the values. I will use a regex that is
  # analogous to the previous query (inverting the lookahead and lookbehind)
  regexp_values <- gregexpr(
    pattern = '(?<=(\\"=>\\")).+?(?=\\"$|\\",)',
    text = text,
    perl = TRUE
  )

  # 5. Extract the values
  values <- regmatches(text, regexp_values)

  # 6. Check that each key corresponds to a value
  if (!all(lengths(keys) == lengths(values))) {
    stop(
      "There are more keys than values (or vice versa). ",
      "Please raise a new issue at https://github.com/ropensci/osmextract",
      call. = FALSE
    )
  }

  # 7. Unlist the two objects
  keys <- unlist(keys)
  values <- unlist(values)
  nums <- sort(table(keys), decreasing = TRUE)
  keys <- factor(keys, levels = names(nums))

  # 8. Nest the two objects
  nested_key_values <- split(values, keys)

  # 9. If which is not NULL, then filter only the corresponding keys
  if (!is.null(which_keys)) {
    idx <- names(nested_key_values) %in% which_keys
    nested_key_values <- nested_key_values[idx]
  }

  # 9. nested_key_values is just a nested list but, unfortunately, the default
  # printing method is quite difficult to understand. Hence, I will assign a new
  # class and define a new printing method.
  structure(nested_key_values, class = c("oe_key_values_list", class(nested_key_values)))
}

#' @export
print.oe_key_values_list <- function(x, n = NULL, ...) {
  # Set n. The default value can be set using the option named oe.max.print.keys
  if (is.null(n)) {
    n <- getOption("oe.max.print.keys", 10L)
  }

  # Truncate the top n elements
  print_truncated <- FALSE
  if (length(x) > n) {
    x <- x[seq_len(n)]
    print_truncated <- TRUE
  }

  # Process each key and create a table-like format
  res <- lapply(x, function(values) {
    tab <- sort(table(values), decreasing = TRUE)
    paste(paste0("#", names(tab)), tab, sep = " = ", collapse = "; ")
  })

  # Extract all keys
  keys <- names(res)

  # Extract the page-width (i.e. the number of chars used by the consol)
  my_width <- getOption("width")

  for (i in seq_len(min(n, length(x)))) {
    cat(keys[i], "= {")
    cat(
      if (nchar(encodeString(res[[i]])) <= (
        my_width + nchar(encodeString(keys[i]), type = "width") + 6
        )
      ) {
        res[[i]]
      } else {
        paste0(strtrim(res[[i]], my_width - nchar(encodeString(keys[i]), type = "width") - 8), " ...")
      }
    )
    cat("}\n")
  }
  if (print_truncated) cat("[Truncated output...]")

  # Return
  invisible(x)
}
