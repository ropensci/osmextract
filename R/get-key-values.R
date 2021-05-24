#' Return keys and (optionally) values stored in "other_tags" column
#'
#' This function returns the OSM keys and (optionally) the values stored in the
#' `other_tags` field. See Details. In both cases, the keys are sorted according
#' to the number of occurrences, which means that the most common keys are
#' stored first.
#'
#' @details OSM data are typically documented using several
#' [`tags`](https://wiki.openstreetmap.org/wiki/Tags), i.e. pairs of two
#' items, namely a `key` and a `value`. The conversion between `.osm.pbf` and
#' `.gpkg` formats is governed by a `CONFIG` file that lists which tags must
#' be explicitly added to the `.gpkg` file. All the other keys are
#' automatically stored using an `other_tags` field with a syntax compatible
#' with the PostgreSQL HSTORE type. See
#' [here](https://gdal.org/drivers/vector/osm.html#driver-capabilities) for
#' more details.
#'
#' When the argument `values` is `TRUE`, then the function returns a named list
#' of class `oe_key_values_list` that, for each key, summarises the
#' corresponding values. The key-value pairs are stored using the following
#' format:
#' `list(key1 = c("value1", "value1", "value2", ...), key2 = c("value1", ...) ...)`.
#' We decided to implement an ad-hoc method for printing objects of class
#' `oe_key_values_list` using the following structure:\preformatted{
#' key1 = {#value1 = n1; #value2 = n2; #value3 = n3, ...}
#' key2 = {#value1 = n1; #value2 = n2; ...}
#' key3 = {#value1 = n1}
#' ...
#' }
#' where `n1` denotes the number of times that value1 is repeated, `n2` denotes
#' the number of times that value2 is repeated and so on. Also the values are
#' listed according to the number of occurrences in decreasing order. By
#' default, the function prints only the ten most common keys, but the number
#' can be adjusted using the option `oe_max_print_keys`.
#'
#' Finally, the `hstore_get_value()` function can be used inside the `query`
#' argument in `oe_get()` to extract one particular tag from an existing file.
#' Check the introductory vignette and see examples.
#'
#' @seealso `oe_vectortranslate()`
#'
#' @inheritParams oe_get
#' @param zone An `sf` object with an `other_tags` field or a character vector
#'   (of length 1) that can be linked to or pointing to a `.osm.pbf` or `.gpkg`
#'   file with an `other_tags` field. Character vectors are linked to `.osm.pbf`
#'   files using `oe_find()`.
#' @param values Logical. If `TRUE`, then function returns the keys and the
#'   corresponding values, otherwise only the keys. Defaults to `FALSE. `
#' @param which_keys Character vector used to subset only some keys and
#'   corresponding values. Ignored if `values` is `FALSE`. See examples.
#' @param ... Ignored.
#'
#' @return If the argument `values` is `FALSE` (the default), then the function
#'   returns a character vector with the names of all keys stored in the
#'   `other_tags` field. If `values` is `TRUE`, then the function returns named
#'   list which stores all keys and the corresponding values. In the latter
#'   case, the returned object has class `oe_key_values_list` and we defined an
#'   ad-hoc printing method. See Details.
#'
#' @export
#'
#' @examples
#' # Get keys from an OSM extract
#' oe_get_keys("ITS Leeds")
#'
#' # Get keys and values
#' oe_get_keys("ITS Leeds", values = TRUE)
#'
#' # Subset some keys
#' oe_get_keys("ITS Leeds", values = TRUE, which_keys = c("surface", "lanes"))
#'
#' # Print all (non-NA) values for a given key
#' oe_get_keys("ITS Leeds", values = TRUE)["surface"]
#'
#' # Get keys from an existing sf object
#' its = oe_get("ITS Leeds")
#' oe_get_keys(its, values = TRUE)
#'
#' # Get keys from a character vector pointing to a file (might be faster than
#' # reading the complete file)
#' its_path = oe_get("ITS Leeds", download_only = TRUE)
#' oe_get_keys(its_path, values = TRUE)
#'
#' # Add an extra key to an existing .gpkg file without repeating the
#' # vectortranslate operations
#' colnames(its)
#' colnames(oe_read(
#'   its_path,
#'   query = "SELECT *,  hstore_get_value(other_tags, 'oneway') AS oneway FROM lines",
#'   quiet = TRUE
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
    stop("The input must have length 1", call. = FALSE)
  }

  if (!file.exists(zone)) {
    # Test if the input zone can be matched with one of the existing files,
    # otherwise stop
    zone = tryCatch(
      error = function(cnd) {
        stop(
          "The input file does not exist and can't be matched with any existing file.",
          " You can download it using oe_get(zone, download_only = TRUE).",
          call. = FALSE
        )
      },
      warning = function(cnd) {
        stop(
          "The input file does not exist and can't be matched with any existing file.",
          " You can download it using oe_get(zone, download_only = TRUE).",
          call. = FALSE
        )
      },
      oe_find(zone, quiet = TRUE)
    )

    if (length(zone) > 1L) {
      zone = zone[1L]
    }
  }

  if (tools::file_ext(zone) %!in% c("gpkg", "pbf")) {
    stop("The input file must have .pbf or .gpkg extension", call. = FALSE)
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

  # Read the gpkg or pbf file selecting only the other_tags column.
  obj = sf::st_read(
    dsn = zone,
    layer = layer,
    query = paste0("select other_tags from ", layer),
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

# The following is an internal function used to extract the keys and the values
get_keys = function(text, values = FALSE, which_keys = NULL) {
  # 0. Preprocess the text input and remove all "\n". See
  # https://github.com/ropensci/osmextract/pull/202#issuecomment-846077516
  text = gsub("\n", "", text)

  # 1. Define regexp for keys and search for matches
  regexp_keys = gregexpr(
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
  keys = regmatches(text, regexp_keys)

  # 3. If values is FALSE, then just return the (unique and sorted) keys
  if (isFALSE(values)) {
    keys = unlist(keys)
    nums = sort(table(keys), decreasing = TRUE)
    keys = factor(keys, levels = names(nums))
    return(levels(keys))
  }

  # 4. Otherwise, we need to extract the values. I will use a regex that is
  # analogous to the previous query (inverting the lookahead and lookbehind)
  regexp_values = gregexpr(
    pattern = '(?<=(\\"=>\\")).+?(?=\\"$|\\",)',
    text = text,
    perl = TRUE
  )

  # 5. Extract the values
  values = regmatches(text, regexp_values)

  # 6. Check that each key corresponds to a value
  if (!all(lengths(keys) == lengths(values))) {
    stop(
      "There are more keys than values (or vice-versa). ",
      "Please raise a new issue at https://github.com/ropensci/osmextract",
      call. = FALSE
    )
  }

  # 7. Unlist and sort the two objects
  keys = unlist(keys)
  values = unlist(values)
  nums = sort(table(keys), decreasing = TRUE)
  keys = factor(keys, levels = names(nums))

  # 8. Nest the two objects
  nested_key_values = split(values, keys)

  # 9. If which_kyes is not NULL, then filter only the corresponding keys
  if (!is.null(which_keys)) {
    idx = names(nested_key_values) %in% which_keys
    nested_key_values = nested_key_values[idx]
  }

  # 10. The object nested_key_values is a nested list. Unfortunately, the
  # default printing method is quite difficult to understand. Hence, I will
  # assign a new class and define a new printing method.
  structure(nested_key_values, class = c("oe_key_values_list", class(nested_key_values)))
}

#' @name oe_get_keys
#' @param x object of class `oe_key_values_list`
#' @param n Maximum number of keys (and corresponding values) to print; can be
#'   set globally by `options(oe_max_print_keys=...)`. Default value is 10.
#' @export
print.oe_key_values_list = function(x, n = getOption("oe_max_print_keys", 10L), ...) {
  # Truncate the top n elements
  print_truncated = FALSE
  if (length(x) > n) {
    x = x[seq_len(n)]
    print_truncated = TRUE
  }

  # Process each key and create a table-like format for the values
  x = lapply(x, function(values) {
    tab = sort(table(values), decreasing = TRUE)
    paste(paste0("#", names(tab)), tab, sep = " = ", collapse = "; ")
  })
  # The output is like list(key1 = "#value1 = n1; #value2 = n2;...").

  # Extract the names of all keys (since I want to create an output like key =
  # {table of values} and I'm not sure how to extract the keys inside the for
  # loop)
  keys = names(x)

  # Extract the page-width (i.e. the number of chars used by the console). I
  # don't want to print an output which is too long for the given console.
  my_width = getOption("width")

  # Print the output using a for loop. I think that nobody wants to print
  # hundreds of thousands of keys, so this shouldn't be a bottleneck.
  for (i in seq_len(min(n, length(x)))) {
    # As written before, I want to create an output like:
    # key = {#value1 = n1; #value2 = n2; ...}
    # so I start printing the ith key and the opening curly bracket
    cat(keys[i], "= {")
    # Then I need to check the number of characters of the string that
    # summarises the values corresponding to the ith key. The object
    # width_keys_and_brackets counts the number of characters taken my the ith
    # key, the opening and clonsing curly brackets and the ...
    width_keys_and_brackets = nchar(encodeString(keys[i]), type = "width") + 6
    # If nchar(encodeString(x[[i]])) is longer than the available number of
    # characters, i.e. my_width - width_keys_and_brackets, then I need to
    # truncate the output.
    if (nchar(encodeString(x[[i]])) > my_width - width_keys_and_brackets) {
      cat(paste0(strtrim(x[[i]], my_width - width_keys_and_brackets - 2), "..."))
    } else {
      cat(x[[i]])
    }
    # Print the closing bracket
    cat("}\n")
  }
  if (print_truncated) cat("[Truncated output...]")

  # Return
  invisible(x)
}
